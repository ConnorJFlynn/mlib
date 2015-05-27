clear 

pathname='d:\Beat\Data\Filter\SPM2000\';
filename=str2mat('300_g.prn','313_g.prn');
filename=str2mat(filename,'305_1.prn','310_1.prn','320_1.prn','340_1.prn');
filename=str2mat(filename,'500_1.prn','610_1.prn');
filename=str2mat(filename,'675_1.prn');
filename=str2mat(filename,'862_1.prn','946_1.prn');
filename=str2mat(filename,'1024_1.prn');
filename=str2mat(filename,'368_2.prn','412_2.prn','450_2.prn');
filename=str2mat(filename,'500_2.prn','610_2.prn');
filename=str2mat(filename,'675_2.prn','719_2.prn');
filename=str2mat(filename,'778_2.prn','817_2.prn');
filename=str2mat(filename,'862_2.prn','946_2.prn');
filename=str2mat(filename,'1024_2.prn');
filename=str2mat(filename,'368_3.prn','412_3.prn','450_3.prn');
filename=str2mat(filename,'500_3.prn','610_3.prn');
filename=str2mat(filename,'675_3.prn','719_3.prn');
filename=str2mat(filename,'778_3.prn','817_3.prn');
filename=str2mat(filename,'862_3.prn','946_3.prn');
filename=str2mat(filename,'1024_3.prn');

colors=['r-' 'g-' 'b-' 'c-' 'm-' 'y-' 'r:' 'g:' 'b:' 'c:' 'm:' 'y:' 'r-' 'g-'];
%********************************reads filter scans*******************************
 for ifilter=[1:2 25:34]
    
 file= deblank([pathname filename(ifilter,:)]); 
 fid=fopen(file,'rt')
 data=fscanf(fid, '%g %g', [2,inf]);
 fclose(fid);
 lambda_SPM1=data(1,:);
 data(2,:) =data(2,:)/max(data(2,:));
 response1=data(2,:);
 
 %[cwvl,FWHM]=cwl(lambda_SPM1,response1,0.001);

 
 %figure(1)
 %plot (lambda_SPM1,response1,[cwvl cwvl],[0,1],'r',[cwvl-FWHM/2 cwvl-FWHM/2],[0,1],'g',[cwvl+FWHM/2 cwvl+FWHM/2],[0,1],'g')
 %orient landscape
 %xlabel('Wavelength [µm]');
 %ylabel('Response');
 %title('Relative Response of SPM');
 %set(gca,'xlim',[0.280 1.10])
 %set(gca,'ylim',[0 1 ]) 
 %grid on

% figure(2)
% loglog(lambda_SPM1,response1,colors([2*ifilter-1 2*ifilter]))
% loglog(lambda_SPM1,response1)
% semilogy(lambda_SPM1,response1)
% orient landscape
% xlabel('Wavelength (nm)');
% ylabel('Relative Response');
% title('Relative Response of SPM');
% set(gca,'xlim',[300 1100])
% set(gca,'ylim',[0 1 ]) 
% set(gca,'xtick',[0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.0]);
% grid on
% pause
% set(gca,'position',[.13 .11 0.7 0.815])

%magic_factor=magicf(lambda_SPM1,response1) 

magic_factor(ifilter)=magicf2(lambda_SPM1,response1)
%magic_factor_red=magicf2(lambda_SPM1+cwvl/1e3,response1)
%magic_factor_blue=magicf2(lambda_SPM1-cwvl/1e3,response1)

%1-magic_factor_red/magic_factor
%1-magic_factor_blue/magic_factor

%yi = interp1(lambda_SPM1,response1,632.8)


%write to file
%fid=fopen('d:\beat\data\filter\SPM2000\cwvl.txt','a');
%fprintf(fid,'%c',filename(ifilter,:));
%fprintf(fid,'%9.2f',cwvl,FWHM);
%fprintf(fid,'\n');
%fclose(fid);

end


