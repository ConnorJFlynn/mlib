twst_io =twst4_to_struct;

figure; plot([1:length(twst_io.time)], twst_io.sig_A(500,:),'o-')
 
lp = twst_io.sig_A(500,:)<1e5;

edge = lp; 
edge(1:end-1) = (edge(1:end-1)&~edge(2:end)) | (~edge(1:end-1)&edge(2:end));

figure;
edge(1:end-1) = edge(1:end-1)|edge(2:end);
edge(2:end) = edge(1:end-1)|edge(2:end);
sum(edge)
lp = twst_io.sig_A(500,:)<1e5 & ~edge;
op = twst_io.sig_A(500,:)>1e5 & ~edge;
 plot(find(op), twst_io.sig_B([10 60 100],op),'o',find(lp), twst_io.sig_B([10 60 100],lp),'x', find(edge), twst_io.sig_B([10 60 100],edge),'k.' )

wlA = find(twst_io.wl_A>820 & twst_io.wl_A<900);
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



