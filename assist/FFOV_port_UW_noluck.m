% Below I have attempted to reimplement the important parts of FFOVCMFR from Univ of Wisc (via Dave Turner)
% No luck though...

 infile = ['C:\case_studies\assist\data\sites\sgp\aeri01\sgpaeri01ch1C1.a1.20100520.001046.cdf'];
aeri = ancload(infile);
%

figure; plot(aeri.vars.wnum.data, aeri.vars.mean_rad.data(:,100), '-')
%%

spec = aeri.vars.mean_rad.data(:,100);
nu = aeri.vars.wnum.data;
dnu = nu(2)-nu(1);
stub = [0:dnu:nu(1)]'; stub(end) = [];
spec = [zeros(size(stub));spec];
nu = [stub; nu];
figure; plot(aeri.vars.wnum.data, aeri.vars.mean_rad.data(:,100), 'bx-',...
    nu, spec, '-r.');

FFOV = 0.0225;
Z = 0.5.*pi.*max(nu).*(length(nu)./2).*FFOV.^2;
wnratio = nu./max(nu);
newigm = fft(spec.*(wnratio.^2));

%%

X = [0:(length(wnratio)./2)];
X = [X, fliplr(X(2:end))];
xrat = X./max(X);

%%
refft = ifft((xrat'.^2) .* newigm);
C2 = Z.^2 .* refft ./ 6;

refft = ifft((xrat'.^4) .* newigm);
C4 = Z.^4 .* refft ./ 6;


figure; s(1) = subplot(3,1,1);
plot(nu,spec,'k-');
s(2) = subplot(3,1,2);
plot(nu,real(refft), 'b-');
s(3) = subplot(3,1,3);
plot(nu,real(refft), 'b-');

linkaxes(s,'x');
% newrad = fft(spec.*(wnratio.^4));
% refft = ifft(xrat'.^4 .* newrad);
% C4 = Z.^4 .* refft ./ 6*5*4;


%%
plots_default;
figure; ax(1) = subplot(2,1,1);
plot(nu, spec,'k-', nu, real(refftd), 'r-')
ax(2) = subplot(2,1,2);
plot(nu, real(C4), 'r-');
linkaxes(ax,'x');