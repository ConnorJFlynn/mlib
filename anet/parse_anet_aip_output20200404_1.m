function anetaip = parse_anet_aip_output(outname)
% Search for "Wavelength Dependence" and read the block of
if ~exist('outname','var')
    outname = getfullname('4STAR_*.output','anet_results');
end
[pname, fname, ext] = fileparts(outname); ii = findstr(fname, '.created');
fstem = fname(1:ii-1);
if exist('outname','var')&&exist(outname, 'file')
    cnvt_txt_file_to_pc(outname);
    fid = fopen(outname); 
    outfile = char(fread(fid,'uchar'))';
    fclose(fid);
    anetaip.output_fname = outname; anetaip.fstem = fstem;
    inputname = strrep(outname, '.output','.input');
    if exist(inputname, 'file') % Read a bunch of supporting data from the input file
        anetaip.input_fname = inputname;
    fid = fopen(anetaip.input_fname);
    done = false;
    inline = [];
    
    while isempty(strfind(inline,'MEASUREMENT'))&&~feof(fid)
        inline = fgetl(fid);
    end
    if ~isempty(strfind(inline,'rad scaled by'))
        anetaip.input.rad_scale = sscanf(inline(strfind(inline,'rad scaled by')+length('rad scaled by'):end),'%f');
    else
        anetaip.input.rad_scale = 1;
    end
    
    if ~isempty(strfind(inline,'aods:'))
        tmp = textscan(inline(strfind(inline,'aods:')+length('aods:'):end),'%f');
        tmp = tmp{:};
        anetaip.input.aods = tmp;
    else
        anetaip.input.aods = [];
    end
    if feof(fid)
       fseek(fid, 0, -1);
    end  
   n= 0;
   while ~feof(fid)
      in_str = fgetl(fid);
      if ~isempty(findstr(in_str,'albedo(IW)'))
         n= n +1;
         sfc_alb(n) = sscanf(in_str,'%f %*[^\n]');
      end
   end  
   if isavar('sfc_alb')
      anetaip.sfc_alb = sfc_alb;
   else
      anetaip.sfc_alb = [];
   end
    if feof(fid)
       fseek(fid, 0, -1);
    end
    while isempty(strfind(inline,'NSTR NLYR NLYRS NW IGEOM IDF IDN DPF'))&&~feof(fid)
        inline = fgetl(fid);
    end
    % 7 1 20 6 1 1 1 0.00 : NSTR NLYR NLYRS NW IGEOM IDF IDN DPF
    [NLYRS] = sscanf(inline,'%*d %*d %d',1);anetaip.input.NLYRS = NLYRS;
    
    inline = fgetl(fid);
    % 0.100 1.0 5.000 1.0 1000       : H(NLYR),W(NLYR),NS
    tmp = sscanf(inline,'%f %f %f %f %d');
    anetaip.input.H = tmp([1 3]); anetaip.input.W = tmp([2 4]); anetaip.input.NS = tmp(5);
    inline = fgetl(fid);inline = fgetl(fid);inline = fgetl(fid);inline = fgetl(fid);
    %  4.378        : wind speed
    wind_speed = sscanf(inline,'%f',1); anetaip.input.wind_speed = wind_speed;
    inline = fgetl(fid);
    % 0.000 1.000   : land_fraction sea_fraction
    [land_fraction,sea_fraction] = sscanf(inline,'%f %f');
    anetaip.input.land_fraction = land_fraction; anetaip.input.sea_fraction = sea_fraction;
    inline = fgetl(fid);
    % 0.010 70.000   :(hlyr(NLYR-I+1),I=1,NLYR+1)
    [hlyr] = sscanf(inline,'%f %f');
    anetaip.input.hlyr = hlyr;

    while isempty(strfind(inline,'houtput(IW,ITAU)'))&&~feof(fid)
        inline = fgetl(fid);
    end
    % 0.080  - houtput(IW,ITAU)
    houtput = sscanf(inline,'%f');
    anetaip.input.houtput = houtput;

    fclose(fid);
    else
        % Define empty input fields?
    end
           
%%
[~,matchend,~,~,~, ~,splitstring] = regexp(outfile,[char(13), char(10)]);
linestart = [1,matchend+1]; linestart(end) = min([linestart(end) length(outfile)]);
for lnum = length(linestart):-1:1
    blocks_(lnum) = isempty(deblank(splitstring{lnum}));
end
blocks = [2, find(blocks_)]; % blank lines are used to separate data blocks, so find them
%%
instr = 'Wavelength dependence';
ii = strfind(outfile,instr );
block_start = find(linestart(blocks)>ii,1,'first');
block_str = outfile(linestart(blocks(block_start)):linestart(blocks(block_start+1)));
w = textscan(block_str, '%f %f %*s %f %*[^\n]');
anetaip.Wavelength =w{1};
anetaip.sky_error = w{2};
anetaip.sky_bias = w{3};
% w = w{1};
%%
%--read Extinction, SSA, and phase function for Wavelength n
for jj =1:length(anetaip.Wavelength)
    wave_str = ['Wavelength ',sprintf('%1.3f',anetaip.Wavelength(jj))];
    wi(jj,:) = strfind(outfile,wave_str);
    
    block_start = find(linestart(blocks)>wi(jj,1),1,'first')-1;
    block_str = outfile(linestart(blocks(block_start)):linestart(blocks(block_start+1)));
    tmp = {''};
    
    while isempty(tmp{1})
        [tmp,block_str] = getl(block_str);
        tmp = textscan(tmp,'%f %f %f %f %f %f');
    end
    anetaip.ext_total(jj) =  tmp{1};
    anetaip.ext_fine(jj) = tmp{2};
    anetaip.ext_coarse(jj) = tmp{3};
    anetaip.ssa_total(jj) = tmp{4};
    anetaip.ssa_fine(jj) = tmp{5};
    anetaip.ssa_coarse(jj) = tmp{6};
    [~,block_str] = getl(block_str);
    tmp = textscan(block_str,'%f %f %f %f');
    anetaip.PF_angle(:,jj) = tmp{1};
    anetaip.PF_total(:,jj) = tmp{2};
    anetaip.PF_fine(:,jj) = tmp{3};
    anetaip.PF_coarse(:,jj) = tmp{4};
end

for W = length(anetaip.Wavelength):-1:1
anetaip.g_tot(W) = 0.5.*trapz((pi./180).*anetaip.PF_angle(:,W), sind(anetaip.PF_angle(:,W)).*cosd(anetaip.PF_angle(:,W)).* anetaip.PF_total(:,W));
anetaip.g_fine(W) = 0.5.*trapz((pi./180).*anetaip.PF_angle(:,W), sind(anetaip.PF_angle(:,W)).*cosd(anetaip.PF_angle(:,W)).* anetaip.PF_fine(:,W));
anetaip.g_coarse(W) = 0.5.*trapz((pi./180).*anetaip.PF_angle(:,W), sind(anetaip.PF_angle(:,W)).*cosd(anetaip.PF_angle(:,W)).* anetaip.PF_coarse(:,W));
end


%%
instr = 'Fluxes:';
ii = strfind(outfile,instr );
block_start = find(linestart(blocks)>ii,1,'first');
block_str = outfile(linestart(blocks(block_start)):linestart(blocks(block_start+1)));
tmp = textscan(block_str, '%f %f %f %f %*[^\n]');
anetaip.flux_dn = tmp{2};
anetaip.flux_up = tmp{3};
anetaip.flux_diffuse = tmp{4};

%%
%--read Refractive index
instr = 'Refractive index:';
ii = strfind(outfile,instr );
block_start = find(linestart(blocks)>ii,1,'first')-1; % negative needed due to missing blank line in output file
block_str = outfile(linestart(blocks(block_start)):linestart(blocks(block_start+1)));

tmp = textscan(block_str,'%f %f %f %f %f %f');
while ~isempty(strfind(block_str,'-th'))||isempty(tmp{1})
    [~,block_str] = getl(block_str);
    tmp = textscan(block_str,'%f %f %f %f %f %f');
end
tmp = textscan(block_str, '%*f %f %f %f %f %f %f %f %f %f %f %f %f  %*[^\n]');
anetaip.refractive_index_real_r = tmp{1};
anetaip.refractive_index_imaginary_r = tmp{7};
%%
%--read Particle size distribution
instr = 'Particle size distribution dV/dlnR';
ii = strfind(outfile,instr );
block_start = find(linestart(blocks)>ii,1,'first')-1; % negative needed due to missing blank line in output file
block_str = outfile(linestart(blocks(block_start)):linestart(blocks(block_start+1)));
tmp = textscan(block_str,'%f %f %f %f %f %f');
while ~isempty(strfind(block_str,'-th'))||isempty(tmp{1})
    [~,block_str] = getl(block_str);
    tmp = textscan(block_str,'%f %f %f %f %f %f');
end
tmp = textscan(block_str, '%f %f %*f %*f %*f %*f %*f');
anetaip.radius = tmp{1};
anetaip.psd = tmp{2};
%%
%--read Aerosol extinction optical depth
instr = 'Aerosol extinction optical depth';
ii = strfind(outfile,instr );
block_start = find(linestart(blocks)>ii,1,'first'); % negative needed due to missing blank line in output file
block_str = outfile(linestart(blocks(block_start)):linestart(blocks(block_start+1)));
tmp = textscan(block_str, '%*f %f');
aod = tmp{1}; anetaip.aod = aod;
%%
%--read  Aerosol absorption optical depth
instr = 'Aerosol absorption optical depth';
ii = strfind(outfile,instr );
block_start = find(linestart(blocks)>ii,1,'first'); %
block_str = outfile(linestart(blocks(block_start)):linestart(blocks(block_start+1)));
tmp = textscan(block_str,'%f %f %f %f %f %f');
while ~isempty(strfind(block_str,'-th'))||isempty(tmp{1})
    [~,block_str] = getl(block_str);
    tmp = textscan(block_str,'%f %f %f %f %f %f');
end
tmp = textscan(block_str, '%*f %f %*[^\n]');
aaod = tmp{1}; anetaip.aaod = aaod;
%%
%--read  (total) optical depth, fit and measured
instr = 'Optical depth';
ii = strfind(outfile,instr );
block_start = find(linestart(blocks)>ii,1,'first') +1; %
block_str = outfile(linestart(blocks(block_start)):linestart(blocks(block_start+1)));
%%
tmp = textscan(block_str,'%f %f %f %*[^\n]');
while ~isempty(strfind(block_str,'-th'))||isempty(tmp{1})
    [~,block_str] = getl(block_str);
    tmp = textscan(block_str,'%f %f %f %*[^\n]');
end
tmp = textscan(block_str,'%*f %f %f %f %*[^\n]');
tod = tmp{1}; anetaip.tod_fit = tod;
tod = tmp{2}; anetaip.tod_meas = tod;
tod = tmp{3}; anetaip.tod_meas_less_fit = tod;

%%
sky_radiances_angle = [];
%--read Sky Radiances for N Wavelength
for jj =1:length(anetaip.Wavelength)
    block_start = find(linestart(blocks)>wi(jj,2),1,'first');
    block_str = outfile(linestart(blocks(block_start)):linestart(blocks(block_start+1)));
    tmp = textscan(block_str, '%f %*[^\n]');
    sky_radiances_angle = unique([sky_radiances_angle ; tmp{1}]);
%     sky_radiances_angle(:,jj) = tmp{1};
end
anetaip.sky_radiances_angle = sky_radiances_angle;
anetaip.sky_radiances_fit = NaN([length(anetaip.sky_radiances_angle),length(anetaip.Wavelength)]);
anetaip.sky_radiances_measured = anetaip.sky_radiances_fit;
anetaip.sky_radiances_pct_diff = anetaip.sky_radiances_fit;
for jj =1:length(anetaip.Wavelength)
    block_start = find(linestart(blocks)>wi(jj,2),1,'first');
    block_str = outfile(linestart(blocks(block_start)):linestart(blocks(block_start+1)));
    tmp = textscan(block_str, '%f %f %f %f %*[^\n]');
    ang = tmp{1};
    ij = interp1(sky_radiances_angle, [1:length(sky_radiances_angle)],ang,'nearest');
        anetaip.sky_radiances_angle(ij) = tmp{1};
    anetaip.sky_radiances_fit(ij,jj) = tmp{2};
    anetaip.sky_radiances_measured(ij,jj) = tmp{3};
    anetaip.sky_radiances_pct_diff(ij,jj) = tmp{4};
%     anetaip.sky_radiances_fit(:,jj) = tmp{2};
%     anetaip.sky_radiances_measured(:,jj) = tmp{3};
%     anetaip.sky_radiances_pct_diff(:,jj) = tmp{4};
end
%%
%--read Sphericity parameter
instr = 'Sphericity Parameter';
ii = strfind(outfile,instr );
block_start = find(linestart(blocks)>ii,1,'first'); % negative needed due to missing blank line in output file
block_str = outfile(linestart(blocks(block_start)):linestart(blocks(block_start+1)));
tmp = textscan(block_str,'%f %f');
anetaip.Sphericity = tmp{1};
anetaip.Sphericity_err = tmp{2};

else
    disp('We need an output file...')
end

return
%%






