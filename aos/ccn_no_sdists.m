
in_files = getfullname('*.cdf;*.nc','cnc','Select one or more cnc files');
if ~iscell(in_files)
    in_files = {in_files};
end
for f = 1:length(in_files)
    tmp = anc_load(in_files{f});
    [tmp] = anc_sift(tmp,[],tmp.ncdef.dims.size_bin);
    if ~exist('ccn','var')
        ccn = tmp;
    else
        ccn = anc_cat(ccn,tmp);
    end
end
[ccn,ccn_] = anc_sift(ccn, ccn.vdata.CCN_temp_unstable==0);% Exclude unstable values
[ccn,ccn_] = anc_sift(ccn, ccn.vdata.CCN_temperature_std<=0.04);% Exclude values with temperature_std>=0.04

ARM_nc_display(ccn);

miss = ccn.vdata.CCN_Q_sample<-1000|ccn.vdata.CCN_Q_sheath<-1000;
figure; plot(serial2doys(ccn.time(~miss)), ccn.vdata.CCN_Q_sheath(~miss)./ccn.vdata.CCN_Q_sample(~miss),'.')

% based on observations at MAO flag conditions where sheath/sample > 11 or < 9
% based on observations at MAO flag first stage monitor > 0.5 as yellow, > 1 as BAD.
% based on observations at MAO flag N_CCN < 10 as BAD.  flag hour max N_CCN < 200 as BAD
