function ts_ = Io_timeseries(indir)
% ts = I_timeseries(indir)
% Extracts time series of daily Io values from a directory of MFRSR/NIMFR
% AOD files. 
%%
% Change this to select a file within the directory.  Slightly different
% coding but easier for the user during selection to know that the selected
% directory actually contains the data they want.

disp('Please select a file from a directory.');
[files,indir] = dir_list('*.cdf');

% if ~exist('indir','var')||~exist(indir,'dir');
%     indir = getdir('*.cdf','mfrsr_Ios','Select directory with MFRSR data.');
% end
% 
% % indir = ['H:\data\cjf\sbsmfrsraod1michS1.c1\'];
% files = dir([indir,'*.cdf']);

% for f = length(files):-1:1
% 
%     anc = ancloadcoords([indir,files(f).name]);
%     ts.time(f) = anc.time(1);
%     ts.head_id(f) = sscanf(anc.atts.head_id.data,'%g');
%     ts.Io_1(f) = anc.vars.Io_filter1.data;
%     ts.Io_2(f) = anc.vars.Io_filter2.data;
%     ts.Io_3(f) = anc.vars.Io_filter3.data;
%     ts.Io_4(f) = anc.vars.Io_filter4.data;
%     ts.Io_5(f) = anc.vars.Io_filter5.data;
%     disp(['File #',num2str(f)])
% end

for f = length(files):-1:1

    anc_ = anc_loadcoords([indir,files(f).name]);
    ts_.time(f) = anc_.time(1);
    ts_.head_id(f) = sscanf(anc_.gatts.head_id,'%g');
    if isfield(anc_.gatts,'logger_id')
       ts_.logger_id(f) = sscanf(anc_.gatts.logger_id,'%g');
    end
    ts_.Io_1(f) = anc_.vdata.Io_filter1;
    ts_.Io_2(f) = anc_.vdata.Io_filter2;
    ts_.Io_3(f) = anc_.vdata.Io_filter3;
    ts_.Io_4(f) = anc_.vdata.Io_filter4;
    ts_.Io_5(f) = anc_.vdata.Io_filter5;
    disp(['File #',num2str(f)])
end

%
[pname, fname, ext] = fileparts(anc_.fname);
[stem,rest] = strtok(fname, '.');
mfr_i = strfind(stem,'aod1mich'); 
if ~isempty(mfr_i)
    site = strrep(stem,'aod1mich','.');
end

%%
figure; plot(ts_.time, [ts_.Io_1;ts_.Io_2;ts_.Io_3;ts_.Io_4;ts_.Io_5], '-o') 
legend('Filter 1','Filter 2','Filter 3','Filter 4','Filter 5');
dynamicDateTicks
title(['Io values for ',site], 'interp','none');
head_id_hex = dec2hex(unique(ts_.head_id))
  
return
    %%