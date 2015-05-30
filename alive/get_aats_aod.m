function all_aats = get_aats_aod(mfr);
%output lat,lon, dist, alt, aod(), gamma, alpha, a0
% mfr = ancload;
if ~exist('mfr','var')
%     disp('Load a netcdf file from SGP to provide lat, lon, alt');
%     mfr = ancload;
    mfr.vars.lat.data = 36.6049995422363 ;
    mfr.vars.lon.data = -97.4850006103516;
    mfr.vars.alt.data = 318;
end

if ~exist('aats_ext.mat','file')
%% Read all the extinction profiles, pick off base of profile, sort by time
aats_ext_dir = ['C:\case_studies\Alive\data\schmid-aats\atts.01-Mar-2006\Ver2\'];
flist = dir([aats_ext_dir,'*_p.asc']);
for f = 1:length(flist)
    disp(['Processing file #',num2str(f),' of ', num2str(length(flist))])
    prod = rd_AATS14_ALIVE('aod_profile', [aats_ext_dir,flist(f).name]);
    [alt,ind] = unique(prod.alt_gps);
    for pf = fieldnames(prod)'
        if ~(strcmp('lambda',pf)|strcmp('product',pf))
        prod.(char(pf)) = prod.(char(pf))(:,ind);
        end
    end
    ind = find((prod.alt_gps-prod.alt_gps(1))<=.1);
    
    for pf = fieldnames(prod)'
        if ~(strcmp('lambda',pf)|strcmp('product',pf))
        aats_ext.(char(pf))(:,f) = mean((prod.(char(pf))(:,ind))')';
        else
            aats_ext.(char(pf)) = prod.(char(pf));
        end
    end
end
[tmp,ind] = sort(aats_ext.time);
    for pf = fieldnames(aats_ext)'
        if ~(strcmp('lambda',pf)|strcmp('product',pf))
        aats_ext.(char(pf)) = aats_ext.(char(pf))(:,ind);
        end
    end

save aats_ext.mat aats_ext
else
    load aats_ext.mat
end

aats_dir = ['C:\case_studies\Alive\data\schmid-aats\atts.01-Mar-2006\Ver2\'];
flist = dir([aats_dir,'*_r.asc']);
for f = 1:length(flist)
    disp(['Processing file #',num2str(f),' of ', num2str(length(flist))])
    prod = rd_AATS14_ALIVE('aod_normal', [aats_dir,flist(f).name]);
%     for d = length(prod.time):-1:1
%         prod.dist(d) = geodist(mfr.vars.lat.data, mfr.vars.lon.data, prod.lat(d), prod.lon(d))/1000;
%     end

    prod.dist = geodist(mfr.vars.lat.data, mfr.vars.lon.data, prod.lat, prod.lon)/1000;
    below = (prod.alt_gps-mfr.vars.alt.data/1000) < .3;
    near = prod.dist < 10;
    this_aats = cutem(prod, below&near&prod.aod_flag);
    if ~exist('all_aats','var')
        all_aats = this_aats;
    else
        all_aats = catem(all_aats, this_aats);
    end
end

%%
for t = length(all_aats.time):-1:1
    [tmp,ind] = min(abs(aats_ext.time-all_aats.time(t)));
    all_aats.profile_time(t) = aats_ext.time(ind);
    all_aats.profile_lat(t) = aats_ext.lat(ind);
    all_aats.profile_lon(t) = aats_ext.lon(ind);
    all_aats.profile_alt_gps(t) = aats_ext.alt_gps(ind);
    all_aats.profile_ext(:,t) = aats_ext.ext(:,ind);
    all_aats.profile_aod(:,t) = aats_ext.aod(:,ind);
    all_aats.profile_a0(t) = aats_ext.a0_ext(ind);
    all_aats.profile_a1(t) = aats_ext.alpha_ext(ind);
    all_aats.profile_a2(t) = aats_ext.gamma_ext(ind);
end

all_aats.col_aod = all_aats.aod + all_aats.profile_ext.*(ones([13,1])*(all_aats.alt_gps-mfr.vars.alt.data/1000));
for d = length(all_aats.profile_time):-1:1
    all_aats.profile_dist(d) = geodist(mfr.vars.lat.data, mfr.vars.lon.data, all_aats.profile_lat(d), all_aats.profile_lon(d))/1000;
end

V = datevec(all_aats.time);
yyyy = V(:,1);
mm = V(:,2);
dd = V(:,3);
HH = V(:,4);
MM = V(:,5);
SS = V(:,6);
doy = serial2doy(all_aats.time)';
HHhh = (doy - floor(doy)) *24;
%
txt_out = [yyyy, mm, dd, HH, MM, SS, doy, HHhh, ...
    all_aats.lat',...
    all_aats.lon',...
    all_aats.dist',...
    all_aats.alt_gps', ...
    all_aats.alt_pres', ...
    all_aats.pres', ...
    all_aats.gamma', ...        
    all_aats.alpha',...
    all_aats.a0', ...
    all_aats.profile_a2', ...        
    all_aats.profile_a1', ...
    all_aats.profile_a0', ...
    all_aats.profile_lat',...
    all_aats.profile_lon',...
    all_aats.profile_dist',...
    all_aats.profile_alt_gps', ...
    all_aats.col_aod(1,:)', ...
    all_aats.col_aod(2,:)', ...
    all_aats.col_aod(3,:)', ...
    all_aats.col_aod(4,:)', ...
    all_aats.col_aod(5,:)', ...
    all_aats.col_aod(6,:)', ...
    all_aats.col_aod(7,:)', ...
    all_aats.col_aod(8,:)', ...
    all_aats.col_aod(9,:)', ...
    all_aats.col_aod(10,:)', ...
    all_aats.col_aod(11,:)', ...
    all_aats.col_aod(12,:)', ...
    all_aats.col_aod(13,:)', ...
    all_aats.aod(1,:)', ...
    all_aats.aod(2,:)', ...
    all_aats.aod(3,:)', ...
    all_aats.aod(4,:)', ...
    all_aats.aod(5,:)', ...
    all_aats.aod(6,:)', ...
    all_aats.aod(7,:)', ...
    all_aats.aod(8,:)', ...
    all_aats.aod(9,:)', ...
    all_aats.aod(10,:)', ...
    all_aats.aod(11,:)', ...
    all_aats.aod(12,:)', ...
    all_aats.aod(13,:)', ...
    all_aats.profile_ext(1,:)', ...
    all_aats.profile_ext(2,:)', ...
    all_aats.profile_ext(3,:)', ...
    all_aats.profile_ext(4,:)', ...
    all_aats.profile_ext(5,:)', ...
    all_aats.profile_ext(6,:)', ...
    all_aats.profile_ext(7,:)', ...
    all_aats.profile_ext(8,:)', ...
    all_aats.profile_ext(9,:)', ...
    all_aats.profile_ext(10,:)', ...
    all_aats.profile_ext(11,:)', ...
    all_aats.profile_ext(12,:)', ...
    all_aats.profile_ext(13,:)'];
%
header_row = ['yyyy, mm, dd, HH, MM, SS, doy, HHhh, '];
header_row = [header_row, 'lat, lon, dist(km), '];
header_row = [header_row, 'alt_gps(km), alt_pres(km), pres(mb), '];
header_row = [header_row, 'gamma, alpha, a0, '];
header_row = [header_row, 'ext_gamma, ext_alpha, ext_a0, '];
header_row = [header_row, 'profile_lat, profile_lon, profile_dist(km), profile_alt_gps, '];
header_row = [header_row, 'col_aod(',num2str(all_aats.lambda(1)),') , '];
header_row = [header_row, 'col_aod(',num2str(all_aats.lambda(2)),') , '];
header_row = [header_row, 'col_aod(',num2str(all_aats.lambda(3)),') , '];
header_row = [header_row, 'col_aod(',num2str(all_aats.lambda(4)),') , '];
header_row = [header_row, 'col_aod(',num2str(all_aats.lambda(5)),') , '];
header_row = [header_row, 'col_aod(',num2str(all_aats.lambda(6)),') , '];
header_row = [header_row, 'col_aod(',num2str(all_aats.lambda(7)),') , '];
header_row = [header_row, 'col_aod(',num2str(all_aats.lambda(8)),') , '];
header_row = [header_row, 'col_aod(',num2str(all_aats.lambda(9)),') , '];
header_row = [header_row, 'col_aod(',num2str(all_aats.lambda(10)),') , '];
header_row = [header_row, 'col_aod(',num2str(all_aats.lambda(11)),') , '];
header_row = [header_row, 'col_aod(',num2str(all_aats.lambda(12)),') , '];
header_row = [header_row, 'col_aod(',num2str(all_aats.lambda(13)),') , '];
header_row = [header_row, 'aod(',num2str(all_aats.lambda(1)),') , '];
header_row = [header_row, 'aod(',num2str(all_aats.lambda(2)),') , '];
header_row = [header_row, 'aod(',num2str(all_aats.lambda(3)),') , '];
header_row = [header_row, 'aod(',num2str(all_aats.lambda(4)),') , '];
header_row = [header_row, 'aod(',num2str(all_aats.lambda(5)),') , '];
header_row = [header_row, 'aod(',num2str(all_aats.lambda(6)),') , '];
header_row = [header_row, 'aod(',num2str(all_aats.lambda(7)),') , '];
header_row = [header_row, 'aod(',num2str(all_aats.lambda(8)),') , '];
header_row = [header_row, 'aod(',num2str(all_aats.lambda(9)),') , '];
header_row = [header_row, 'aod(',num2str(all_aats.lambda(10)),') , '];
header_row = [header_row, 'aod(',num2str(all_aats.lambda(11)),') , '];
header_row = [header_row, 'aod(',num2str(all_aats.lambda(12)),') , '];
header_row = [header_row, 'aod(',num2str(all_aats.lambda(13)),') , '];
header_row = [header_row, 'low_alt_ext(',num2str(all_aats.lambda(1)),') , '];
header_row = [header_row, 'low_alt_ext(',num2str(all_aats.lambda(2)),') , '];
header_row = [header_row, 'low_alt_ext(',num2str(all_aats.lambda(3)),') , '];
header_row = [header_row, 'low_alt_ext(',num2str(all_aats.lambda(4)),') , '];
header_row = [header_row, 'low_alt_ext(',num2str(all_aats.lambda(5)),') , '];
header_row = [header_row, 'low_alt_ext(',num2str(all_aats.lambda(6)),') , '];
header_row = [header_row, 'low_alt_ext(',num2str(all_aats.lambda(7)),') , '];
header_row = [header_row, 'low_alt_ext(',num2str(all_aats.lambda(8)),') , '];
header_row = [header_row, 'low_alt_ext(',num2str(all_aats.lambda(9)),') , '];
header_row = [header_row, 'low_alt_ext(',num2str(all_aats.lambda(10)),') , '];
header_row = [header_row, 'low_alt_ext(',num2str(all_aats.lambda(11)),') , '];
header_row = [header_row, 'low_alt_ext(',num2str(all_aats.lambda(12)),') , '];
header_row = [header_row, 'low_alt_ext(',num2str(all_aats.lambda(13)),')'];

format_str = ['%d, %d, %d, %d, %d, %0.f, %3.6f, %2.4f, '];
format_str = [format_str, '%2.3f, %2.3f, %2.3f, '];
format_str = [format_str, '%2.3f, %2.3f, %2.3f, '];
format_str = [format_str, '%2.3f, %2.3f, %2.3f, '];
format_str = [format_str, '%2.3f, %2.3f, %2.3f, '];

format_str = [format_str, '%2.3f, %2.3f, %2.3f, %2.3f, '];
format_str = [format_str, '%2.3f, %2.3f, %2.3f, %2.3f, '];
format_str = [format_str, '%2.3f, %2.3f, %2.3f, %2.3f, '];
format_str = [format_str, '%2.3f, %2.3f, %2.3f, %2.3f, %2.3f, '];
format_str = [format_str, '%2.3f, %2.3f, %2.3f, %2.3f, '];
format_str = [format_str, '%2.3f, %2.3f, %2.3f, %2.3f, '];
format_str = [format_str, '%2.3f, %2.3f, %2.3f, %2.3f, %2.3f, '];
format_str = [format_str, '%2.3f, %2.3f, %2.3f, %2.3f, '];
format_str = [format_str, '%2.3f, %2.3f, %2.3f, %2.3f, '];
format_str = [format_str, '%2.3f, %2.3f, %2.3f, %2.3f, %2.3f \n'];

fid = fopen([aats_dir, '/aats_est_col_aod_lowalt_nearsgp.txt'],'wt');
fprintf(fid,'%s \n',header_row );
fprintf(fid,format_str,txt_out');
fclose(fid);


function in = cutem(in, keep)
fields = fieldnames(in);
for f = 1:length(fields)
    temp = char(fields(f));
    if strcmp(temp,'product')|strcmp(temp,'lambda')
        in.(temp) = in.(temp);
    elseif size(in.(temp),1)~=1
        in.(temp) = in.(temp)(:,keep);
    else
        in.(temp) = in.(temp)(keep);
    end
end

function one = catem(one, two)
[temp, inds] = sort([one.time, two.time]);
fields = fieldnames(one);
for f = 1:length(fields)
    temp = char(fields(f));
    if strcmp(temp,'product')|strcmp(temp,'lambda')
        one.(temp) = one.(temp);
    elseif size(one.(temp),1)~=1
        one.(temp)= [one.(temp), two.(temp)];
        one.(temp) = one.(temp)(:,inds);
    else
        one.(temp)= [one.(temp), two.(temp)];
        one.(temp) = one.(temp)(inds);
    end
end


% for all profiles in directory
% read each profile
% compute distance from ARM site
% select only good aod,  below 0.6 km, and within 2 km of site.
