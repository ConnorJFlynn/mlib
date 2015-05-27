%GPS PW
pathname='C:\Beat\Data\Oklahoma\WVIOP3\GPS\';
[STATION,MJD_LMNO,ZWD,PW_LMNO,PW_ERR,K_FAC] = textread([pathname 'lmno_zwd_pw.asc'],'%s%f%f%f%f%f','headerlines',1);
[STATION,MJD_OKC2,ZWD,PW_OKC2,PW_ERR,K_FAC] = textread([pathname 'okc2_zwd_pw.asc'],'%s%f%f%f%f%f','headerlines',1);
DOY_LMNO=MJD_LMNO+2400000.5-julian(31,12,1999,0);
DOY_OKC2=MJD_OKC2+2400000.5-julian(31,12,1999,0);
%AATS-6 PW
[DOY_AATS6_2,PW_AATS6_2,AOD_flag_2,AOD_AATS6_2,AOD_Error_AATS6_2,alpha_AATS6_2,lambda_AATS6_2]=read_AATS6(3);
%Model PW
pathname='C:\Beat\Data\Oklahoma\WVIOP3\Model\';
[DOY_Model,PW_Model] = textread([pathname 'pwv_model.asc'],'%f%f','headerlines',0);
figure(1)
orient landscape
plot(DOY_OKC2,PW_OKC2/10,'.-',DOY_LMNO,PW_LMNO/10,'.-',DOY_AATS6_2,PW_AATS6_2,'.',DOY_Model,PW_Model,'k.-')
legend('GPS CF','GPS Lamont','AATS-6','Model')
xlabel('Day of Year 2000','FontSize',14)
ylabel('CWV (cm)','FontSize',14)
axis([262,284,0,6])
grid on
set(gca,'FontSize',14)
