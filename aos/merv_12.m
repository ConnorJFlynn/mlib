function fef = merv_12

D = [.01, .02, .03, .04, .05, .08, .1 , .2, .3, .4,.5, .7, .8, 1, 1.5, 2, 3, 4, 5]
eff= [.85, .7, .6, .52, .47, .35, .305, .22, .26, .33, .4, .55, .6, .71, .9, .95, .98, .995, 1];
D_ = logspace(log10(.01), log10(5), 50);
eff_ = interp1(D, eff, D_, 'pchip');
figure; plot(D, eff,'o',D_ ,eff_, ':'); logx; legend('merv 12')
fef.D = D_; fef.ef = eff_;


return