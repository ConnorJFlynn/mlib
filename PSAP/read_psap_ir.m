function [psapr, xmsn_reset, mf_P] = read_psap_ir(ins);
% Reads paired PSAP I and R packets for PSAP with SN = SN
% Augments psapr with normalizaton factors.
% Stubbed in dilution correction factor (not currently used)
% if ~isavar('SN'); SN = []; end
% if ~ischar(SN); SN = num2str(SN); end
if ~isavar('ins')
   ins = getfullname('*psap3wI*.tsv',['bnl_psapi']);
end
[psapi,xmsn_reset, mf_P] = read_psap3w_bnli(ins);

ins_ = strrep(strrep(ins, 'psap3wI','psap3wR'),'psapw3I','psapw3R');
ins_ = fix_file_timestamp(ins_);
psapr = read_psap3w_bnlr(ins_);
done = false;
x = length(xmsn_reset.R_time);
for n = length(psapr.time):-1:1
   while x>1 && xmsn_reset.R_time(x)>psapr.itime(n)
      x = x -1;
   end    
   psapr.blu_norm_factor(n) = xmsn_reset.blu_norm_factor(x);
   psapr.grn_norm_factor(n) = xmsn_reset.grn_norm_factor(x);
   psapr.red_norm_factor(n) = xmsn_reset.red_norm_factor(x);
end

psapr.blu_norm_factor = psapr.blu_norm_factor'; psapr.blu_norm_factor(psapr.blu_norm_factor==0) = 1;
psapr.grn_norm_factor = psapr.grn_norm_factor'; psapr.grn_norm_factor(psapr.grn_norm_factor==0) = 1;
psapr.red_norm_factor = psapr.red_norm_factor'; psapr.red_norm_factor(psapr.red_norm_factor==0) = 1;
psapr.transmittance_blue = psapr.blu_rel ./ psapr.blu_norm_factor;
psapr.transmittance_green = psapr.grn_rel ./ psapr.grn_norm_factor;
psapr.transmittance_red = psapr.red_rel ./ psapr.red_norm_factor;
baditime = diff(psapi.time)<=0; 
if any(baditime)
   psapi.time(baditime) = interp1(find(~baditime), psapi.time(~baditime), find(baditime), 'linear','extrap');
end
psapr.valve_pos = interp1(psapi.time, psapi.valve_pos,psapr.time,'nearest','extrap');
psapr.dil_flow_setpt = interp1(psapi.time, psapi.dil_flow_setpt,psapr.time,'nearest','extrap');
psapr.dil_flow_read = interp1(psapi.time, psapi.dil_flow_read,psapr.time,'nearest','extrap');
psapr.dcf = ones(size(psapr.time)); 

return

function ins_ = fix_file_timestamp(ins_)
for L = length(ins_):-1:1;
   [pname, fstem,x] = fileparts(ins_{L});
   G = textscan(fstem,'%s','delimiter','.'); G = G{1};
   time_str = ['.',G{6},'.'];
   time_str00 = time_str; time_str00(6:7) = '00';
   time_str01 = time_str; time_str01(6:7) = '01';
   time_str02 = time_str; time_str02(6:7) = '02';
   time_str03 = time_str; time_str03(6:7) = '03';
   time_str04 = time_str; time_str04(6:7) = '04';
   if ~isafile(ins_{L})
      if isafile(strrep(ins_{L},time_str,time_str00))
         ins_(L) = {strrep(ins_{L},time_str,time_str00)};
      elseif isafile(strrep(ins_{L},time_str,time_str01))
         ins_(L) = {strrep(ins_{L},time_str,time_str01)};
      elseif isafile(strrep(ins_{L},time_str,time_str02))
         ins_(L) = {strrep(ins_{L},time_str,time_str02)};
      elseif isafile(strrep(ins_{L},time_str,time_str03))
         ins_(L) = {strrep(ins_{L},time_str,time_str03)};
      elseif isafile(strrep(ins_{L},time_str,time_str04))
         ins_(L) = {strrep(ins_{L},time_str,time_str04)};
      else
         ins_(L) = [];
      end
   end
end

return
