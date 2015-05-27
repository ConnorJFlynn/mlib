function write_files_phase4LNA_v05(chemin_out,range,time,...
                                CBH,CTH,OTmi,OTpi,LR,T,NLayermax,...
                                dP,dP_parti, ...
                                Pr2paranorm,Pr2perpnorm,betamolparamatT2,betamolperpmatT2,...
                                betamolparamat,betamolperpmat,...
                                flagcld,...
                                annee,mois,jour,Nshot,resol_t)


    filename = [chemin_out '/lna_2a_depolNF-5m_v02_' annee mois jour '_000000_1440.nc'];
    disp(filename)
    anc.fname = filename;
    anc.clobber = true;
	
	% Attributes
    anc.atts.Location.data = 'SIRTA, Palaiseau, France';
    anc.atts.System.data ='LNA Lidar';
    anc.atts.Title.data ='SIRTA LNA Lidar depolariation ratio';
    anc.atts.Longitude.data ='2.208 deg E';
    anc.atts.Latitude.data ='48.713 deg N';
    anc.atts.range.data ='156 m';
    anc.atts.Detection_Mode.data ='analog';
    anc.atts.Zenith_angle.data ='0';
    anc.atts.Shot_averages.data =num2str(Nshot);
    anc.atts.Range_resolution_raw.data ='15 m';
    anc.atts.PRF.data ='20 Hz';
    anc.atts.day.data =jour;
    anc.atts.month.data =mois;
    anc.atts.year.data =annee;

%     nc.Location='SIRTA, Palaiseau, France';
%     nc.System='LNA Lidar';
%     nc.Title='SIRTA LNA Lidar depolariation ratio';
%     nc.Longitude='2.208 deg E';
%     nc.Latitude='48.713 deg N';
%     nc.range='156 m';
%     nc.Detection_Mode='analog';
%     nc.Zenith_angle='0';
%     nc.Shot_averages=num2str(Nshot);
%     nc.Range_resolution_raw='15 m';
%     nc.PRF='20 Hz';
%     nc.day=jour;
%     nc.month=mois;
%     nc.year=annee;
%     
Date = round(clock);
    anc.atts.history.data = ['Generated '  sprintf('%04d',Date(1)) '/' sprintf('%02d',Date(2)) '/' sprintf('%02d',Date(3)) ' '...
	    sprintf('%02d',Date(4)) ':' sprintf('%02d',Date(5)) ' Local Time by Y. Morille'];
    anc.atts.institution.data = 'LMD-SIRTA/IPSL';

comments =['channel used : 1, wavelength : 532 nm, polarization : NULL , telescope : NFOV, 0.5 mrad, 60 cm diameter.'];

    anc.atts.comment_a.data ='Depolariation ratio';
    anc.atts.comment_b.data =comments;
    anc.atts.comment_c.data ='program used : depol_part_v01.m';
    anc.atts.version.data   ='version v01';

	NLayer=[1:NLayermax];
	
	% Define dimensions
	anc.dims.time.length = length(time);
   anc.dims.time.isunlim = true;
	anc.dims.range.length = length(range);
	anc.dims.NLayer.length = length(NLayer);

	% Define variables
	anc.vars.time.dims      = {'time'};
	anc.vars.range.dims     = {'range'};
	anc.vars.NLayer.dims    = {'NLayer'};
	anc.vars.CBH.dims       = {'NLayer', 'time'};
	anc.vars.CTH.dims       = {'NLayer', 'time'};
	anc.vars.OTmi.dims      = {'NLayer', 'time'};
	anc.vars.OTpi.dims      = {'NLayer', 'time'};
	anc.vars.LR.dims        = {'NLayer', 'time'};
	anc.vars.T.dims         = {'NLayer', 'time'};
	anc.vars.dP.dims        = {'range', 'time'};
	anc.vars.dP_parti.dims  = {'range', 'time'};
	anc.vars.betaT2_para_tot.dims   = {'range', 'time'};
	anc.vars.betaT2_perp_tot.dims   = {'range', 'time'};
	anc.vars.betaT2_para_mol.dims   = {'range', 'time'};
	anc.vars.betaT2_perp_mol.dims   = {'range', 'time'};
	anc.vars.beta_para_mol.dims     = {'range', 'time'};
	anc.vars.beta_perp_mol.dims     = {'range', 'time'};
	anc.vars.flagstrat.dims         = {'range', 'time'};

	
	% Define Attributes
	anc.vars.time.atts.units.data        = ['hours since ' annee '-' mois '-' jour ' 00:00:00 00:00'];
	anc.vars.range.atts.units.data       = 'm';
	anc.vars.NLayer.atts.units.data    = '-';
	anc.vars.CBH.atts.units.data       = 'm';
	anc.vars.CTH.atts.units.data       = 'm';
	anc.vars.OTmi.atts.units.data      = '-';
	anc.vars.OTpi.atts.units.data      = '-';
	anc.vars.LR.atts.units.data        = 'sr';
	anc.vars.T.atts.units.data         = 'deg C';
	anc.vars.dP.atts.units.data.units.data          = '%/100';
	anc.vars.dP_parti.atts.units.data    = '%/100';
	anc.vars.betaT2_para_tot.atts.units.data = '1/m 1/sr';
	anc.vars.betaT2_perp_tot.atts.units.data = '1/m 1/sr';
	anc.vars.betaT2_para_mol.atts.units.data = '1/m 1/sr';
	anc.vars.betaT2_perp_mol.atts.units.data = '1/m 1/sr';
	anc.vars.beta_para_mol.atts.units.data   = '1/m 1/sr';
	anc.vars.beta_perp_mol.atts.units.data   = '1/m 1/sr';
	anc.vars.flagstrat.atts.units.data       = '-';

	anc.vars.time.atts.long_name.data        = 'Decimal hours since midnigth UTC';
	anc.vars.range.atts.long_name.data       = 'Altitude';
	anc.vars.NLayer.atts.long_name.data    = 'Nmber of layers';
	anc.vars.CBH.atts.long_name.data       = 'Cloud base height';
	anc.vars.CTH.atts.long_name.data       = 'Cloud top height';
	anc.vars.OTmi.atts.long_name.data      = 'Optical Thickness MI method';
	anc.vars.OTpi.atts.long_name.data      = 'Optical Thickness PI method';
	anc.vars.LR.atts.long_name.data        = 'Lidar Ratio';
	anc.vars.T.atts.long_name.data         = 'Temperature';
	anc.vars.dP.atts.long_name.data          = 'Total Depolarization ratio';
	anc.vars.dP_parti.atts.long_name.data    = 'Particle Depolarization ratio';
	anc.vars.betaT2_para_tot.atts.long_name.data    = 'Normalized Total Backscatter*T*T, parallel polarization';
	anc.vars.betaT2_perp_tot.atts.long_name.data    = 'Normalized Total Backscatter*T*T, perpendicular polarization';
	anc.vars.betaT2_para_mol.atts.long_name.data    = 'Normalized Molecular Backscatter*T*T, parallel polarization';
	anc.vars.betaT2_perp_mol.atts.long_name.data    = 'Normalized Molecular Backscatter*T*T, perpendicular polarization';
	anc.vars.beta_para_mol.atts.long_name.data       = 'Normalized Molecular Backscatter,    parallel polarization';
	anc.vars.beta_perp_mol.atts.long_name.data       = 'Normalized Molecular Backscatter,    perpendicular polarization';
	anc.vars.flagstrat.atts.long_name.data           = 'STRAT flag';
comments='flag = 0 : no significant power return, SNR < 3, flag = 1 : molecular, flag = 2 : boundary layer, flag = 3 : aerosol layer, flag = 4 : cloud layer, flag > 4 : no detection.';
    anc.vars.flagstrat.atts.comments.data            = comments;

	anc.vars.time.data        = time;
	anc.vars.range.data       = range;
    anc.vars.NLayer.data      = NLayer;
    anc.vars.CBH.data         = CBH';
    anc.vars.CTH.data         = CTH';
    anc.vars.LR.data          = LR';
    anc.vars.T.data           = T';
	anc.vars.OTmi.data        = OTmi';
	anc.vars.OTpi.data        = OTpi';
	
    anc.vars.dP.data          = dP';
	anc.vars.dP_parti.data    = dP_parti';

	anc.vars.betaT2_para_tot.data    = Pr2paranorm';
	anc.vars.betaT2_perp_tot.data    = Pr2perpnorm';
	anc.vars.betaT2_para_mol.data    = betamolparamatT2';
	anc.vars.betaT2_perp_mol.data    = betamolperpmatT2';
	anc.vars.beta_para_mol.data       = betamolparamat';
	anc.vars.beta_perp_mol.data       = betamolperpmat';
	anc.vars.flagstrat.data           = flagcld';


	anc = ancheck(anc);
   anc = ancsave(anc);
