% Check the monthly aos, aos_um, and aos_1min files.

fstr = 'CN_amb';

figure; plot(serial2doy(aos_mon.time), aos_mon.(fstr), 'x', ...
   serial2doy(aos_um.time), aos_um.(fstr), '.', ...
   serial2doy(aos_1min.time), aos_1min.(fstr), 'o' )

%%
figure; 
clear ax
ax(1) = subplot(2,1,1); plot(serial2doy(aos_mon.time), [aos_mon.CN_contr, aos_mon.cpc_corr], '.');
title('CN contr and CPC_corr','interpreter','none')
ax(2) = subplot(2,1,2); plot(serial2doy(aos_mon.time), [aos_mon.CN_amb, aos_mon.ccn_corr], '.');
title('CN amb and CCN_corr','interpreter','none')
linkaxes(ax,'x')

% CN_contr == CPC_corr
% CN_amb == CCN_corr
%%
figure; 
ax2(1) = subplot(2,1,1); plot(serial2doy(aos_mon.time),[aos_mon.Bap_G, aos_mon.Bap_G_3W],'.');
ax2(2) = subplot(2,1,2); plot(serial2doy(aos_mon.time), [aos_mon.Bap_B_3W], 'b.', ...
  serial2doy(aos_mon.time), [aos_mon.Bap_R_3W], 'r.' );
linkaxes(ax2,'xy')

%%
figure; 
clear ax2
plot(serial2doy(aos_mon.time), aos_mon.Bap_G_3W, 'k.', ...
   serial2doy(aos_um.time), [aos_um.Bap_G_3W_1um, aos_um.Bap_G_3W_10um],'o')

%%
figure; 
clear ax2
plot(serial2doy(aos_mon.time), aos_mon.Bsp_B_Dry, 'k.', ...
   serial2doy(aos_um.time), [aos_um.Bsp_B_Dry_1um, aos_um.Bsp_B_Dry_10um],'o')

%%





field = fieldnames(aos);
f = 3;
clear xl
%%
if exist('xl','var')
   xl = xlim;
end
if (f>=length(field))
   f = 4;
else
   f = f+1;
end

% for f = 4:length(field);
if all(size(aos.(field{f}))==size(aos.time))
if isempty(findstr(field{f},'_1um'))&&isempty(findstr(field{f},'_10um'))
   plot(serial2doy(aos.time), aos.(field{f}),'.');
   xlabel('time (day of year)');
   title(field{f},'interpreter','none')
else
   plot(serial2doy(aos.time), aos.(field{f}),'.',serial2doy(aos.time), aos.(field{f+1}),'.');
   xlabel('time (day of year)');
lg =    legend(field{f}, field{f+1});
set(lg,'interpreter','none')
   f = f+1;
   title(field{f},'interpreter','none')
end
if exist('xl','var')
xlim(xl);
end
else
   disp(field{f})
   end
% end
%%
figure; 
NaNs = isNaN(aip.w_G_1um);
ssa = interp1(aip.time(~NaNs), aip.w_G_1um(~NaNs), aip.time(NaNs),'linear');
ax3(1) = subplot(2,1,1); semilogy(aip.time(NaNs)-min(aip.time), aip.Bsp_G_Dry_1um(NaNs).*(1./ssa -1), 'k.', ...
aip.time - min(aip.time), [aip.Bap_G_1um, aip.Bsp_G_Dry_1um],'.');
ax3(2) = subplot(2,1,2); plot(aip.time - min(aip.time), [aip.w_G_1um],'b.',aip.time(NaNs)-min(aip.time), ssa, 'r.');
linkaxes(ax3,'x')

%%

field = fieldnames(aos_mon);
f = 4;
%%
if (f>length(field))
   f = 4;
else
   f = f+1;
end
if isfield(aos_um,[field{f},'_1um'])
% for f = 4:length(field);
   plot(serial2doy(aos_mon.time), aos_mon.(field{f}),'x', ...
      serial2doy(aos_1min.time), aos_1min.(field{f}),'o', ...
   serial2doy(aos_um.time), aos_um.([field{f},'_1um']),'r.', ...      
      serial2doy(aos_um.time), aos_um.([field{f},'_10um']),'g.' ...
   );
   xlabel('time (day of year)');
   
% end
else
      plot(serial2doy(aos_mon.time), aos_mon.(field{f}),'x', ...
      serial2doy(aos_1min.time), aos_1min.(field{f}),'o')
end
title([datestr(aos_mon.time(1), 'mmm'), ': ',field{f}],'interpreter','none')
%%

linkaxes(ax,'x')
%%
figure;
x = x+1;
ax(x) = subplot(3,1,1);  
plot(aos.time - min(aos.time), aos.subfrac_Ba_B,'.');
title('screening submicron fractions')
x = x+1;
ax(x) = subplot(3,1,2); 
plot(aos.time - min(aos.time), [aos.Bap_B_3W_1um] ,'b.',...
   aos.time - min(aos.time), [aos.Bap_B_3W_10um] ,'g.');
x = x+1
ax(x) = subplot(3,1,3); 
plot(aos.time - min(aos.time), [aos.Bsp_B_Dry_1um] ,'b.',...
  aos.time - min(aos.time), [aos.Bsp_B_Dry_10um] ,'g.' );

linkaxes(ax,'x')
%%
figure;
y = y+1;
ay(y) = subplot(3,1,1);  
plot(aos.time - min(aos.time), [aos.w_B_1um],'b.',...
  aos.time - min(aos.time), [aos.w_B_10um],'g.' );
title('screening ssa')
y = y+1;
ay(y) = subplot(3,1,2); 
plot(aos.time - min(aos.time), [aos.Bap_B_3W_1um] ,'b.',...
   aos.time - min(aos.time), [aos.Bsp_B_Dry_1um] ,'bx');
y = y+1
ay(y) = subplot(3,1,3); 
plot(aos.time - min(aos.time), [aos.Bap_B_3W_10um] ,'g.',...
  aos.time - min(aos.time), [aos.Bsp_B_Dry_10um] ,'gx' );

linkaxes(ay,'x')