function aos = impact_aos_h_2(aos);
%aos = impact_aos_h_2(aos);
% This function separates the 1um and 10um values into distinct variables.
% It was shaddowed by "impact_aos_h" in the aos directory
% 
% This seems to be pretty inefficiently coded...  Very slow. Might be able
% to clean up the selection logic, but will still always be faced with
% doing the polyfit over sequential size cuts, one at a time.
% Trying to add logic to avoid interpolating new results from interpolated
% points.
% disp('Need to double check or improve the logic when the impactor gets stuck [ sum(submicron)==0]')
if isfield(aos,'cut_10um')
   aos = rmfield(aos,'cut_10um');
end
if isfield(aos,'cut_1um')
   aos = rmfield(aos,'cut_1um');
end

fields = fieldnames(aos);
missing = zeros([length(fields),1]);
% label_str = {'fname', 'time';'flags';... 3
%    'CN_contr';'CN_amb';'Bap_G';... 3
%    'Bsp_B_Dry';'Bsp_G_Dry';'Bsp_R_Dry';'Bbsp_B_Dry';'Bbsp_G_Dry';'Bbsp_R_Dry'; ... 6
%    'Bsp_B_Wet';'Bsp_G_Wet';'Bsp_R_Wet';'Bbsp_B_Wet';'Bbsp_G_Wet';'Bbsp_R_Wet'; ...
%    'RH_Inlet';'T_Inlet';'RH_Inlet_Dry';'T_Inlet_Dry';'RH_Neph_Dry';'T_Neph_Dry';'RH_S1';'T_S1';...
%    'RH_S2';'T_S2';'RH_Inlet_Wet';'T_Inlet_Wet';'RH_Neph_Wet';'T_Neph_Wet';'RH_Ambient';'T_Ambient';...
%    'P_Ambient';'P_Neph_Dry';'P_Neph_Wet';'wind_spd';'wind_dir';'Bap_B_3W';'Bap_G_3W';'Bap_R_3W';
%    'ccn_corr';'cpc_corr','SS_pct'};
missing = [NaN,NaN,NaN,... %These fields can't be missing
   99999,499999,9999,...
   9999,9999,9999,9999,9999,9999,...%ref
   9999,9999,9999,9999,9999,9999,...%wet
   999,999,999,999,999,999,999,999,...%T/rh through S1
   999,999,999,999,999,999,999,999,...%t/rh S2 through amb
   9999,9999,9999,... %pressures
   99,999,9999,9999,9999, ... % Winds and Bap
   99999,499999,9]'-1; % ccn_corr,cpc_corr,SS_pct

   no_cut = {'time';'flags';'CN_contr';'CN_amb';'TrB';'TrG';'TrR';'SS_pct';'RH_Inlet';'T_Inlet';...
      'RH_Inlet_Dry';'T_Inlet_Dry';'RH_Inlet_Wet';'T_Inlet_Wet';'RH_Ambient';'T_Ambient';...
      'P_Ambient';'wind_spd';'wind_dir';'ccn_corr';'cpc_corr'};
   um_cut = {'Bap_G' ;   'Bsp_B_Dry';   'Bsp_G_Dry' ;  'Bsp_R_Dry' ;  'Bbsp_B_Dry'; ...
 'Bbsp_G_Dry' ;  'Bbsp_R_Dry' ;  'Bsp_B_Wet';   'Bsp_G_Wet';   'Bsp_R_Wet' ;  'Bbsp_B_Wet' ;...
 'Bbsp_G_Wet';   'Bbsp_R_Wet' ; ...
 'P_Neph_Dry' ;  'P_Neph_Wet' ;  'Bap_B_3W'  ;  'Bap_G_3W'  ;  'Bap_R_3W' };
   
windowSize = 2;
   submicron = filter(ones(1,windowSize)/windowSize,1,single(bitget(aos.flags,5)))==1;
   supmicron = filter(ones(1,windowSize)/windowSize,1,single(bitget(aos.flags,5)==0))==1;
   impactor_pos = (supmicron|submicron) .* cumsum(~submicron&~supmicron);
   impactor_sub = submicron .* cumsum(~submicron&~supmicron);
   impactor_sup = supmicron .* cumsum(~submicron&~supmicron);
%    submicron = logical(bitget(aos.flags,5));

%    supmicron = ~submicron;
   for f = 4:length(fields)
%       disp(fields{f});
%       NaNs = (aos.(fields{f})>=missing(f))|(aos.(fields{f})<-9)|((~submicron)&(~supmicron));
%       aos.(fields{f})(NaNs) = NaN;
      if any(strcmp(fields{f},um_cut))
         aos.([fields{f} '_1um']) = NaN(size(aos.time));
         aos.([fields{f} '_10um']) = NaN(size(aos.time));
         aos.([fields{f} '_1um'])(submicron) = aos.(fields{f})(submicron);
         aos.([fields{f} '_10um'])(supmicron) = aos.(fields{f})(supmicron);
         aos = rmfield(aos,fields{f});
      end
   end
% At this point the measurements have been separated into 1 um and 10 um
% impactor positions, so plot them and look at outliers.

%Next, test just the mads filter on these intervals.
fields = fieldnames(aos);
w = true(size(aos.time));
tic
for n = max(impactor_pos):-1:1;
   if mod(n,100)==0
      toc; tic
   disp(num2str(n))
   end
   samp = impactor_pos==n;
   samp_ind = find(samp);
   for f = 14:length(fields)
      if ~isempty(strfind(fields{f},'_1um'))||~isempty(strfind(fields{f},'_10um'))
         w(samp) = madf(aos.(fields{f})(samp),3);
         aos.(fields{f})(samp&(w==0)) = NaN;
         w(samp) = madf(aos.(fields{f})(samp),3);
         aos.(fields{f})(samp&(w==0)) = NaN;
      end
   end
end
   
for n = max(impactor_pos)-1:-1:2
   if mod(n,100)==0
            toc; tic
   disp(num2str(n))
   end
   samp = (impactor_pos==n);
   pre = (impactor_pos==(n-1));
   post =(impactor_pos==(n+1));
   N_samp = sum(samp);
   N_pre = sum(pre);
   N_post = sum(post);
   samp_ind = find(samp);
   if (N_samp>10)&&(N_samp<60)&&(N_pre>10)&&(N_post>10)
      if submicron(samp_ind(1))==1
         cut = '_10um';
      else %Then we want to fill the gap in the 10 um fields.
         cut = '_1um';
      end
      delta_t = 24*60*(aos.time(samp_ind(end))-aos.time(samp_ind(1)));
     if delta_t<60
        near_pre = ((24*60*(aos.time(samp_ind(1))-aos.time))< 15)&pre;
        near_post = ((24*60*(aos.time-aos.time(samp_ind(end))))< 15)&post;
        for f = 4:length(fields)
           if ~isempty(findstr(fields{f},cut))
              good_pre = (near_pre)&~isNaN(aos.(fields{f}));
              good_post = (near_post)&~isNaN(aos.(fields{f}));
              good = (near_pre|near_post)&~isNaN(aos.(fields{f}));
              if (sum(good_pre)>3)&&(sum(good_post)>3)
            [P,S,mu] = polyfit(aos.time(good),aos.(fields{f})(good),1);
            aos.(fields{f})(samp) = polyval(P,aos.time(samp),[],mu);
              end
           end
        end
     end
   end
end
aos.impactor_pos = impactor_pos;
aos.impactor_sub = impactor_sub;
aos.impactor_sup = impactor_sup;
return
