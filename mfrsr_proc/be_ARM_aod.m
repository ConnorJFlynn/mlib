function be = be_ARM_aod;
% Compute best-estimate AOD time series from collocated measurements
% Idea is to obtain comprehensive time series of collocated AOD
% measurements, step through by some time increment to compute robust best-fit AOD
% rejecting statistical outliers and points that deviate from the fit line
% by more than some threshold value.

% Subsequently, infer instrument health channel-by-channel health as a
% fraction of values (hourly? daily?) that are within agreement of the BE
% value.

cim(1) = pack_anet_aodv3(read_cimel_aod_v3(getfullname('*.lev*','anet_aod_v3','Select Aeronet AOD v3 file'))); %CART
cim(2) = pack_anet_aodv3(read_cimel_aod_v3(getfullname('*.lev*','anet_aod_v3','Select Aeronet AOD v3 file'))); %Cart
cim(3) = pack_anet_aodv3(read_cimel_aod_v3(getfullname('*.lev*','anet_aod_v3','Select Aeronet AOD v3 file'))); %ARM SGP
% nnn = pack_anet_aodv3(read_cimel_aod_v3(getfullname('*.lev*','anet_aod_v3','Select Aeronet AOD v3 file'))); %ARM SGP

nim(1) = pack_xmfrx_aod(anc_bundle_files(getfullname('*nimfraod*.cdf;*nimfraod*.nc','nimfr','Select NIMFR AOD files')));
mfr(1) = pack_xmfrx_aod(anc_bundle_files(getfullname('*mfrsraod*.cdf;*mfrsraod*.nc','mfrC1','Select MFRSR C1 AOD files')));
mfr(2) = pack_xmfrx_aod(anc_bundle_files(getfullname('*mfrsraod*.cdf;*mfrsraod*.nc','mfrE13','Select MFRSR E13 AOD files')));

%sas = anc_bundle_files
 start_date = min([cim(1).time(1), cim(2).time(1),cim(3).time(1), mfr(1).time(1), ...
     mfr(2).time(1),nim(1).time(1), nim(2).time(1), nim(3).time(1)]');
end_date = max([cim(1).time(end), cim(2).time(end),cim(3).time(end), mfr(1).time(end), ...
     mfr(2).time(end),nim(1).time(end), nim(2).time(end), nim(3).time(end)]');
 datestr(start_date)
 datestr(end_date)

%Pack each input source into a time-by-wavelength grid. Times need not be
%regular.  For a given source, the wavelength grid is fixed, so may need to
%represent a super-set of wavelengths if actual wavelengths change over
%time, or periods with distinct wavelength selections would be represented
%as separate time-dimensioned structs.  That is probably best, and each
%struct will contain a name tag which might or might not be unique.
% For example, cim1 will be an array of structs: cim1(1).time, cim1(1).wl, cim1.aod(t,wl)

aods = NaN([0,3]);
mm = 2; dt = mm ./(24.*60);
for t =  start_date :dt : end_date
    src =0;
    for c = 1:length(cim)
        src = src + 1;
        mmm = cim(c);
        t_ = mmm.time>= t & mmm.time < t+dt ;
        for ti = find(t_)
            tmp1 = [aods(:,1); mmm.aod(:,ti)]; 
            tmp2 = [aods(:,2); mmm.wl];
            tmp3 = [aods(:,3);repmat(src,[length(mmm.wl),length(ti)])];
            aods = [tmp1,tmp2,tmp3];            
        end
    end
    for c = 1:length(nim)
        src = src + 1;
        mmm = nim(c);
        t_ = mmm.time>= t & mmm.time < t+dt ;
        for ti = find(t_)
            disp(ti)
            tmp1 = [aods(:,1); mmm.aod(:,ti)]; 
            tmp2 = [aods(:,2);repmat(mmm.wl,[1,length(ti)])];
            tmp3 = [aods(:,3);repmat(src,[length(mmm.wl),length(ti)])];
            aods = [tmp1,tmp2,tmp3];
        end
    end
    for c = 1:length(mfr)
        src = src + 1;
        mmm = mfr(c);
        t_ = mmm.time>= t & mmm.time < t+dt ;
        for ti = find(t_)
            aods(:,1) = [aods(:,1); mmm.aod(:,ti)];
            aods(:,2) = [aods(:,2);repmat(mmm.wl,[1,length(ti)])];
            aods(:,3) = [aods(:,3);repmat(src,[length(mmm.wl),length(ti)])];
        end
    end
end
% Bit-mapped field of sources 
% Distinguish between whether source was available and whether source was
% ultimately used?  I think not.  Just whether it was used within a fit
% interval.

% Shall we make any attempt to improve or assess cloud-screen?





end
