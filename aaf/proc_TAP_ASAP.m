function tap = proc_TAP_ASAP(clean)
% read ASAP TAP data files with rd_tap_lucy
% concatenate all spots for a given filter
if ~exist('clean','var')
    clean = false;
elseif ischar(clean)
    clean = logical(length(strfind(upper(clean),'T')));
else
    clean = logical(clean);
end

tap = rd_tap_lucy;
tap.flow_mfc = tap.flow_slpm;
[P_tap_flow] =tap_aaf_flow_ref;
tap.flow_slpm = polyval(P_tap_flow, tap.flow_mfc);
% tap_flow_corr =tap.flow_sm./tap_flow_tsi;


tap.clean_blue = NaN(size(tap.signal_blue)); tap.clean_green = tap.clean_blue; tap.clean_red = tap.clean_blue;

% Find records when filter or active spot changes.
spot = [1:10];
active = tap.active_spot;
first_good = find(active>0,1,'first');
first_good_spot = active(first_good);
changes = find((active(2:end)>0)& ((active(2:end)>active(1:end-1)) |...
    (tap.filter_id(2:end)~=tap.filter_id(1:end-1)) ) )+1;
% Extend bounds of loop to extend to end of file
if clean
    bounds = unique([1; changes; length(tap.time)])';
else
    bounds = unique([changes; length(tap.time)])';
end

for t = 1:length(bounds)-1
    %    {datestr(tap_a0.time(bounds(t)-1)), tap_a0.vdata.filter_id(bounds(t)-1), tap_a0.vdata.active_spot_number(bounds(t)-1);...
    %       datestr(tap_a0.time(bounds(t))), tap_a0.vdata.filter_id(bounds(t)), tap_a0.vdata.active_spot_number(bounds(t));...
    %       datestr(tap_a0.time(bounds(t)+1)), tap_a0.vdata.filter_id(bounds(t)+1), tap_a0.vdata.active_spot_number(bounds(t)+1)}
    active = tap.active_spot(bounds(t));
    tap.clean_blue(spot>=active,(bounds(t)):bounds(end)) = tap.signal_blue(spot>=active, bounds(t))*ones([1,length([(bounds(t)):bounds(end)])]);
    tap.clean_green(spot>=active,(bounds(t)):bounds(end)) = tap.signal_green(spot>=active, bounds(t))*ones([1,length([(bounds(t)):bounds(end)])]);
    tap.clean_red(spot>=active,(bounds(t)):bounds(end)) = tap.signal_red(spot>=active, bounds(t))*ones([1,length([(bounds(t)):bounds(end)])]);
end
tap.norm_blue = tap.signal_blue ./ tap.clean_blue;
tap.norm_green = tap.signal_green ./ tap.clean_green;
tap.norm_red = tap.signal_red ./ tap.clean_red;

tap.spot_tr_blue = NaN(size(tap.norm_blue));  tap.spot_tr_green = tap.spot_tr_blue;  tap.spot_tr_red = tap.spot_tr_blue;
tap.transmittance_blue = NaN(size(tap.time)); tap.transmittance_green = tap.transmittance_blue; tap.transmittance_red = tap.transmittance_blue;

% bounds = [1 bounds];
for t = 1:length(bounds)-1
    active = tap.active_spot(bounds(t));
    clean = spot>active & spot<9; % clean spots greater than active spot
    dirty = spot<active; % dirty spots less than active spot number
    
    ref = 10-mod(active,2);  % Yield reference spot = 10 when active spot is even, ref = 9 when odd.
    nonref = 9 + mod(active,2); % yields non-reference spot = 9 when active is even, 10 when odd
    
    % leave non-reference spot with no flow unchanged
    tap.spot_tr_blue(nonref,bounds(t):bounds(end)) = tap.norm_blue(nonref,bounds(t):bounds(end));
    tap.spot_tr_green(nonref,bounds(t):bounds(end)) = tap.norm_green(nonref,bounds(t):bounds(end));
    tap.spot_tr_red(nonref,bounds(t):bounds(end)) = tap.norm_red(nonref,bounds(t):bounds(end));
    
    % normalize reference spot relative to non-reference spot with no flow
    % this should normalize out changes in the LED intensity but will leave
    % effects due to flow including filter leakage / deposition on the reference, filter flexure,
    %RH effects on the filter.
    tap.spot_tr_blue(ref,bounds(t):bounds(end)) = ...
        tap.norm_blue(ref,bounds(t):bounds(end)) ./ tap.norm_blue(nonref,bounds(t):bounds(end));
    tap.spot_tr_green(ref,bounds(t):bounds(end)) = ...
        tap.norm_green(ref,bounds(t):bounds(end)) ./ tap.norm_green(nonref,bounds(t):bounds(end));
    tap.spot_tr_red(ref,bounds(t):bounds(end)) = ...
        tap.norm_red(ref,bounds(t):bounds(end)) ./ tap.norm_red(nonref,bounds(t):bounds(end));
    
    if active>0 % Only compute transmittances if active spot > 0
        % normalize active spot by reference
        % This should normalize out LED changes, filter flexure, and RH effects
        % on the filter, but not RH effects on deposited material, sample
        % evaporation, or filter leaks
        tap.spot_tr_blue(active,bounds(t):bounds(end)) = ...
            tap.norm_blue(active,bounds(t):bounds(end)) ./ tap.norm_blue(ref,bounds(t):bounds(end));
        tap.spot_tr_green(active,bounds(t):bounds(end)) = ...
            tap.norm_green(active,bounds(t):bounds(end)) ./ tap.norm_green(ref,bounds(t):bounds(end));
        tap.spot_tr_red(active,bounds(t):bounds(end)) = ...
            tap.norm_red(active,bounds(t):bounds(end)) ./ tap.norm_red(ref,bounds(t):bounds(end));
        
        % Capture transmittances from active spot into 1-D fields
        tap.transmittance_blue(bounds(t):bounds(end)) = tap.spot_tr_blue(active,bounds(t):bounds(end));
        tap.transmittance_green(bounds(t):bounds(end)) = tap.spot_tr_green(active,bounds(t):bounds(end));
        tap.transmittance_red(bounds(t):bounds(end)) = tap.spot_tr_red(active,bounds(t):bounds(end));
        
        % normalize "clean" spots by non-reference spot with no flow
        % This should normalize out LED changes, filter flexure, and RH effects
        % on the filter, but not filter leaks
        tap.spot_tr_blue(clean,bounds(t):bounds(end)) = ...
            tap.norm_blue(clean,bounds(t):bounds(end)) ./ (ones([sum(clean),1])*tap.norm_blue(nonref,bounds(t):bounds(end)));
        tap.spot_tr_green(clean,bounds(t):bounds(end)) = ...
            tap.norm_green(clean,bounds(t):bounds(end)) ./ (ones([sum(clean),1])*tap.norm_green(nonref,bounds(t):bounds(end)));
        tap.spot_tr_red(clean,bounds(t):bounds(end)) = ...
            tap.norm_red(clean,bounds(t):bounds(end)) ./ (ones([sum(clean),1])*tap.norm_red(nonref,bounds(t):bounds(end)));
        
        % normalize "dirty" spots by non-reference spot with no flow
        % This should normalize out LED changes, filter flexure, and RH effects
        % on the filter, but not RH effects on deposited material, volatilization
        % of depostied material, slow wicking effects, or filter leaks
        
        tap.spot_tr_blue(dirty,bounds(t):bounds(end)) = ...
            tap.norm_blue(dirty,bounds(t):bounds(end)) ./ (ones([sum(dirty),1])*tap.norm_blue(nonref,bounds(t):bounds(end)));
        tap.spot_tr_green(dirty,bounds(t):bounds(end)) = ...
            tap.norm_green(dirty,bounds(t):bounds(end)) ./ (ones([sum(dirty),1])*tap.norm_green(nonref,bounds(t):bounds(end)));
        tap.spot_tr_red(dirty,bounds(t):bounds(end)) = ...
            tap.norm_red(dirty,bounds(t):bounds(end)) ./ (ones([sum(dirty),1])*tap.norm_red(nonref,bounds(t):bounds(end)));
    end
end

tap.transmittance_blue(tap.active_spot==0) = NaN;
tap.transmittance_green(tap.active_spot==0) = NaN;
tap.transmittance_red(tap.active_spot==0) = NaN;

% calibrate flow_slpm
% Use best ratio for TAP to PSAP spot sizes.



figure_(4);
plot(1:length(tap.time), tap.active_spot, 'o-');title('active spot');sb(1) = gca;

figure; plot( tap.time,[1:length(tap.time),],'o');dynamicDateTicks


figure_(1);
ch = 1;
sb(end+1) = subplot(5,1,ch);
plot(1:length(tap.time), 100.*(tap.signal_blue(ch,:) - mean(tap.signal_blue(ch,:)))./mean(tap.signal_blue(ch,:)), 'b-', ...
    1:length(tap.time), 100.*(tap.signal_green(ch,:) - mean(tap.signal_green(ch,:)))./mean(tap.signal_green(ch,:)), 'g-', ...
    1:length(tap.time), 100.*(tap.signal_red(ch,:) - mean(tap.signal_red(ch,:)))./mean(tap.signal_red(ch,:)), 'r-');
% title(tap.fname, 'interp','none')

ch = 2;
sb(end+1) = subplot(5,1,ch);
plot(1:length(tap.time), 100.*(tap.signal_blue(ch,:) - mean(tap.signal_blue(ch,:)))./mean(tap.signal_blue(ch,:)), 'b-', ...
    1:length(tap.time), 100.*(tap.signal_green(ch,:) - mean(tap.signal_green(ch,:)))./mean(tap.signal_green(ch,:)), 'g-', ...
    1:length(tap.time), 100.*(tap.signal_red(ch,:) - mean(tap.signal_red(ch,:)))./mean(tap.signal_red(ch,:)), 'r-');

ch = 3;
sb(end+1) = subplot(5,1,ch);
plot(1:length(tap.time), 100.*(tap.signal_blue(ch,:) - mean(tap.signal_blue(ch,:)))./mean(tap.signal_blue(ch,:)), 'b-', ...
    1:length(tap.time), 100.*(tap.signal_green(ch,:) - mean(tap.signal_green(ch,:)))./mean(tap.signal_green(ch,:)), 'g-', ...
    1:length(tap.time), 100.*(tap.signal_red(ch,:) - mean(tap.signal_red(ch,:)))./mean(tap.signal_red(ch,:)), 'r-');

ch = 4;
sb(end+1) = subplot(5,1,ch);
plot(1:length(tap.time), 100.*(tap.signal_blue(ch,:) - mean(tap.signal_blue(ch,:)))./mean(tap.signal_blue(ch,:)), 'b-', ...
    1:length(tap.time), 100.*(tap.signal_green(ch,:) - mean(tap.signal_green(ch,:)))./mean(tap.signal_green(ch,:)), 'g-', ...
    1:length(tap.time), 100.*(tap.signal_red(ch,:) - mean(tap.signal_red(ch,:)))./mean(tap.signal_red(ch,:)), 'r-');

ch = 5;
sb(end+1) = subplot(5,1,ch);
plot(1:length(tap.time), 100.*(tap.signal_blue(ch,:) - mean(tap.signal_blue(ch,:)))./mean(tap.signal_blue(ch,:)), 'b-', ...
    1:length(tap.time), 100.*(tap.signal_green(ch,:) - mean(tap.signal_green(ch,:)))./mean(tap.signal_green(ch,:)), 'g-', ...
    1:length(tap.time), 100.*(tap.signal_red(ch,:) - mean(tap.signal_red(ch,:)))./mean(tap.signal_red(ch,:)), 'r-');

figure_(2);
ch = 6;
sb(end+1) = subplot(5,1,ch-5);
plot(1:length(tap.time), 100.*(tap.signal_blue(ch,:) - mean(tap.signal_blue(ch,:)))./mean(tap.signal_blue(ch,:)), 'b-', ...
    1:length(tap.time), 100.*(tap.signal_green(ch,:) - mean(tap.signal_green(ch,:)))./mean(tap.signal_green(ch,:)), 'g-', ...
    1:length(tap.time), 100.*(tap.signal_red(ch,:) - mean(tap.signal_red(ch,:)))./mean(tap.signal_red(ch,:)), 'r-');
% title(tap.fname, 'interp','none')

ch = 7;
sb(end+1) = subplot(5,1,ch-5);
plot(1:length(tap.time), 100.*(tap.signal_blue(ch,:) - mean(tap.signal_blue(ch,:)))./mean(tap.signal_blue(ch,:)), 'b-', ...
    1:length(tap.time), 100.*(tap.signal_green(ch,:) - mean(tap.signal_green(ch,:)))./mean(tap.signal_green(ch,:)), 'g-', ...
    1:length(tap.time), 100.*(tap.signal_red(ch,:) - mean(tap.signal_red(ch,:)))./mean(tap.signal_red(ch,:)), 'r-');

ch = 8;
sb(end+1) = subplot(5,1,ch-5);
plot(1:length(tap.time), 100.*(tap.signal_blue(ch,:) - mean(tap.signal_blue(ch,:)))./mean(tap.signal_blue(ch,:)), 'b-', ...
    1:length(tap.time), 100.*(tap.signal_green(ch,:) - mean(tap.signal_green(ch,:)))./mean(tap.signal_green(ch,:)), 'g-', ...
    1:length(tap.time), 100.*(tap.signal_red(ch,:) - mean(tap.signal_red(ch,:)))./mean(tap.signal_red(ch,:)), 'r-');

ch = 9;
sb(end+1) = subplot(5,1,ch-5);
plot(1:length(tap.time), 100.*(tap.signal_blue(ch,:) - mean(tap.signal_blue(ch,:)))./mean(tap.signal_blue(ch,:)), 'b-', ...
    1:length(tap.time), 100.*(tap.signal_green(ch,:) - mean(tap.signal_green(ch,:)))./mean(tap.signal_green(ch,:)), 'g-', ...
    1:length(tap.time), 100.*(tap.signal_red(ch,:) - mean(tap.signal_red(ch,:)))./mean(tap.signal_red(ch,:)), 'r-');

ch = 10;
sb(end+1) = subplot(5,1,ch-5);
plot(1:length(tap.time), 100.*(tap.signal_blue(ch,:) - mean(tap.signal_blue(ch,:)))./mean(tap.signal_blue(ch,:)), 'b-', ...
    1:length(tap.time), 100.*(tap.signal_green(ch,:) - mean(tap.signal_green(ch,:)))./mean(tap.signal_green(ch,:)), 'g-', ...
    1:length(tap.time), 100.*(tap.signal_red(ch,:) - mean(tap.signal_red(ch,:)))./mean(tap.signal_red(ch,:)), 'r-');

figure_(3);
plot(1:length(tap.time), tap.flow_slpm, 'o-');title('sample flow');
sb(end+1) = gca;

% dynamicDateTicks(sb,'link')
linkaxes(sb,'x')



% figure; plot((tap.time), tap.active_spot,'o'); ax(1) = gca;
% figure; plot((tap.time), tap.norm_green, '-'); title('green normalized to spot change'); ax(2) = gca;
% figure; plot((tap.time), tap.spot_tr_blue, '-'); title('blue spot Tr'); ax(3) = gca;

tap_spot_diam = 6.8; % 6.8 mm diam = 38.48 mm^2 area; ???
tap_spot_area = 36.3168;
tic; [tap.Ba_B_raw, tap.Tr_ss_B] = smooth_Tr_Bab(tap.time, tap.flow_slpm, tap.transmittance_blue,30,tap_spot_area);toc
tic; [tap.Ba_G_raw, tap.Tr_ss_G] = smooth_Tr_Bab(tap.time, tap.flow_slpm, tap.transmittance_green,30,tap_spot_area);toc
tic; [tap.Ba_R_raw, tap.Tr_ss_R,tap.dV_ss, tap.dL_ss] = smooth_Tr_Bab(tap.time, tap.flow_slpm, tap.transmittance_red,30,tap_spot_area);toc
close('all') 
tap.k_WBO_B = WeissBondOgren(tap.Tr_ss_B);
tap.Ba_B = tap.Ba_B_raw .* tap.k_WBO_B;
tap.k_WBO_G = WeissBondOgren(tap.Tr_ss_G);
tap.Ba_G = tap.Ba_G_raw .* tap.k_WBO_G;
tap.k_WBO_R = WeissBondOgren(tap.Tr_ss_R);
tap.Ba_R = tap.Ba_R_raw .* tap.k_WBO_R;

good_B = ones(size(tap.time)); 
good_B(tap.active_spot==0) = NaN;
good_B(tap.flow_slpm<0.5) = NaN;
good_G = good_B; good_G(isnan(tap.Ba_G)) = NaN;
good_R = good_B; good_R(isnan(tap.Ba_R)) = NaN;
good_B(isnan(tap.Ba_B)) = NaN;
bad = good_B; bad(good_B==1) = NaN;
done = false;
while ~done
    bad_B = bad; bad_B(good_B==1) = NaN; bad_B(isnan(good_B)) = 1;
    bad_G = bad; bad_G(good_G==1) = NaN; bad_G(isnan(good_G)) = 1;
    bad_R = bad; bad_R(good_R==1) = NaN; bad_R(isnan(good_R)) = 1;
    figure_(4); plot(tap.time, tap.active_spot, 'o-', tap.time, tap.flow_slpm,'r*');
    ax(3) = gca; legend('active spot','sample flow');dynamicDateTicks; 
    figure_(5); plot((tap.time), tap.transmittance_blue, '-',...
        (tap.time), tap.transmittance_green, '-',...
        (tap.time), tap.transmittance_red, '-');dynamicDateTicks
    ax(1) = gca;
    title('transmittances');legend('Ba_B','Ba_G','Ba_R');
    % run part of "proc_tap_a0_to_b1"
    figure_(6); plot((tap.time).*good_B, tap.Ba_B, '.',...
        (tap.time).*good_G, tap.Ba_G, '.',...
        (tap.time).*good_R, tap.Ba_R, '.',...
        (tap.time).*bad_B, tap.Ba_B, 'k.',...
        (tap.time).*bad_G, tap.Ba_G, 'k.',...
        (tap.time).*bad_R, tap.Ba_R, 'k.'); title('Absorption Coefficients');legend('Ba_B','Ba_G','Ba_R');
    ax(2) = gca;dynamicDateTicks
    
    linkaxes(ax,'x');
    if isavar('v5')
        axis(v5);
    end
    mark = menu('Zoom in to select/unselect Ba values','Select','Unselect','Done');
    v5 = axis(ax(2));
    t_ = tap.time>=v5(1)&tap.time<=v5(2);
    good_B_ = tap.Ba_B>=v5(3)&tap.Ba_B<=v5(4);
    good_G_ = tap.Ba_G>=v5(3)&tap.Ba_G<=v5(4);
    good_R_ = tap.Ba_R>=v5(3)&tap.Ba_R<=v5(4);
    if mark==1
        good_B(t_&good_B_) = 1;
        good_G(t_&good_G_) = 1;
        good_R(t_&good_R_) = 1;
    elseif mark==2
        good_B(t_&good_B_) = NaN;
        good_G(t_&good_G_) = NaN;
        good_R(t_&good_R_) = NaN;
    elseif mark==3
        done = true;
    end
end

yyyymmdd = datestr(tap.time, 'yyyymmdd_HHMMSS.FFF');

gs = (good_B==1) | (good_G==1) | (good_R==1);
gs_i = find(gs);
header_str = 'Date_Time, Ba_B, Ba_G, Ba_R, Tr_B, Tr_G, Tr_R, sample_flow_rate, sample_vol, sample_length, Ba_B_raw, Ba_G_raw, Ba_R_raw,w_B, w_G, w_R';
units_str = 'YYYYMMDD_hhmmss.mmm, [1/Mm], [1/Mm], [1/Mm], [unitless], [unitless], [unitless], [LPM], [L], m, [1/Mm], [1/Mm], [1/Mm], [unitless], [unitless], [unitless]';

fid = fopen([tap.pname, strrep(tap.fname{1},'.dat','.csv')],'w');
fprintf(fid, '%s \n',header_str);
fprintf(fid, '%s \n',units_str);
for g = gs_i'
fprintf(fid,'%s, %3.2f, %3.2f, %3.2f, %1.9f, %1.9f, %1.9f, %1.3f, %1.3f, %2.3f, %3.2f, %3.2f, %3.2f, %2.2f, %2.2f, %2.2f \n',...
        yyyymmdd(g,:), ...
        tap.Ba_B(g), tap.Ba_G(g), tap.Ba_R(g), ...
        tap.Tr_ss_B(g), tap.Tr_ss_G(g), tap.Tr_ss_R(g), ...
        tap.flow_slpm(g), tap.dV_ss(g), tap.dL_ss(g), ...
        tap.Ba_B_raw(g), tap.Ba_G_raw(g), tap.Ba_R_raw(g),...
        tap.k_WBO_B(g), tap.k_WBO_G(g),tap.k_WBO_R(g));
end
fclose(fid);

close('all');

return