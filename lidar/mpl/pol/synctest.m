testdir = ['C:\ISDAC\sgptest\ftphome\'];
t = timer('TimerFcn',@rsyncMPL, 'Period', 60.0, 'execution','fixedRate'); 
start(t);
sfiles = dir([testdir,'*.mpl']);
for m = 1:length(sfiles)
    disp(['processing ',sfiles(m).name]);
    mplpol = rd_Sigma([testdir,sfiles(m).name]);
    [polavg,ind] = proc_mplpolraw(mplpol);
end
%%
