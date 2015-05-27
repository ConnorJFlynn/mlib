d = rd_pcasp_dat;
%
%

d.AD_cal = double(d.AD);

for a = 1:8
d.AD_cal(a,:) = (double(d.AD(a,:))+d.setup.offsets(a)) .* d.setup.calcCoeffs(a);
end
%
figure(1); 
ax(1) = subplot(2,1,1); 
plot((d.time-d.time(1))*24*60*60, d.AD(4,:),'-r.');
title(d.fname,'interpreter','none')
legend('Sample Flow')
ax(2) = subplot(2,1,2);
plot((d.time-d.time(1))*24*60*60, d.AD(7,:),'-b.');
legend('Sheath Flow')
linkaxes(ax,'x');
%%

figure(2); 
axx(1) = subplot(2,1,1); 
plot((d.time-d.time(1))*24*60*60, d.AD_cal(4,:),'-r.');
axx(2) = subplot(2,1,2);
plot((d.time-d.time(1))*24*60*60, d.AD_cal(7,:),'-b.');
linkaxes(axx,'x');
%%

for a = 1:8
    figure(a); 
    subplot(2,1,1);
    plot(serial2Hh(d.time), d.AD(a,:), 'ro-');
    title([d.fname, ': ', d.setup.auxLabel{a}],'interpreter','none');
    ylabel('raw AD counts')
    subplot(2,1,2); 
    plot(serial2Hh(d.time), double(d.AD(a,:)+d.setup.offsets(a)).*d.setup.calcCoeffs(a), 'go-');
    xlabel('time');
    ylabel('engineering units')
    titlestr = ['offset = ',num2str(d.setup.offsets(a)), ', coef = ',num2str(d.setup.calcCoeffs(a))];
title(titlestr);
     print(a,[d.pname, 'pcasp_b.',datestr(d.time(1),'yyyy_mm_dd.'),'AD_channel_',num2str(a),'.png'],'-dpng');
end

