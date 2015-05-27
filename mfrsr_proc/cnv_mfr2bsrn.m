function bsrn = cnv_mfr2bsrn(mfr)
% ingests mfr data into bsrn structure
if ~exist('mfr','var')
   mfr = ancload;
end
% Darwin 		DAR 	BSRN station no: 2
% S. Great Plains E13 	BSRN station no: 27
% Billings 	BIL 	BSRN station no: 28
% Momote 		MAN 	BSRN station no: 29
% Nauru Island 	NAU 	BSRN station no: 30

if ~isempty(findstr(mfr.atts.site_id.data,'sgp'))
   if ~isempty(findstr(mfr.atts.facility_id.data(1:2),'C1'))
   bsrn_id = 28;
   station = 'Billings 	BIL';
   elseif ~isempty(findstr(mfr.atts.facility_id.data(1:2),'E13'))
   bsrn_id = 27;
   station = 'S. Great Plains E13';

   end
elseif ~isempty(findstr(mfr.atts.site_id.data,'twp'))
   if ~isempty(findstr(mfr.atts.facility_id.data(1:2),'C1'))
   bsrn_id = 29;
   station = 'Momote 		MAN';
   elseif ~isempty(findstr(mfr.atts.facility_id.data(1:2),'C2'))
   bsrn_id = 30;
   station = 'Nauru Island 	NAU';
   elseif ~isempty(findstr(mfr.atts.facility_id.data(1:2),'C3'))
   bsrn_id = 2;
   station = 'Darwin 		DAR';
   end
end
bsrn.header.station = station; % station name
bsrn.header.scientist = 'Connor J. Flynn, PNNL';
bsrn.header.email = 'Connor.Flynn@pnl.gov';
bsrn.header.latitude = sprintf('%9.4f',mfr.vars.lat.data);
bsrn.header.longitude = sprintf('%9.4f',mfr.vars.lon.data);
tz = floor(mfr.vars.lon.data./15);
bsrn.header.timezone = sprintf('%9.4f',tz);
bsrn.header.altitude = sprintf('%9.0f',mfr.vars.alt.data);
bsrn.header.bsrnidnumber = sprintf(' %9d',bsrn_id);
V = datevec(mfr.time(1));
bsrn.header.year = sprintf(' %9d',V(1));
bsrn.header.month = sprintf(' %9d',V(2));
proc_time = now;
secs = floor(24*60*60*rem(proc_time,1));
bsrn.header.processed = [datestr(proc_time,'yyyy-mm-dd '),sprintf(' %5d',secs)];

% populate calib structure
bsrn.calib.bsrnidnumber = sprintf(' %9d',bsrn_id);;
bsrn.calib.year = sprintf(' %9d',V(1));
bsrn.calib.month = sprintf(' %9d',V(2));
bsrn.calib.sunnoinstruments = sprintf('%9d',1);
bsrn.calib.sunnochannels1 = sprintf('%9d',5);
mfr_filter1 = get_mfr_filter(mfr,1);
mfr_filter2 = get_mfr_filter(mfr,2);
mfr_filter3 = get_mfr_filter(mfr,3);
mfr_filter4 = get_mfr_filter(mfr,4);
mfr_filter5 = get_mfr_filter(mfr,5);
bsrn.calib.sunwavelengths1 = sprintf(' %9.4f',[mfr_filter1.cwl,mfr_filter2.cwl,...
   mfr_filter3.cwl,mfr_filter4.cwl,mfr_filter5.cwl]);
bsrn.calib.sunfwhm1 = sprintf(' %9.4f',[mfr_filter1.fwhm,mfr_filter2.fwhm,...
   mfr_filter3.fwhm,mfr_filter4.fwhm,mfr_filter5.fwhm]);
bsrn.calib.sunyear1 = sprintf(' %9d',[1,1,1,1,1].*V(1));
bsrn.calib.sunmonth1 = sprintf(' %9d',[1,1,1,1,1].*V(2));
bsrn.calib.sunday1 = sprintf(' %9d',[1,1,1,1,1].*V(3));
bsrn.calib.suncal1 = sprintf(' %9.3f',[mfr_filter1.Vo,mfr_filter2.Vo,...
   mfr_filter3.Vo,mfr_filter4.Vo,mfr_filter5.Vo]);
bsrn.calib.sunu951 = sprintf(' %9.3f',[mfr_filter1.Vo,mfr_filter2.Vo,...
   mfr_filter3.Vo,mfr_filter4.Vo,mfr_filter5.Vo].*.03);
bsrn.calib.sunresolution1 = sprintf(' %9.3f',[1,1,1,1,1].*5000./4096);

% populate data structure
% 60 2007-03-01 525 0.8 38.830 977.8 -999.9 0.0 63870 78760 84450 92940
% 94550
V = datevec(mfr.time);
secs = floor(24*60*60*rem(mfr.time,1))';

trans = [mfr.vars.direct_normal_narrowband_filter1.data ./ mfr_filter1.TOA;... 
mfr.vars.direct_normal_narrowband_filter2.data ./ mfr_filter2.TOA;...
mfr.vars.direct_normal_narrowband_filter3.data ./ mfr_filter3.TOA;...
mfr.vars.direct_normal_narrowband_filter4.data ./ mfr_filter4.TOA;...
mfr.vars.direct_normal_narrowband_filter5.data ./ mfr_filter5.TOA];
trans = trans';
neg_trans = trans<0;
trans(~neg_trans) = trans(~neg_trans) .* 1e5;
trans(neg_trans) = -99999;
trans = floor(trans);
txt_out = [bsrn_id.*ones(size(mfr.time')),V(:,1), V(:,2), V(:,3), secs, ...
   15.*ones(size(mfr.time')), mfr.vars.solar_zenith_angle.data',...
   10.*mfr.vars.surface_pressure.data',...
   -999.9.*ones(size(mfr.time')), -99.9.*ones(size(mfr.time')), (trans)];

good_time = any(trans>0,2)&mfr.vars.solar_zenith_angle.data'<96;
txt_out = txt_out(good_time,:);
bsrn.data = txt_out;

return

function filterN = get_mfr_filter(mfr,N)
if isfield(mfr.atts, ['filter',num2str(N),'_CWL_measured'])
    filterN.cwl = sscanf(mfr.atts.(['filter',num2str(N),'_CWL_measured']).data,'%f');
end
if isempty(filterN.cwl)||(filterN.cwl<=100)
   filterN.cwl = sscanf(mfr.atts.(['filter',num2str(N),'_CWL_nominal']).data,'%f');
end
if isfield(mfr.atts, ['filter',num2str(N),'_FWHM_measured'])
    filterN.fwhm = sscanf(mfr.atts.(['filter',num2str(N),'_FWHM_measured']).data,'%f');
end
if isempty(filterN.fwhm)||(filterN.fwhm<=0)
   filterN.fwhm = sscanf(mfr.atts.(['filter',num2str(N),'_FWHM_nominal']).data,'%f');
end
if isfield(mfr.atts, ['filter',num2str(N),'_TOA_direct_normal'])
   filterN.TOA = sscanf(mfr.atts.(['filter',num2str(N),'_TOA_direct_normal']).data,'%f');
end
filterN.nom_cal = mfr.vars.(['nominal_calibration_factor_filter',num2str(N)]).data;
filterN.Io = mfr.vars.(['Io_filter',num2str(N)]).data;
% filterN.Vo = filterN.nom_cal .* filterN.Io;
filterN.Vo = filterN.Io;
% %SUNWAVELENGTHS1= 412.0000 500.0000 610.0000 778.0000 867.0000

%% Output header info

%% 


% %[HEADER]
% %STATION=Lauder, New Zealand
% %SCIENTIST=Bruce W Forgan Bureau of Meteorology
% %EMAIL=b.forgan@bom.gov.au
% %LATITUDE= -45.0450
% %BSRNIDNUMBER= 60
% %LONGITUDE= 169.6890
% %ALTITUDE= 350
% %TIMEZONE= -12.0000
% %YEAR= 2007
% %MONTH= 3
% %PROCESSED=2007-09-27 51586
% [/HEADER]
% [SUNCALIB]
% %BSRNIDNUMBER= 60
% %YEAR= 2007
% %MONTH= 3
% %SUNNOINSTRUMENTS= 1
% %SUNNOCHANNELS1= 5
% %SUNWAVELENGTHS1= 412.0000 500.0000 610.0000 778.0000 867.0000
% %SUNFWHM1= 10.0000 10.0000 10.0000 10.0000 10.0000
% %SUNCAL1= 2.9862 3.9721 4.1629 3.8489 3.4450
% %SUNU951= 0.0893 0.0552 0.0497 0.0382 0.0548
% %SUNRESOLUTION1= 0.0001 0.0001 0.0001 0.0001 0.0001
% %SUNYEAR1= 2007 2007 2007 2007 2007
% %SUNMONTH1= 2 2 2 2 2
% %SUNDAY1= 1 1 1 1 1
% [/SUNCALIB]
% [SUNTRANS]
% .....
% 60 2007-03-01 525 0.8 38.830 977.8 -999.9 0.0 63870 78760 84450 92940 94550
% 60 2007-03-01 585 0.8 38.770 977.8 -999.9 0.0 63840 78920 84570 92820 94410
% 60 2007-03-01 645 0.8 38.710 977.8 -999.9 0.0 63870 78860 84520 92870 94470
% 60 2007-03-01 706 0.8 38.650 977.8 -999.9 1.0 63410 78240 83980 92130 93730
% 60 2007-03-01 765 0.8 38.590 977.8 -999.9 2.0 63410 78050 83910 92310 93700
% 60 2007-03-01 825 0.8 38.530 977.8 -999.9 1.0 62900 77630 83240 91460 93100
% ......
% 60 2007-03-31 81885 0.8 56.830 960.0 -999.9 24.0 53670 73290 79670 91100 88070
% 60 2007-03-31 81945 0.8 56.720 960.0 -999.9 43.0 54170 72990 79850 90040 92390
% 60 2007-03-31 82005 0.8 56.610 960.0 -999.9 30.0 52480 71320 78810 89860 89980
% 60 2007-03-31 82065 0.8 56.500 960.0 -999.9 4.0 54670 74220 81740 93470 96340
% 60 2007-03-31 82125 0.8 56.400 960.0 -999.9 2.0 54790 74680 82170 93520 96510
% 60 2007-03-31 82185 0.8 56.290 960.0 -999.9 20.0 55070 74720 82000 93730 95670
% 60 2007-03-31 82245 0.8 56.180 960.0 -999.9 29.0 36590 49260 54170 58990 60400
% 60 2007-03-31 86385 0.8 50.660 960.0 -999.9 41.0 34320 45110 45230 50040 52530
% [/SUNTRANS]