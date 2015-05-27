% AERI DOD review
%%
clear; close('all')
%%
% read in ch1, ch2, sum, and eng files. 
ach1 = ancload;
% ach2 = ancload;
asum = ancload;
%%

aeng = ancload;
%%

figure; plot([1:asum.dims.wnumsum2.length],asum.vars.wnumsum2.data+10,'.',...
[1:asum.dims.wnumsum4.length],asum.vars.wnumsum4.data+20,'x',...
[1:asum.dims.wnumsum6.length],asum.vars.wnumsum6.data+30,'+',...
[1:asum.dims.wnumsum8.length],asum.vars.wnumsum8.data+40,'o',...
[1:asum.dims.wnumsum10.length],asum.vars.wnumsum10.data+50,'.',...
[1:asum.dims.wnumsum12.length],asum.vars.wnumsum12.data+60,'x',...
[1:asum.dims.wnumsum14.length],asum.vars.wnumsum14.data+70,'o');
legend('2','4','6','8','10','12','14')
%%
figure
plot([1:asum.dims.wnumsum12.length],asum.vars.wnumsum12.data-asum.vars.wnumsum4.data,'o')
title('wnumsum12 and wnumsum4')

%%
% Figure out asum dims...
% For Ch 1:wnumsum 1,3,5,7,9,11,13
% wnumsum1==wnumsum5==wnumsum7==wnumsum9
% ResponsivitySpectralAveragesCh1(time, wnumsum1)
% SkyNENCh1(time, wnumsum5)
% HBB2minNENestimateNo1Ch1(time, wnumsum7)
% HBB2minNENestimateNo2Ch1(time, wnumsum9)

% wnumsum3 nearly same as wnumsum11,wnumsum13 
% SkyUniformityCh1(time, wnumsum3)

% wnumsum11==wnumsum13
% SkyRadianceSpectralAveragesCh1(time, wnumsum11) 
% SkyBrightnessTempSpectralAveragesCh1(time, wnumsum13)

%For Ch 2: 2,4,6,8,10,12,14
% wnumsum2==wnumsum6==wnumsum8==wnumsum10
% wnumsum12==wnumsum14
% wnumsum2 nearly same as wnumsum12,wnumsum14 


[100, asum.vars.wnumsum1.data(1), asum.vars.wnumsum1.data(end);
500, asum.vars.wnumsum5.data(1), asum.vars.wnumsum5.data(end);
700, asum.vars.wnumsum7.data(1), asum.vars.wnumsum7.data(end);
900, asum.vars.wnumsum9.data(1), asum.vars.wnumsum9.data(end);
300, asum.vars.wnumsum3.data(1), asum.vars.wnumsum3.data(end);
1100, asum.vars.wnumsum11.data(1), asum.vars.wnumsum11.data(end);
1300, asum.vars.wnumsum13.data(1), asum.vars.wnumsum13.data(end)]

%%
[2, asum.vars.wnumsum2.data(1), asum.vars.wnumsum2.data(end);
6, asum.vars.wnumsum6.data(1), asum.vars.wnumsum6.data(end);
8, asum.vars.wnumsum8.data(1), asum.vars.wnumsum8.data(end);
10, asum.vars.wnumsum10.data(1), asum.vars.wnumsum10.data(end);
4, asum.vars.wnumsum4.data(1), asum.vars.wnumsum4.data(end);
12, asum.vars.wnumsum12.data(1), asum.vars.wnumsum12.data(end);
14, asum.vars.wnumsum14.data(1), asum.vars.wnumsum14.data(end)]

%%
% ResponsivitySpectralAveragesCh1(time, wnumsum1)
% SkyNENCh1(time, wnumsum5)
% HBB2minNENestimateNo1Ch1(time, wnumsum7)
% HBB2minNENestimateNo2Ch1(time, wnumsum9)
figure; 
ax(1) = subplot(4,1,1); 
lines = plot(asum.vars.wnumsum1.data, 1./asum.vars.ResponsivitySpectralAveragesCh1.data,'-');
recolor(lines, serial2doy(asum.time)); colorbar
title('1 / ResponsivitySpectralAveragesCh1');
ax(2) = subplot(4,1,2); 
lines = plot(asum.vars.wnumsum5.data, asum.vars.SkyNENCh1.data,'-');
recolor(lines, serial2doy(asum.time)); colorbar
title('SkyNENCh1');
ax(3) = subplot(4,1,3); 
lines = plot(asum.vars.wnumsum7.data, asum.vars.HBB2minNENestimateNo1Ch1.data,'-');
recolor(lines, serial2doy(asum.time)); colorbar
title('HBB2minNENestimateNo1Ch1');
ax(4) = subplot(4,1,4); 
lines = plot(asum.vars.wnumsum9.data, asum.vars.HBB2minNENestimateNo2Ch1.data,'-');
recolor(lines, serial2doy(asum.time)); colorbar
title('HBB2minNENestimateNo2Ch1');
linkaxes(ax,'x')
%%
% ResponsivitySpectralAveragesCh1(time, wnumsum1)
% SkyNENCh1(time, wnumsum5)
% HBB2minNENestimateNo1Ch1(time, wnumsum7)
% HBB2minNENestimateNo2Ch1(time, wnumsum9)
figure; 
ax2(1) = subplot(4,1,1); 
lines = plot(asum.vars.wnumsum2.data, 1./asum.vars.ResponsivitySpectralAveragesCh2.data,'-');
recolor(lines, serial2doy(asum.time)); colorbar
title('1 / ResponsivitySpectralAveragesCh2');
ax2(2) = subplot(4,1,2); 
lines = plot(asum.vars.wnumsum6.data, asum.vars.SkyNENCh2.data,'-');
recolor(lines, serial2doy(asum.time)); colorbar
title('SkyNENCh2');
ax2(3) = subplot(4,1,3); 
lines = plot(asum.vars.wnumsum8.data, asum.vars.HBB2minNENestimateNo1Ch2.data,'-');
recolor(lines, serial2doy(asum.time)); colorbar
title('HBB2minNENestimateNo1Ch2');
ax2(4) = subplot(4,1,4); 
lines = plot(asum.vars.wnumsum10.data, asum.vars.HBB2minNENestimateNo2Ch2.data,'-');
recolor(lines, serial2doy(asum.time)); colorbar
title('HBB2minNENestimateNo2Ch2');
linkaxes(ax2,'x')
%%
figure; 
axx(1) = subplot(3,1,1); 
lines = semilogy(asum.vars.wnumsum3.data, asum.vars.SkyUniformityCh1.data,'-',...
  asum.vars.wnumsum4.data, asum.vars.SkyUniformityCh2.data,'-' );
recolor(lines, [serial2doy(asum.time),serial2doy(asum.time)]); colorbar
title('SkyUniformityCh1');
axx(2) = subplot(3,1,2); 
lines = plot(asum.vars.wnumsum11.data, asum.vars.SkyRadianceSpectralAveragesCh1.data,'-',...
   asum.vars.wnumsum12.data, asum.vars.SkyRadianceSpectralAveragesCh2.data,'-');
recolor(lines, [serial2doy(asum.time),serial2doy(asum.time)]); colorbar
title('SkyRadianceSpectralAveragesCh1');
axx(3) = subplot(3,1,3); 
lines = plot(asum.vars.wnumsum13.data, asum.vars.SkyBrightnessTempSpectralAveragesCh1.data,'-',...
   asum.vars.wnumsum14.data, asum.vars.SkyBrightnessTempSpectralAveragesCh2.data,'-');
recolor(lines, [serial2doy(asum.time),serial2doy(asum.time)]); colorbar
title('SkyBrightnessTempSpectralAveragesCh1');

linkaxes(axx,'x')

%%




% ResponsivitySpectralAveragesCh1(time, wnumsum1) "AERI LW Responsivity Spectral Averages (Ch1)" ;
% SkyUniformityCh1(time, wnumsum3) "AERI LW Scene Variability Spectral Averages (Ch1)"
% wnumsum3.len = 58, 550.2<wnumsum3<1975 
% SkyNENCh1(time, wnumsum5) "AERI LW Scene NESR Spectral Averages (Ch1)"
% HBB2minNENestimateNo1Ch1(time, wnumsum7) "AERI LW HBB 2min NESR Estimate #1 derived 
%                                           from variance during HBB view (Ch1)"
% HBB2minNENestimateNo2Ch1(time, wnumsum9) "AERI LW HBB 2min NESR Estimate #2 derived 
%                                           from sequential HBB views (Ch1)"                                          
% SkyRadianceSpectralAveragesCh1(time, wnumsum11) "AERI LW Scene Radiance Spectral Averages (Ch1)"                                           
% SkyBrightnessTempSpectralAveragesCh1(time, wnumsum13) "AERI LW Scene Brightness Temp Spectral 
%                                                       Averages (Ch1)" ;
%                                                       
%                                           
% ResponsivitySpectralAveragesCh2(time, wnumsum2) "AERI SW Responsivity Spectral Averages (Ch2)" ;
% SkyNENCh1(time, wnumsum5) "AERI LW Scene NESR Spectral Averages (Ch1)"
% SkyNENCh2(time, wnumsum6) "AERI SW Scene NESR Spectral Averages (Ch2)"
% HBB2minNENestimateNo1Ch2(time, wnumsum8) "AERI SW HBB 2min NESR Estimate #1 derived 
%                                           from variance during HBB view (Ch2)" ;
% HBB2minNENestimateNo2Ch2(time, wnumsum10) "AERI SW HBB 2min NESR Estimate #2 derived 
%                                           from sequential HBB views (Ch2)" ;
% SkyRadianceSpectralAveragesCh2(time, wnumsum12) "AERI SW Scene Radiance Spectral Averages (Ch2)"
% SkyBrightnessTempSpectralAveragesCh2(time, wnumsum14) "AERI SW Scene Brightness Temp Spectral Averages (Ch2)" ;
