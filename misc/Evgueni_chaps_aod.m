mfr = ancload;
nimfr = ancload;
%%
anet_v1p5 = read_cimel_aod;
 anet_v2 = read_cimel_aod;
%%

xl1 =[163,dd+1];
xl2 =[174,175];
eps = 1e-3;
good_nimfr = nimfr.vars.variability_flag.data<eps;
good = mfr.vars.variability_flag.data<eps;
pos = mfr.vars.aerosol_optical_depth_filter2.data>0;
figure;
plot(serial2doy(mfr.time(pos)), mfr.vars.aerosol_optical_depth_filter2.data(pos), 'r.',...
serial2doy(mfr.time(good)), mfr.vars.aerosol_optical_depth_filter2.data(good), 'g.',...
   serial2doy(nimfr.time(good_nimfr)), nimfr.vars.aerosol_optical_depth_filter2.data(good_nimfr),'b.',...
serial2doy(anet_v1p5.time), anet_v1p5.AOT_500, 'ko',...
serial2doy(anet_v2.time), anet_v2.AOT_500, 'go');
lg = legend('raw','mfrsr','nimfr','anet v1.5','anet v2')
sb(1) = gca;
xlabel('day of year')
ylabel('AOD 500 nm')
xlim(xl1)
figure;
plot(serial2doy(mfr.time(pos)), mfr.vars.aerosol_optical_depth_filter2.data(pos), 'r.',...
serial2doy(mfr.time(good)), mfr.vars.aerosol_optical_depth_filter2.data(good), 'g.',...
   serial2doy(nimfr.time(good_nimfr)), nimfr.vars.aerosol_optical_depth_filter2.data(good_nimfr),'b.',...
serial2doy(anet_v1p5.time), anet_v1p5.AOT_500, 'ko',...
serial2doy(anet_v2.time), anet_v2.AOT_500, 'go');
sb(2)=gca;
lg = legend('raw','mfrsr','nimfr','anet v1.5','anet v2')
% set(lg,'location','EastOutside')
xlabel('day of year')
ylabel('AOD 500 nm')
xlim(xl2);
linkaxes(sb,'y')

%%
% Custom screen MFRSR for June 12
%%
good = mfr.vars.total_optical_depth_filter5.data>0 & mfr.vars.total_optical_depth_filter5.data<1;
ii = 0
v = axis;
%
%%
for x = 1:6
ii = ii+1;
[good(good)] = hmadf_span(mfr.vars.total_optical_depth_filter5.data(good), 20, 2);
sum_good(ii) = sum(good);
disp(num2str(sum(good)));
semilogy(serial2Hh(mfr.time),  mfr.vars.total_optical_depth_filter5.data,'r.',serial2Hh(mfr.time(good)),  mfr.vars.total_optical_depth_filter5.data(good),'b.'); 
title(['Iterations = ',num2str(ii),'  good = ',num2str(sum(good))])
% axis(v)
pause(.125)
end

for d = floor(mfr.time(end)):-1:floor(mfr.time(1))
   disp(['Day ',num2str(d-floor(mfr.time(1)))])
   day = (mfr.time>=d)&(mfr.time<(d+1))&(mfr.vars.total_optical_depth_filter5.data>0)...
      &isfinite(mfr.vars.total_optical_depth_filter5.data);
   if sum(day)>0
   good(day) =post_screen(serial2doy(mfr.time(day)), mfr.vars.total_optical_depth_filter2.data(day), good(day),10,.125);
   end
end
semilogy(serial2Hh(mfr.time),  mfr.vars.total_optical_depth_filter5.data,'r.',serial2Hh(mfr.time(good)),  mfr.vars.total_optical_depth_filter5.data(good),'b.'); 
title(['Iterations = ',num2str(ii),'  good = ',num2str(sum(good))])
% axis(v)
%%
post_good = good;
eps_thresh = 4e-3;
[aero(good), eps, aero_eps, mad, abs_dev] = aod_screen(serial2doy(mfr.time(good)), mfr.vars.total_optical_depth_filter5.data(good),0, .5,15, 3, eps_thresh,20,20,.05);
figure; plot(serial2Hh(mfr.time(good)), mfr.vars.total_optical_depth_filter5.data(good),'b.',serial2Hh(mfr.time(aero)), mfr.vars.total_optical_depth_filter5.data(aero),'g.'); title(['good = ',num2str(sum(eps<eps_thresh))]);
aero_ii =find(aero);
axis(v)
%%
figure; sb(1) = subplot(2,1,1); plot(serial2Hh(mfr.time(aero)), mfr.vars.aerosol_optical_depth_filter2.data(aero),'g.',serial2Hh(mfr.time(aero)), mfr.vars.aerosol_optical_depth_filter5.data(aero),'r.'); 
sb(2) = subplot(2,1,2); plot(serial2Hh(mfr.time(aero)), mfr.vars.angstrom_exponent.data(aero),'k.')
linkaxes(sb,'x')
%%
good = aero;


%%
%%
dd = 163;
mfr_day = (serial2doy(mfr.time)>=dd)&(serial2doy(mfr.time)<=dd+1)&good;
nim_day = (serial2doy(nimfr.time)>=dd)&(serial2doy(nimfr.time)<=dd+1); % &good_nimfr;
% anet1_day = (serial2doy(anet_v1p5.time)>=dd)&(serial2doy(anet_v1p5.time)<=dd+1);
% anet2_day =(serial2doy(anet_v2.time)>=dd)&(serial2doy(anet_v2.time)<=dd+1);
mfr_day_ii = find(mfr_day);
nim_day_ii = find(nim_day);
[ainb,bina] = nearest(mfr.time(mfr_day_ii), nimfr.time(nim_day_ii));
%%
[pname,fname] = fileparts(mfr.fname);
V = datevec(mfr.time(mfr_day_ii(ainb)));
yyyy = V(:,1);
mm = V(:,2);
dd = V(:,3);
HH = V(:,4);
MM = V(:,5);
SS = V(:,6);
doy = serial2doy(mfr.time(mfr_day_ii(ainb)))';
HHhh = (doy - floor(doy)) *24;
% txt_out needs to be composed of data oriented as column vectors.
txt_out = [yyyy, mm, dd, doy, HHhh, ...
mfr.vars.aerosol_optical_depth_filter2.data(mfr_day_ii(ainb))', ...
mfr.vars.aerosol_optical_depth_filter5.data(mfr_day_ii(ainb))', ...
mfr.vars.angstrom_exponent.data(mfr_day_ii(ainb))',...
nimfr.vars.aerosol_optical_depth_filter2.data(nim_day_ii(bina))', ...
nimfr.vars.aerosol_optical_depth_filter5.data(nim_day_ii(bina))', ...
nimfr.vars.angstrom_exponent.data(nim_day_ii(bina))' ];

header_row = ['yyyy, mm, dd, day_of_year, HHhh_UTC, '];
header_row = [header_row, 'AOD_500_mfr, AOD_870_mfr, '];
header_row = [header_row, 'Angstrom_500_870_mfr '];
header_row = [header_row, 'AOD_500_nimfr, AOD_870_nimfr, '];
header_row = [header_row, 'Angstrom_500_870_nimfr '];

format_str = ['%d, %d, %d, %3.6f, %3.6f, %2.3f, %2.3f, %2.3f, %2.3f, %2.3f, %2.3f \n'];
%%

fid = fopen([pname,filesep,'..',filesep,'mfr_and_nimfr.txt'],'wt');
fprintf(fid,'%s \n',header_row );

fprintf(fid,format_str,txt_out');
fclose(fid);

