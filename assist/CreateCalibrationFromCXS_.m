function [CalSet,CalSet_, CalSet__] = CreateCalibrationFromCXS_(HBB, T_hot, CBB, T_cold,T_mirror, emis, em2);
% [CalSet,CalSet_, CalSet__] = CreateCalibrationFromCXS_(HBB, T_hot, CBB, T_cold,T_mirror, emis, em2);
% Returns complex gain [radiance/cts] and offset [cts]
% CalSet has realistic emissivity and mirror temperature effects
% CalSet_ has realistic emissivity but no mirror temperature effects
% CalSet__ has unity emissivity and no mirror temperature effects
% HBB is a structure with Header, x and y for the hot calibration target
% T_hot is the temperature of the hot target
% CBB is a structure with Header, x and y for the cold calibration target
% T_cold is the temperature of the cold target
% yields radiance units of mW(m^2 sr cm^-1)
% I'm turning this around so gain is multiplicative
if ~exist('T_mirror','var')
   T_mirror = T_cold;
end
if ~exist('emis', 'var')
    em = 0.998.*ones(size(HBB.x));
else
    em = interp1(emis.x, emis.y, HBB.x, 'pchip','extrap');
end
if ~exist('em2','var')
   em2 = em;
end
if isstruct(em2)
   em2_ = interp1(em2.x, em2.y, HBB.x, 'pchip','extrap');
   em2 = em2_;
end
% Assume emissivity is unity
BB_hot__ = Blackbody(HBB.x, T_hot); 
BB_cold__ = Blackbody(CBB.x, T_cold);

% Use varying non-unity emissivity but neglect self-light
BB_hot_ = em.*Blackbody(HBB.x, T_hot);
BB_cold_ = em2.*Blackbody(CBB.x, T_cold);

% Include both effects.
BB_hot = em.*Blackbody(HBB.x, T_hot)+(1-em).*Blackbody(HBB.x, T_mirror);
BB_cold = em2.*Blackbody(CBB.x, T_cold)+(1-em2).*Blackbody(HBB.x, T_mirror);

%%

CalSet.x = HBB.x;
% This one is clean (now)
CalSet__.LH = BB_hot__;
CalSet__.LC = BB_cold__;
CalSet__.Resp = (HBB.y - CBB.y)./(BB_hot__ - BB_cold__);
CalSet__.Offset_cts =   -CBB.y +BB_cold__.*CalSet__.Resp;
CalSet__.Offset_ru =   -CBB.y./CalSet__.Resp +BB_cold__;
CalSet__.emis = 1;
CalSet__.T_mirror = 0;

% This one has emissivity
CalSet_.Resp = (HBB.y - CBB.y)./(BB_hot_ - BB_cold_);
CalSet_.Offset_cts =   -CBB.y +BB_cold_.*CalSet_.Resp;
CalSet_.Offset_ru =   -CBB.y./CalSet_.Resp +BB_cold_;
CalSet_.emis = em;
CalSet_.T_mirror = 0;
% This one has emissivity and mirror radiance
CalSet.Resp = (HBB.y - CBB.y)./(BB_hot - BB_cold);
CalSet.Offset_cts =   BB_cold.*CalSet.Resp -CBB.y ;
CalSet.Offset_ru =    BB_cold -CBB.y./CalSet.Resp;
CalSet.emis = em;
CalSet.T_mirror = T_mirror;


%%
