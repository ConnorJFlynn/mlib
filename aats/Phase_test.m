lambda=[0.550]; 
m=1.4;
r_min=0.01; % minimum radius
r_max=10;   % maximum radius
n_rad=1000; % number of radii
r=logspace(log10(r_min), log10(r_max), n_rad);% radius vector equally spaced in log r
k=2*pi./lambda;

angle=[0:180];
[S11,Q_scat]=phase(lambda,r,m,angle);


N=[1e4 0];        %
r_mode=[0.1 0.3]; % Mode radius in micron
sigma=[2.03 2];  % 
[dNdr]=lognorm(r,N,r_mode,sigma);


%Integration
P=trapz(r,S11.*(ones(size(angle))'*dNdr)')./...
   trapz(r,(ones(size(angle))'*(k.^2*pi*r.^2.*Q_scat'.*dNdr))');

figure(4)
semilogy(angle,P*4*pi)

figure(5)
plot(angle,P*4*pi,'r')
grid on
axis([80 180 0 0.5])