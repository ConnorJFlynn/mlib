function aos = impact_aos_h(aos);
%aos = impact_aos_h(aos);
% This function separates the 1um and 10um values into distinct variables. 

fields = fieldnames(aos);
missing = zeros([length(fields),1]);
% label_str = {'time';'flags';...
%    'CN_contr';'CN_amb';'Bap_G';...
%    'Bsp_B_Dry';'Bsp_G_Dry';'Bsp_R_Dry';'Bbsp_B_Dry';'Bbsp_G_Dry';'Bbsp_R_Dry'; ...
%    'Bsp_B_Wet';'Bsp_G_Wet';'Bsp_R_Wet';'Bbsp_B_Wet';'Bbsp_G_Wet';'Bbsp_R_Wet'; ...
%    'RH_Inlet';'T_Inlet';'RH_Inlet_Dry';'T_Inlet_Dry';'RH_Neph_Dry';'T_Neph_Dry';'RH_S1';'T_S1';...
%    'RH_S2';'T_S2';'RH_Inlet_Wet';'T_Inlet_Wet';'RH_Neph_Wet';'T_Neph_Wet';'RH_Ambient';'T_Ambient';...
%    'P_Ambient';'P_Neph_Dry';'P_Neph_Wet';'wind_spd';'wind_dir';'Bap_B_3W';'Bap_G_3W';'Bap_R_3W';
%    'TrB';'TrG';'TrR';'SS_pct'};
missing = [NaN,NaN,... %These fields can't be missing
   99999,99999,9999,...
   9999,9999,9999,9999,9999,9999,...%ref
   9999,9999,9999,9999,9999,9999,...%wet
   999,999,999,999,999,999,999,999,...%T/rh through S1
   999,999,999,999,999,999,999,999,...%t/rh S2 through amb
   9999,9999,9999,... %pressures
   99,999,9999,9999,9999, ... % Winds and Bap
   9,9,9,9]'-1; % TrB,TrG,TrR,SS_pct
windowSize = 2;
   no_cut = {'time';'flags';'CN_contr';'CN_amb';'TrB';'TrG';'TrR';'SS_pct';'RH_Inlet';'T_Inlet';...
      'RH_Ambient';'T_Ambient';'P_Ambient';'wind_spd';'wind_dir'};
   submicron = filter(ones(1,windowSize)/windowSize,1,single(bitget(aos.flags,5)))==1;
   supmicron = filter(ones(1,windowSize)/windowSize,1,single(bitget(aos.flags,5)==0))==1;
%    submicron = logical(bitget(aos.flags,5));
%    supmicron = ~submicron;
   for f = 2:length(fields)
      NaNs = (aos.(fields{f})>=missing(f))|(aos.(fields{f})<-9)|((~submicron)&(~supmicron));
      aos.(fields{f})(NaNs) = NaN;
      if ~any(strcmp(fields{f},no_cut))
         aos.([fields{f} '_1um']) = NaN(size(aos.time));
         aos.([fields{f} '_10um']) = NaN(size(aos.time));
         aos.([fields{f} '_1um'])(submicron) = aos.(fields{f})(submicron);
         aos.([fields{f} '_10um'])(supmicron) = aos.(fields{f})(supmicron);
         aos = rmfield(aos,fields{f});
      end
   end

fields = fieldnames(aos);
% bad_flag = bitget(aos.flags,1)&bitget(aos.flags,2)&bitget(aos.flags,3);
% bad_trans = bitget(aos.flags,6);

tt = length(aos.time);
t = 1;
first = 1;
last = 1;
while t<tt && submicron(t)==submicron(first)
   t = t+1;
end
while t<tt && submicron(t)~=submicron(first)
   t = t+1;
end
while t<tt
   while t<tt && submicron(t)==submicron(first)
      t = t+1;
   end
   if submicron(t)~=submicron(first)
      last = t-1;
   end
   disp([num2str(tt-last)])
   sub = [first:last];
   % Now check which size cut we are interpolating over   
   % screen out bads and interpolate to fill them.
   if submicron(first)==1 %Then we want to fill the gap in the 1um fields
      cut = '_1um';
   else %Then we want to fill the gap in the 10 um fields.
      cut = '_10um';
   end
   for f = 2:length(fields)
      if ~isempty(findstr(fields{f},cut))
%          disp(fields{f})
         NaNs = ~isfinite(aos.(fields{f})(sub))|(aos.(fields{f})(sub)<-9);
         %          if (sum(~NaNs)>10)
         nind = find(~NaNs);
         %          if (sum(~NaNs)>2)&&((max(aos.time(sub(~NaNs)))-min(aos.time(sub(~NaNs))))>(1/36));
         if (sum(~NaNs)>2)&&((aos.time(sub(nind(end)))-aos.time(sub(nind(1))))>(1/48));
            [P,S,mu] = polyfit(aos.time(sub(~NaNs)),aos.(fields{f})(sub(~NaNs)),1);
            aos.(fields{f})(sub(NaNs)) = polyval(P,aos.time(sub(NaNs)),[],mu);
            lte_0 = false(size(sub));
            lte_0(sub(NaNs)) = aos.(fields{f})(sub(NaNs))<=0;
             aos.(fields{f})(lte_0) = NaN;
            big = false(size(sub));
            big(sub(NaNs)) = aos.(fields{f})(sub(NaNs))>(2*max(aos.(fields{f})(sub(~NaNs))));
             aos.(fields{f})(big) = NaN;
         end
      end
   end
   while first < tt && submicron(first)==submicron(first+1)
      first = first +1;
   end
   first = first +1;
end
%    for f = 1:length(fields)
%          if ~isempty(findstr(fields{f},'Bap_'))&&findstr(fields{f},'Bap_')==1
%             NaNs = ~isfinite(aos.(fields{f}))|(aos.(fields{f})<-9)|bad_trans;
%             aos.(fields{f})(NaNs) = NaN;
%          end
% %    end
% save aos.mat aos
