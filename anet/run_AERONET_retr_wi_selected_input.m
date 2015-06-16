function [outfile,outname,s,w] = run_AERONET_retr_wi_selected_input
% run_4STAR_AERONET_retrieval(skytag, line_num,)

% Create two copies of input file.  One with skytag and creation date/time
% in the name, the other as "4STAR_.input". 
% Copy 4STAR_.output file into version with input file tag


pname = 'C:\z_4STAR\work_2aaa__\';
fname = ['4STAR_.input'];
skyinput = getfullname([pname, '*.input']);
[pname_tagged,fname_tagged,ext] = fileparts(skyinput); 
pname_tagged = [pname_tagged filesep];

% If necessary, edit config file
%%
edit(skyinput);
OK = menu('Edit and save the config file if necessary. Select OK when done.','Use existing', 'Use edited file...');
if OK==2
    [skyinput] = getfullname(['*.input'],'anet_input');
    [pname_tagged,fname_tagged,ext] = fileparts(skyinput); 
    pname_tagged = [pname_tagged filesep];
end

% fid2 = fopen([pname,fname],'w');
% for lin = 1:length(line_num)
%     fprintf(fid2,'%s \n',line_num{lin});
% end
% fclose(fid2);
%%
if exist([skyinput],'file')
    [SUCCESS,MESSAGE,MESSAGEID] = copyfile(skyinput,'C:\z_4STAR\work_2aaa__\4STAR_.input');
    if exist('C:\z_4STAR\work_2aaa__\4STAR_.output','file')
        delete('C:\z_4STAR\work_2aaa__\4STAR_.output')
    end
    [ss,ww, toc_] = run_4STAR_AERONET_retrieval;
    if exist('C:\z_4STAR\work_2aaa__\4STAR_.output','file')
        outname = [pname_tagged,fname_tagged,'.output'];
        [SUCCESS,MESSAGE,MESSAGEID] = ...
            movefile('C:\z_4STAR\work_2aaa__\4STAR_.output',outname);
%         fid3 = fopen(outname, 'r');
%         outfile = char(fread(fid3,'uchar'))';
%         fclose(fid3);
        anetaip = parse_anet_aip_output(outname);                
    end
end
  %%

return