function houred = hourly_aos(aip_1h,days)
if ~exist('days','var')
   days = ones([1,365]);
end;
field = fieldnames(aip_1h);
houred.time = [0:23];
for f = 2:length(field)
   if length(aip_1h.(field{f}))>1
      tmp = aip_1h.(field{f});
      prop = NaN([24,length(tmp)/24]);
      prop(:) = tmp;
      houred.(field{f}) = NaN([24,1]);
      houred.(['N_',field{f}]) = NaN([24,1]);
      for h = 24:-1:1
         if ~isempty(findstr(field{f},'Bsp_'))&& ~isempty(findstr(field{f},'_10um'))
            ii_good = find((prop(h,days)<300)&~isNaN(prop(h,days)));
         elseif ~isempty(findstr(field{f},'Bsp_')) && ~isempty(findstr(field{f},'_1um'))
            ii_good = find((prop(h,days)<750)&~isNaN(prop(h,days)));
         elseif ~isempty(findstr(field{f},'Bap_'))
            ii_good = find((prop(h,days)<25)&~isNaN(prop(h,days)));
         elseif ~isempty(findstr(field{f},'wind'))
            ii_good = find(ones(size(days))&~isNaN(prop(h,days)));
         else
            ii_good = find(ones(size(days))&~isNaN(prop(h,days)));
         end
         houred.(['N_',field{f}])(h) = length(ii_good);
         houred.(field{f})(h) = mean(prop(h,days(ii_good)));
         %       houred.(['N_',field{f}])(h) = sum(~isNaN(prop(h,:))&(prop(h,:)<300));
         %       houred.(field{f})(h) = mean(prop(h,(prop(h,:)<400)&~isNaN(prop(h,:))));
      end
   end
end
houred.first_day = min(days);
houred.last_day = max(days);
%%
figure; plot(houred.time, houred.Bsp_G_Dry_10um, 'go',houred.time, houred.Bsp_G_Dry_1um, 'g.')
title(['Bsp G hourly averages from day ',num2str(houred.first_day), ':',num2str(houred.last_day)]);
legend('10 um','1 um');
ylabel('1/Mm'); xlabel('hour of day')

figure; plot(houred.time, houred.Bap_G_3W_10um, 'go',houred.time, houred.Bap_G_3W_1um, 'g.')
title(['Bap G hourly averages from day ',num2str(houred.first_day), ':',num2str(houred.last_day)]);
legend('10 um','1 um');
ylabel('1/Mm'); xlabel('hour of day');
%%

figure; 
subplot(2,1,1); 
scatter(houred.time, houred.wind_N,1+16*houred.wind_spd,houred.wind_spd,'filled')
title(['Wind components from day ',num2str(houred.first_day), ':',num2str(houred.last_day)]);

legend('North');
ylabel('m/s'); 
subplot(2,1,2); 
scatter(houred.time, houred.wind_E,1+16*houred.wind_spd,houred.wind_spd,'filled')
title('Wind speeds by component');
legend('East');
ylabel('m/s'); 
xlabel('hour of day');

