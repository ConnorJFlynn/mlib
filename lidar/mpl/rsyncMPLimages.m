function [type,data,s,w] = rsyncMPLimages(type, data);
%update MPL images on science.arm.gov
disp(['Sending images to science.arm.gov: ',datestr(now,'yyyy-mm-dd HH:MM')]);
tic
[s,w] =system('c:\cygwin\bin\bash.exe /cygdrive/c/ISDAC/science.arm.gov/rsync_images.sh');
disp(['Done sending images: ',datestr(now,'yyyy-mm-dd HH:MM')]);
toc
% 
% rsync -avz -e "ssh.exe -i /cygdrive/c/ISDAC/science.arm.gov/rsa_key.prv" /cygdrive/c/ISDAC/192.148.94.8/processed/png/recent*.png cflynn@science.arm.gov:/home/cflynn/ISDAC/MPL_images/
% 
% 
% rsync_str = 'c:\cygwin\bin\rsync.exe -a ';
% ssh_str = '-e "c:\cygwin\bin\ssh.exe -i /cygdrive/c/ISDAC/science.arm.gov/rsa_key.prv" ';
% src_str = '/cygdrive/c/ISDAC/192.148.94.8/processed/png/*.png '; 
% dest_str = 'flynn@science.arm.gov:/home/cflynn/ISDAC/MPL_images/ ';
% [s,w] = system([rsync_str ssh_str src_str dest_str])