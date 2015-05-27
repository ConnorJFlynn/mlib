clear
lambda=[0.3060:0.00001:0.30606];
press=744;  %station pressure
O3=0.250; %O3 content atm-cm
b=rayleigh(lambda,press);             %rayleigh optical depth

a=O3*1.4729e19*exp(-139.5265*lambda);%ozone
i=find (lambda>0.323);
a(i)=O3*3.34559e23*exp(-170.6829*lambda(i));%ozone 

tau_aero=0.02*ones(size(lambda));
tau=1.8881*ones(size(lambda));%slope from 305 nm normal Langley plot 24.10.1996 LT 8.5-12.2
%tau=1.3438*ones(size(lambda));%slope from 310 nm normal Langley plot 24.10.1996 LT 8.5-12.2
%tau=0.8067*ones(size(lambda));%slope  from 320 nm normal Langley plot 24.10.1996 LT 8.5-12.2
%tau=0.5378 *ones(size(lambda));%slope  from 340 nm normal Langley plot 24.10.1996 LT 8.5-12.2

plot(lambda,a+b+tau_aero-tau)
grid on
