function anetaip = star_anet_aip_process(s)
%
if ~exist('s','var')
    sfile = getfullname('*starsky.mat','starsky','Select star sky mat file.');
    s = load(sfile);
end
if isfield(s,'filename')
    [p,skytag,x] = fileparts(s.filename{1});
    skytag = strrep(skytag,'_VIS_','_');skytag = strrep(skytag,'_NIR_','_');
end
[pname_mat,~,~] = fileparts(sfile);
if ~exist([pname_mat, filesep,skytag,'_starsky.mat'],'file')
save([pname_mat, filesep,skytag,'_starsky.mat'], '-struct','s');
end


if ~isfield(s,'PWV')
    s.PWV = 1.7;
end
if ~isfield(s,'O3col')
    s.O3col=0.330;
end
if s.O3col>1
    s.O3col = s.O3col./1000;
end
if ~isfield(s,'wind_speed')
    s.wind_speed= 7.5;
end
% for TCAP
hy.lat = 41.67; hy.lon = -70.2898; %Hyannis airport
amf.lat = 42.03113; amf.lon = -70.04820; % AMF1 Cape Cod
% Should replace this with an actual determination based on a land-surface
% mapping.
if ~isfield(s,'land_fraction')
    if (geodist(hy.lat,hy.lon,mean(s.Lat(s.Alt>10)),mean(s.Lon(s.Alt>10)))>50000) &&...
            (geodist(amf.lat,amf.lon,mean(s.Lat(s.Alt>10)),mean(s.Lon(s.Alt>10)))>50000)
        s.land_fraction = 0;
    else
        s.land_fraction = 0.25;
    end
end
%  s.land_fraction = 0.1;
s.rad_scale = 1.25;
s.ground_level = 10e-3; % picking very low "ground level" sufficient for sea level or AMF ground level.
% Should replace this with an actual determination based on a land-surface
% mapping.
% Both gen_sky_inp_4STAR and gen_aip_cimel_need to be modified.
pname_tagged = 'C:\z_4STAR\work_2aaa__\4STAR_\';
tag = [skytag,'.created_',datestr(now, 'yyyymmdd_HHMMSS.')];
fname_tagged = ['4STAR_.',tag, 'input'];
s.pname_tagged = pname_tagged;
s.fname_tagged = fname_tagged;
[inp, line_num] = gen_sky_inp_4STAR(s); %good_sky SA restrictions in here.
% Make sure the gen_aip_cimel_strings is capable of accepting inp that
% distinguishes between hlyr and houtput.
%   line_num = gen_aip_cimel_strings(inp);
%
%   [~,fstem,ext] = fileparts(s.filename{1});
% % pname = [pname, filesep];
% fstem = strrep(fstem, '_VIS','');

if exist([pname_tagged, fname_tagged],'file')
    [SUCCESS,MESSAGE,MESSAGEID] = copyfile([pname_tagged, fname_tagged],'C:\z_4STAR\work_2aaa__\4STAR_.input');
    if exist('C:\z_4STAR\work_2aaa__\4STAR_.output','file')
        delete('C:\z_4STAR\work_2aaa__\4STAR_.output')
    end
    [ss,ww, toc_] = run_4STAR_AERONET_retrieval;
    if exist('C:\z_4STAR\work_2aaa__\4STAR_.output','file')
        outname = [pname_tagged,'4STAR_.',tag,'output'];
        [SUCCESS,MESSAGE,MESSAGEID] = ...
            movefile('C:\z_4STAR\work_2aaa__\4STAR_.output',outname);
%         fid3 = fopen(outname, 'r');
%         outfile = char(fread(fid3,'uchar'))';
%         fclose(fid3);
        anetaip = parse_anet_aip_output(outname);                
    end
end
%
return