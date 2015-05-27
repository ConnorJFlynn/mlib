function aip = grid_1day2(aip)
except = {'time';'SS_pct';'CN_frac'};
if isfield(aip,'flags')
   aip = rmfield(aip,'flags');
end
if isfield(aip,'CN_amb')
   aip = rmfield(aip,'CN_amb');
end
fields = fieldnames(aip);

   % Now define hourly grid.  
   dt = 1;
   new_time = [floor(aip.time(1)./dt).*dt:dt:floor(aip.time(end)./dt).*dt]' + dt/2;

% new_time = downsample(aip.time,60);
for f = 2:length(fields);
%    disp(fields{f});
   if (length(aip.time)==length(aip.(fields{f})))&&~any(strcmp(fields{f},except))
      
      if sum(~isNaN(aip.(fields{f})))>1
         aip.(fields{f}) = fill_NaNs(aip.(fields{f}));
         aip.(fields{f}) = downsample(aip.(fields{f}),24);
      else
         aip.(fields{f}) = NaN([floor(length(aip.time)/(24)),1]);
      end
   end
end
aip.wind_spd = (aip.wind_N.^2 + aip.wind_E.^2).^.5;
N = aip.wind_N>=0;
aip.wind_dir(N) = rem(atan(aip.wind_E(N) ./ aip.wind_N(N))*180/pi+360,360);
aip.wind_dir(~N) = atan(aip.wind_E(~N) ./ aip.wind_N(~N))*180/pi+180;
% new_time = downsample(aip.time,60);
% gtp5 = aip.SS_pct>0.5;
% gtp7 = aip.SS_pct>0.5;
% gtp9 = aip.SS_pct>0.9;
% gt1p2 = aip.SS_pct>1.2;
% NaNs = isNaN(aip.SS_pct)|isNaN(aip.CN_frac);
% for t = length(new_time):-1:1
%    near = (aip.time -(new_time(t))>=(-dt/2))&((aip.time-new_time(t))<(dt/2));
% %    near2 =    abs(aip.time - new_time(t))<=1/48;
%    aip.CN_frac_gtp5(t,1) = mean(aip.CN_frac(near&gtp5&~NaNs));
%    aip.CN_frac_gtp7(t,1) = mean(aip.CN_frac(near&gtp7&~NaNs));
%    aip.CN_frac_gtp9(t,1) = mean(aip.CN_frac(near&gtp9&~NaNs));
%    aip.CN_frac_gt1p2(t,1) = mean(aip.CN_frac(near&gt1p2&~NaNs));
%    aip.CN_frac_gtp5_N(t,1) = sum(near&gtp5&~NaNs);
%    aip.CN_frac_gtp7_N(t,1) = sum(near&gtp7&~NaNs);
%    aip.CN_frac_gtp9_N(t,1) = sum(near&gtp9&~NaNs);
%    aip.CN_frac_gt1p2_N(t,1) = sum(near&gt1p2&~NaNs);
% end
% Use this?  aip.(fields{f}) = fill_NaNs(aip.(fields{f}));
aip.time = new_time;
aip.dust = aip.dust>0;
% aip = rmfield(aip,'SS_pct');
% aip = rmfield(aip,'CN_frac');

function A = fill_NaNs(A);
iA = [1:length(A)];
NaNs = (isNaN(A));
% disp(sum(~NaNs))
A(NaNs) = interp1(iA(~NaNs),A(~NaNs),iA(NaNs),'nearest');

