%%
% get directory listing
clear

%% This section for stepping through files in a given directory
trt_path = getdir; %'C:\case_studies\ARRA\SAS\avantes\NOAAData\';
trt_file = dir([trt_path, '*.trt']);
%%
in_file = read_avantes_trt([trt_path,trt_file(1).name]);
%
done = false;
ff = 1;
while ~done
read_avantes_trt([trt_path,trt_file(ff).name]);
mn = menu('Select an option','Next','Previous','Done');
if mn == 1
   ff = ff +1;
elseif mn == 2
   ff = ff -1;
else
   done = true;
end
if ff>length(trt_file)
   ff = 1;
end
if ff<1
   ff = length(trt_file);
end
end
%%

%% This section for sorting into directories for each spec type and darks

in_file = read_avantes_trt;
%
trt_file = dir([in_file.pname, '*.trt']);
for ff = 1:length(trt_file)
[in_file] = read_avantes_trt([in_file.pname,trt_file(ff).name],true);
if ~exist([in_file.pname, char(in_file.Spec_desc)],'dir')
   mkdir([in_file.pname, char(in_file.Spec_desc)]);
end
if ~exist([in_file.pname, char(in_file.Spec_desc),filesep,'darks'],'dir')
   mkdir([in_file.pname, char(in_file.Spec_desc),filesep,'darks']);
end
if in_file.dark
   out_dir = [in_file.pname, char(in_file.Spec_desc),filesep,'darks',filesep];
else
   out_dir = [in_file.pname, char(in_file.Spec_desc),filesep];
end

fid_in = fopen([in_file.pname,trt_file(ff).name],'r');
fid_out = fopen([out_dir,filesep,trt_file(ff).name],'w');
fwrite(fid_out, fread(fid_in));
fclose(fid_out); fclose(fid_in);

end


%% This section for concatenating all files of a given type together

in_file = read_avantes_trt;
%
trt_file = dir([in_file.pname, '*.trt']);

for ff = 1:length(trt_file)
[in_file] = cat_spec_type(in_file,read_avantes_trt([in_file.pname,trt_file(ff).name],true));
end
   disp(['Saving ',char(in_file.fname{end})])
   save([in_file.pname, in_file.fname{end},'.mat'],'in_file');

%%
% for ff = 2:length(trt_file)
% [in_file] = cat_trt(in_file,[trt_path,trt_file(ff).name]);
% end
%
   disp(['Saving ',in_file.fname])
   save([in_file.pname, in_file.fname,'.mat'],'in_file');
%    in_file
   if isfield(in_file,'mean_samp')
%    figure(5); ax(1) = subplot(2,1,1);semilogy(in_file.nm,
%    in_file.Sample,'-',in_file.nm, in_file.mean_samp,'k-');
      figure(5); ax(1) = subplot(2,1,1);semilogy(in_file.nm, in_file.mean_samp,'k-');
      ylabel('avg counts')
   ax(2) = subplot(2,1,2); plot(in_file.nm, 100.*in_file.std_samp./in_file.mean_samp,'r-'); 
   ylabel('% error')
   linkaxes(ax,'x')
   end
%% 