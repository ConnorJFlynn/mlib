function paeri_pcfilter_driver(directory,PCdirectory)
%
%       function paeri_pcfilter_driver(directory,PCdirectory)
%
%   ....This function reads in netcdf files for channel 1 (c1) for the PAERI and performs 
%       PC noise filtering on the spectra.  It uses the method describe
%       by:
%
%         Antonelli et al, 2004: A principal component noise filter for
%           high spectral resolution infrared measurements, J. Geophys. Res.,
%           109, D23102, doi:10.1029/2004JD00482.
%
%       and
%
%         Turner et al, 2006:  Noise reduction of Atmospheric Emitted
%         Radiance Interferometer (AERI) observations using principal
%         component analysis, J. Atmos. Ocean. Tech., 23, 1223-1238.
%
%       Input
%       -----
%       directory     - directory in which the PAERI QC data reside
%       PCdirectory  - directory where you want the PC filtered files to be written
%
%       Example call to 'paeri_pcfilter_driver.m'
%       ---------------------------
%         paeri_pcfilter_driver('/data/dataman/paeri/data/QC/QC_checked/','/data/dataman/paeri/data/PC/');
%       
%       Written by Von P. Walden
%                  3 May 2007
%       Updated    5 May 2007 (Removed dependence on month; now processes everthing in the QC directory.)
%                 21 May 2007 (Now calculates how many files to read on the fly using nfreq.)
%		Updated   23 May 2009 (Modified by PMR, see initials within for specific changes)
%
%addpath('/data/dataman/paeri/docs/Mfiles');
%addpath('/data/dataman/paeri/docs/Mfiles/QC');

%   ....Determines the number of spectra to use in the PC noise filter based on Turner et al's 
%       recommendation of using at least twice the number of spectral points (about 2600).
%       The spectral limits are 490 to 1800 cm-1, and the spectral resolution is 0.5 cm-1.
%
%       Dave Turner actually recommended we use about 10,000 spectra instead of double the spectral limits.
%nspectra_limit = (1800-490)./0.5 * 2;
nspectra_limit = 1000;
directory = 'C:\case_studies\assist\data\sites\sgp\aeri_data\20100726\';
if ~strcmp(directory(length(directory)),filesep)
    directory = [directory,filesep];
end
PCdirectory = 'C:\case_studies\assist\data\sites\sgp\aeri_data\20100726\pcs\';
if ~strcmp(PCdirectory(length(PCdirectory)),filesep)
    PCdirectory = [PCdirectory,filesep];
end

%
%   ....Determines which files to open.  
%
d = dir([directory,'sgpaerich1*.cdf']);

l = 1;

while l <= length(d)
%while l <= 1
    
    f            = l;   % File index used below to copy filtered data into files.

    c1t.Time     = [];
    c1t.wnum1    = [];
    c1t.mean_rad = [];
    c1t.wnum1s   = [];
    c1t.SkyNEN   = [];
   
    nspectra = 0;
    sprintf('READING PAERI SPECTRA TO FILTER:')
    while (nspectra < nspectra_limit)&&l<=length(d)

        % Change the filename (PMR)
        sm           = ancload([directory,d(l).name(1:7) 'summary' d(l).name(11:length(d(1).name))]);
        c1           = ancload([directory,d(l).name]);
        good         = find(c1.vars.missingDataFlag.data == 0);

        if(length(good) > 1)
            c1t.wnum1    = c1.vars.wnum.data;
            c1t.Time     = [c1t.Time;     c1.vars.time.data(good)];
            c1t.mean_rad = [c1t.mean_rad; c1.vars.mean_rad.data(:,good)'];
            c1t.wnum1s   = sm.vars.wnumsum5.data;
            c1t.SkyNEN   = [c1t.SkyNEN;   sm.vars.SkyNENCh1.data(:,good)'];
        end

        nspectra     = nspectra + length(good);
        sprintf('File read: %36s, # of good spectra: %6d, Total # of spectra read: %6d\n',d(l).name,length(good),nspectra)

        l            = l + 1;
        
    end
    
    % For testing...
    %c1p = c1t;
    
    
    %
    %   ....Perform the PC noise filtering.
    %
    sprintf('PERFORMING PCA NOISE FILTERING:')
    datestr(now)

        [c1p.mean_rad,c1p.numberOfPCs] = paeri_pcfilter(c1t.wnum1,c1t.mean_rad,c1t.wnum1s,c1t.SkyNEN,4);    
    
    datestr(now)
    
    %
    %   ....Write PC noise-filtered data to new YYMMDD_qc_pc.nc files using .
    %
    sprintf('CREATING PC NOISE-FILTERED DATA FILES:')
    start       = 0;
    c1_mean_rad = [];
    for k = f:l-1
        %   ....Open file pointers to original netcdf files, but makes copies first!
        d(k).name
        eval(['!cp ',directory,d(k).name,' ',PCdirectory,d(k).name(1:length(d(k).name)-20),'_pc',d(k).name(length(d(k).name)-19:length(d(k).name))]);
        fpc1 = netcdf.open([PCdirectory,d(k).name(1:length(d(k).name)-20),'_pc',d(k).name(length(d(k).name)-19:length(d(k).name))],'NC_WRITE');

        c1                  = rd_netcdf([directory,d(k).name]);
        c1_mean_rad         = c1.mean_rad';
        good                = find(c1.missingDataFlag == 0);

        if (length(good) > 0)
            c1_mean_rad(good,:) = c1p.mean_rad(start+(1:length(good)),:);
            start = start + length(good);
        end

        varid = netcdf.inqVarID(fpc1,'mean_rad');
        netcdf.putVar(fpc1,varid,c1_mean_rad');
        netcdf.reDef(fpc1);   % Must enter define mode to add new variable.
            dimid = netcdf.inqDimID(fpc1,'scalar');
            varid = netcdf.defVar(fpc1,'numberOfPCs','double',dimid);
        netcdf.endDef(fpc1);  % Goes back to data mode to putVar.
        netcdf.putVar(fpc1,varid,c1p.numberOfPCs);
        netcdf.close(fpc1);
	
    end
    
    f = l; 

end




