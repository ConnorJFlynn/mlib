function fef = merv13
block = [0.01048, 0.95179
0.01186, 0.94464
0.01331, 0.93571
0.01484, 0.92679
0.01666, 0.91429
0.01800, 0.90536
0.02006, 0.89107
0.02253, 0.87679
0.02434, 0.86250
0.02692, 0.84643
0.02999, 0.82857
0.03191, 0.81607
0.03501, 0.79464
0.03783, 0.77500
0.04087, 0.75357
0.04382, 0.73214
0.04698, 0.70893
0.04998, 0.68929
0.05317, 0.66786
0.05700, 0.64464
0.06064, 0.62500
0.06451, 0.60536
0.06863, 0.57857
0.07358, 0.55536
0.07949, 0.53571
0.08655, 0.51786
0.09424, 0.49821
0.10341, 0.48036
0.11173, 0.46250
0.12165, 0.44464
0.13452, 0.42679
0.14422, 0.41250
0.15947, 0.39464
0.17771, 0.38036
0.19804, 0.37143
0.21730, 0.36786
0.24216, 0.37679
0.26986, 0.39464
0.29156, 0.41250
0.31501, 0.43393
0.33772, 0.45357
0.35376, 0.47143
0.38817, 0.49464
0.40977, 0.51786
0.43593, 0.54464
0.45664, 0.56607
0.48205, 0.58929
0.50887, 0.61429
0.53718, 0.63750
0.56270, 0.66071
0.59401, 0.68393
0.62223, 0.71071
0.66196, 0.73393
0.68806, 0.75714
0.72075, 0.77679
0.77271, 0.80714
0.80942, 0.82679
0.88131, 0.85357
0.93035, 0.87143
1.00517, 0.89286
1.08601, 0.91429
1.19165, 0.93393
1.29748, 0.95000
1.42369, 0.96607
1.56217, 0.97857
1.75437, 0.98571
1.92502, 0.98929
2.19556, 0.98929
2.46568, 0.98929
2.79054, 0.98929
3.15820, 0.99107
3.51943, 0.99107
3.92198, 0.99107
4.43871, 0.99107
4.94640, 0.99107
5.55496, 0.99107
6.23839, 0.99107
7.11514, 0.99107
7.99053, 0.99107
8.97362, 0.99107
9.92294, 0.99286
];

D = block(:,1);
eff= block(:,2);
D_ = logspace(log10(.01), log10(5), 100);
eff_ = interp1(D, eff, D_, 'pchip');
figure; plot(D, eff,'o',D_ ,eff_, ':'); logx; legend('merv 13')
fef.D = D_; fef.ef = eff_;

return