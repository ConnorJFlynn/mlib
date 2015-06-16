function out_cas = rd_cas_txt(fname);
%%
if ~exist('fname','var')||~exist(fname,'file');
   fname = getfullname('*.txt','cas');
end
head_str = ['      Date	      Time	     Ch_00	     Ch_01	     Ch_02	     Ch_03	     Ch_04	     Ch_05	     Ch_06	     Ch_07	     Ch_08	     Ch_09	     Ch_10	     Ch_11	     Ch_12	     Ch_13	     Ch_14	     Ch_15	     Ch_16	     Ch_17	     Ch_18	     Ch_19	     Ch_20	     Ch_21	     Ch_22	     Ch_23	     Ch_24	     Ch_25	     Ch_26	     Ch_27	     Ch_28	     Ch_29	     Ch_30	     Ch_31	     Ch_32	     Ch_33	     Ch_34	     Ch_35	     Ch_36	     Ch_37	     Ch_38	     Ch_39	     Ch_40	     Ch_41	     Ch_42	     Ch_43	     Ch_44	     Ch_45	     Ch_46	     Ch_47	     Ch_48	     Ch_49	     Ch_50	     Ch_51	     Ch_52	     Ch_53	     Ch_54	     Ch_55	     Ch_56	     Ch_57	     Ch_58	     Ch_59	     Ch_60	     Ch_61	     Ch_62	     Ch_63	     Ch_64	     Ch_65	     Ch_66	     Ch_67	     Ch_68	     Ch_69	     Ch_70	     Ch_71	     AD_00	     AD_01	     AD_02	     AD_03	     AD_04	     AD_05	     AD_06	     AD_07	     AD_08	     AD_09	     AD_10	     AD_11	     AD_12	     AD_13	     AD_14	     AD_15	     AD_16	     AD_17	     AD_18	     AD_19	     AD_20	     AD_21	     AD_22	     AD_23	     AD_24	     AD_25	     AD_26	     AD_27	     AD_28	     AD_29	     AD_30	     Cnt00	     Cnt01	     Cnt02	     Cnt03	     Cnt04	     Cnt05	     Cnt06	     Cnt07	     Cnt08	     Cnt09	     Cnt10	     Cnt11	     Cnt12	     Cnt13	     Cnt14	     Cnt15	     Cnt16	     Cnt17	     Cnt18	     Cnt19	    BCnt00	    BCnt01	    BCnt02	    BCnt03	    BCnt04	    BCnt05	    BCnt06	    BCnt07	    BCnt08	    BCnt09	    BCnt10	    BCnt11	    BCnt12	    BCnt13	    BCnt14	    BCnt15	    BCnt16	    BCnt17	    BCnt18	    BCnt19	     Ch_52	     Ch_53'];
unit_str = ['yyyy-mm-dd	hh:mm:ss.s	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts	      cnts'];

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
