function psap_b1 = more_psap_fun(psap_b1)
if ~exist('psap_b1','var')
   psap_b1 = anc_bundle_files;
end
bad_filter = false(size(psap_b1.time));
normd = NaN(size(psap_b1.time));
psap_b1.vdata.transmittance_blue = normd;

filter_changing = (psap_b1.vdata.tr_blue > 9.8 & psap_b1.vdata.tr_blue < 10.1) | ...
   (psap_b1.vdata.tr_green > 9.8 & psap_b1.vdata.tr_green < 10.1) | ...
   (psap_b1.vdata.tr_red > 9.8 & psap_b1.vdata.tr_red < 10.1);

bad_flow= psap_b1.vdata.sample_flow_rate< .8 | psap_b1.vdata.sample_flow_rate > 2;

std_flow = stdwin(psap_b1.vdata.sample_flow_rate,150);

std_tr = NaN(size(std_flow));
std_tr(~filter_changing) = stdwin(psap_b1.vdata.tr_blue(~filter_changing)./psap_b1.vdata.transmittance_blue_raw(~filter_changing),150);
std_tr(filter_changing) = interp1(psap_b1.time(~filter_changing), std_tr(~filter_changing),psap_b1.time(filter_changing), 'nearest');

stable_tr = std_tr < 1e-3;
stable_flow = std_flow < 1e-2;

pop = filter_changing |  bad_flow | ~stable_flow | ~stable_tr;

ipop = find(pop);
ii = ipop(1); jj = ipop(end);
% Some of these indications are erratic.  
% Try to remove isolated spikes and merge erratic intervals to create
% relatively fewer but more uniform likely periods to investigate/process
% If their are other points within full-width "window" after the current
% value that don't pass tests, then n

pops = length(pop);
window = 150;
while ii < jj && ii < (pops-window)
   while ~pop(ii)&&ii<pops-window
      ii = ii + 1;
   end
   if pop(ii) && ~any(pop(ii+2:ii+window))
      pop(ii) = false; %remove isolated spikes
      ii = ii + 1;
   end
   if pop(ii) && ~any(pop(ii+2:ii+window))
      pop(ii) = false; %remove isolated double spikes
      ii = ii + 1;
   end
   while any(pop(ii:ii+window))&& ii< pops-window
      pop(ii) = true;
      ii = ii + 1;
   end
end
bad_tr = pop;
figure(1);
xx(1) = subplot(4,1,1);
semilogy(serial2doys(psap_b1.time), std_flow,'k-x', ...
   serial2doys(psap_b1.time), std_tr,'c-o',...
   serial2doys(psap_b1.time(~stable_flow)), std_flow(~stable_flow),'rx', ...
   serial2doys(psap_b1.time(~stable_tr)), std_tr(~stable_tr),'ro');
legend('std flow > 1e-2', 'std tr > 1e-3')
xx(2) = subplot(4,1,2);
plot(serial2doys(psap_b1.time), psap_b1.vdata.filter_unstable, 'k-',...
   serial2doys(psap_b1.time(pop)), pop(pop),'r*');legend('unstable','pop');
xx(3) = subplot(4,1,3); plot(serial2doys(psap_b1.time), psap_b1.vdata.sample_flow_rate,'o');
legend('flow rate < 0.8');
xx(4)= subplot(4,1,4); plot(serial2doys(psap_b1.time), psap_b1.vdata.tr_blue,'bx');
plot(serial2doys(psap_b1.time), psap_b1.vdata.transmittance_blue_raw.*normd,'ko',...
   serial2doys(psap_b1.time), psap_b1.vdata.transmittance_blue_raw, 'c.',...
   serial2doys(psap_b1.time), psap_b1.vdata.tr_blue,'r.');legend('derived','raw','panel')

linkaxes(xx,'x');

% So now we should have block of reasonably contiguous intervals that might
% consitute filter changes due to any of the above conditions.
% Next, we try to find stable values within an hour after each change
% and normalize the raw filter to match the front panel.

% Question: can we identify when the user pressed reset without changing
% the filter?  This would be an event where front panel tr went to unit
% without a corresponding flow disturbance and/or 9.9 values.

change_start = pop;
changes = [find(~change_start(1:end-1)&change_start(2:end))',find(change_start(1:end-1)&~change_start(2:end))'];

for x = 1:(size(changes,1)-1)
   changed = changes(x,2)+1; % counter after conditions are stable.  Look for front_panel reset within an hour. 
   no_reset = false;
   while changed<changes(x+1,1) && ( psap_b1.vdata.tr_blue(changed)<0.9|| psap_b1.vdata.tr_blue(changed)>1.1) 
      changed = changed +1;
   end
   time_before = psap_b1.time >= (psap_b1.time(changes(x,1))-5./(24*60)) & psap_b1.time< psap_b1.time(changes(x,1));
   normed_before = mean(normd(time_before));
   tr_raw_before = psap_b1.vdata.transmittance_blue_raw(time_before);
   good_iq = IQ(tr_raw_before); % check IQ and inner for robustness, consider merge
   tr_raw_before = mean(tr_raw_before(good_iq));
   time_after = psap_b1.time >= psap_b1.time(changed) & psap_b1.time< (psap_b1.time(changed) + 5./(25*60));
   tr_raw_after = psap_b1.vdata.transmittance_blue_raw(time_after);
   good_iq = IQ(tr_raw_after); 
   tr_raw_after = mean(tr_raw_after(good_iq));
   rel_diff_raw_tr = (tr_raw_after -tr_raw_before)/tr_raw_after;
   tr_stable = all(stable_tr(changes(x,1):changed)); % transmittance ratio stable over interval, filter NOT changed
   if (rel_diff_raw_tr < 0.05)||tr_stable
      filter_change = false; % we should continue using previous normalization
   else
      filter_change = true; % we need to compute a new normalization
   end
   
   if changed == changes(x+1,1)
      disp('Probably the front-panel was not reset.')
      no_reset = true; % do not normalize to the front panel
   end
   
   if ~filter_change
      % use existing filter normalization
      normd([(changes(x,2)+1):(changes(x+1,1)-1)]) = normed_before;
      if (tr_raw_after-tr_raw_before)>0.02
         bad_tr(changes(x,2)+1:changes(x+1,1)-1) = true;
      end
   else
      if no_reset
         % use tr_raw_after for normalization
         normd([(changes(x,2)+1):(changes(x+1,1)-1)]) = 1./tr_raw_after;
      else
         % use stable, good values from within an hour "changed"
         hour = psap_b1.time>=psap_b1.time(changed) & psap_b1.time<(psap_b1.time(changed)+1./24);
         hour = hour & (psap_b1.vdata.tr_blue < psap_b1.vdata.tr_blue(changed));
         hour = hour & (psap_b1.vdata.tr_blue > (psap_b1.vdata.tr_blue(changed)-.1));
         hour = hour & (psap_b1.vdata.sample_flow_rate > .9) & (psap_b1.vdata.sample_flow_rate < 1.05);
         hour = hour & (std_tr < 1e-3)& (std_flow < 1e-2);
         hour = hour & psap_b1.vdata.transmittance_blue_raw>0 & psap_b1.vdata.transmittance_blue_raw< 10;
         tr_rat = psap_b1.vdata.tr_blue(hour)./psap_b1.vdata.transmittance_blue_raw(hour);
         if ~isempty(tr_rat)
            good = IQ(tr_rat,.1); mean_tr_rat = mean(tr_rat(good));
            normd([(changes(x,2)+1):(changes(x+1,1)-1)]) = mean_tr_rat;
         else
            disp('Empty transmittance ratio?')
         end
      end
   end
   
   span = [changes(x,2)+1:changes(x+1,1)-1];
  
  psap_b1.vdata.transmittance_blue(span) = psap_b1.vdata.transmittance_blue_raw(span).*normd(span);
   
   good = psap_b1.vdata.transmittance_blue_raw>0 & psap_b1.vdata.transmittance_blue_raw< 9;
good = good & psap_b1.vdata.tr_blue>0 & psap_b1.vdata.tr_blue< 9;
good = good & psap_b1.vdata.sample_flow_rate > .5 & psap_b1.vdata.sample_flow_rate < 2;
good = good & psap_b1.vdata.dilution_correction_factor >.5 & psap_b1.vdata.dilution_correction_factor < 5;
good = good & normd > 0 & (std_tr < 1e-3);
good = good & (std_flow < 1e-2);


figure(9); s(1) = subplot(3,1,1);
plot(serial2doys(psap_b1.time(good)), psap_b1.vdata.transmittance_blue(good),'ko',...
   serial2doys(psap_b1.time), psap_b1.vdata.transmittance_blue_raw, 'c.',...
   serial2doys(psap_b1.time), psap_b1.vdata.tr_blue,'r.',...
   serial2doys(psap_b1.time(bad_tr)), psap_b1.vdata.transmittance_blue(bad_tr),'rx');
legend('derived','raw','panel');
ylim([0,2]);
s(2) = subplot(3,1,2); plot(serial2doys(psap_b1.time), normd,'k.'); legend('factor');
s(3) = subplot(3,1,3);
plot(serial2doys(psap_b1.time(good)), psap_b1.vdata.tr_blue(good)- psap_b1.vdata.transmittance_blue(good),'ko');
legend('differnce');
linkaxes([xx,s],'x');
min_x = max([1 x-1]);max_x = max([3,x+1]);
xlim([serial2doys(psap_b1.time(changes(min_x,1))),serial2doys(psap_b1.time(changes(max_x,1)))]);
disp(['Event #',num2str(x),'.  Filter ',...
   strrep(strrep(num2str(filter_change),'0','NOT '),'1',''),'changed. ',...
   ' RESET ',strrep(strrep(num2str(~no_reset),'0','NOT '),'1',''),'pressed']);
end



return