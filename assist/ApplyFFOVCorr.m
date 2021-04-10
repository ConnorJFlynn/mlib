function [Cnu_,c2 ,c4] = ApplyFFOVCorr(nu,Cnu, hfov)
%%
if ~exist('hfov','var')
    % 22.5 mrad FFOV (45 mrad full-angle)
    hfov = 0.0225;
end
nu_dims = size(nu);
[nu_dims, dim_ii] = sort(nu_dims,'descend');
%%
nu = permute(nu,dim_ii);
Cnu = permute(Cnu,dim_ii);
%%
dnu = mean(diff(nu));
Dx = 1./dnu; % total phase delay
dx = Dx./32768; % incremental phase delay, equal to effective laser wavelength
x = nu./dnu;
xi = x(1);
x = [[0:(xi-1)]';x];
nu = x.*dnu; % nu is in units of 1/cm

x = x .* dx; % now x is in units of cm
mid_x = length(x)./2;
 x = [x;flipud(x)];

Cnu= [repmat(0,(xi),size(Cnu,2));Cnu];


nu = [nu;flipud(nu)];
%
k2 = (((pi.*hfov.^2./2).^2)./6);
k4 = -(((pi.*hfov.^2./2).^4)./120);

Cnu = [Cnu; flipud(Cnu)];
c2_ = fft(nu.^2*ones([1,size(Cnu,2)]).*Cnu,[],1);
c4_ = fft(nu.^4*ones([1,size(Cnu,2)]).*Cnu,[],1);
c2 = ifft(x.^2*ones([1,size(Cnu,2)]).*c2_,[],1);
c4 = ifft(x.^4*ones([1,size(Cnu,2)]).*c4_,[],1);
Cnu(1:xi,:) = [];
c2(1:xi,:) = [];
c4(1:xi,:) = [];
Cnu = Cnu(1:nu_dims(1),:);
c2 = c2(1:nu_dims(1),:);
c4 = c4(1:nu_dims(1),:);

c2 = k2.*c2;
c4 = k4.*c4;
%%
Cnu_ = Cnu + c2 + c4;

%%
% nu(1:xi) = [];
% figure; 
% % plot(nu,[real(Cnu(1,:));c2(1,:);c4(1,:)],'-');
% plot(nu,[real(Cnu(:,1)),c2(:,1),c4(:,1)],'-');
% 
% grid('on');
% legend('Cnu','c2','c4');

Cnu_ = ipermute(Cnu_,dim_ii);
%%
return