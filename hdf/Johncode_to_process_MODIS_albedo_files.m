%Johncode_to_process_MODIS_albedo_files.m


flag_plot_cells='no';  %for interactive plotting
data=['MCD43GF_CMG'];
list=cellstr(data);
ddeg=30/3600;  %30 arcsec = 30/3600 = 1/120 deg
lonMODalb=[-180:ddeg:180];
lonMODalb=lonMODalb(1:end-1);
latMODalb=[90:-ddeg:-90];
latMODalb=latMODalb(1:end-1);
km_input=20; %1/2 the length of the desired grid cell
arclenval=km2deg(km_input*sqrt(2));
jday_MOC=cumdays_nonleap(month)'+day;
[table_AOD,table_SZA,table_fracdiffuse]=readMODIS_fracdiffuse_table; %reads MODIS diffuse fraction table
direc_MODalb_param='c:\johnmatlab\MODIS_albedo_param_files_BU_2007\';
meanf_geo=zeros(1,length(Latitude_fl));
meanf_iso=zeros(1,length(Latitude_fl));
meanf_vol=zeros(1,length(Latitude_fl));
stdf_geo=zeros(1,length(Latitude_fl));
stdf_iso=zeros(1,length(Latitude_fl));
stdf_vol=zeros(1,length(Latitude_fl));
albedo_sfc_calc=zeros(289,1);
surfalb=zeros(289,length(Latitude_fl));

%%for jdayMODalb=1:1,  %change this to 1:1 for testing
for jdayMODalb=1:46,  %change this to 1:1 for testing
    %tic
    kdayuse=find(jday_MOC>=daybeg_MOD_alb(jdayMODalb)&jday_MOC<daybeg_MOD_alb(jdayMODalb+1));
    jsav=find(ig>=kdayuse(1)&ig<=kdayuse(end));
    iguse=ig(jsav);
    latout=[];
    lonout=[];
    for kk=1:4,
        [alatout,blonout]=reckon(Latitude_fl(iguse),Longitude_fl(iguse),arclenval,45+(kk-1)*90);
        latout(:,kk)=alatout;
        lonout(:,kk)=blonout;
    end
    latout(:,5)=latout(:,1);
    lonout(:,5)=lonout(:,1);
    %now open MODIS albedo parameter data files
    filenameMODalb_geo=sprintf('MCD43GF_geo_shortwave_%03d_2007.hdf',daybeg_MOD_alb(jdayMODalb));
    filenameMODalb_iso=sprintf('MCD43GF_iso_shortwave_%03d_2007.hdf',daybeg_MOD_alb(jdayMODalb));
    filenameMODalb_vol=sprintf('MCD43GF_vol_shortwave_%03d_2007.hdf',daybeg_MOD_alb(jdayMODalb));
    buffer_geo = read_L3_grid_file_000([direc_MODalb_param filenameMODalb_geo],3,list);
    buffer_iso = read_L3_grid_file_000([direc_MODalb_param filenameMODalb_iso],3,list);
    buffer_vol = read_L3_grid_file_000([direc_MODalb_param filenameMODalb_vol],3,list);
    for jj=1:length(iguse),
        jyuse=find(latMODalb>=min(latout(jj,1:4))&latMODalb<=max(latout(jj,1:4)));
        jxuse=find(lonMODalb>=min(lonout(jj,1:4))&lonMODalb<=max(lonout(jj,1:4)));
        latuse=ones(length(jxuse),1)*latMODalb(jyuse);
        lonuse=lonMODalb(jxuse)'*ones(1,length(jyuse));
        inval=inpolygon(lonuse,latuse,lonout(jj,:),latout(jj,:));
        [ri,rj]=find(inval==1);
        if strcmp(flag_plot_cells,'yes')
            hold off
            plot_gridcellboundaries_and_points
            pause
        end
        if ~isempty(ri) & ~isempty(rj)
            kxuse=jxuse(unique(ri));
            kyuse=jyuse(unique(rj));
            valint16geo=buffer_geo.MCD43GF_CMG(kxuse,kyuse);
            valueuse_geo=double(valint16geo(valint16geo>=0 & valint16geo<=1000))/1000;
            meanf_geo(iguse(jj))=nanmean(valueuse_geo);
            stdf_geo(iguse(jj))=nanstd(valueuse_geo);
            valint16iso=buffer_iso.MCD43GF_CMG(kxuse,kyuse);
            valueuse_iso=double(valint16iso(valint16iso>=0 & valint16iso<=1000))/1000;
            meanf_iso(iguse(jj))=nanmean(valueuse_iso);
            stdf_iso(iguse(jj))=nanstd(valueuse_iso);
            valint16vol=buffer_vol.MCD43GF_CMG(kxuse,kyuse);
            valueuse_vol=double(valint16vol(valint16vol>=0 & valint16vol<=1000))/1000;
            meanf_vol(iguse(jj))=nanmean(valueuse_vol);
            stdf_vol(iguse(jj))=nanstd(valueuse_vol);
            
            clear valint16geo valint16iso valint16vol
            %clear valueuse_geo valueuse_iso valueuse_vol
        else
            meanf_geo(iguse(jj))=NaN;
            meanf_iso(iguse(jj))=NaN;
            meanf_vol(iguse(jj))=NaN;
        end
        %
        [frac_diffuse]=tableinterpolate(table_AOD,table_SZA,table_fracdiffuse,ones(289,1)*AODmidvis(iguse(jj)),SZAfine_fl(:,iguse(jj)));
        [albedo_sfc_calc] = calc_sfc_albedo_Schaaf(meanf_iso(iguse(jj)),meanf_vol(iguse(jj)),meanf_geo(iguse(jj)),frac_diffuse',SZAfine_fl(:,iguse(jj)));
        %%[albedo_sfc_calc_array] = calc_sfc_albedo_Schaaf(valueuse_iso,valueuse_vol,valueuse_geo,frac_diffuse',SZAfine_fl(:,iguse(jj)));
        %%meansfcalb=mean(albedo_sfc_calc_array,1)';
        surfalb(:,iguse(jj))=albedo_sfc_calc;
    end
    clear buffer_geo buffer_iso buffer_vol
    fprintf('jdayMODalb:%d\n',jdayMODalb)
end

