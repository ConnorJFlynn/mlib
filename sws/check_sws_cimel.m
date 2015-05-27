v2 = read_anet_pp;
%%
   pos = v2.scat_deg>6;
for t = length(v2.time):-1:1

v2.zen_rad(t) = interp1(v2.scat_deg(pos), v2.pp(t,pos)', v2.sza_deg(t), 'linear');
end
%%
k10 = v2.time>datenum(2009,12,31);
jan8 = floor(serial2doy(v2.time))==8
figure; scatter(serial2doy(v2.time(k10)), v2.zen_rad(k10),32,v2.wavelength(k10),'filled'); colorbar
%%
crad = read_cimel_aip; %some tweaks to read
%%
y2010 = crad.time >=datenum(2010,1,0);
figure; plot(crad.time(y2010), [crad.A440nm(y2010)./crad.A870nm(y2010),crad.K440nm(y2010)./crad.K870nm(y2010)],'.');
legend('Arat','Krat')

%%

First, compute SWS responsivity for Si and InGaAs for both calibration trips.
#1 With Optronics
#2 With 30" Labsphere
How different are they?
Compare to previous time series.

Next, for SWS data post September, look at:
   1. Ratio of SWS to Cimel sky radiance as fnt of wavelength, esp 
   before and after February cleaning
   2. Ratio of SWS to Cimel cloud radiance at 440 nm and 870 nm.  See if same 
   scaling between SWS and Cimel at 440 nm applied at 870 nm.
