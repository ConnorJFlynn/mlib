clear
% reads Perkin Elmer scan  of optical window
colors=['r-' 'g-' 'b-' 'c-' 'm-' 'y-' 'r:' 'g:' 'b:' 'c:' 'm:' 'y:'];
for ii=1:6
 [filename, pathname] = uigetfile('c:\beat\data\glass\*.txt', 'Glass', 0, 0);
 fid=fopen([pathname filename]);
 data=fscanf(fid, '%g %g', [2,inf]);
 fclose(fid);
 lambda_w=data(1,:);
 trans_w=data(2,:);
plot(lambda_w,trans_w,colors([2*ii-1 2*ii]))
hold on
end


% Schott BK7
%
 d1=5 % [mm]
 d2=6 % [mm]
 fid=fopen('c:\beat\data\glass\bk7int.prn');
 data=fscanf(fid, '%g %g', [2,inf]);
 fclose(fid);
 lambda=data(1,:);
 transmittance=data(2,:);
 transmittance=exp(log(transmittance).*d2/d1);
 lambda2=[302:2:1050]
 transmittance =INTERP1(lambda,transmittance,lambda2)';
%plot (lambda2,transmittance);


B1=1.03961212
B2=2.31792344e-1
B3=1.01046945
C1=6.00069867e-3
C2=2.00179144e-2
C3=1.03560653e2

y=sellmeier(lambda2/1000,B1,B2,B3,C1,C2,C3);
n=sqrt(y+1);
P=2*n./(y+2);

%plot (lambda2,P)

transmittance=transmittance.*P;

plot(lambda2,transmittance*100,'g');
set (gca,'xlim',[300 1100])
set (gca,'ylim',[85 95])
xlabel('Wavelength (nm)')
ylabel('Transmittance (%)')
%********************************reads filter scans*******************************
 [filename, pathname] = uigetfile('c:\beat\data\filter\*.*', 'Filter', 0, 0);
 fid=fopen([pathname filename]);
 data=fscanf(fid, '%g %g', [2,inf]);
 fclose(fid);
 lambda_SPM=data(1,:);
 data(2,:) =data(2,:)/max(data(2,:));
 response=data(2,:);

%interpolate to Perkin Elmer scan wavelengths
 i=find(lambda_w <=max(lambda_SPM) & lambda_w >=min(lambda_SPM));
 response =INTERP1(lambda_SPM,response,lambda_w(i))';


x=trapz(response.*trans_w(i))
y=trapz(response)

T=x./y
