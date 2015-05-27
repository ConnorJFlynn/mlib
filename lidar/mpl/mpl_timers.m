


t1 = timer('TimerFcn',@rsyncNSAMPL, 'Period', 120.0, 'execution','fixedRate'); start(t1);
t2 = timer('TimerFcn',@process_realtime, 'Period', 240.0, 'execution','fixedRate'); start(t2);
t3 = timer('TimerFcn',@rsyncMPLimages, 'Period', 240.0, 'execution','fixedRate'); start(t3);


% t = timer('TimerFcn',@rsyncMPL, 'Period', 60.0, 'execution','fixedRate'); start(t)

