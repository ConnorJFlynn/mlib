%compares our old airmass error expression with the one in John Reagan's Report
m=1:0.1:25;
i=find(m<=2);
dm(i)=.0003*m(i);
j=find(m>2);
dm(j)=.0003.*m(j).*(m(j)/2).^2.2;
dm25=.0025.*m;

figure(1)
semilogy(m,dm,m,dm25);
xlabel('Airmass');
ylabel('Airmass Bias or Airmass Unc');
axis([1 20 0.0001 1])
grid on
legend('Reagan et al.','constant rel. error')