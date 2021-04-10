function sws = proc_swssas_raw(files)
% sws = proc_swssas_raw;
% Process SAS-style SWS raw files
if ~isavar('files')
files = getfullname('*sws_vis*.csv','sws_raw','Select raw SWS VIS files to bundle.');
end
% tic; 
sws =bundle_sas_raw(files);
% toc
sat_val = 32767;

dark_out = sws_dark_rate(sws)
% General idea for darks is to examine a group of them to 1) exclude
% outliers and 2) determine a best "average" value of the remaining darks
% Looks like 10 minute intervals computed on some finer step (5 min?) is good.
% Could adapt this to yield different darks for different integration times
% Could also convert all to rate without loss of generality, irrespective
% of seperate processing of darks for different integrations.


% tstep = (5 * 60)./(24*60*60);% 1 minute step
% hwin = (5 * 50)./(24*60*60); % 5 minute half-width window
% times_out = length([(sws.time(1)+hwin):tstep:(sws.time(end)-hwin)]);
% %Around here put in logic to handle darks with different integration times
% dark_out.time = zeros([times_out,1]);
% dark_out.darks = zeros([times_out,length(sws.lambda)]);
% to = 0;
% for t = (sws.time(1)+hwin):tstep:(sws.time(end)-hwin)
%    to = to +1;
%    win = (sws.time>= (t-hwin)) & (sws.time <= (t+hwin))&sws.Shutter_open_TF==0;
%    ts = sws.time(win);
%    mins = min(rate(win,:),[],2);
%    maxs = max(rate(win,:),[],2);
%    good = rpoly_mad(ts,mins,1,3);
%    good2 = rpoly_mad(ts,maxs,1,3);
%    good = good & good2;
% %    if sum(good)<length(good)
% %       disp('Screening out erratic darks')
% %    end
%    spc = rate(win,:);
%    eq = {'1';'X'};
%    [K] = fit_it(serial2doy(ts(good)),spc(good,:),eq);
%    dark_out.time(to) = mean(ts(good));
%    dark_out.dark_rate(to,:) = eval_eq(serial2doy(mean(ts(good))),K,eq);
% end


dark_rates = interp1(dark_out.time, dark_out.dark_rate, sws.time,'pchip','extrap');
rate = sws.spec ./ (sws.t_int_ms * ones(size(sws.lambda)));
sig = rate - dark_rates;
% compute nonlinearity correction for sws.spec based on raw cts, well depth
%   but apply after dark subtraction and scattering subtraction
% scattering subtraction/correction, apply after darks
% Apply nlc to sig(shutter == 1) 

if mean(sws.lambda(IQ(sws.lambda)))<900
   if ~exist('infile','var')
      infile = getfullname('*sws*resp*si*.dat','sws_resp','Select VIS responsivity file');
   end
   fid = fopen(infile);
   first_line = fgetl(fid);fclose(fid);
   if strcmp(first_line(1),'%')
      lamp_cal = rd_sasze_resp_file(infile);
      resp =  lamp_cal.resp;
   else
      tmp_cal = load(infile);
      resp = tmp_cal(:,2);
   end
   if ~exist('infile','var')
      infile = getfullname('*sws*resp*ir*.dat','sws_resp','Select IR responsivity file');
   end
   fid = fopen(infile);
   first_line = fgetl(fid);fclose(fid);
   if strcmp(first_line(1),'%')
      lamp_cal = rd_sasze_resp_file(infile);
      resp =  lamp_cal.resp;
   else
      tmp_cal = load(infile);
      resp = tmp_cal(:,2);
   end
else
   
end

rad = sig ./ (ones(size(sws.time))*resp');


% "Best"
% Compute non-linearity correction on raw cts
% Determine rates.
% Determine robust dark rates (catch times when darks are not robust)
% Subtract darks
% Subtract stray light
% Apply non-linearity correction to subtracted rates.
% Divide corrected rate by responsivity
% Apply QC to flag saturated values, times when darks are suspect, wavelength
% regions where calibration is poor, and
% regions outside confident wavelength range
% What about uncertainties?  Propagate uncertainties in calibration from
% counting statistics plus an estimated calibration uncertainty overall,
% plus measurement counting statistics, plus errors related to each
% correction.
% What about wavelength registration?




return