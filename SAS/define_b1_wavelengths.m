% SAS wavelengths corresponding to other existing SW narrowband
% measurements:
%%
mfrsr_UV = [368, 300, 305, 311, 317, 325, 332];
mfrsr = [415, 500, 615, 673, 870, 940];
cimel= [ 340, 380, 440, 500, 675, 870, 1020, 1640];
NFOV = [673, 870];
RLidar= [355, 387, 409];
HSRL= [532, 1064];
MPL= [523, 532];
VCeil= [910];
AATS14  = 1000.*[0.3535, 0.3800, 0.4520, 0.5005, 0.5204, 0.6052, 0.6751, ...
    0.7805, 0.8645, 0.9410, 1.0191, 1.2356, 1.5585, 2.1391];

lambda = unique([mfrsr_UV,mfrsr,cimel,NFOV,RLidar,HSRL,MPL,VCeil,AATS14]);
%%
lambda(1) =[];lambda(end) = [];
rdiff = diff(lambda)./lambda(2:end);
lambda(find(rdiff<0.01)) = [];
rdiff(rdiff<0.01) = [];
figure; plot(lambda(2:end), rdiff,'-o')

%%
% In email to Yan Shi from me:
% 355 nm
% 387 nm
% 408 nm
% 415 nm
% 440 nm
% 500 nm
% 532 nm
% 650 nm
% 673 nm
% 762 nm
% 870 nm
% 910 nm
% 935 nm 
% 975 nm closest pixel from vis
% 975 nm closest pixel from nir
% 1019 nm from nir
% 1030 nm
% 1050 nm
% 1064 nm
% 1125 nm
% 1175 nm
% 1225 nm
% 1370 nm
% 1440 nm
% 1500 nm
% 1550 nm
% 1637 nm
%%
emailed = 1000.*[0.3550 0.3870 0.4080 0.4150 0.4400 0.5000 0.5320 0.6500 0.6730 0.7620 ...
 0.8700 0.9100 0.9350 0.9750 0.9751 1.0190 1.0300 1.0500 1.0700 1.1250 ...
 1.1750 1.2250 1.3700 1.4400 1.5000 1.5500 1.6370];
%%