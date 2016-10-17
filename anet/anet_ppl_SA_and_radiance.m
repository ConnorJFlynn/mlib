function ppl = anet_ppl_SA_and_radiance(ppl)
% alm = anet_ppl_SA_and_radiance(ppl)
% Pack data from aeronet ppl file into structure with radiance dimensioned
% against time and azimuth angle, and compute scattering angles.
if ~exist('ppl','var')
    ppl = read_cimel_aip;
end

fld = fieldnames(ppl);
fld(1:13) = [];
for f = 1:length(fld)
    ppl.radiance(:,f) = ppl.(char(fld(f)));
    ppl = rmfield(ppl,fld{f});
end
flds = strrep(fld,'pos',''); flds = strrep(flds,'neg_','-'); flds = strrep(flds,'pt','.');
for n = length(flds):-1:1
dZa(n) = sscanf(flds{n},'%f');
end
ppl.dZa = dZa;
ppl.SA = scat_ang_degs(0.*ones(size(dZa)), 0.*ones(size(dZa)), abs(dZa), 0.*ones(size(dZa)))';

return