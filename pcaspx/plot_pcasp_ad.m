function plot_pcasp_ad(d);
if ~exist('d','var');
   d = rd_pcasp_dat;
end
close('all')
if isfield(d,'cal')
   AD = d.cal.AD;
else
   AD = (double(d.AD) + double(d.setup.offsets')*ones([1,length(d.time)])).*(double(d.setup.calcCoeffs)'*ones([1,length(d.time)]));
end
for a = 1:8
   figure(a);
   subplot(2,1,1);
   plot(serial2Hh(d.time), d.AD(a,:), 'ro-');
   title([d.fname, ': ', d.setup.auxLabel{a}],'interpreter','none');
   ylabel('raw AD counts')
   subplot(2,1,2);
   plot(serial2Hh(d.time), AD(a,:), 'go-');
   xlabel('time');
   ylabel('engineering units')
   titlestr = ['offset = ',num2str(d.setup.offsets(a)), ', coef = ',num2str(d.setup.calcCoeffs(a))];
   title(titlestr);
%    print(a,[d.pname, 'pcasp_a.',datestr(d.time(1),'yyyy_mm_dd.'),'AD_channel_',num2str(a),'.png'],'-dpng');
end