function [s,w,toc_] = run_4STAR_AERONET_retrieval
% run_4STAR_AERONET_retrieval(skytag, line_num,)

% Create two copies of input file.  One with skytag and creation date/time
% in the name, the other as "4STAR_.input". 
% Copy 4STAR_.output file into version with input file tag

% pname_tagged = 'C:\z_4STAR\work_2aaa__\4STAR_\';
% pname = 'C:\z_4STAR\work_2aaa__\';
% fname = ['4STAR_.input'];
% tag = [skytag,'.created_',datestr(now, 'yyyymmdd_HHMMSS.')];
% fname_tagged = ['4STAR_.',tag, 'input'];
% 
% fid = fopen([pname_tagged,fname_tagged],'w');
% for lin = 1:length(line_num)
%     fprintf(fid,'%s \n',line_num{lin});
% end
% fclose(fid);
% If necessary, edit config file
%%
% edit([pname_tagged,fname_tagged]);
% OK = menu('Edit and save the config file if necessary. Select OK when done.','OK');
% [success, message, message_id] = copyfile([pname_tagged,fname_tagged],[pname,fname],'f')
% fid2 = fopen([pname,fname],'w');
% for lin = 1:length(line_num)
%     fprintf(fid2,'%s \n',line_num{lin});
% end
% fclose(fid2);
%%
% disp('Running retrieval...')
pause(0.01);
tic_ = tic; [s,w] = system('C:\z_4STAR\work_2aaa__\4STAR_retr.bat');toc_ = toc(tic_);

% if exist('C:\z_4STAR\work_2aaa__\4STAR_.output','file')
%     outname = [pname_tagged,'4STAR_.',tag,'output'];
%      [SUCCESS,MESSAGE,MESSAGEID] = ...
%          movefile([pname,'4STAR_.output'],outname);
%      
% end
% fid3 = fopen(outname, 'r');
% outfile = char(fread(fid3,'uchar'))';
% fclose(fid3);
%   anetaip = parse_anet_aip_output(outfile,outname);
%   %%
%   plot_anet_aip(anetaip);
  %%

return