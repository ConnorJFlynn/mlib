%calls routine King_CLI and uses
%sigeps,cnstrmtx,mie_par,mie,vek_mult,mie_test, yerrorbar
clear
clear global
close all
global nigamsv ggamsv Q1sv Q2sv Qsv fsv dnlgrsv uncdnlgrsv dnrsv uncdnrsv taucsv
global relerr dndlgrsav radcalc r3mom r2mom reff colvolume colsfcarea
global taunumint tausum nustar rg_coarse rg_fine sigext rad_bound_fine
flag_write_results='true';
flag_save='false';
flag_plot_tau='true';		%figure 1
flag_plot_dndlogr='true';	%figure 2
flag_plot_dSdlogr='true';	%figure 3
flag_plot_Q='false';			%figs 4-6
flag_plot_f='false';			%figs 7-9
flag_plot_contrib='true';	%figs 10-12
filesave='CLIsave.sav';
mode=1; %mode in King mode=0 is not fully implemented yet
iread_sigext=0;		%=0 perform Mie scat calcs; =1 perform Mie calcs and write file; =2 reads file of Mie calcs, but performs no calculations
flag_kingstop1=0;		%for debug purposes only
%lambda_AATS14=[380.3 448.25 452.97 499.4 524.7 605.4 666.8 711.8 778.5 864.4 939.5 1018.7 1059.0 1557.5]/1000;%ACE-2
lambda_AATS14= [0.3535 0.3800 0.4490 0.4994 0.5246 0.6057 0.6751 0.7784 0.8645 1.0191 1.2413 1.5574]% SAFARI-2000
lambda_AATS6=[380.1 450.7 525.3 863.9 941.5 1020.7]/1000;
%refrac_idx=1.55-0.0050i;     % index of refraction for Sahara Dust %Patterson
%refrac_idx=1.4 -0.0035i;     % index of refraction for MBL % Tanre
refrac_idx=1.51 -0.021i;     % index of refraction for Biomass Burning Aerosols Afrcan Savanna Zambia (Dubovik JAS 2002)
r_min=0.05; % minimum radius
r_max=4;  % maximum radius
n_coarse_rad_bin=15; %number of coarse radii bins
nitermax = 8;
%following for SAFARI-2000 Aug 17 smoke plume
%lambda=lambda_AATS14;  %select wavelengths to be used in CLI
%taup_meas=    [3.8207    3.4309    2.4155    1.8635    1.6744    1.1734    0.8935 0.6282    0.4843    0.3196    0.2027    0.1245]';
%unc_taup_meas=[0.05       0.04       0.0454    0.0313    0.0458    0.0284    0.0053 0.0037    0.0041    0.0035    0.0042    0.0094]';
%date_text='AATS-14, 17 Aug 2000, Smoke Plume';
 
%following for SAFARI-2000 Aug 17 outside of smoke plume 0.05 to 4
lambda=lambda_AATS14;  %select wavelengths to be used in CLI
taup_meas=     [ 0.0869    0.0761    0.0646    0.0538    0.0559    0.0403    0.0334  0.0314    0.0305    0.0267    0.0263    0.0228]';
unc_taup_meas=[     0.0122    0.0190    0.0227    0.0260    0.0446    0.0283    0.0048    0.0034    0.0040    0.0035    0.0095    0.0095]';
date_text='AATS-14, 17 Aug 2000, Outside of Smoke Plume';
%following for SAFARI-2000 Aug 17 just smoke plume delta AOD 0.05 to 1.0 works fine
%lambda=lambda_AATS14;  %select wavelengths to be used in CLI
%taup_meas=     [3.7338    3.3548    2.3509    1.8097    1.6185    1.1331    0.8601   0.5968    0.4538    0.2929    0.1764    0.1017]';
%unc_taup_meas= [0.05     0.05     0.05     0.05     0.05     0.04     0.03    0.02     0.01     0.01     0.01     0.01]';
%date_text='AATS-14, 17 Aug 2000, Smoke Plume Delta AOD';
%following for ace-2 aats-14 data on 7/17/97 MBL 203-882m mean_extinctions, radii limits are 0.1 to 4.0
%lambda=lambda_AATS14([1 2 3 4 5 6 7 8 9 10 12 13 14]);  %select wavelengths to be used in CLI
%taup_meas=     [0.0841 0.0746 0.0732 0.0685 0.0651 0.0586 0.0541 0.0498 0.0486 0.0461 0.0448 0.0421 0.0358]';
%unc_taup_meas= [0.005  0.005  0.005  0.0050 0.005  0.005  0.005  0.005  0.005  0.005  0.005  0.005  0.005 ]';
%date_text='AATS-14, 17 July 97, MBL 203-882m';

%following for ace-2 aats-14 data on 7/17/97 Sahara Layer 2603-3436m mean_extinctions,, radii limits are 0.1 to 4.0
%lambda=lambda_AATS14([1 2 3 4 5 6 7 8 9 10 12 13 14]);  %select wavelengths to be used in CLI
%taup_meas=     [0.1537 0.1548 0.1553 0.1555 0.1570 0.1574 0.1573 0.1584  0.1567 0.1565 0.1589 0.1502 0.1325]';
%unc_taup_meas= [0.005  0.005  0.005  0.0050 0.005  0.005  0.005  0.005  0.005  0.005  0.005  0.005  0.005 ]';
%date_text='AATS-14, 17 July 97, Dust 2603-3436m';

%following for ace-2 aats-14 data on 7/17/97 Old Sahara Case
%lambda=lambda_AATS14([1 2 3 4 5 6 7 9 10 12 14]);  %select wavelengths to be used in CLI 
%taup_meas=     [0.2601   0.2644   0.2647   0.2653   0.2669   0.2673   0.2692	  0.2665   0.2653   0.2638   0.2308]';
%unc_taup_meas= [0.0104   0.0059   0.0052   0.0050   0.0043   0.0057   0.0048    0.0025   0.0017   0.0021   0.0034]';
%date_text='17 July 97 AATS-14';

[dummy,Q1est]=size(lambda)


%require opt depth uncertainty(wvl) >= lowlim_relunc_taup*taup_meas
%lowlim_relunc_taup = .02;
%for j = 1:length(lambda),
%   unc_use(j) = max([unc_taup_meas(j) taup_meas(j)*lowlim_relunc_taup]);
%end
%unc_taup_meas = unc_use';

King_CLI(iread_sigext,flag_kingstop1,flag_save,filesave,refrac_idx,lambda,...
   taup_meas,unc_taup_meas,r_min,r_max,n_coarse_rad_bin,Q1est,mode,nitermax);

if strcmp(flag_write_results,'true')
   %write output to file for subsequent summarizing (using program stats_CLI.m)
	fid = fopen('c:\beat\king\CLIresults.txt','a');
	fprintf(fid,'%s %5.2f %5.2f\n',date_text,r_min,r_max);
	for it=1:nitermax,
     for inu=1:3,
     	 for ir = 1:n_coarse_rad_bin,
        fprintf(fid,'%2i   %2i   %8.5f   %12.5e  %12.5e  %12.5e  %12.5e\n',it,inu,rg_coarse(ir),...
          dnlgrsv(ir,inu,it),uncdnlgrsv(ir,inu,it),dnrsv(ir,inu,it),uncdnrsv(ir,inu,it));
	  	 end
     end     
	end   
	fclose(fid);
end

%begin plots
fprintf('Now creating plots\n');
wvl_min=0.3; wvl_max=1.6;  %2; 
taup_min=0.01; taup_max=1;
rad_min=.03; rad_max=5;
dndlgr_min=1E+03 ; dndlgr_max=1E+12;
dSdlgr_min=1E+02; dSdlgr_max=1E+11;
text_rfr_rad=sprintf('%5.3f%4.3fi  %3.2f-%3.1f um\n',real(refrac_idx),imag(refrac_idx),r_min,r_max);

if strcmp(flag_plot_tau,'true')		%figure 1
    
    figure(1);
    
    grid on
    set(1,'DefaultAxesColorOrder',[0 0 1])
    orient landscape;
    for ns=1:3,
        text_string=sprintf('nustar(%1d): %5.3f\n',ns,nustar(ns));
        subplot(1,3,ns)
        loglog(lambda,taup_meas,'bo')
        hold on
        yerrorbar('loglog',wvl_min,wvl_max,taup_min,taup_max,lambda,taup_meas,unc_taup_meas,'bo')
        hold on
        for iter=8:8,
            loglog(lambda,taucsv(:,ns,iter),':')
        end
        for iter=8:8,
            loglog(lambda,tausum(:,iter,ns),'r:')
        end
        for iter = 8:8,
            loglog(lambda,taunumint(:,iter,ns),'gd-')
        end
        axis([wvl_min wvl_max taup_min taup_max])
        %set(gca,'XLim',[0.3 1.1],'YLim',[0.1 1.0])
        %set(gca,'XTick',[0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1]);
        set(gca,'XTick',[0.3 0.5 0.7 1.0 1.2 1.4 1.6]);
        %set(gca,'YTick',[0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.1]);
        %set(gca,'YTick',[0.1 0.11 0.12 0.13 0.14 0.15 0.16 0.17 0.18 0.19 0.2]);
        xlabel('WAVELENGTH (\mum)');
        ylabel('AEROSOL OPTICAL DEPTH');
        xtext = wvl_min*(wvl_max/wvl_min).^0.1;
        ytext = taup_min*(taup_max/taup_min).^0.15;
        text(xtext,ytext,date_text);
        ytext = taup_min*(taup_max/taup_min).^0.09;
        text(xtext,ytext,text_rfr_rad);
        ytext = taup_min*(taup_max/taup_min).^0.05;
        text(xtext,ytext,text_string);
    end
end	%figure 1

if strcmp(flag_plot_dndlogr,'true')		%figure 2
 figure(2);
 set(2,'DefaultAxesColorOrder',[0 0 1])
 orient landscape;
  for ns=1:3,
    	text_string=sprintf('nustar(%1d): %5.3f\n',ns,nustar(ns));
      subplot(1,3,ns)
      for iter=1:nitermax,
			slope = log10(dnlgrsv(2,ns,iter)/dnlgrsv(1,ns,iter))/log10(rg_coarse(2)/rg_coarse(1));
   		dndlgrsav(1,ns,iter) = dnlgrsv(1,ns,iter)*10.^(slope*log10(r_min/rg_coarse(1)));
   		slope = log10(dnlgrsv(n_coarse_rad_bin,ns,iter)/dnlgrsv(n_coarse_rad_bin-1,ns,iter))/log10(rg_coarse(n_coarse_rad_bin)/rg_coarse(n_coarse_rad_bin-1));
  			dndlgrsav(n_coarse_rad_bin+2,ns,iter) = dnlgrsv(n_coarse_rad_bin,ns,iter)*10.^(slope*log10(r_max/rg_coarse(n_coarse_rad_bin)));
  			dndlgrsav(2:n_coarse_rad_bin+1,ns,iter) = dnlgrsv(1:n_coarse_rad_bin,ns,iter);
        end
      loglog(radcalc(1:2),dndlgrsav(1:2,ns,1),'g-')
      hold on
      loglog(radcalc(n_coarse_rad_bin+1:n_coarse_rad_bin+2),dndlgrsav(n_coarse_rad_bin+1:n_coarse_rad_bin+2,ns,1),'g-')
      hold on
      loglog(rg_coarse',dnlgrsv(:,ns,1),'gx-')
      hold on
		for iter=2:nitermax-1,
         loglog(radcalc(1:2),dndlgrsav(1:2,ns,iter),'b-')
         hold on
         loglog(radcalc(n_coarse_rad_bin+1:n_coarse_rad_bin+2),dndlgrsav(n_coarse_rad_bin+1:n_coarse_rad_bin+2,ns,iter),'b-')
         hold on
         loglog(rg_coarse',dnlgrsv(:,ns,iter),'bd-')
      	hold on
    end
      loglog(radcalc(1:2),dndlgrsav(1:2,ns,nitermax),'r:')
      hold on
      loglog(radcalc(n_coarse_rad_bin+1:n_coarse_rad_bin+2),dndlgrsav(n_coarse_rad_bin+1:n_coarse_rad_bin+2,ns,nitermax),'r:')
      hold on
      for irad=1:n_coarse_rad_bin,
         if dnlgrsv(irad,ns,nitermax)-uncdnlgrsv(irad,ns,nitermax) >= 0
            lower_errorbar(irad)= uncdnlgrsv(irad,ns,nitermax);
        else
            lower_errorbar(irad) = dnlgrsv(irad,ns,nitermax)-dndlgr_min;
        end
    end
     yerrorbar('loglog',rad_min,rad_max,dndlgr_min,dndlgr_max,rg_coarse',dnlgrsv(:,ns,nitermax),lower_errorbar(:),uncdnlgrsv(:,ns,nitermax),'r:o')
     set(gca,'xlim',[rad_min rad_max],'ylim',[dndlgr_min dndlgr_max])
     %set(gca,'XTick',[0.05 0.1 0.5 1.0 5.0 10.]);
   	 xtext = rad_min*(rad_max/rad_min).^0.4;
     ytext = dndlgr_min*(dndlgr_max/dndlgr_min).^0.9;
     text(xtext,ytext,text_string);
     xlabel('PARTICLE RADIUS (\mum)');
   	ylabel('dNc/dlogr (cm^{-2})');
end
end	%figure 2

if strcmp(flag_plot_dSdlogr,'true')
   figure(3);
   orient landscape;
  for ns=1:3,
   text_string=sprintf('nustar(%1d): %5.3f\n',ns,nustar(ns));

		subplot(1,3,ns)
 
      for iter=1:nitermax,
         for ii=2:n_coarse_rad_bin+1
          dSdlgrsav(ii,ns,iter) = 4*pi*rg_coarse(ii-1).^2*dnlgrsv(ii-1,ns,iter);
         end 
         slope = log10(dSdlgrsav(3,ns,iter)/dSdlgrsav(2,ns,iter))/log10(rg_coarse(2)/rg_coarse(1));
   		dSdlgrsav(1,ns,iter) = dSdlgrsav(2,ns,iter)*10.^(slope*log10(r_min/rg_coarse(1)));
         slope = log10(dSdlgrsav(n_coarse_rad_bin+1,ns,iter)/dSdlgrsav(n_coarse_rad_bin,ns,iter))/log10(rg_coarse(n_coarse_rad_bin)/rg_coarse(n_coarse_rad_bin-1));
   		dSdlgrsav(n_coarse_rad_bin+2,ns,iter) = dSdlgrsav(n_coarse_rad_bin+1,ns,iter)*10.^(slope*log10(r_max/rg_coarse(n_coarse_rad_bin)));
      end
      
      loglog(radcalc(1:2),dSdlgrsav(1:2,ns,1),'g-')
      hold on
      loglog(radcalc(n_coarse_rad_bin+1:n_coarse_rad_bin+2),dSdlgrsav(n_coarse_rad_bin+1:n_coarse_rad_bin+2,ns,1),'g-')
      hold on
      dSlgrsv(:,ns,1)=4*pi*rg_coarse.^2.*dnlgrsv(:,ns,1);
      loglog(rg_coarse,dSlgrsv(:,ns,1),'gx-')
      hold on
		for iter=2:nitermax-1,
         loglog(radcalc(1:2),dSdlgrsav(1:2,ns,iter),'b-')
         hold on
         loglog(radcalc(n_coarse_rad_bin+1:n_coarse_rad_bin+2),dSdlgrsav(n_coarse_rad_bin+1:n_coarse_rad_bin+2,ns,iter),'b-')
         hold on
         dSlgrsv(:,ns,iter)=4*pi*rg_coarse.^2.*dnlgrsv(:,ns,iter);
         loglog(rg_coarse,dSlgrsv(:,ns,iter),'bd-')
      	hold on
   	end
      
      loglog(radcalc(1:2),dSdlgrsav(1:2,ns,nitermax),'r:')
      hold on
      loglog(radcalc(n_coarse_rad_bin+1:n_coarse_rad_bin+2),dSdlgrsav(n_coarse_rad_bin+1:n_coarse_rad_bin+2,ns,nitermax),'r:')
      hold on
      
      dSlgrsv(:,ns,nitermax)=4*pi*rg_coarse.^2.*dnlgrsv(:,ns,nitermax);

		uncdSdlgrsv(:,ns,nitermax)=4*pi*rg_coarse.^2.*uncdnlgrsv(:,ns,nitermax);
		for irad=1:n_coarse_rad_bin,
         if dnlgrsv(irad,ns,nitermax)-uncdnlgrsv(irad,ns,nitermax) >= 0
            lower_errorbar(irad)= uncdSdlgrsv(irad,ns,nitermax);
         else
            lower_errorbar(irad) = dSlgrsv(irad,ns,nitermax)-dSdlgr_min;
         end
      end
     yerrorbar('loglog',rad_min,rad_max,dSdlgr_min,dSdlgr_max,rg_coarse,dSlgrsv(:,ns,nitermax),lower_errorbar(:),uncdSdlgrsv(:,ns,nitermax),'r:o')
   	set(gca,'xlim',[rad_min rad_max],'ylim',[dSdlgr_min dSdlgr_max])
   	set(gca,'XTick',[0.01 0.05 0.1 0.5 1.0 5.0 10.]);
      xtext = rad_min*(rad_max/rad_min).^0.1;
      ytext = dSdlgr_min*(dSdlgr_max/dSdlgr_min).^0.15;
      text(xtext,ytext,date_text);
      ytext = dSdlgr_min*(dSdlgr_max/dSdlgr_min).^0.09;
      text(xtext,ytext,text_string);
      ytext = dSdlgr_min*(dSdlgr_max/dSdlgr_min).^0.05;
      text(xtext,ytext,text_rfr_rad);
		xlabel('PARTICLE RADIUS (\mum)');
   	ylabel('dSc/dlogr (\mum^{2} cm^{-2})');
	end
end   %end fig3

Q_min=1E-03; Q_max=1E+03;
ggam_min=.001; ggam_max=5;
if strcmp(flag_plot_Q,'true')
 for ns=1:3,
   text_string=sprintf('nustar(%1d): %5.3f\n',ns,nustar(ns));
   hfig=3+ns;
   figure(hfig);
   orient landscape;
	set(hfig,'DefaultAxesColorOrder',[0 0 1])
		for iter=1:nitermax,
      	loglog(ggamsv(1:13,iter,ns),Qsv(1:13,iter,ns),'r-')
      	loglog(ggamsv(1:13,iter,ns),Q1sv(1:13,iter,ns),'g-')
      	loglog(ggamsv(1:13,iter,ns),Q2sv(1:13,iter,ns),'b-')
      	hold on
   	end
   	set(gca,'xlim',[ggam_min ggam_max],'ylim',[Q_min Q_max])
   	set(gca,'XTick',[0.001 .005 .01 .05 .10 .50 1.0 5.0 10.]);
   	xtext = ggam_min*(ggam_max/ggam_min).^0.4;
      ytext = Q_min*(Q_max/Q_min).^0.9;
      text(xtext,ytext,text_string);
		xlabel('Relative Lagrange Multiplier, gamma');
   	ylabel('Fitting Measure, Q,Q1,Q2');
 end
end	%Q vs ggam plots...figs 4-6

if strcmp(flag_plot_f,'true')
 f_min=.01; f_max=10;
 for ns=1:3,
   text_string=sprintf('nustar(%1d): %5.3f\n',ns,nustar(ns));
   hfig=6+ns;
   figure(hfig);
   orient landscape;
	set(hfig,'DefaultAxesColorOrder',[0 0 1])
      for iter=2:2:nitermax,
         subplot(2,2,iter/2);
         for lf=1:n_coarse_rad_bin,
				loglog(ggamsv(1:13,iter,ns),fsv(lf,1:13,iter,ns),'b-')
      		set(gca,'xlim',[ggam_min ggam_max],'ylim',[f_min f_max])
   			set(gca,'XTick',[0.001 .005 .01 .05 .10 .50 1.0 5.0 10.]);
				hold on
   		end
   		set(gca,'xlim',[ggam_min ggam_max],'ylim',[f_min f_max])
   		set(gca,'XTick',[0.001 .005 .01 .05 .10 .50 1.0 5.0 10.]);
      	xtext = ggam_min*(ggam_max/ggam_min).^0.4;
      	ytext = f_min*(f_max/f_min).^0.9;
      	text(xtext,ytext,text_string);
      	xlabel('Relative Lagrange Multiplier, gamma');
   		ylabel('f');
      end
   end     
end	%end f plots; figs 7-9


if strcmp(flag_plot_contrib,'true')		%plots 10-12
   %plot contribution function as function of radius

nwl = length(lambda);
log_rgfine = log10(rg_fine');

for i = 1:length(rad_bound_fine)-1;
	dlogrfine(i) = log10(rad_bound_fine(i+1)/rad_bound_fine(i));
end
dlogrfine = dlogrfine';

for iter=1:nitermax,
	for ns=1:3,
   	dndlogr_calc(:,ns,iter) = 10.^interp1q(log10(radcalc'),log10(dndlgrsav(:,ns,iter)),log10(rg_fine'));   %log(10)*rg_fine'.*   
      for kwl = 1:nwl,
         contrib(:,kwl,iter,ns) = sigext(kwl,:)'.*dndlogr_calc(:,ns,iter);
         taup_trapz(kwl,iter,ns) = trapz(log_rgfine,contrib(:,kwl,iter,ns)); 
         integrand = contrib(:,kwl,iter,ns).*dlogrfine(:,1);
 	   	taup_cum_int(:,kwl,iter,ns) =  cumsum(integrand,1)/taup_trapz(kwl,iter,ns);  
      end
   end
end 

%symbol_wvl = ['c-';'b-';'g-';'r-'];
contrib_min = 0;
contrib_max = inf;

 for ns=1:3,
   hfig=9+ns;
   figure(hfig);
   orient landscape;
      for iter=2:2:nitermax,
         subplot(2,2,iter/2);
         for kwl=1:nwl,
				semilogx(rg_fine',contrib(:,kwl,iter,ns))
      		set(gca,'xlim',[rad_min rad_max],'ylim',[contrib_min contrib_max])
   			set(gca,'XTick',[.01 .05 .10 .50 1.0 2 3 4 5 8 10]);
            %set(gca,'YTick',[.001 .01 .1 1.0 10.]);
            hold on
   		end
   		text_string=sprintf('%3.2f-%3.1f um\nnu(%1d):%5.3f\niter:%d\n',r_min,r_max,ns,nustar(ns),iter);
   		xtext = rad_min*(rad_max/rad_min).^0.05;
   		ytext = contrib_min + 0.8*(contrib_max - contrib_min);
   		%ytext = contrib_min *(contrib_max/contrib_min).^0.9;
   		text(xtext,ytext,text_string);
    		xtext = rad_min*(rad_max/rad_min).^0.2;
         text(xtext,1.05*contrib_max,date_text);
         
         xlabel('PARTICLE RADIUS (\mum)');
			ylabel('dNc/dlogr Contribution Function');
      end
  end    	%figs 10-12 
  
  for ns=1:3,
   hfig=12+ns;
   figure(hfig);
   orient landscape;
      for iter=2:2:nitermax,
         subplot(2,2,iter/2);
         for kwl=1:nwl,
			 	semilogx(rg_fine',taup_cum_int(:,kwl,iter,ns))
      		set(gca,'xlim',[rad_min rad_max],'ylim',[0 1]);
   			set(gca,'XTick',[.01 .05 .10 .50 1.0 2 3 4 5 8 10]);
            hold on
   		end
   		text_string=sprintf('%3.2f-%3.1f um\nnu(%1d):%5.3f\niter:%d\n',r_min,r_max,ns,nustar(ns),iter);
   		xtext = rad_min*(rad_max/rad_min).^0.05;
   	 	ytext = 0.8;
   		text(xtext,ytext,text_string);
    		xtext = rad_min*(rad_max/rad_min).^0.2;
         text(xtext,1.05,date_text);
         xlabel('PARTICLE RADIUS (\mum)');
			ylabel('Opt Depth Cumulative Integral');
      end
  end   %figs 13-15  

end

%if strcmp(flag_plot_contrib,'true')		%plot1 refresh
   %add to figure 1
	%figure(1)
	%for ns=1:3,
     % subplot(1,3,ns)
	%	for iter = 1:nitermax,
    %     loglog(lambda,taup_trapz(:,iter,ns),'y-')
    %  end
  % end
%end