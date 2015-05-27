function anetaip = rd_anet_aip_output(output_file);
if ~exist('output_file','var')||~exist(output_file,'file')
    output_file = getfullname_('*.output','aip_output','Select output file to plot...');
end

% output_file_4STAR = ['c:\z_4STAR\work_2aaa__\4STAR_.output'];
% if ~exist(output_file_4STAR,'file')
%     output_file_4STAR = [getfullname_('4STAR_.output','STARanet','Select output file from AERONET retrieval.')];
% end

fid=fopen(output_file,'r');
anetaip.fname =output_file;
c = onCleanup(@()fclose(fid));
%--read Extinction of aerosol for 4 Wavelength
for j =1:4
    for k =1:5
        line = fgetl(fid);
    end
    for i = 1:83
        line = fgetl(fid);
        pp = sscanf(line,'%f %f %f %f');
        angle(i,j) = pp(1);
        total(i,j) = pp(2);
        fine(i,j) = pp(3);
        coarse(i,j) = pp(4);
    end
end
anetaip.angle = angle;
anetaip.total = total;
anetaip.fine = fine;
anetaip.coarse = coarse;
%--read Sky error
for k =1:8
    line = fgetl(fid);
end

for i =1:4
    line = fgetl(fid);
    pp = sscanf(line,'%f %f %f');
    Wavelength(i) = pp(1);
    sky_error(i) = pp(2);
end
anetaip.Wavelength = Wavelength;
anetaip.sky_error = sky_error;
%--read Refractive index
for k =1:12
    line = fgetl(fid);
end

for i =1:4
    line = fgetl(fid);
    pp = sscanf(line,'%f %f %*f %*f %*f %*f %*f %f %*f %*f %*f %*f %*f');
  %  Wavelength(i) = pp(1);
    refractive_index_real_r(i) = pp(2);
    refractive_index_imaginary_r(i) = pp(3);
end
anetaip.refractive_index_real_r = refractive_index_real_r;
anetaip.refractive_index_imaginary_r = refractive_index_imaginary_r;

%--read Particle size distribution
for k =1:5
    line = fgetl(fid);
end

for i =1:22
    line = fgetl(fid);
    pp = sscanf(line,'%f %f %*f %*f %*f %*f %*f');
    radius(i) = pp(1);
    psd(i) = pp(2);
end
anetaip.radius = radius;
anetaip.psd = psd;

%--read Single Scattering Albedo
for k =1:6
    line = fgetl(fid);
end

for i =1:4
    line = fgetl(fid);
    pp = sscanf(line,'%f %f %*f %*f %*f %*f %*f');
    ssa_r(i) = pp(2);
end
anetaip.ssa_r = ssa_r;

%--read Aerosol extinction optical depth
for k =1:5
    line = fgetl(fid);
end

for i =1:4
    line = fgetl(fid);
    pp = sscanf(line,'%f %f');
    aod(i) = pp(2);
end
anetaip.aod = aod;

%--read  Aerosol absorption optical depth
for k =1:6
    line = fgetl(fid);
end

for i =1:4
    line = fgetl(fid);
    pp = sscanf(line,'%f %f %*f %*f');
    aaod(i) = pp(2);
end
anetaip.aaod = aaod;

%--read Sky Radiances for 4 Wavelength
for k =1:50
        line = fgetl(fid);
    end
for j =1:4
    for k =1:4
        line = fgetl(fid);
    end
    for i = 1:24
        line = fgetl(fid);
        pp = sscanf(line,'%f %f %f %*f');
        sky_radiances_angle(i,j) = pp(1);
        sky_radiances_fit(i,j) = pp(2);
        sky_radiances_measured(i,j) = pp(3);
    end
end
anetaip.sky_radiances_angle = sky_radiances_angle;
anetaip.sky_radiances_fit = sky_radiances_fit;
anetaip.sky_radiances_measured = sky_radiances_measured;



       


