function mtmpl = mtmpl_ret(mpl, time_int);
%mtmpl= mtmpl_ret(mpl, time_int);
%This function returns an MPL structure with a given temporal averaging and cal range, but otherwise empty.
% time_int should be in minutes.
mins_in_day = 24*60;
out_int = time_int/mins_in_day;
mtmpl.time = [floor(mpl.time(1))+0.5*out_int:out_int:(1+floor(mpl.time(1))-0.5*out_int)]';
t = length(mtmpl.time);
mtmpl.r = mpl.r;
mtmpl.range = mpl.range(mpl.r.lte_15);
r = length(mtmpl.range);

mtmpl.klett.beta_a = -9999*ones(r,t);
mtmpl.klett.alpha_a = -9999*ones(r,t);
mtmpl.nor = -9999*ones(r,t);
mtmpl.klett.Sa = -9999*ones(1,t)';
mtmpl.cal.C = -9999*ones(1,t)';
mtmpl.mfr.aod_523 = -9999*ones(1,t)';
mtmpl.hk.bg = -9999*ones(1,t)';
mtmpl.hk.energyMonitor = -9999*ones(1,t)';
mtmpl.sonde.beta_R = -9999*ones(r);
mtmpl.sonde.alpha_R = -9999*ones(r);
