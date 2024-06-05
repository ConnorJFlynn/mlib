function  twst_io = TWST_sky_with_LP715(in_file)

if ~isavar('in_file')||~isafile(in_file)
   twst_io =twst4_to_struct;
else
    twst_io =twst4_to_struct(in_file);
end

figure; plot([1:length(twst_io.time)], twst_io.sig_A(500,:),'o-')
 
lp = twst_io.sig_A(500,:)<1e5; %long-pass filter is in when sig_A(500) is small

edge = lp; 
% find edges 
edge(1:end-1) = (edge(1:end-1)&~edge(2:end)) | (~edge(1:end-1)&edge(2:end));

figure;
done = false
while ~done
   % expand edges
   edge(1:end-1) = edge(1:end-1)|edge(2:end);
   edge(2:end) = edge(1:end-1)|edge(2:end);
   sum(edge)
   lp = twst_io.sig_A(500,:)<1e5 & ~edge;
   op = twst_io.sig_A(500,:)>1e5 & ~edge;
   plot(find(op), twst_io.sig_B([10 60 100],op),'o',find(lp), twst_io.sig_B([10 60 100],lp),'x', find(edge), twst_io.sig_B([10 60 100],edge),'k.' );
     if isavar('v');
      axis(v);
   end
   zoom('on');
   ok = menu('Repeat or done?', 'Repeat','Done')
   v = axis;
   if ok==2
      done = true;
   end
end
xl = xlim; xl_ = [1:length(twst_io.time)]>xl(1) & [1:length(twst_io.time)]<xl(2);

opA = nan(size(twst_io.sig_A)); lpA = opA;
opB = nan(size(twst_io.sig_B)); lpB = opB;
opA(:,op&xl_) = twst_io.sig_A(:,op&xl_); opB(:,op&xl_) = twst_io.sig_B(:,op&xl_);
lpA(:,lp&xl_) = twst_io.sig_A(:,lp&xl_); lpB(:,lp&xl_) = twst_io.sig_B(:,lp&xl_);
figure; plot(twst_io.wl_A, nanmean(opA(:,op&xl_),2),'-k', twst_io.wl_A, nanmean(lpA(:,lp&xl_),2),'-r'); logy;zoom('on')
title('Zoom in to select region to normalize ch A');
menu('Click OK when done zooming','OK');
a_wl = xlim;
wlA = find(twst_io.wl_A>a_wl(1) & twst_io.wl_A<a_wl(2));
o2l = exp(mean(log(nanmean(opA(wlA,xl_),2)./nanmean(lpA(wlA,xl_),2))));
% o2l = (mean(mean(twst_io.sig_A(wlA,op),2))./mean(mean(twst_io.sig_A(wlA,lp),2)));

% figure; subplot(2,1,1); plot(twst_io.wl_B,nanmean(opB,2),...
%  twst_io.wl_B,1.0 .*nanmean(lpB,2),'r-'); legend('Open','LongPass');
% B_wl = xlim;
% title(datestr(twst_io.time(1),'yyyy-mm-dd HH:MM'))
% subplot(2,1,2); plot(twst_io.wl_B,nanmean(opB,2)- 1.09.*nanmean(lpB,2),'r-', 2.*twst_io.wl_A, 0.0001.*(nanmean(opA,2)-1.09.*nanmean(lpA,2)),'-'); 
% xlim(B_wl)
% legend('ChB Open-LP','ChA 1e^-^4 (2W)')

% Try with radiances...
lwl = twst_io.wl_B>1600&twst_io.wl_B<1675;
ef = (mean((nanmean(twst_io.zenrad_B(lwl,op&xl_),2)./nanmean(twst_io.zenrad_B(lwl,lp&xl_),2))));
% ef = 1.1;
figure; subplot(3,1,1); plot(twst_io.wl_B,nanmean(twst_io.zenrad_B(:,op&xl_),2),...
 twst_io.wl_B,ef .*nanmean(twst_io.zenrad_B(:,lp&xl_),2),'r-'); legend('Open','LP 715 nm');
B_wl = xlim;
ylabel('sky radiance')
title(datestr(twst_io.time(1),'yyyy-mm-dd HH:MM'))
subplot(3,1,2); plot(twst_io.wl_B,nanmean(twst_io.zenrad_B(:,op&xl_),2)- ef.*nanmean(twst_io.zenrad_B(:,lp&xl_),2),'r-', ...
   2.*twst_io.wl_A, 0.006.*(nanmean(twst_io.zenrad_A(:,op&xl_),2)-ef.*nanmean(twst_io.zenrad_A(:,lp&xl_),2)),'-'); 
xlim(B_wl)
ylabel('stray radiance')
legend('stray (open - LP)', '0.6% of chA at WL/2')
subplot(3,1,3); plot(twst_io.wl_B,100.*(nanmean(twst_io.zenrad_B(:,op&xl_),2)- ef.*nanmean(twst_io.zenrad_B(:,lp&xl_),2))./(ef.*nanmean(twst_io.zenrad_B(:,lp&xl_),2)),'m-'); 
xlim(B_wl); ylim([0,40]);
ylabel('percent [%]')
xlabel('wavelength [nm]');
legend('% stray light')


figure; subplot(2,1,1); plot([1:length(twst_io.wl_B)],mean(twst_io.sig_B(:,op&xl_),2),...
 [1:length(twst_io.wl_B)],1.0 .*mean(twst_io.sig_B(:,lp&xl_),2),'r-'); legend('Open','LongPass');
title(datestr(twst_io.time(1),'yyyy-mm-dd HH:MM'))
subplot(2,1,2); plot([1:length(twst_io.wl_B)],mean(twst_io.sig_B(:,op&xl_),2),...
 [1:length(twst_io.wl_B)],o2l.*mean(twst_io.sig_B(:,lp&xl_),2),'r-'); legend('Open','LongPass(scaled)')

figure; plot([1:length(twst_io.wl_B)],(mean(twst_io.sig_B(:,op&xl_),2)-...
1.08.*mean(twst_io.sig_B(:,lp&xl_),2)),'r-'); legend('Open-LongPass')
title(datestr(twst_io.time(1),'yyyy-mm-dd HH:MM'));

figure; plot(twst_io.wl_B,mean(twst_io.sig_B(:,op&xl_),2), '-',...
   twst_io.wl_B, o2l.*mean(twst_io.sig_B(:,lp&xl_),2),'-r'); legend('Open','LongPass')
title(datestr(twst_io.time(1),'yyyy-mm-dd HH:MM'));

figure; subplot(2,1,1); plot(twst_io.wl_B,mean(twst_io.sig_B(:,op&xl_),2),...
 twst_io.wl_B,1.08 .*mean(twst_io.sig_B(:,lp&xl_),2),'r-'); legend('Open','LongPass');
title(datestr(twst_io.time(1),'yyyy-mm-dd HH:MM'))
subplot(2,1,2); plot(twst_io.wl_B,(mean(twst_io.sig_B(:,op&xl_),2)-...
1.08.*mean(twst_io.sig_B(:,lp&xl_),2)),'r-'); legend('Open-LongPass')
xlabel('wavelength [nm]')



figure; plot([1:length(twst_io.wl_B)],(mean(twst_io.sig_B(:,op&xl_),2)-...
 o2l  .*mean(twst_io.sig_B(:,lp&xl_),2))./mean(twst_io.sig_B(:,op&xl_),2),'r-');
legend('Relative difference')
title(datestr(twst_io.time(1),'yyyy-mm-dd HH:MM'))
figure; plot([1:length(twst_io.wl_B)],mean(twst_io.zenrad_B(:,op&xl_),2),'-',[1:length(twst_io.wl_B)],o2l.*mean(twst_io.zenrad_B(:,lp&xl_),2),'-')
title(datestr(twst_io.time(1),'yyyy-mm-dd HH:MM'))

return
mn_opA = mean(opA(wlA,:)); mn_lpA =  mean(lpA(wlA,:));
figure; plot(twst_io.time, mn_opA ,'o',twst_io.time,mn_lpA,'x')
abnan = isnan(mn_opA)&isnan(mn_lpA);
OA = patch_ab(twst_io.time, mn_opA,twst_io.time(~isnan(mn_lpA)),mn_lpA(~isnan(mn_lpA)));
LA = patch_ab(twst_io.time, mn_lpA,twst_io.time(~isnan(mn_opA)),mn_opA(~isnan(mn_opA)));
OA(abnan) = NaN; LA(abnan) = NaN;
figure; plot(twst_io.time, mn_opA ,'o',twst_io.time,mn_lpA,'x', twst_io.time, OA,'.', twst_io.time, LA,'.')

for w = length(twst_io.wl_B): -1 : 1
   OB = opB(w,:); LB = lpB(w,:);
   OBp(w,:) = patch_ab(twst_io.time, OB,twst_io.time(~isnan(LB)),LB(~isnan(LB)));
   LBp(w,:) = patch_ab(twst_io.time, LB,twst_io.time(~isnan(OB)),OB(~isnan(OB)));
end
OBp(:,abnan) = NaN;
LBp(:,abnan) = NaN;

% figure; plot(twst_io.time, opB(60,:) ,'o',twst_io.time,lpB(60,:),'x', twst_io.time, OBp(60,:),'.', twst_io.time, LBp(60,:),'.')
figure; plot( twst_io.time, OBp(60,:)./OA,'.', twst_io.time, LBp(60,:)./LA,'.')

ind = 71
[nanmean(LBp(ind,:)./LA), nanmean(OBp(ind,:)./OA), nanmean(LBp(ind,:)./LA)./ nanmean(OBp(ind,:)./OA) ]

figure; plot([1:length(twst_io.wl_B)],nanmean(OBp./(ones([128,1])*OA),2),'-',...
   [1:length(twst_io.wl_B)],nanmean(LBp./(ones([128,1])*LA),2),'-'); legend('Open','LongPass')
title({'TWST-EN0010 Ch B Spectra with and without LP filter';datestr(twst_io.time(1),'yyyy-mm-dd HH:MM')})

figure; plot(twst_io.wl_B,nanmean(OBp,2),'-',twst_io.wl_B,nanmean(LBp,2),'-'); legend('Open','LongPass')
title({'TWST-EN0010 Ch B Spectra with and without LP filter';datestr(twst_io.time(1),'yyyy-mm-dd HH:MM')})



ed = 1;
lps = zeros(size(twst_io.sig_B(:,1))); ops = lps;
vlps = zeros(size(twst_io.sig_A(:,1))); vops = vlps; % vis

lpn = 0; opn = 0; lp_time = 0; op_time = 0;
while ed < length(edge)
   while lp(ed) && ed <= length(edge)
      lpn = lpn + 1;
      lps(:,end) = lps(:,end)+twst_io.sig_B(:,ed)./mean(twst_io.sig_A(wlA,ed));
            vlps(:,end) = vlps(:,end)+twst_io.sig_A(:,ed);
      lp_time(end) = lp_time(end)+twst_io.time(ed);
      ed = ed + 1;
   end
   if lpn>0
      lps(:,end) = lps(:,end)./lpn; lps(:,end+1) = 0;
            vlps(:,end) = vlps(:,end)./lpn; vlps(:,end+1) = 0;
      lp_time(end) = lp_time(end) ./ lpn; lp_time(end+1) = 0;      
       lpn = 0;
   end

   while op(ed) && ed <= length(edge)
      opn = opn + 1;
      ops(:,end) = ops(:,end)+twst_io.sig_B(:,ed)./mean(twst_io.sig_A(wlA,ed));
         vops(:,end) = vops(:,end)+twst_io.sig_A(:,ed);
      op_time(end) = op_time(end)+twst_io.time(ed);
      ed = ed + 1;
   end
   if opn>0
      ops(:,end) = ops(:,end)./opn; ops(:,end+1) = 0;
         vops(:,end) = vops(:,end)./opn; vops(:,end+1) = 0;
      op_time(end) = op_time(end) ./ opn;  op_time(end+1) = 0;
       opn = 0;
   end

   while ~op(ed)&&~lp(ed)&& ed < length(edge)
   ed = ed + 1;
   end
end
op_time(end) = []; lp_time(end) = [];
ops(:,end) = []; lps(:,end) = [];
vops(:,end) = []; vlps(:,end) = [];
figure; plot(op_time(2:12), ops(60,2:12),'o',lp_time(2:12), lps(60,2:12),'x'); dynamicDateTicks

wlA = find(twst_io.wl_A>760 & twst_io.wl_A<900);
figure; plot(op_time(2:12), mean(vops(wlA,2:12)),'o',lp_time(2:12), mean(vlps(wlA,2:12)),'x'); dynamicDateTicks

figure; plot(op_time(2:12), ops(60,2:12)./mean(vops(wlA,2:12)),'o',lp_time(2:12), lps(60,2:12)./mean(vlps(wlA,2:12)),'x'); dynamicDateTicks

[mean(ops(60,2:12)./mean(vops(wlA,2:12))), mean(lps(60,2:12)./mean(vlps(wlA,2:12)))]

figure; plot(op_time, mean(vops(wlA,:)),'o',lp_time, mean(vlps(wlA,:)),'x'); dynamicDateTicks
figure; plot(twst_io.wl_A, vops(:,5), '-',twst_io.wl_A, vlps(:,5), '-')


figure; plot(twst_io.wl_B, mean(ops(:,2:13),2),'-',twst_io.wl_B, mean(lps(:,2:13),2),'-'); 
title('radiance 760-900')
legend('open','LP715')

figure; plot(twst_io.wl_B, mean(ops(:,2:13)./mean(vops(wlA,2:13)),2),'-',twst_io.wl_B, mean(lps(:,2:13)./mean(vlps(wlA,2:13)),2),'-'); 
title('normalized against vis 760-900')
legend('open','LP715')



