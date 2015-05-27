%%

mfrraw.time = datenum(mfrraw.timestr, 'yyyy-mm-dd HH:MM:SS.h');
th_raw = raw_raw(:,11:17);
fsb = raw_raw(:,18:24);
blk = raw_raw(:,25:31);
ssb = raw_raw(:,32:38);
% figure; plot(raw_raw(:,1), fsb);title('fsb');
% figure; plot(raw_raw(:,1), ssb);title('ssb');
% figure; plot(raw_raw(:,1), blk);title('blk');
dirh = (ssb+fsb)/2 - blk;
dif = th_raw - dirh;
th = dif + dirh;
%%
figure; plot([1:length(th)]', [dirh(:,1), dif(:,1), th(:,1)]);
legend('dirh', 'dif', 'th')
title('broadband from raw ascii');

figure; plot([1:length(th)]', [dirh(:,2), dif(:,2), th(:,2)]);
legend('dirh', 'dif', 'th')
title('filter1 from raw ascii')
% %%
% 
% % tmp = ancload;
% % raw = tmp;
% %%
ch = {'broadband', 'filter1', 'filter2','filter3', 'filter4','filter5', 'filter6'};
for c = 1:7
   
  raw.vars.(['dirh_',char(ch(c))]).data = (raw.vars.(['ssb_',char(ch(c))]).data + raw.vars.(['fsb_',char(ch(c))]).data)/2 - raw.vars.(['blk_',char(ch(c))]).data;
  raw.vars.(['dif_',char(ch(c))]).data =  raw.vars.(['th_',char(ch(c))]).data  - raw.vars.(['dirh_',char(ch(c))]).data; 
end
 figure; plot(serial2doy0(raw.time), [raw.vars.dirh_broadband.data; raw.vars.dif_broadband.data; raw.vars.th_broadband.data],'.')
 legend('dirh','dif', 'th')
 title('broadband from raw cdf')
 
  figure; plot(serial2doy0(raw.time), [raw.vars.dirh_filter1.data; raw.vars.dif_filter1.data; raw.vars.th_filter1.data],'.')
 legend('dirh','dif', 'th')
 title('raw cdf filter1')