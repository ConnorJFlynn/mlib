function aos = add_aod(aos);
% aos_mon = add_aod(aos);
% The bulk of this copied from grid_aos.
aod_file = 'C:\case_studies\dust\aod_metric_stuff\MFRSR_forward_scat_corrs\aod_metric\niamey_corrected_aod.cdf';
aod = ancload(aod_file);
[ainb, bina] = nearest(aos.time', aod.time);

aos.aod_415nm = NaN(size(aos.time));
aos.aod_500nm = aos.aod_415nm;
aos.aod_615nm = aos.aod_415nm;
aos.aod_673nm = aos.aod_415nm;
aos.aod_870nm = aos.aod_415nm;
aos.ang_500_870_MFRSR = aos.aod_415nm;

aos.aod_415nm(ainb) = aod.vars.aod_415nm.data(bina);
aos.aod_500nm(ainb) = aod.vars.aod_500nm.data(bina);
aos.aod_615nm(ainb) = aod.vars.aod_615nm.data(bina);
aos.aod_673nm(ainb) = aod.vars.aod_673nm.data(bina);
aos.aod_870nm(ainb) = aod.vars.aod_870nm.data(bina);
aos.ang_500_870_MFRSR(ainb) = aod.vars.angstrom_exponent.data(bina);
%    inds = interp1(ccn.time, [1:length(ccn.time)],aos_mon.time, 'nearest');
%    if isfield(aos_mon,'fname')
%       aos_mon = rmfield(aos_mon,'fname');
%    end


