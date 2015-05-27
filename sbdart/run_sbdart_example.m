function w = run_sbdart_example(input);
%w = run_sbdart(input);
w = [];
sbdart_path = ['C:\Users\d3k014\Documents\MATLAB\mlib\local\sbdart\'];

fid = fopen([sbdart_path, 'INPUT'],'wt');
y = (['&INPUT']);
fprintf(fid,'%s \n',y);
y = (['IDATM = 2']);
fprintf(fid,'%s \n',y);
y = (['WLINF = 0.453']);
fprintf(fid,'%s \n',y);
y = (['WLSUP = 0.453']);
fprintf(fid,'%s \n',y);
% y = (['NF = 0']);
% fprintf(fid,'%s \n',y);
 y = (['NSTR = 20']);
 fprintf(fid,'%s \n',y);
% y = (['isalb = 0']);
% fprintf(fid,'%s \n',y);
% y = (['albcon = 0']);
% fprintf(fid,'%s \n',y);
y = (['SZA = 45']);
fprintf(fid,'%s \n',y);
y = (['SAZA = 0']);
fprintf(fid,'%s \n',y);
y = (['IDAY = 0']);
fprintf(fid,'%s \n',y);
% y = (['IAER = 0']);
% fprintf(fid,'%s \n',y);
y = ['iaer = 2, wlbaer= .453, tbaer= 0.109, wbaer=.9, gbaer=0.8'];
fprintf(fid, '%s \n',y);
y = (['phi = 0,15,30,45,60,75,90,105,120,135,150,165,180']);
fprintf(fid,'%s \n',y);
y = (['vzen=  90,89,85,80,70,60,50,45,40,20,10,5,1,0']);
y = (['uzen=  0,14,32,45,60,70,80,89,91,100,110,120,135,148,165,180']);
fprintf(fid,'%s \n',y);
y = (['CORINT = TRUE']);
fprintf(fid,'%s \n',y);
% y = (['DELTAM = FALSE']);
% fprintf(fid,'%s \n',y);

IOUT = 23;
y = (['IOUT = ',num2str(IOUT)]);
fprintf(fid,'%s \n',y);

% y = (['ABAER = ',num2str(mean_ang)]);
% fprintf(fid,'%s \n',y);
% y = (['WLBAER = ',num2str([mfr.cw_415nm,mfr.cw_500nm,mfr.cw_615nm,...
%     mfr.cw_673nm,mfr.cw_870nm]/1000)]);
% fprintf(fid,'%s \n',y);
% y = (['QBAER = ',num2str(mean_taus)]);
% fprintf(fid,'%s \n',y);
% y = (['WBAER = 0.89, 0.89, 0.89, 0.89, 0.89']);
% fprintf(fid,'%s \n',y);
% y = (['GBAER = 0.63, 0.63, 0.63, 0.63, 0.63']);
% fprintf(fid,'%s \n',y);
y = (['/']);
fprintf(fid,'%s \n',y);
fclose(fid);
pname = pwd;
cd(sbdart_path)
[s,w] = system(['C:\cygwin\bin\bash -c sbdart']);
cd(pname);
if IOUT == 6
   [phi, uzen, sa, full_sa,pp] = plot_iout6(w)
end
if (IOUT == 20)|(IOUT == 21)|(IOUT == 23)
   [phi, uzen, sa, full_sa,pp] = plot_iout20(w)
end
%%
