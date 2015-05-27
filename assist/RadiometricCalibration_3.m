function [RadianceSpc] = RadiometricCalibration_3(RawSpc, CalSet);
% Returns the calibrated radiance
% RawSpc contains the raw spectra
% CalSet is the radiometric calibration dataset with elements
% CalSet.Resp = (HBB.y - CBB.y)./(BB_hot - BB_cold);
% CalSet.Offset_cts =   CBB.y -BB_cold.*CalSet.Resp;
% CalSet.Offset_ru =   CBB.y./CalSet.Resp -BB_cold;

if isfield(RawSpc,'Header')
RadianceSpc.Header = RawSpc.Header;
end
RadianceSpc.x = RawSpc.x;
% RadianceSpc.y = 0*RawSpc.y;
for ll = size(RawSpc.y, 1):-1:1
    RadianceSpc.y(ll,:) = RawSpc.y(ll,:) ./ CalSet.Resp - CalSet.Offset_ru;
end
