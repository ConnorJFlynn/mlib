function rs=readahsrl(filename,start_time,end_time,min_alt,max_alt);
%rs=readahsrl(filename [,start_time,end_time,min_alt,max_alt]);
%reads a netcdf file created by processed_netcdf and places output
%in a structure.
%filename    =name of file created by processed_netcdf or netCDF structure 
%             (eg 'ahsrl_20070101T0000_20070201T0000_180s_30m_2sn.nc'
%              or name of netCDF structure)
%rs          = matlab structure containing contents of netcdf file
%               (use fieldnames(rs) to list variables in rs)
%.....these are optional, they allow loading part of a file to rs.
%start_time  = begin reading at this time('eg '3-jan-07 21:00')
%end_time    = stop reading at this time('eg  '4-jan-07 12:00')
%              (start and end times can also be entered as datenums)
%min_alt     = only read data above this altitude (km).
%max_alt     = only read data below this altitude (km).


% (c) 2007 Ed Eloranta, University of Wisconsin Lidar group
% eloranta@lidar.ssec.wisc.edu

%do you want debug plots
debug=1;

%check to see if file exists. 
if ~isstruct(filename)
  if exist(filename,'file')
    fprintf(['\nReading file ',filename,'\n']);
  else
    fprintf(['\n\n******', filename,'   was not found*******************\n\n\n']);
    rs=[];
    return
  end
  
end

%read file or accept nc structure.
if ischar(filename)
  filename=strjust(filename,'left');
  filename=deblank(filename);
  nc=netcdf(filename); %read file
else
  nc=filename;
end


processingStruct=netcdfattr2struct(nc,'processing_parameters');

if ~isfield(processingStruct,'qc_params')
  processingStruct.qc_params=struct([]);
end


%create standard matlab datenums forms by adding milliseconds and microseconds
   first_time_vec=nc{'first_time'}(:,:)'; 
   start_time_num=datenum(first_time_vec(1,1:6))+(first_time_vec(1,7)/1000 ...
         +first_time_vec(1,8)/1e6)/(24*60*60);
   last_time_vec=nc{'last_time'}(:,:)';
   last_time_num=datenum(last_time_vec(1,1:6))+(last_time_vec(1,7)/1000 ...
         +last_time_vec(1,8)/1e6)/(24*60*60);
   mean_time_vec=nc{'mean_time'};
   if isempty(mean_time_vec)
     mean_time_vec=nc{'start_time'};
   end
   
%       bmm 3/3/10  convert the ncclass to remove indexing problem
%       from ncdf data
    mean_time_vec = double(mean_time_vec);
    
    
   mean_times=datenum(mean_time_vec(:,1:6))+(mean_time_vec(1,7)/1000 ...
         +mean_time_vec(1,8)/1e6)/(24*60*60);
   %n_times=max(size(mean_time_vec));
   n_times=length(mean_times);
   cal_offsets=nc{'new_cal_offset'}(:)+1;
   
%prepare vector of pointers to calibration info for each time in record
   cal_offsets=cal_offsets(cal_offsets>0);
   pointers_to_cal_index=ones(n_times,1);
   n_cal_times=max(size(cal_offsets)); %number of cal times              
   for i= 2:n_cal_times
      pointers_to_cal_index(cal_offsets(i):n_times)=i;
   end


variables=var(nc);
nvars=length(variables);






rs=struct('start_time_num',start_time_num,'last_time_num',last_time_num,'mean_times',mean_times,'pointers_to_cal_index',pointers_to_cal_index);

if 0
%get global attributes and add them to variables in struct cmd line.
ga=att(nc);
[jnk,n_attributes]=size(ga);

for i=14:n_attributes
cmd_str=[cmd_str,'''', name(ga{i}),'''',',','ga{',num2str(i),'}(:),'];
end
end


%set up a string for eval to place variables in structure rs
for i=1:nvars
  var_name=name(variables{i});
  %skip these variables, already in cmd_str
  if (strcmp(var_name,'base_time') |strcmp(var_name,'first_time')...
       | strcmp(var_name,'last_time') | strcmp(var_name,'time')...
       | strcmp(var_name,'time_offset')| strcmp(var_name,'start_time')...
       | strcmp(var_name,'mean_time')| strcmp(var_name,'new_cal_offset')...
       | strcmp(var_name,'end_time'))
  elseif  strcmp(var_name,'depol')
      %read circular depol in order to compute linear depol
      circular_depol=nc{'depol'}(:,:);
      linear_depol=circular_depol./(2+circular_depol);%convert circular to linear depol
      %place circular and linear depol in cmd_str					      
      rs.('circular_depol')=circular_depol;
      rs.('linear_depol')=linear_depol;
      %nc{'h2o_depol_threshold'}(:)
      water_mask=zeros(size(circular_depol));
      water_mask(linear_depol<=processingStruct.particlesettings.h20_depol_threshold(:))=1;
      rs.('water_mask')=water_mask;
  elseif strcmp(var_name,'raob_time_vector')
      %convert vector times to matlab datenums
      raob_time_vector=eval(sprintf('nc{''%s''}%s;',var_name, ...
                                    ncdimread(nc{var_name})));%nc{'raob_time_vector'};
      raob_time_vector=raob_time_vector(:,1:6);
      rss=size(raob_time_vector);
      if rss(2)~=6
        raob_time_vector=raob_time_vector';
      end
      raob_time_num=datenum(raob_time_vector);
      rs.('raob_time_num')=raob_time_num;
  elseif strcmp(var_name,'raob_station')  
    raob_station=eval(sprintf('nc{''%s''}%s;',var_name,ncdimread(nc{var_name})));
    if length(raob_station)==prod(size(raob_station))
      % if theres only one, its read in transposed...
      % Whiskey? Tango? Foxtrot?  Oh right... Matlab.
      raob_station=transpose(raob_station); 
    end
    rs.(var_name)=raob_station;
  elseif ~isempty(find(strfind(var_name,'profile_')==1))
    pfn=var_name(length('profile_x'):length(var_name));
    if strcmp(pfn,'od')
      pfn='optical_depth';
    end
    if(strcmp(pfn,'depol'))
      pfn='circular_depol';
    end
    if(strcmp(pfn,'cross_counts'))
      pfn='crosspol_counts';
    end
    pfv=eval(sprintf('nc{''%s''}%s;',var_name, ncdimread(nc{var_name})));
    if isfield(rs,'profiles')
      rs.profiles.(pfn)=pfv;
    else
      rs.profiles=struct(pfn,pfv);
    end
  elseif strcmp(var_name,'qc_mask')
    unsignedvar=nc{var_name};
    unsigned(unsignedvar,1);
    rs.(var_name)=unsignedvar(:,:);
  else
     %cmd_str=[cmd_str,'''',var_name,'''', ',nc{','''',var_name,'''','}' ...
      %        ncdimread(nc{var_name}) ',']; 	    
      rs.(var_name)=eval(sprintf('nc{''%s''}%s;',var_name,ncdimread(nc{var_name})));
      
 end %end of of large strcmp
end  %end of for i loop
		    


%cmd_str=cmd_str(:,1:length(cmd_str)-1);
%cmd_str=[cmd_str,');'];
%fprintf('%s\n',cmd_str);
%eval(cmd_str);



%if reading a file close file before return.
if ischar(filename)
    close(nc);
end


%if partial file was requested
if nargin>1
  %check to see that requested time interval is contained in this netcdf file
  if nargin>3
    if (start_time_num>datenum(end_time))...
        | (last_time_num<datenum(start_time))
      fprintf('\n Requested time interval not contained in netcdf file \n\n')
      rs=[];
      return
    end
  end

 %find size of  data arrays
   [ntimes]=length(rs.mean_times);
   [nalts]=length(rs.altitude);
    
  t_indices=1:ntimes;
 
  t_indices=t_indices((rs.mean_times>=datenum(start_time))...
		       & rs.mean_times<=datenum(end_time));

  a_indices=1:nalts;
  a_indices=a_indices(rs.altitude>=min_alt*1000 & rs.altitude<=max_alt*1000);
  rs.altitude=rs.altitude(a_indices);
  rs.mean_times=rs.mean_times(t_indices);
  rs.start_time_str=datestr(rs.mean_times(length(t_indices)));
  rs.end_time_str=datestr(rs.mean_times(1));
  rs.start_time_num=datenum(rs.start_time_str);
  rs.last_time_num=datenum(rs.end_time_str);
  
  %evn though ranges are clippled profiles still computed for full file length
  rs.profiles.optical_depth=rs.profiles.optical_depth(a_indices,1);
  rs.profiles.atten_beta_r_backscat= ...
      rs.profiles.atten_beta_r_backscat(a_indices,1);
  rs.profiles.circular_depol=rs.profiles.circular_depol(a_indices,1);
  rs.profiles.molecular_counts=rs.profiles.molecular_counts(a_indices,1);
  rs.profiles.combined_counts_lo=rs.profiles.combined_counts_lo(a_indices,1);
  rs.profiles.combined_counts_hi=rs.profiles.combined_counts_hi(a_indices,1);
  rs.profiles.crosspol_counts=rs.profiles.crosspol_counts(a_indices,1);
  rs.profiles.beta_a_backscat=rs.profiles.beta_a_backscat(a_indices,1);
  rs.profiles.beta_m=rs.profiles.beta_m(a_indices,1);
  
  vars_cellstruc=fieldnames(rs);
  [n_vars,jnk]=size(vars_cellstruc);


  %trim arrays 
  for i=1:n_vars 
    var_name=['rs.',char(vars_cellstruc(i))];
    if size(eval(var_name))==[ntimes nalts]   %trim size of large data arrays
      eval([var_name,'=',var_name,'(t_indices,a_indices);']);
      %fprintf('%s\n',name);
    elseif size(eval(var_name))==[ntimes 1]    %trim size of 1-d arrays
      eval([var_name,'=',var_name,'(t_indices,1);']);
    elseif size(eval(var_name),2)'==nalts      %time size of cal arrays
      eval([var_name,'=',var_name,'(:,a_indices);']);
    end
  end
end %nargin~=1

%add processing info
rs.processingStruct=processingStruct;

%adjust for changes in field names
if isfield(rs,'molecular')
  rs.molecular_counts=rs.molecular;
end
if isfield(rs,'combined_hi')
  rs.combined_counts_hi=rs.combined_hi;
end
if isfield(rs,'combined_lo')
  rs.combined_counts_lo=rs.combined_lo;
end
if isfield(rs,'combined')
  rs.combined_counts=rs.combined;
end
if isfield(rs,'cross')
  rs.cross_counts=rs.cross;
end

 
[ntimes]=length(rs.mean_times);
[nalts]=length(rs.altitude);
fprintf('\nTime interval:   %s  --> %s\n'...
	  ,datestr(rs.mean_times(1)), datestr(rs.mean_times(ntimes)))
fprintf('Altitude interval: %g --> %g km\n'...
	  ,rs.altitude(1)/1000,rs.altitude(nalts)/1000)
return


function ds=ncdimread(var)
ds='(:';
dims=dim(var);
for i= 2:length(dims)
  ds = [ds ',:'];
end
ds = [ds ')'];
if numel(dims)>0 && length(dims{1})==1
  test=eval(['var' ds ';']);
  testsize=size(test);
  if(testsize(1)~=1)
    ds=[ds ''''];
  end
end
return
