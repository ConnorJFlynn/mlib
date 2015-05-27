function [Cnu_,c2 ,c4] = ApplyFFOVCorr(nu,Cnu, hfov)
%%
if ~exist('hfov','var')
    % 22.5 mrad FFOV (45 mrad full-angle)
    hfov = 0.0225;
end
dnu = mean(diff(nu));
Dx = 1./dnu; % total phase delay
dx = Dx./32768; % incremental phase delay, equal to effective laser wavelength
x = nu./dnu;
xi = x(1);
x = [[0:(xi-1)]';x];
nu = x.*dnu; % nu is in units of 1/cm
% nu = x; % nu now runs from 0:N
x = x .* dx; % now x is in units of cm
mid_x = length(x)./2;
 x = [x(1:mid_x);flipud(x(1:mid_x))];
% x = x ./ length(x); % now x is in units of cm
Cnu= [repmat(0,(xi),size(Cnu,2));Cnu];

dim_n = find(size(Cnu)==length(nu));
% nu = [nu;flipud(nu)];
%
k2 = (((pi.*hfov.^2./2).^2)./6);
k4 = -(((pi.*hfov.^2./2).^4)./120);
if dim_n ==1
% Cnu = [Cnu; flipud(Cnu)];
c2_ = fft(nu.^2*ones([1,size(Cnu,2)]).*Cnu,[],dim_n);
c4_ = fft(nu.^4*ones([1,size(Cnu,2)]).*Cnu,[],dim_n);
c2 = ifft(x.^2*ones([1,size(Cnu,2)]).*c2_,[],dim_n);
c4 = ifft(x.^4*ones([1,size(Cnu,2)]).*c4_,[],dim_n);
Cnu(1:xi,:) = [];
c2(1:xi,:) = [];
c4(1:xi,:) = [];
% c4(1:xi,:) = [];

else
    Cnu = [Cnu, fliplr(Cnu)];
c2_ = fft(Cnu.*(ones([size(Cnu,1),1])*nu.^2),[],dim_n);
c2 = ifft(c2_.*(ones([size(Cnu,1),1])*x.^2),[],dim_n);
c4_ = fft(Cnu.*(ones([size(Cnu,1),1])*nu.^4),[],dim_n);
c4 = ifft(c4_.*(ones([size(Cnu,1),1])*x.^4),[],dim_n);
Cnu(:,1:xi) = [];
c2(:,1:xi) = [];
c4(:,1:xi) = [];
c2 = c2(:,1:size(Cnu,dim_n));
c4 = c4(:,1:size(Cnu,dim_n));

end
c2 = k2.*c2;
c4 = k4.*c4;
nu(1:xi) = [];
%%
Cnu_ = Cnu + c2 + c4;

%%
figure; 
% plot(nu,[real(Cnu(1,:));c2(1,:);c4(1,:)],'-');
plot(nu,[real(Cnu(:,1)),c2(:,1),c4(:,1)],'-');

grid('on');
legend('Cnu','c2','c4');



%%
return