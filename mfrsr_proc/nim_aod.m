barn_nim.fig = figure;
% set(barn_nim.fig, 'visible','off')
pname = 'C:\case_studies\McFarlane\aod\';
aod_dir = dir([pname,'*.txt']);
for f = length(aod_dir): -1:1
    clear barn_nim
    barn_nim.fig = gcf;
    barn_nim.data = load(fullfile(pname, aod_dir(f).name));
    [p,fname,x] = fileparts(aod_dir(f).name);
    barn_nim.fname = aod_dir(f).name;
    barn_nim.pname = pname;
    % Jim's data is in LST = GMT + 1, so UTC is LST -1
    barn_nim.time = datenum(fname,'yyyymmdd')+(barn_nim.data(:,1)-1)/24;
    barn_nim.cza = barn_nim.data(:,3);
    barn_nim.aod_415nm = barn_nim.data(:,4);
    barn_nim.aod_500nm = barn_nim.data(:,5);
    barn_nim.aod_615nm = barn_nim.data(:,6);
    barn_nim.aod_673nm = barn_nim.data(:,7);
    barn_nim.aod_870nm = barn_nim.data(:,8);
    barn_nim.aod_940nm = barn_nim.data(:,9);
    barn_nim.angstrom = barn_nim.data(:,10);
    barn_nim.solar_azimuth_angle = barn_nim.data(:,12);
    barn_nim.aod_523nm = barn_nim.aod_500nm .* ((500/523) .^barn_nim.angstrom);
    barn_nim = rmfield(barn_nim, 'data');

    barn_nim.time = barn_nim.time';
    barn_nim.cza = barn_nim.cza';
    barn_nim.solar_azimuth_angle = barn_nim.solar_azimuth_angle';
    barn_nim.aod_415nm = barn_nim.aod_415nm';
    barn_nim.aod_500nm = barn_nim.aod_500nm';
    barn_nim.aod_523nm = barn_nim.aod_523nm';
    barn_nim.aod_615nm = barn_nim.aod_615nm';
    barn_nim.aod_673nm = barn_nim.aod_673nm';
    barn_nim.aod_870nm = barn_nim.aod_870nm';
    barn_nim.aod_940nm = barn_nim.aod_940nm';
    barn_nim.angstrom = barn_nim.angstrom';
    

%     barn_nim.aero = aod_screen(barn_nim.time, barn_nim.aod_500nm,0,2,5,6,5e-4);
    [barn_nim.aero,aero_eps, eps,mad, abs_dev] = aod_screen(barn_nim.time, barn_nim.aod_500nm,...
        0,5,5,6,3e-4);
    if sum(barn_nim.aero)>1
        plot(serial2Hh(barn_nim.time), barn_nim.aod_500nm, 'r.',serial2Hh(barn_nim.time(barn_nim.aero)), barn_nim.aod_500nm(barn_nim.aero), 'g.');
        xlim([6,18]);
        ylim([.75*min(barn_nim.aod_500nm(barn_nim.aero)),1.2*max(barn_nim.aod_500nm(barn_nim.aero))]);
        title(['Niamey AOD 500 nm: ',datestr(barn_nim.time(end),'yyyy-mm-dd')]);
        legend('raw','screened');
        ylabel('AOD');
        xlabel('time (UTC)');
        print('-dpng',fullfile(barn_nim.pname,'plots',[fname,'.png']));

        barn_nim.time = barn_nim.time(barn_nim.aero);
        barn_nim.cza = barn_nim.cza(barn_nim.aero);
        barn_nim.aod_415nm = barn_nim.aod_415nm(barn_nim.aero);
        barn_nim.aod_500nm = barn_nim.aod_500nm(barn_nim.aero);
        barn_nim.aod_523nm = barn_nim.aod_523nm(barn_nim.aero);
        barn_nim.aod_615nm = barn_nim.aod_615nm(barn_nim.aero);
        barn_nim.aod_673nm = barn_nim.aod_673nm(barn_nim.aero);
        barn_nim.aod_870nm = barn_nim.aod_870nm(barn_nim.aero);
        barn_nim.aod_940nm = barn_nim.aod_940nm(barn_nim.aero);
        barn_nim.angstrom =  barn_nim.angstrom(barn_nim.aero);
        barn_nim.aero = barn_nim.aero(barn_nim.aero);
        %


        V = datevec(barn_nim.time);
        yyyy = V(:,1);
        mm = V(:,2);
        dd = V(:,3);
        HH = V(:,4);
        MM = V(:,5);
        SS = V(:,6);
        doy = serial2doy(barn_nim.time)';
        HHhh = (doy - floor(doy)) *24;
        %
        txt_out = [yyyy, mm, dd, HH, MM, SS, doy, HHhh, ...
            barn_nim.aod_415nm',...
            barn_nim.aod_500nm',...
            barn_nim.aod_523nm',...
            barn_nim.aod_615nm',...
            barn_nim.aod_673nm',...
            barn_nim.aod_870nm',...
            barn_nim.aod_940nm',...
            barn_nim.angstrom'];
        %
        bads = txt_out(:,10)<=0;
        txt_out(bads,:) = [];
        %
        header_row = ['yyyy, mm, dd, HH, MM, SS, doy, HHhh, '];
        header_row = [header_row, 'aod_415nm, aod_500nm, aod_523nm,'];
        header_row = [header_row, 'aod_615nm, aod_673nm, aod_870nm, '];
        header_row = [header_row, 'aod_940nm, angstrom_exponent'];

        format_str = ['%d, %d, %d, %d, %d, %0.f, %3.6f, %2.4f, '];
        format_str = [format_str, '%2.3f, %2.3f, %2.3f,'];
        format_str = [format_str, '%2.3f, %2.3f, %2.3f,'];
        format_str = [format_str, '%2.3f, %2.3f \n '];

        fid = fopen([barn_nim.pname, '/screened/', fname, '.cjf.txt'],'wt');
        fprintf(fid,'%s \n',header_row );
        fprintf(fid,format_str,txt_out');
        status = fclose(fid);
    end
end
