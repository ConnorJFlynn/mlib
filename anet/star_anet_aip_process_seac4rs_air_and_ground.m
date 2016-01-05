function anetaip = star_anet_aip_process_seac4rs(s)
% SEAC4RS specific functionality:
% Check to see if telemetry is changing.  If so, then use Euler angles, if
% not then determine ground offsets.
if ~exist('s','var')
    s = getfullname('*vis_sky*.*','starsky','Select star sky mat file.');
end
if strfind(s,'.mat')
   s = load(s);
else
   s = starsky(s);
end
if ~isstruct(s) && exist(s,'file')
    if ~isempty(strfind(s, 'starsky.mat'))
        s = load(s);
    else
        s = starsky_plus(load(s));
    end
end
if ~isfield(s,'flight_level')
    s = starsky_plus(s);
end

if isfield(s,'filename')
    [p,skytag,x] = fileparts(s.filename{1});
    skytag = strrep(skytag,'_VIS_','_');
    skytag = strrep(skytag,'_NIR_','_');
end
[pname_mat,~,~] = fileparts(s.filename{1});
if ~exist([pname_mat, filesep,skytag,'_starsky.mat'],'file')
   save([pname_mat, filesep,skytag,'_starsky.mat'], '-struct','s');
end
% if az_gnd doesn't exist, then apply Euler angle correction
if ~isfield(s,'Az_gnd')
s.Az_deg = -1.*s.AZstep./50;
s.sun_sky_El_offset = 3; %This represents the known mechanical offset between the sun and sky FOV in elevation.
s.El_true = s.El_deg;
s.El_true(s.Str==2) = s.El_deg(s.Str==2) - s.sun_sky_El_offset;
[s.Az_gnd, s.El_gnd] = ac_to_gnd_SEACRS(s.Az_deg, s.El_true, s.Headng, s.pitch, s.roll);
s.SA = scat_ang_degs(s.sza, s.sunaz, 90-abs(s.El_gnd), s.Az_gnd);
end
s.good_sky(s.Str~=2) = false;
if isfield(s,'good_alm')
s.good_alm = s.good_sky & s.good_alm;
end
if isfield(s,'good_almA')&isfield(s,'good_alm')
s.good_almA = s.good_almA & s.good_alm;
end
if isfield(s,'good_almB')&isfield(s,'good_alm')
s.good_almB = s.good_almB & s.good_alm;
end
s = handselect_skyscan(s);
% Next, apply handscreen to s. Save output and process.
% 
% if ~isfield(s,'PWV')
%     s.PWV = 1.7;
% end
% if ~isfield(s,'O3col')
%     s.O3col=0.330;
% end
% if s.O3col>1
%     s.O3col = s.O3col./1000;
% end
% if ~isfield(s,'wind_speed')
%     s.wind_speed= 7.5;
% end
% % for SEAC4RS
%  s.land_fraction = 1;
% % Should replace this with an actual determination based on a land-surface
% % mapping.
% s.rad_scale = 1; % This is an adhoc means of adjusting radiance calibration for whatever reason.
% s.ground_level = s.flight_level/1000; % picking very low "ground level" sufficient for sea level or AMF ground level.
% % Should replace this with an actual determination based on a land-surface mapping.
% % Both gen_sky_inp_4STAR and gen_aip_cimel_need to be modified.
pname_tagged = 'C:\z_4STAR\work_2aaa__\4STAR_\';
tag = [skytag,'.created_',datestr(now, 'yyyymmdd_HHMMSS.')];
fname_tagged = ['4STAR_.',tag, 'input'];
s.pname_tagged = pname_tagged;
s.fname_tagged = fname_tagged;
% [outname,ss,ww] = run_AERONET_retr_wi_selected_input_files([s.pname_tagged, '4STAR_.',skytag,'.input']);
% [inp, line_num] = gen_sky_inp_4STAR(s); %good_sky SA restrictions in here.
% % Make sure the gen_aip_cimel_strings is capable of accepting inp that
% % distinguishes between hlyr and houtput.
% %   line_num = gen_aip_cimel_strings(inp);
% %
% %   [~,fstem,ext] = fileparts(s.filename{1});
% % % pname = [pname, filesep];
% % fstem = strrep(fstem, '_VIS','');
% 
% if exist([pname_tagged, fname_tagged],'file')
%     [SUCCESS,MESSAGE,MESSAGEID] = copyfile([pname_tagged, fname_tagged],'C:\z_4STAR\work_2aaa__\4STAR_.input');
%     if exist('C:\z_4STAR\work_2aaa__\4STAR_.output','file')
%         delete('C:\z_4STAR\work_2aaa__\4STAR_.output')
%     end
%     [ss,ww, toc_] = run_4STAR_AERONET_retrieval;
%     if exist('C:\z_4STAR\work_2aaa__\4STAR_.output','file')
%         outname = [pname_tagged,'4STAR_.',tag,'output'];
%         [SUCCESS,MESSAGE,MESSAGEID] = ...
%             movefile('C:\z_4STAR\work_2aaa__\4STAR_.output',outname);
% %         fid3 = fopen(outname, 'r');
% %         outfile = char(fread(fid3,'uchar'))';
% %         fclose(fid3);
%         anetaip = parse_anet_aip_output(outname);                
%     end
% end
%
return