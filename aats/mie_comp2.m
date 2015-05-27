lambda=[0.3]; 
m=1.3;
r_min=0.01; % minimum radius
r_max=10;   % maximum radius
n_rad=10; % number of radii
r=logspace(log10(r_min), log10(r_max), n_rad);% radius vector equally spaced in log r
x=mie_par(r,lambda)
Nmax=mie_test(x)

m=1.3-0.15i
[Q_ext,Q_scat,a,b]=mie(x,m,Nmax);

%m=1.3+0.15i
%[Q_ext2,Q_scat2]=mie2(x,m,Nmax)
%Q_ext-Q_ext2
%Q_scat-Q_scat2
