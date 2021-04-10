function [outname,ss,ww] = run_AERONET_retr_wi_selected_input_files(skyinput);
% run_4STAR_AERONET_retrieval(skytag, line_num,)
% No customization, just pick files and run retrieval for all selected
% if ~exist('skyinput','var')
%    skyinput = getfullname(['*.input'],'4STAR_retr','Select one or more input files.');
%    if ischar(skyinput)&&~iscell(skyinput)&&exist(skyinput,'file')
%       skyinput ={skyinput};
%    end
% else
%    [pname, fname,ext] = fileparts(skyinput); [~, fname,~] = fileparts(fname)
%    skyinput = getfullname([pname,filesep,fname,'*.input'],'4STAR_retr','Select one or more input files.');
%    if ischar(skyinput)&&~iscell(skyinput)&&exist(skyinput,'file')
%       skyinput ={skyinput};
%    end
% end
if ~exist('skyinput','var')||~exist(skyinput,'file')
   skyinput = getfullname(['*.input'],'4STAR_retr','Select one or more input files.');
end
if ischar(skyinput)&&~iscell(skyinput)&&exist(skyinput,'file')
   skyinput ={skyinput};
end
for F = length(skyinput):-1:1
   infile = skyinput{F};
   disp(['Running ',num2str(F)])
   if exist(infile,'file')
      [pname_tagged, fname_tagged, ~] = fileparts(infile);pname_tagged = [pname_tagged, filesep];
      %         skip_dir = [pname_tagged, 'skip',filesep];
      %         if ~exist(skip_dir,'dir')
      %             mkdir(skip_dir);
      %         end
      bad_dir = [pname_tagged, 'bad',filesep];
      if ~exist(bad_dir,'dir')
         mkdir(bad_dir);
      end
      done_dir = [pname_tagged, 'done',filesep];
      %         done_dir = setnamedpath('staraip_out',[], 'Select the output directory for star aip results');
      if ~exist(done_dir,'dir')
         mkdir(done_dir);
      end
      
      
      [~,fstem] = fileparts(fname_tagged); [~,fstem] = fileparts(fstem);
      imgdir = getnamedpath('star_images');
      if ~isdir([imgdir,fstem]);
         mkdir(imgdir, fstem);
      end
      
      
      if false %exist([skip_dir,fname_tagged,'.input'],'file')
         disp(['Skipping file ',fname_tagged,'.input'])
      else
         copyfile(['C:\z_4STAR\work_2aaa__\saved_dats\*.dat'], ['C:\z_4STAR\work_2aaa__\']);
         copyfile(['C:\z_4STAR\work_2aaa__\saved_dats\fort.*'], ['C:\z_4STAR\work_2aaa__\']);
         
         %             copyfile(infile, [skip_dir, fname_tagged, '.input']);
         in_test = fopen(infile, 'r');
         first_line = fgetl(in_test);
         fclose(in_test);
         enil = fliplr(first_line);
         vel = strtok(enil,':');
         lev = fliplr(vel);
         in_lev = sscanf(lev, '%f');
         % Haven't got around to re-tagging with post-processing data level
         
         [SUCCESS,MESSAGE,MESSAGEID] = copyfile(infile,'C:\z_4STAR\work_2aaa__\4STAR_.input');
         if exist('C:\z_4STAR\work_2aaa__\4STAR_.output','file')
            delete('C:\z_4STAR\work_2aaa__\4STAR_.output')
         end
         disp(['Running retrieval for ',fname_tagged]);
         [ss,ww, toc_] = run_4STAR_AERONET_retrieval;
         disp(['Completed in ',sprintf('%2.1f ',toc_), 'seconds'])
         if exist('C:\z_4STAR\work_2aaa__\4STAR_retr.log','file')
            outname = [pname_tagged,fname_tagged,'.4STAR_retr.log'];
            [SUCCESS,MESSAGE,MESSAGEID] = ...
               movefile('C:\z_4STAR\work_2aaa__\4STAR_retr.log',outname);
         end
         
         if exist('C:\z_4STAR\work_2aaa__\4STAR_.output','file')
            outname = [pname_tagged,fname_tagged,'.output'];
            [SUCCESS,MESSAGE,MESSAGEID] = ...
               movefile('C:\z_4STAR\work_2aaa__\4STAR_.output',outname);
            %         fid3 = fopen(outname, 'r');
            %         outfile = char(fread(fid3,'uchar'))';
            %         fclose(fid3);
            try
               anetaip = parse_anet_aip_output(outname);
            
               [lv, tests] = anet_postproc_dl(anetaip);
               
               plot_anet_aip(anetaip);
               save([done_dir,'..',filesep, fname_tagged, '.mat'],'-struct','anetaip')
               movefile([done_dir,'..',filesep, fname_tagged, '.*'], done_dir );
            catch ME
               disp(['Trouble displaying output from ',fname_tagged])
               copyfile(infile, bad_dir);
               [~, skyscan] = fileparts(fname_tagged);[~, skyscan] = fileparts(skyscan);
               figure; plot(0:1,0:1,'o'); title(['Crashed during ',skyscan], 'interp','none');
               text(0.1,0.8,ME.identifier,'color','red');
               text(0.1,0.6,ME.message,'color','red','fontsize',8);
               imgdir = getnamedpath('star_images');
               skyimgdir = [imgdir,skyscan,filesep];
               saveas(gcf,[skyimgdir,skyscan, '.bad.png']);
               ppt_add_slide([imgdir,skyscan,'.ppt'], [skyimgdir,skyscan, '.bad']);
               movefile([imgdir,skyscan,'.ppt'],[imgdir,'bad.',skyscan,'.ppt']);
               warning(['Crashed during ', fname_tagged]);
            end
            
         end
      end
   end
   pause(3); close('all');
end
%%
if length(skyinput)==0
   outname = [];
end
return
