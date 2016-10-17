function alm = anet_alm_SA_and_radiance(alm)
% alm = anet_alm_SA_and_radiance(alm)
% Pack data from aeronet alm file into structure with radiance dimensioned
% against time and azimuth angle, and compute scattering angles.
if ~exist('alm','var')
    alm = read_cimel_aip;
end

fld = fieldnames(alm);
fld(1:13) = [];
for f = 1:length(fld)
    alm.radiance(:,f) = alm.(char(fld(f)));
    alm = rmfield(alm,fld{f});
end
flds = strrep(fld,'pos',''); flds = strrep(flds,'neg_','-'); flds = strrep(flds,'pt','.');
for n = length(flds):-1:1
dAz(n) = sscanf(flds{n},'%f');
end
alm.dAz = dAz;
for n = length(dAz):-1:1
alm.SA(:,n) = scat_ang_degs(alm.SolarZenithAngle_degrees_, 0.*ones([length(alm.time),1]), alm.SolarZenithAngle_degrees_, abs(ones(size(alm.time))*dAz(n)));
end

return