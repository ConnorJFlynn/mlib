function [time,N]=read_cpc(pathname,filename);
%read in cpc data
data = csvread([pathname,filename]);
time=data(:,2);     % decimal hour
V   =data(:,3);  %Concentration #/cm3

N=10.^(V-3); %Convert to number/cc

%get rid of doubled lines
ii=find(diff(time)==0);
time(ii+1)=[];
N(ii+1)=[];

plot(time,N)