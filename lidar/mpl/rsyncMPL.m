function [type,data,s,w] = rsyncMPL(type, data);
%get MPL data with rsync
disp(['Processing sync data: ',datestr(now,'yyyy-mm-dd HH:MM')])
w = [];
% s = synctest;
s = mpl_realtime;
%     [s,w] =system('c:\cygwin\bin\bash.exe /cygdrive/c/ISDAC/sgpmpl_rsync.sh');