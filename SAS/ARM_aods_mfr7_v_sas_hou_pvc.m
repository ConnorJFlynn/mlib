% Current situation with HOU comparisons:
% There seemed to be a notable difference in AOD agrreement between 
% MFR and SAS about some date.  
% ARM-processed sas aod look _decent_ AFTER doys(500) (whenever that is)
% Was this an accident to call it "early"?  Did I accidentally select LATE?
% Regardless, there is a distinct difference between the two periods.
% This may be related to banding issues that could be improved using the MFR 
% direct/diffuse approach.  
% What I'll attempt to do today is apply fix_sas_ddr to the ARM processed AOD files
% To do so, I'll read in the sas_filtered mat file and a corresponding data set for
% MFR and run fix_sas_ddr.  Then what?

cim = rd_anetaod_v3;
mfr = load('D:\aodfit_be\hou\houmfrsr7nchaod1michM1.c1.filtered.mat');
sasv = load('D:\aodfit_be\hou\housasvisaodfilt.mat');

mfr = load('D:\aodfit_be\pvc\pvcmfrsraodM1.c1.filt.mat');
sas = load('D:\aodfit_be\pvc\pvcsashevisaodM1.c1.filt.mat');
sas_ = cat_sasnir_wl;
sas = anc_sift(sas, ~any(sas.vdata.aerosol_optical_depth<=0));

[cinm, minc] = nearest(cim.time, mfr.time);
[cins, sinc] = nearest(cim.time, sas.time);
[mins, sinm] = nearest(mfr.time, sas.time);
% Plot sas vs cim and mfrsr to see if there are periods we should exclude as below
figure; scatter(sas.vdata.aerosol_optical_depth(4,sinc), cim.AOD_500nm_AOD(cins),6,serial2doys(sas.time(sinc)));



ij = find(serial2doys(sas.time(sinc))>300 & serial2doys(sas.time(sinc))<600);
cins = cins(ij); sinc = sinc(ij);
[mins, sinm] = nearest(mfr.time, sas.time);
ij = find(serial2doys(sas.time(sinm))>300 & serial2doys(sas.time(sinm))<600);
mins = mins(ij); sinm = sinm(ij);


site_str = ['PVC TCAP: ', datestr(sas.time(sinm(1)),'mmm yyyy - '),datestr(sas.time(sinm(end)),'mmm yyyy')]
site_str = ['HOU TRACER: ', datestr(sas.time(sinm(1)),'mmm yyyy - '),datestr(sas.time(sinm(end)),'mmm yyyy')]
site_str = ['HOU TRACER: ', datestr(sas.time(sinc(1)),'mmm yyyy - '),datestr(sas.time(sinc(end)),'mmm yyyy')]


X = cim.AOD_500nm_AOD(cinm);
Y = mfr.vdata.aerosol_optical_depth_filter2(minc);
x_str = 'Cimel AOD'; y_str = 'MFRSR AOD'; t_str = 'Aerosol Optical Depth 500 nm';

X = cim.AOD_675nm_AOD(cinm);
Y = mfr.vdata.aerosol_optical_depth_filter4(minc);
x_str = 'Cimel AOD'; y_str = 'MFRSR AOD'; t_str = 'Aerosol Optical Depth 675 nm';

X = cim.AOD_870nm_AOD(cinm);
Y = mfr.vdata.aerosol_optical_depth_filter5(minc);
x_str = 'Cimel AOD'; y_str = 'MFRSR AOD'; t_str = 'Aerosol Optical Depth 870 nm';



X = cim.AOD_380nm_AOD(cins);
Y = sas.vdata.aerosol_optical_depth(1,sinc);
x_str = 'Cimel AOD'; y_str = 'SASHe AOD'; t_str = 'Aerosol Optical Depth 380 nm';

X = cim.AOD_440nm_AOD(cins);
Y = sas.vdata.aerosol_optical_depth(3,sinc);
x_str = 'Cimel AOD'; y_str = 'SASHe AOD'; t_str = 'Aerosol Optical Depth 440 nm';

X = cim.AOD_500nm_AOD(cins);
Y = sas.vdata.aerosol_optical_depth(4,sinc);
x_str = 'Cimel AOD'; y_str = 'SASHe AOD'; t_str = 'Aerosol Optical Depth 500 nm';

X = cim.AOD_675nm_AOD(cins);
Y = sas.vdata.aerosol_optical_depth(6,sinc);
x_str = 'Cimel AOD'; y_str = 'SASHe AOD'; t_str = 'Aerosol Optical Depth 675 nm';

X = cim.AOD_870nm_AOD(cins);
Y = sas.vdata.aerosol_optical_depth(7,sinc);
x_str = 'Cimel AOD'; y_str = 'SASHe AOD'; t_str = 'Aerosol Optical Depth 870 nm';



X = mfr.vdata.aerosol_optical_depth_filter1(mins);
Y = sas.vdata.aerosol_optical_depth(2,sinm);
x_str = 'MFRSR AOD'; y_str = 'SASHe AOD'; t_str = 'Aerosol Optical Depth 415 nm';

X = mfr.vdata.aerosol_optical_depth_filter2(mins);
Y = sas.vdata.aerosol_optical_depth(4,sinm);
x_str = 'MFRSR AOD'; y_str = 'SASHe AOD'; t_str = 'Aerosol Optical Depth 500 nm';

X = mfr.vdata.aerosol_optical_depth_filter3(mins);
Y = sas.vdata.aerosol_optical_depth(5,sinm);
x_str = 'MFRSR AOD'; y_str = 'SASHe AOD'; t_str = 'Aerosol Optical Depth 615 nm';

X = mfr.vdata.aerosol_optical_depth_filter4(mins);
Y = sas.vdata.aerosol_optical_depth(6,sinm);
x_str = 'MFRSR AOD'; y_str = 'SASHe AOD'; t_str = 'Aerosol Optical Depth 673 nm';

X = mfr.vdata.aerosol_optical_depth_filter5(mins);
Y = sas.vdata.aerosol_optical_depth(7,sinm);
x_str = 'MFRSR AOD'; y_str = 'SASHe AOD'; t_str = 'Aerosol Optical Depth 870 nm';

% Evaluate from here...
if size(X,1)==size(Y,2); Y = Y'; end
bad = X<=0 | Y<=0; X(bad) =[]; Y(bad) = [];
D = den2plot(X,Y);
figure; scatter(X, Y,6,log10(D)); colormap(comp_map_w_jet);
xlabel(x_str); ylabel(y_str); title({site_str; t_str})
 xl = xlim; yl = ylim; xlim([0,round(10.*min([xl(2),yl(2)]))./10]);ylim(xlim); axis('square');
hold('on'); xl = xlim; li = plot(xl, xl, 'k:','linewidth',4); hold('off')

[good, P_bar] = rbifit(X,Y,4,0); hold('on');  plot(xl,polyval(P_bar,xl),'b-', 'linewidth',3); hold('off')

[gt,txt, stats] = txt_stat(X(good), Y(good),P_bar); set(gt,'color','b');
gt.Units = 'Normalized'; gt.Position = round(gt.Position.*10)./10;

% ... to here
xl = xlim; yl = ylim; xlim([0,round(10.*min([xl(2),yl(2)]))./10]);ylim(xlim); axis('square');

[gt,txt, stats] = txt_stat(X, Y,P_bar); set(gt,'color','b');


% We could:
% A. Show agreement between Csphot and Anet at 500, 675, and 870
% B. Show corresponding agreement between CSPHOT and SAS at 
