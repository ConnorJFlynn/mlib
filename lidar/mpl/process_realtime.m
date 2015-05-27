function [type,data,s,w] = process_realtime(type, data);
%get MPL data with rsync
tic
disp(['Processing sync data: ',datestr(now,'yyyy-mm-dd HH:MM')])
w = [];
% s = synctest;
s = mpl_realtime;
disp(['Done processing MPL data: ',datestr(now,'yyyy-mm-dd HH:MM')])
toc
disp(['Sending images to science.arm.gov: ',datestr(now,'yyyy-mm-dd HH:MM')]);
tic
[s,w] =system('c:\cygwin\bin\bash.exe /cygdrive/c/ISDAC/science.arm.gov/rsync_images.sh');
disp(['Done sending images: ',datestr(now,'yyyy-mm-dd HH:MM')]);
toc
%     [s,w] =system('c:\cygwin\bin\bash.exe /cygdrive/c/ISDAC/sgpmpl_rsync.sh');