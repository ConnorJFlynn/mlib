function good = sky_angstrom_screen(wl, SA, rads)
%%
%angs is the angstrom exponent from only these two wavelengths
angs = ang_exp(rads(:,1), rads(:,end), wl(1), wl(end));
% Pangs is the Angstrom exponent quadratic fit over the inner range of w
Pangs = [];
for si = length(SA):-1:1
    Pangs(si,:) = polyfit(log(wl(1:end)), log(rads(si,1:end)),2);
end
%%
[SA, ij] = sort(SA);
rads_ = rads(ij,:);
angs_ = angs(ij);
Pangs = Pangs(ij,:);
%%
Pangs_a = -1.*Pangs(:,2); %Alpha "linear" angstrom exponent
Pangs_b = -1.*Pangs(:,1); %Beta "curvature" angstrom exponent
edge = 3; % Check for abrupt departures in Angstrom with sliding window of 
% computed fits excluding the center-most value and comparing the residual
% at that point relative to the residual of adjacent values.
w = ones(size(SA));
for ss = (length(SA)-edge):-1:(edge+1)
    ra = [ss-edge:ss-1 ss+1:ss+edge];
%         [P,S] = polyfit(SA(ra),Pangs_a(ra),2);
%     w(ss) = mean(std(Pangs_a(ra)-polyval(P,SA(ra),S)))./abs(Pangs_a(ss)-polyval(P,SA(ss),S));
    [P,S] = polyfit(SA(ra),angs_(ra),2);
    w(ss) = mean(std(angs_(ra)-polyval(P,SA(ra),S)))./abs(angs_(ss)-polyval(P,SA(ss),S));
end
%%

figure(88)
sb(1) = subplot(3,1,1); 
semilogy(SA, rads_(:,[1 end]), '-o',SA(Pangs_b<0), rads_(Pangs_b<0,[1 end]), 'ro');
legend(sprintf('%3.1f nm',1000.*wl(1)),sprintf('%3.1f nm',1000.*wl(end)));
title('sky radiance');
 set(gca,'Yminorgrid','off');
sb(2) = subplot(3,1,2);
plot(SA,angs,'-*',SA(w<.1|Pangs_b<0), angs(w<.1|Pangs_b<0), 'ro');
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

