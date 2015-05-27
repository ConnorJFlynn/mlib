function cos_corr = sgpsashe_coscorr(sza);
% cos_corr = sgpsashe_coscorr(sza);
% A spline of a Fourier smoothed result from TableCurve


corr = [0	1.001418342
2.5	0.998962121
5	0.996790577
7.5	0.994806797
10	0.992913867
12.5	0.991014375
15	0.989008918
17.5	0.986800063
20	0.984300252
22.5	0.981428587
25	0.978120936
27.5	0.974322952
30	0.970002657
32.5	0.965139838
35	0.95973897
37.5	0.95381664
40	0.947413179
42.5	0.940579749
45	0.933387085
47.5	0.925914012
50	0.918252128
52.5	0.910497277
55	0.902749502
57.5	0.895108709
60	0.88767006
62.5	0.880524079
65	0.873747499
67.5	0.867409053
70	0.861559275
72.5	0.856236518
75	0.851448611
77.5	0.847195753
80	0.843478144];
cos_corr = interp1(corr(:,1), corr(:,2), sza,'pchip');

return;
