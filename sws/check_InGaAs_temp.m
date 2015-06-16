% Check SWS aux files
%%
sws_aux = ancload(getfullname('*.cdf','swsaux'));
%
% plot_qcs(sws_aux)
[pname, fname, ext] = fileparts(sws_aux.fname);
if exist('sws_temp','var')
   clear sws_temp
end
files = dir([pname,filesep, '*.cdf']);
for f = 1:length(files)
   disp(['loading ',files(f).name,', file #,',num2str(f),' of ',num2str(length(files))])
   sws_aux = ancload([pname,filesep, files(f).name]);
   sws_aux.vars = rmfield(sws_aux.vars,'SI_spect_temp');
   sws_aux.vars = rmfield(sws_aux.vars,'qc_SI_spect_temp');
   sws_aux.vars = rmfield(sws_aux.vars,'pc104_5v');
   sws_aux.vars = rmfield(sws_aux.vars,'qc_pc104_5v');
   sws_aux.vars = rmfield(sws_aux.vars,'pc104_neg12v');
   sws_aux.vars = rmfield(sws_aux.vars,'qc_pc104_neg12v');
   sws_aux.vars = rmfield(sws_aux.vars,'pc104_pos12v');
   sws_aux.vars = rmfield(sws_aux.vars,'qc_pc104_pos12v');
   sws_aux.vars = rmfield(sws_aux.vars,'ps2_12v');
   sws_aux.vars = rmfield(sws_aux.vars,'qc_ps2_12v');
%    sws_aux.vars = rmfield(sws_aux.vars,'ps2_5v');
%    sws_aux.vars = rmfield(sws_aux.vars,'qc_ps2_5v');
   if ~exist('sws_temp','var')
      sws_temp = sws_aux;
   else
      sws_temp = anccat(sws_aux, sws_temp);
   end
   

end
%%
figure(1)
plot((sws_temp.time)-sws_temp.time(1)+serial2doy(sws_temp.time(1)), sws_temp.vars.InGaAs_spect_temp.data,'.-');
   ax(1) = gca;
   title('tracking InGaAs spectrometer temperature');
xlabel('day of year');
ylabel('degrees C');
zoom('on');
%

figure(2)
ax(2) = subplot(2,1,1);
plot(sws_temp.time-sws_temp.time(1)+serial2doy(sws_temp.time(1)), sws_temp.vars.internal_temp.data,'.-');
   
   title('SWS internal temperature');
xlabel('day of year');
ylabel('degrees C');
zoom('on');

ax(3) = subplot(2,1,2);
plot(sws_temp.time-sws_temp.time(1)+serial2doy(sws_temp.time(1)), sws_temp.vars.ps2_5v.data,'.-');
%    ax(3) = gca;
   title('PS2 5V');
xlabel('day of year');
ylabel('volts');
zoom('on');
linkaxes(ax,'x')

disp('done')