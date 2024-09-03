function [xap] = amice_xap_auto(xap)
% automatically processes CLAP and TAP files from AMICE including flow cal.
% 2024-08-15: CJF, updating to incorporate new normalization approach
% This approach does not depend on "white" filter and instead normalizes all spots to
% themselves after a spot-advance, and then re-normalizes the active spot against
% all-nine signals to remove light source variation.  Also normalizes each reference
% spot to track leaks
% Maybe explore applying a sliding median or IQ to determine the initial normalization
% value after a spot-advance.


if ~isavar('xap')
   xap = rd_xap3;
elseif ~isstruct(xap)
   xap = rd_xap3(xap);
end
if ~isfield(xap,'xap_name')
   emanp = fliplr(xap.pname{1});
   xap_name = fliplr(strtok(emanp,filesep));
   xap.xap_name = xap_name;
end
LPM = round(median(unique(xap.flow_lpm(~isnan(xap.flow_lpm)))));
P_LPM = get_flowcal(xap_name, LPM);
xap.flow_LPM = polyval(P_LPM, xap.flow_lpm);
% TAP 640 (25); 520 (35); 465 (22)
xap.wl = [465, 520, 640];
xap = xap_cast(xap);
filt = unique(xap.filter_id_hex);
filt(filt<xap.filter_id_hex(1)) = [];
filt(filt>xap.filter_id_hex(end))  = [];
filt(filt<1)= []; filt(filt>(10*median(filt))) = [];
xap_filt = [];
for flt = filt'
   keep = xap.filter_id_hex==flt;
   [xap, xap_] = split_xap(xap, keep);
   xap_flt = proc_xap_filter(xap);
   xap_filt  = cat_timeseries(xap_flt,xap_filt);
   xap = xap_;
end

% xap.So_B = NaN(size(xap.signal_blue));xap.So_G = xap.So_B; xap.So_R = xap.So_B;
% xap.Tr_B = NaN(size(xap.signal_blue)); xap.Tr_G = xap.Tr_B; xap.Tr_R = xap.Tr_B;
% spot_adv = [1;1+find(xap.spot(1:end-1)<xap.spot(2:end))];
% for sa = 1:length(spot_adv);
%    if sa==length(spot_adv)
%       xr = spot_adv(sa):length(xap.time);
%    else
%       xr = [spot_adv(sa):(spot_adv(sa+1)-1)];
%    end
%    mark_i = spot_adv(sa); mark_j = min([mark_i+50, length(xap.spot)]); %Normalize spot against this interval.
%    %The So are normalized to the beginning of the active spot, but not against reference
%    xap.So_R(xr,:) = xap.signal_red(xr,:)./median(xap.signal_red(mark_i:mark_j,:));
%    xap.So_G(xr,:) = xap.signal_green(xr,:)./median(xap.signal_green(mark_i:mark_j,:));
%    xap.So_B(xr,:) = xap.signal_blue(xr,:)./median(xap.signal_blue(mark_i:mark_j,:));
%    aspot = xap.spot(spot_adv(sa));% active spot
%    for spot = 10:-1:1
%       not_spot = [1:10]; not_spot(not_spot==spot | not_spot==aspot) = [];
%       xap.Tr_R(xr,spot) = xap.So_R(xr,spot)./median(xap.So_R(xr,not_spot),2);
%       xap.Tr_G(xr,spot) = xap.So_G(xr,spot)./median(xap.So_G(xr,not_spot),2);
%       xap.Tr_B(xr,spot) = xap.So_B(xr,spot)./median(xap.So_B(xr,not_spot),2);
%    end
%    xap.Tr(xr,:) = [xap.Tr_B(xr,aspot),xap.Tr_G(xr,aspot),xap.Tr_R(xr,aspot)]; 
%    % plot(xr, Tr_blue(xr),'-'); hold('on')
% end
% bad = diff2(xap.spot); bad(abs(bad)>0) = NaN; bad(2:end) = bad(1:end-1)+bad(2:end);
% % figure; plot([1:length(xap.time)],xap.Tr(:,1),'-',find(isnan(bad)),xap.Tr(isnan(bad),1),'ro');
% xap.Tr(isnan(bad),:)=NaN; 
% xap.Tr(xap.Tr>1)= NaN;
% xap.flow_LPM(isnan(bad)) = NaN;
% W = 120;
% xap.flow_LPM_sm = filter(1/W*ones(W,1), 1, xap.flow_LPM);
% xap.flow_LPM_sm = smooth(xap.flow_LPM,120,'moving');
% 
% % Bap_B = Bap_ss(xap.time, xap.flow_LPM_sm, Tr, 30);
% xap.ATN = -100.*log(xap.Tr);
% xap.Bap = Bap_ss(xap.time, xap.flow_LPM_sm, xap.Tr, 30);
%  % xap.Bap(xap.Bap<=0) = NaN;
% figure; plot(xap.time, xap.Bap,'-' ); dynamicDateTicks; sgtitle(xap.xap_name)


% xap.Bap = Bap_ss(ae33.time, ae33.Flow1.*(1-ae33.zeta_leak), ae33.Tr1, 60, ae33.spot_area);

% me_trim = me;
% flds = fieldnames(me_trim); remv = {};
% for fld = length(flds):-1:1
%    field = flds{fld};
%    if ~all(size(me_trim.(field))==size(me_trim.time))
%       remv = [remv,{field}];
%    end
% end
% me_trim = rmfield(me_trim,remv);

function P_LPM = get_flowcal(xap_name, LPM);
flowcal_path = getfilepath('AMICE_flowcals');
if strcmpi(xap_name, 'tap12')
   if LPM==1
      flowcal = load([flowcal_path,'tap12_1LPM.mat']);
   elseif LPM==2
      flowcal = load([flowcal_path,'tap12_2LPM.mat']);
   end
elseif strcmpi(xap_name, 'tap13')
   flowcal = load([flowcal_path,'tap13_1LPM.mat']);
elseif strcmpi(xap_name, 'clap10')
   flowcal = load([flowcal_path,'clap10.mat']);
elseif strcmpi(xap_name, 'clap92')
   flowcal = load([flowcal_path,'clap92.mat']);
end
P_LPM = flowcal.P_LPM;
return


function [xap, xap_] = split_xap(xap, keep)
tlen = length(xap.time);
flds = fieldnames(xap);
for fld = 1:length(flds)
   field = flds{fld};
   if ~any(size(xap.(field))==tlen)
      xap_.(field) = xap.(field);
   elseif size(xap.(field),1)==tlen
      xap_.(field) = xap.(field)(~keep,:);
      xap.(field) = xap.(field)(keep,:);      
   elseif size(xap.(field),2)==tlen
       xap_.(field) = xap.(field)(:,~keep);
      xap.(field) = xap.(field)(:,keep);
     
   end
end
return


