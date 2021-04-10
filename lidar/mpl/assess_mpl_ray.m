function assess_mpl_ray(polavg,inarg)
skip = logical(menu('Assess collimation or skip?','Assess','skip')-1); pause(0.05);
if ~skip
i = 0;
clear hr_ avg_
all_done = false;
while ~all_done
   mn_0 = menu('Select one or more periods to assess collimation?','Yes','No, all done.');pause(.1);
   if mn_0 ==1
      i = i+1;       hr_(i,:) = false(size(polavg.time));
      done_looping = false;
      while ~done_looping
         mn = menu({'Zoom in to a period of time with clear air.';...
            'Select "Ready" to add the displayed times to the current average';...
            'Or "Done" to complete this average.'},'Add to this average.','Done with this average.');
         if mn==1
            xl = xlim; hr_(i,:) = hr_(i,:) | serial2hs(polavg.time)>xl(1)&serial2hs(polavg.time)<xl(2);sum(hr_(i,:))
            avg_(i,:) = mean(polavg.attn_bscat(:,hr_(i,:)),2);
            cal_r = polavg.range>8 & polavg.range<10;
            cal_mean = mean(mean(avg_(:,cal_r)))./mean(polavg.std_attn_prof(cal_r));
            figure_(79);pause(0.1); plot(avg_./cal_mean ,polavg.range,'-',polavg.std_attn_prof,polavg.range,'--');logx
         else
            done_looping = true;
         end
      end
   elseif mn_0 ==2
      all_done = true;
   end
end
cal_means = mean(avg_(:,cal_r)./(ones([size(avg_,1),1])*(polavg.std_attn_prof(cal_r)')),2);
figure_(79);pause(0.1); plot(avg_./cal_means , polavg.range,'-',polavg.std_attn_prof',polavg.range,'--');logx;
title({['Collimation and overlap assessment for ',upper(inarg.tla(1:3)), ' ',upper(inarg.tla(4:end))];...
   datestr(polavg.time(1),'yyyy-mm-dd')});
xlabel('km^-^1 sr^-^1'); ylabel('range [km]');
outfile1 = [inarg.fig_dir, inarg.tla,'_mplpol_3flynn.col_sr_per_km.',datestr(polavg.time(1),'yyyy_mm_dd'),'.fig'];
figure_(89);pause(0.1); plot(avg_ , polavg.range,'-',(polavg.std_attn_prof').*cal_means,polavg.range,'--');logx;
title({['Collimation and overlap assessment for ',upper(inarg.tla(1:3)), ' ',upper(inarg.tla(4:end))];...
   datestr(polavg.time(1),'yyyy-mm-dd')});
xlabel('MHz'); ylabel('range [km]');
outfile2 = [inarg.fig_dir, inarg.tla,'_mplpol_3flynn.col_MHz.',datestr(polavg.time(1),'yyyy_mm_dd'),'.fig'];
N = 0;
while exist(outfile1)||exist(outfile2)
   N = N + 1;
   outfile1 = [inarg.fig_dir, inarg.tla,'_mplpol_3flynn.collimation.',datestr(polavg.time(1),'yyyy_mm_dd'),'.',num2str(N),'.fig'];
   outfile2 = [inarg.fig_dir, inarg.tla,'_mplpol_3flynn.col_MHz.',datestr(polavg.time(1),'yyyy_mm_dd'),'.',num2str(N),'.fig'];
end
ok = menu('Zoom in and click OK when ready to save figure 89.','OK, save it.');
pause(0.05);yl =ylim;
saveas(89,outfile1)
close(89)
ylim(yl);
ok = menu('Zoom in and click OK when ready to save figure 79.','OK, save it.');
pause(0.05);
saveas(79,outfile2)
end

return