lower=.250
upper=.350

[filename,path]=uigetfile('c:\beat\data\lamps\f*.prn', 'Choose a Lamp File', 0, 0);
fid=fopen([path filename]);

data=fscanf(fid, '%g %g', [2,inf]);
lambda_FEL=data(1,:)/1000;
FEL       =data(2,:);
fclose(fid);

i=find(lambda_FEL>=lower & lambda_FEL<=upper);
lambda_FEL=lambda_FEL(i);
FEL=FEL(i);


y=log(FEL.*lambda_FEL.^5);
x=1./lambda_FEL;

figure(1)
plot(x,y,'go')

[p,S] = POLYFIT(x,y,1)

b=p(1);
a=p(2);

y=FEL.*lambda_FEL.^5./exp(p(2)+p(1)./lambda_FEL)


[p,S] = POLYFIT(lambda_FEL,y,5)
[y_fit,delta] = POLYVAL(p,[lower:.002:upper],S);

figure(2)
plot([lower:.002:upper],y_fit, lambda_FEL,y,'go' )



fid=fopen('c:\beat\data\lamps\lampfit.dat','a');
fprintf(fid,'%15.6f',a,b,p);
fprintf(fid,'\n');
fclose(fid);

[y_fit,delta] = POLYVAL(p,lambda_FEL,S);

E_fit=y_fit.*lambda_FEL.^(-5).*exp(a+b./lambda_FEL);

figure(3)
plot(lambda_FEL,(FEL-E_fit)./FEL);
