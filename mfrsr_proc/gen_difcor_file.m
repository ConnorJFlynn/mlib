function diffuse_cors = gen_difcor_file(infile)
% Corrected output file name to read "DiffuseCorr"

if ~exist('infile','var')
   [fname, pname] = uigetfile('*info*');
   if length(pname>0)
      infile = [pname, fname];
   end
end
fid = fopen(infile);
solarfile = char(fread(fid,'char')');
fclose(fid);
header_row = (solarfile(1:min(find(solarfile==10))-1));
SN = solarfile;
WE = solarfile;
for f = 1:7
   A = findstr(SN, ['SN',num2str(f)]);
   [label, SN] = strtok(SN(A:end));
   cos_corrs(f).bench_angle = [0:180];
   cos_corrs(f).SN = sscanf(SN,'%f',181);
   B = findstr(WE, ['WE', num2str(f)]);
   [label, WE] = strtok(WE(B:end));
   cos_corrs(f).WE = sscanf(WE,'%f',181);
end

%First do northern hemisphere:


%Breaking SN and WE into 4 ordinate directions vs elevation angle.
disp(['Computing northern hemisphere diffuse corrections ...']);
for f = 7:-1:1
   cos_corrs(f).zenith_angle = [0:90];
   cos_corrs(f).N = cos_corrs(f).SN(181:-1:91);
   cos_corrs(f).S = cos_corrs(f).SN(1:91);
   cos_corrs(f).W = cos_corrs(f).WE(1:91);
   cos_corrs(f).E = cos_corrs(f).WE(181:-1:91);
   disp(['  ch ',num2str(f)]);
   diffuse_cors(f).northern = difcor(cos_corrs(f));
%    diffuse = difcor_ext(cos_corrs(f));
end


% Flip corrections for southern hemisphere deployment
disp(['Computing southern hemisphere diffuse corrections...'])
   for f = 7:-1:1
      cos_corrs(f).SN = cos_corrs(f).SN(end:-1:1);
      cos_corrs(f).WE = cos_corrs(f).WE(end:-1:1);
      cos_corrs(f).N = cos_corrs(f).SN(181:-1:91);
      cos_corrs(f).S = cos_corrs(f).SN(1:91);
      cos_corrs(f).W = cos_corrs(f).WE(1:91);
      cos_corrs(f).E = cos_corrs(f).WE(181:-1:91);
         disp(['  ch ',num2str(f)]);
      diffuse_cors(f).southern = difcor(cos_corrs(f));
   end

[fpath, fname, fext, fver] = fileparts(infile);
header_time = datenum('1900','yyyy') + sscanf(fliplr(strtok(fliplr(header_row))),'%e');
yyyymmdd = datestr(header_time, 'yyyymmdd');
hhmmss = datestr(header_time, 'HHMMSS');
% 
% if ~exist([fpath,filesep,'DiffuseCorrs'],'dir')
%    mkdir(fpath, 'DiffuseCorrs');
%    
% end
% fpath = [fpath,filesep,'DiffuseCorrs'];
[tok, rest] = strtok(fname, '.');
filename = ['DiffuseCorr', rest];
outfile = fullfile(fpath, [filename, '.dat']);
%%
fid = fopen(outfile,'wt');
fprintf(fid,'%s \n',header_row );
fprintf(fid, '%s \n', upper('northern_hemisphere'));
format_str = ['channel %d = %2.3f \n'];
for f = 1:7
text_out = [f, diffuse_cors(f).northern.Rayleigh45];
fprintf(fid, format_str, text_out);
end
fprintf(fid, '%s \n', 'END');

fprintf(fid, '%s \n', upper('southern_hemisphere'));
format_str = ('channel %d = %2.3f \n');
for f = 1:7
text_out = [f, diffuse_cors(f).southern.Rayleigh45];
fprintf(fid, format_str, text_out);
end
fprintf(fid, '%s \n', 'END');
fclose(fid);
%%
function diffuse = difcor(angle_corrs)
%diffuse = difcor(angle_corrs);
% Calculates the correction required of the diffuse hemispheric due to
% non-lambertian sensor response
% Assumes that the supplied angle corrections are correct for the
% deployment hemisphere.  That is, if southern hemisphere swap E for W
% and N for S.

k=pi/180; %convert from degrees to radians

da=2; %//step in azimuth angle 
dz = 2;%//step in zenith angle
hemisp_corr = zeros(1,10);
for zen = 0:dz:89 %start in azimuth angle
   for az = 0:da:359 %start in zenith angle
      coscor = 1 ./ cos_correction(angle_corrs,az,zen); % //value of cosine correction from SolarInfo for zenith and azimuth za and az angles and for filter p
      sza=45 ;%//Rayleigh
      r=sin(k*sza)*sin(k*zen)*cos(k*az)+cos(k*zen)*cos(k*zen);
      r=1+r^2;
      hemisp_corr(1)=hemisp_corr(1)+sin(k*zen)*cos(k*zen)*r*da*dz*k*k ;%//the case of ideal Lambertian sensor
      hemisp_corr(2)=hemisp_corr(2)+sin(k*zen)*cos(k*zen) *r*coscor*da*dz*k*k ;%//the case of real (SolarInfo) sensor
   end %azimuth
end % zen

%//diffuse cosine corrections

hemisp_corr(2)=hemisp_corr(2)/hemisp_corr(1) ;%//Rayleigh sza=45
diffuse.Rayleigh45 = hemisp_corr(2);

