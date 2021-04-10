function me = proc_tap_a0_to_b1(tap_a0, me_old);
% tap = proc_tap_a0_to_b1(tap_a0, me_old);
% optional argument tap_a0 may be one or more filenames or an anc struct
% if not supplied, you'll be prompted to select file(s)
% optional argument "me_old" contains results from the previously processed file

if ~exist('tap_a0','var')||isempty(tap_a0)||(ischar(tap_a0)&&~exist(tap_a0,'file'))
    tap_a0 = getfullname('sgpaostap*','tap_a0');
    tap_a0 = anc_bundle_files(tap_a0);
elseif iscell(tap_a0)&&ischar(tap_a0{1})
    tap_a0 = anc_bundle_files(tap_a0);
elseif ~isstruct(tap_a0)||~isfield(tap_a0,'time')
    if isfield(tap_a0,'fname')&&exist(tap_a0.fname,'file')
        tap_a0 = anc_bundle_files(tap_a0.fname);
    else % abandon input value for tap_a0 and select a new file
        tap_a0 = getfullname('sgpaostap*','tap_a0');
        tap_a0 = anc_bundle_files(tap_a0);
    end
end
if ischar(tap_a0)&&exist(tap_a0,'file')
    tap_a0 = anc_load(tap_a0);
end
if ~isstruct(tap_a0)||~isfield(tap_a0,'time')||~isfield(tap_a0,'ncdef')...
        ||~isfield(tap_a0,'gatts')||~isfield(tap_a0,'vatts')||~isfield(tap_a0,'vdata')
    if isfield(tap_a0,'fname')&&exist(tap_a0.fname,'file')
        tap_a0 = anc_bundle_files(tap_a0.fname);
    else % abandon input value for tap_a0 and select a new file
        tap_a0 = getfullname('sgpaostap*','tap_a0');
        tap_a0 = anc_bundle_files(tap_a0);
    end
end

% Concentrating on March 28-29 because active spot is changeing but not too
% fast, and ref_0 and ref_9 values are reasonable values

% load a0 data into a compact N-dimensioned format
me.time = tap_a0.time;
me.filter_id = tap_a0.vdata.filter_id;
me.active_spot = tap_a0.vdata.active_spot_number;

ch_str = {'ch1','ch2','ch3','ch4','ch5','ch6','ch7','ch8','ref9','ref0'};
for ch = 1:length(ch_str)
    me.signal_dark_raw(ch,:) = tap_a0.vdata.([ch_str{ch}, '_dark']);
    me.signal_blue_raw(ch,:) = tap_a0.vdata.([ch_str{ch}, '_blue']);
    me.signal_green_raw(ch,:) = tap_a0.vdata.([ch_str{ch}, '_green']);
    me.signal_red_raw(ch,:) = tap_a0.vdata.([ch_str{ch}, '_red']);
end
me.signal_blue = me.signal_blue_raw - me.signal_dark_raw;
me.signal_green = me.signal_green_raw - me.signal_dark_raw;
me.signal_red = me.signal_red_raw - me.signal_dark_raw;

% Pre-assign "clean" fields that will store clean filter values used for
% normalization
me.clean_blue = NaN(size(me.signal_blue)); me.clean_green = me.clean_blue; me.clean_red = me.clean_blue;

% Find records when filter or active spot changes.
spot = [1:10];
active = tap_a0.vdata.active_spot_number;
first_good = find(active>0,1,'first');
first_good_spot = active(first_good);
% find changes when active spot is greater than 0 AND when active spot
% advances, or active spot goes from 8 to 1 or filter ID changes
changes = find((active(2:end)>0) & ...
    (active(2:end)>active(1:end-1) | (active(2:end)==1 & active(1:end-1)==8) | ...
    tap_a0.vdata.filter_id(2:end)~=tap_a0.vdata.filter_id(1:end-1) )  )+1;
% Extend bounds of loop to extend to end of file
bounds = unique([changes, length(tap_a0.time)]);

if exist('me_old','var')
    % find the last filter_id for a valid active_spot from previous file
    old_ii = find(me_old.active_spot>0, 1,'last');
    filter_id_old = me_old.filter_id(old_ii);
    active_spot_old = me_old.active_spot(old_ii);
    % If the filter and active spot haven't changed, carry old "clean" values forward
    if me.filter_id(first_good)==filter_id_old && first_good_spot==active_spot_old
        clean_blue_old = me_old.clean_blue(:,old_ii);
        clean_green_old = me_old.clean_green(:,old_ii);
        clean_red_old = me_old.clean_red(:,old_ii);
        me.clean_blue(spot>=active_spot_old,(1:bounds(1)-1)) = clean_blue_old(spot>=active_spot_old)*ones([1,length([1:(bounds(1)-1)])]);
        me.clean_green(spot>=active_spot_old,(1:bounds(1)-1)) = clean_green_old(spot>=active_spot_old)*ones([1,length([1:(bounds(1)-1)])]);
        me.clean_red(spot>=active_spot_old,(1:bounds(1)-1)) = clean_red_old(spot>=active_spot_old)*ones([1,length([1:(bounds(1)-1)])]);
    end
end
% first_good_spot = active(changes(1));
% Have verified that the bounds are good by walking through and examining
% indices.
wrapped = false;
for t = 1:length(bounds)-1
    {datestr(tap_a0.time(bounds(t)-1)), tap_a0.vdata.filter_id(bounds(t)-1), tap_a0.vdata.active_spot_number(bounds(t)-1);...
        datestr(tap_a0.time(bounds(t))), tap_a0.vdata.filter_id(bounds(t)), tap_a0.vdata.active_spot_number(bounds(t));...
        datestr(tap_a0.time(bounds(t)+1)), tap_a0.vdata.filter_id(bounds(t)+1), tap_a0.vdata.active_spot_number(bounds(t)+1)}
    active = tap_a0.vdata.active_spot_number(bounds(t));

    % If the spot goes backwards for the same filter and the last change
    % was > 30 minutes ago, then the filter is probably exhausted and we're
    % just wrapping around with an old filter. Else, it probably just did a
    % white filter test or cycled to seat spots in a clean filter
    if tap_a0.vdata.active_spot_number(bounds(t))< tap_a0.vdata.active_spot_number(bounds(t)-1) &&...
            tap_a0.vdata.filter_id(bounds(t)-1) == tap_a0.vdata.filter_id(bounds(t)) && ...
            t>1 && dtime(datevec(tap_a0.time(bounds(t))),datevec(tap_a0.time(bounds(t-1))))>30*60
        wrapped = true;
    end
    % Reset wrapped to false when the filter Id changes again
    if tap_a0.vdata.filter_id(bounds(t)-1) ~= tap_a0.vdata.filter_id(bounds(t))
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
    active = tap_a0.vdata.active_spot_number(bounds(t));
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

me.transmittance_blue(me.active_spot==0) = NaN;
me.transmittance_green(me.active_spot==0) = NaN;
me.transmittance_red(me.active_spot==0) = NaN;


%

figure; these = plot((tap_a0.time), tap_a0.vdata.active_spot_number,'o'); ax(1) = gca; dynamicDateTicks
title('active spot');
figure; plot(tap_a0.time, tap_a0.vdata.tap_flow_rate, 'x-'); title('tap_flow_rate'); ax(end+1) = gca; dynamicDateTicks;

figure; these = plot((tap_a0.time), me.signal_green, '-'); title('green signal'); ax(end+1) = gca;
dynamicDateTicks
legend('1','2','3','4','5','6','7','8','9','10'); recolor(these,[1:10]);

figure; these = plot((tap_a0.time), me.norm_green, '-'); title('green normalized to spot change'); ax(end+1) = gca;
dynamicDateTicks
legend('1','2','3','4','5','6','7','8','9','10');recolor(these,[1:10]);

figure; these = plot((tap_a0.time), me.spot_tr_green, '-'); title('green spot Tr'); ax(end+1) = gca;
dynamicDateTicks
legend('1','2','3','4','5','6','7','8','9','10'); recolor(these,[1:10]);

figure; plot((tap_a0.time), me.transmittance_blue, '-',...
    (tap_a0.time), me.transmittance_green, '-',...
    (tap_a0.time), me.transmittance_red, '-'); title('transmittances'); 
ax(end+1) = gca;
dynamicDateTicks
% figure; plot(serial2hs(tap_a0.time), me.norm_green, '-'); title('green normalized to spot change'); ax(3) = gca;
% figure; plot(serial2hs(tap_a0.time), me.norm_red, '-'); title('red normalized to spot change'); ax(4) = gca;
linkaxes(ax,'x');

% for t = 1:length(changes)-1
%     active = tap_b1.vdata.active_spot_number(1+changes(t));
%     me.clean_blue(spot>=active,(1+changes(t)):changes(t+1)) = me.signal_blue(spot>=active, 1+changes(t))*ones([1,length([(1+changes(t)):changes(t+1)])]);
%     me.clean_green(spot>=active,(1+changes(t)):changes(t+1)) = me.signal_green(spot>=active, 1+changes(t))*ones([1,length([(1+changes(t)):changes(t+1)])]);
%     me.clean_red(spot>=active,(1+changes(t)):changes(t+1)) = me.signal_red(spot>=active, 1+changes(t))*ones([1,length([(1+changes(t)):changes(t+1)])]);
% end

%
% sp = 0;
% done = false; figure;
% while ~done && sp<10
% sp = sp +1;
%  s(1) = subplot(2,1,1);
% plot(serial2hs(tap_b1.time), tap_b1.vdata.signal_dark_raw(sp,:), 'r.', serial2hs(tap_b1.time), me.signal_dark_raw(sp,:), 'ko');
%  title(['Display dark raw spot ',num2str(sp)]);
% s(2) = subplot(2,1,2);
% plot(serial2hs(tap_b1.time), tap_b1.vdata.signal_dark_raw(sp,:)- me.signal_dark_raw(sp,:), 'rx')
% linkaxes(s,'x');
% ok = menu('done','no','yes');
% if ok == 2
%     done = true;
% end
% end
% % Non-zero 9,10, swapped
% figure;
% sp = 0;
% done = false;
% while ~done && sp<10
% sp = sp +1;
% s(1) = subplot(2,1,1);
% plot(serial2hs(tap_b1.time), tap_b1.vdata.signal_blue_raw(sp,:), 'r.', serial2hs(tap_b1.time), me.signal_blue_raw(sp,:), 'ko');
%  title(['Display blue raw spot ',num2str(sp)]);
% s(2) = subplot(2,1,2);
% plot(serial2hs(tap_b1.time), tap_b1.vdata.signal_blue_raw(sp,:)- me.signal_blue_raw(sp,:), 'rx')
% linkaxes(s,'x');
% ok = menu('done','no','yes');
% if ok == 2
%     done = true;
% end
% end
%
%
% sp = 0;
% done = false;
% while ~done && sp<10
% sp = sp +1;
% s(1) = subplot(2,1,1);
% plot(serial2hs(tap_b1.time), tap_b1.vdata.signal_red_raw(sp,:), 'r.', serial2hs(tap_b1.time), me.signal_red_raw(sp,:), 'ko');
%  title(['Display red raw spot ',num2str(sp)]);
% s(2) = subplot(2,1,2);
% plot(serial2hs(tap_b1.time), tap_b1.vdata.signal_red_raw(sp,:)- me.signal_red_raw(sp,:), 'rx')
% linkaxes(s,'x');
% ok = menu('done','no','yes');
% if ok == 2
%     done = true;
% end
% end
%
%
% sp = 0;
% figure;
% done = false;
% while ~done && sp<10
% sp = sp +1;
% s(1) = subplot(2,1,1);
% plot(serial2hs(tap_b1.time), tap_b1.vdata.signal_green_raw(sp,:), 'r.', serial2hs(tap_b1.time), me.signal_green_raw(sp,:), 'ko');
%  title(['Display raw green spot ',num2str(sp)]);
% s(2) = subplot(2,1,2);
% plot(serial2hs(tap_b1.time), tap_b1.vdata.signal_green_raw(sp,:)- me.signal_green_raw(sp,:), 'rx')
% linkaxes(s,'x');
% ok = menu('done','no','yes');
% if ok == 2
%     done = true;
% end
% end
%
%
%
% sp = 0;
% done = false;
% figure;
%
% while ~done && sp<10
% sp = sp +1;
% s(1) = subplot(2,1,1);
% plot(serial2hs(tap_b1.time), tap_b1.vdata.signal_green(sp,:), 'r.', serial2hs(tap_b1.time), me.signal_green(sp,:), 'ko');
%  title(['Display dark-subtracted green ',num2str(sp)]);
% s(2) = subplot(2,1,2);
% plot(serial2hs(tap_b1.time), tap_b1.vdata.signal_green(sp,:)- me.signal_green(sp,:), 'rx')
% linkaxes(s,'x');
% ok = menu('done','no','yes');
% if ok == 2
%     done = true;
% end
% end
%
% % Non-zero differences for spot 6,7,8,9,10

return