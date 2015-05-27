function cos_corrs = read_solarfile(infile, lat);
%angle_corrs = read_solarfile(infile);
% Reads an MFRSR solarinfo file to determine the cosine correction
% Returns .bench_angle, .SN{ch}, and .WE{ch} with ch=[1:7]
% and .zenith_angle, .N{ch}, .E{ch}, S{ch}, and W{ch} with ch=[1:7]
% Modified from 20060319 version by breaking cos corr into cardinal
% directions and also accounting for reversal with lat<0

if ~exist('infile','var')
   [fname, pname] = uigetfile;
   if length(pname>0)
      infile = [pname, fname];
   end
end
if ~exist('lat', 'var')
   %Assume lat >= 0
   lat = 0;
end
fid = fopen([infile]);
solarfile = char(fread(fid,'char')');
fclose(fid);
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
% for f = 1:7
%    cos_corrs(f).WE = sscanf(solarfile(B(1,1):end),'%f',181);
%    %     WE{ch}(1) = [];
%    B(:,1) = [];
% end

% If southern hemisphere, flip corrections
if lat < 0
   for f = 1:7
      cos_corrs(f).SN = cos_corrs(f).SN(end:-1:1);
      cos_corrs(f).WE = cos_corrs(f).WE(end:-1:1);
   end
end

%Breaking SN and WE into 4 ordinate directions vs elevation angle.
for f = 7:-1:1
   cos_corrs(f).zenith_angle = [0:90];
   cos_corrs(f).N = cos_corrs(f).SN(181:-1:91);
   cos_corrs(f).S = cos_corrs(f).SN(1:91);
   cos_corrs(f).W = cos_corrs(f).WE(1:91);
   cos_corrs(f).E = cos_corrs(f).WE(181:-1:91);
end
