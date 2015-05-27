 function [angle,f_ang_scat,f_ang_scat_sin,f_ang_bscat,f_ang_bscat_sin]=read_TSI_fangle();
%  TSI 3563 neph angular sensitivity functions for total scatter (ts) 
%    and backscatter (bs)
%  normalized to integrate to 2pi (for ts) and pi (for bs), just like sine function
%  sine function also included for reference
%  includes opal glass transmission, backscatter shutter and forward and 
%    backward truncation
%  note that backward truncation was measured; forward truncation was
%    scaled off the mechanical drawings 
%  measured by goniometer in June, 1994 at the Nephelometer Workshop
%    at TSI (St Paul, Minnesota)
%  angular sensitivity was identical (within measurement accuracy) for
%    all four units tested
%  column 1	angle (degrees)
%  column 2	neph angular sensitivity for total scatter
%  column 3	reference sine function for total scatter
%  column 4	neph angular sensitivity for backscatter
%  column 5	reference sine function for backscatter


pathname='c:\beat\data\strawa\';
filename='fangle.dat';
fid=fopen([pathname filename]);
for i=1:17
    fgetl(fid);
end
data=fscanf(fid,'%g',[5,inf]);
fclose(fid);
angle=data(1,:);           %  column 1	angle (degrees)
f_ang_scat=data(2,:);      %  column 2	neph angular sensitivity for total scatter
f_ang_scat_sin=data(3,:);  %  column 3	reference sine function for total scatter
f_ang_bscat=data(4,:);     %  column 4	neph angular sensitivity for backscatter
f_ang_bscat_sin=data(5,:); %  column 5	reference sine function for backscatter


%I want to normalize so that max value like the sine function 

[y,i]=max(f_ang_bscat);
f_ang_bscat=f_ang_bscat./max(f_ang_bscat)*f_ang_bscat_sin(i);

[y,i]=max(f_ang_scat);
f_ang_scat=f_ang_scat./max(f_ang_scat)*f_ang_scat_sin(i);

figure(6)
plot(angle,f_ang_scat,'.',angle,f_ang_scat_sin,'k',angle,f_ang_bscat,'.',angle,f_ang_bscat_sin,'k')
% trapz(deg2rad(angle),f_ang_scat)
% trapz(deg2rad(angle),f_ang_scat_sin)


