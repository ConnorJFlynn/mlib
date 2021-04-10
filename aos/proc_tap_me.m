function [me_trim, me] = proc_tap_me(me)
if ~isavar('me')
  me = rd_tap_bmi_raw_nolf;
end
% Processes TAP after compacting to "tight" me struct
me.clean_blue = NaN(size(me.signal_blue)); me.clean_green = me.clean_blue; me.clean_red = me.clean_blue;

% Find records when filter or active spot changes.
spot = [1:10];
active = me.spot_active;
first_good = find(active>0,1,'first');
first_good_spot = active(first_good);
% find changes when active spot is greater than 0 AND when active spot
% advances, or active spot goes from 8 to 1 or filter ID changes
changes = find((active(2:end)>0) & ...
    (active(2:end)>active(1:end-1) | (active(2:end)==1 & active(1:end-1)==8) | ...
    me.filter_id(2:end)~=me.filter_id(1:end-1) )  )+1;
% Extend bounds of loop to extend to end of file
% had to modify 
if size(changes,1)>1
   changes = changes';
end
bounds = unique([changes, length(me.time)]);

if exist('old','var')
   
   % find the last filter_id for a valid active_spot from previous file
   old_ii = find(old.spot_active>0, 1,'last');
   filter_id_old = old.filter_id(old_ii);
   active_spot_old = old.spot_active(old_ii);
   % If the filter and active spot haven't changed, carry old "clean" values forward
   if me.filter_id(first_good)==filter_id_old && first_good_spot==active_spot_old
      clean_blue_old = old.clean_blue(:,old_ii);
      clean_green_old = old.clean_green(:,old_ii);
      clean_red_old = old.clean_red(:,old_ii);
      me.clean_blue(spot>=active_spot_old,(1:bounds(1)-1)) = clean_blue_old(spot>=active_spot_old)*ones([1,length([1:(bounds(1)-1)])]);
      me.clean_green(spot>=active_spot_old,(1:bounds(1)-1)) = clean_green_old(spot>=active_spot_old)*ones([1,length([1:(bounds(1)-1)])]);
      me.clean_red(spot>=active_spot_old,(1:bounds(1)-1)) = clean_red_old(spot>=active_spot_old)*ones([1,length([1:(bounds(1)-1)])]);
   end
   
else  % treat as a new filter, new spot by default
        me.clean_blue = me.signal_blue(:,1)*ones([1,length(me.time)]);
        me.clean_green = me.signal_green(:,1)*ones([1,length(me.time)]);
        me.clean_red = me.signal_red(:,1)*ones([1,length(me.time)]);
end
% first_good_spot = active(changes(1));
% Have verified that the bounds are good by walking through and examining
% indices.
wrapped = false;
for t = 1:length(bounds)-1
    {datestr(me.time(bounds(t)-1)), me.filter_id(bounds(t)-1), me.spot_active(bounds(t)-1);...
        datestr(me.time(bounds(t))), me.filter_id(bounds(t)), me.spot_active(bounds(t));...
        datestr(me.time(bounds(t)+1)), me.filter_id(bounds(t)+1), me.spot_active(bounds(t)+1)};
    active = me.spot_active(bounds(t));

    % If the spot goes backwards for the same filter and the last change
    % was > 30 minutes ago, then the filter is probably exhausted and we're
    % just wrapping around with an old filter. Else, it probably just did a
    % white filter test or cycled to seat spots in a clean filter
    if me.spot_active(bounds(t))< me.spot_active(bounds(t)-1) &&...
            me.filter_id(bounds(t)-1) == me.filter_id(bounds(t)) && ...
            t>1 && dtime(datevec(me.time(bounds(t))),datevec(me.time(bounds(t-1))))>30*60
        wrapped = true;
    end
    % Reset wrapped to false when the filter Id changes again
    if me.filter_id(bounds(t)-1) ~= me.filter_id(bounds(t))
        wrapped = false;
    end        

    if ~wrapped
        me.clean_blue(spot>=active,(bounds(t)):bounds(end)) = me.signal_blue(spot>=active, bounds(t))*ones([1,length([(bounds(t)):bounds(end)])]);
        me.clean_green(spot>=active,(bounds(t)):bounds(end)) = me.signal_green(spot>=active, bounds(t))*ones([1,length([(bounds(t)):bounds(end)])]);
        me.clean_red(spot>=active,(bounds(t)):bounds(end)) = me.signal_red(spot>=active, bounds(t))*ones([1,length([(bounds(t)):bounds(end)])]);
    end
end
me.norm_blue = me.signal_blue ./ me.clean_blue;
me.norm_green = me.signal_green ./ me.clean_green;
me.norm_red = me.signal_red ./ me.clean_red;

me.spot_tr_blue = NaN(size(me.norm_blue));  me.spot_tr_green = me.spot_tr_blue;  me.spot_tr_red = me.spot_tr_blue;
me.transmittance_blue = NaN(size(me.time)); me.transmittance_green = me.transmittance_blue; me.transmittance_red = me.transmittance_blue;

%extend bounds to include beginning of file (but normalizations will only
%be defined above after the first spot change)
bounds = [1 bounds];
for t = 1:length(bounds)-1
    active = me.spot_active(bounds(t));
    clean = spot>active & spot<9; % clean spots greater than active spot
    dirty = spot<active; % dirty spots less than active spot number

    ref = 10-mod(active,2);  % Yield reference spot = 10 when active spot is even, ref = 9 when odd.
    nonref = 9 + mod(active,2); % yields non-reference spot = 9 when active is even, 10 when odd
    
    % leave non-reference spot with no flow unchanged
    me.spot_tr_blue(nonref,bounds(t):bounds(end)) = me.norm_blue(nonref,bounds(t):bounds(end));
    me.spot_tr_green(nonref,bounds(t):bounds(end)) = me.norm_green(nonref,bounds(t):bounds(end));
    me.spot_tr_red(nonref,bounds(t):bounds(end)) = me.norm_red(nonref,bounds(t):bounds(end));
    
    % normalize reference spot relative to non-reference spot with no flow
    % this should normalize out changes in the LED intensity but will leave
    % effects due to flow including filter flexure, RH effects on the filter.
    me.spot_tr_blue(ref,bounds(t):bounds(end)) = ...
        me.norm_blue(ref,bounds(t):bounds(end)) ./ me.norm_blue(nonref,bounds(t):bounds(end));
    me.spot_tr_green(ref,bounds(t):bounds(end)) = ...
        me.norm_green(ref,bounds(t):bounds(end)) ./ me.norm_green(nonref,bounds(t):bounds(end));
    me.spot_tr_red(ref,bounds(t):bounds(end)) = ...
        me.norm_red(ref,bounds(t):bounds(end)) ./ me.norm_red(nonref,bounds(t):bounds(end));
    
    if active>0 % Only compute transmittances if active spot > 0
        % normalize active spot by reference 
        % This should normalize out LED changes, filter flexure, and RH effects 
        % on the filter, but not RH effects on deposited material, sample
        % evaporation, or filter leaks
        me.spot_tr_blue(active,bounds(t):bounds(end)) = ...
            me.norm_blue(active,bounds(t):bounds(end)) ./ me.norm_blue(ref,bounds(t):bounds(end));
        me.spot_tr_green(active,bounds(t):bounds(end)) = ...
            me.norm_green(active,bounds(t):bounds(end)) ./ me.norm_green(ref,bounds(t):bounds(end));
        me.spot_tr_red(active,bounds(t):bounds(end)) = ...
            me.norm_red(active,bounds(t):bounds(end)) ./ me.norm_red(ref,bounds(t):bounds(end));
        
        % Capture transmittances from active spot into 1-D fields
        me.transmittance_blue(bounds(t):bounds(end)) = me.spot_tr_blue(active,bounds(t):bounds(end));
        me.transmittance_green(bounds(t):bounds(end)) = me.spot_tr_green(active,bounds(t):bounds(end));
        me.transmittance_red(bounds(t):bounds(end)) = me.spot_tr_red(active,bounds(t):bounds(end));
        
        % normalize "clean" spots by non-reference spot with no flow
        % This should normalize out LED changes, filter flexure, and RH effects
        % on the filter, but not filter leaks
        me.spot_tr_blue(clean,bounds(t):bounds(end)) = ...
            me.norm_blue(clean,bounds(t):bounds(end)) ./ (ones([sum(clean),1])*me.norm_blue(nonref,bounds(t):bounds(end)));
        me.spot_tr_green(clean,bounds(t):bounds(end)) = ...
            me.norm_green(clean,bounds(t):bounds(end)) ./ (ones([sum(clean),1])*me.norm_green(nonref,bounds(t):bounds(end)));
        me.spot_tr_red(clean,bounds(t):bounds(end)) = ...
            me.norm_red(clean,bounds(t):bounds(end)) ./ (ones([sum(clean),1])*me.norm_red(nonref,bounds(t):bounds(end)));
        
        % normalize "dirty" spots by non-reference spot with no flow
        % This should normalize out LED changes, filter flexure, and RH effects
        % on the filter, but not RH effects on deposited material, volatilization
        % of depostied material, slow wicking effects, or filter leaks

        me.spot_tr_blue(dirty,bounds(t):bounds(end)) = ...
            me.norm_blue(dirty,bounds(t):bounds(end)) ./ (ones([sum(dirty),1])*me.norm_blue(nonref,bounds(t):bounds(end)));
        me.spot_tr_green(dirty,bounds(t):bounds(end)) = ...
            me.norm_green(dirty,bounds(t):bounds(end)) ./ (ones([sum(dirty),1])*me.norm_green(nonref,bounds(t):bounds(end)));
        me.spot_tr_red(dirty,bounds(t):bounds(end)) = ...
            me.norm_red(dirty,bounds(t):bounds(end)) ./ (ones([sum(dirty),1])*me.norm_red(nonref,bounds(t):bounds(end)));               
    end
end

me.transmittance_blue(me.spot_active==0) = NaN;
me.transmittance_green(me.spot_active==0) = NaN;
me.transmittance_red(me.spot_active==0) = NaN;


figure; these = plot((me.time), me.spot_active,'o'); ax(1) = gca; dynamicDateTicks
title('active spot');
figure; plot(me.time, me.flow_lpm, 'x-'); title('tap flow rate'); ax(end+1) = gca; dynamicDateTicks;

sp = 0;
figure;
sp = sp +1;
 plot(me.time, me.signal_blue(sp,:),'b-',me.time, me.signal_green(sp,:),'g.',me.time, me.signal_red(sp,:),'r.');
title(['Spot: ',num2str(sp)])
dynamicDateTicks
hold('on');
figure; these = plot((me.time), me.signal_red, '-'); title('red signal'); ax(end+1) = gca;
dynamicDateTicks
legend('1','2','3','4','5','6','7','8','9','10'); recolor(these,[1:10]);

figure; these = plot((me.time), me.norm_green, '-'); title('green normalized to spot change'); ax(end+1) = gca;
dynamicDateTicks
legend('1','2','3','4','5','6','7','8','9','10');recolor(these,[1:10]);

figure; these = plot((me.time), me.spot_tr_green, '-'); title('green spot Tr'); ax(end+1) = gca;
dynamicDateTicks
legend('1','2','3','4','5','6','7','8','9','10'); recolor(these,[1:10]);

figure; plot((me.time), me.transmittance_blue, '-',...
    (me.time), me.transmittance_green, '-',...
    (me.time), me.transmittance_red, '-'); title('transmittances'); 
ax(end+1) = gca;
dynamicDateTicks
% figure; plot(serial2hs(me.time), me.norm_green, '-'); title('green normalized to spot change'); ax(3) = gca;
% figure; plot(serial2hs(me.time), me.norm_red, '-'); title('red normalized to spot change'); ax(4) = gca;
linkaxes(ax,'x');

me_trim = me;
flds = fieldnames(me_trim); remv = {};
for fld = length(flds):-1:1
   field = flds{fld};
   if ~all(size(me_trim.(field))==size(me_trim.time))
      remv = [remv,{field}];
   end
end
me_trim = rmfield(me_trim,remv);

return