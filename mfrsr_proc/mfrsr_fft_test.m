function fft_test = mfrsr_fft_test;
% Loops through all files in a directory, chunking into solar days
% Identify contiguous intervals of valid measurements at least dur=300 in length
% Test direct_diffuse_ratio at 870. 
[dlist, dname] = dir_list('*.cdf;*.nc');
files = dirlist_to_filelist(dlist, dname);
% This is the number of consecutive records required.  why 300?
dur = 300; dur_ = dur -1;

disp(files{1})
mfr = anc_load(files{1}); files(1) = [];
[zen, az, soldst, ha, dec, el, am] = sunae(mfr.vdata.lat, mfr.vdata.lon, mfr.time);
X = 1;
while ~isempty(files)
    while ~isempty(files) && (mfr.time(end)-mfr.time(1)<2 || sum(el>0)==0)
        [~,fname] = fileparts(files{1})
        title_str = fname;
        if ~isdir(files{1})
            mfr = anc_cat(mfr, anc_load(files{1}));
          
        end
        files(1) = [];
    end
    % The logic to split_solar seems to be efficient
    [mfr, mfr_] = split_solar(mfr);
    [mfr, bad] = mfrsr_fft_flag(mfr);
%     if length(mfr.time)>0
%        [zen, az, soldst, ha, dec, el, am] = sunae(mfr.vdata.lat, mfr.vdata.lon, mfr.time);
%        %I tried diffuse/total, diffuse./dirh, and dirh/diffuse.
%        % Similar results. Likely Alexandrov results in tau are improved by
%        % pre-screening with eps test.  Instead let's try direct normal to diffuse
%        % We can also attempt to use eps-screen on that by normalizing to maxima,
%        % perhaps limited to the max over some airmass range such as 1:6
% 
%        Dd = mfr.vdata.direct_diffuse_ratio_filter5;
%        diff5 = mfr.vdata.diffuse_hemisp_narrowband_filter5;
%        dv = datevec(mfr.time);
%        dts = [20;dtime(dv(2:end,:), dv(1:end-1,:))]'; %difference between time records in seconds
%        dts_ = dts>18 & dts < 22 & am>1 & am<6 & Dd>0 & diff5>0; % contiguous good measurements
%        bad = false(size(dts_));
%         s = find(dts_,1,'first');
%         while (s + dur_) <= length(dts_)
%             contig = prod(dts_(s+[0:dur_]));
%             if ~contig
%                 s = s+1;
%             else
%                 fft_test.time(X) = mean(mfr.time(s+[0:dur_]));
%                 fft_test.dif_fraction(X) = mean(Dd(s+[0:dur_]));
%                 mom = fft_moments(mfr.time(s+[0:dur_]), Dd(s+[0:dur_]));
%                 in_band = mom.P>95 & mom.P<120;
%                 out_band = mom.P>90 & mom.P<130 & ~in_band;
%                 fft_test.fft_M(X,:) = mom.fft_M;
%                 fft_test.in_band(X) = mean(abs(mom.fft_M(in_band)));
%                 [P,S,MU] = polyfit(mom.P(out_band),abs(mom.fft_M(out_band)),1);
%                 fft_test.side_bands(X) = mean(polyval(P,mom.P(in_band),S,MU));
%                 fft_test.pwr_frac(X) = (fft_test.in_band(X) - fft_test.side_bands(X))./fft_test.side_bands(X);
%                 if (fft_test.pwr_frac(X)>.75)
%                    bad(s+[0:dur_]) = true;
%                 end
% %                              figure_(12); plot(mom.P, abs(fft_test.fft_M(X,:)),'-',...
% %                                  mom.P(in_band), abs(fft_test.fft_M(X,in_band)),'go',...
% %                                  mom.P(out_band), abs(fft_test.fft_M(X,out_band)),'rx'); xlim([80,140]);
% %                              title([datestr(mfr.time(s)),sprintf('; power frac: %g',fft_test.pwr_frac(X))]);
% %                              pause(0.05);
%                 s = s + 100; 
%                 X = X +1;
%             end
%         end
%     end
    mfr = mfr_; clear mfr_
end

% Run through a collection of files (such as the 1-year of data at E3) to
% identify contiguous portion of day-time data (airmass or SunEl > ?)
% Compute diffuse/total ratio.  Compute fft moments for 120-contiguous
% values.  Normalize power at 108 by mean difuse/total ratio over same
% contiguous interval.
% Compute time series of mean values and normalized 108 s power.
% red  = (fft_test.pwr_frac(2:end)>.5&fft_test.pwr_frac(1:end-1)>.5)|(fft_test.pwr_frac(1:end-1)>1);
% figure; plot(fft_test.time-7./24, fft_test.pwr_frac,'.',...
%     fft_test.time(red)-7./24, fft_test.pwr_frac(red),'rx'); dynamicDateTicks

return


function  [mfr, mfr_] = split_solar(mfr)
noon = find_noon(double(mfr.vdata.lat), double(mfr.vdata.lon),linspace(floor(mfr.time(1)),ceil(mfr.time(1)),60), 1./(24*60*60*10));
[mfr,mfr_] = anc_sift(mfr,mfr.time< (noon+.5));
return

