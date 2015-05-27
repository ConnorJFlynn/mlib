function mpl = mplcbh_codcon(mpl, clear_sky_avg, thresh);
% mpl = cbh_codcon(mpl, clear_sky_avg);
% mpl = read_mpl
% [pileA, pileB] = sift_nolog(mpl.range(mpl.r.lte_20),mpl.rawcts(mpl.r.lte_20,:))
% clear_sky_avg = mean(mpl.rawcts(:,pileA)')';
% clear_sky_avg = clear_sky_avg - mean(clear_sky_avg(mpl.r.bg));


if nargin<3
   bin_threshold = .015;
   cloud_threshold = .003;
   base_threshold = .0005;
else
   bin_threshold = thresh.bin_threshold;
   cloud_threshold = thresh.cloud_threshold;
   base_threshold = thresh.base_threshold;
end

numer = mpl.prof(mpl.r.lte_20,:) - (clear_sky_avg(mpl.r.lte_20)*ones(size(mpl.time)));
denom = clear_sky_avg(mpl.r.lte_20)*ones(size(mpl.time));
pos = find(denom>0);
nada = find(denom==0);
denom(nada) = min(min(denom(pos)));
sig_rat = numer./denom;
% Get Rayleigh extinction coef for std atm.
[atm_temp, atm_press] = std_atm(mpl.range);
[alpha, b] = ray_a_b(atm_temp, atm_press);
sig_rat = sig_rat .* (alpha(mpl.r.lte_20) * ones(size(mpl.time)));


% Multiply sig_rat by Rayleigh ext coef profile
% Extinction to backscatter ratio for aerosol is typically at least 3 times higher than for molecular
% Thus, the extinction profile above under-represents the likely extinction
% from aerosol or cloud, serving as a useful lower limit.
% tau = sum(ext)

[bins, times] = size(sig_rat);
cloud_base_height = -9e-9 * ones(size(mpl.time));
mpl.cod = cloud_base_height;

for t = 1:times
   %disp(['Starting profile for t = ', num2str(t), ' of ', num2str(times)]);
   signif = find(sig_rat(:,t) > bin_threshold);
   if ~isempty(signif)
      block_start = signif(1);
      block_end = signif(1);
      
      finished = length(signif)<2;
      while ~finished
         while (length(signif)>1 & (signif(2)==signif(1)+1))
            signif(1) = [];
            block_end = signif(1);
         end
         %Found contiguous block, now test block to see if it is a cloud
         if block_start==block_end
            block_sum = sig_rat(block_start,t)*(mpl.range(2)-mpl.range(1));
         else
            block_sum = trapz(mpl.range(block_start:block_end), sig_rat(block_start:block_end,t));
         end
         if block_sum > cloud_threshold
            if block_start==block_end
               block_cumsum = sig_rat(block_start,t)*(mpl.range(2)-mpl.range(1));
            else
               block_cumsum = cumtrapz(mpl.range(block_start:block_end),sig_rat(block_start:block_end,t));
            end;
            cloud_base_bin = block_start -1 + (min(find(block_cumsum>base_threshold)));
            cloud_base_height(t) = mpl.range(cloud_base_bin);
            finished = 1;
            mpl.cod(t) = block_sum;
            %disp(['profile #', num2str(t),' at ',sprintf('%2.2f:',serial2Hh(mpl.time(t))),', cbh = ' , num2str(cloud_base_height(t)), sprintf(', cod = %2.3f',block_sum)])
         end
         if (~finished)
            signif(1) = [];
            if length(signif)>1
               block_start = signif(1);
               block_end = signif(1);
            end
            finished = length(signif)<2;
         end
         
      end
   end
end
mpl.cbh = cloud_base_height;
figure; imagesc(serial2Hh(mpl.time), mpl.range(mpl.r.lte_20), sig_rat); axis('xy'); colormap('jet');
axis([axis, 0, 5e-2,0,5e-2]);
title(['MPL signal to clear sky ratio for ', datestr(mpl.time(1),1)]);
hold on;
plot(serial2Hh(mpl.time), (mpl.cbh>0)-1, 'r.');
ylabel('range (km)');
xlabel('time (UTC)')

% figure; subplot(2,1,1), imagesc(serial2Hh(mpl.time), mpl.range(mpl.r.lte_20), sig_rat); axis('xy'); colormap('jet');
% axis([axis, 0, 5e-2,0,5e-2]);
% title('MPL signal to clear sky ratio times Rayleigh extinction coef.');
% ylabel('range (km)');
% subplot(2,1,2); plot(serial2Hh(mpl.time), mpl.cbh>0, 'r.');
% title('cloud detected');
% v = axis;
% axis([v(1), v(2), .5, 1.5])
% xlabel('time (UTC)')

zoom
