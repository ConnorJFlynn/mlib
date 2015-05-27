function [s_od]=showahsrl(rs,apply_mask,fig1);
%[atten_backscat,od]=showahsrl(rs, [apply_mask,fig1]);
%
%rs         = name of structure containing data created by readahsrl.
%apply_mask = if 1 apply mask contained in rs.qc_mask to rti plots
%                mean vertical profiles always include masking.
%fig1       = figure number of first figure(optional, default: fig1=1).
%                if fig1<0, first figure =|fig1| a larger selection
%                of figures will be included.
%od         = optical depth computed from average transmission over
%              displayed time period.

%(c) 2007 Ed Eloranta, University of Wisconsin Lidar Group
% eloranta@lidar.ssec.wisc.edu



path(path,'../calibration')
%warning off MATLAB:divideByZero
warning off 
%if first figure number is not specified default fig1=1.
switch nargin 
 case 1
    apply_mask=0;
    fig1=1;
 case 2
    fig1=1;
 case 3
    %all parameters supplied
 otherwise 
  fprintf('\nERROR---Too many input parameters\n');
  return
end
 

  times=rs.mean_times;
  pointers_to_cal_index=rs.pointers_to_cal_index;
  ntimes=length(times);
  nalts=length(rs.altitude);
  bin_width=diff(rs.altitude); 
  bin_width(nalts)=bin_width(nalts-1);
  

%make display strings

if isfield(rs.processingStruct.particlesettings,'type')
  particle_type_str=strtok(rs.processingStruct.particlesettings.type,'(');
  indices=findstr(particle_type_str,'_');
  particle_type_str(indices)=' ';
else
  particle_type_str=' ';
end

if isfield(rs.processingStruct.qc_params,'min_radar_backscat')
  min_radar_backscat_str=num2str(rs.processingStruct.qc_params.min_radar_backscat);
else
  min_radar_backscat_str='0';
end

if isfield(rs.processingStruct.qc_params,'min_beta_a')
  min_beta_a_str=num2str(rs.processingStruct.qc_params.min_beta_a);
else
  min_beta_a_str='0';
end
 
%get mask from rs or set mask to all ok.
if apply_mask & isfield(rs,'qc_mask')
  qmask=rs.qc_mask;
else
  qmask=uint32(intmax('uint32'))*uint32(ones(ntimes,nalts));
end

qmaskstruct=extract_qc_bits(qmask);

lidar_mask=qmaskstruct.lidar_mask;
od_mask=qmaskstruct.od_mask;
radar_mask=qmaskstruct.radar_mask;





% form fig_date_str
%if all data from one day
plot_profiles=1; %plot average vertical profiles for short records.
if strcmp(datestr(rs.start_time_num,1),datestr(rs.last_time_num,1))
    fig_date_str=[datestr(rs.start_time_num,7),'-',datestr(rs.start_time_num,3),'-'...
		  datestr(rs.start_time_num,11),' ',datestr(rs.start_time_num,15) ...
		   ,' ---> ',datestr(rs.last_time_num,15)];
elseif rs.last_time_num-rs.start_time_num > 7    %if greater than one week
    plot_profiles=0;
    fig_date_str=[datestr(rs.start_time_num,7),'-',datestr(rs.start_time_num,3),'-'...
		  ,datestr(rs.start_time_num,11),' ---> '...
	          datestr(rs.last_time_num,7),'-',datestr(rs.last_time_num,3)];
else %if more than 1 day but <= 7 days of data are included
    fig_date_str=[datestr(rs.start_time_num,7),'-',datestr(rs.start_time_num,3),'-'...
		  datestr(rs.start_time_num,11),'  ',datestr(rs.start_time_num,15)...
       ,' ---> ',datestr(rs.last_time_num,7),'-',datestr(rs.last_time_num,3)...
       ,'-',datestr(rs.last_time_num,11),'  ',datestr(rs.last_time_num,15)];
end



%don't plot radiosonde profile if displaying more than one week of data
if isfield(rs,'temperature_profile') & plot_profiles
   %find closest radiosonde profile if more than one sonde profile
   if length(rs.raob_time_num)>1
     mid_point_time=(rs.last_time_num+rs.start_time_num)/2;
     index=1:length(rs.raob_time_num);
     prev_sonde=max(1,max(index(rs.raob_time_num<mid_point_time)));
     next_sonde=min(length(rs.raob_time_num),prev_sonde+1);
     if (mid_point_time-rs.raob_time_num(prev_sonde))...
	    <=(rs.raob_time_num(next_sonde)-mid_point_time)
       sonde_num=prev_sonde;
     else
       sonde_num=next_sonde;
     end
   else
       sonde_num=1;
   end
   sonde_tag=datestr(rs.raob_time_num(sonde_num),30);
   sonde_tag=[sonde_tag(1:(length(sonde_tag)-2)) , ' UTC'];
   sonde_tag=[deblank(rs.raob_station(sonde_num,:)),'  ',sonde_tag];
   figure(fig1+7)
   clf
   set(gcf,'Name','Radiosonde profiles     ');
     %plot radiosonde profiles
     % if fig==5
     %    subplot(2,3,1)
     % end;  
   frost_point_temp=frost_point(rs.dewpoint_profile(sonde_num,:));
   
   ax(1)=min(min(rs.dewpoint_profile(sonde_num,:))...
		 ,min(rs.temperature_profile(sonde_num,:)))-1;
   ax(2)=max(rs.temperature_profile(sonde_num,:))+1;
   ax(3)=rs.altitude(1)/1000;
   ax(4)=rs.altitude(length(rs.altitude))/1000;
   
   dt=ax(2)-ax(1);
  
   theta_max=max(max(rs.temperature_profile(sonde_num,:).*(1000./rs.pressure_profile(sonde_num,:)).^.286));
   if dt>500
     t1000= 20*ceil(ax(1)/20):20:20*ceil(theta_max/20);
   elseif dt>50
     t1000= 10*ceil(ax(1)/10):10:10*ceil(theta_max/10);
   elseif dt>25
     t1000= 5*ceil(ax(1)/5):5:5*ceil(theta_max/5);
   else
      t1000=2*ceil(ax(1))/2:2:2*ceil(theta_max/2);
   end
  
   adiabats=t1000'*(1000./rs.pressure_profile(sonde_num,:)).^-0.286;

   if rs.altitude(length(rs.altitude))>=rs.top_alt_sounding
     h1=plot(adiabats,rs.altitude/1000,'c'... 
	   ,rs.temperature_profile(sonde_num,:),rs.altitude/1000,'r'...
	   ,rs.temperature_profile(sonde_num,rs.altitude<rs.top_alt_sounding)...
	   ,rs.altitude(rs.altitude<rs.top_alt_sounding)/1000,'r'...
	   ,rs.dewpoint_profile(sonde_num,:),rs.altitude/1000,'g'...
	   ,frost_point_temp,rs.altitude/1000,'b');
     set(h1(length(h1)-2:length(h1)),'LineWidth',3);
     ylabel('altitude (km)')
     xlabel('Temp (rd), dewpt (grn) ^\circ K')
   
     legend([h1(length(h1)-2) h1(length(h1)-3) h1(length(h1)-1) h1(length(h1)) h1(1)]...
	  ,'temp','standard atm','dew pt','frost pt','adiabats');
  
   else
   
     
     h1=plot(adiabats,rs.altitude/1000,'c'... 
	   ,rs.temperature_profile(sonde_num,:),rs.altitude/1000,'r'...
	   ,rs.temperature_profile(sonde_num,:),rs.altitude/1000,'r'...
	   ,rs.dewpoint_profile(sonde_num,:),rs.altitude/1000,'g'...
	   ,frost_point_temp,rs.altitude/1000,'b');
   set(h1(length(h1)-2:length(h1)),'LineWidth',3);
    legend([h1(length(h1)-2:length(h1))', h1(1)],'temp','dew pt','frost pt','adiabats');
  end
  
   
   set(h1(length(h1)-2:length(h1)),'LineWidth',3);
   ylabel('altitude (km)')
   xlabel('Temp (rd), dewpt (grn) ^\circ K')
   title(sonde_tag); 
   grid on
   axis(ax);
   lineh1=line([273 273],ax(3:4));
   set(lineh1,'Color',[0 0 1],'LineStyle','--');
   lineh2=line([233 233],ax(3:4));
   set(lineh2,'Color',[0 0 1],'LineStyle','--');
   end
     
if ~isfield(rs,'use_gps_altitude')
  rs.use_gps_altitude=0; %FIXME 20100303 JPG not stored in netcdf,
                         %so crashes below
end
   
%show attenuated backscatter rti
if isfield(rs,'atten_backscat')  
 %  atten_backscat(atten_backscat<=0)=NaN;
  if ~rs.use_gps_altitude %for ground based data
     s_vect=ones(ntimes,1);
     ref_bin=find(rs.altitude>=150,1);
     
     % if fixed scalling of attenuated bacscatter is not requested
     if ~isfield(rs,'att_bs_scale')                    
        cal_return=rs.beta_a_backscat(:,ref_bin)+(3/(8*pi))*rs.beta_m(ref_bin);
     else
        cal_return=rs.att_bs_scale+(3/(8*pi))*rs.beta_m(ref_bin);
     end
     
     normaltvec=ones(1,nalts);
     
     norm_array=(cal_return./rs.atten_backscat(:,ref_bin))*normaltvec;
     rs.atten_backscat=rs.atten_backscat.*norm_array;
    
     attb_max=max(max(rs.atten_backscat(:,10:ref_bin)));
     if(attb_max>5e-4)
       bmax=5e-3;
     elseif(attb_max>5e-5)
       bmax=1e-4;
     else
       bmax=1e-5;
     end;  
  else
     bmax=1e-3;
  end
  
  bmin=1e-8;
  rti_fig(rs.atten_backscat,times,rs.altitude ...
	   ,[bmin,bmax],['Attenuated backscatter (no masks applied)  '...
	    ,datestr(rs.start_time_num,1)],'1 / (m str)','gg',fig1);
  end %end of isfield(rs,'corrected_combined')
 
   
   if 0
    switch(fig)
     case 1 %fig==1
       sfig=[fig_offset+1,3,1,1];
       %figure(fig_offset+1)
       %subplot(3,1,1)
     case {2,5} %elseif fig==2 | fig==5
       %figure(fig_offset+1)
       %subplot(2,1,1)
       sfig=[fig_offset+1,2,1,1];
     otherwise %else
       %figure(fig_offset+1)
       %clfr =
       %set(gcf,'Name','Atten Backscatter RTI   ');
       sfig=fig_offset+1;
     end;
   end
 
  
  
%plot aerosol backscatter rti
%and of mask bits 2-->8 used if apply_mask==1
if isfield(rs,'beta_a_backscat')  
   beta_a_max=max(max(rs.beta_a_backscat));
   if(beta_a_max>5e-4)
     bmax=1e-3;
   elseif(beta_a_max>5e-5)
     bmax=1e-4;
   else
     bmax=1e-5;
   end;  
   title_str=['Aerosol backscatter cross section  '...
         ,datestr(rs.start_time_num,1)];
   units_str='1/(m str)';
   beta_a=rs.beta_a_backscat;
   beta_a(:,rs.altitude<90)=nan;
   rti_fig(beta_a.*lidar_mask,times,rs.altitude...
	    ,[1e-9 bmax],title_str,units_str,'gg',fig1+2)
   if plot_profiles && exist('sonde_tag','var') %don't include sonde tag for long period plots
     corneranno(2,sonde_tag);
   else
     corneranno(2,'profile not stored');
   end
end;


%depolaraization
%all lidar mask planes used if apply_mask==1.
if isfield(rs,'circular_depol')   
   units_str='%';
   title_str=['Particulate circular depolarization ratio  '...
	  ,datestr(rs.start_time_num,1)];
   cscale=[1,2,5,10,20,50,100,200]';
   depol=rs.circular_depol;
   depol(:,rs.altitude<90)=nan;
   depol(depol<.012)=.012;
   rti_fig(100*depol.*lidar_mask,times(:,1)...
	   ,rs.altitude,cscale,title_str,units_str,'gg',(fig1+4))
end


if isfield(rs,'radar_backscattercrosssection')... 
    & sum(sum(isfinite(rs.radar_backscattercrosssection)))
    radar_present=1;
elseif isfield(rs,'radar_reflectivity') & sum(sum(isfinite(rs.radar_reflectivity)))
     radar_present=1;
else
     radar_present=0;
end



if isfield(rs,'radar_backscattercrosssection') & radar_present  
  cscale=[1e-14 1e-7];
  title_str=['Radar backscatter cross section  ',datestr(rs.start_time_num,1)];
  units_str='1/(m sr)';
  rti_fig(rs.radar_backscattercrosssection.*radar_mask...
	  ,times,rs.altitude,cscale,title_str,units_str,'gg',fig1+6)  
end


if isfield(rs,'radar_reflectivity') & radar_present
  cscale=[-50 30];
  title_str=['Radar reflectivity   ',datestr(rs.start_time_num,1)];
  units_str='dBz';
  temp=rs.radar_reflectivity;
  temp(radar_mask==0)=NaN;
  rti_fig(temp,times,rs.altitude,cscale,title_str,units_str,'li',fig1+8)
end

%plot backscatter cross section profiles  
if isfield(rs,'beta_m') && isfield(rs,'altitude') && isfield(rs, ...
  'beta_a_backscat') && isfield(rs,'atten_beta_r_backscat' )...
      & plot_profiles
if 0
if fig==5
     subplot(2,3,2)
  else
     figure(fig_offset+19)
     clf
     set(gcf,'Name','Backscatter profiles      ');
  end;
end
  figure(fig1+16)
  if isfield(rs,'profiles') && ~isempty(rs.profiles)
    if isfield(rs.profiles,'beta_m')
      mean_beta_m=rs.profiles.beta_m;
    else
      [mean_beta_m,jnk,jnk]= ...
          filtered_mean(rs.beta_m(pointers_to_cal_index,:));
    end
    mean_mol_backscat=rs.profiles.atten_beta_r_backscat;
    mean_beta_a_backscat=rs.profiles.beta_a_backscat;
  else
  [mean_beta_m,jnk,jnk]=filtered_mean(rs.beta_m(pointers_to_cal_index,:));
  %beta_a_backscat is derived from non-linear process--here we mask
  %portions of the profile where the mol signal is lost and thus the
  %profile represents only the average of the aerosols signal when the
  %attenuation is small enough to observe the mol signal.
  [mean_beta_a_backscat,jnk,jnk]=filtered_mean(rs.beta_a_backscat,od_mask);
  %mol signal is derived from linear process, thus this unmasked mean
  %profile represents the mean transmission of the atmosphere.
  [mean_mol_backscat,jnk,jnk]=filtered_mean(rs.atten_beta_r_backscat);
  end
  %mask lowest points in beta_a_backscat profile
  mean_beta_a_backscat(rs.altitude<90)=nan;
  mean_mol_backscat(rs.altitude<90)=nan;
  %h23=semilogx(3/(8*pi)*mean_beta_m,rs.altitude/1000,'k',mean_mol_backscat...
  h23=semilogx(3/(8*pi)*rs.profiles.beta_m,rs.altitude/1000,'k',mean_mol_backscat...
     ,rs.altitude/1000,'b',mean_beta_a_backscat,rs.altitude/1000,'r');
  set(h23(1:3),'linewidth',2);
  grid on
  axis([2e-10 4e-3 rs.altitude(1)/1000 rs.altitude(nalts)/1000]);
  set(gca,'XTickMode','manual','XTick',[1e-9 1e-8 1e-7 1e-6 1e-5 1e-4 1e-3],...
	  'XTickLabelMode','manual',...
	  'XTickLabel',{'1e-9' '1e-8' '1e-7' '1e-6' '1e-5' '1e-4' '1e-3'});
  xlabel('Backscatter (m^{-1} str^{-1})')
  ylabel('altitude (km)')
  title(['Mean profiles ',fig_date_str])
  legend('mol','atten mol','particulate');
  set(gcf,'name','Backscatter profiles');
%plot scattering ratio profiles  

if 0
if fig==5
     subplot(2,3,3)
  else
     figure(fig_offset+20)
     clf
     set(gcf,'Name','Scattering ratio profile ');
  end;
end  


figure(fig1+17) 
  mean_sr=8*pi*mean_beta_a_backscat./(3*mean_beta_m);
  mean_sr(rs.altitude<90)=nan;
  h55=plot(mean_sr,rs.altitude/1000,'r');
  grid on
  set(h55(1),'LineWidth',2);
  ylabel('Altitude (km)')
  xlabel('Backscatter ratio')
 uplmt=max(mean_sr(10:length(mean_sr))+.1);
 if isempty(uplmt)
   uplmt=.2;
 end
 
  axis([-0.2 max(0.5,uplmt)  rs.altitude(1)/1000 rs.altitude(nalts)/1000]);
  title(['Backscatter ratio  ',fig_date_str]);
  set(gcf,'name','Scattering ratio profile')

  %plot depolarization profile  
if 0
  if fig==5
     subplot(2,3,5)
  else
     figure(fig_offset+22)
     clf
     set(gcf,'Name','Depolarization profile   ');
  end;
end
end
  if isfield(rs.profiles,'circular_depol')
   figure(fig1+23)
    hold off
   mean_l_depol=rs.profiles.circular_depol./(2+rs.profiles.circular_depol);
   h24=plot(rs.profiles.circular_depol*100,rs.altitude/1000,'b'...
            ,mean_l_depol*100,rs.altitude/1000,'g');
   axis([0 250 rs.altitude(1)/1000 rs.altitude(nalts)/1000]);
   grid on
   set(h24(:),'LineWidth',3);   
   ylabel('Altitude (km)')
   title(['Mean depolarization,   ',fig_date_str]);
   xlabel('Particulate depolarization (%)')
   legend('Circular','Linear')
   set(gcf,'name','Depolarization profile')

  end
  
 
%plot optical depth profile  
if 0
    if fig==5
     subplot(2,3,4)
    else
     figure(fig_offset+21)
     set(gcf,'Name','Optical depth profile    ');
     clf
    end;
end
  
if 0
 if isfield(rs,'atten_beta_r_backscat') & isfield(rs,'beta_m')...
      & plot_profiles
   beta_m=rs.beta_m(pointers_to_cal_index,:);
   od=-0.5*log(8*pi*rs.atten_beta_r_backscat./(3*beta_m));
   title_str=['Optical depth   ',datestr(rs.start_time_num,1)];
   od=real(od);
   od(rs.atten_beta_r_backscat<=0)=NaN;
   od(lidar_mask==0)=.0001;
   od(:,rs.altitude<90)=nan;
   %rti_fig(od,times,rs.altitude,[0.05 3],title_str,' ','gg',fig1+20)
 end
end

if isfield(rs,'optical_depth')
   title_str=['Optical depth,  ',fig_date_str];
   rti_fig(rs.optical_depth,times,rs.altitude,[0.05 3],title_str,' ','gg',fig1+21)
end

figure(fig1+22)
rs.profiles.optical_depth(rs.altitude<200)=0;
h22=plot(rs.profiles.optical_depth,rs.altitude/1000,'b');
grid on
ax=axis;
axis([ax(1) max(ax(2),0.5) ax(3:4)]);
set(h22(1),'linewidth',3);
xlabel('Optical Depth')
ylabel('Altitude (km)')
title(['OD computed from average transmission  ',fig_date_str])
set(gcf,'Name','Optical depth profile');


if 0
 figure(fig1+21)
  if isfield(rs,'profiles') && ~isempty(rs.profiles)
    s_od=rs.profiles.optical_depth;
    s_od(1)=NaN;
  else
  %use od_mask because we must sum same number of points as atten_beta_r
  [sum_beta_m,frac_beta_m_ok]=filtered_sum(beta_m,od_mask);
  [sum_atten_beta_r,frac_atten_beta_r_ok]= ...
      filtered_sum(rs.atten_beta_r_backscat,od_mask);
  s_od=-0.5*log(8*pi*sum_atten_beta_r./(3*sum_beta_m));
  s_od(nalts)=NaN; %last point of sum_atten_beta_r may not have as many
                   %bins in sum.
  end
 
  s_od(rs.altitude<90)=nan;
  
  h25=plot(s_od,rs.altitude/1000,'b');
  %h25=plot(s_od,rs.altitude/1000,frac_atten_beta_r_ok,rs.altitude/1000);
  ax=axis;
  maxv=max((max(real(s_od(isfinite(s_od))))+.1),1.1);
  if isempty(maxv)
    maxv=1.1;
  end
  axis([-0.1 maxv ax(3:4)]);
  %axis([-0.1 max((max(real(s_od(isfinite(s_od))))+.1),1.1) ax(3:4)]);
  grid
  xlabel('Optical Depth')
  ylabel('Altitude (km)')
  set(h25(1),'linewidth',2)
  title(['OD computed from average transmission  ',fig_date_str])
  %legend('OD','fraction of mol profiles used',4)
  set(gcf,'name','Optical depth profile')
end


if isfield(rs,'effective_diameter_prime') & radar_present
  rs.effective_diameter_prime(~qmaskstruct.complete_mask)=-inf;  
  rs.effective_diameter_prime(~qmaskstruct.backscat_mask)=NaN;
  cscale=[10 min(1000,max(max(max(rs.effective_diameter_prime)),100))];
  title_str=['Particle effective diameter prime  ',datestr(rs.start_time_num',1)];
  units_str='microns';
  rti_fig(rs.effective_diameter_prime,times,rs.altitude,cscale...
	 ,title_str,units_str,'gg',fig1+22) 
end

if isfield(rs,'effective_diameter') & radar_present
  rs.effective_diameter(~qmaskstruct.complete_mask)=-inf;
  rs.effective_diameter(~qmaskstruct.backscat_mask)=NaN;
  cscale=[1 max(min(300,max(max(rs.effective_diameter))),10)];
  title_str=['Particle effective diameter using  ',particle_type_str...
	     ,'  ',datestr(rs.start_time_num',1)];
  units_str='microns';
  rti_fig(rs.effective_diameter,times,rs.altitude,cscale...
	 ,title_str,units_str,'gg',fig1+24);  
end
 
  %plot water mask
if isfield(rs,'water_mask')  
  cscale=[1 0 0;0 0 1];
  title_str=['Liquid(blue), Ice(red), Liq == circ depol < '...
	     num2str(rs.processingStruct.particlesettings.h20_depol_threshold)...
	     ,'  ',datestr(rs.start_time_num',1)];
  units_str={'ice','water'};
  water_mask=rs.water_mask;
  water_mask(~isfinite(rs.beta_a_backscat))=NaN;
  water_mask=water_mask+1;
  rti_fig(water_mask.*lidar_mask,times,rs.altitude,cscale...
	  ,title_str,units_str,'cl',fig1+23)
  
 
  
end

 if isfield(rs,'mean_diameter') & radar_present
  %rs.mean_diameter(~qmaskstruct.complete_mask)=-inf;
  %rs.mean_diameter(~qmaskstruct.backscat_mask)=NaN; 
  cscale=[10 max(min(5e3,max(max(rs.mean_diameter))),100)];
  title_str=['Particle mean diameter using  ',particle_type_str...
	     ,'  ',datestr(rs.start_time_num',1)];
  units_str='microns';
  rti_fig(rs.mean_diameter,times,rs.altitude...
	    ,cscale,title_str,units_str,'gg',fig1+26);
end
 
 

if isfield(rs,'radar_dopplervelocity') & radar_present
  rs.radar_dopplervelocity(~qmaskstruct.radar_ok_mask)=NaN;
  cscale=[-1 2];
  title_str=['Radar fall velocity  ',datestr(rs.start_time_num',1)];
  units_str='m/s';
  rti_fig(rs.radar_dopplervelocity.*qmaskstruct.radar_backscat_mask...
	  ,times,rs.altitude,cscale,title_str,units_str,'li',fig1+10)
end

if isfield(rs,'radar_spectralwidth') & radar_present
  rs.radar_spectralwidth(~qmaskstruct.radar_ok_mask)=NaN;
  cscale=[0 1];
  title_str=['Radar spectral width  ',datestr(rs.start_time_num',1)];
  units_str='m/s)';
  rti_fig(rs.radar_spectralwidth,times,rs.altitude,cscale,title_str,units_str,'li',fig1+12)
end



if isfield(rs,'num_particles') & radar_present
  rs.num_particles(~qmaskstruct.complete_mask)=-inf;
  rs.num_particles(~qmaskstruct.backscat_mask)=NaN; 
  cscale=[.1 1e4];
  title_str=['Number density using ',particle_type_str,'   ',datestr(rs.start_time_num',1)];
  units_str='1/liter';
  rs.num_particles(qmask==0)=NaN;
  rti_fig(rs.num_particles.*qmaskstruct.complete_mask,times,rs.altitude ...
	     ,cscale,title_str,units_str,'gg',fig1+28);
end


if isfield(rs,'LWC')  & radar_present
  rs.LWC(~qmaskstruct.complete_mask)=-inf;
  rs.LWC(~qmaskstruct.backscat_mask)=NaN; 
  cscale=[.001 1];
  title_str=['Water Content using ',particle_type_str...
	     , '   ',datestr(rs.start_time_num',1)];
  units_str='gr/m^3';
  rti_fig(rs.LWC,times,rs.altitude,cscale,title_str,units_str,'gg', ...
	  fig1+30);
set(gcf,'name','LWC rti')
end

if (isfield(rs,'effective_diameter') |isfield(rs,'effective_diameter'))...
      & radar_present & plot_profiles
  figure(fig1+32)
  if isfield(rs,'effective_diameter')
    [mean_eff_diameter,min_eff_diameter,max_eff_diameter]...
        =filtered_mean(rs.effective_diameter,bitget(rs.qc_mask,1)); 
  end
 
  if isfield(rs,'effective_diameter_prime')
    [mean_eff_diameter_prime,min_eff_diameter_prime,min_eff_diameter_prime]=...
              filtered_mean(rs.effective_diameter_prime,bitget(rs.qc_mask,1));  
    
  else
    mean_eff_diameter_prime=NaN*ones(ntimes,nalts);
    max_eff_diameter_prime=mean_eff_diameter_prime;
    min_eff_diameter_prime=max_eff_diameter_prime;
  end
  
  if isfield(rs,'effective_diameter')
    [mean_eff_diameter,min_eff_diameter,max_eff_diameter]...
        =filtered_mean(rs.effective_diameter,bitget(rs.qc_mask,1)); 
  else
    mean_eff_diameter=NaN*ones(ntimes,nalts);
    max_eff_diameter=mean_eff_diameter;
    min_eff_diameter=max_eff_diameter;
  end

  if isfield(rs,'mean_diameter')
    [mean_d,min_mean_d,max_mean_d]=...
              filtered_mean(rs.mean_diameter,bitget(rs.qc_mask,1));
  else
    mean_d=NaN*ones(ntimes,nalts);
  end

  h1000=plot(mean_eff_diameter_prime,rs.altitude/1000,'k'...
      ,mean_eff_diameter, rs.altitude/1000,'r',mean_d,rs.altitude/1000,'b'...
      ,min_eff_diameter,rs.altitude/1000,'g',max_eff_diameter,rs.altitude/ ...
	       1000,'c');
    
  set(gcf,'name','Eff diameter profile')
  grid
  xlabel(['D_e_f_f  (microns) for points with  ',...
	    '\beta''>1e-6  &  \beta_r_a_d>1e-13 m^-^1sr^-^1'])
  ylabel('Altitude (km)');
    
  title(['Time averaged particle size using  ',particle_type_str,'  ',datestr(rs.start_time_num,0)...
	   ,'--->',datestr(rs.last_time_num,13)]);
  if 1
    legend('mean eff dia prime','mean eff dia','mean diameter','min eff dia','max eff dia')
  end
  set(h1000([1:3]),'linewidth',2)  
end

if isfield(rs,'LWC') & radar_present & plot_profiles
   figure(fig1+34)
   [mean_lwc,min_lwc,max_lwc]=filtered_mean(rs.LWC,bitget(rs.qc_mask,1));
   h1000=plot(mean_lwc, rs.altitude/1000,'r',min_lwc...
      ,rs.altitude/1000,'g',max_lwc,rs.altitude/1000,'c');
   legend('mean LWC','min LWC','max LWC')
   grid
    xlabel(['LWC  (gr/m^3) for points with  ','\beta >',min_beta_a_str...
	    ,'  &  \beta_r_a_d>',min_radar_backscat_str, 'm^-^1sr^-^1']);
   ylabel('Altitude (km)');
    
   title(['Time averaged liquid water content  ',particle_type_str,'  '...
     ,datestr(rs.start_time_num,0),'--->',datestr(rs.last_time_num,13)]);
   set(gcf,'name','mean LWC profile')
   set(h1000(1),'linewidth',2);
end

if isfield(rs,'num_particles') & radar_present & plot_profiles
 figure(fig1+36)
   [mean_num,min_num,max_num]=filtered_mean(rs.num_particles,bitget(rs.qc_mask,1));
   h1000=semilogx(mean_num, rs.altitude/1000,'r',min_num...
      ,rs.altitude/1000,'g',max_num,rs.altitude/1000,'c');
    grid
    xlabel(['Number density  (1/liter) for points with  ',...
	    '\beta''>',min_beta_a_str,'  &  \beta_r_a_d>'...
	    ,min_radar_backscat_str,' m^-^1sr^-^1'])
    ylabel('Altitude (km)');
    title(['Time averaged number density using ',particle_type_str,'  '...
	,datestr(rs.start_time_num,0),'--->',datestr(rs.last_time_num,13)]);
    legend('mean','min','max')
    set(h1000(1),'linewidth',2);
    set(gcf,'name','Mean number density profile')
end


 

if 0 %isfield(rs,'od')
  rs.od(lidar_mask==0)=NaN;
  units_str=' ';
  title_str=['Particulate optical depth  '...
	  ,datestr(rs.start_time_num,1)];
  cscale(1:2)=[0 2.5];
  rti_fig(rs.od,times,rs.altitude,cscale...
	  ,title_str,units_str,'li',(fig1+18))
end;


if isfield(rs,'aeri_btemp')
  if prod(size(find(rs.aeri_btemp_wavenumber>2510)))
    refunits='K';
    crange=[180,290];
    dat=rs.aeri_btemp';
    labl=['AERI Brightness Temperature  ' fig_date_str];
    rti_fig(dat',times,rs.aeri_btemp_wavenumber ...
            ,crange,labl,refunits...
       ,'wn',fig1+38);
    if sum(sum(isfinite(dat)))<=0
      figureNoData(blankaerifigurestring,'AERI Brightness Temperature');
    end

  figure(fig1+42)
   set(gcf,'name','Brightness temp vs wavenumber')
   clf
   [mdat,jnk,jnk]=filtered_mean(dat');
   h1=plot(rs.aeri_btemp_wavenumber',mdat);
   set(h1,'linewidth',2);
   ax=axis;
   wvf= rs.aeri_btemp_wavenumber(isfinite(rs.aeri_btemp_wavenumber));
   if ~isempty(wvf)
     axis([min(wvf) max(wvf) ax(3) ax(4)]);
   end
   xlabel('WaveNumber');
   ylabel(['Brightness Temperature vs wavenumber (' refunits ')']);
   %title(['Average ' labl]);
   grid on
   addTopAxes(gca,'WaveLength (\mum)',@wn2wl,['Average ' labl]);

  figure(fig1+44)
  clf
     idxof_570=find(rs.aeri_btemp_wavenumber>570);
    idxof_675=find(rs.aeri_btemp_wavenumber>675);
    idxof_985=find(rs.aeri_btemp_wavenumber>985);%find(mdat<=min(mdat))
    idxof_2510=find(rs.aeri_btemp_wavenumber>2510);
    
    
    h1=plot(times,dat(idxof_570(1),:),'k',times,dat(idxof_675(1),:),'r'...
	    ,times,dat(idxof_985(1),:),'b',times,dat(idxof_2510(1),:),'g');
    if (times(length(times))-rs.start_time_num)<1/25 %less than 1 hours
      datetick('x',13)
    elseif (times(length(times))-rs.start_time_num)<2 %less than 1 day
      datetick('x',15)
    else
      datetick('x',7) 
    end
    set(h1,'linewidth',2)
    set(gcf,'name','Brightness temp vs time');
    xlabel('Time (UT)')
    ylabel('Brightness Temperature (K)');
    title(['Brightness temp, k=570(blk), 675(rd), 985(blu), 2510(grn)' ...
	   ' cm^-^1  ',datestr(rs.start_time_num,1)]);
    ax=axis;
    axis([ax(1:2) 160 300]);
    grid on
   end
end

%AERI radiance plot

if isfield(rs,'aeri1_radiance') | isfield(rs,'aeri2_radiance')
  figure(fig1+46);
  if isfield(rs,'aeri1_radiance')&isfield(rs,'aeri2_radiance')
    subplot(2,1,1)
  end
  if isfield(rs,'aeri1_radiance')
    [mean_rad,min_rad,max_rad]=filtered_mean(rs.aeri1_radiance);
    plot(rs.aeri1_radiancewavenumbers,min_rad,'c'...
       ,rs.aeri1_radiancewavenumbers,max_rad,'g'...
       ,rs.aeri1_radiancewavenumbers,mean_rad,'r')
   
    ax=axis;
    ax(1)=rs.aeri1_radiancewavenumbers(1);
    ax(2)=rs.aeri1_radiancewavenumbers(length(rs.aeri1_radiancewavenumbers));
    ax(4)=max(mean_rad);
    if ~isnan(ax(1)) & ~isnan(ax(2)) & ax(2)>ax(1)
      axis([ax(1:2) 0 ax(4)]);
    end
    grid
    %xlabel('Wavenumber (cm^-^1)')
    ylabel('Radience  mw/( m^2 sr cm^-^1)')
    legend('min','max','mean')
    xlabel('Wavenumber (cm^-^1)');
    title(['Mean radiance (channel 1) ','  '...
	,datestr(rs.start_time_num,0),'--->',datestr(rs.last_time_num,13)]);
  end
  if isfield(rs,'aeri1_radiance')&isfield(rs,'aeri2_radiance')
    subplot(2,1,2)
  end
  if isfield(rs,'aeri2_radiance')
    [mean_rad,min_rad,max_rad]=filtered_mean(rs.aeri2_radiance);
    plot(rs.aeri2_radiancewavenumbers,min_rad,'c'...
       ,rs.aeri2_radiancewavenumbers,max_rad,'g'...
       ,rs.aeri2_radiancewavenumbers,mean_rad,'r')
    ax=axis;
    ax(1)=rs.aeri2_radiancewavenumbers(1);
    ax(2)=rs.aeri2_radiancewavenumbers(length(rs.aeri2_radiancewavenumbers));
    ax(4)=max(mean_rad);
    if ~isnan(ax(1)) & ~isnan(ax(2)) & ax(2)>ax(1) 
      axis([ax(1:2) 0 ax(4)]);
    end
    grid
    xlabel('Wavenumber (cm^-^1)')
    ylabel('Radience  mw/( m^2 sr cm^-^1)')
    legend('min','max','mean')

    title(['Mean radiance (channel 2)','  '...
	,datestr(rs.start_time_num,0),'--->',datestr(rs.last_time_num, ...
						     13)]);
  end
  
end

if isfield(rs,'mwr_brightnesstemp') 
  if isempty(rs.mwr_frequency) || ...
        sum(sum(isfinite(rs.mwr_frequency)))==0
  
  else
  figure(fig1+47);
  clf
  subplot(3,1,3)
  btsky=rs.mwr_brightnesstemp;
  lgnd='';
  switch length(rs.mwr_frequency==5)
   case 5
    h1=plot(times,btsky(:,1),'k',times,btsky(:,2),'r'...
            ,times,btsky(:,3),'b',times,btsky(:,4),'g',times, ...
            btsky(:,5),'m');
    lgnd=sprintf(['Brightness temp, k=%.3f(blk), %.3f(rd), %.3f(blu), %.3f(grn), %.3f(mag)' ...
                  ' GHz'],rs.mwr_frequency)
   case 4
    h1=plot(times,btsky(:,1),'k',times,btsky(:,2),'r'...
            ,times,btsky(:,3),'b',times,btsky(:,4),'g');
    lgnd=sprintf(['Brightness temp, k=%.3f(blk), %.3f(rd), %.3f(blu), %.3f(grn)' ...
                  ' GHz'],rs.mwr_frequency)
   case 3
    h1=plot(times,btsky(:,1),'k',times,btsky(:,2),'r'...
            ,times,btsky(:,3),'b');
    lgnd=sprintf(['Brightness temp, k=%.3f(blk), %.3f(rd), %.3f(blu)' ...
                  ' GHz'],rs.mwr_frequency)
   case 2
    h1=plot(times,btsky(:,1),'k',times,btsky(:,2),'r');
    lgnd=sprintf(['Brightness temp, k=%.3f(blk), %.3f(rd)' ...
                  ' GHz'],rs.mwr_frequency)
   case 1
    h1=plot(times,btsky(:,1),'k');
    lgnd=sprintf(['Brightness temp, k=%.3f GHz'],rs.mwr_frequency)
  end
    
  theax=gca;
  dtime=times(length(times))-rs.start_time_num;
  if dtime<1/25 %less than 1 hours
    datetick('x',13)
  elseif dtime<2 %less than 1 day
    datetick('x',15)
  else
    datetick('x',7) 
  end
  xaxticks=get(gca,'XTick');
  axlim=axis;
  set(gca,'XTickMode','Manual','XTick',xaxticks);
  %set(h1,'linewidth',2)
  set(gcf,'name','Brightness temp vs time');
  xlabel('Time (UT)')
  ylabel('deg K');
  title(lgnd);
  grid on;

  subplot(3,1,1)
  h1=plot(times,rs.mwr_liquidwater,'b');
  theax=gca;
  set(gca,'XTickMode','Manual','XTick',xaxticks);
  set(gca,'XTickLabelMode','manual','XTickLabel',[]);
  ax=axis;
  axis([axlim(1),axlim(2),-40,400])
  ylabel('g/m^2');
  title(['Microwave Radiometer Total liquid water along LOS path  ',datestr(rs.start_time_num,1)]);
  grid on;
  subplot(3,1,2)
  h1=plot(times,rs.mwr_watervapor,'c');
  set(gca,'XTickLabelMode','manual','XTickLabel',[]);
  set(gca,'XTickMode','Manual','XTick',xaxticks);
  theax=gca;
  ax=axis;
  axis([axlim(1),axlim(2),ax(3),ax(4)])
  ylabel('cm');
  title(['Total water vapor along LOS path  ',datestr(rs.start_time_num,1)]);
  grid on;
  end
end

  

if 0
     figure(fig1+31)
     plot(rs.mean_times(:,1),rs.od(:,bins_to_plot))
     ax=axis;
     axis([rs.mean_times(min(nshots,10),1) ax(2) -.2 5]);
     title(['Optical depths   '  datestr(rs.start_time_num,1)]); 
     if (rs.last_time_num-rs.start_time_num)<= 3 %less than one day
         datetick('x','HH:MM');
     else
         datetick('x','dd');
     end;
     datetick('x',13);
     z=num2str(round(rs.altitudes(bins_to_plot)));
     legend(z)
     grid
     ylabel('od')
  
end
 

if isfield(rs,'local_met_temperature')
  figure(fig1+48)
  plot(rs.mean_times,rs.local_met_temperature)
  title(['Local temperature at 327m above msl  ',datestr(rs.start_time_num,1)]);
  grid
  datetick('x');
  
  xlabel('Time (UT)')
  ylabel('Temperature (deg C)')
end

if isfield(rs,'local_met_wind_speed')
  figure(fig1+49)
  plot(rs.mean_times,rs.local_met_wind_speed)
  title(['Local wind speed at 327m above msl  ',datestr(rs.start_time_num,1)]);
  grid
  datetick('x');
  xlabel('Time (UT)')
  ylabel('Wind speed (m/s)')
end

if isfield(rs,'local_met_wind_dir')
  figure(fig1+50)
  if (max(rs.local_met_wind_dir)-min(rs.local_met_wind_dir))<300
    plot(rs.mean_times,rs.local_met_wind_dir)
    ax=axis;
    axis([ax(1:2) 0 360])
  else
    temp=rs.local_met_wind_dir;
    temp(temp<180)=temp(temp<180)+360;
    plot(rs.mean_times,temp)
    ax=axis;
    axis([ax(1:2) 180 540])
  end
  
  title(['Local wind direction at 327m above msl  ',datestr(rs.start_time_num,1)]);
  grid
  datetick('x');
  xlabel('Time (UT)')
  ylabel('Wind direction (deg)')
end

if isfield(rs,'local_met_solarflux')
  figure(fig1+51)
  plot(rs.mean_times,rs.local_met_solarflux)
  title(['Solar flux  ',datestr(rs.start_time_num,1)]);
  grid
  datetick('x');
  xlabel('Time (UT)')
  ylabel('Solar flux (W/m^2)')
end
fieldnames(rs)

if isfield(rs,'use_gps_altitude') && rs.('use_gps_altitude')~=0
  figure(fig1+52)
  plot(times,10*rs.pitch_angle...
       ,times,rs.roll_angle)
  xlabel('Time (UT)')
  ylabel('Angle (deg)')
  grid on
  legend('10*pitch','Roll');
  ax=axis;
  axis([rs.mean_times(1) rs.mean_times(length(rs.mean_times)) ax(3:4)])
  datetick('x');
  title(['Aircraft pitch, roll angle  ',datestr(rs.start_time_num,1)])
  set(gcf,'name','aircraft pitch, roll')

  figure(fig1+53)
  [nl]=size(rs.aircraft_lat);
  dt=(rs.mean_times(2)-rs.mean_times(1))*24*60;  %dt in minutes
  dn=ceil(2/dt);
  plot(rs.aircraft_long(1:dn:nl),rs.aircraft_lat(1:dn:nl),'.' ...
       ,rs.aircraft_long(1:dn:nl),rs.aircraft_lat(1:dn:nl),'or')
  for i=1:10*dn:nl
     text(rs.aircraft_long(1:dn*10:nl),rs.aircraft_lat(1:dn*10:nl)...
	  ,datestr(rs.mean_times(1:dn*10:nl),15));
  end
  title(['Aircraft location    ',datestr(rs.start_time_num,1)]);
  ylabel('Latitude (deg)')
  xlabel('Longitude (deg)')
  grid on
  %ax=axis;
  %axis([floor(ax(1)-.1) ceil(ax(2)+.1) floor(ax(3)-.1) ceil(ax(4)+.1)]);
  set(gcf,'name','Aircraft track')
end


if 0
  if plotall>=0 %bring first five figures to front
  figPresent=get(0,'Children');
  for i=([0:4]+fig1)
    if sum(figPresent==i)>0
      figure(i)
    end
  end
  %figure(fig1+3)
  %figure(fig1+2)
  %figure(fig1+1)
  %figure(fig1)
end
end
return






function [mean_profile,min_profile,max_profile]=filtered_mean(input_array,mask);
%function [mean_profile,min_profile,max_profile]=filtered_mean(input_array,[mask]);
%generate mean profile with profile of minimum and max values ignoring NaN's and infinities
%assume input_array(ntimes,naltitudes) or input_array(ntimes)
%disregard points where optional array mask=0;
%provide mean_profile(altitude),min_profile(altitude),max_profile(altitude)
%find valid data points 
    if nargin==1
      mask=ones(size(input_array));
    end
    mask(~isfinite(input_array))=0;
    input_array(mask==0)=0;
    mean_profile=sum(input_array,1)./sum(mask,1);
    input_array(mask==0)=-inf;
    max_profile=max(input_array,[],1);
    input_array(mask==0)=inf;
    min_profile=min(input_array,[],1);
return
    

function [sum_profile,good_point_fraction]=filtered_sum(input_array,mask);
%[sum_profile,good_point_fraction(filtered_sum(input_array,mask);

   
   if nargin==1
     mask=ones(size(input_array));
     mask(~isfinite(input_array))=0;
     input_array(mask==0)=0;
     sum_profile=sum(input_array,1);
   else
     mask(~isfinite(input_array))=0;
     input_array(mask==0)=0;
     sum_profile=sum(input_array,1);
   end
   array_size=size(mask);
   good_point_fraction=sum(mask,1)./array_size(1);
   return
   
function addTopAxes(ax,label,xlfunc,dastitle)
  ca=gca;
  axes(ax);
  apos=get(gca,'position');
  set(gca,'position',[apos(1) apos(2), apos(3), apos(4)*.90]);
  set(gca,'XTickMode','manual','XLimMode','manual');
  ytic=str2num(get(gca,'Xticklabel'));
  yv=get(gca,'XTick');
  yl=get(gca,'XLim');
  ym=find(yv<=yl(2) & yv>=yl(1));
  ytic=ytic(ym);
  ytickvals=feval(xlfunc,ytic);
  nlabels=length(ytickvals);
  ax=axis;
  %add mJ axis on right
  ax1=gca;
  hold on
  ax3=axes('Position',get(ax1,'Position'),'YAxisLocation','right'...
	   , 'XAxisLocation','top','Color','none','ytick',[],'TickLength',[0,0]);
  set(ax3,'xTickMode','manual','xlimmode','manual','xtick',yv(ym),'xLim',yl,'xTickLabel',num2str(ytickvals,'%.1f'))
  xlabel(label);
  title(dastitle)
  axes(ca);
return
 

function wl=wn2wl(wn)
wn(:);
wl=10000.0./wn(:);
return
