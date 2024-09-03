function xap = proc_xap_filter(xap)

% Process a single CLAP or TAP file from AMICE including flow cal.
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
xap = xap_cast(xap);
xap.So_B = NaN(size(xap.signal_blue));xap.So_G = xap.So_B; xap.So_R = xap.So_B;
xap.Tr_B = NaN(size(xap.signal_blue)); xap.Tr_G = xap.Tr_B; xap.Tr_R = xap.Tr_B;
spot_adv = [1;1+find(xap.spot(1:end-1)<xap.spot(2:end))];
for sa = 1:length(spot_adv);
   if sa==length(spot_adv)
      xr = spot_adv(sa):length(xap.time);
   else
      xr = [spot_adv(sa):(spot_adv(sa+1)-1)];
   end
   mark_i = spot_adv(sa); mark_j = min([mark_i+50, length(xap.spot)]); %Normalize spot against this interval.
   %The So are normalized to the beginning of the active spot, but not against reference
   xap.So_R(xr,:) = xap.signal_red(xr,:)./median(xap.signal_red(mark_i:mark_j,:));
   xap.So_G(xr,:) = xap.signal_green(xr,:)./median(xap.signal_green(mark_i:mark_j,:));
   xap.So_B(xr,:) = xap.signal_blue(xr,:)./median(xap.signal_blue(mark_i:mark_j,:));
   aspot = xap.spot(spot_adv(sa));% active spot
   for spot = 10:-1:1
      not_spot = [1:10]; not_spot(not_spot==spot | not_spot==aspot) = [];
      xap.Tr_R(xr,spot) = xap.So_R(xr,spot)./median(xap.So_R(xr,not_spot),2);
      xap.Tr_G(xr,spot) = xap.So_G(xr,spot)./median(xap.So_G(xr,not_spot),2);
      xap.Tr_B(xr,spot) = xap.So_B(xr,spot)./median(xap.So_B(xr,not_spot),2);
   end
   xap.Tr(xr,:) = [xap.Tr_B(xr,aspot),xap.Tr_G(xr,aspot),xap.Tr_R(xr,aspot)]; 
   % plot(xr, Tr_blue(xr),'-'); hold('on')
end
bad = diff2(xap.spot); bad(abs(bad)>0) = NaN; bad(2:end) = bad(1:end-1)+bad(2:end);
% figure; plot([1:length(xap.time)],xap.Tr(:,1),'-',find(isnan(bad)),xap.Tr(isnan(bad),1),'ro');
xap.Tr(isnan(bad),:)=NaN; 
xap.Tr(xap.Tr>1)= NaN;
xap.flow_LPM(isnan(bad)) = NaN;
W = 120;
xap.flow_LPM_sm = filter(1/W*ones(W,1), 1, xap.flow_LPM);
xap.flow_LPM_sm = smooth(xap.flow_LPM,120,'moving');

% Bap_B = Bap_ss(xap.time, xap.flow_LPM_sm, Tr, 30);
xap.ATN = -100.*log(xap.Tr);
xap.Bap = Bap_ss(xap.time, xap.flow_LPM_sm, xap.Tr, 300);
 % xap.Bap(xap.Bap<=0) = NaN;
figure; plot(xap.time, xap.Bap,'-' ); dynamicDateTicks; sgtitle(xap.xap_name)
menu('Zoom in to desired region and hit OK when done','OK');
xl = xlim; xl_ = xap.time>xl(1)&xap.time<xl(2);

   Bap = Bap_ss(xap.time, xap.flow_LPM_sm, xap.Tr(:,2), 1, 30);
   time = xap.time(xl_); 
   Bap = Bap(xl_); 
   bad = isnan(Bap); Bap(bad) = interp1(time(~bad), Bap(~bad),time(bad),'linear'); 
   bad = isnan(Bap); Bap(bad) = interp1(time(~bad), Bap(~bad),time(bad),'nearest','extrap'); 
   v.time = time; 
   v.Bap = Bap;
   DATA.freq= v.Bap; DATA.rate = 1;
   v.retval = allan(DATA, xap.xap_name);

for t = length(xap.time):-1:1
   P_aae = polyfit(log(xap.wl), log(xap.Bap(t,:)),2);
   P_aae = polyder(P_aae);
   xap.AAE(t,:) = -real(polyval(P_aae,log(xap.wl)));
   xap.AAE_500(t) = -real(polyval(P_aae,log(500)));
end
figure; plot(xap.time, xap.AAE,'.', xap.time, xap.AAE_500,'k.');dynamicDateTicks

end