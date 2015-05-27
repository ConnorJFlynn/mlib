function [type,data,s,w] = rsyncNSAMPL(type, data);
%get MPL data with rsync
disp(['Collecting data from MPL: ',datestr(now,'yyyy-mm-dd HH:MM:SS')]);
tic
[s,w] =system('c:\cygwin\bin\bash.exe /cygdrive/c/ISDAC/192.148.94.8/scripts/nsampl_rsync.sh');
disp(['Collections completed: ', datestr(now,'yyyy-mm-dd HH:MM:SS')])
toc
