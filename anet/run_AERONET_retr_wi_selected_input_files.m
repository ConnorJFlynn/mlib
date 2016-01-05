function [outname,ss,ww] = run_AERONET_retr_wi_selected_input_files(skyinput);
% run_4STAR_AERONET_retrieval(skytag, line_num,)
% No customization, just pick files and run retrieval for all selected
if ~exist('skyinput','var')
   skyinput = getfullname(['*.input'],'4STAR_retr','Select one or more input files.');
   if ischar(skyinput)&&~iscell(skyinput)&&exist(skyinput,'file')
      skyinput ={skyinput};
   end
else
   [pname, fname,ext] = fileparts(skyinput);
   skyinput = getfullname([pname,filesep,fname,'*.input'],'4STAR_retr','Select one or more input files.');
   if ischar(skyinput)&&~iscell(skyinput)&&exist(skyinput,'file')
      skyinput ={skyinput};
   end
end
for F = length(skyinput):-1:1
    infile = skyinput{F};
    if exist(infile,'file')
        [pname_tagged, fname_tagged, ~] = fileparts(infile);pname_tagged = [pname_tagged, filesep];
        skip_dir = [pname_tagged, 'skip',filesep];
        if ~exist(skip_dir,'dir')
            mkdir(skip_dir);
        end
        bad_dir = [pname_tagged, 'bad',filesep];
        if ~exist(bad_dir,'dir')
            mkdir(bad_dir);
        end
        done_dir = [pname_tagged, 'done',filesep];
        if ~exist(done_dir,'dir')
            mkdir(done_dir);
        end        
        if exist([skip_dir,fname_tagged,'.input'],'file')
            disp(['Skipping file ',fname_tagged,'.input'])
        else
            copyfile(['C:\z_4STAR\work_2aaa__\saved_dats\*.dat'], ['C:\z_4STAR\work_2aaa__\']);
            copyfile(['C:\z_4STAR\work_2aaa__\saved_dats\fort.*'], ['C:\z_4STAR\work_2aaa__\']);

            copyfile(infile, [skip_dir, fname_tagged, '.input']);
            
            
            [SUCCESS,MESSAGE,MESSAGEID] = copyfile(infile,'C:\z_4STAR\work_2aaa__\4STAR_.input');
            if exist('C:\z_4STAR\work_2aaa__\4STAR_.output','file')
                delete('C:\z_4STAR\work_2aaa__\4STAR_.output')
            end
            disp(['Running retrieval for ',fname_tagged]);
            [ss,ww, toc_] = run_4STAR_AERONET_retrieval;
            disp(['Completed in ',sprintf('%2.1f ',toc_), 'seconds'])
            if exist('C:\z_4STAR\work_2aaa__\4STAR_.output','file')
                outname = [pname_tagged,fname_tagged,'.output'];
                [SUCCESS,MESSAGE,MESSAGEID] = ...
                    movefile('C:\z_4STAR\work_2aaa__\4STAR_.output',outname);
                %         fid3 = fopen(outname, 'r');
                %         outfile = char(fread(fid3,'uchar'))';
                %         fclose(fid3);
                try
                    anetaip = parse_anet_aip_output(outname);
                    save([done_dir,'..',filesep, fname_tagged, '.mat'],'-struct','anetaip')
                    movefile([done_dir,'..',filesep, fname_tagged, '.*'], done_dir );
                catch
                    disp(['Trouble displaying output from ',fname_tagged])
                    copyfile(infile, bad_dir);
                end
            end
        end
    end
%     close('all');
end
%%

return
