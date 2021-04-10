function dLogDp = compute_dN_dLogDp(Dp, Dmin,Dmax)

end

uhsas = anc_load;
aps_a1 = anc_load;
dlog = log10(aps_a1.vdata.aerodynamic_diameter_bound(2,:)./aps_a1.vdata.aerodynamic_diameter_bound(1,:))';
sample_flow_rate = aps_a1.vdata.total_flow_rate-aps_a1.vdata.sheath_flow_rate;
delta_time = mean(diff(aps.time)).*24*60;
sample_vol = sample_flow_rate .* delta_time * 1000; % in cc
figure; plot([1:length(aps_a1.vdata.aerodynamic_diameter)], sqrt(aps_a1.vdata.aerodynamic_diameter_bound(1,:).*aps_a1.vdata.aerodynamic_diameter_bound(2,:)),'x-')
N_cc = aps_a1.vdata.N_TOF./ (ones(length(aps_a1.vdata.aerodynamic_diameter),1)*sample_vol);
dN_dlogDp = N_cc./(dlog*ones([1,length(aps_a1.time)]));
Hh = serial2hs(aps_a1.time); Hh_00 = Hh<=1;
dN_00h = mean(dN_dlogDp(:,1),2);
figure; plot(1000.*aps_a1.vdata.aerodynamic_diameter, dN_00h,'o-'); logx


smps = anc_load;
N_cc = smps.vdata.number_size_distribution; 
N_cc_1 = N_cc(:,1);
good = N_cc_1>0 & smps.vdata.diameter_midpoint>=smps.vdata.lower_size(1);
NN = sum(N_cc_1(good));
f =  N_cc_1(good)./NN;

 figure; plot(smps.vdata.diameter_midpoint(good), f,'o-')
sum(f .*smps.vdata.diameter_midpoint(good))
NN = sum(N_cc_1(N_cc_1>0)); dlogDp1 = NN ./ smps.vdata.total_concentration(1);
N_cc_2 = N_cc(:,2);
NN = sum(N_cc_2(N_cc_2>0)); dlogDp2 = NN ./ smps.vdata.total_concentration(2);
smps.vdata.number_size_distribution./(ones([length(smps.vdata.diameter_midpoint),1])*smps.vdata.total_concentration);
f(f<=0) = NaN;
ds = f .* (smps.vdata.diameter_midpoint*ones([1,length(smps.time)]));
md = meannonan(ds);
smps.vdata
uhsas.vdata.size_distribution
uhsas.vdata.upper_size_limit
uhsas.vdata.lower_size_limit
dLogDP = log(uhsas.vdata.upper_size_limit./uhsas.vdata.lower_size_limit)';
figure; plot([1:length(uhsas.vdata.upper_size_limit)], uhsas.vdata.upper_size_limit,'o')

aps_b1 = anc_load;

dlog_smps = log(smps.vdata.diameter_midpoint(2:end)./smps.vdata.diameter_midpoint(1:end-1));
figure; plot([1:length(smps.vdata.diameter_midpoint)], smps.vdata.diameter_midpoint,'-+')


% Josh's results
josh = [   487.000      924.378
      523.000      294.389
      523.000      232.953
      562.000      164.478
      562.000      116.756
      604.000      86.2574
      604.000      61.8434
      649.000      43.0776
      649.000      29.1649
      698.000      20.5820
      698.000      13.1172
      750.000      9.24090
      750.000      6.10980
      806.000      3.97824
      806.000      3.24938
      866.000      2.37128
      866.000      1.92681
      931.000      1.60742
      931.000      1.60011
      1000.00      1.39717
      1000.00      1.11732
      1075.00      1.24095
      1075.00     0.963506
      1155.00     0.948471
      1155.00     0.839578
      1241.00     0.808037
      1241.00     0.708744
      1334.00     0.656369
      1334.00     0.593173
      1433.00     0.522030
      1433.00     0.432285
      1540.00     0.403785
      1540.00     0.321310
      1655.00     0.282221
      1655.00     0.235678
      1778.00     0.192204
      1778.00     0.160272
      1911.00     0.126107
      1911.00     0.100933
      2054.00    0.0722123
      2054.00    0.0528234
      2207.00    0.0377602
      2207.00    0.0288240
      2371.00    0.0229127
      2371.00    0.0181943
      2548.00    0.0147604
      2548.00    0.0120128
      2738.00    0.0108323
      2738.00   0.00988572
      2943.00   0.00866447
      2943.00   0.00666047
      3162.00     -0.00000
      3162.00         -NaN
];