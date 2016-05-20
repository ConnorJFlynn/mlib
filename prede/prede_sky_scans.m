function prede = prede_sky_scans(prede);
%read a structure containing raw prede scans, convert to ALM, PPL with
%scattering angle
% Removing concept of "scans".  Use logical to distinguish alm, ppl, etc.

%Okay, we'll try to identify contiguous alm and ppl scans.  Any other
%contiguous groups we'll classify as "custom"
% if isfield(prede,'R') %Random or custom mode

if ~exist('prede','var')
   prede = read_prede;
end
if ~isstruct(prede)&&exist(prede,'file')
    prede = read_prede(prede);
end
[Zen_Sun,Az_Sun, soldst, HA_Sun, Decl_Sun, Elev_Sun, airmass] = sunae(prede.lat, prede.lon, prede.time);
prede.Zen_Sun = Zen_Sun;
prede.Az_Sun = Az_Sun;
prede.Elev_Sun = Elev_Sun;

tracking = (abs(Zen_Sun - prede.zen)<1)&(abs(Az_Sun - prede.azi)<1); % if within 0.28 degree of sun
ZA_offset = offset_angle(Zen_Sun(tracking)*pi/180,prede.zen(tracking)*pi/180)*180/pi; 
prede.zen = prede.zen + ZA_offset;
prede.ele = 90-prede.zen;
Az_offset = offset_angle(Az_Sun(tracking)*pi/180,prede.azi(tracking)*pi/180)*180/pi; 
prede.azi = prede.azi + Az_offset;
tracking = (abs(Zen_Sun - prede.zen)<.1)&(abs(Az_Sun - prede.azi)<.1); % if within 0.28 degree of sun

%%
azi_offset = -.04;% approximate determined from commented plots below
zen_offset = 0;azi_offset = Az_offset; zen_offset = ZA_offset;
prede.SA = (180./pi).*scat_ang_rads(Zen_Sun*pi/180, Az_Sun*pi/180, (prede.zen+zen_offset)*pi/180, (prede.azi+azi_offset)*pi/180);
ppl = (prede.SA>.25)&(abs(Az_Sun - prede.azi)<abs(Zen_Sun - prede.zen)); % if within half a degree of az and outside half degree of zenith
alm = (prede.SA>.25)&(abs(Az_Sun - prede.azi)>abs(Zen_Sun - prede.zen)); % if within half a degree of zenith and outside half degree of az
prede.SA(ppl&(prede.zen<Zen_Sun)) = -prede.SA(ppl&(prede.zen<Zen_Sun));
prede.SA(alm&(prede.azi<Az_Sun)) = -prede.SA(alm&(prede.azi<Az_Sun));
% figure; plot([1:length(prede.SA)],Az_Sun - prede.azi,'o');
% zoom('on')
% ok = menu('Zoom to select desired branches to assess offset.','Done');
% xl = xlim;
% legs = (floor(xl(1)):ceil(xl(2)));
% [SA_legs, legs_ii] = sort(prede.SA(legs));
% %
% filts = [prede.filter_1(legs(legs_ii));prede.filter_2(legs(legs_ii));prede.filter_3(legs(legs_ii));prede.filter_4(legs(legs_ii));...
%     prede.filter_5(legs(legs_ii));prede.filter_6(legs(legs_ii));prede.filter_7(legs(legs_ii))];
% figure; plot(abs(SA_legs(SA_legs>.5)), filts(2:end,SA_legs>.5),'-o',abs(SA_legs(SA_legs<-.5)),filts(2:end,SA_legs<-.5), 'k-x')

% tracking = (abs(Zen_Sun - ZA)<5e-3)&(abs(Az_Sun - Azi)<5e-3); % if within
% 0.28 degree of sun

%%

prede.tracking = tracking;

% alm = (abs(ZA_diff)<1e-3)&(abs(Azi_diff)>1e-3);
% Now remove isolated points
% alm = [alm(1:2) alm(3:end)&alm(2:end-1)&alm(1:end-2) alm(end-1:end)];
% prede.alm = alm;
% if any(alm)
   contig = diff(alm)>0;
   contig = [alm(1) contig];
   contig = cumsum(contig);
   contig(~alm) = 0;
   prede.alm = contig;
% end
if max(Az_Sun) < 180
   alm_r = alm&(prede.azi>Az_Sun)&(prede.azi<(Az_Sun+180));
   alm_l = alm&~alm_r;
else
   alm_l = alm&(prede.azi<Az_Sun)&(prede.azi>(Az_Sun-180));
   alm_r = alm&~alm_l;
   alm_l = alm_l;
   alm_l = alm_l | ((prede.azi<Az_Sun));
end
ii_alm_r = find(alm_r);
% prede.SA(alm_l) = -1*prede.SA(alm_l);
prede.alm_l = alm_l;
prede.alm_r = alm_r;

prede.ppl_above = ppl&(prede.ele>Elev_Sun);
prede.ppl_below = ppl&(prede.ele<Elev_Sun);

%
% ppl = (abs(Azi_diff)<1e-3)&(abs(ZA_diff)>1e-3);
% ppl = [ppl(1) ppl(2:end)&ppl(1:end-1) ppl(end)];
% prede.ppl = ppl;
% if any(ppl)
contig = diff(ppl)>0;
contig = [ppl(1) contig];
contig = cumsum(contig);
contig(~ppl) = 0;
prede.ppl = contig;
% end
% ppl_p = ppl&(Zen_Sun < ZA);