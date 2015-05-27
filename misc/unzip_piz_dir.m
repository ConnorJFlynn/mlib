
function unzip_piz_dir
%%

piz_dir = ['D:\case_studies\assist\finland\finland_assist_raw\2014_05_17\assist\hide\'];
piz = dir([piz_dir,'*.piz']);
for p =1:length(piz)
    uz = unzip([piz_dir, piz(p).name],[piz_dir,'proc\']);
    disp([length(piz)-p])
end


return
%%