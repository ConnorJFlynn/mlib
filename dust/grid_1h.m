function aip = grid_1h(aip)
except = {'time';'SS_pct';'CN_frac'};
aip = rmfield(aip,'flags');
aip = rmfield(aip,'CN_amb');
fields = fieldnames(aip);
new_time = downsample(aip.time,60);
for f = 2:length(fields);
%    disp(fields{f});
   if (length(aip.time)==length(aip.(fields{f})))&&~any(strcmp(fields{f},except))
      if sum(~isNaN(aip.(fields{f})))>1
         aip.(fields{f}) = fill_NaNs(aip.(fields{f}));
         aip.(fields{f}) = downsample(aip.(fields{f}),60);
      else
         aip.(fields{f}) = NaN([floor(length(aip.time)/60),1]);
      end
   end
end
% new_time = downsample(aip.time,60);
gtp5 = aip.SS_pct>0.5;
gtp7 = aip.SS_pct>0.5;
gtp9 = aip.SS_pct>0.9;
gt1p2 = aip.SS_pct>1.2;
NaNs = isNaN(aip.SS_pct)|isNaN(aip.CN_frac);
for t = length(new_time):-1:1
   near = abs(aip.time - new_time(t))<=1/48;
   aip.CN_frac_gtp5(t,1) = mean(aip.CN_frac(near&gtp5&~NaNs));
   aip.CN_frac_gtp7(t,1) = mean(aip.CN_frac(near&gtp7&~NaNs));
   aip.CN_frac_gtp9(t,1) = mean(aip.CN_frac(near&gtp9&~NaNs));
   aip.CN_frac_gt1p2(t,1) = mean(aip.CN_frac(near&gt1p2&~NaNs));
   aip.CN_frac_gtp5_N(t,1) = sum(near&gtp5&~NaNs);
   aip.CN_frac_gtp7_N(t,1) = sum(near&gtp7&~NaNs);
   aip.CN_frac_gtp9_N(t,1) = sum(near&gtp9&~NaNs);
   aip.CN_frac_gt1p2_N(t,1) = sum(near&gt1p2&~NaNs);
end
% Use this?  aip.(fields{f}) = fill_NaNs(aip.(fields{f}));
aip.time = new_time;
aip = rmfield(aip,'SS_pct');
aip = rmfield(aip,'CN_frac');

function A = fill_NaNs(A);
iA = [1:length(A)];
NaNs = (isNaN(A));
% disp(sum(~NaNs))
A(NaNs) = interp1(iA(~NaNs),A(~NaNs),iA(NaNs),'nearest','extrap');

