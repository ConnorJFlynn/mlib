bkgrd=CountsCC(:,7:99);
numsum=sum(bkgrd,2);
figure;
subplot(2,1,1); plot(Date_Time,numsum)
datetick('x')
ylabel('Total N Conc, per cc')
title('Magic UHSAS Segregated');
legend(s1);
rad=radius(7:99);
Rmeansum=bkgrd*rad';
Rmean=Rmeansum./numsum;
subplot(2,1,2); plot(Date_Time,Rmean)
datetick('x')
xlabel('Time, UTC');
ylabel('Rmean nm');