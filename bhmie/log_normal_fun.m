function [fr]=log_normal_fun(rm,lns,r)
kt=-[log(r./rm)].^2/(2*lns^2);
%% volume size distribution
fr=1/sqrt(2*pi)/lns./r.*exp(kt);
return