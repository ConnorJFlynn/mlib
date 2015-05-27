% %Modifying to clean up variable names and to add checking the
% %mod-date of files and avoid wild-cards which cause problems.
disp('Please make sure MPL program is not running!');
disp('Hit any key when ready.')
pause
scans = read_scan_file;
if length(scans.theta)==0
   disp('Problem reading scan file.')
end
disp('Initializing the scanner...')
status = scanner_init;
if status < 0
   disp('Failed to initialize scanner.  Trying again...')
   status = scanner_init;
   if status < 0
      disp('Failed to initialize scanner.  Continuing anyway!')
   else
      disp('Scanner initialized to zenith.')
   end
else
   disp('Scanner initialized to zenith.')
end
%Clean up data directories.  Need to move all files from
%Downtown raw data directories into slush holding bins.
%Don't proceed until these are empty.  Prompt user to close MPL
%program or reboot if we can't clear out the directories.
if ~exist('C:\tnmpl\','dir')
   mkdir('C:\','tnmpl');
end

base = 'C:\tnmpl\Downtown\';
if ~exist(base, 'dir')
   mkdir('C:\tnmpl','Downtown');
end
if ~exist([base,'slush'], 'dir')
   mkdir(base,'slush')
end
if ~exist([base,'archive'], 'dir')
   mkdir(base,'archive')
end
if ~exist([base,'tmp'], 'dir')
   mkdir(base,'tmp')
end

data = [base, 'Data\'];
slush = [base,'slush\'];
archive = [base,'archive\'];
tmp = [base,'tmp\'];
stamped = [base, 'stamped\'];
rawdir = dir([data,'*.??W']);
while length(rawdir)>0
   [s] = system(['move ',data,'*.* ',slush]);
   if (s>0)
      disp('Cannot move files from Downtown data directory!');
      disp('Please make sure the MPL program is not running.');
      disp('Press any key when ready, or reboot if all else fails.');
      pause
   end
   rawdir = dir([data,'*.??W']);
end
tmp = [base,'tmp\'];
if ~exist(tmp,'dir')
   mkdir(base, 'tmp');
end
tempdir = dir([tmp,'*.??W']);
if ~isempty(tempdir)
   delete(tmp,'*.??W');
end

% pname = [];
% %Prompt user for appropriate MPL shortcut
% while length(pname)<1
%    [fname, pname] = uigetfile(['C:\tnmpl\*.lnk'], 'Select shortcut for desired scan plane.');
%    if exist([pname, fname],'file')
%       disp('Starting MPL program.')
pname = 'C:\tnmpl\';
fname = 'MPL towards Downtown.lnk';
winopen([pname, fname]);
pause(5);
disp('Wait for the MPL program to appear...  ');
disp('   1. Select 10 second averaging time.');
disp('   2. Select "Save Data"')
disp('   3. Select "Detector Power"')
disp('   4. Select "Collect Data".')
disp('   Select "Graph" if desired')
%    else
%       pname = [];
%    end
% end
dir1 = [];
disp('Checking for new data...');
while isempty(dir1)
   dir1 = dir([data,'*.??W']);
   pause(10);
   %    disp('Checking for new data...');
end
% Find out which directory is non-empty
if ~isempty(dir1)
   %Downtown data
   base = base;
   data = [base, '\Data\'];
   slush = [base,'\slush\'];
   archive = [base,'\archive\'];
   tmp = [base,'\tmp\'];
   rawdir = dir1;
   azimuth = 345;%North by NW
end

pos_dstr = datestr(now, 'yyyymmdd');
pos_file = [base,'mir_pos.',pos_dstr,'.dat'];
if ~exist(pos_file,'file')
   mir_fid = fopen(pos_file,'w');
   fprintf(mir_fid,'yyyymmdd.hhmmss , degrees \n');
else
   mir_fid = fopen(pos_file,'a');
end

% Note that below 'scan' is the number of the lines in the scan file
% and will cycle repeatedly while 'n' is the Nth move of the mirror
% and will increment without bound.
scan = 1;
n = 1;
while ~isempty(rawdir)
   %    disp(['Moving mirror to ',num2str(scans.theta(scan)), ' degrees from zenith.'])
   mirror.time(n) = scanner_move(scans.theta(scan));
   mirror.pos(n) = scans.theta(scan);
   fprintf(mir_fid,'%s , %g  \n',datestr(mirror.time(n),'yyyymmdd.HHMMSS'), mirror.pos(n));
   mirror.endtime(n) = mirror.time(n) + scans.dwell(scan)/(24*60);

   wait_time = mirror.time(n) + scans.dwell(scan)/(24*60);
   disp(['Time: ' ,datestr(now,'HH:MM:SS'), ' CST,  Zenith angle: ',num2str(scans.theta(scan)), ' degrees.  Averaging for ',...
      num2str(60*scans.dwell(scan)),' seconds.' ])
   %    disp(['Dwell time for this angle is ', num2str(60*scans.dwell(scan)),' seconds.'])
   while (now <= wait_time)
      pause(10);
      %Reading partial files may have been leading to collisions and
      %data loss.  I'll stick with reading the completed files based
      %on mod_time
      rawdir = dir([data,'*.??W']);
      for f = 1:length(rawdir)
         age = (now-datenum(rawdir(f).date,'dd-mmm-yyyy HH:MM:SS'))*24*60*60;
         if age>15
            disp(['Copying ',tempdir(f).name,' from Data to archive'])
            s = system(['copy ',data,rawdir(f).name, ' ',archive]);
            s = system(['move ',data,rawdir(f).name, ' ',tmp]);
         end
      end
      pause(.5);
      tmpdir = dir([tmp,'*.??W']);
      if ~isempty(tmpdir)
         for f =1:length(tmpdir)
            [mpl,status,save_array] = read_mpl([tmp,tmpdir(f).name]);
            delete([tmp,tmpdir(f).name])
            save_array(43,:) = 255;
            save_array(44,:) = 255;
            %First assign save_array positions to 255
            % Next, loop over n to identify the records having each
            % position
            %figure out which time have which mirror position
            %output back to file named with yyyymmdd_hh.dat
            for pos = 1:n
               these = find((mpl.time>=mirror.time(pos))&(mpl.time<mirror.endtime(pos)));
               if ~isempty(these)
                  save_array(43,these) = floor((254/360)*azimuth);
                  save_array(44,these) = floor((254/90)*mirror.pos(pos));
%                   disp('tagged raw file with positions')
               end
            end

            dstr = datestr(mpl.time(1), 'yyyymmdd_HHMM');
            fid = fopen([stamped,dstr,'.dat'],'w');
            count = fwrite(fid, save_array,'uchar');
            fclose(fid);
         end
      end
   end
   n = n+1;

   if scan >= length(scans.dwell)
      scan = 1;
   else
      scan = scan + 1;
   end
   
   this_hour = now;
   v = datevec(this_hour);
   if v(5)==2
      last_hour = this_hour - 1/(24);
      last_v = datevec(last_hour);
      hourly_dir = [datestr(last_v,'yyyymmdd_HH')];
      %Make directories for last hours data
      mkdir(archive,hourly_dir);
      hourly_dir = [archive,hourly_dir,'\'];
      s = system(['move ',archive,'\',datestr(last_v,'yymmddHH'), '.??W ',hourly_dir]);
%       daily_dir = [datestr(last_v,'yyyy_mm_dd')];
      if ~exist ([archive, 'zipped'],'dir')
         mkdir(archive,'zipped')
      end
      zipped_dir = [archive,'zipped\'];
      disp('Zipping files for storage and transfer...')
      zip([zipped_dir,datestr(last_v,'yyyymmdd_HH'),'.zip'],hourly_dir);
      delete([hourly_dir,'*.*']);
      rmdir([hourly_dir]);
      
      mkdir(stamped,hourly_dir);
      hourly_dir = [stamped,hourly_dir,'\'];
      s = system(['move ',stamped,'\',datestr(last_v,'yymmddHH'), '.??W ',hourly_dir]);
%       daily_dir = [datestr(last_v,'yyyy_mm_dd')];
      zipped_dir = [archive,'zipped\'];
      disp('Zipping files for storage and transfer...')
      zip([zipped_dir,datestr(last_v,'yyyymmdd_HH'),'.stamped.zip'],hourly_dir);
      delete([hourly_dir,'*.*']);
      rmdir([hourly_dir]); 
      
      system(['copy ', pos_file, ' ', zipped_dir])
   end
   %Move archived and stamped files into them.  
   %Zip the hourly directories.  
   %Move the hourly zipped direcories to a daily repository
   %And to the ftp location.

   %    s = system(['copy c:\tnmpl\tmp1\*.??W c:\tnmpl\tmp1\this.scn']);
   %    [mpl, status, save_array] = read_mpl('c:\tnmpl\tmp1\this.scn');
   %    delete('c:\tnmpl\tmp1\*.??W');
   %    delete('c:\tnmpl\tmp1\this.scn');

   % Read tmp1, determine which records correspond to current mirror
   % position, plot mean and latest, save file back out with only
   % records relevant to current position.
   % For each file in tmp2, insert azimuth and el scaled to 0-254 or
   % 255 if indeterminate.  Save each file back out, then move them to
   % archival/yyyymmdd_HH.


   % Move the files to archive
   %Collecting data
   %first move what files can be moved to an archival location
   %next
end
fclose(mir_fid);
