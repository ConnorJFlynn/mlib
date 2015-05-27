
figure; plot(sa)
figure; plot(uzen)
uzen(1)

ans =

    90

uzen(2)

ans =

    95

sa = [uzen -90, uzen];
figure; plot(uzen)
figure; plot(sa)
sa = [(uzen -90), uzen];
figure; plot(sa)
sa = sa - 40;

clear
uzen = [9.0000E+01  9.5000E+01  1.0000E+02  1.0500E+02  1.1000E+02  1.1500E+02  1.2000E+02  1.2500E+02  1.3000E+02  1.3500E+02 1.4000E+02  1.4500E+02  1.5000E+02  1.5500E+02  1.6000E+02  1.6500E+02  1.7000E+02  1.7500E+02  1.8000E+02];;

uzen  = uzen';

pp_phi0_phi180 = [1.6872E+02  1.6872E+02
  1.6691E+02  1.8256E+02
  1.2668E+02  1.5122E+02
  9.7135E+01  1.2591E+02
  7.7452E+01  1.0820E+02
  6.4025E+01  9.5430E+01
  5.4622E+01  8.5801E+01
  4.7937E+01  7.8239E+01
  4.3177E+01  7.2087E+01
  3.9835E+01  6.6929E+01
  3.7577E+01  6.2496E+01
  3.6168E+01  5.8609E+01
  3.5443E+01  5.5146E+01
  3.5280E+01  5.2026E+01
  3.5586E+01  4.9196E+01
  3.6290E+01  4.6622E+01
  3.7338E+01  4.4285E+01
  3.8688E+01  4.2180E+01
  4.0310E+01  4.0310E+01
];

sa = [(uzen-90); uzen]; figure; plot(sa)
pp = pp_phi0_phi180(:,1);
pp = [pp;flipud(pp_phi0_phi180(:,2));
pp = pp_phi0_phi180(:,1);

this = [pp; flipud(pp_phi0_phi180(:,2))];

pp = [pp; flipud(pp_phi0_phi180(:,2))];
whos

clear this
figure; semilogy(abs(sa), pp)
figure; semilogy(abs(sa-40), pp)
figure; semilogy(abs(sa-140), pp)
figure; semilogy(abs(sa-140), 500*pp)
figure; semilogy(abs(sa-140), 100*pp)
figure; semilogy(abs(sa-140), 10*pp)
figure; semilogy(abs(sa-140), 10*pp)
figure; semilogy(abs(sa-140), 3*pp)
figure; semilogy(abs(sa-140), 2*pp)
figure; semilogy(sa, 2*pp)

