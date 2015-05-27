function out_cas = rd_spp_txt(fname);
%%
if ~exist('fname','var')||~exist(fname,'file');
   fname = getfullname_('*.txt','spp');
end
head_str = ['      Date	      Time	      Ch_0	      Ch_1	      Ch_2	      Ch_3	      Ch_4	      Ch_5	      Ch_6	      Ch_7	      Ch_8	      Ch_9	     Ch_10	     Ch_11	     Ch_12	     Ch_13	     Ch_14	      Cnt1	      Cnt2	      Cnt3	      Cnt4	      Cnt5	      Cnt6	      Cnt7	      Cnt8	      Cnt9	     Cnt10	     Cnt11	     Cnt12	     Cnt13	     Cnt14	     Cnt15	     Cnt16	     Cnt17	     Cnt18	     Cnt19	     Cnt20	     Cnt21	     Cnt22	     Cnt23	     Cnt24	     Cnt25	     Cnt26	     Cnt27	     Cnt28	     Cnt29	     Cnt30	      ChkS'];
unit_str = ['yyyy-mm-dd	hh:mm:ss.s	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts'];

headstr = textscan(head_str,'%s','delimiter','\t');
header = headstr{1};
%%


%%

fid = fopen(fname, 'r');
format_str = ['%s %s ',repmat(['%f '],1,length(header))];

cas = textscan(fid,format_str,'delimiter','\t','headerlines',6);
fclose(fid);


%%

for i = length(cas{1}):-1:1
   tstr(i,:) = [cas{1}{i}, ' ', cas{2}{i}];
end
%%
out_cas.time = datenum(tstr,'yyyy-mm-dd HH:MM:SS.FFF');
cas(1) = [];cas(1) = [];
%%
for f = 1:length(header)
   out_cas.(header{f}) = cas{f};
end
%%
out_cas.fname = fname;
