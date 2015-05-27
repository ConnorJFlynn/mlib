close all
cwl=939.76
bw=4.62 %FWHM
start_wvl=932
end_wvl=948
step=0.1
max_trans=0.83
x=(start_wvl:step:end_wvl);
sigma=bw/2/(-2*log(0.5))^0.5
trans=gauss(x,cwl,sigma);
trans=trans./max(trans)*max_trans;
plot(x,trans)
grid on

hold on
load d:\Beat\Data\Filter\Ames14_1_940.asc

plot(Ames14_1_940(:,1),Ames14_1_940(:,2),'r')

