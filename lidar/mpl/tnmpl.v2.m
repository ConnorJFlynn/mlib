% %Modifying to clean up variable names and to add checking the
% %mod-date of files and avoid wild-cards which cause problems.
% disp('Please make sure MPL program is not running!');
% % disp('Hit any key when ready.')
% pause(10);
% scans = read_scan_file;
% if length(scans.theta)==0
%    disp('Problem reading scan file.')
% end
% disp('Initializing the scanner...')
% status = scanner_init;
% if status < 0
%    disp('Could not initialize scanner!')
% else
%    disp('Scanner initialized to zenith.')
% end
%Clean up data directories.  Need to move all files from Williams and
%Downtown raw data directories into slush holding bins.
%Don't proceed until these are empty.  Prompt user to close MPL
%program or reboot if we can't clear out the directories.
if ~exist('C:\tnmpl\','dir')
   mkdir('C:\','tnmpl');
end

base1 = 'C:\tnmpl\Downtown\';
if ~exist(base1, 'dir')
   mkdir('C:\tnmpl','Downtown');
end
base2 = 'C:\tnmpl\Williams\';
if ~exist(base2, 'dir')
   mkdir('C:\tnmpl','Williams');
end
base = base1;
if ~exist([base,'slush'], 'dir')
   mkdir(base,'slush')
end
if ~exist([base,'archive'], 'dir')
   mkdir(base,'archive')
end
if ~exist([base,'tmp'], 'dir')
   mkdir(base,'tmp')
end

base = base2;
if ~exist([base,'slush'], 'dir')
   mkdir(base,'slush')
end
if ~exist([base,'archive'], 'dir')
   mkdir(base,'archive')
end
if ~exist([base,'tmp'], 'dir')
   mkdir(base,'tmp')
end


base = base1;
data = [base, '\Data\'];
slush = [base,'\slush\'];
archive = [base,'\archive\'];
tmp = [base,'\tmp\'];
rawdir = dir([data,'*.??W']);
while length(rawdir)>0
   [s] = system('move ',data,'*.* ',slush);
   if (s>0)
      disp('Cannot move files from Downtown data directory!');
      disp('Please make sure the MPL program is not running.');
      disp('Press any key when ready, or reboot if all else fails.');
      pause
   end
   rawdir = dir([data,'*.??W']);
end
tmp = [base,'\tmp\'];
if ~exist(tmp,'dir')
   mkdir(base, 'tmp');
end
tempdir = dir([tmp,'*.??W']);
if ~isempty(tempdir)
   delete(basetemp,'*.??W');
end

base = base2;
data = [base, '\Data\'];
slush = [base,'\slush\'];
archive = [base,'\archive\'];
tmp = [base,'\tmp\'];
rawdir = dir([data,'*.??W']);
while length(rawdir)>0
   [s] = system('move ',data,'*.* ',slush);
   if (s>0)
      disp('Cannot move files from Williams data directory!');
      disp('Please make sure the MPL program is not running.');
      disp('Press any key when ready, or reboot if all else fails.');
      pause
   end
   rawdir = dir([data,'*.??W']);
end
tmp = [base,'\tmp\'];
if ~exist(tmp,'dir')
   mkdir(base, 'tmp');
end
tempdir = dir([tmp,'*.??W']);
if ~isempty(tempdir)
   delete(basetemp,'*.??W');
end

pname = [];
%Prompt user for appropriate MPL shortcut
while length(pname)<1
   [fname, pname] = uigetfile(['C:\tnmpl\*.lnk'], 'Select shortcut for desired scan plane.');
   if exist([pname, fname],'file')
      disp('Starting MPL program.')
      winopen([pname, fname]);
      pause(5);
      disp('Wait for the MPL program to appear.  Select 10 second averaging.');
      disp('Then select "Save Data", "Detector Power", and "Collect Data" in that order.')
   else
      pname = [];
   end
end
dir1 = [];
dir2 = [];
while isempty(dir1)&isempty(dir2)
   dir1 = dir([base1,'data\*.??W']);
   dir2 = dir([base2,'data\*.??W']);
   pause(10);
   disp('Checking for new data...');
end
% Find out which directory is non-empty
if ~isempty(dir1)
   %Downtown data
   base = base1;
   data = [base, '\Data\'];
   slush = [base,'\slush\'];
   archive = [base,'\archive\'];
   tmp = [base,'\tmp\'];
   rawdir = dir1;
   azimuth = 345;%North by NW
else
   %Williams data
   base = base2;
   rawdir = dir2;
   data = [base, '\Data\'];
   slush = [base,'\slush\'];
   archive = [base,'\archive\'];
   tmp = [base,'\tmp\'];
   azimuth = 285;%West by NW
end

pos_dstr = datestr(now, 'yyyymmdd');
pos_file = [base,'mir_pos.',pos_dstr,'.dat'];
if ~exist(pos_file,'file')
   mir_fid = fopen(pos_file,'w');
   fprintf(mir_fid,'yyyymmdd.hhmmss , degrees \n');
else
   mir_fid = fopen(pos_file,'a');
end

% Note that below 'scan' is the number of the line in the scan file
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
   disp(['Mirror at ',num2str(scans.theta(scan)), ' degrees.'])
   wait_time = mirror.time(n) + scans.dwell(scan)/(24*60);
   disp(['Dwell time for this angle is ', num2str(60*scans.dwell(scan)),' seconds.'])
   while (now <= wait_time)
      pause(10);
      %Reading partial files may have been leading to collisions and
      %data loss.  I'll stick with reading the completed files based
      %on mod_time
      rawdir = dir([data,'*.??W']);
      for f = 1:length(rawdir)
         age = (datenum(rawdir(f).date,'dd-mmm-yyyy HH:MM:SS')-now)*24*60*60; 
         if age>15
            disp(['Copying ',tempdir(f).name,' from Data to archive'])
            s = system(['copy ',data,rawdir(f).name, ' ',archive]);
            s = system(['move ',data,rawdir(f).name, ' ',tmp]);
         end
      end
      pause(.5);
      tmpdir = dir(tmp,'*.??W');
      if ~isempty(tmpdir)
         for f =1:length(tmpdir)
            [mpl,status,save_array] = read_mpl(['c:\tnmpl\tmp1\',tmpdir(f).name]);
            save_array(43,:) = 255;
            save_array(44,:) = 255;
            %First assign save_array positions to 255
            % Next, loop over n to identify the records having each
            % position
            for pos = 1:n
               these = find((mpl.time>=mirror.time(pos))&(mpl.time<mirror.endtime(pos)));
               if ~isempty(these)
                  save_array(43,these) = floor((254/360)*azimuth);
                  save_array(44,these) = floor((254/90)*mirror.pos(pos));
                  disp('tagged raw file with positions')
               end
            end
            %figure out which time have which mirror position
            %output back to file named with yyyymmdd_hh.dat
            dstr = datestr(mpl.time(1), 'yyyymmdd_HHMM');
            fid = fopen([pname, '\stamped\',dstr,'.dat'],'w');
            count = fwrite(fid, save_array,'uchar');
            fclose(fid);
         end
      end
   end
   n = n+1;
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
   if scan >= length(scans.dwell)
      scan = 1;
   else
      scan = scan + 1;
   end
   %Collecting data
   %first move what files can be moved to an archival location
   %next
end
fclose(mir_fid);


while ~isempty(dir2)
   %Collecting Williams data
end
