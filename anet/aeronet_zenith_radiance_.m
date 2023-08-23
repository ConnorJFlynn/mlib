function aip = aeronet_zenith_radiance_(infile)
% aip = aeronet_zenith_radiance(infile)
% Reads AERONET PPL file to yield SA vs SKY_RAD and interpolates to ZEN_RAD

if ~exist('infile','var')||~exist(infile,'file')
    infile = getfullname('*.*','aeronet_ppl','Select AERONET AIP PPL file.');
end

%%
aip = read_cimel_aip(infile);

%%
aip.waves_rounded = (round(aip.Nominal_Wavelength_nm_.*100)./100);
aip.wave_rounded = unique(aip.waves_rounded);
fields = fieldnames(aip);
sa = []
sky_rad = []
for f = 1:length(fields)
    if any(~isempty(strfind(fields{f},'pos'))|| ~isempty(strfind(fields{f},'neg_')))
        fld = fields{f};
        fld = strrep(fld,'pt','.'); fld = strrep(fld,'pos',''); fld = strrep(fld,'neg_','-');
        sa(end+1) = sscanf(fld,'%f');
        sky_rad(:,end+1) = aip.(fields{f});
    end
end
[aip.SA, ii] = sort(sa);
aip.sky_rad = sky_rad(:,ii);
% Original units µW/cm^2/sr/nm = mW/cm^2/sr/um
% 1e-3 * 1e4
% Desire radiance units W/(m^2 um sr)
aip.sky_rad = aip.sky_rad * 10;
aip.sky_rad_units = 'W/(m^2 um sr)';
% Figure out how to hand duplicate SA values...
[SA, ij] = unique(aip.SA);
for t = length(aip.time):-1:1
aip.zen_rad(t) = interp1(aip.SA(ij), aip.sky_rad(t,ij), aip.Solar_Zenith_Angle_Degrees_(t),'linear');
end

for w = 1:length(aip.wave_rounded)
    nm = aip.wave_rounded(w);
    aip.(['zen_rad_',sprintf('%d',nm),'_nm']) = NaN(size(aip.time));
    aip.(['zen_rad_',sprintf('%d',nm),'_nm'])(aip.waves_rounded==aip.wave_rounded(w)) =aip.zen_rad(aip.waves_rounded==aip.wave_rounded(w));
    aip.(['zen_rad_',sprintf('%d',nm),'_nm'])(aip.(['zen_rad_',sprintf('%d',nm),'_nm'])<0) = NaN;    
end

% figure; plot(serial2doys(aip.time), [aip.zen_rad_440_nm, aip.zen_rad_500_nm, ...
%     aip.zen_rad_670_nm, aip.zen_rad_870_nm],'o')

%%


return
