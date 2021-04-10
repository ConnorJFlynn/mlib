function psapr = read_psap3w_bnlr(ins);

if ~isavar('ins') || isempty(ins)
   ins = getfullname_('*psap3wr*.tsv','bnl_psap');
end

if iscell(ins)&&length(ins)>1
   psapr = read_psap3w_bnlr(ins{1});
   psapr2 = read_psap3w_bnlr(ins(2:end));
   if ~isempty(psapr)
       psapr_.fname = unique([psapr.fname,psapr2.fname]);
       psapr = cat_timeseries(psapr, psapr2);psapr.fname = psapr_.fname;
   else
       psapr = psapr2;
   end
else
   if iscell(ins);
      fid = fopen(ins{1});
      [psapr.pname,psapr.fname,ext] = fileparts(ins{1});
   else
      fid = fopen(ins);
      [psapr.pname,psapr.fname,ext] = fileparts(ins);
   end
   psapr.pname = {psapr.pname}; psapr.fname = {[psapr.fname, ext]};
   this = fgetl(fid);
   a = 1;
   while isempty(strfind(this,'yyyy-mm-dd'))&&isempty(strfind(this,'hh:mm:ss.sss'))&&isempty(strfind(this,'YYMMDDhhmmss'))
      %%
      this = fgetl(fid);
      a = a + 1;
      %%
   end
   % yyyy-mm-dd	hh:mm:ss.sss	YYMMDDhhmmss
   format_str = '%s %s %s ';
   %signed 32bit hex int		unsigned 12bit hex int	 signed 32bit hex int		unsigned 12bit hex int		signed 32bit hex int		unsigned 12bit hex int
   format_str = [format_str,'%s %s %s %s ']; % blu sig, ref, ct, over
   format_str = [format_str,'%s %s %s %s ']; % grn sig, ref, ct, over
   format_str = [format_str,'%s %s %s %s ']; % red sig, ref, ct, over
   format_str = [format_str,'%s %s %s %s ']; % dark sig, ref, ct, over
   % Dark Signal sum	Dark ref. sum	Dark sample count	Dark overflow count
   %Mass flow output, 1 sec	Mass flow	Flags
   format_str = [format_str, '%f %f %s %*[^\n]'];
   %
   %mV	LPM
   
   C = textscan(fid, format_str);
   % Clean up incomplete C
   first_len = size(C{1},1);last_len = size(C{end},1);
   if first_len ~= last_len
      for CC = length(C):-1:1
         if size(C{CC},1)~=last_len
            C{CC}(last_len+1:end) = [];
         end
      end
   end
   D = {[]};
   while ~feof(fid) %then get_more_parts
      disp(['Bad packet in :',psapr.fname])
      while isempty(D{end})
         tmp = fgetl(fid); D = textscan(tmp,format_str);
      end
      C_ = textscan(fid, format_str);   first_len = size(C_{1},1);last_len = size(C_{end},1);
      if first_len ~= last_len
         for CC = length(C_):-1:1
            if size(C_{CC},1)~=last_len
               C_{CC}(last_len+1:end) = [];
            end
         end
      end
      for L = 1:length(C_)
         C(L) = {[C{L};C_{L}]};
      end
   end
   fclose(fid);
   C(1)= {char(C{1})};
   C(2)= {char(C{2})};
   C(3) ={char(C{3})};
   nonan = ~strcmp(C{4},'NaN');
   if any(nonan)
   T = [C{1},repmat(' ',[length(C{7}),1]), C{2}];
   psapr.time = datenum(T,'yyyy-mm-dd HH:MM:SS.fff');
   nans = NaN(size(psapr.time));
   psapr.itime = nans; psapr.I_SS = nans;

   
   IT = [repmat('20',[length(C{7}),1]), C{3}];
   psapr.itime(nonan)  = datenum(IT(nonan,:),'yyyymmddHHMMSS');
   V = datevec(psapr.itime(nonan)); psapr.I_SS(nonan) = floor(V(:,6));
   
   % A = C{1};
   % B = C{2};
   % D = C{3};
   % for x =length(A):-1:1
   %     D_str(x) = {[A{x}, ' ',B{x}]};
   %     D_str_(x) = {['20',D{x}]};
   % end
   % psapr.time = datenum(D_str,'yyyy-mm-dd HH:MM:SS.FFF');
   % psapr.time_ = datenum(D_str_,'yyyymmddHHMMSS');
   psapr.blu_sig = nans; psapr.blu_sig(nonan)= hex2nm(C{4}(nonan));
   psapr.blu_ref = nans; psapr.blu_ref(nonan)= hex2nm(C{5}(nonan));
   psapr.blu_adc_cnt = nans; psapr.blu_adc_cnt(nonan)= hex2nm(C{6}(nonan));
   psapr.blu_adc_over = nans; psapr.blu_adc_over(nonan)= hex2nm(C{7}(nonan));
   psapr.grn_sig = nans; psapr.grn_sig(nonan)= hex2nm(C{8}(nonan));
   psapr.grn_ref = nans; psapr.grn_ref(nonan)= hex2nm(C{9}(nonan));
   psapr.grn_adc_cnt = nans; psapr.grn_adc_cnt(nonan)= hex2nm(C{10}(nonan));
   psapr.grn_adc_over = nans; psapr.grn_adc_over(nonan)= hex2nm(C{11}(nonan));
   psapr.red_sig = nans; psapr.red_sig(nonan)= hex2nm(C{12}(nonan));
   psapr.red_ref = nans; psapr.red_ref(nonan)= hex2nm(C{13}(nonan));
   psapr.red_adc_cnt = nans; psapr.red_adc_cnt(nonan)= hex2nm(C{14}(nonan));
   psapr.red_adc_over = nans; psapr.red_adc_over(nonan)= hex2nm(C{15}(nonan));
   psapr.dark_sig = nans; psapr.dark_sig(nonan)= hexntwo(C{16}(nonan));
   psapr.dark_ref = nans; psapr.dark_ref(nonan)= hexntwo(C{17}(nonan));
   psapr.dark_adc_cnt = nans; psapr.dark_adc_cnt(nonan)= hex2nm(C{18}(nonan));
   psapr.dark_adc_over = nans; psapr.dark_adc_over(nonan)= hex2nm(C{19}(nonan));
   psapr.flow_AD = nans; psapr.flow_AD(nonan)= C{20}(nonan);
   psapr.flow_lpm = nans; psapr.flow_lpm(nonan)= C{21}(nonan);
   psapr.flags = nans; psapr.flags(nonan)= hex2nm(C{22}(nonan));
   %%
   psapr.red_rel = (psapr.red_sig-psapr.dark_sig)./(psapr.red_ref-psapr.dark_ref);
   psapr.grn_rel = (psapr.grn_sig-psapr.dark_sig)./(psapr.grn_ref-psapr.dark_ref);
   psapr.blu_rel = (psapr.blu_sig-psapr.dark_sig)./(psapr.blu_ref-psapr.dark_ref);
   else
       psapr = [];
   end
end

%%
%
% figure; plot(serial2Hh(psapr.time), [psapr.red_ref - mean(psapr.red_ref),psapr.grn_ref - mean(psapr.grn_ref),psapr.blu_ref - mean(psapr.blu_ref)],'.');
% legend('red','grn','blu');
% title('mean subtracted reference for each wavelength');
% xlabel('time [UTC]');
% %%
%
% figure; plot(serial2doy(psapr.time), [psapr.red_sig./psapr.red_ref - mean(psapr.red_sig./psapr.red_ref),psapr.grn_sig./psapr.grn_ref - mean(psapr.grn_sig./psapr.grn_ref),psapr.blu_sig./psapr.blu_ref - mean(psapr.blu_sig./psapr.blu_ref)],'.');
% legend('red','grn','blu')
%%
return
