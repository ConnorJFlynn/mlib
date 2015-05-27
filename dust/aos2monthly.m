function aos2monthly(aos);
   v = datevec(aos.time);
   fields = fieldnames(aos);
while ~isempty(aos.time);
   last_v = datevec(aos.time(end));
   last_mon = ((v(:,1)==last_v(1))&(v(:,2)==last_v(2)));
   aos_mon.fname = aos.fname;
%    aos_mon.station = aos.station;
   for f = 2:length(fields)
%       disp(fields{f})
   aos_mon.(fields{f}) = aos.(fields{f})(last_mon); aos.(fields{f})(last_mon)=[];
   end
%    last_v(last_mon) = [];
   dstr = datestr(aos_mon.time(1),'yyyy_mm_dd')
   save(['C:\case_studies\dust\nimaosM1.noaa\monthly_mats\aos\aos.',dstr,'.mat'],'aos_mon');
end

   
   

