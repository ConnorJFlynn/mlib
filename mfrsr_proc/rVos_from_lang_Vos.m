function IQM = rVos_from_lang_Vos(langs, HW, plots);
% IQM = rVos_from_lang_Vos(langs,HW,plot);
% Provided with time series of Vo and Vo_uw values, this
% function identifies robust Vo values within +/- HW days applies an interquartile filter, 
% and then a polyfit centered on the point  to yield the smoothed
% Vo centered on the given time. Also applies AU correction unless tag==anet

if ~isavar('plots')
   plots = 1;
end

if ~isavar('HW');
   % Define the HWidth Langley samples to use.
   HW = 14;
end
if isfield(langs,'tag') 
   if ~foundstr(langs.tag,'anet')
      langs.Co = langs.Co.*(langs.AU.^2);
      langs.Co_uwU = langs.Co_uw.*(langs.AU.^2);
   end
end

nms = unique(langs.nm);
IQM.fname = langs.fname;
IQM.pname = langs.pname;
IQM.nm = nms;

IQM.tag = langs.tag;
tz = langs.time_LST(1)-langs.time_UT(1);

all_days = floor(min(langs.time_UT)):ceil(max(langs.time_UT));
IQM.Vo_AU = NaN([length(nms),length(all_days)]);
if plots==2 figure_(42); end 
for nm_i = length(nms):-1:1
   nm = nms(nm_i);
   for t = length(all_days):-1:1
      IQM.time_UT(t) = all_days(t);
      near = abs(all_days(t)-langs.time_UT)<=HW;
      IQM.pres_atm(t) = langs.pres_atm;
      these_i = find(near&(langs.nm==nm));
      tims = [langs.time_UT(these_i) langs.time_UT(these_i)];
      Vos = [langs.Co(these_i) langs.Co_uw(these_i)]; 
      good = IQ(Vos);
      IQM.Vo_AU(nm_i,t) = polyval(polyfit(tims(good), Vos(good),1),all_days(t));
      if plots == 2
      plot(langs.time_UT(langs.nm==nm), langs.Co(langs.nm==nm),'r.',langs.time_UT(langs.nm==nm), langs.Co_uw(langs.nm==nm),'r.', ...
         tims, Vos,'b.', tims(good), Vos(good),'g.',...
         all_days,IQM.Vo_AU(nm_i,:) ,'c.'); dynamicDateTicks;  pause(.001)
      end
   end
end
IQM.time_LST = IQM.time_UT + tz;
if plots > 0
figure; plot(IQM.time_UT, IQM.Vo_AU,'.');dynamicDateTicks; title(langs.tag);dynamicDateTicks; 
figure; subplot(2,1,1); plot(IQM.time_UT, IQM.Vo_AU./(IQM.Vo_AU(:,1)*ones([1,size(IQM.Vo_AU,2)])),'.');dynamicDateTicks; title(langs.tag);
        subplot(2,1,2); plot(IQM.time_UT, IQM.Vo_AU./(IQM.Vo_AU(:,end)*ones([1,size(IQM.Vo_AU,2)])),'.');dynamicDateTicks; title(langs.tag);
end
%%
% This snippet allows a channel and reference to be specified along with an x-range
% The shape of the reference is scaled to match the x-limits, essentially replacing
% the channel values with these scaled reference values.

% langs.Vo_AU = (mean([langs.Vo;langs.Vo_uw]).*(langs.AU.^2));
% 
% 
% ch = IQM.Vo_Au(2,:); ref = IQM.Vo(4,:); 
% 
% xl = xlim; xl_i = find(all_days>=xl(1),1,'first'); xl_f = find(all_days<=xl(2), 1, 'last');
% Yi = ch(xl_i)./ref(xl_i); Yf = ch(xl_f)./ref(xl_f);
% X = interp1(all_days([xl_i xl_f]), [Yi Yf],all_days(xl_i:xl_f),'linear');
% plot(all_days(xl_i:xl_f), ref(xl_i:xl_f).*X,'k.')
% IQM.Vo(2,xl_i:xl_f) = ref(xl_i:xl_f).*X;

%%

% Find good langleys from entire time series.

%    for ch = {'broadband', 'filter1', 'filter2', 'filter3', 'filter4', 'filter5', 'filter6'}
%       chan = char(ch);
%       Vo.vars.(chan).data = smooth(serial2doy0(Vo.time),Vo.vars.(chan).data,.1, 'lowess')';
%    end
%
end