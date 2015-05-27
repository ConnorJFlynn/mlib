function aos = impact_aos_h(aos);
%aos = impact_aos_h(aos);
% This function separates the 1um and 10um values into distinct variables. 

fields = fieldnames(aos);
missing = zeros([length(fields),1]);
missing(1:43) = [NaN,NaN,NaN,NaN,...
   99999,99999,9999,...
   9999,9999,9999,9999,9999,9999,...%ref
   9999,9999,9999,9999,9999,9999,...%wet
   999,999,999,999,999,999,999,999,...%T/rh through S1
   999,999,999,999,999,999,999,999,...%t/rh S2 through amb
   9999,9999,9999,... %pressures
   99,999,9999,9999,9999];% Winds and Bap
   submicron = logical(bitget(aos.flags,5));
   for f = 5:43
      NaNs = (aos.(fields{f})>missing(f));
      aos.(fields{f})(NaNs) = NaN;
      aos.([fields{f} '_1um']) = NaN(size(aos.time));
      aos.([fields{f} '_10um']) = NaN(size(aos.time));
      aos.([fields{f} '_1um'])(submicron) = aos.(fields{f})(submicron);
      aos.([fields{f} '_10um'])(~submicron) = aos.(fields{f})(~submicron);
      aos = rmfield(aos,fields{f});
   end

fields = fieldnames(aos);
bad_flag = bitget(aos.flags,1)&bitget(aos.flags,2)&bitget(aos.flags,3);
bad_trans = bitget(aos.flags,6);

tt = length(aos.time);
t = 1;
first = 1;
last = 1;
while t<tt && submicron(t)==submicron(first)
   t = t+1;
end
while t<tt && submicron(t)~=submicron(first)
   t = t+1;
end
while t<tt
   while t<tt && submicron(t)==submicron(first)
      t = t+1;
   end
   if submicron(t)~=submicron(first)
      last = t-1;
   end
   disp([num2str(tt-last)])
   sub = [first:last];
   % Now check which size cut we are interpolating over   
   % screen out bads and interpolate to fill them.
   if submicron(first)==1 %Then we want to fill the gap in the 1um fields
      cut = '_1um';
   else %Then we want to fill the gap in the 10 um fields.
      cut = '_10um';
   end
   for f = 1:length(fields)
      if ~isempty(findstr(fields{f},cut))
%          disp(fields{f})
         NaNs = ~isfinite(aos.(fields{f})(sub))|(aos.(fields{f})(sub)<-9);
         if ~isempty(findstr(fields{f},'Ba_'))&&findstr(fields{f},'Ba_')==1
            NaNs = NaNs|bad_trans(sub);
         end
%          if (sum(~NaNs)>2)&&((max(aos.time(sub(~NaNs)))-min(aos.time(sub(~NaNs))))>(1/36));
         if (sum(~NaNs)>10)
            [P,S,mu] = polyfit(aos.time(sub(~NaNs)),aos.(fields{f})(sub(~NaNs)),1);
            aos.(fields{f})(sub(NaNs)) = polyval(P,aos.time(sub(NaNs)),[],mu);
            lte_0 = false(size(sub));
            lte_0(sub(NaNs)) = aos.(fields{f})(sub(NaNs))<=0;
             aos.(fields{f})(lte_0) = NaN;
            big = false(size(sub));
            big(sub(NaNs)) = aos.(fields{f})(sub(NaNs))>(2*max(aos.(fields{f})(sub(~NaNs))));
             aos.(fields{f})(big) = NaN;
         end
      end
   end
   while first < tt && submicron(first)==submicron(first+1)
      first = first +1;
   end
   first = first +1;
end

