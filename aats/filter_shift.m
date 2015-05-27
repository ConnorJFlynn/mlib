%computes filter shift
lambda=[380.3   448.25 452.97 499.4  524.7  605.4  666.8  711.8  778.5  864.4  939.5  1018.7 1059   1557.5];
shift =[5e-6     4e-5   4e-5   4e-5  4e-5   4e-5   4e-5   4e-5   4e-5   4e-5   4e-5   4e-5   4e-5   4e-5  ];
T=[0:0.1:30];

shift=lambda.*shift;
shift=(ones(14,1)*T).*(ones(301,1)*shift)'

figure(1)
plot(T,shift)
figure(2)
dtau_r=rayleigh((ones(301,1)*lambda)'/1e3+shift/1e3,1013.25,5)-rayleigh((ones(301,1)*lambda)'/1e3,1013.25,5)
plot(T,dtau_r)