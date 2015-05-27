[AATS6_filename,pathname]=uigetfile('c:\jens\data\ACE-Asia\AATS6_results\AATS6_profiles\v22\*p_v22.asc','Choose file', 0, 0);
fid=fopen([pathname AATS6_filename]);
for i=1:8
        fgetl(fid);
end

if (strcmp(AATS6_filename(1:4),'RF16'))
    lambda=fscanf(fid,'aerosol wavelengths [10^-9 m]%g%g%g%g');
    fgetl(fid);
    fgetl(fid);
    fgetl(fid);
    fgetl(fid);
    data=fscanf(fid,'%g',[20,inf]);
    fclose(fid);
    UT=data(1,:);
    AATS6_lat=data(2,:);
    AATS6_long=data(3,:);
    AATS6_alt=data(4,:);
    AATS6_AOD=data(5:8,:);
    AATS6_AOD_Error=data(9:12,:);
    alpha=-data(13,:);
    a0=data(14,:);
    AATS6_extinction=data(15:18,:);
    alpha_ext=-data(19,:);
    a0_ext=data(20,:);
    AOD_fit = AATS6_AOD(3,:);
    AOD_fit_err = AATS6_AOD_Error(3,:);
    Ext_fit = AATS6_extinction(3,:);
else
    lambda=fscanf(fid,'aerosol wavelengths [10^-9 m]%g%g%g%g%g');
    fgetl(fid);
    fgetl(fid);
    fgetl(fid);
    fgetl(fid);
    data=fscanf(fid,'%g',[23,inf]);
    fclose(fid);
    UT=data(1,:);
    AATS6_lat=data(2,:);
    AATS6_long=data(3,:);
    AATS6_alt=data(4,:);
    AATS6_AOD=data(5:9,:);
    AATS6_AOD_Error=data(10:14,:);
    alpha=-data(15,:);
    a0=data(16,:);
    AATS6_extinction=data(17:21,:);
    alpha_ext=-data(22,:);
    a0_ext=data(23,:);
    AOD_fit = AATS6_AOD(4,:);
    AOD_fit_err = AATS6_AOD_Error(4,:);
    Ext_fit = AATS6_extinction(4,:);
end