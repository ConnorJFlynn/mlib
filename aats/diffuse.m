%calculates diffuse light correction

function [F,runc_F]=diffuse(a0,alpha,gamma,method,xsect_dir);

%opens data file
fid=fopen([xsect_dir 'diffuse_Asia.asc']);
fgetl(fid);
fgetl(fid);
data=fscanf(fid,'%g',[9,inf]);
fclose(fid);

switch method
    case 1
        lambda_1=[0.380];
        lambda_2=[1.020];
        
        wvl=   data(1,:);
        acoeff=data(2,:);
        bcoeff=data(3,:);
        runc_s=data(4,:);
        runc_i=data(5,:);
        
    case 2
        lambda_1=[1.020];
        lambda_2=[1.558];
        
        wvl=   data(1,:);
        acoeff=data(6,:);
        bcoeff=data(7,:);
        runc_s=data(8,:);
        runc_i=data(9,:);
end

%compute alpha from fit over given range lambda
x=log(lambda_1);
AOD_1=exp(-gamma*x^2-alpha*x+a0);
x=log(lambda_2);
AOD_2=exp(-gamma*x^2-alpha*x+a0);

alpha=log(AOD_1./AOD_2)./log(lambda_2/lambda_1);

m=length(bcoeff);
n=length(alpha);

f=(ones(n,1)*acoeff).*exp(ones(n,1)*bcoeff.*(ones(m,1)*alpha)');
F=1+f;

runc_f=(ones(n,1)*runc_s).*(ones(m,1)*alpha)'+(ones(n,1)*runc_i);

runc_F=f.*runc_f./F;

figure(1)
subplot(2,1,1)
plot(alpha,f,'.')
subplot(2,1,2)
plot(alpha,runc_f,'.')

figure(2)
subplot(2,1,1)
plot(alpha,F,'.')
subplot(2,1,2)
plot(alpha,runc_F,'.')