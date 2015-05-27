function out_cas = rd_cip_txt(fname);
%%
if ~exist('fname','var')||~exist(fname,'file');
   fname = getfullname_('*.txt','cip');
end
head_str = ['      Date	      Time	     Ch_00	     Ch_01	     Ch_02	     Cnt00	     Cnt01	     Cnt02	     Cnt03	     Cnt04	     Cnt05	     Cnt06	     Cnt07	     Cnt08	     Cnt09	     Cnt10	     Cnt11	     Cnt12	     Cnt13	     Cnt14	     Cnt15	     Cnt16	     Cnt17	     Cnt18	     Cnt19	     Cnt20	     Cnt21	     Cnt22	     Cnt23	     Cnt24	     Cnt25	     Cnt26	     Cnt27	     Cnt28	     Cnt29	     Cnt30	     Cnt31	     Cnt32	     Cnt33	     Cnt34	     Cnt35	     Cnt36	     Cnt37	     Cnt38	     Cnt39	     Cnt40	     Cnt41	     Cnt42	     Cnt43	     Cnt44	     Cnt45	     Cnt46	     Cnt47	     Cnt48	     Cnt49	     Cnt50	     Cnt51	     Cnt52	     Cnt53	     Cnt54	     Cnt55	     Cnt56	     Cnt57	     Cnt58	     Cnt59	     Cnt60	     Cnt61	     Ch_03	     Ch_04	     AD_00	     AD_01	     AD_02	     AD_03	     AD_04	     AD_05	     AD_06	     AD_07	     AD_08	     AD_09	     AD_10	     AD_11	     AD_12	     AD_13	     AD_14	     AD_15	     Ch_05	     Ch_06	     Ch_07	     Ch_08	     Ch_09	     Ch_10	     Ch_11'];
unit_str = ['yyyy-mm-dd	hh:mm:ss.s	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts'];

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
