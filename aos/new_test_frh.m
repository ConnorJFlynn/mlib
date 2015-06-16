function status = new_test_frh();
fitrh_path = 'C:\case_studies\aip\fitrh\new\';
[fname] = getfullname([fitrh_path,'*.cdf'],'fitrh');
fitrh = ancload(fname);
[pname, fname,ext] = fileparts(fitrh.fname);
pname = [pname, filesep];
[tmp,rest] = strtok(fname,'.');[tmp,rest] = strtok(rest,'.');[tmp,rest] = strtok(rest,'.');

%%
aos = ancload([pname,['sgpnoaaaosC1.b0.',tmp,'.000000.cdf']]);
aip = ancload([pname,['sgpaip1ogrenC1.c1.',tmp,'.000000.cdf']]);
% aosavg = ancload([fitrh_path,'*.cdf']);



%%
good_T = aos.vars.T_MainInlet.data>-90 & aos.vars.T_NephVol_Dry.data>-90 & aos.vars.T_preHG.data>-90 & aos.vars.T_postHG.data>-90 & aos.vars.T_NephVol_Wet.data>-90;
aos.vars.T_MainInlet.data(~good_T) = NaN;
aos.vars.T_NephVol_Dry.data(~good_T) = NaN;
aos.vars.T_preHG.data(~good_T) = NaN;
aos.vars.T_postHG.data(~good_T) = NaN;
aos.vars.T_NephVol_Wet.data(~good_T)= NaN;
good_RH = aos.vars.RH_MainInlet.data>0 & aos.vars.RH_NephVol_Dry.data>0 & aos.vars.RH_preHG.data>0 & aos.vars.RH_postHG.data>0 & aos.vars.RH_NephVol_Wet.data>0;
aos.vars.RH_MainInlet.data(~good_RH) = NaN;
aos.vars.RH_NephVol_Dry.data(~good_RH) = NaN;
aos.vars.RH_preHG.data(~good_RH) = NaN;
aos.vars.RH_postHG.data(~good_RH) = NaN;
aos.vars.RH_NephVol_Wet.data(~good_RH)= NaN;
%%
figure(9)
subplot(2,1,1); 
plot(serial2Hh(aos.time), [aos.vars.T_MainInlet.data; aos.vars.T_NephVol_Dry.data; aos.vars.T_preHG.data; aos.vars.T_postHG.data; aos.vars.T_NephVol_Wet.data],'-');
ylabel('Celcius')
lg_top = legend('MainInlet','NephVol_Dry','preHG','postHG','NephVol_Wet');
set(lg_top,'interp','none')
subplot(2,1,2); 
plot(serial2Hh(aos.time), [aos.vars.RH_MainInlet.data; aos.vars.RH_NephVol_Dry.data; aos.vars.RH_preHG.data; aos.vars.RH_postHG.data; aos.vars.RH_NephVol_Wet.data],'-');
ylabel('% RH')
lg_bot = legend('MainInlet','NephVol_Dry','preHG','postHG','NephVol_Wet');
set(lg_bot,'interp','none')
xlabel('UTC (hours)')
%%
figure(9)
size_1 = aos.vars.Bbs_B_Wet_1um_Neph3W_2.data>-900;
size_10 = aos.vars.Bbs_B_Wet_10um_Neph3W_2.data>-900;
plot(serial2Hh(aos.time(size_1)), [aos.vars.Bbs_B_Wet_1um_Neph3W_2.data(size_1)],'r-',...
   serial2Hh(aos.time(size_10)), [aos.vars.Bbs_B_Wet_10um_Neph3W_2.data(size_10)],'b-')
   title('Blue Bbs')
%%
figure(9)
size_1 = aos.vars.Bbs_G_Wet_1um_Neph3W_2.data>-900;
size_10 = aos.vars.Bbs_G_Wet_10um_Neph3W_2.data>-900;
plot(serial2Hh(aos.time(size_1)), [aos.vars.Bbs_G_Wet_1um_Neph3W_2.data(size_1)],'r-',...
   serial2Hh(aos.time(size_10)), [aos.vars.Bbs_G_Wet_10um_Neph3W_2.data(size_10)],'b-')
title('Green Bbs')
%%
figure(9)
size_1 = aos.vars.Bbs_R_Wet_1um_Neph3W_2.data>-900;
size_10 = aos.vars.Bbs_R_Wet_10um_Neph3W_2.data>-900;
plot(serial2Hh(aos.time(size_1)), [aos.vars.Bbs_R_Wet_1um_Neph3W_2.data(size_1)],'r-',...
   serial2Hh(aos.time(size_10)), [aos.vars.Bbs_R_Wet_10um_Neph3W_2.data(size_10)],'b-')
title('Red Bbs')
%%
figure(10);
subplot(2,1,1);
plot(serial2Hh(fitrh.time), [ fitrh.vars.Bbs_B_Dry_1um_min.data; fitrh.vars.Bbs_B_Dry_10um_min.data;...
   fitrh.vars.Bbs_G_Dry_1um_min.data; fitrh.vars.Bbs_G_Dry_10um_min.data;...
   fitrh.vars.Bbs_R_Dry_1um_min.data; fitrh.vars.Bbs_R_Dry_10um_min.data],'-'); 
title('Dry Bbs min values')
leg_top = legend('B_1um','B_10um', 'G_1um','G_10um', 'R_1um','R_10um'); set(leg_top,'interp','none')
subplot(2,1,2);
plot(serial2Hh(fitrh.time), [ fitrh.vars.Bbs_B_Dry_1um_max.data; fitrh.vars.Bbs_B_Dry_10um_max.data;...
   fitrh.vars.Bbs_G_Dry_1um_max.data; fitrh.vars.Bbs_G_Dry_10um_max.data;...
   fitrh.vars.Bbs_R_Dry_1um_max.data; fitrh.vars.Bbs_R_Dry_10um_max.data],'-'); 
title('Dry Bbs max values')
leg_bot = legend('B_1um','B_10um', 'G_1um','G_10um', 'R_1um','R_10um'); set(leg_bot,'interp','none')
%%
figure(11);
subplot(2,1,1);
plot(serial2Hh(fitrh.time), [ fitrh.vars.Bbs_B_Wet_1um_min.data; fitrh.vars.Bbs_B_Wet_10um_min.data;...
   fitrh.vars.Bbs_G_Wet_1um_min.data; fitrh.vars.Bbs_G_Wet_10um_min.data;...
   fitrh.vars.Bbs_R_Wet_1um_min.data; fitrh.vars.Bbs_R_Wet_10um_min.data],'-'); 
title('Wet Bbs min values')
leg_top = legend('B_1um','B_10um', 'G_1um','G_10um', 'R_1um','R_10um'); set(leg_top,'interp','none')
subplot(2,1,2);
plot(serial2Hh(fitrh.time), [ fitrh.vars.Bbs_B_Wet_1um_max.data; fitrh.vars.Bbs_B_Wet_10um_max.data;...
   fitrh.vars.Bbs_G_Wet_1um_max.data; fitrh.vars.Bbs_G_Wet_10um_max.data;...
   fitrh.vars.Bbs_R_Wet_1um_max.data; fitrh.vars.Bbs_R_Wet_10um_max.data],'-'); 
title('Wet Bbs max values')
leg_bot = legend('B_1um','B_10um', 'G_1um','G_10um', 'R_1um','R_10um'); set(leg_bot,'interp','none')
%%
close('all');
for t = 1:length(fitrh.time);

   %    t = 1;
   sz = {'1', '10'};
   wl = {'B','G','R'};
   B_ = {'Bs','Bbs'};
   b = B_(1);
   for s = sz
      fig = 0;
      for w = wl
         fig = fig +1;
         wet = [b{:},'_',w{:},'_Wet_',s{:},'um_Neph3W_2'];
         dry = [b{:},'_',w{:},'_Dry_',s{:},'um_Neph3W_1'];
         rat = ['Wet_Dry_Ratio_',b{:},'_',w{:},'_',s{:},'um_Neph3W'];
         aos_times = ((aos.time >= fitrh.time(t))& (serial2Hh(aos.time)<(serial2Hh(fitrh.time(t))+1))&...
            (aos.vars.RH_NephVol_Wet.data>30)&(aos.vars.RH_NephVol_Wet.data<95)&...
            (aos.vars.(dry).data>0)&...
            (aos.vars.(wet).data>0));
         aip_times = ((aip.time >= fitrh.time(t))& (serial2Hh(aip.time)<(serial2Hh(fitrh.time(t))+1))&...
            (aip.vars.RH_NephVol_Wet.data>30)&(aip.vars.RH_NephVol_Wet.data<95)&...
            (aip.vars.(dry).data>0)&(aip.vars.(wet).data>0));            
%          rh_for_fit = aos.vars.RH_NephVol_Wet.data(aos_times);
%          obs = aos.vars.(wet).data(aos_times)./aos.vars.(dry).data(aos_times);
         rh_for_fit = aip.vars.calculated_RH_NephVol_Wet.data(aip_times);
         obs = aip.vars.(rat).data(aip_times);
 
         [fit_2p_a, fit_2p_b,rsqr_corh_2p,dry_RH_corh_2p] = fitcorh_2p(rh_for_fit,obs);
         [under_P,rsqr_under,under_rh_dry] = fitrh_under_corh(rh_for_fit,obs,2);
         a_2p = fitrh.vars.(['fRH_',b{:},'_',w{:},'_',s{:},'um_2p']).data(1,t);
         b_2p = fitrh.vars.(['fRH_',b{:},'_',w{:},'_',s{:},'um_2p']).data(2,t);
         [tmp,rh_dry_2p] = fitrh_2p(rh_for_fit,a_2p,b_2p);
         rsqr_2p= R_squared(obs, tmp);
          
         a_3p = fitrh.vars.(['fRH_',b{:},'_',w{:},'_',s{:},'um_3p']).data(1,t);
         b_3p = fitrh.vars.(['fRH_',b{:},'_',w{:},'_',s{:},'um_3p']).data(2,t);
         c_3p = fitrh.vars.(['fRH_',b{:},'_',w{:},'_',s{:},'um_3p']).data(3,t);
         [fit_3p,rh_dry_3p] = fitrh_3p(rh_for_fit,a_3p,b_3p,c_3p);
         rh_dry_3p = real(rh_dry_3p);
         rsqr_3p= R_squared(obs,fit_3p );
         

         frh_noaa_2p = fitrh_2p(rh_for_fit,a_2p,b_2p);
         frh_flynn_2p = fitrh_2p(rh_for_fit,fit_2p_a,fit_2p_b);
         frh_noaa_3p = fitrh_3p(rh_for_fit,a_3p,b_3p,c_3p);
         frh_flynn_under_corh = polyval(under_P, 1./(1-rh_for_fit./100));
         disp(['NOAA 2p dry RH=',num2str(rh_dry_2p),'%, R-squared=',num2str(rsqr_2p)]);
         disp(['NOAA 3p dry RH=',num2str(rh_dry_3p),'%, R-squared=',num2str(rsqr_3p)]);
         disp(['Flynn 2p dry RH=',num2str(dry_RH_corh_2p),'%, R-squared=',num2str(rsqr_corh_2p)]);
         disp(['Flynn under_coRH dry RH=',num2str(under_rh_dry),'%, R-squared=',num2str(rsqr_under)]);

         %%
         figure(77); 
         plot(rh_for_fit/100, obs, 'ro',...
            rh_for_fit/100, [frh_noaa_2p;  frh_flynn_2p;frh_noaa_3p; frh_flynn_under_corh],'-');
         xlabel('rh%/100'); ylabel('frh'); title(rat,'interp','none');
         lg = legend('wet/dry ratio','NOAA 2p','Flynn 2p fit to log-log','NOAA 3p','Flynn fit to 1/coRH');
         set(lg,'location','northwest');
         figure(78); 
         plot(1./(1-rh_for_fit/100), obs, 'ro',...
            1./(1-rh_for_fit/100), [frh_noaa_2p; frh_flynn_2p;frh_noaa_3p; frh_flynn_under_corh],'-');
         xlabel('1 / corh'); ylabel('frh'); title(rat,'interp','none');
         lg = legend('wet/dry ratio','NOAA 2p','Flynn 2p fit to log-log','NOAA 3p','Flynn fit to 1/coRH');
          set(lg,'location','northwest');
          disp(['.']);
         %%

      end
   end
%    %%
%    figure(88);
%    plot(serial2Hh(fitrh.time), ...
%       [fitrh.vars.fRH_Bs_B_10um_3p_r_square.data; ...
%       fitrh.vars.fRH_Bs_G_10um_3p_r_square.data; ...
%       fitrh.vars.fRH_Bs_R_10um_3p_r_square.data],'o', ...
%       serial2Hh(fitrh.time), ...
%       [fitrh.vars.fRH_Bs_B_1um_3p_r_square.data; ...
%       fitrh.vars.fRH_Bs_G_1um_3p_r_square.data; ...
%       fitrh.vars.fRH_Bs_R_1um_3p_r_square.data;...
%       ],...
%       '.');
%    legend('B_10','G_10','R_10','B_1','G_1','R_1')
   %%
      b = B_(2);
   for s = sz
      fig = 0;
      for w = wl
         fig = fig +1;
         wet = [b{:},'_',w{:},'_Wet_',s{:},'um_Neph3W_2'];
         dry = [b{:},'_',w{:},'_Dry_',s{:},'um_Neph3W_1'];
         %          aos_times = ((aos.time >= fitrh.time(t))& (serial2Hh(aos.time)<(serial2Hh(fitrh.time(t))+1))&...
         %             (aos.vars.RH_NephVol_Wet.data>30)&(aos.vars.RH_NephVol_Wet.data<95)&...
         %             (aos.vars.(dry).data>0)&...
         %             (aos.vars.(wet).data>0));
         %          rh_for_fit = aos.vars.RH_NephVol_Wet.data(aos_times);
         %          obs = aos.vars.(wet).data(aos_times)./aos.vars.(dry).data(aos_times);
         %                   aip_times = ((aip.time >= fitrh.time(t))& (serial2Hh(aip.time)<(serial2Hh(fitrh.time(t))+1))&...
         %             (aip.vars.RH_NephVol_Wet.data>30)&(aip.vars.RH_NephVol_Wet.data<95)&...
         %             (aip.vars.(dry).data>0)&(aip.vars.(wet).data>0));
         %          rh_for_fit = aos.vars.RH_NephVol_Wet.data(aos_times);
         %          obs = aos.vars.(wet).data(aos_times)./aos.vars.(dry).data(aos_times);
         
         rat = ['Wet_Dry_Ratio_',b{:},'_',w{:},'_',s{:},'um_Neph3W'];
         aip_times = ((aip.time >= fitrh.time(t))& (serial2Hh(aip.time)<(serial2Hh(fitrh.time(t))+1))&...
            (aip.vars.RH_NephVol_Wet.data>30)&(aip.vars.RH_NephVol_Wet.data<95)&...
            (aip.vars.(dry).data>0)&(aip.vars.(wet).data>0));
         rh_for_fit = aip.vars.calculated_RH_NephVol_Wet.data(aip_times);
         obs = aip.vars.(rat).data(aip_times);
         [fit_2p_a, fit_2p_b,rsqr_corh_2p,dry_RH_corh_2p] = fitcorh_2p(rh_for_fit,obs);
         [under_P,rsqr_under,under_rh_dry] = fitrh_under_corh(rh_for_fit,obs,2);
         a_2p = fitrh.vars.(['fRH_',b{:},'_',w{:},'_',s{:},'um_2p']).data(1,t);
         b_2p = fitrh.vars.(['fRH_',b{:},'_',w{:},'_',s{:},'um_2p']).data(2,t);
         [tmp,rh_dry_2p] = fitrh_2p(rh_for_fit,a_2p,b_2p);
         rsqr_2p= R_squared(obs, tmp);
          
         frh_noaa_2p = fitrh_2p(rh_for_fit,a_2p,b_2p);
         frh_flynn_2p = fitrh_2p(rh_for_fit,fit_2p_a,fit_2p_b);
         frh_flynn_under_corh = polyval(under_P, 1./(1-rh_for_fit./100));
         disp(['NOAA 2p dry RH=',num2str(rh_dry_2p),'%, R-squared=',num2str(rsqr_2p)]);
         disp(['Flynn 2p dry RH=',num2str(dry_RH_corh_2p),'%, R-squared=',num2str(rsqr_corh_2p)]);
         disp(['Flynn under_coRH dry RH=',num2str(under_rh_dry),'%, R-squared=',num2str(rsqr_under)]);
         %%

                  %%
         figure(77); 
         plot(rh_for_fit/100, obs, 'ro',...
            rh_for_fit/100, [frh_noaa_2p;frh_flynn_2p; frh_flynn_under_corh],'-');
         xlabel('rh%/100'); ylabel('frh'); title(rat,'interp','none');
         lg = legend('wet/dry ratio','NOAA 2p','Flynn 2p fit to log-log','Flynn fit to 1/coRH');
         set(lg,'location','northwest');
         figure(78); 
         plot(1./(1-rh_for_fit/100), obs, 'ro',...
            1./(1-rh_for_fit/100), [frh_noaa_2p; frh_flynn_2p; frh_flynn_under_corh],'-');
         xlabel('1 / corh'); ylabel('frh'); title(rat,'interp','none');
         lg = legend('wet/dry ratio','NOAA 2p','Flynn 2p fit to log-log','Flynn fit to 1/coRH');
         set(lg,'location','northwest');
         disp(['.']);
         %%

      end
   end

   %          figure(blue_2p);
   %          plot(rh_for_fit, aos.vars.(wet).data(aos_times)./aos.vars.(dry).data(aos_times), '.',...
   %             rh, [fit_2p, fit_2p_pda,fit_2p_mda,fit_2p_pdb,fit_2p_mdb]);
   %          legend('data points','2P','+da', '-da','+db','-db')
   %
   %          figure(blue_3p);
   %          plot(rh_for_fit, aos.vars.(wet).data(aos_times)./aos.vars.(dry).data(aos_times), '.',...
   %             rh, [fit_3p, fit_3p_pda,fit_3p_mda,fit_3p_pdb,fit_3p_mdb,fit_3p_pdc,fit_3p_mdc]);
   %          legend('data points','3P','+da', '-da','+db','-db','+dc','-dc')
   %
   
   %%
   
   %     a = fitrh.Blue_fRH_3param_p1_1um(t);
   %     b = fitrh.Blue_fRH_3param_p2_1um(t);
   %     c = fitrh.Blue_fRH_3param_p3_1um(t);
   %     da = fitrh.Blue_fRH_3param_stddev_p1_1um(t);
   %     db = fitrh.Blue_fRH_3param_stddev_p2_1um(t);
   %     dc = fitrh.Blue_fRH_3param_stddev_p3_1um(t);
   %          [fit_3p, fit_3p_err] = frh_3p(rh, a_3p, b_3p, c_3p, da_3p, db_3p, dc_3p);
   %          %     [fit_3p_ldc, fit_3p_err_ldc] = frh_3p([30:5:85]', a, b, c-dc, da, db, dc);
   %          %     [fit_3p_pdc, fit_3p_err_pdc] = frh_3p([30:5:85]', a, b, c+dc, da, db, dc);
   %          %%
   %          figure(blue);
   %          aos_times = ((aos.time >= fitrh.time(t))& (serial2Hh(aos.time)<(serial2Hh(fitrh.time(t))+1))&(aos.vars.RH_NephVol_Wet.data>30)&(aos.vars.RH_NephVol_Wet.data<95)&(aos.vars.Bs_B_Dry_10um_Neph3W_1.data>0)&(aos.vars.Bs_B_Wet_10um_Neph3W_2.data>0));
   %          plot(aos.vars.RH_NephVol_Wet.data(aos_times), aos.vars.Bs_B_Wet_10um_Neph3W_2.data(aos_times)./aos.vars.Bs_B_Dry_10um_Neph3W_1.data(aos_times), '.', rh, [fit_2p, fit_3p]);
   %          legend('data points','2P','3P')
end


status = 1;
return
%%

function [frh, frh_err] = frh_2p(rh, a, b, da, db);
%[frh, frh_err] = frh_2p(rh, a, b, da, db);
% Evaluates CMDL two-parameter fit for frh and calculates error estimate
% using returned sigmas for da and db and partial derivatives
% frh = a *((1-rh)^(-b))
% d(frh)/da = da * (1-rh)^(-b)
% d(frh)/db = frh * (-log(1-rh)) * db
if rh > 1
    rh = rh/100;
end
coh = (1-rh);
frh = a * (coh.^(-b));
pder_1 = da * (coh .^(-b));
pder_2 = db .* frh .* (-1*log(coh));
frh_err = sqrt(pder_1.^2 + pder_2.^2);

return


function [frh, frh_err] = frh_3p(rh, a, b, c,  da, db, dc);
%[frh, frh_err] = frh_3p(rh, a, b, c,  da, db, dc);
% Evaluates CMDL three-parameter fit for frh and calculates error estimate
% using returned sigmas and partial derivatives
% frh = a .* (1 + b .* (rh.^c));
% d(frh)/da = 1 + b .* (rh.^c);
% d(frh)/db = a .* (rh.^c);
% d(frh)/dc = a .* b .* (rh.^c) .* log(rh);

if rh > 1
    rh = rh/100;
end
frh = a .* (1 + b .* (rh.^c));
pder_1 = da .* (1 + b .* (rh.^c));
pder_2 = db .* a .* (rh.^c);
pder_3 = dc .* (a .* b .* (rh.^c) .* log(rh));
frh_err = sqrt(pder_1.^2 + pder_2.^2 + pder_3.^2);
return

