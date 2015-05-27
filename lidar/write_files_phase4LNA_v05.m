function write_files_phase4LNA_v05(chemin_out,range,time,...
                                CBH,CTH,OTmi,OTpi,LR,T,NLayermax,...
                                dP,dP_parti, ...
                                Pr2paranorm,Pr2perpnorm,betamolparamatT2,betamolperpmatT2,...
                                betamolparamat,betamolperpmat,...
                                flagcld,...
                                annee,mois,jour,Nshot,resol_t)


    filename = [chemin_out '/lna_2a_depolNF-5m_v02_' annee mois jour '_000000_1440.nc'];
    disp(filename)
    nc = netcdf(filename, 'clobber');
	
	% Attributes
    nc.Location='SIRTA, Palaiseau, France';
    nc.System='LNA Lidar';
    nc.Title='SIRTA LNA Lidar depolariation ratio';
    nc.Longitude='2.208 deg E';
    nc.Latitude='48.713 deg N';
    nc.range='156 m';
    nc.Detection_Mode='analog';
    nc.Zenith_angle='0';
    nc.Shot_averages=num2str(Nshot);
    nc.Range_resolution_raw='15 m';
    nc.PRF='20 Hz';
    nc.day=jour;
    nc.month=mois;
    nc.year=annee;
Date = round(clock);
    nc.history=['Generated '  sprintf('%04d',Date(1)) '/' sprintf('%02d',Date(2)) '/' sprintf('%02d',Date(3)) ' '...
	    sprintf('%02d',Date(4)) ':' sprintf('%02d',Date(5)) ' Local Time by Y. Morille'];
    nc.institution='LMD-SIRTA/IPSL';

comments =['channel used : 1, wavelength : 532 nm, polarization : NULL , telescope : NFOV, 0.5 mrad, 60 cm diameter.'];

    nc.comment_a ='Depolariation ratio';
    nc.comment_b =comments;
    nc.comment_c ='program used : depol_part_v01.m';
    nc.version   ='version v01';

	NLayer=[1:NLayermax];
	
	% Define dimensions
	nc('time') = length(time);
	nc('range') = length(range);
	nc('NLayer') = length(NLayer);

	% Define variables
	nc{'time'}      = 'time';
	nc{'range'}     = 'range';
	nc{'NLayer'}    = 'NLayer';
	nc{'CBH'}       = {'time','NLayer'};
	nc{'CTH'}       = {'time','NLayer'};
	nc{'OTmi'}      = {'time','NLayer'};
	nc{'OTpi'}      = {'time','NLayer'};
	nc{'LR'}        = {'time','NLayer'};
	nc{'T'}         = {'time','NLayer'};
	nc{'dP'}        = {'time','range'};
	nc{'dP_parti'}  = {'time','range'};
	nc{'betaT2_para_tot'}   = {'time','range'};
	nc{'betaT2_perp_tot'}   = {'time','range'};
	nc{'betaT2_para_mol'}   = {'time','range'};
	nc{'betaT2_perp_mol'}   = {'time','range'};
	nc{'beta_para_mol'}     = {'time','range'};
	nc{'beta_perp_mol'}     = {'time','range'};
	nc{'flagstrat'}         = {'time','range'};

	
	% Define Attributes
	nc{'time'}.units        = ['hours since ' annee '-' mois '-' jour ' 00:00:00 00:00'];
	nc{'range'}.units       = 'm';
	nc{'NLayer'}    = '-';
	nc{'CBH'}       = 'm';
	nc{'CTH'}       = 'm';
	nc{'OTmi'}      = '-';
	nc{'OTpi'}      = '-';
	nc{'LR'}        = 'sr';
	nc{'T'}         = 'deg C';
	nc{'dP'}.units          = '%/100';
	nc{'dP_parti'}.units    = '%/100';
	nc{'betaT2_para_tot'}.units = '1/m 1/sr';
	nc{'betaT2_perp_tot'}.units = '1/m 1/sr';
	nc{'betaT2_para_mol'}.units = '1/m 1/sr';
	nc{'betaT2_perp_mol'}.units = '1/m 1/sr';
	nc{'beta_para_mol'}.units   = '1/m 1/sr';
	nc{'beta_perp_mol'}.units   = '1/m 1/sr';
	nc{'flagstrat'}.units       = '-';

	nc{'time'}.long_name        = 'Decimal hours since midnigth UTC';
	nc{'range'}.long_name       = 'Altitude';
	nc{'NLayer'}.long_name    = 'Nmber of layers';
	nc{'CBH'}.long_name       = 'Cloud base height';
	nc{'CTH'}.long_name       = 'Cloud top height';
	nc{'OTmi'}.long_name      = 'Optical Thickness MI method';
	nc{'OTpi'}.long_name      = 'Optical Thickness PI method';
	nc{'LR'}.long_name        = 'Lidar Ratio';
	nc{'T'}.long_name         = 'Temperature';
	nc{'dP'}.long_name          = 'Total Depolarization ratio';
	nc{'dP_parti'}.long_name    = 'Particle Depolarization ratio';
	nc{'betaT2_para_tot'}.long_name    = 'Normalized Total Backscatter*T*T, parallel polarization';
	nc{'betaT2_perp_tot'}.long_name    = 'Normalized Total Backscatter*T*T, perpendicular polarization';
	nc{'betaT2_para_mol'}.long_name    = 'Normalized Molecular Backscatter*T*T, parallel polarization';
	nc{'betaT2_perp_mol'}.long_name    = 'Normalized Molecular Backscatter*T*T, perpendicular polarization';
	nc{'beta_para_mol'}.long_name       = 'Normalized Molecular Backscatter,    parallel polarization';
	nc{'beta_perp_mol'}.long_name       = 'Normalized Molecular Backscatter,    perpendicular polarization';
	nc{'flagstrat'}.long_name           = 'STRAT flag';
comments='flag = 0 : no significant power return, SNR < 3, flag = 1 : molecular, flag = 2 : boundary layer, flag = 3 : aerosol layer, flag = 4 : cloud layer, flag > 4 : no detection.';
    nc{'flagstrat'}.comments            = comments;

	nc{'time'}(:)        = time;
	nc{'range'}(:)       = range;
    nc{'NLayer'}(:)      = NLayer;
    nc{'CBH'}(:)         = CBH';
    nc{'CTH'}(:)         = CTH';
    nc{'LR'}(:)          = LR';
    nc{'T'}(:)           = T';
	nc{'OTmi'}(:)        = OTmi';
	nc{'OTpi'}(:)        = OTpi';
	
    nc{'dP'}(:)          = dP';
	nc{'dP_parti'}(:)    = dP_parti';

	nc{'betaT2_para_tot'}(:)    = Pr2paranorm';
	nc{'betaT2_perp_tot'}(:)    = Pr2perpnorm';
	nc{'betaT2_para_mol'}(:)    = betamolparamatT2';
	nc{'betaT2_perp_mol'}(:)    = betamolperpmatT2';
	nc{'beta_para_mol'}(:)       = betamolparamat';
	nc{'beta_perp_mol'}(:)       = betamolperpmat';
	nc{'flagstrat'}(:)           = flagcld';


	nc = close(nc);
