% Chu
%
% Computes coefficients to predict AOD at 605.4 from the other wavelengths
%
% Chu W.P., M.P. McCormick, J. Lenoble, C. Bogniez, and P. Pruvost, 
% "SAGE II Inversion Algorithm", J. Gephys. Res., Vol. 94, No. D6, 8339-8351, June 20, 1989.
%
% Written: 29.1.1998 by Beat Schmid
% 20.10.1999, Changed check for isnan, was not doing it right
clear 
lambda_AATS14=[380.0 449.1 453.9 499.5 524.8 605.9 667.2 711.9 778.6 864.0 940.0 1019.4 1059.7 1557.9]/1e3;	
lambda=lambda_AATS14([1 3 4 5 6 7 9 10]); % select wavelengths to be used in O3 retrieval
m=1.43;     % index of refraction
r_min=0.01; % minimum radius
r_max=10;   % maximum radius
n_rad=1000;  % number of radii

r=logspace(log10(r_min), log10(r_max), n_rad)% radius vector equally spaced in log r

x=mie_par(r,lambda);

tic
for irad=1:n_rad;
    disp([num2str(irad),'-',num2str(n_rad)])
    for ilambda=1:length(lambda)
        N=mie_test(x(irad,ilambda));
          if isnan(N)
           N=40;
          end
        N=N+10;
        [Q_ext(ilambda,irad),dummy]=mie(x(irad,ilambda),m,N);
        Sigma_ext(ilambda,irad)=Q_ext(ilambda,irad)*pi*r(irad).^2; %Go to cross section
     end
 end
 toc
 
 K3=Sigma_ext(3,:);
 K=Sigma_ext;
 K(3,:)=[];
 alpha=K3*K'*inv(K*K'+diag([1e5 1e1 1e1 1e4 1e1 1e1 1e1]))
  


