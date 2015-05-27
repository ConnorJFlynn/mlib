function [zpd_loc,zpd_mag] = find_zpd_fft(ch)
% Usage: [zpd_loc,zpd_mag] = find_zpd_fft(ch)
% Accept assist igram struct with x and y fields and returns zpd location
% and magnitude.  Implements logic from LRTech to identify the zpd position 
% by examining the extrema in the igram and deciding between the maxima and 
% minima with a symmetry condition that the adjacent relative extrema be most 
% similar in magnitude.  This may be preferable to simply finding the
% max(abs(ch.y)) value for ABB or cloudy scenes where the raw igram
% amplitude may become small and the phase may oscillate.

%%

F = bitget(ch.flags,2)>0;
R = bitget(ch.flags,3)>0;
ingram = ch.y(2,:);
%%
clear ingram_
clear blah_spec
clear blah_shift


ingram_(1,:) = zpd2end(ingram,length(ch.x)./2 -2);
ingram_(2,:) = zpd2end(ingram,length(ch.x)./2 -1);
ingram_(3,:) = zpd2end(ingram,length(ch.x)./2 +0);
ingram_(4,:) = zpd2end(ingram,length(ch.x)./2 +1);
ingram_(5,:) = zpd2end(ingram,length(ch.x)./2 +2);
ingram_(6,:) = zpd2end(ingram,length(ch.x)./2 +3);
ingram_(7,:) = zpd2end(ingram,length(ch.x)./2 +4);
ingram_(8,:) = zpd2end(ingram,length(ch.x)./2 +5);
ingram_(9,:) = zpd2end(ingram,length(ch.x)./2 +6);
ingram_(10,:) = zpd2end(ingram,length(ch.x)./2 +7);
ingram_(11,:) = zpd2end(ingram,length(ch.x)./2 +8);
ingram_(12,:) = zpd2end(ingram,length(ch.x)./2 +9);
ingram_(13,:) = zpd2end(ingram,length(ch.x)./2 +10);
ingram_(14,:) = zpd2end(ingram,length(ch.x)./2 +11);
ingram_(15,:) = zpd2end(ingram,length(ch.x)./2 +12);
ingram_(16,:) = zpd2end(ingram,length(ch.x)./2 +13);

blah_spec = (fft(ingram_, [], 2));
blah_shift = blah_spec(:,[length(ch.x)/2+1:length(ch.x),1:length(ch.x)./2]);
%
figure; 
sx(1) = subplot(2,1,1);
lines = plot([1:length(ch.x)],real(blah_shift),'-');
recolor(lines, [-2:13]);
colorbar
sx(2) = subplot(2,1,2);
lines = plot([1:length(ch.x)],imag(blah_shift)./real(blah_shift),'-');
recolor(lines, [-2:13]);
colorbar
linkaxes(sx,'x');
xlim([1.1e4,1.25e4]);
ylim([-1,1])
%%
x = [1:length(ch.x)];
fit_xl = 1e4*[1.1772,1.23];
fit_ii = x>=fit_xl(1) & x<=fit_xl(2);
%%
[P1,~,mu1] = polyfit(x(fit_ii),imag(blah_shift(1,fit_ii))./real(blah_shift(1,fit_ii)),1);
[P2,~,mu1] = polyfit(x(fit_ii),imag(blah_shift(2,fit_ii))./real(blah_shift(2,fit_ii)),1);
[P3,~,mu1] = polyfit(x(fit_ii),imag(blah_shift(3,fit_ii))./real(blah_shift(3,fit_ii)),1);
[P4,~,mu1] = polyfit(x(fit_ii),imag(blah_shift(4,fit_ii))./real(blah_shift(4,fit_ii)),1);
[P5,~,mu1] = polyfit(x(fit_ii),imag(blah_shift(5,fit_ii))./real(blah_shift(5,fit_ii)),1);
[P6,~,mu1] = polyfit(x(fit_ii),imag(blah_shift(6,fit_ii))./real(blah_shift(6,fit_ii)),1);
[P7,~,mu1] = polyfit(x(fit_ii),imag(blah_shift(7,fit_ii))./real(blah_shift(7,fit_ii)),1);
[P8,~,mu1] = polyfit(x(fit_ii),imag(blah_shift(8,fit_ii))./real(blah_shift(8,fit_ii)),1);
[P9,~,mu1] = polyfit(x(fit_ii),imag(blah_shift(9,fit_ii))./real(blah_shift(9,fit_ii)),1);
[P10,~,mu1] = polyfit(x(fit_ii),imag(blah_shift(10,fit_ii))./real(blah_shift(10,fit_ii)),1);
[P11,~,mu1] = polyfit(x(fit_ii),imag(blah_shift(11,fit_ii))./real(blah_shift(11,fit_ii)),1);
[P12,~,mu1] = polyfit(x(fit_ii),imag(blah_shift(12,fit_ii))./real(blah_shift(12,fit_ii)),1);
[P13,~,mu1] = polyfit(x(fit_ii),imag(blah_shift(13,fit_ii))./real(blah_shift(13,fit_ii)),1);
[P14,~,mu1] = polyfit(x(fit_ii),imag(blah_shift(14,fit_ii))./real(blah_shift(14,fit_ii)),1);
[P15,~,mu1] = polyfit(x(fit_ii),imag(blah_shift(15,fit_ii))./real(blah_shift(15,fit_ii)),1);
[P16,~,mu1] = polyfit(x(fit_ii),imag(blah_shift(16,fit_ii))./real(blah_shift(16,fit_ii)),1);


[Pp1,~,mu1] = polyfit(x(fit_ii),imag(blah_shift(1,fit_ii))./real(blah_shift(1,fit_ii)),2);
[Pp2,~,mu1] = polyfit(x(fit_ii),imag(blah_shift(2,fit_ii))./real(blah_shift(2,fit_ii)),2);
[Pp3,~,mu1] = polyfit(x(fit_ii),imag(blah_shift(3,fit_ii))./real(blah_shift(3,fit_ii)),2);
[Pp4,~,mu1] = polyfit(x(fit_ii),imag(blah_shift(4,fit_ii))./real(blah_shift(4,fit_ii)),2);
[Pp5,~,mu1] = polyfit(x(fit_ii),imag(blah_shift(5,fit_ii))./real(blah_shift(5,fit_ii)),2);
[Pp6,~,mu1] = polyfit(x(fit_ii),imag(blah_shift(6,fit_ii))./real(blah_shift(6,fit_ii)),2);
[Pp7,~,mu1] = polyfit(x(fit_ii),imag(blah_shift(7,fit_ii))./real(blah_shift(7,fit_ii)),2);
[Pp8,~,mu1] = polyfit(x(fit_ii),imag(blah_shift(8,fit_ii))./real(blah_shift(8,fit_ii)),2);
[Pp9,~,mu1] = polyfit(x(fit_ii),imag(blah_shift(9,fit_ii))./real(blah_shift(9,fit_ii)),2);
[Pp10,~,mu1] = polyfit(x(fit_ii),imag(blah_shift(10,fit_ii))./real(blah_shift(10,fit_ii)),2);
[Pp11,~,mu1] = polyfit(x(fit_ii),imag(blah_shift(11,fit_ii))./real(blah_shift(11,fit_ii)),2);
[Pp12,~,mu1] = polyfit(x(fit_ii),imag(blah_shift(12,fit_ii))./real(blah_shift(12,fit_ii)),2);
[Pp13,~,mu1] = polyfit(x(fit_ii),imag(blah_shift(13,fit_ii))./real(blah_shift(13,fit_ii)),2);
[Pp14,~,mu1] = polyfit(x(fit_ii),imag(blah_shift(14,fit_ii))./real(blah_shift(14,fit_ii)),2);
[Pp15,~,mu1] = polyfit(x(fit_ii),imag(blah_shift(15,fit_ii))./real(blah_shift(15,fit_ii)),2);
[Pp16,~,mu1] = polyfit(x(fit_ii),imag(blah_shift(16,fit_ii))./real(blah_shift(16,fit_ii)),2);

figure; plot([-2:13],abs([P1(1),P2(1),P3(1),P4(1),P5(1),P6(1),P7(1),P8(1),...
   P9(1),P10(1),P11(1),P12(1),P13(1),P14(1),P15(1),P16(1)]),'-o',...
   [-2:13],abs([Pp1(1),Pp2(1),Pp3(1),Pp4(1),Pp5(1),Pp6(1),Pp7(1),Pp8(1),...
   Pp9(1),Pp10(1),Pp11(1),Pp12(1),Pp13(1),Pp14(1),Pp15(1),Pp16(1)]),'-x')
%%
figure; plot([1:length(ch.x)./2],imag(blah_spec(:,1:(length(ch.x)./2)))./real(blah_spec(:,1:(length(ch.x)./2))),'-');
axis(v)
%%
return

