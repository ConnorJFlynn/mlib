%This function reads 30 parameter ascii file from C-130 RAF
function [UT,GLON,GLAT,GALT,PSFDC,ATX,PALT]=read_C130_nav_Asia;

data_dir='c:\beat\data\ACE-Asia\Raf\'

[filename,path]=uigetfile([data_dir '*.asc'],'Choose a File',0, 0);
[hh,mm,ss,ATX,BSPHUM,BSPRR,CONCN,GALT,GLAT,GLON,HGM232,PALT,PCAB,PITCH,PLWCC,PLWCF_LPI,PSFDC,RHODT,RHOLA,RHOLA1,RHUM,RICE,ROLL,TFILTF,THDG,WDC,WSC,XCNCOLD,XCNHOT,XGLWC,XTSG1,XTSG10,XUCN]=textread([path filename],'%2d:%2d:%2d%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f','headerlines',1);

UT=hh+mm/60+ss/3600;

figure(11)
subplot(4,1,1)
plot(UT,PITCH,UT,ROLL)
legend('pitch','roll')
subplot(4,1,2)
plot(UT,PSFDC)
ylabel('Press [hPa]')
grid on
subplot(4,1,3)
plot(UT,ATX)
ylabel('Ambient Temp [hPa]')
grid on
figure(21)
subplot(1,2,1)
plot3(GLON,GLAT,GALT)
grid on
subplot(1,2,2)
plot(GLON,GLAT)
grid on

