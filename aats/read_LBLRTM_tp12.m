pathname='d:\Beat\Data\Oklahoma\LBLRTM\';
nfile=2;
for ifile=1:nfile
 [file,pathname] = uigetfile(['d:\Beat\Data\Oklahoma\LBLRTM\','TAPE12*.*'], 'Choose Tape12 file');
 filename=deblank([pathname file]);
 data= lbl_read2(filename)
 disp(data.file_header.user_id)
 disp(data.file_header.secant)
 disp(data.file_header.p_ave)
 disp(data.file_header.t_ave)
 disp(data.file_header.molecule_id)
 disp(data.file_header.mol_col_dens)
 disp(data.file_header.LBL_id)
 od(:,ifile)=data.od;
 end
 figure
 subplot(2,1,1)
 semilogy(1e7./data.v,od)
 xlabel('Wavelength (nm)')
 ylabel('OD')
 subplot(2,1,2)
 plot(1e7./data.v,exp(-od))
 xlabel('Wavelength (nm)')
 ylabel('T')
 
for iplot=1:nfile-1
 figure
 plot(1e7./data.v,od(:,iplot+1)./od(:,1))
end
