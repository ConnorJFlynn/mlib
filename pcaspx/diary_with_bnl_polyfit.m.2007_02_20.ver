
small =

    0.0000  250.0000
    0.0000  370.0000
    0.0000  880.0000

small_P = polyfit(small(:,2), small(:,1)*1e8, 1)

small_P =

    0.0068    0.7027

small_P = polyfit(small(:,1)*1e8, small(:,2), 1)

small_P =

  141.9730  -79.2498

gain1 = small;
gain1_P = small_P

gain1_P =

  141.9730  -79.2498

gain2 = [2.15E-07	4180
9.94E-07	4550
1.74E-06	4880
2.69E-06	5300
4.60E-06	6080
];

gain2_P = polyfit(gain2(:,1)*1e8, gain2(:,2), 1)

gain2_P =

  1.0e+003 *

    0.0043    4.1135

gain2_P = polyfit(gain2(:,1)*1e8, gain2(:,2)-4096, 1)

gain2_P =

    4.3193   17.4990

gain2(:,2)-4096

ans =

          84
         454
         784
        1204
        1984

gain2_P = polyfit(gain2(:,1)*1e8, (gain2(:,2)-4096), 1)

gain2_P =

    4.3193   17.4990

gain2_P(2) + 4096

ans =

  4.1135e+003

figure; plot(gain2(:,1)*1e8, gain2(:,2), 'ro', gain2(:,1)*1e8, polyval(gain2_P, gain2(:,1)*1e8)+4096,'b')
gain2_P_ = polyfit(gain2(:,1)*1e8, (gain2(:,2)), 1)

gain2_P_ =

  1.0e+003 *

    0.0043    4.1135

figure; plot(gain2(:,1)*1e8, gain2(:,2), 'ro', gain2(:,1)*1e8, polyval(gain2_P, gain2(:,1)*1e8)+4096,'b', gain2(:,1)*1e8, polyval(gain2_P_, gain2(:,1)*1e8),'g', )
??? figure; plot(gain2(:,1)*1e8, gain2(:,2), 'ro', gain2(:,1)*1e8, polyval(gain2_P, gain2(:,1)*1e8)+4096,'b', gain2(:,1)*1e8, polyval(gain2_P_, gain2(:,1)*1e8),'g', )
                                                                                                                                                                     |
Error: Unbalanced or misused parentheses or brackets.

figure; plot(gain2(:,1)*1e8, gain2(:,2), 'ro', gain2(:,1)*1e8, polyval(gain2_P, gain2(:,1)*1e8)+4096,'b', gain2(:,1)*1e8, polyval(gain2_P_, gain2(:,1)*1e8),'g' )
figure; plot(gain2(:,1)*1e8, gain2(:,2), 'ro', gain2(:,1)*1e8, polyval(gain2_P, gain2(:,1)*1e8)+4096,'b', gain2(:,1)*1e8, polyval(gain2_P_, gain2(:,1)*1e8),'g:' )
gain3 = [1.64E-05	8290
3.26E-05	8370
5.79E-05	8470
9.88E-05	8800
1.93E-04	9700
2.57E-04	9875
];

gain3_P = polyfit(gain3(:,1)*1e8, (gain3(:,2)-(2*4096)), 1)

gain3_P =

    0.0719  -60.4354

gain3(:,2)-(2*4096)

ans =

          98
         178
         278
         608
        1508
        1683

gain3_P = polyfit(gain3(:,1)*1e8, gain3(:,2), 1)

gain3_P =

  1.0e+003 *

    0.0001    8.1316

gain3_P = polyfit(gain3(:,1)*1e8, (gain3(:,2)-(2*4096)), 1)

gain3_P =

    0.0719  -60.4354

figure; plot(gain3(:,1)*1e8, gain3(:,2), 'ro', gain3(:,1)*1e8, polyval(gain3_P, gain3(:,1)*1e8)+2*4096,'b')
save pcasp
