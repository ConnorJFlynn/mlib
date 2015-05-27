function mono = rh_compare(indir)
if ~exist('indir','var')
   indir = getdir;
end
ridni = fliplr(indir);
pmt = fliplr(strtok(ridni(2:end),filesep));

%% SAS temp tests
% Reading Albert's data files from 20100211prelimThermoEval
% No background counts for the moment.  
%    %
   pname = indir;
   %%
   trh_files = dir([pname,'*.csv']);
   for m = length(trh_files):-1:1
      disp(trh_files(m).name)
      if isempty(findstr(trh_files(m).name(end-6),'_'))
         trh_files(m) = [];
      end
   end
   trh_all = [];
    for m = 1:length(trh_files)
       disp(['Loading ',trh_files(m).name,': ',num2str(m), ' of ',num2str(length(trh_files))]);
%       time_str = (trh_files(m).name(1:end-4));
%       V(1) = sscanf(time_str(1:4),'%d');
%       V(2) = sscanf(time_str(5:6),'%d');
%       V(3) = sscanf(time_str(7:8),'%d');
%       V(4) = sscanf(time_str(10:11),'%d');
%       V(5) = sscanf(time_str(13:14),'%d');
%       V(6) = sscanf(time_str(16:17),'%d');
%       back.time(m) = datenum(V);
     trh = load([pname,trh_files(m).name]);
     trh(:,end+1)=datenum(trh(:,1:6));
     [in_times,inds] = unique(trh(:,end),'first');
     trh(:,end) = interp1(inds,in_times, [1:length(trh(:,1))],'linear','extrap');
     trh_all = [trh_all;trh];

   end   
   %%
% For the NIDAQ T-RH data, the fields are  YY,MM,DD,HH,MM,SS   
% (year month day hour minute second), temp 1 (freezer), RH 1, Temp2 (room), RH 2, supply voltage
% The data is in raw values, volts from NIDAQ.
[trh.time,inds] = sort(trh_all(:,end));
trh.V_T_freezer_precon = trh_all(inds,7);
trh.V_rh_freezer_precon = trh_all(inds,8);
trh.V_T_room_humirel = trh_all(inds,9);
trh.V_rh_room_humirel = trh_all(inds,10);
trh.V_cc = trh_all(inds,11);

[trh.rh_freezer, trh.T_freezer] = precon_trh(trh.V_rh_freezer_precon,trh.V_T_freezer_precon,trh.V_cc);
[trh.rh_room, trh.T_room] = humirel_trh(trh.V_rh_room_humirel,trh.V_T_room_humirel,trh.V_cc);


%% 
 figure; 
 plot(serial2Hh(trh.time), [trh.V_T_freezer_precon, trh.V_rh_freezer_precon,trh.V_cc],'o');
 xlabel('time [Hh]');
 ylabel('voltages');
 lg = legend('T','RH','V_cc');set(lg,'interp','none')
 title('time series of voltages from Precon T/RH sensor')
 zoom('on');
%% 
 figure; 
 plot(serial2Hh(trh.time), [trh.V_T_room_humirel, trh.V_rh_room_humirel,trh.V_cc],'o');
 xlabel('time [Hh]');
 ylabel('voltages');
 lg = legend('T','RH','V_cc');set(lg,'interp','none')
 title('time series of voltages from Humirel T/RH sensor')
 zoom('on');
 %% 
 figure; 
 lines2 = plot(mono.nm_nir, mono.spec_nir,'-');
 recolor(lines2,mono.nir_deg_C,[1,5]); colorbar;
 xlabel('wavelength [nm]');
 title('NIR detector temperature response');
 zoom('on');
% axis('xy'); caxis([-5,0]); colorbar
% title(pmt, 'interp','none');
% ylabel('scan nm')
% xlabel('pixel')
%%
figure;
plot(60.*serial2Hh(mono.time), [mono.vis_deg_C; mono.nir_deg_C],'o-');
legend('vis','nir')
xlabel('time [minutes]');
ylabel('deg C')


return
     