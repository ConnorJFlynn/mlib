function status = edg2flynn2csv% Read in edgar file
pname = 'C:\case_studies\assist\May17\';
in_file = getfullname([pname, '*.mat']);
[p,fname,ext] = fileparts(in_file);
fname =[fname,ext];
edgar_mat = loadinto([pname,fname]);
flynn_mat = repack_edgar(edgar_mat);
logi.F = bitget(flynn_mat.flags,2)>0;
logi.R = bitget(flynn_mat.flags,3)>0;
logi.H = bitget(flynn_mat.flags,5)>0;
logi.A = bitget(flynn_mat.flags,6)>0;
% assist.chA.laser_wl = 632.8e-7;    % He-Ne wavelength in cm
% assist.chA.laser_wn = 1./assist.chA.laser_wl; % wavenumber in 1/cm
% assist = flip_reverse_scans(assist)
% assist.chA.y(assist.logi.R,:) = fliplr(assist.chA.y(assist.logi.R,:));
flynn_mat.y(logi.R,:) = fliplr(flynn_mat.y(logi.R,:));
dim_n = find(size(flynn_mat.y)==length(flynn_mat.x));

zpd_shift_F = find_zpd_xcorr(flynn_mat.y(logi.F,:));
flynn_mat.y(logi.F,:) =  sideshift(flynn_mat.x, flynn_mat.y(logi.F,:), zpd_shift_F);
flynn_mat.y(logi.F,:) = fftshift(flynn_mat.y(logi.F,:),dim_n);
flynn_mat.zpd_shift(logi.F) = zpd_shift_F;
zpd_shift_R = find_zpd_xcorr(flynn_mat.y(logi.R,:));
flynn_mat.y(logi.R,:) =  sideshift(flynn_mat.x, flynn_mat.y(logi.R,:), zpd_shift_R);
flynn_mat.y(logi.R,:) = fftshift(flynn_mat.y(logi.R,:),dim_n);
flynn_mat.zpd_shift(logi.R) = zpd_shift_R;
[flynn_mat.cxs.x,flynn_mat.cxs.y] = RawIgm2RawSpc(flynn_mat.x,flynn_mat.y, 1./flynn_mat.laserFrequency);
[first,~] = strtok(fname,'.');

out_file = [pname, first,'.igm.csv'];
edghdr2csv(edgar_mat,out_file);
fid1 = fopen([out_file],'a+');
c = onCleanup(@()fclose(fid1));
fprintf(fid1,'%s',['"ZPDshiftapplied=[']);
fprintf(fid1,'%g, %g',[flynn_mat.zpd_shift(logi.F),flynn_mat.zpd_shift(logi.R)]);
fprintf(fid1,'%s \n',[']"']);
fprintf(fid1,'index, forward, reverse \n');
for ii= 1:length(flynn_mat.x)
   fprintf(fid1,'%i, %7.12g, %7.12g \n',[flynn_mat.x(ii); flynn_mat.y(1,ii);flynn_mat.y(2,ii)]);
end   
fclose(fid1);

out_file = [pname, first,'.real_cxs.csv'];
edghdr2csv(edgar_mat,out_file);
fid2 = fopen([out_file],'a+');
fprintf(fid2,'%s',['"ZPDshiftapplied=[']);
fprintf(fid2,'%g,%g',[flynn_mat.zpd_shift(logi.F),flynn_mat.zpd_shift(logi.R)]);
fprintf(fid2,'%s \n',[']"']);
fprintf(fid2,'wavenumber, forward, reverse \n');
for ii= 1:length(flynn_mat.cxs.x)
   fprintf(fid2,'%5.5f, %7.12g, %7.12g \n',[flynn_mat.cxs.x(ii); real(flynn_mat.cxs.y(1,ii));real(flynn_mat.cxs.y(2,ii))]);
end   
fclose(fid2);

out_file = [pname, first,'.imag_cxs.csv'];
edghdr2csv(edgar_mat,out_file);
fid3 = fopen([out_file],'a+');
fprintf(fid3,'%s',['"ZPDshiftapplied=[']);
fprintf(fid3,'%g,%g',[flynn_mat.zpd_shift(logi.F),flynn_mat.zpd_shift(logi.R)]);
fprintf(fid3,'%s \n',[']"']);
fprintf(fid3,'wavenumber, forward, reverse \n');
for ii= 1:length(flynn_mat.cxs.x)
   fprintf(fid3,'%5.5f, %7.12g, %7.12g \n',[flynn_mat.cxs.x(ii); imag(flynn_mat.cxs.y(1,ii));imag(flynn_mat.cxs.y(2,ii))]);
end   
fclose(fid3);



return