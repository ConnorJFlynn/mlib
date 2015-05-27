function [rs]=make_data_quality_mask(rs,qc_params,show_masks);
%[rs] = make_data_quality_mask(rs,qc_params,[show_masks]);
%
%
%Update qc_mask variable in lidar data structure using threshold values
%supplied in the user supplied sturcture qc_params. This provides data
%quality checks. Data arrays other than rs.qc_mask are not affected by
%this routine. The user may apply the mask bits as needed.
%
%rs         = data structure returned by readahsrl.m
%             rs will include an updated qc_mask on return from this routine.
%qc_params  = matlab structure containing some, or all, of the following mask threshold parameters:
%  qc_param.lock_level         = mask if data lock level exceeds this pararmeter
%                                   lock level values,  0<qc_param.lock_level<1
%                                   (typical value =1, but often not supplied)
%  qc_param.seed_percent       = mask if fraction of unseed shots>threshold
%                                   (typical value >0.5)
%  qc_param.mol_snr            = mask if 1/sqrt(mol_counts)<threshold.
%                                   (select to suppress noise above opaque clouds,usually>=1)
%  qc_param.backscat_snr       = mask if backscat/std_backscat <threshold.
%  qc_param.mol_lost           = >0 mask altitudes after first point with
%                                   molecular_counts<qc_param.mol_lost.
%                              = 0 disable mol_lost mask
%                                   (select to suppress noise above
%                                   opaque clouds,usually>=1)
%  qc_param.min_beta_a         = min acceptable lidar backscatter 1/(m sr)
%  qc_param.min_radar_backscat = min acceptable radar backscatter 1/(m sr)
%  qc_param.min_radar_dBz      = min acceptable radar dBz
%                                    if min_radar_dBz is provided it
%                                    replaces min radar_backscat. 
%  qc_param.min_lidar_alt      = mask lidar data below this altitude  (meters)
%  qc_param.min_radar_alt      = mask radar data below this altitude  (meters)
%
%show_masks = 2 for all mask plots, 1 for masked backscat plot, or 0 for no plots
%                (default,  show_masks=0)
%rs.qc_mask = data quality mask with same dimensions as data arrays in rs
%             masks are contained in bit-planes of qc_mask as follows:
%  complete_mask       =1   % bit 1, and of mask bits 2-->8
%  lidar_ok_mask       =2   % bit 2, lidar data is present.
%  lock_quality_mask   =3   % bit 3, quality of I2 lock.
%  seed_quality_mask   =4   % bit 4, min seed percent
%  mol_count_snr_mask  =5   % bit 5, 1/sqrt(mol_counts+mol_dark_counts)
%  backscat_snr_mask   =6   % bit 6, lidar_backscat SNR ok
%  mol_lost_mask       =7   % bit 7, molecular signal extinguished
%  beta_a_mask         =8   % bit 8, min lidar backscatter crosssection
%  radar_backscat_mask =9   % bit 9, min radar backscatter crosssection
%  radar_ok_mask       =10  % bit 10, radar data is present
%  aeri_ok_mask        =11  % bit 11, aeri data is present
%  aeri_qc_mask        =12  % bit 12, aeri data has been quality checked
%Note: MatLab refers to the lowest bitplane as bit 1.
%
%see our web page for further documentation--click on 'Data Quality Masking'
%on the 'Process and Export NetCDF Data' web page.

% (c) 2007, Ed Eloranta, University of Wisconsin Lidar Group
% eloranta@lidar.ssec.wisc.edu


if nargin==1
  fprintf('\nError---Too few input parameters\n')
  return
elseif nargin==2 
  show_masks=0;
elseif nargin==3
  %show_masks is provided
else
  fprintf('\nERROR---Too many input parameters\n'); 
end

%show_masks=2  %force mask plots

if 0
%do data quality checks
%qc_mask contains different data masks in different matlab bit planes
%as identified below.
complete_mask_bit       =1;   % bit 1, and of all mask planes
lidar_ok_mask_bit       =2;   % bit 2, lidar data is present
lock_quality_mask_bit   =3;   % bit 3, quality of I2 lock
seed_quality_mask_bit   =4;   % bit 4, min seed percent
mol_count_snr_mask_bit  =5;   % bit 5, 1/sqrt(mol_counts+mol_dark_counts)
backscat_snr_mask_bit   =6;   % bit 6, std_err_lidar_backscat/lidar_backscat
mol_lost_mask_bit       =7;   % bit 7, molecular signal extinguished
min_backscat_mask_bit   =8;   % bit 8, min acceptable lidar backscatter
min_radar_backscat_bit  =9;   % bit 9, min acceptable radar backscatter
radar_ok_mask_bit       =10;  % bit 10, radar data is present
aeri_ok_mask_bit        =11;  % bit 11, aeri data is present
aeri_qc_mask_bit        =12;  % bit 12, aeri data has been quality checked
end

if isfield(rs,'mean_times')
  times=rs.mean_times;
else
  times=rs.time_nums;
end

rs

%initialize all mask bits as bad in data quality mask
ntimes=length(times);
nalts=length(rs.altitude);

qc_mask=extract_qc_bits(uint32(ones(ntimes,nalts)).*intmax('uint32'));
%qc_mask.complete_mask(:,:)=true;

%if min radar reflectivity is supplied use it to define min_radar_backscatter.
%if isfield(qc_params,'min_radar_dBz')
%  min_radar_backscat= ...
%      reflectivityToBackscatterCrossSection(qc_params.min_radar_dBz);
%elseif isfield(qc_params,'min_radar_backscat')
%  min_radar_backscat=qc_params.min_radar_backscat;
%end

if isfield(qc_params,'min_radar_alt')
  min_radar_alt=qc_params.min_radar_alt;
else
  min_radar_alt=0;
end
if isfield(qc_params,'min_lidar_alt')
  min_lidar_alt=qc_params.min_lidar_alt;
else
  min_lidar_alt=0;
end



%remove mask bits at points which  don't meet qc thresholds
  %create mask for laser shots with proper frequency lock to I2 line
  if isfield(rs,'lock_quality') & isfield(qc_params,'lock_level')
    temp=ones(ntimes,1);
    temp(isnan(rs.lock_quality) | rs.lock_quality<qc_params.lock_level)=0;
    qc_mask.lock_quality_mask=temp*ones(nalts,1)';
    %clear bit 1 where lock_quality_mask_bit is cleared
    %qc_mask.complete_mask(~qc_mask.lock_quality_mask)=false;
  end


  %add mask for seed % if requested
  if isfield(rs,'seed_quality') & isfield(qc_params,'seed_percent')
    temp=ones(ntimes,1);
    temp((1-rs.seed_quality)>qc_params.seed_percent)=0;
    qc_mask.seed_quality_mask=temp*ones(nalts,1)';
    %qc_mask.complete_mask(~qc_mask.seed_quality_mask)=false;
  end


  if isfield(rs,'molecular')
    rs.molecular_counts=rs.molecular;
  end
  
  if isfield(rs,'mol_dark_count')
    darkcountsize=size(rs.mol_dark_count);
    if darkcountsize(2)==nalts
      darkcountmatr=1;
    else
      darkcountmatr=ones(1,nalts);
    end
  end
  
  %add mask for mol photon counting error
  if isfield(rs,'mol_dark_count') & isfield(rs,'molecular_counts')& isfield(qc_params,'mol_snr')
    temp=ones(ntimes,nalts);   
    %note: molecular counts includes dark counts
    s_to_noise=(rs.molecular_counts-rs.mol_dark_count*darkcountmatr)./sqrt(rs.molecular_counts);
    temp(s_to_noise<qc_params.mol_snr |~isfinite(rs.molecular_counts))=0;
    qc_mask.mol_count_snr_mask=temp;
   % qc_mask.complete_mask(~qc_mask.mol_count_snr_mask)=false;
  end
 

  
 
  %add mask for beta_a_backscat snr
  if isfield(rs,'beta_a_backscat') & isfield(rs,'std_beta_a_backscat')...
	& isfield(qc_params,'backscat_snr')
    temp=ones(size(rs.std_beta_a_backscat));%ntimes,nalts);
    temp(~isfinite(rs.std_beta_a_backscat))=0;
    temp((rs.beta_a_backscat./rs.std_beta_a_backscat)<qc_params.backscat_snr)=0;
    temp(:,rs.altitude<min_lidar_alt)=0; %mask lowest lidar alts
    qc_mask.backscat_snr_mask=temp;
    %qc_mask.complete_mask(~qc_mask.backscat_snr_mask)=false;
    
  end
  
  
  
  %add mask for min acceptable lidar backscatter cross section 
  if isfield(rs,'beta_a_backscat') & isfield(qc_params,'min_beta_a')
    temp=ones(size(rs.beta_a_backscat));
    temp(rs.beta_a_backscat<qc_params.min_beta_a |~isfinite(rs.beta_a_backscat))=0;
    temp(:,rs.altitude<min_lidar_alt)=0; %mask lowest lidar alts
    qc_mask.min_backscat_mask=temp;
    %qc_mask.complete_mask(~qc_mask.min_backscat_mask)=false;
  end
  
  %add mask for min acceptable radar backscatter cross section 
  %and mask for radar ok
  if isfield(rs,'radar_backscattercrosssection')...
	& (isfield(qc_params,'min_radar_backscat') |isfield(qc_params,'min_radar_dBz')) 
    temp=ones(size(rs.radar_backscattercrosssection));
    temp(rs.radar_backscattercrosssection< qc_params.min_radar_backscat)=0;
    temp(:,rs.altitude<min_radar_alt)=0; %mask lowest radar alts
    qc_mask.radar_backscat_mask=temp;
    %qc_mask.complete_mask(~qc_mask.min_radar_mask)=false;
    %now check for NaN's indicating that radar is not providing profiles.
    temp=ones(size(rs.radar_backscattercrosssection));
    temp(isnan(rs.radar_backscattercrosssection))=0;
    qc_mask.radar_ok_mask=temp;
    %qc_mask=qc_mask-2^(radar_ok_mask_bit-1)*temp;
    %qc_mask.complete_mask(~qc_mask.radar_ok_mask)=false;
  end
  
  
  
  %add mask for molecular signal lost and lidar_ok_mask 
  if isfield(rs,'molecular_counts')& isfield(rs,'mol_dark_count')...
	& isfield(qc_params,'mol_lost') 
    temp=rs.molecular_counts-rs.mol_dark_count*darkcountmatr;
    temp(temp<qc_params.mol_lost)=NaN;
    temp(:,1)=0;
    temp(:,rs.altitude<min_lidar_alt)=0;
    temp(isnan(cumsum(temp,2)))=0; 
    qc_mask.mol_lost_mask=temp;
    %qc_mask.complete_mask(~qc_mask.mol_lost_mask)=false;
    
    %lidar_ok_mask cleared for lowest alts.
    temp(:,rs.altitude<min_lidar_alt)=0;
    %[nt,na]=size(temp);
    %temp=temp(:,1);
    %temp=temp*ones(size(rs.altitude))';
    qc_mask.lidar_ok_mask=temp;%%qc_mask-2^(lidar_ok_mask_bit-1)*temp;
    %qc_mask.complete_mask(~qc_mask.lidar_ok_mask)=false;
   
  end

  

%add mask bits for aeri data

  %is aeri data present
 
  
%add or update qc_mask in structure rs  
[mtmp,qc_mask,ub]=compress_qc_bits(qc_mask);
qc_mask.complete_mask=qc_mask.complete_mask_runtime;
mtmp=compress_qc_bits(qc_mask);
rs.qc_mask=mtmp;%bitor(mtmp,bitcmp(ub));
rs.processingStruct.qc_params=qc_params;



if show_masks == 2 
 title_str='Lidar signal present mask (red ok)';
 rti_fig(qc_mask.lidar_ok_mask+1,times,[rs.altitude(1) rs.altitude(nalts)]...
	 ,[0 0 1 ; 1 0 0],title_str,{'lidar missing','lidar present'}...
	 ,'cl',998)

 title_str='Lock quality mask (red ok)';
 rti_fig(qc_mask.lock_quality_mask+1,times,[rs.altitude(1) rs.altitude(nalts)]...
	 ,[0 0 1 ; 1 0 0],title_str,{'no lock','freq locked'}...
	 ,'cl',999)

 title_str='Seed quality mask (red ok)';
  rti_fig(qc_mask.seed_quality_mask+1,times,[rs.altitude(1) rs.altitude(nalts)]...
	 ,[0 0 1 ; 1 0 0],title_str,{'not seeded','seeding ok'}...
	 ,'cl',1000)

 title_str='Molecular count snr mask (red ok)';
  rti_fig(qc_mask.mol_count_snr_mask+1,times,[rs.altitude(1) rs.altitude(nalts)]...
	 ,[0 0 1 ; 1 0 0],title_str,{'low mol snr','mol snr ok'}...
	 ,'cl',1001)
 	   
 title_str='Backscatter error quality mask (red ok)';
 rti_fig(qc_mask.backscat_snr_mask+1,times,[rs.altitude(1) rs.altitude(nalts)]...
	 ,[0 0 1 ; 1 0 0],title_str,{'noisy','data 0k'}...
	 ,'cl',1002) 

 title_str='Molecular signal lost mask (red ok)';
  rti_fig(qc_mask.mol_lost_mask+1,times,[rs.altitude(1) rs.altitude(nalts)]...
	 ,[0 0 1 ; 1 0 0],title_str,{'mol lost','mol present'}...
	 ,'cl',1003) 
  title_str='Min lidar backscatter cross section mask (red ok)';
   rti_fig(qc_mask.min_backscat_mask+1,times,[rs.altitude(1) rs.altitude(nalts)]...
	 ,[0 0 1 ; 1 0 0],title_str,{'backscat low','backscat ok'}...
	 ,'cl',1004)
   

 title_str='Min radar backscatter cross section mask (red ok)';
  rti_fig(qc_mask.radar_backscat_mask+1,times,[rs.altitude(1) rs.altitude(nalts)]...
	 ,[0 0 1 ; 1 0 0],title_str,{'radar sig low','radar sig ok'}...
	 ,'cl',1005)
 

 title_str='Radar present mask (red ok)';
 rti_fig(qc_mask.radar_ok_mask+1,times,[rs.altitude(1) rs.altitude(nalts)]...
	 ,[0 0 1 ; 1 0 0],title_str,{'radar missing','radar present'}...
	 ,'cl',1006)
 
end

if show_masks==1 | show_masks==2

 mask=qc_mask.beta_a_mask;%bitget(qc_mask,3) & bitget(qc_mask,4) & bitget(qc_mask,5) & bitget(qc_mask,6)...
  %     &bitget(qc_mask,7) &bitget(qc_mask,8); 
 title_str=['Lidar backscatter cross section (Masked values shown in black and white)'];
 rti_fig(rs.beta_a_backscat,times,[rs.altitude(1) rs.altitude(nalts)]...
	,[1e-8 1e-3],title_str,' ','gg',1007,mask)
 
 if isfield(qc_params,'min_radar_backscat') | isfield(qc_params,'min_radar_dBz')
 
    if isfield(qc_params,'min_radar_backscat')  
       title_str=['Radar backscatter cross section (values less than  ', ...
	    num2str(qc_params.min_radar_backscat),'  shown in black and' ...
		    ,' white)'];
    else
      title_str=['Radar backscatter cross section (values less than  ', ...
	    num2str(qc_params.min_radar_dBz),' dBz  shown in black and' ...
		    ,' white)'];	    
		  
    end
	    
    rti_fig(rs.radar_backscattercrosssection,times,[rs.altitude(1) rs.altitude(nalts)]...
	,[1e-14 1e-7],title_str,' ','gg',1008,qc_mask.radar_backscat_mask)
		  

 end %if either radar min field
end %if show masks

