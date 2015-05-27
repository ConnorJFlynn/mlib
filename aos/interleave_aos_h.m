function aos = interleave_aos_h(aos);
% Removed bad_trans application to Bap
flags = uint32(aos.vars.flags_NOAA.data);
% flags = uint32(hex2dec((aos.vars.flags_NOAA.data(1:4,:))'));
bad_flag = bitget(flags,1)&bitget(flags,2)&bitget(flags,3);
bad_trans = bitget(flags,6);
submicron = single(bitget(flags,5));
fields = fieldnames(aos.vars);

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
      cut = '_1um_';
   else %Then we want to fill the gap in the 10 um fields.
      cut = '_10um_';
   end
   for f = 1:length(fields)
      if ~isempty(findstr(fields{f},cut))
%          disp(fields{f})
         NaNs = ~isfinite(aos.vars.(fields{f}).data(sub))|(aos.vars.(fields{f}).data(sub)<-9);
%          if ~isempty(findstr(fields{f},'Ba_'))&&findstr(fields{f},'Ba_')==1
%             NaNs = NaNs|bad_trans(sub);
%          end
%          if (sum(~NaNs)>2)&&((max(aos.time(sub(~NaNs)))-min(aos.time(sub(~NaNs))))>(1/36));
         if (sum(~NaNs)>10)
            [P,S,mu] = polyfit(aos.time(sub(~NaNs)),aos.vars.(fields{f}).data(sub(~NaNs)),1);
            aos.vars.(fields{f}).data(sub(NaNs)) = polyval(P,aos.time(sub(NaNs)),[],mu);
            lte_0 = false(size(sub));
            lte_0(sub(NaNs)) = aos.vars.(fields{f}).data(sub(NaNs))<=0;
             aos.vars.(fields{f}).data(lte_0) = NaN;
            big = false(size(sub));
            big(sub(NaNs)) = aos.vars.(fields{f}).data(sub(NaNs))>(2*max(aos.vars.(fields{f}).data(sub(~NaNs))));
             aos.vars.(fields{f}).data(big) = NaN;
         end
      end
   end
   while first < tt && submicron(first)==submicron(first+1)
      first = first +1;
   end
   first = first +1;
end

   for f = 1:length(fields)
       if numel(aos.vars.(fields{f}).dims)==1 && strcmp('time',aos.vars.(fields{f}).dims)
         NaNs = (aos.vars.(fields{f}).data<-9);
         aos.vars.(fields{f}).data(NaNs) = NaN;
      end
   end