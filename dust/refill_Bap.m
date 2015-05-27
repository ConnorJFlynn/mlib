function  [Bap, SSA] = refill_Bap(aos_time, Bap, Bsp, SSA);
% aip = refill_Bap(aip);
% Identifies times when Bap is missing (presumably due to clogged/saturated
% filters) and fills with Bsp.*(1/SSA -1);
NaNs = isNaN(Bap)|isNaN(SSA);
notNaNs=~NaNs;
if any(notNaNs)
windowSize = 5;
   NaNs = filter(ones(1,windowSize)/windowSize,1,NaNs)==1;
   nNaNs = length(NaNs);
%    NaNs(2:end) = NaNs(1:(end-1))|(NaNs(2:end)); 
%This is a bit subtle.  The first NaNs is broader (OR), so the NotNaNs is
%narrower, thus avoiding interp over NaNs. 
windowSize = 15;
filt_SSA = filter(ones(1,windowSize)/windowSize,1,SSA(notNaNs));
% sm_SSA = smooth(aos_time(notNaNs), SSA(notNaNs),'lowess',20);

SSA(NaNs) = interp1(aos_time(notNaNs), filt_SSA, aos_time(NaNs),'linear');
Bap(NaNs) = Bsp(NaNs).*(1./SSA(NaNs) -1);
NaNs = (SSA>1)|(SSA<0.35);
SSA(NaNs) = NaN;
Bap(NaNs) = NaN;
end

%This generates warnings due to some SSA being NaN so interpolated Bap is
%also NaN. Could get rid of this by flagging NaNs =isNaN(Bap)|isNaN(SSA);
% Maybe first flag and fix SSA NaNs, then flag and fix Bap NaNs.
