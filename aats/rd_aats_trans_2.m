function aats = rd_aats_trans( aats_file )
% aats = rd_aats_trans( aats_file )

%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
if ~exist('aats_file','var')||~exist(aats_file,'file')
    aats_file = getfullname('*_trans_*.txt','aats_trans');
end
fid = fopen(aats_file);
if fid>0
    [aats.pname, aats.fname,ext] = fileparts(aats_file);
    aats.pname = [aats.pname, filesep]; aats.fname =  [aats.fname, ext];
    tmp1 = fgetl(fid);
    A = textscan(tmp1,'%f');A = A{:};
    tmp2 = fgetl(fid);
    B = textscan(tmp2,'%f'); B = B{:};
    tmp3 = fgetl(fid);
    C = textscan(tmp3,'%s','delimiter',' ');
    D = textscan(fid,['%23c ',repmat('%f ',[1,10]),repmat('%f ',[1,14]),repmat('%f ',[1,14]),repmat('%f ',[1,14]),repmat('%f ',[1,13]),repmat('%f ',[1,13]),repmat('%f ',[1,13]),repmat('%f ',[1,13]),repmat('%f ',[1,13]),repmat('%f ',[1,13]),repmat('%f ',[1,13]), '%*[^\n]']);
    aats.wl = B';
    DD = D{1};
    aats.time = datenum(DD,'dd-mmm-yyyy HH:MM:SS');
    aats.lat = D{2};    aats.lon = D{3};    aats.pres = D{4};
    aats.gps_km = D{5}; aats.sza = D{6}; aats.mRay = D{7};
    aats.maero = D{8}; aats.mO3 = D{9}; aats.CWV_cm = D{10}; aats.L_cld = D{11};
    mark = 11;
    % trans
    mark = mark + 1; mark_end = mark +13;
    yy = [D{mark:mark_end}];
    aats.tr = yy;
    mark = mark_end;
    
    % trans err
    mark = mark + 1; mark_end = mark +13;
    yy = [D{mark:mark_end}];
    aats.tr_err = yy;
    mark = mark_end;
    
    % trans ray
    mark = mark + 1; mark_end = mark +13;
    yy = [D{mark:mark_end}];
    aats.tr_ray = yy;
    mark = mark_end;
    
    % aod
    mark = mark + 1; mark_end = mark +12;
    yy = [D{mark:mark_end}];
    aats.aod = yy;
    mark = mark_end;
    
    % trans O3
    mark = mark + 1; mark_end = mark +12;
    yy = [D{mark:mark_end}];
    aats.tr_O3 = yy;
    mark = mark_end;
    
    % trans NO2
    mark = mark + 1; mark_end = mark +12;
    yy = [D{mark:mark_end}];
    aats.tr_NO2 = yy;
    mark = mark_end;
    
    % trans O4
    mark = mark + 1; mark_end = mark +12;
    yy = [D{mark:mark_end}];
    aats.tr_O4 = yy;
    mark = mark_end;
    
    % trans_CO2_etc
    mark = mark + 1; mark_end = mark +12;
    yy = [D{mark:mark_end}];
    aats.tr_CO2_etc = yy;
    mark = mark_end;
    
    % trans_H2O
    mark = mark + 1; mark_end = mark +12;
    yy = [D{mark:mark_end}];
    aats.tr_H2O = yy;
    mark = mark_end;
    
    % aod_err
    mark = mark + 1; mark_end = mark +12;
    yy = [D{mark:mark_end}];
    aats.aod_err = yy;
    mark = mark_end;
    
    fclose(fid);
else
    disp('bad fid');
end

return

