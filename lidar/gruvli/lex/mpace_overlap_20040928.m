function [range, ol_corr] = mpace_overlap_20040928;
%ol_corr = lidar_mpace_overlap_20040928;
%This correction is a linear regression from vertical data.  This does not
%reflect the bend in the molecular return at the tropopause.  Should look
%at this limation in post-processing.
%
%It was calculated as:
% P = [-1.503439404935121e-001   -1.146687261130099e+000];
% ol_corr = (lidar.range>10) + (lidar.range<=10).*(exp(polyval(P,lidar.range))./copol_smoothest);

ol =  [ 0  0
    0.0300 0
    0.0600 0
    0.0900  656.0191
    0.1200  163.5819
    0.1500   93.1064
    0.1800   64.9091
    0.2100   49.7254
    0.2400   40.2361
    0.2700   33.7441
    0.3000   29.0233
    0.3300   25.4362
    0.3600   22.6184
    0.3900   20.3465
    0.4200   18.4760
    0.4500   16.9093
    0.4800   15.5780
    0.5100   14.4328
    0.5400   13.4372
    0.5700   12.5639
    0.6000   11.7916
    0.6300   11.1038
    0.6600   10.4873
    0.6900    9.9317
    0.7200    9.4283
    0.7500    8.9701
    0.7800    8.5513
    0.8100    8.1671
    0.8400    7.8133
    0.8700    7.4864
    0.9000    7.1835
    0.9300    6.9021
    0.9600    6.6399
    0.9900    6.3950
    1.0200    6.1658
    1.0500    5.9508
    1.0800    5.7487
    1.1100    5.5583
    1.1400    5.3787
    1.1700    5.2090
    1.2000    5.0483
    1.2300    4.8959
    1.2600    4.7512
    1.2900    4.6135
    1.3200    4.4825
    1.3500    4.3575
    1.3800    4.2382
    1.4100    4.1243
    1.4400    4.0153
    1.4700    3.9112
    1.5000    3.8118
    1.5300    3.7223
    1.5600    3.6369
    1.5900    3.5554
    1.6200    3.4777
    1.6500    3.4034
    1.6800    3.3324
    1.7100    3.2646
    1.7400    3.1998
    1.7700    3.1378
    1.8000    3.0784
    1.8300    3.0216
    1.8600    2.9672
    1.8900    2.9151
    1.9200    2.8650
    1.9500    2.8170
    1.9800    2.7709
    2.0100    2.7266
    2.0400    2.6839
    2.0700    2.6427
    2.1000    2.6031
    2.1300    2.5648
    2.1600    2.5278
    2.1900    2.4921
    2.2200    2.4575
    2.2500    2.4239
    2.2800    2.3914
    2.3100    2.3599
    2.3400    2.3292
    2.3700    2.2995
    2.4000    2.2706
    2.4300    2.2425
    2.4600    2.2151
    2.4900    2.1885
    2.5200    2.1627
    2.5500    2.1375
    2.5800    2.1130
    2.6100    2.0891
    2.6400    2.0659
    2.6700    2.0433
    2.7000    2.0213
    2.7300    1.9999
    2.7600    1.9790
    2.7900    1.9588
    2.8200    1.9390
    2.8500    1.9198
    2.8800    1.9011
    2.9100    1.8829
    2.9400    1.8652
    2.9700    1.8480
    3.0000    1.8313
    3.0300    1.8151
    3.0600    1.7993
    3.0900    1.7840
    3.1200    1.7691
    3.1500    1.7546
    3.1800    1.7406
    3.2100    1.7270
    3.2400    1.7137
    3.2700    1.7009
    3.3000    1.6883
    3.3300    1.6761
    3.3600    1.6642
    3.3900    1.6525
    3.4200    1.6412
    3.4500    1.6300
    3.4800    1.6192
    3.5100    1.6085
    3.5400    1.5980
    3.5700    1.5877
    3.6000    1.5777
    3.6300    1.5677
    3.6600    1.5580
    3.6900    1.5484
    3.7200    1.5390
    3.7500    1.5297
    3.7800    1.5206
    3.8100    1.5116
    3.8400    1.5027
    3.8700    1.4940
    3.9000    1.4854
    3.9300    1.4770
    3.9600    1.4687
    3.9900    1.4605
    4.0200    1.4524
    4.0500    1.4445
    4.0800    1.4367
    4.1100    1.4290
    4.1400    1.4215
    4.1700    1.4141
    4.2000    1.4068
    4.2300    1.3996
    4.2600    1.3926
    4.2900    1.3857
    4.3200    1.3790
    4.3500    1.3724
    4.3800    1.3660
    4.4100    1.3597
    4.4400    1.3536
    4.4700    1.3476
    4.5000    1.3417
    4.5300    1.3360
    4.5600    1.3305
    4.5900    1.3251
    4.6200    1.3198
    4.6500    1.3146
    4.6800    1.3095
    4.7100    1.3045
    4.7400    1.2996
    4.7700    1.2949
    4.8000    1.2901
    4.8300    1.2855
    4.8600    1.2809
    4.8900    1.2764
    4.9200    1.2720
    4.9500    1.2675
    4.9800    1.2632
    5.0100    1.2588
    5.0400    1.2546
    5.0700    1.2503
    5.1000    1.2461
    5.1300    1.2419
    5.1600    1.2377
    5.1900    1.2336
    5.2200    1.2295
    5.2500    1.2254
    5.2800    1.2213
    5.3100    1.2172
    5.3400    1.2132
    5.3700    1.2092
    5.4000    1.2052
    5.4300    1.2013
    5.4600    1.1973
    5.4900    1.1934
    5.5200    1.1895
    5.5500    1.1856
    5.5800    1.1818
    5.6100    1.1780
    5.6400    1.1742
    5.6700    1.1705
    5.7000    1.1668
    5.7300    1.1632
    5.7600    1.1596
    5.7900    1.1561
    5.8200    1.1526
    5.8500    1.1493
    5.8800    1.1460
    5.9100    1.1427
    5.9400    1.1395
    5.9700    1.1364
    6.0000    1.1334
    6.0300    1.1304
    6.0600    1.1274
    6.0900    1.1246
    6.1200    1.1217
    6.1500    1.1190
    6.1800    1.1163
    6.2100    1.1136
    6.2400    1.1109
    6.2700    1.1083
    6.3000    1.1058
    6.3300    1.1033
    6.3600    1.1008
    6.3900    1.0983
    6.4200    1.0959
    6.4500    1.0935
    6.4800    1.0911
    6.5100    1.0887
    6.5400    1.0864
    6.5700    1.0840
    6.6000    1.0817
    6.6300    1.0795
    6.6600    1.0772
    6.6900    1.0749
    6.7200    1.0727
    6.7500    1.0705
    6.7800    1.0683
    6.8100    1.0661
    6.8400    1.0639
    6.8700    1.0617
    6.9000    1.0596
    6.9300    1.0574
    6.9600    1.0553
    6.9900    1.0532
    7.0200    1.0511
    7.0500    1.0491
    7.0800    1.0471
    7.1100    1.0451
    7.1400    1.0431
    7.1700    1.0412
    7.2000    1.0393
    7.2300    1.0374
    7.2600    1.0356
    7.2900    1.0339
    7.3200    1.0322
    7.3500    1.0305
    7.3800    1.0289
    7.4100    1.0273
    7.4400    1.0257
    7.4700    1.0242
    7.5000    1.0228
    7.5300    1.0213
    7.5600    1.0200
    7.5900    1.0186
    7.6200    1.0173
    7.6500    1.0160
    7.6800    1.0148
    7.7100    1.0136
    7.7400    1.0124
    7.7700    1.0112
    7.8000    1.0101
    7.8300    1.0090
    7.8600    1.0079
    7.8900    1.0068
    7.9200    1.0058
    7.9500    1.0047
    7.9800    1.0037
    8.0100    1.0026
    8.0400    1.0016
    8.0700    1.0006
    8.1000    0.9996
    8.1300    0.9987
    8.1600    0.9977
    8.1900    0.9967
    8.2200    0.9958
    8.2500    0.9948
    8.2800    0.9939
    8.3100    0.9930
    8.3400    0.9921
    8.3700    0.9913
    8.4000    0.9905
    8.4300    0.9897
    8.4600    0.9889
    8.4900    0.9882
    8.5200    0.9875
    8.5500    0.9869
    8.5800    0.9863
    8.6100    0.9858
    8.6400    0.9853
    8.6700    0.9849
    8.7000    0.9845
    8.7300    0.9843
    8.7600    0.9840
    8.7900    0.9839
    8.8200    0.9837
    8.8500    0.9837
    8.8800    0.9837
    8.9100    0.9838
    8.9400    0.9839
    8.9700    0.9841
    9.0000    0.9843
    9.0300    0.9846
    9.0600    0.9849
    9.0900    0.9853
    9.1200    0.9856
    9.1500    0.9861
    9.1800    0.9865
    9.2100    0.9870
    9.2400    0.9875
    9.2700    0.9880
    9.3000    0.9885
    9.3300    0.9890
    9.3600    0.9895
    9.3900    0.9900
    9.4200    0.9905
    9.4500    0.9910
    9.4800    0.9914
    9.5100    0.9919
    9.5400    0.9923
    9.5700    0.9928
    9.6000    0.9932
    9.6300    0.9935
    9.6600    0.9938
    9.6900    0.9941
    9.7200    0.9944
    9.7500    0.9946
    9.7800    0.9949
    9.8100    0.9951
    9.8400    0.9953
    9.8700    0.9955
    9.9000    0.9958
    9.9300    0.9960
    9.9600    0.9963
    9.9900    0.9966
   10.0200    1.0000
   10.0500    1.0000
   10.0800    1.0000
   10.1100    1.0000
   10.1400    1.0000
   10.1700    1.0000
   10.2000    1.0000
   10.2300    1.0000
   10.2600    1.0000
   10.2900    1.0000
   10.3200    1.0000
   10.3500    1.0000
   10.3800    1.0000
   10.4100    1.0000
   10.4400    1.0000
   10.4700    1.0000
   10.5000    1.0000
   10.5300    1.0000
   10.5600    1.0000
   10.5900    1.0000
   10.6200    1.0000
   10.6500    1.0000
   10.6800    1.0000
   10.7100    1.0000
   10.7400    1.0000
   10.7700    1.0000
   10.8000    1.0000
   10.8300    1.0000
   10.8600    1.0000
   10.8900    1.0000
   10.9200    1.0000
   10.9500    1.0000
   10.9800    1.0000
   11.0100    1.0000
   11.0400    1.0000
   11.0700    1.0000
   11.1000    1.0000
   11.1300    1.0000
   11.1600    1.0000
   11.1900    1.0000
   11.2200    1.0000
   11.2500    1.0000
   11.2800    1.0000
   11.3100    1.0000
   11.3400    1.0000
   11.3700    1.0000
   11.4000    1.0000
   11.4300    1.0000
   11.4600    1.0000
   11.4900    1.0000
   11.5200    1.0000
   11.5500    1.0000
   11.5800    1.0000
   11.6100    1.0000
   11.6400    1.0000
   11.6700    1.0000
   11.7000    1.0000
   11.7300    1.0000
   11.7600    1.0000
   11.7900    1.0000
   11.8200    1.0000
   11.8500    1.0000
   11.8800    1.0000
   11.9100    1.0000
   11.9400    1.0000
   11.9700    1.0000
   12.0000    1.0000
   12.0300    1.0000
   12.0600    1.0000
   12.0900    1.0000
   12.1200    1.0000
   12.1500    1.0000
   12.1800    1.0000
   12.2100    1.0000
   12.2400    1.0000
   12.2700    1.0000
   12.3000    1.0000
   12.3300    1.0000
   12.3600    1.0000
   12.3900    1.0000
   12.4200    1.0000
   12.4500    1.0000
   12.4800    1.0000
   12.5100    1.0000
   12.5400    1.0000
   12.5700    1.0000
   12.6000    1.0000
   12.6300    1.0000
   12.6600    1.0000
   12.6900    1.0000
   12.7200    1.0000
   12.7500    1.0000
   12.7800    1.0000
   12.8100    1.0000
   12.8400    1.0000
   12.8700    1.0000
   12.9000    1.0000
   12.9300    1.0000
   12.9600    1.0000
   12.9900    1.0000
   13.0200    1.0000
   13.0500    1.0000
   13.0800    1.0000
   13.1100    1.0000
   13.1400    1.0000
   13.1700    1.0000
   13.2000    1.0000
   13.2300    1.0000
   13.2600    1.0000
   13.2900    1.0000
   13.3200    1.0000
   13.3500    1.0000
   13.3800    1.0000
   13.4100    1.0000
   13.4400    1.0000
   13.4700    1.0000
   13.5000    1.0000
   13.5300    1.0000
   13.5600    1.0000
   13.5900    1.0000
   13.6200    1.0000
   13.6500    1.0000
   13.6800    1.0000
   13.7100    1.0000
   13.7400    1.0000
   13.7700    1.0000
   13.8000    1.0000
   13.8300    1.0000
   13.8600    1.0000
   13.8900    1.0000
   13.9200    1.0000
   13.9500    1.0000
   13.9800    1.0000
   14.0100    1.0000
   14.0400    1.0000
   14.0700    1.0000
   14.1000    1.0000
   14.1300    1.0000
   14.1600    1.0000
   14.1900    1.0000
   14.2200    1.0000
   14.2500    1.0000
   14.2800    1.0000
   14.3100    1.0000
   14.3400    1.0000
   14.3700    1.0000
   14.4000    1.0000
   14.4300    1.0000
   14.4600    1.0000
   14.4900    1.0000
   14.5200    1.0000
   14.5500    1.0000
   14.5800    1.0000
   14.6100    1.0000
   14.6400    1.0000
   14.6700    1.0000
   14.7000    1.0000
   14.7300    1.0000
   14.7600    1.0000
   14.7900    1.0000
   14.8200    1.0000
   14.8500    1.0000
   14.8800    1.0000
   14.9100    1.0000
   14.9400    1.0000
   14.9700    1.0000
   15.0000    1.0000
   15.0300    1.0000
   15.0600    1.0000
   15.0900    1.0000
   15.1200    1.0000
   15.1500    1.0000
   15.1800    1.0000
   15.2100    1.0000
   15.2400    1.0000
   15.2700    1.0000
   15.3000    1.0000
   15.3300    1.0000
   15.3600    1.0000
   15.3900    1.0000
   15.4200    1.0000
   15.4500    1.0000
   15.4800    1.0000
   15.5100    1.0000
   15.5400    1.0000
   15.5700    1.0000
   15.6000    1.0000
   15.6300    1.0000
   15.6600    1.0000
   15.6900    1.0000
   15.7200    1.0000
   15.7500    1.0000
   15.7800    1.0000
   15.8100    1.0000
   15.8400    1.0000
   15.8700    1.0000
   15.9000    1.0000
   15.9300    1.0000
   15.9600    1.0000
   15.9900    1.0000
   16.0200    1.0000
   16.0500    1.0000
   16.0800    1.0000
   16.1100    1.0000
   16.1400    1.0000
   16.1700    1.0000
   16.2000    1.0000
   16.2300    1.0000
   16.2600    1.0000
   16.2900    1.0000
   16.3200    1.0000
   16.3500    1.0000
   16.3800    1.0000
   16.4100    1.0000
   16.4400    1.0000
   16.4700    1.0000
   16.5000    1.0000
   16.5300    1.0000
   16.5600    1.0000
   16.5900    1.0000
   16.6200    1.0000
   16.6500    1.0000
   16.6800    1.0000
   16.7100    1.0000
   16.7400    1.0000
   16.7700    1.0000
   16.8000    1.0000
   16.8300    1.0000
   16.8600    1.0000
   16.8900    1.0000
   16.9200    1.0000
   16.9500    1.0000
   16.9800    1.0000
   17.0100    1.0000
   17.0400    1.0000
   17.0700    1.0000
   17.1000    1.0000
   17.1300    1.0000
   17.1600    1.0000
   17.1900    1.0000
   17.2200    1.0000
   17.2500    1.0000
   17.2800    1.0000
   17.3100    1.0000
   17.3400    1.0000
   17.3700    1.0000
   17.4000    1.0000
   17.4300    1.0000
   17.4600    1.0000
   17.4900    1.0000
   17.5200    1.0000
   17.5500    1.0000
   17.5800    1.0000
   17.6100    1.0000
   17.6400    1.0000
   17.6700    1.0000
   17.7000    1.0000
   17.7300    1.0000
   17.7600    1.0000
   17.7900    1.0000
   17.8200    1.0000
   17.8500    1.0000
   17.8800    1.0000
   17.9100    1.0000
   17.9400    1.0000
   17.9700    1.0000
   18.0000    1.0000
   18.0300    1.0000
   18.0600    1.0000
   18.0900    1.0000
   18.1200    1.0000
   18.1500    1.0000
   18.1800    1.0000
   18.2100    1.0000
   18.2400    1.0000
   18.2700    1.0000
   18.3000    1.0000
   18.3300    1.0000
   18.3600    1.0000
   18.3900    1.0000
   18.4200    1.0000
   18.4500    1.0000
   18.4800    1.0000
   18.5100    1.0000
   18.5400    1.0000
   18.5700    1.0000
   18.6000    1.0000
   18.6300    1.0000
   18.6600    1.0000
   18.6900    1.0000
   18.7200    1.0000
   18.7500    1.0000
   18.7800    1.0000
   18.8100    1.0000
   18.8400    1.0000
   18.8700    1.0000
   18.9000    1.0000
   18.9300    1.0000
   18.9600    1.0000
   18.9900    1.0000
   19.0200    1.0000
   19.0500    1.0000
   19.0800    1.0000
   19.1100    1.0000
   19.1400    1.0000
   19.1700    1.0000
   19.2000    1.0000
   19.2300    1.0000
   19.2600    1.0000
   19.2900    1.0000
   19.3200    1.0000
   19.3500    1.0000
   19.3800    1.0000
   19.4100    1.0000
   19.4400    1.0000
   19.4700    1.0000
   19.5000    1.0000
   19.5300    1.0000
   19.5600    1.0000
   19.5900    1.0000
   19.6200    1.0000
   19.6500    1.0000
   19.6800    1.0000
   19.7100    1.0000
   19.7400    1.0000
   19.7700    1.0000
   19.8000    1.0000
   19.8300    1.0000
   19.8600    1.0000
   19.8900    1.0000
   19.9200    1.0000
   19.9500    1.0000
   19.9800    1.0000];
range = ol(:,1);
ol_corr = ol(:,2);
return