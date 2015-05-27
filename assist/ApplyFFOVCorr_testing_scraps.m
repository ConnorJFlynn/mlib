function [Cnu_,c2 ,c4] = ApplyFFOVCorr(nu,Cnu, hfov)
%%
if ~exist('hfov','var')
    % 22.5 mrad FFOV (45 mrad full-angle)
    hfov = 0.0225;
end
dnu = mean(diff(nu));
Dx = 1./dnu; % total phase delay
dx = Dx./32768; % incremental phase delay, equal to laser wavelength?
x = nu./dnu;
xi = x(1);
x = [[0:(xi-1)]';x];
nu = x.*dnu; % nu is in units of 1/cm
% nu = x; % nu now runs from 0:N
x = x .* dx; % now x is in units of cm
% x = x ./ length(x); % now x is in units of cm
Cnu= [repmat(0,(xi),size(Cnu,2));Cnu];
dim_n = find(size(Cnu)==length(nu));
%
k2 = (((pi.*hfov.^2./2).^2)./6);
k4 = -(((pi.*hfov.^2./2).^4)./120);
if dim_n ==1
c2_ = fft(nu.^2*ones([1,size(Cnu,2)]).*Cnu,[],dim_n);
c2 = ifft(x.^2*ones([1,size(Cnu,2)]).*c2_,[],dim_n);
c4_ = fft(nu.^4*ones([1,size(Cnu,2)]).*Cnu,[],dim_n);
c4 = ifft(x.^4*ones([1,size(Cnu,2)]).*c4_,[],dim_n);
c2(1:xi,:) = [];
c4(1:xi,:) = [];
Cnu(1:xi,:) = [];
else
    %%
    figure; 
    %%
    s(1) = subplot(4,2,1)
    plot(nu,Cnu ,'-')
    %%
    s(2) = subplot(4,2,2);
    plot(nu,Cnu.*(ones([size(Cnu,1),1])*nu.^2) ,'-')
    %%
c2_ = fft(Cnu.*(ones([size(Cnu,1),1])*nu.^2),[],dim_n);
    %%
    s(3) = subplot(4,2,3);
    plot(x,c2_ ,'-');
    s(4) = subplot(4,2,4);
    plot(x,c2_.*(ones([size(Cnu,1),1])*(x./2).^2) ,'-');
    
    %%
c2 = ifft(c2_.*(ones([size(Cnu,1),1])*x.^2),[],dim_n);
    s(5) = subplot(4,2,5);
    plot(nu,k2.*c2 ,'-');

    
%%
c4_ = fft(Cnu.*(ones([size(Cnu,1),1])*nu.^4),[],dim_n);
c4 = ifft(c4_.*(ones([size(Cnu,1),1])*x.^4),[],dim_n);
c2(:,1:xi) = [];
c4(:,1:xi) = [];
Cnu(:,1:xi) = [];
end
c2 = k2.*c2;
c4 = k4.*c4;
nu(1:xi) = [];
%%
Cnu_ = Cnu+ c2 + c4;

%%
figure; 
plot(nu,[real(Cnu);c2;c4],'-');
grid('on');
legend('Cnu','c2','c4');



%%
return