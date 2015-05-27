    a_1=0.69616630;
    l_1=0.068404300; 
    a_2=0.40794260;
    l_2=0.11624140;
    a_3=0.89747940;
    l_3=9.8961610, 
lambda = [0.21:0.01:3.71];
n_sqrd = 1 + a_1.*lambda.^2./(lambda.^2 - l_1.^2) +  a_2.*lambda.^2./(lambda.^2 - l_2.^2) + ...
   a_3.*lambda.^2./(lambda.^2 - l_3.^2);
n = sqrt(n_sqrd);
figure; ax(1) = subplot(2,1,1);
plot(lambda.*1e3, n, '.');
ylabel('index of refraction');
ax(2) = subplot(2,1,2);
plot(lambda.*1e3, asin(1./n).*180./pi,'.');
ylabel('critical angle vs air');
xlabel('wavelength [nm]');
linkaxes(ax,'x');
xlim([325,2200]);
%%