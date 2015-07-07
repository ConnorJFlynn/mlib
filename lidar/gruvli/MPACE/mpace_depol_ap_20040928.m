function [depol_ap, range] = mpace_depol_ap_20040928;
%[depol_ap, range] = mpace_depol_ap_20040928;
% This correction is a data measured with the a cloth draped over the vertical viewport.
% This is an averaged smoothed profile of the background-subtracted
% afterpulse from green_lidar.ap.20040928.112111.nc
% It was smoothed as: 
% depol_ap = smooth(lidar_ap.range, mean(lidar_ap.depol')','lowess');
%

ap =  [0    0.0000
    0.0300    0.0002
    0.0600    0.0004
    0.0900    0.0005
    0.1200    0.0006
    0.1500    0.0008
    0.1800    0.0009
    0.2100    0.0010
    0.2400    0.0011
    0.2700    0.0012
    0.3000    0.0012
    0.3300    0.0012
    0.3600    0.0012
    0.3900    0.0012
    0.4200    0.0013
    0.4500    0.0012
    0.4800    0.0012
    0.5100    0.0012
    0.5400    0.0011
    0.5700    0.0011
    0.6000    0.0011
    0.6300    0.0011
    0.6600    0.0010
    0.6900    0.0010
    0.7200    0.0010
    0.7500    0.0010
    0.7800    0.0010
    0.8100    0.0010
    0.8400    0.0010
    0.8700    0.0010
    0.9000    0.0010
    0.9300    0.0009
    0.9600    0.0009
    0.9900    0.0009
    1.0200    0.0009
    1.0500    0.0009
    1.0800    0.0009
    1.1100    0.0010
    1.1400    0.0010
    1.1700    0.0010
    1.2000    0.0010
    1.2300    0.0010
    1.2600    0.0010
    1.2900    0.0010
    1.3200    0.0010
    1.3500    0.0010
    1.3800    0.0011
    1.4100    0.0011
    1.4400    0.0012
    1.4700    0.0012
    1.5000    0.0012
    1.5300    0.0012
    1.5600    0.0013
    1.5900    0.0014
    1.6200    0.0016
    1.6500    0.0015
    1.6800    0.0014
    1.7100    0.0014
    1.7400    0.0015
    1.7700    0.0014
    1.8000    0.0013
    1.8300    0.0014
    1.8600    0.0015
    1.8900    0.0016
    1.9200    0.0015
    1.9500    0.0015
    1.9800    0.0015
    2.0100    0.0016
    2.0400    0.0017
    2.0700    0.0017
    2.1000    0.0018
    2.1300    0.0018
    2.1600    0.0017
    2.1900    0.0017
    2.2200    0.0018
    2.2500    0.0019
    2.2800    0.0019
    2.3100    0.0018
    2.3400    0.0020
    2.3700    0.0021
    2.4000    0.0020
    2.4300    0.0020
    2.4600    0.0022
    2.4900    0.0023
    2.5200    0.0021
    2.5500    0.0020
    2.5800    0.0021
    2.6100    0.0021
    2.6400    0.0021
    2.6700    0.0021
    2.7000    0.0020
    2.7300    0.0019
    2.7600    0.0018
    2.7900    0.0020
    2.8200    0.0021
    2.8500    0.0023
    2.8800    0.0022
    2.9100    0.0023
    2.9400    0.0022
    2.9700    0.0024
    3.0000    0.0027
    3.0300    0.0026
    3.0600    0.0025
    3.0900    0.0024
    3.1200    0.0025
    3.1500    0.0026
    3.1800    0.0030
    3.2100    0.0031
    3.2400    0.0031
    3.2700    0.0027
    3.3000    0.0025
    3.3300    0.0026
    3.3600    0.0029
    3.3900    0.0029
    3.4200    0.0028
    3.4500    0.0028
    3.4800    0.0028
    3.5100    0.0024
    3.5400    0.0022
    3.5700    0.0024
    3.6000    0.0029
    3.6300    0.0032
    3.6600    0.0033
    3.6900    0.0031
    3.7200    0.0029
    3.7500    0.0031
    3.7800    0.0034
    3.8100    0.0036
    3.8400    0.0037
    3.8700    0.0036
    3.9000    0.0033
    3.9300    0.0029
    3.9600    0.0031
    3.9900    0.0035
    4.0200    0.0037
    4.0500    0.0035
    4.0800    0.0036
    4.1100    0.0035
    4.1400    0.0034
    4.1700    0.0033
    4.2000    0.0035
    4.2300    0.0035
    4.2600    0.0036
    4.2900    0.0037
    4.3200    0.0032
    4.3500    0.0031
    4.3800    0.0031
    4.4100    0.0035
    4.4400    0.0038
    4.4700    0.0041
    4.5000    0.0036
    4.5300    0.0034
    4.5600    0.0035
    4.5900    0.0035
    4.6200    0.0032
    4.6500    0.0031
    4.6800    0.0028
    4.7100    0.0032
    4.7400    0.0035
    4.7700    0.0035
    4.8000    0.0032
    4.8300    0.0033
    4.8600    0.0031
    4.8900    0.0031
    4.9200    0.0028
    4.9500    0.0025
    4.9800    0.0027
    5.0100    0.0036
    5.0400    0.0039
    5.0700    0.0036
    5.1000    0.0035
    5.1300    0.0033
    5.1600    0.0033
    5.1900    0.0034
    5.2200    0.0039
    5.2500    0.0039
    5.2800    0.0039
    5.3100    0.0047
    5.3400    0.0047
    5.3700    0.0044
    5.4000    0.0042
    5.4300    0.0043
    5.4600    0.0042
    5.4900    0.0048
    5.5200    0.0047
    5.5500    0.0047
    5.5800    0.0044
    5.6100    0.0046
    5.6400    0.0048
    5.6700    0.0046
    5.7000    0.0040
    5.7300    0.0038
    5.7600    0.0040
    5.7900    0.0038
    5.8200    0.0035
    5.8500    0.0039
    5.8800    0.0046
    5.9100    0.0053
    5.9400    0.0055
    5.9700    0.0052
    6.0000    0.0051
    6.0300    0.0046
    6.0600    0.0038
    6.0900    0.0031
    6.1200    0.0041
    6.1500    0.0045
    6.1800    0.0045
    6.2100    0.0046
    6.2400    0.0048
    6.2700    0.0050
    6.3000    0.0053
    6.3300    0.0056
    6.3600    0.0050
    6.3900    0.0046
    6.4200    0.0045
    6.4500    0.0046
    6.4800    0.0042
    6.5100    0.0043
    6.5400    0.0049
    6.5700    0.0060
    6.6000    0.0063
    6.6300    0.0059
    6.6600    0.0045
    6.6900    0.0037
    6.7200    0.0036
    6.7500    0.0042
    6.7800    0.0045
    6.8100    0.0058
    6.8400    0.0055
    6.8700    0.0049
    6.9000    0.0051
    6.9300    0.0061
    6.9600    0.0053
    6.9900    0.0044
    7.0200    0.0052
    7.0500    0.0057
    7.0800    0.0057
    7.1100    0.0048
    7.1400    0.0038
    7.1700    0.0039
    7.2000    0.0047
    7.2300    0.0054
    7.2600    0.0049
    7.2900    0.0047
    7.3200    0.0043
    7.3500    0.0053
    7.3800    0.0057
    7.4100    0.0054
    7.4400    0.0049
    7.4700    0.0057
    7.5000    0.0056
    7.5300    0.0054
    7.5600    0.0060
    7.5900    0.0066
    7.6200    0.0062
    7.6500    0.0061
    7.6800    0.0063
    7.7100    0.0054
    7.7400    0.0045
    7.7700    0.0068
    7.8000    0.0080
    7.8300    0.0065
    7.8600    0.0040
    7.8900    0.0036
    7.9200    0.0038
    7.9500    0.0035
    7.9800    0.0033
    8.0100    0.0034
    8.0400    0.0049
    8.0700    0.0064
    8.1000    0.0065
    8.1300    0.0053
    8.1600    0.0045
    8.1900    0.0048
    8.2200    0.0071
    8.2500    0.0085
    8.2800    0.0079
    8.3100    0.0064
    8.3400    0.0074
    8.3700    0.0075
    8.4000    0.0085
    8.4300    0.0086
    8.4600    0.0078
    8.4900    0.0056
    8.5200    0.0074
    8.5500    0.0082
    8.5800    0.0078
    8.6100    0.0074
    8.6400    0.0079
    8.6700    0.0071
    8.7000    0.0065
    8.7300    0.0072
    8.7600    0.0070
    8.7900    0.0071
    8.8200    0.0072
    8.8500    0.0067
    8.8800    0.0050
    8.9100    0.0059
    8.9400    0.0077
    8.9700    0.0075
    9.0000    0.0070
    9.0300    0.0064
    9.0600    0.0056
    9.0900    0.0047
    9.1200    0.0055
    9.1500    0.0063
    9.1800    0.0067
    9.2100    0.0072
    9.2400    0.0070
    9.2700    0.0063
    9.3000    0.0057
    9.3300    0.0064
    9.3600    0.0077
    9.3900    0.0077
    9.4200    0.0068
    9.4500    0.0060
    9.4800    0.0063
    9.5100    0.0074
    9.5400    0.0079
    9.5700    0.0081
    9.6000    0.0062
    9.6300    0.0033
    9.6600    0.0024
    9.6900    0.0047
    9.7200    0.0068
    9.7500    0.0054
    9.7800    0.0043
    9.8100    0.0048
    9.8400    0.0048
    9.8700    0.0049
    9.9000    0.0068
    9.9300    0.0079
    9.9600    0.0065
    9.9900    0.0046
   10.0200    0.0036
   10.0500    0.0052
   10.0800    0.0076
   10.1100    0.0075
   10.1400    0.0063
   10.1700    0.0070
   10.2000    0.0079
   10.2300    0.0082
   10.2600    0.0084
   10.2900    0.0070
   10.3200    0.0077
   10.3500    0.0095
   10.3800    0.0088
   10.4100    0.0065
   10.4400    0.0074
   10.4700    0.0086
   10.5000    0.0079
   10.5300    0.0085
   10.5600    0.0103
   10.5900    0.0121
   10.6200    0.0108
   10.6500    0.0058
   10.6800    0.0044
   10.7100    0.0058
   10.7400    0.0059
   10.7700    0.0025
   10.8000    0.0011
   10.8300    0.0023
   10.8600    0.0047
   10.8900    0.0054
   10.9200    0.0051
   10.9500    0.0043
   10.9800    0.0068
   11.0100    0.0107
   11.0400    0.0136
   11.0700    0.0143
   11.1000    0.0162
   11.1300    0.0141
   11.1600    0.0094
   11.1900    0.0054
   11.2200    0.0052
   11.2500    0.0064
   11.2800    0.0085
   11.3100    0.0096
   11.3400    0.0068
   11.3700    0.0061
   11.4000    0.0070
   11.4300    0.0087
   11.4600    0.0061
   11.4900    0.0088
   11.5200    0.0110
   11.5500    0.0121
   11.5800    0.0112
   11.6100    0.0122
   11.6400    0.0112
   11.6700    0.0107
   11.7000    0.0117
   11.7300    0.0122
   11.7600    0.0113
   11.7900    0.0120
   11.8200    0.0122
   11.8500    0.0107
   11.8800    0.0091
   11.9100    0.0084
   11.9400    0.0064
   11.9700    0.0055
   12.0000    0.0074
   12.0300    0.0096
   12.0600    0.0104
   12.0900    0.0104
   12.1200    0.0079
   12.1500    0.0060
   12.1800    0.0061
   12.2100    0.0082
   12.2400    0.0075
   12.2700    0.0088
   12.3000    0.0097
   12.3300    0.0120
   12.3600    0.0113
   12.3900    0.0098
   12.4200    0.0062
   12.4500    0.0072
   12.4800    0.0098
   12.5100    0.0115
   12.5400    0.0103
   12.5700    0.0114
   12.6000    0.0098
   12.6300    0.0049
   12.6600    0.0032
   12.6900    0.0078
   12.7200    0.0132
   12.7500    0.0111
   12.7800    0.0049
   12.8100    0.0001
   12.8400    0.0069
   12.8700    0.0113
   12.9000    0.0092
   12.9300    0.0040
   12.9600    0.0051
   12.9900    0.0057
   13.0200    0.0055
   13.0500    0.0116
   13.0800    0.0130
   13.1100    0.0101
   13.1400    0.0041
   13.1700    0.0054
   13.2000    0.0055
   13.2300    0.0091
   13.2600    0.0103
   13.2900    0.0102
   13.3200    0.0115
   13.3500    0.0148
   13.3800    0.0126
   13.4100    0.0079
   13.4400    0.0063
   13.4700    0.0082
   13.5000    0.0087
   13.5300    0.0110
   13.5600    0.0107
   13.5900    0.0104
   13.6200    0.0108
   13.6500    0.0107
   13.6800    0.0082
   13.7100    0.0078
   13.7400    0.0119
   13.7700    0.0151
   13.8000    0.0121
   13.8300    0.0047
   13.8600    0.0013
   13.8900    0.0027
   13.9200    0.0066
   13.9500    0.0132
   13.9800    0.0140
   14.0100    0.0060
   14.0400    0.0005
   14.0700    0.0039
   14.1000    0.0085
   14.1300    0.0109
   14.1600    0.0119
   14.1900    0.0097
   14.2200    0.0091
   14.2500    0.0095
   14.2800    0.0066
   14.3100    0.0001
   14.3400    0.0026
   14.3700    0.0102
   14.4000    0.0142
   14.4300    0.0104
   14.4600    0.0078
   14.4900    0.0091
   14.5200    0.0089
   14.5500    0.0118
   14.5800    0.0152
   14.6100    0.0144
   14.6400    0.0067
   14.6700    0.0066
   14.7000    0.0104
   14.7300    0.0108
   14.7600    0.0048
   14.7900    0.0030
   14.8200    0.0065
   14.8500    0.0109
   14.8800    0.0126
   14.9100    0.0115
   14.9400    0.0070
   14.9700    0.0045
   15.0000    0.0080
   15.0300    0.0095
   15.0600    0.0058
   15.0900    0.0039
   15.1200    0.0093
   15.1500    0.0166
   15.1800    0.0155
   15.2100    0.0107
   15.2400    0.0050
   15.2700    0.0076
   15.3000    0.0133
   15.3300    0.0187
   15.3600    0.0141
   15.3900    0.0118
   15.4200    0.0131
   15.4500    0.0143
   15.4800    0.0083
   15.5100    0.0044
   15.5400    0.0075
   15.5700    0.0123
   15.6000    0.0085
   15.6300    0.0039
   15.6600    0.0077
   15.6900    0.0139
   15.7200    0.0184
   15.7500    0.0186
   15.7800    0.0191
   15.8100    0.0185
   15.8400    0.0156
   15.8700    0.0086
   15.9000    0.0077
   15.9300    0.0102
   15.9600    0.0115
   15.9900    0.0097
   16.0200    0.0102
   16.0500    0.0154
   16.0800    0.0163
   16.1100    0.0128
   16.1400    0.0106
   16.1700    0.0140
   16.2000    0.0139
   16.2300    0.0167
   16.2600    0.0176
   16.2900    0.0148
   16.3200    0.0109
   16.3500    0.0157
   16.3800    0.0191
   16.4100    0.0165
   16.4400    0.0104
   16.4700    0.0068
   16.5000    0.0052
   16.5300    0.0032
   16.5600    0.0036
   16.5900    0.0054
   16.6200    0.0073
   16.6500    0.0066
   16.6800    0.0033
   16.7100    0.0016
   16.7400    0.0073
   16.7700    0.0136
   16.8000    0.0092
   16.8300    0.0051
   16.8600    0.0100
   16.8900    0.0144
   16.9200    0.0146
   16.9500    0.0120
   16.9800    0.0099
   17.0100    0.0039
   17.0400    0.0040
   17.0700    0.0064
   17.1000    0.0092
   17.1300    0.0089
   17.1600    0.0105
   17.1900    0.0130
   17.2200    0.0132
   17.2500    0.0148
   17.2800    0.0116
   17.3100    0.0084
   17.3400    0.0048
   17.3700    0.0081
   17.4000    0.0136
   17.4300    0.0205
   17.4600    0.0168
   17.4900    0.0123
   17.5200    0.0122
   17.5500    0.0145
   17.5800    0.0104
   17.6100    0.0088
   17.6400    0.0124
   17.6700    0.0108
   17.7000    0.0015
   17.7300   -0.0030
   17.7600    0.0054
   17.7900    0.0110
   17.8200    0.0137
   17.8500    0.0072
   17.8800    0.0034
   17.9100    0.0032
   17.9400    0.0103
   17.9700    0.0122
   18.0000    0.0148
   18.0300    0.0206
   18.0600    0.0284
   18.0900    0.0241
   18.1200    0.0096
   18.1500    0.0058
   18.1800    0.0168
   18.2100    0.0173
   18.2400    0.0090
   18.2700    0.0024
   18.3000    0.0085
   18.3300    0.0170
   18.3600    0.0224
   18.3900    0.0138
   18.4200    0.0057
   18.4500    0.0063
   18.4800    0.0041
   18.5100    0.0020
   18.5400    0.0080
   18.5700    0.0180
   18.6000    0.0095
   18.6300   -0.0007
   18.6600   -0.0041
   18.6900   -0.0020
   18.7200    0.0001
   18.7500    0.0111
   18.7800    0.0156
   18.8100    0.0050
   18.8400   -0.0042
   18.8700    0.0027
   18.9000    0.0160
   18.9300    0.0182
   18.9600    0.0110
   18.9900    0.0091
   19.0200    0.0103
   19.0500    0.0135
   19.0800    0.0133
   19.1100    0.0121
   19.1400    0.0087
   19.1700    0.0068
   19.2000    0.0056
   19.2300    0.0041
   19.2600    0.0100
   19.2900    0.0159
   19.3200    0.0162
   19.3500    0.0155
   19.3800    0.0224
   19.4100    0.0289
   19.4400    0.0271
   19.4700    0.0188
   19.5000    0.0092
   19.5300    0.0028
   19.5600    0.0079
   19.5900    0.0182
   19.6200    0.0264
   19.6500    0.0243
   19.6800    0.0191
   19.7100    0.0195
   19.7400    0.0205
   19.7700    0.0125
   19.8000    0.0108
   19.8300    0.0147
   19.8600    0.0115
   19.8900    0.0064
   19.9200    0.0062
   19.9500    0.0026
   19.9800   -0.0024];
range = ap(:,1);
depol_ap = ap(:,2);