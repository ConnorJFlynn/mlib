function IQM = rVos_from_Tr_Vos(Vos, HW, plots);
% IQM = rVos_from_Tr_Vos(langs,HW,plot);
% Provided with time series of Vo values, this
% function identifies robust Vo values within +/- HW days applies an interquartile filter, 
% and then a polyfit centered on the point  to yield the smoothed
% Vo centered on the given time. Also applies AU correction unless tag==anet

if ~isavar('plots')
   plots = 1;
end

if ~isavar('HW');
   % Define the HWidth Langley samples to use.
   HW = 21;
end
%ugly logic. shouldn't be in here, should be up one level at least.
if isfield(Vos,'fname') 
   if ~foundstr(Vos.fname,'_ARM_')&&~(foundstr(Vos.fname,'sashe')&&foundstr(Vos.fname, 'aod'))
      Vos.Co = Vos.Co.*(Vos.AU.^2);
   end
end
nms = unique(Vos.wls);
IQM.nm = nms;

all_days = floor(min(Vos.time_LST)):ceil(max(Vos.time_LST));
IQM.Vo_AU = NaN([length(nms),length(all_days)]);

for nm_i = length(nms):-1:1
   nm = nms(nm_i);
   if plots==2 figure_(42+nm_i); end 
   for t = length(all_days):-1:1
      IQM.time_LST(t) = all_days(t);
      near = abs(all_days(t)-Vos.time_LST)<=HW;
      these_i = find(near&~isnan(Vos.Vo(:,nm_i)));
      tims = Vos.time_LST(these_i);
      Vo_s = Vos.Vo(these_i,nm_i); 
      good = IQ(Vo_s);
      IQM.Vo_AU(nm_i,t) = polyval(polyfit(tims(good), Vo_s(good),1),all_days(t));
      if plots == 2
      plot(Vos.time_LST, Vos.Vo(:,nm_i),'r.', ...
         tims, Vo_s,'bo', tims(good), Vo_s(good),'gx',...
         all_days,IQM.Vo_AU(nm_i,:) ,'c*'); dynamicDateTicks;  pause(.001)
      title([num2str(nm),' nm']);
      end
   end
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