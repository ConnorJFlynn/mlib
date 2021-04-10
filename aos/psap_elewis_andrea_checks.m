infile =getfullname('*.csv','andrea_psap');
if isavar('infile')&isafile(infile)
   [~,psap.fname,ext]  = fileparts(infile);
   fid = fopen(infile);
   A = textscan(fid,'%f %f %s %f','delimiter',',','headerlines',1);
end
psap.Ba_B = A{1}; psap.Ba_G = A{2}; psap.Ba_R = A{4};
psap.time = datenum(A{3}, 'yyyy-mm-dd HH:MM:SS');

   
psap.AAE_BG = ang_exp(psap.Ba_B, psap.Ba_G, 464,529);
psap.AAE_BR = ang_exp(psap.Ba_B, psap.Ba_R, 464,648);
psap.AAE_GR = ang_exp(psap.Ba_G, psap.Ba_R, 529,648);

figure; plot(psap.time, [psap.Ba_B, psap.Ba_G, psap.Ba_R],'*')
dynamicDateTicks

figure; plot(psap.time, [psap.AAE_BG, psap.AAE_BR, psap.AAE_GR],'x');
dynamicDateTicks