function [resp_stem, resp_dir] = gen_sws_resp_files(sws_resp,time,tint,resp_dir)
% [resp_stem, resp_dir] = gen_sws_resp_files(sws_resp,time,tint)

if any(sws_resp(:,1)>500&sws_resp(:,1)<600)
    det_str = '.si.';
else
    det_str = '.ir.';
end
%%
if ~exist('resp_dir','var')
    resp_dir = ['C:\case_studies\SWS\docs\from_DMF_Suty\sgpswsC1\response_funcs\'];
end
if ~exist(resp_dir,'dir')
    resp_dir = getnamedpath('sws_resp','Select a directory to save SWS responsivities');
end
db = '';
if time>datenum(2016,01,01)
    resp_stem = ['enaswsC1.resp_func.',datestr(time,'yyyymmdd0000'),det_str,num2str(tint),'ms',db];
else
    resp_stem = ['sgpswsC1.resp_func.',datestr(time,'yyyymmdd0000'),det_str,num2str(tint),'ms',db];
end
n =1; resp_stem_ = resp_stem;
while exist([resp_dir,resp_stem,'.dat'],'file')
    n = n+1;
    db = ['_',num2str(n)];
    resp_stem = [resp_stem_,db];
end
resp_stem = [resp_stem,'.dat'];
out = [sws_resp(:,[1 end])]';
fid = fopen([resp_dir,resp_stem],'w');
fprintf(fid,'   %5.3f    %5.3f \n',out);
fclose(fid);

return
