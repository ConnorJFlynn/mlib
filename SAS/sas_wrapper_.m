function	s=sas_wrapper_
% Modifying starwrapper to process SAS data for gases and cwv
sfile = getfullname('*.cdf','pvc_sashevis');
sas = anc_load(sfile);
sas2 = anc_load(strrep(sfile,'vis','nir'));
ss.t = sas.time'; 
ss.w = double(sas.vdata.wavelength)'./1000;
ss2.w = double(sas2.vdata.wavelength)'./1000;
ss.rate = sas.vdata.direct_normal_transmittance' .* (ones(size(sas.time'))*sas.vdata.smoothed_Io_values');
ss2.rate = sas2.vdata.direct_normal_transmittance' .* (ones(size(sas2.time'))*sas2.vdata.smoothed_Io_values');
ss.sza = double(sas.vdata.solar_zenith_angle)';
ss.Pst = double(sas.vdata.atmos_pressure)'*10;
ss.Alt = double(sas.vdata.alt)';
ss.Lat = double(sas.vdata.lat)';
ss.Lon = sas.vdata.lon';
v=datevec(ss.t);
ss.f=sundist(v(:,3), v(:,2), v(:,1)); % Beat's code
clear v;

ss.c0 = sas.vdata.smoothed_Io_values';
ss2.c0 = sas2.vdata.smoothed_Io_values';
 
ss.O3h=21; % 
ss.O3col=0.275;%0.280; %     OMI 
ss.NO2col=3.0e15;%2.0e15; %   OMI

%% set default toggle switches
if exist('toggle','var')&&~isempty(toggle)&&isstruct(toggle)
toggle = update_toggle(toggle);
else
    toggle = update_toggle;
end
if isfield(ss, 'toggle')
    ss.toggle = catstruct(toggle, ss.toggle); % merge, overwrite toggle with s.toggle
    toggle = ss.toggle;
else
    ss.toggle = toggle;
end

%% remerge the toggles and if not created make the s.toggle struct


if toggle.verbose;  disp('In Starwrapper'), end;
% Load sashevis and sashenir, trim useless pixels and concatenate along wavelength

%% get data type
% datatype = 'vis'; 
% if toggle.verbose; disp('get data types'), end;
% [daystr, filen, datatype,instrumentname]=starfilenames2daystr(s.filename, 1);s.datatype = datatype;
% if exist('s2','var')
%     [daystr2, filen2, datatype2,instrumentname2]=starfilenames2daystr(s2.filename, 1);s2.datatype = datatype2;
%     if instrumentname~=instrumentname2;
%         error('Instrument name on files from both structures do not match')
%     end;
% end;

%********************
%% get additional info specific to this data set
%********************
if toggle.verbose; disp('get additional info specific to file'), end;
ss.ng=[]; % variables needed for this code (starwrapper.m).
ss.sd_aero_crit=Inf; % variable for screening direct sun datanote
% infofile_ = ['starinfo_' daystr '.m']; 
% data_folder = getnamedpath('4STAR_Github_data_folder','Select 4STAR GitHub data folder.');
% infofile = fullfile(data_folder, ['starinfo' daystr '.m']);
% infofile2 = ['starinfo' daystr]; % 2015/02/05 for starinfo files that are functions, found when compiled with mcc for use on cluster
% open infofile2
% % open starinfo file merely to see what we need to provide later
% if isempty(s.O3h) || isempty(s.O3col);
%     warning(['Enter ozone height and column density in starinfo' daystr '.m.']);
% end;
% if isempty(s.NO2col);
%     warning(['Enter nitric dioxide column density in starinfo' daystr '.m.']);
% end;
%********************
%% add related variables, derive count rate and combine structures
%********************
%% include wavelengths in um and flip NIR raw data
sunfile = getfullname('*starsun.mat','starsun','Select a 4STAR starsun file');
star = load(sunfile,'w');
[visc0, nirc0, visnotec0, nirnotec0, ~, ~, visaerosolcols, niraerosolcols, visc0err, nirc0err]=starc0(now,toggle.verbose);     % C0
[visc0mod, nirc0mod, visc0modnote, nirc0modnote, visc0moderr, nirc0moderr,model_atmosphere]=starc0mod(now,toggle.verbose);% this is for calling modified c0 file
% If we do a mod Langley read modified Io values here
% s.c0mod = [visc0mod';nirc0mod'];% combine arrays

%% subtract dark and divide by integration time
% We'll get "rate" by multiplying dirn_trans by smoothed_Io, if we actually need it
% [s.rate, s.dark, s.darkstd, note]=starrate(s);

% We'll probalby let m_ray and m_aero be identical. 
% calculate airmasses
% [m_ray, m_aero, m_H2O, m_O3, m_NO2]


    [ss.m_ray, ss.m_aero, ss.m_H2O, ss.m_O3, ss.m_NO2]=airmasses(ss.sza, ss.Alt, ss.O3h); % airmass for O3
    % lambda has to be in microns, pressure in hPa, dec_or_t either delination
% angle or time in the Matlab format, latitude in degrees (negative
% southern hemisphere). press, dec_or_t and lat must have the same number
% of rows, and just one column.  

% Now merge vis and nir specs.
% Be careful!  We want to maintain the 4STAR geometry with vis = [1:1044] 
s = ss;
s.w = star.w;
s.rate = repmat(NaN(size(s.t)),[1,length(star.w)]);
s.c0 = NaN(size(star.w));
s.rate(:,1:1044) = interp1(ss.w',ss.rate',s.w(1:1044)','linear')';
s.rate(:,1045:end) = interp1(ss2.w',ss2.rate',s.w(1045:end)','linear')';
s.c0(1:1044) = interp1(ss.w', ss.c0',s.w(1:1044)','linear')';
s.c0(1045:end) = interp1(ss2.w', ss2.c0',s.w(1045:end)','linear')';



    [s.tau_ray]=rayleighez(s.w,s.Pst,s.t,ones(size(s.t)).*s.Lat); % Rayleigh
    [cross_sections, s.tau_O3, s.tau_NO2, s.tau_O4, s.tau_CO2_CH4_N2O]=...
       taugases(s.t, 'vis', ones(size(s.t)).*s.Alt, s.Pst, ones(size(s.t)).*s.Lat, ones(size(s.t)).*s.Lon, s.O3col, s.NO2col); % gases
    [cross_sections, tau_O3, tau_NO2, tau_O4, tau_CO2_CH4_N2O]=...
       taugases(s.t, 'nir', ones(size(s.t)).*s.Alt, s.Pst, ones(size(s.t)).*s.Lat, ones(size(s.t)).*s.Lon, s.O3col, s.NO2col); % gases
    s.tau_O3 = [s.tau_O3,tau_O3];
    s.tau_O4 =[s.tau_O4, tau_O4];
    s.tau_NO2 = [s.tau_NO2,tau_NO2]; 
    s.tau_CO2_CH4_N2O = [s.tau_CO2_CH4_N2O, tau_CO2_CH4_N2O];
    
    % CO2, CH4, N2O are zero at this point
    [pp,qq] = size(s.rate);
    s.rateaero=real(s.rate./repmat(s.f,1,qq)./tr(s.m_ray, s.tau_ray)./...
       tr(s.m_O3, s.tau_O3)./tr(s.m_NO2, s.tau_NO2)./tr(s.m_ray, s.tau_O4)./...
       tr(s.m_ray, s.tau_CO2_CH4_N2O)); % rate adjusted for the aerosol component; % rate adjusted for the aerosol component
    s.tau_aero_noscreening=real(-log(s.rateaero./repmat(s.c0,pp,1))./repmat(s.m_aero,1,qq)); 
%     figure; these = plot([1:length(s.t)], s.tau_aero_noscreening(:,[400:50:800]), '-'); recolor(these, s.w(400:50:800));colorbar
% figure; plot(s.w, s.tau_aero_noscreening(300,:),'-')
    % aerosol optical depth before flags are applied
    s.tau_aero=s.tau_aero_noscreening; 
    % total optical depth (Rayleigh subtracted) needed for gas processing
    % if toggle.gassubtract
        tau_O4nir          = s.tau_O4; tau_O4nir(:,1:1044)=0;
        s.rateslant        = real(s.rate./repmat(s.f,1,qq));
        s.ratetot          = real(s.rate./repmat(s.f,1,qq)./tr(s.m_ray, s.tau_ray)./tr(s.m_ray, tau_O4nir));
        s.tau_tot_slant    = real(-log(s.ratetot./repmat(s.c0,pp,1)));
        s.tau_tot_vertical = real(-log(s.ratetot./repmat(s.c0,pp,1))./repmat(s.m_aero,1,qq));
        
            %-----------------------------------------
    if ~license('test','Optimization_Toolbox'); % check if the opticmization toolbox exists
        toggle.runwatervapor = false;
        warning('!!Optimization Toolbox not found!!, running without watervapor and gas retrievals')
    end
 % fit a polynomial curve to the non-strongly-absorbing wavelengths

%     a2 = NaN(size(s.t)); a1 = a2; a0 = a2; 
%     [a2(~sun_),a1(~sun_),a0(~sun_)]=...
%        polyfitaod(s.w(s.aerosolcols),s.tau_aero(~sun_,s.aerosolcols)); % polynomial separated into components for historic reasons
%     s.tau_aero_polynomial=[a2 a1 a0];
%     s.tau_ang_polynomial = [2*a2 a1];
% if ~isempty(strfind(lower(datatype),'sun'))|| ~isempty(strfind(lower(datatype),'forj'));
    
    if toggle.runwatervapor;
        tic_water = tic; if toggle.verbose; disp('water vapor retrieval start'), end;
        [cwv] = cwvcorecalc_(s,model_atmosphere);
        if toggle.verbose; disp({['Water vapor retrieval duration:'],toc}); end;
        
        % create subtracted 940 nm water vapor from AOD (this is nir-o2-o2 sub)
        s.tau_aero_subtract = real(cwv.tau_OD_wvsubtract./repmat(s.m_aero,1,qq));  %m_aero and m_H2O are the same 
        s.cwv = cwv; clear cwv
        toc(tic_water)
        % gases subtractions and o3/no2 conc [in DU] from fit
        %-----------------------------------------------------
        if toggle.gassubtract
            if toggle.verbose; disp('gases subtractions start'), end;
            
            % this is old routine
            %[s.tau_aero_fitsubtract s.gas] = gasessubtract(s);
            
            % this is new routine
            tic_gas = tic;
            gas = retrieveGases(s); 
            toc(tic_gas)
%             s.gas = gas;
            % subtract derived gasess
            s.tau_aero_subtract_all = s.tau_aero_subtract - gas.o3.o3OD - gas.o3.o4OD - gas.o3.h2oOD ...
               -s.tau_NO2 - gas.co2.co2OD - gas.co2.ch4OD;%tau_NO2% s.gas.no2.no2OD! temporary until no2 refined
            
            if toggle.verbose; disp('gases subtractions end'), end;
            %s.tau_aero=s.tau_aero_wvsubtract;
        end;               
    end;
    
    % cjf: Reformulation in terms of atmos transmittance tr. I prefer this to
    % using "rateaero", since it eliminates arbitrary units (cts/ms, etc) and
    % plots of atmospheric tr are more intelligible than rateaero.
    % And it is also keeps the sun and sky processing more symmetric.
    % s.tr = s.rate./repmat(s.c0,pp,1)./repmat(s.f,1,qq);
    % s.tr(s.Str~=1|s.Md~=1,:) = NaN;% not defined if the shutter is not open to sun or if not actively tracking
    % s.traero=s.tr./tr(s.m_ray, s.tau_ray)./tr(s.m_O3, s.tau_O3)./tr(s.m_NO2, s.tau_NO2)./tr(s.m_ray, s.tau_O4)./tr(s.m_ray, s.tau_CO2_CH4_N2O); % rate adjusted for the aerosol component
    % s.tau_aero_noscreening=-log(s.traero)./repmat(s.m_aero,1,qq); % aerosol optical depth before flags are applied
    % Yohei 2012/10/22
    % Though the analogy with the sky algorithm is attractive, I prefer
    % rateaero over tr. I use rateaero for Langley plots, but have not used
    % tr for any purpose so far. But I can be persuaded to include tr if
    % there is a practical use in it to justify a modest increase in file size.
    
    tau=real(-log(s.rate./repmat(s.f,1,qq)./repmat(s.c0,pp,1))./repmat(s.m_aero,1,qq)); % tau, just for the error analysis below
    warning('Diffuse light correction and its uncertainty (tau_aero_err10) to be amended.');
    % % % s=rmfield(s, 'rate'); YS 2012/10/09
    
    % estimate uncertainties in tau aero - largely inherited from AATS14_MakeAOD_MLO_2011.m
    if toggle.computeerror;
        m_err=0.0003.*(s.m_ray/2).^2.2; % expression for dm/m is from Reagan report
        m_err(s.m_ray<=2)=0.0003; % negligible for TCAP July, but this needs to be revisited. The AATS code offers two options: this (0.03%) and 1%.
        s.m_err = m_err;
        s.tau_aero_err1=abs(tau.*repmat(s.m_err,1,qq)); % YS 2012/10/09 abs avoids imaginary part and hence reduces the size of tau_aero_err (for which tau_aero is NaN as long as rate<=darkstd is screened out.).
        if size(s.c0err,1)==1;
            s.tau_aero_err2=1./s.m_aero*(s.c0err./s.c0);
        elseif size(s.c0err,1)==2;
            s.tau_aero_err2lo=1./s.m_aero*(s.c0err(1,:)./s.c0);
            s.tau_aero_err2hi=1./s.m_aero*(s.c0err(2,:)./s.c0);
        end;
        s.tau_aero_err3=s.darkstd./(s.raw-s.dark)./repmat(s.m_aero,1,qq); % be sure to subtract dark, as it can be negative.
        s.tau_aero_err4=repmat(s.m_ray./s.m_aero,1,qq)*s.tau_r_err.*s.tau_ray;
        s.tau_aero_err5=repmat(s.m_O3./s.m_aero,1,qq)*s.tau_O3_err.*s.tau_O3;
        s.tau_aero_err6=repmat(s.m_NO2./s.m_aero,1,qq)*s.tau_NO2_err.*s.tau_NO2;
        %s.tau_aero_err6=s.m_NO2./s.m_aero*s.tau_NO2_err*s.tau_NO2;
        s.tau_aero_err7=repmat(s.m_ray./s.m_aero,1,qq).*s.tau_O4_err.*s.tau_O4;
        s.tau_aero_err8=0; % legacy from the AATS code; reserve this variable for future H2O error estimate; % tau_aero_err8=tau_H2O_err*s.tau_H2O.* (ones(n(2),1)*(m_H2O./m_aero));
        s.responsivityFOV=starresponsivityFOV(s.t,'SUN',s.QdVlr,s.QdVtb,s.QdVtot);
        s.track_err=abs(1-s.responsivityFOV);
        s.tau_aero_err9=s.track_err./repmat(s.m_aero,1,qq);
        s.tau_aero_err10=0; % reserved for error associated with diffuse light correction; tau_aero_err10=tau_aero.*runc_F'; %error of diffuse light correction
        s.tau_aero_err11=s.m_ray./s.m_aero*s.tau_CO2_CH4_N2O_abserr;
        if size(s.c0err,1)==1;
            s.tau_aero_err=(s.tau_aero_err1.^2+s.tau_aero_err2.^2+s.tau_aero_err3.^2+s.tau_aero_err4.^2+s.tau_aero_err5.^2+s.tau_aero_err6.^2+s.tau_aero_err7.^2+s.tau_aero_err8.^2+s.tau_aero_err9.^2+s.tau_aero_err10.^2+s.tau_aero_err11.^2).^0.5; % combined uncertianty
        elseif size(s.c0err,1)==2;
            s.tau_aero_errlo=-(s.tau_aero_err1.^2+s.tau_aero_err2lo.^2+s.tau_aero_err3.^2+s.tau_aero_err4.^2+s.tau_aero_err5.^2+s.tau_aero_err6.^2+s.tau_aero_err7.^2+s.tau_aero_err8.^2+s.tau_aero_err9.^2+s.tau_aero_err10.^2+s.tau_aero_err11.^2).^0.5; % combined uncertianty
            s.tau_aero_errhi=(s.tau_aero_err1.^2+s.tau_aero_err2hi.^2+s.tau_aero_err3.^2+s.tau_aero_err4.^2+s.tau_aero_err5.^2+s.tau_aero_err6.^2+s.tau_aero_err7.^2+s.tau_aero_err8.^2+s.tau_aero_err9.^2+s.tau_aero_err10.^2+s.tau_aero_err11.^2).^0.5; % combined uncertianty
        end;
    end;
    
    %flags bad_aod, unspecified_clouds and before_and_after_flight
    %produces YYYYMMDD_auto_starflag_created20131108_HHMM.mat and
    %s.flagallcols
    %************************************************************
    if toggle.dostarflag;
        if toggle.verbose; disp('Starting the starflag'), end;
        %if ~isfield(s, 'rawrelstd'), s.rawrelstd=s.rawstd./s.rawmean; end;
        [s.flags, good]=starflag_(s,toggle.flagging); % flagging=1 automatic, flagging=2 manual, flagging=3, load existing
    end;
    %************************************************************
    
    %% apply flags to the calculated tau_aero_noscreening
    s.tau_aero=s.tau_aero_noscreening;
    if toggle.dostarflag && toggle.flagging==1;
        s.tau_aero(s.flags.bad_aod,:)=NaN;
    end;
    % tau_aero on the ground is used for purposes such as comparisons with AATS; don't mask it except for clouds, etc. Yohei,
    % 2014/07/18.
    % The lines below used to be around here. But recent versions of starwrapper.m. do not have them. Now revived. Yohei, 2014/10/31.
    % apply flags to the calculated tau_aero_noscreening
    if toggle.doflagging;
        if toggle.booleanflagging;
            s.tau_aero(any(s.flagallcols,3),:)=NaN;
            s.tau_aero(any(s.flag,3))=NaN;
        else
            s.tau_aero(s.flag~=0)=NaN; % the flags come starinfo########.m and starwrapper.m.
        end;
    end;
    % The end of "The lines below used to be around here. But recent
    % versions of starwrapper.m. do not have them. Now revived. Yohei, 2014/10/31."
    
   
    
    % derive optical depths and gas mixing ratios
    % Michal's code TO BE PLUGGED IN HERE.
    
% end; % End of sun-specific processing



%********************
%% remove some of the results for a lighter file
%********************
if ~toggle.saveadditionalvariables;
    s=rmfield(s, {'darkstd'});
    if ~isempty(strfind(lower(datatype),'sun'));
        s=rmfield(s, {'tau_O3' 'tau_O4' 'tau_aero_noscreening' 'tau_ray' ...
        'rawmean' 'rawstd' 'sat_ij'});
    end;
    if toggle.computeerror;
        s=rmfield(s, {'tau_aero_err1' 'tau_aero_err2' 'tau_aero_err3' 'tau_aero_err4' 'tau_aero_err5' 'tau_aero_err6' 'tau_aero_err7' 'tau_aero_err8' 'tau_aero_err9' 'tau_aero_err10' 'tau_aero_err11'});
    end;
end;



s.toggle = toggle;
return

function s = combine_star_s_s2(s,s2,toggle);
pp=numel(s.t);
qq=size(s.raw,2);
    % check whether the two structures share almost identical time arrays
    if pp~=length(s2.t);
        bad_t=find(diff(s.t)<=0);
        bad_t2=find(diff(s2.t)<=0);
        if length(bad_t2) > 0
            disp('bad_t2 larger than 0');
        end
        [ainb, bina] = nearest(s.t, s2.t);
        st_len = length(s.t);
        st2_len = length(s2.t);
        fld = fieldnames(s);
        for fd = 1:length(fld)
            [rr,col] = size(s.(fld{fd}));
            if rr == st_len && col==1
                s.(fld{fd}) = s.(fld{fd})(ainb);
                s2.(fld{fd}) = s2.(fld{fd})(bina);
            elseif rr==st_len && col == length(s.w)
                s.(fld{fd}) = s.(fld{fd})(ainb,:);
                s2.(fld{fd}) = s2.(fld{fd})(bina,:);
            end
        end
        
        %         error(['Different size of time arrays. starwrapper.m needs to be updated.']);
    end;
    pp=numel(s.t);
    qq=size(s.raw,2);
    ngap=numel(find(abs(s.t-s2.t)*86400>0.02));
    if ngap==0;
    elseif ngap<pp*0.2; % less than 20% of the data have time differences. warn and proceed.
        warning([num2str(ngap) ' rows have different time stamps between the two arrays by greater than 0.02s.']);
    else; % many differences. stop.
        error([num2str(ngap) ' rows have different time stamps between the two arrays by greater than 0.02s.']);
    end;
    % check whether the two structures come from separate spectrometers
    if isequal(lower(s.datatype(1:3)), lower(s2.datatype(1:3)))
        error('Two structures must be for separate spectrometers.');
    end;
    % discard the s2 variables for which s has duplicates
    if toggle.verbose, disp('discarding duplicate structures'), end;
    fn={'Str' 'Md' 'Zn' 'Lat' 'Lon' 'Alt' 'Headng' 'pitch' 'roll' 'Tst' 'Pst' 'RH' 'AZstep' 'Elstep' 'AZ_deg' 'El_deg' 'QdVlr' 'QdVtb' 'QdVtot' 'AZcorr' 'ELcorr'};...
        fn={fn{:} 'Tbox' 'Tprecon' 'RHprecon' 'Tplate' 'sat_time'};
    fnok=[]; % Yohei, 2012/11/27
    for ff=1:length(fn); % take the values from the s structure, and discard those in s2
        if isfield(s, fn{ff});
            fnok=[fnok; ff];
            if size(s.(fn{ff}),1)~=pp || size(s2.(fn{ff}),1)~=pp
                error(['Check ' fn{ff} '.']);
            end;
        end;
    end;
    drawnow;
    s2=rmfield(s2, fn(fnok));
    clear fnok; % Yohei, 2012/11/27
    % combine some of the remaining s2 variables into corresponding s variables
    fnc={'raw' 'rawcorr' 'w' 'c0' 'c0err' 'fwhm' 'rate' 'dark' 'darkstd' 'sat_ij' 'skyresp', 'skyresperr'};
    qq2=size(s2.raw,2);
    s.([lower(s.datatype(1:3)) 'cols'])=1:qq;
    s.([lower(s2.datatype(1:3)) 'cols'])=(1:qq2)+qq;
    for ff=length(fnc):-1:1;
        if size(s.(fnc{ff}),2)~=qq || size(s2.(fnc{ff}),2)~=qq2
            error(['Check ' fnc{ff} '.']);
        else
            s.(fnc{ff})=[s.(fnc{ff}) s2.(fnc{ff})];
        end;
    end;
    s.aerosolcols=[s.aerosolcols(:)' s2.aerosolcols(:)'];
    %     s.aeronetcols = [s.aeronetcols(:)' s2.aeronetcols(:)'];
    note_x = {[upper(s.datatype(1:3)) ' and ' upper(s2.datatype(1:3)) ' data were combined with starwrapper.m. ']};
    note_x(end+1,1) = {[upper(s2.datatype(1:3)) ' notes: ']};
    for L = 1:length(s.note)
        note_x(end+1,1) = {s.note{L}};
    end
    note_x(end+1,1) = {[upper(s.datatype(1:3)) ' notes: ']};
    for L = 1:length(s2.note)
        note_x(end+1,1) = {s2.note{L}};
    end
    s.note = note_x;
    %     s.note={[upper(datatype(1:3)) ' and ' upper(datatype2(1:3)) ' data were combined with starwrapper.m. ']; [upper(datatype(1:3)) ' notes: ']; s.note{:} ;...
    %         [upper(datatype2(1:3)) ' notes: ']; s2.note{:}};
    s.filename=[s.filename; s2.filename];
    s2=rmfield(s2, [fnc(:); 'aerosolcols';'aeronetcols'; 'note'; 'filename']);
    % store the remaining s2 variables separately in s
    fn=fieldnames(s2);
    for ff=1:length(fn);
        s.([lower(s.datatype(1:3)) fn{ff}])=s.(fn{ff});
        s.([lower(s2.datatype(1:3)) fn{ff}])=s2.(fn{ff});
    end;
    s=rmfield(s, setdiff(fn,'t'));
    qq=qq+qq2;
    clear qq2 s2;
    [daystr, filen, s.datatype]=starfilenames2daystr(s.filename, 1);
% end


return
