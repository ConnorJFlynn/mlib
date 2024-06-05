
eko = rd_eko_tsv; % read eko dir


figure; scatter(90-eko.asel(eko.AM), [eko.filt_1(eko.AM)./eko.pix_1(eko.AM)],8,floor(2.*serial2doy(eko.time(eko.AM)))./2); axis(v)
days = serial2doy(eko.time)>264 & serial2doy(eko.time)<269 ; % visually selected from scatter plot with time as color

hold('on'); plot(90-eko.asel(eko.AM&days), [eko.filt_1(eko.AM&days)./eko.pix_1(eko.AM&days)],'k.'); axis(v)
% eyeball scale factor, maybe better to use PM since it is flatter?
k1 = 1.027;

figure; scatter(90-eko.asel(eko.AM), [eko.filt_2(eko.AM)./eko.pix_2(eko.AM)],8,floor(2.*serial2doy(eko.time(eko.AM)))./2); 
hold('on')
plot(90-eko.asel(eko.AM&days), [eko.filt_2(eko.AM&days)./eko.pix_2(eko.AM&days)],'k*'); 
k2 = .73

figure; scatter(90-eko.asel(eko.AM), [eko.filt_4(eko.AM)./eko.pix_4(eko.AM)],8,floor(2.*serial2doy(eko.time(eko.AM)))./2); 
hold('on')
plot(90-eko.asel(eko.AM&days), [eko.filt_4(eko.AM&days)./eko.pix_4(eko.AM&days)],'k*'); 
k4 = .695

figure; scatter(90-eko.asel(eko.AM), [eko.filt_5(eko.AM)./eko.pix_5(eko.AM)],8,floor(2.*serial2doy(eko.time(eko.AM)))./2); 
hold('on')
plot(90-eko.asel(eko.AM&days), [eko.filt_5(eko.AM&days)./eko.pix_5(eko.AM&days)],'k*'); 
k5 = 1.445;

figure; plot(90-eko.asel(eko.AM&days), [eko.filt_1(eko.AM&days)./eko.pix_1(eko.AM&days)]./k1,'*'); axis(v); legend('filt 1 AM')

figure; plot(90-eko.asel(eko.AM&days), [eko.filt_2(eko.AM&days)./eko.pix_2(eko.AM&days)]./k2,'*'); axis(v);legend('filt 2 AM')

figure; plot(90-eko.asel(eko.AM&days), [eko.filt_4(eko.AM&days)./eko.pix_4(eko.AM&days)]./k4,'*'); axis(v);legend('filt 4 AM')

figure; plot(90-eko.asel(eko.AM&days), [eko.filt_5(eko.AM&days)./eko.pix_5(eko.AM&days)]./k5,'*'); axis(v);legend('filt 5 AM')


figure; plot(90-eko.asel(eko.PM&days), [eko.filt_1(eko.PM&days)./eko.pix_1(eko.PM&days)]./k1,'*'); axis(v); legend('filt 1 PM')

figure; plot(90-eko.asel(eko.PM&days), [eko.filt_2(eko.PM&days)./eko.pix_2(eko.PM&days)]./k2,'*'); axis(v);legend('filt 2 PM')

figure; plot(90-eko.asel(eko.PM&days), [eko.filt_4(eko.PM&days)./eko.pix_4(eko.PM&days)]./k4,'*'); axis(v);legend('filt 4 PM')

figure; plot(90-eko.asel(eko.PM&days), [eko.filt_5(eko.PM&days)./eko.pix_5(eko.PM&days)]./k5,'*'); axis(v);legend('filt 5 PM')

vv = axis;
axis(vv)

figure; plot(1./cosd(90-eko.asel(eko.AM&days)), [eko.filt_1(eko.AM&days)./eko.pix_1(eko.AM&days)]./k1,'*');  legend('filt 1 AM')
av = axis;
figure; plot(1./cosd(90-eko.asel(eko.AM&days)), [eko.filt_2(eko.AM&days)./eko.pix_2(eko.AM&days)]./k2,'*'); axis(av);legend('filt 2 AM')

figure; plot(1./cosd(90-eko.asel(eko.AM&days)), [eko.filt_4(eko.AM&days)./eko.pix_4(eko.AM&days)]./k4,'*'); axis(av);legend('filt 4 AM')

figure; plot(1./cosd(90-eko.asel(eko.AM&days)), [eko.filt_5(eko.AM&days)./eko.pix_5(eko.AM&days)]./k5,'*'); axis(av);legend('filt 5 AM')


figure; plot(1./cosd(90-eko.asel(eko.PM&days)), [eko.filt_1(eko.PM&days)./eko.pix_1(eko.PM&days)]./k1,'*'); axis(av); legend('filt 1 PM')

figure; plot(1./cosd(90-eko.asel(eko.PM&days)), [eko.filt_2(eko.PM&days)./eko.pix_2(eko.PM&days)]./k2,'*'); axis(av);legend('filt 2 PM')

figure; plot(1./cosd(90-eko.asel(eko.PM&days)), [eko.filt_4(eko.PM&days)./eko.pix_4(eko.PM&days)]./k4,'*'); axis(av);legend('filt 4 PM')

figure; plot(1./cosd(90-eko.asel(eko.PM&days)), [eko.filt_5(eko.PM&days)./eko.pix_5(eko.PM&days)]./k5,'*'); axis(av);legend('filt 5 PM')

eko.AM = eko.saz<0 & (1./cosd(eko.asza))<9; eko.PM = eko.saz>0& (1./cosd(eko.asza))<9;

lang_am = (1./cosd(eko.asza))>2 & (1./cosd(eko.asza))<5;

figure; plot(90-eko.asel(eko.PM&days&lang_am), [[eko.filt_2(eko.PM&days&lang_am)./eko.pix_2(eko.PM&days&lang_am)]./k2,...
   [eko.filt_4(eko.PM&days&lang_am)./eko.pix_4(eko.PM&days&lang_am)]./k4,...
   [eko.filt_5(eko.PM&days&lang_am)./eko.pix_5(eko.PM&days&lang_am)]./k5],'.');legend('filt 2','filt 4','filt 5'); title('PM')

figure; plot(90-eko.asel(eko.AM&days&lang_am), [[eko.filt_2(eko.AM&days&lang_am)./eko.pix_2(eko.AM&days&lang_am)]./k2,...
   [eko.filt_4(eko.AM&days&lang_am)./eko.pix_4(eko.AM&days&lang_am)]./k4,...
   [eko.filt_5(eko.AM&days&lang_am)./eko.pix_5(eko.AM&days&lang_am)]./k5],'.');legend('filt 2','filt 4','filt 5'); title('AM')

figure; plot(1./cosd(90-eko.asel(eko.PM&days&lang_am)), [[eko.filt_2(eko.PM&days&lang_am)./eko.pix_2(eko.PM&days&lang_am)]./k2,...
   [eko.filt_4(eko.PM&days&lang_am)./eko.pix_4(eko.PM&days&lang_am)]./k4,...
   [eko.filt_5(eko.PM&days&lang_am)./eko.pix_5(eko.PM&days&lang_am)]./k5],'.');legend('filt 2','filt 4','filt 5'); title('PM')

figure; plot(1./cosd(90-eko.asel(eko.AM&days&lang_am)), [[eko.filt_2(eko.AM&days&lang_am)./eko.pix_2(eko.AM&days&lang_am)]./k2,...
   [eko.filt_4(eko.AM&days&lang_am)./eko.pix_4(eko.AM&days&lang_am)]./k4,...
   [eko.filt_5(eko.AM&days&lang_am)./eko.pix_5(eko.AM&days&lang_am)]./k5],'.');legend('filt 2','filt 4','filt 5'); title('AM')

% PM fit
X = 90-eko.asel(eko.PM&days&lang_am);
Y2  = [eko.filt_2(eko.PM&days&lang_am)./eko.pix_2(eko.PM&days&lang_am)]./k2;
Y4  = [eko.filt_4(eko.PM&days&lang_am)./eko.pix_4(eko.PM&days&lang_am)]./k4;
Y5  = [eko.filt_5(eko.PM&days&lang_am)./eko.pix_5(eko.PM&days&lang_am)]./k5;
bads = isnan(X)|isnan(Y2)|isnan(Y4)|isnan(Y5);
X(bads) = []; Y2(bads) = []; Y4(bads) = []; Y5(bads) = [];
%  [good,P,S,mu] = rpoly_mad(X,Y,N,M,good);
[good_PM, P_PM] = rpoly_mad([X;X;X],[Y2; Y4; Y5], 2,4);sum(good_PM)
xx = [X;X;X]; yy = [Y2; Y4; Y5];
figure; plot(xx,yy, '.', xx(good_PM),yy(good_PM),'k.')
hold('on');
plot(xx(good_PM), yy(good_PM),'k.', [60:80],polyval(P_PM,[60:80]),'r--')

% AM fit
X = 90-eko.asel(eko.AM&days&lang_am);
Y2  = [eko.filt_2(eko.AM&days&lang_am)./eko.pix_2(eko.AM&days&lang_am)]./k2;
Y4  = [eko.filt_4(eko.AM&days&lang_am)./eko.pix_4(eko.AM&days&lang_am)]./k4;
Y5  = [eko.filt_5(eko.AM&days&lang_am)./eko.pix_5(eko.AM&days&lang_am)]./k5;
bads = isnan(X)|isnan(Y2)|isnan(Y4)|isnan(Y5);
X(bads) = []; Y2(bads) = []; Y4(bads) = []; Y5(bads) = [];
%  [good,P,S,mu] = rpoly_mad(X,Y,N,M,good);
[good_AM, P_AM] = rpoly_mad([X;X;X],[Y2; Y4; Y5], 2,4);sum(good_AM)
xx = [X;X;X]; yy = [Y2; Y4; Y5];
figure; plot(xx,yy, '.', xx(good_AM),yy(good_AM),'k.')
hold('on');
plot ([60:80],polyval(P_AM,[60:80]),'r--')

New_corr = NaN(size(eko.time));
New_corr(eko.AM) = polyval(P_AM,eko.asza(eko.AM));
New_corr(eko.PM) = polyval(P_PM,eko.asza(eko.PM));

% Noon-fit (vs saz)
X = eko.saz(day);
Y2  = [eko.filt_2(day)./eko.pix_2(day)]./k2;
Y4  = [eko.filt_4(day)./eko.pix_4(day)]./k4;
Y5  = [eko.filt_5(day)./eko.pix_5(day)]./k5;
bads = isnan(X)|isnan(Y2)|isnan(Y4)|isnan(Y5);
X(bads) = []; Y2(bads) = []; Y4(bads) = []; Y5(bads) = [];
%  [good,P,S,mu] = rpoly_mad(X,Y,N,M,good);
[good_day, P_day] = rpoly_mad([X;X;X],[Y2; Y4; Y5], 3,4);sum(good_day)
xx = [X;X;X]; yy = [Y2; Y4; Y5];
figure; plot(xx,yy, '.')
hold('on');
plot(xx(good_day), yy(good_day),'k.', [-85:85],polyval(P_day,[-85:85]),'r--')
Noon_corr = NaN(size(eko.time));
Noon_corr = polyval(P_day,eko.saz);


% Before
figure; plot(1./cosd(90-eko.asel(eko.PM&days&lang_am)), [[eko.filt_2(eko.PM&days&lang_am)./eko.pix_2(eko.PM&days&lang_am)]./k2,...
   [eko.filt_4(eko.PM&days&lang_am)./eko.pix_4(eko.PM&days&lang_am)]./k4,...
   [eko.filt_5(eko.PM&days&lang_am)./eko.pix_5(eko.PM&days&lang_am)]./k5],'.');legend('filt 2','filt 4','filt 5'); title('PM')

figure; plot(1./cosd(90-eko.asel(eko.AM&days&lang_am)), [[eko.filt_2(eko.AM&days&lang_am)./eko.pix_2(eko.AM&days&lang_am)]./k2,...
   [eko.filt_4(eko.AM&days&lang_am)./eko.pix_4(eko.AM&days&lang_am)]./k4,...
   [eko.filt_5(eko.AM&days&lang_am)./eko.pix_5(eko.AM&days&lang_am)]./k5],'.');legend('filt 2','filt 4','filt 5'); title('AM')

% Apply fitted corrections

figure; plot(90-eko.asel(eko.PM&days&lang_am), [[eko.filt_2(eko.PM&days&lang_am)./eko.pix_2(eko.PM&days&lang_am)]./k2./New_corr(eko.PM&days&lang_am),...
   [eko.filt_4(eko.PM&days&lang_am)./eko.pix_4(eko.PM&days&lang_am)]./k4./New_corr(eko.PM&days&lang_am),...
   [eko.filt_5(eko.PM&days&lang_am)./eko.pix_5(eko.PM&days&lang_am)]./k5./New_corr(eko.PM&days&lang_am)],'.');legend('filt 2','filt 4','filt 5'); title('PM')

figure; plot(90-eko.asel(eko.AM&days&lang_am), [[eko.filt_2(eko.AM&days&lang_am)./eko.pix_2(eko.AM&days&lang_am)]./k2./New_corr(eko.AM&days&lang_am),...
   [eko.filt_4(eko.AM&days&lang_am)./eko.pix_4(eko.AM&days&lang_am)]./k4./New_corr(eko.AM&days&lang_am),...
   [eko.filt_5(eko.AM&days&lang_am)./eko.pix_5(eko.AM&days&lang_am)]./k5./New_corr(eko.AM&days&lang_am)],'.');legend('filt 2','filt 4','filt 5'); title('AM')

% Noon corr
figure; plot(90-eko.asel(days&lang_am), [[eko.filt_2(days&lang_am)./eko.pix_2(days&lang_am)]./k2./Noon_corr(days&lang_am),...
   [eko.filt_4(days&lang_am)./eko.pix_4(days&lang_am)]./k4./Noon_corr(days&lang_am),...
   [eko.filt_5(days&lang_am)./eko.pix_5(days&lang_am)]./k5./Noon_corr(days&lang_am)],'.');legend('filt 2','filt 4','filt 5'); title('AM')


figure; plot(-1./cosd(90-eko.asel(eko.AM&days)), ...
   cosd(90-eko.asel(eko.AM&days)).*(1-[eko.filt_2(eko.AM&days)./eko.pix_2(eko.AM&days)]./k2./New_corr(eko.AM&days)),'g+',...
   1./cosd(90-eko.asel(eko.PM&days)),...
   cosd(90-eko.asel(eko.PM&days)).*(1-[eko.filt_2(eko.PM&days)./eko.pix_2(eko.PM&days)]./k2./New_corr(eko.PM&days)),'gx');  legend('filt 2 AM','filt 2 PM')

figure; plot(-1./cosd(90-eko.asel(eko.AM&days)), ...
   cosd(90-eko.asel(eko.AM&days)).*(1-[eko.filt_4(eko.AM&days)./eko.pix_4(eko.AM&days)]./k4./New_corr(eko.AM&days)),'r+',...
   1./cosd(90-eko.asel(eko.PM&days)),...
   cosd(90-eko.asel(eko.PM&days)).*(1-[eko.filt_4(eko.PM&days)./eko.pix_4(eko.PM&days)]./k4./New_corr(eko.PM&days)),'rx');  legend('filt 4 AM','filt 4 PM')

figure; plot(-1./cosd(90-eko.asel(eko.AM&days)), ...
   cosd(90-eko.asel(eko.AM&days)).*(1-[eko.filt_5(eko.AM&days)./eko.pix_5(eko.AM&days)]./k5./New_corr(eko.AM&days)),'m+',...
   1./cosd(90-eko.asel(eko.PM&days)),...
   cosd(90-eko.asel(eko.PM&days)).*(1-[eko.filt_5(eko.PM&days)./eko.pix_5(eko.PM&days)]./k5./New_corr(eko.PM&days)),'mx');  legend('filt 5 AM','filt 5 PM')

% Noon corr

figure; plot(1./cosd(90-eko.asel(days)), ...
   cosd(90-eko.asel(days)).*(1-[eko.filt_2(days)./eko.pix_2(days)]./k2./Noon_corr(days)),'g+');  legend('filt 2')

figure; plot(1./cosd(90-eko.asel(days)), ...
   cosd(90-eko.asel(days)).*(1-[eko.filt_4(days)./eko.pix_4(days)]./k4./Noon_corr(days)),'r+');  legend('filt 4')

figure; plot(1./cosd(90-eko.asel(days)), ...
   cosd(90-eko.asel(days)).*(1-[eko.filt_5(days)./eko.pix_5(days)]./k5./Noon_corr(days)),'m+');  legend('filt 5')


% End apply fitted corrections

% Next load eko diffuse DFH
% Compute DDR for filt and pix.  No need for k2,k4,k5 but still apply k2 to pix
DDR = rd_eko_tsv;
DDR.filt1 = interp1(DDR.time, DDR.filt_1, eko.time,'linear','extrap');
DDR.filt2 = interp1(DDR.time, DDR.filt_2, eko.time,'linear','extrap');
DDR.filt4 = interp1(DDR.time, DDR.filt_4, eko.time,'linear','extrap');
DDR.filt5 = interp1(DDR.time, DDR.filt_5, eko.time,'linear','extrap');

DDR.pix1 = interp1(DDR.time, DDR.pix_1, eko.time,'linear','extrap');
DDR.pix2 = interp1(DDR.time, DDR.pix_2, eko.time,'linear','extrap');
DDR.pix4 = interp1(DDR.time, DDR.pix_4, eko.time,'linear','extrap');
DDR.pix5 = interp1(DDR.time, DDR.pix_5, eko.time,'linear','extrap');

DDR.pix1(eko.AM) = DDR.pix1(eko.AM).*New_corr(eko.AM); DDR.pix1(eko.PM) = DDR.pix1(eko.PM).*New_corr(eko.PM); 
DDR.pix2(eko.AM) = DDR.pix2(eko.AM).*New_corr(eko.AM); DDR.pix2(eko.PM) = DDR.pix2(eko.PM).*New_corr(eko.PM);
DDR.pix4(eko.AM) = DDR.pix4(eko.AM).*New_corr(eko.AM); DDR.pix4(eko.PM) = DDR.pix4(eko.PM).*New_corr(eko.PM);
DDR.pix5(eko.AM) = DDR.pix5(eko.AM).*New_corr(eko.AM); DDR.pix5(eko.PM) = DDR.pix5(eko.PM).*New_corr(eko.PM);

% Overwrites the above
DDR.pix1 = interp1(DDR.time, DDR.pix_1, eko.time,'linear','extrap');
DDR.pix2 = interp1(DDR.time, DDR.pix_2, eko.time,'linear','extrap');
DDR.pix4 = interp1(DDR.time, DDR.pix_4, eko.time,'linear','extrap');
DDR.pix5 = interp1(DDR.time, DDR.pix_5, eko.time,'linear','extrap');

DDR.pix1(days) = DDR.pix1(days).*Noon_corr(days);
DDR.pix2(days) = DDR.pix2(days).*Noon_corr(days); 
DDR.pix4(days) = DDR.pix4(days).*Noon_corr(days); 
DDR.pix5(days) = DDR.pix5(days).*Noon_corr(days); 

difh.filt4 = eko.filt_4 ./ DDR.filt4; difh.filt5 = eko.filt_5 ./ DDR.filt5;
difh.filt1 = eko.filt_1 ./ DDR.filt1; difh.filt2 = eko.filt_2 ./ DDR.filt2;
difh.pix4 = k4.*eko.pix_4 ./ DDR.pix4; difh.pix5 = k5.*eko.pix_5 ./ DDR.pix5;
difh.pix1 = k1.*eko.pix_1 ./ DDR.pix1; difh.pix2 = k2.*eko.pix_2 ./ DDR.pix2;


%These may look "upside down" but they're correct because we're now assuming
%That the direct beams agree (as demonstrated by the flat comparisons above)
%So we are now interested in the diffuse fields.  Since the diffuse
%Is in the denominator of the DDR, having DDR_eko/DDR_mfr is ~ difh_mfr/difh_eko
DDR_rat_1 = DDR.pix1 ./ DDR.filt1; DDR_rat_2 = DDR.pix2 ./ DDR.filt2; 
DDR_rat_4 = DDR.pix4 ./ DDR.filt4; DDR_rat_5 = DDR.pix5 ./ DDR.filt5; 

figure; plot(eko.time(days), [DDR.filt1(days), DDR.filt2(days), DDR.filt4(days), DDR.filt5(days)],'.'); dynamicDateTicks
%zoom to select Sept 24 solar day
xl_day = xlim; 
day = eko.time>xl_day(1) & eko.time<xl_day(2);

% Let's see the direct beam
figure; plot(eko.time(days), [eko.filt_1(days), eko.pix_1(days).*k1.*Noon_corr(days)],'.')
figure; plot(eko.time(days), [eko.filt_2(days), eko.pix_2(days).*k2.*Noon_corr(days)],'.')
figure; plot(eko.time(days), [eko.filt_4(days), eko.pix_4(days).*k4.*Noon_corr(days)],'.')
figure; plot(eko.time(days), [eko.filt_5(days), eko.pix_5(days).*k5.*Noon_corr(days)],'.')

figure; plot(eko.time(day), [DDR.filt1(day), DDR.filt2(day), DDR.filt4(day), DDR.filt5(day)],'.'); dynamicDateTicks
figure; plot(eko.time(day), [DDR.pix1(day), DDR.pix2(day), DDR.pix4(day), DDR.pix5(day)],'.'); dynamicDateTicks

figure; plot(-(90-eko.asel(eko.AM & day)), DDR_rat_1(eko.AM & day), '+',90-eko.asel(eko.PM & day), DDR_rat_1(eko.PM & day), 'x'); legend('AM filt1','PM filt1')
figure; plot(-(90-eko.asel(eko.AM & day)), DDR_rat_2(eko.AM & day), '+',90-eko.asel(eko.PM & day), DDR_rat_2(eko.PM & day), 'x'); legend('AM filt2','PM filt2')
figure; plot(-(90-eko.asel(eko.AM & day)), DDR_rat_4(eko.AM & day), '+',90-eko.asel(eko.PM & day), DDR_rat_4(eko.PM & day), 'x'); legend('AM filt4','PM filt4')
figure; plot(-(90-eko.asel(eko.AM & day)), DDR_rat_5(eko.AM & day), '+',90-eko.asel(eko.PM & day), DDR_rat_5(eko.PM & day), 'x'); legend('AM filt5','PM filt5')



figure; plot(eko.saz(day), [1.*eko.pix_5(day), 1.*eko.pix_4(day), 1.*eko.pix_2(day), 1.*eko.pix_1(day)],'.'); legend('dirn 5','dirn 4','dirn 2','dirn1');
xlabel('SAZ'); ylabel('dirn EKO raw')
figure; plot(eko.saz(day), [k5.*eko.pix_5(day), k4.*eko.pix_4(day), k2.*eko.pix_2(day), k1.*eko.pix_1(day)],'.'); legend('dirn 5','dirn 4','dirn 2','dirn1');
xlabel('SAZ'); ylabel('dirn EKO')
figure; plot(eko.saz(day), [eko.filt_5(day), eko.filt_4(day), eko.filt_2(day), eko.filt_1(day)],'.'); legend('dirn 5','dirn 4','dirn 2','dirn 1');
xlabel('SAZ'); ylabel('dirn mfrsr')

figure; plot(eko.saz(day), [difh.pix5(day), difh.pix4(day), difh.pix2(day), difh.pix1(day)],'.'); legend('difh 5','difh 4','difh 2','difh1');
xlabel('SAZ'); ylabel('difh EKO')
figure; plot(eko.saz(day), [difh.filt5(day), difh.filt4(day), difh.filt2(day), difh.filt1(day)],'.'); legend('difh 5','difh 4','difh 2','difh 1');
xlabel('SAZ'); ylabel('difh mfrsr')
figure; plot(eko.saz(day), [DDR.pix5(day), DDR.pix4(day), DDR.pix2(day), DDR.pix1(day)],'.'); legend('DDR 5','DDR 4','DDR 2','DDR');
xlabel('SAZ'); ylabel('DDR EKO')
figure; plot(eko.saz(day), [DDR.filt5(day), DDR.filt4(day), DDR.filt2(day), DDR.filt1(day)],'.'); legend('DDR 5','DDR 4','DDR 2','DDR');
xlabel('SAZ'); ylabel('DDR mfrsr')
figure; plot(eko.saz(day), [DDR_rat_5(day),DDR_rat_4(day),DDR_rat_2(day),DDR_rat_1(day)],'*'); legend('rat5','rat4','rat2','rat1');
xlabel('SAZ'); ylabel('DDR eko / DDR mfrsr')

figure; plot(-(90-eko.asel(eko.AM&day)), Noon_corr(eko.AM&day), '+',90-eko.asel(eko.PM&day), Noon_corr(eko.PM&day), 'x'); legend('Noon Corr')

figure; plot(-(90-eko.asel(eko.AM)), DDR_rat_1(eko.AM), '+',90-eko.asel(eko.PM), DDR_rat_1(eko.PM), 'x'); legend('AM filt1','PM filt1')
figure; plot(-(90-eko.asel(eko.AM)), DDR_rat_2(eko.AM), '+',90-eko.asel(eko.PM), DDR_rat_2(eko.PM), 'x'); legend('AM filt2','PM filt2')
figure; plot(-(90-eko.asel(eko.AM)), DDR_rat_4(eko.AM), '+',90-eko.asel(eko.PM), DDR_rat_4(eko.PM), 'x'); legend('AM filt4','PM filt4')
figure; plot(-(90-eko.asel(eko.AM)), DDR_rat_5(eko.AM), '+',90-eko.asel(eko.PM), DDR_rat_5(eko.PM), 'x'); legend('AM filt5','PM filt5')