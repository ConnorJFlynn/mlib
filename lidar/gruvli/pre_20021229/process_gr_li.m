% Group processing of green lidar files with gr_li_3...
[dirlist, pname] = dir_list('*.nc');
cd(pname);
mkdir(pname, 'done');
for i = 1:length(dirlist)
    disp(['Processing file ' num2str(i) ' of ' num2str(length(dirlist)) ': ' dirlist(i).name ]);
    status = gr_li_3([pname dirlist(i).name])
    if ~(status<0)
       system(['move ' dirlist(i).name 'done']);
   end
end
