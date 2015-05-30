function tmp = dmp;
%%

in_dir = 'C:\case_studies\fkb\fkbqcrad1longM1.c1\';
files = dir([in_dir,'*.cdf']);
close('all')
fig1 = figure;
fig2 = figure;
fig3 = figure;

done = false;
f = 0;
ff = 1;
pos = [];
while ~done

   while sum(pos)<2
   f  = f + ff;
   if f > length(files)
      f = 1;
   elseif f < 1
      f = length(files);
   end   
   disp(['Reading ',files(f).name]);
   qcrad = ancload([in_dir, files(f).name]);
[zen, az, soldst, ha, dec, el, am] = sunae(qcrad.vars.lat.data, qcrad.vars.lon.data, qcrad.time); 
   pos = qcrad.vars.MFRSR_direct_normal_broadband.data>0 & qcrad.vars.short_direct_normal.data>0 & el>17.5;
   csza = cos(pi.*(qcrad.vars.zenith.data./180));
   if sum(pos)<2
      disp(['Only ',num2str(sum(pos)),' remaining data points.']);
   else
   end
   figure(fig1);
   units = ['[',char(qcrad.vars.short_direct_normal.atts.units.data(1:end-1)),']'];
   sb(1) = subplot(2,1,1);
   plot(serial2Hh(qcrad.time(pos)), qcrad.vars.MFRSR_direct_normal_broadband.data(pos),'r-',...
      serial2Hh(qcrad.time(pos)),qcrad.vars.short_direct_normal.data(pos),'b-');
      title(['Plot for ',datestr(qcrad.time(1))]);
      ylabel(['short direct normal ',units]);
      legend('mfr','nip','location','South')
   
   sb(2) = subplot(2,1,2);
   plot(serial2Hh(qcrad.time(pos)), qcrad.vars.MFRSR_direct_normal_broadband.data(pos) - qcrad.vars.short_direct_normal.data(pos),'ko');
   ylim([-50,50])

   xlabel('time (UTC)');
   ylabel(['MFRSR BB - NIP ', units]);
   zoom('on')
   linkaxes(sb,'x');
%%
   figure(fig2); 
   %%
   
   sb1(1) = subplot(3,1,1);
   plot(csza(pos), csza(pos).*qcrad.vars.MFRSR_direct_normal_broadband.data(pos),'r-',...
      csza(pos), csza(pos).*qcrad.vars.short_direct_normal.data(pos),'b-');
%    xlabel('csza')
   ylabel(['csza * short direct normal ',units]);
      title(['Plot for ',datestr(qcrad.time(1))]);
      legend('mfr','nip','location','SouthEast');
   sb1(2) =subplot(3,1,2);
   plot(csza(pos), csza(pos).*(qcrad.vars.MFRSR_direct_normal_broadband.data(pos)-qcrad.vars.short_direct_normal.data(pos)),'k-');
%    xlabel('csza')
   ylabel(['csza * (MFRSR-NIP) direct normal ',units]);
      title(['Plot for ',datestr(qcrad.time(1))]);
      legend('mfr','nip','location','SouthEast');
   sb1(3) =subplot(3,1,3);
   plot(csza(pos), csza(pos).*((qcrad.vars.MFRSR_direct_normal_broadband.data(pos)-qcrad.vars.short_direct_normal.data(pos))./qcrad.vars.short_direct_normal.data(pos)),'r-');
   xlabel('csza')
   ylabel(['csza * (MFRSR./NIP) direct normal ',units]);
linkaxes(sb1,'x');      
      
      figure(fig3);
      
sb2(1) = subplot(3,1,1);
   plot(1./csza(pos), qcrad.vars.MFRSR_direct_normal_broadband.data(pos),'r-',...
      1./csza(pos), qcrad.vars.short_direct_normal.data(pos),'b-');
%    xlabel('airmass')
   ylabel(['shortwave direct normal ', units]);
sb2(2) =  subplot(3,1,2);
   plot(1./csza(pos), qcrad.vars.MFRSR_direct_normal_broadband.data(pos)- ...
      qcrad.vars.short_direct_normal.data(pos),'k-');
%    xlabel('airmass')
   ylabel(['(MFRSR-NIP) shortwave direct normal ', units]);
sb2(3) = subplot(3,1,3);
   plot(1./csza(pos), qcrad.vars.MFRSR_direct_normal_broadband.data(pos) ./ ...
      qcrad.vars.short_direct_normal.data(pos),'r-');
   xlabel('airmass')
   ylabel(['(MFRSR./NIP)shortwave direct normal ', units]);
linkaxes(sb2,'x');
   zoom('on')
   
   %%
   end
k = menu('Select desired option','Next file','Previous file', 'Exit');
if k ==1
ff = 1;
elseif k ==2
ff = -1;
elseif k==3
   done = true;
end
pos = [];
end
return
%%
function blah;
%%
[zen, az, soldst, ha, dec, el, am] = sunae(qcrad.vars.lat.data, qcrad.vars.lon.data, qcrad.time);
figure; 
plot(serial2Hh(qcrad.time), zen-qcrad.vars.zenith.data, '.')

%%
csza = cos(pi.*(qcrad.vars.zenith.data./180));
   scatter(csza(pos), qcrad.vars.short_direct_normal.data(pos),16,serial2Hh(qcrad.time(pos)));
hold('on')
   scatter(csza(pos), qcrad.vars.MFRSR_direct_normal_broadband.data(pos),64,serial2Hh(qcrad.time(pos)));
   colorbar;
   
 %%
 return