function IQM = daily_smoothed_Vo_from_tau_lang(langs, HW);
% IQM = daily_smoothed_Vo_from_tau_lang(langs,HW);
% Provided with time series of tau-langley Vo values, this
% function identifies Vo values within +/0 HW days applies an interquartile filter, 
% and then a polyfit centered on tehe piont filter to yield the smoothed
% Vo centered on the given time.


if ~isavar('HW');
   % Define the HWidth Langley samples to use.
   HW = 14;
end
nms = unique(langs.nm);
IQM.nm = nms;

all_days = floor(min(langs.time_UT)):ceil(max(langs.time_UT));

for nm_i = length(nms):-1:1
   nm = nms(nm_i);
   for t = length(all_days):-1:1
      IQM.time_UT = all_days(t);
      near = abs(all_days(t)-langs.time_UT)<=HW;
      
      these_i = find(near&(langs.nm==nm));
      good = IQ(langs.Vo(these_i));
      IQM.Vo(nm_i,t) = polyval(polyfit(langs.time_UT(these_i(good)), langs.Vo(these_i(good)),1),all_days(t));
%       plot(langs.time_UT(langs.nm==nm), langs.Vo(langs.nm==nm),'r.', ...
%          langs.time_UT(these_i), langs.Vo(these_i),'b.', ...
%          langs.time_UT(these_i(good)), langs.Vo(these_i(good)),'g.',...
%          all_days,IQM.Vo(nm_i,:) ,'c.'); pause(.01)
   end
end
figure; plot(all_days, IQM.Vo,'.');dynamicDateTicks;title('Anet new')
figure; plot(all_days, IQM.Vo./(IQM.Vo(:,1)*ones([1,366])),'.');dynamicDateTicks;title('Anet C1, new')

%%
% This snippet allows a channel and reference to be specified along with an x-range
% The shape of the reference is scaled to match the x-limits, essentially replacing
% the channel values with these scaled reference values.

ch = IQM.Vo(2,:); ref = IQM.Vo(4,:); 

xl = xlim; xl_i = find(all_days>=xl(1),1,'first'); xl_f = find(all_days<=xl(2), 1, 'last');
Yi = ch(xl_i)./ref(xl_i); Yf = ch(xl_f)./ref(xl_f);
X = interp1(all_days([xl_i xl_f]), [Yi Yf],all_days(xl_i:xl_f),'linear');
plot(all_days(xl_i:xl_f), ref(xl_i:xl_f).*X,'k.')
IQM.Vo(2,xl_i:xl_f) = ref(xl_i:xl_f).*X;

%%

% Find good langleys from entire time series.

%    for ch = {'broadband', 'filter1', 'filter2', 'filter3', 'filter4', 'filter5', 'filter6'}
%       chan = char(ch);
%       Vo.vars.(chan).data = smooth(serial2doy0(Vo.time),Vo.vars.(chan).data,.1, 'lowess')';
%    end
%
