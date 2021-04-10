function good = sky_angstrom_screen(wl, SA, rads)
%%
%angs is the angstrom exponent from only these two wavelengths
angs = ang_exp(rads(:,2), rads(:,end-1), wl(2), wl(end-1));
% Pangs is the Angstrom exponent quadratic fit over the inner range of w
Pangs = [];
for si = length(SA):-1:1
    Pangs(si,:) = polyfit(log(wl(2:end-1)), log(rads(si,2:end-1)),2);
end
%%
% Instead of sorting by SA, probably just want to take only SA with
% monotonic trend and greater than some threshold. This will preclude
% angstrom screen of near-sun (which is white anyway) and split alm into
% separate branches, making it more properly local. 

[SA, ij] = sort(SA);
rads_ = rads(ij,:);
angs_ = angs(ij);
Pangs = Pangs(ij,:);
%%
Pangs_a = -1.*Pangs(:,2); %Alpha "linear" angstrom exponent
Pangs_b = -1.*Pangs(:,1); %Beta "curvature" angstrom exponent
edge = 6; % Check for abrupt departures in Angstrom with sliding window of 
% computed fits excluding the center-most value and comparing the residual
% at that point relative to the residual of adjacent values.
w = ones(size(SA));
for ss = (length(SA)-edge):-1:(edge+1)
    ra = [ss-edge:ss-1 ss+1:ss+edge];
%         [P,S] = polyfit(SA(ra),Pangs_a(ra),2);
%     w(ss) = mean(std(Pangs_a(ra)-polyval(P,SA(ra),S)))./abs(Pangs_a(ss)-polyval(P,SA(ss),S));
    [P,S] = polyfit(log(SA(ra)),Pangs_a(ra),2);
%     if (angs_(ss)-polyval(P,SA(ss),S))<0
    w(ss) = mean(std(Pangs_a(ra)-polyval(P,log(SA(ra)),S)))./abs(Pangs_a(ss)-polyval(P,log(SA(ss)),S));
%     end
end
w(w>1) = 1;

%%
figure(88)
sb(1) = subplot(3,1,1); 
semilogy(SA, rads_(:,[1 end]), '-o',SA(Pangs_b<0), rads_(Pangs_b<0,[1 end]), 'ro');
legend(sprintf('%3.1f nm',1000.*wl(2)),sprintf('%3.1f nm',1000.*wl(end-1)));
title('sky radiance');
 set(gca,'Yminorgrid','off');
sb(2) = subplot(3,1,2);
plot(SA,Pangs_a,'-*',SA(w<.1|Pangs_b<0), Pangs_a(w<.1|Pangs_b<0), 'ro');
legend('all','iffy','location','southeast')
title('Angstrom exponent from above wavelengths')
sb(3) = subplot(3,1,3);
semilogy(SA,w,'k-x')
 set(gca,'Yminorgrid','off');
 xlabel('scattering angle [deg]');
 title('weight based on consistent angstrom exponent vs neighbors')
linkaxes(sb,'x');
%%

good(ij) = w>.1 & Pangs_b>0;

return
%%

