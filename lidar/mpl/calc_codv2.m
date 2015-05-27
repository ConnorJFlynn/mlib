function [cod, below_lo, below_hi, above_lo, above_hi, flag] = calc_cod(height, backscatter, cloud_mask, atten, max_deviation, snr);
% cod = calc_cod(height, backscatter, cloud_mask, atten, max_deviation, snr);
% [cod, below_lo, below_hi, above_lo, above_hi, flag] = calc_cod(height, backscatter, cloud_mask, atten, max_deviation, snr);
% Returns -1 for failed retrieval (cloud base too low or noise too large)
% Returns 0 for no cloud detected
% Returns positive numbers for cloud optical thickness
% This function is designed for "thin" cloud optical depth retrieval
% At a certain point this retrieval is unreliable due to attenuation of 
% signal below the signal to noise level.
% flag is a bit-mapped field: 0 = true; 1 = false
% flag_bit_0: cloud detected (same as num_cloud_bins > 0)
% flag_bit_1: cloud base > 200 meters from ground
% flag_bit_2: found clear air region below cloud
% flag_bit_3: found molecular return above cloud
% flag_bit_4: more than zero bins retained below cloud
% flag_bit_5: more than zero bins retained above cloud
% flag_bit_6: positive average backscatter below cloud
% flag_bit_7: positive attenuated profile below cloud
% flag_bit_8: positive average backscatter above cloud
% flag_bit_9: positive attenuated profile above cloud
% flag_bit_10 positive optical depth retrieved

flag = 0;
zero_bins = find(backscatter<=0);
pos_bins = find(backscatter>0);
least_value = min(backscatter(pos_bins));
backscatter(zero_bins) = 1e-3*least_value;

cloud_bins = find(cloud_mask==1);
num_cloud_bins = length(cloud_bins);
if num_cloud_bins==0
   flag = flag +1;
end
if num_cloud_bins>0
   below_cloud = find((height>.2)&(height<height(min(cloud_bins))));
   num_below =length(below_cloud);
   if num_below == 0
      flag = flag + 2;
   end
   
   % Make sure we aren't in virga below the cloud by requiring a negative slope before the cloud base
   % Step down from detected cbh one bin at a time until backscat increases.
   % Exit if 3 or fewer bins left.
   while ((backscatter(max(below_cloud)-1)<backscatter(max(below_cloud)))&(num_below>3))         
      below_cloud(length(below_cloud)) =[];
      num_below =length(below_cloud);
   end;
   
   % Now, attempt to remove region below cloud that is contaminated by aerosol. 
   % Do this by calculating the ratio of measured backscatter divided by the attenutated profile.
   % and discarding any points falling above a certain threshold.
   % This process is iterated until all remaining points are within max_deviation of the mean.  
   % Ultimately, a robost fitting algorithm would be most appropriate. 
   done=-1;
   while (num_below>4)&(done<0)
      backscat_to_atten_ratio = backscatter(below_cloud)./atten(below_cloud);
      mean_ratio = mean(backscat_to_atten_ratio);
      below_cloud = below_cloud(find((backscat_to_atten_ratio < ((1+max_deviation)*mean_ratio))));
      num_discarded = num_below - length(below_cloud);
      if num_discarded <= 0
         done = 1;
      end
      num_below = length(below_cloud);
   end;
   
   % Constrain "above_cloud" indices so they don't exceed the atten profile length
   above_cloud  = find((height>height(max(cloud_bins)))&(height<height(length(atten))));
   top = min(find(backscatter(above_cloud)<least_value));
   above_cloud = above_cloud(1:top);
   num_above = length(above_cloud);
   
   % Also make sure that beam isn't attenuated away prior to this point by looking for least_value
   if any(backscatter(below_cloud(num_below):above_cloud(1))<least_value)
      above_cloud = [];
      num_above = 0;
   end
   
   % Make sure we are above the cloud by requiring the ratio of backscatter to sonde above the cloud
   % to be less than the ratio below the cloud.
   % If not then step out in bins towards upper bound.
   % Repeat until appropriate backscatter or less than 25 bins.
   if num_below > 3
      P_below = polyfit(height(below_cloud), (backscatter(below_cloud)./atten(below_cloud)), 1);
      ratio_from_below = polyval(P_below,height(below_cloud(num_below)));
   else
      ratio_from_below = mean(backscatter(below_cloud)./atten(below_cloud));
   end

   done=-1;
   
   while ((done<0)&(num_above>10))
      ratio_at_cloud_top = mean(backscatter(above_cloud(1:10))./atten(above_cloud(1:10)));
      if ~any(ratio_at_cloud_top > ratio_from_below)
         done = 1;
      end
      above_cloud(1:2) = [];
      num_above = length(above_cloud);
   end;
   
   % Now, attempt to step above the cloud region one bin at a time by checking the lowest 
   % above-cloud bin against the log fit of the next ten higher bins. 
   % Require agreement better than max_deviation
   done=-1;
   while ((done<0)&(num_above>10))
      near = above_cloud(2:11);
      P = polyfit(height(near), real(log(backscatter(near))), 1);
      nearest_backscatter = exp(polyval(P,(height(above_cloud(1)))));
      test = abs((backscatter(above_cloud(1))-nearest_backscatter)./nearest_backscatter);
      %[above_cloud(1), test]
      if test < max_deviation
         done = 1;
      else
         above_cloud(1) = [];
         num_above = length(above_cloud);
      end
   end;
   
  
   % Now, attempt to remove region above cloud that is too attenuated or noisy to be useful. 
   % Do this by requiring the ratio of backscatter near and far to be similar to the
   % ratio of the atten profile.  If they're not, discard the upper 1/3 above cloud.
   % This comparison is predicated on there not being any significant cloud or aerosol 
   % return above the detected cloud top.
    done=-1;

   while ((done<0)&(num_above>=6))
      near = above_cloud(1:floor(num_above/2));
      far = above_cloud(floor(num_above/2):num_above);
            
      P = polyfit(height(near), real(log(atten(near))), 1);
      near_atten = exp(polyval(P,mean(height(near))));
      P = polyfit(height(far), real(log(atten(far))), 1);
      far_atten = exp(polyval(P,mean(height(far))));
      atten_ratio = far_atten./near_atten;         
      
      %          P = polyfit(height(near), real(log(backscatter(near,t))), 1);
      %          near_backscatter = exp(polyval(P,mean(height(near))));
      %          P = polyfit(height(far), real(log(backscatter(far,t))), 1);
      
      P = polyfit(height(near), real(log(backscatter(near))), 1);
      near_backscatter = exp(polyval(P,mean(height(near))));
      P = polyfit(height(far), real(log(backscatter(far))), 1);
      far_backscatter = exp(polyval(P,mean(height(far))));
      backscatter_ratio = far_backscatter/near_backscatter;              
      
      Q = backscatter_ratio / atten_ratio;
      R = 1-Q;
      if ((Q>0)&(abs(R)<(max_deviation)))
         above_cloud = above_cloud(1:floor(0.66*num_above));
         num_above = length(above_cloud);            
         done = 1;
      else
         above_cloud = above_cloud(1:floor(0.66*num_above));
         num_above = length(above_cloud);
      end
   end;
   
   % flag_bit_0: 1 cloud detected (same as num_cloud_bins > 0)
   % flag_bit_1: 2 cloud base > 200 meter from ground
   % flag_bit_2: 4 found clear air region below cloud
   % flag_bit_3: 8 reliable molecular return above cloud
   % flag_bit_4: 16 more than zero bins retained below cloud
   % flag_bit_5: 32 more than zero bins retained above cloud
   % flag_bit_6: 64 positive average backscatter below cloud
   % flag_bit_7: 128 positive attenuated profile below cloud
   % flag_bit_8: 256 positive average backscatter above cloud
   % flag_bit_9: 512 positive attenuated profile above cloud
   % flag_bit_10 1024 positive optical depth retrieved
   
   
   
   if num_below <=3
      flag = flag + 4; % flag_bit_2:  clear air region below cloud FALSE
   end
   if num_above <= 5
      flag = flag + 8;
   end;
   if num_below==0
      flag = flag + 16;
   end
   if num_above==0
      flag = flag + 32;
   end
   
   if ((num_below > 0)&(num_above >= 6)) %Then there are at least enough bins to work with
      %   if ((num_below > 3)&(num_above > 5)) %Then there are enough bins to work with
      
      % Might want to re-visit this using atten_ratio and backscatter_ratio and predicted
      % values near cloud base and cloud top. (Similar to above treatment)
      
      if mean(backscatter(below_cloud)<=0)
         flag = flag + 64;
      end
      if mean(atten(below_cloud)<=0)
         flag = flag + 128;
      end      
      if mean(backscatter(above_cloud)<=0)
         flag = flag + 256;
      end
      if mean(atten(above_cloud)<=0)
         flag = flag + 512;
      end    
      
      below_ratio = mean(backscatter(below_cloud)./atten(below_cloud)); 
      above_ratio = mean(backscatter(above_cloud))./mean(atten(above_cloud));
      cloud_transmittance_squared = above_ratio / below_ratio;
      if cloud_transmittance_squared >= 1
         flag = flag + 1024; %optical depth less than one
         %check for positive inputs and transmittance <=1
      end

      %if ((mean(atten(below_cloud))>0)&(mean(backscatter(below_cloud))>0)&(mean(atten(above_cloud))>0)&(mean(backscatter(above_cloud))>0)&(cloud_transmittance_squared<=1))
      if ((mean(atten(below_cloud))>0)&(mean(backscatter(below_cloud))>0)&(mean(atten(above_cloud))>0)&(mean(backscatter(above_cloud))>0))         
         cloud_optical_depth = -0.5 * log(cloud_transmittance_squared);
         nsr = std(backscatter(above_cloud))/mean(backscatter(above_cloud));
%          if nsr > max_deviation
%             cloud_optical_depth = 5;
%          end
%          if cloud_optical_depth <= -.1 
%              semilogy(height, backscatter, 'b',  height(below_cloud), mean(backscatter(below_cloud))*[ones(1,length(below_cloud))],'g', height(above_cloud),  std(backscatter(above_cloud))*[ones(1,length(above_cloud))], 'r', height(max(cloud_bins)),  backscatter(max(cloud_bins)), 'yo')
%              title(['optical depth = ', num2str(cloud_optical_depth), ' num_below = ', num2str(num_below), ' num_above =', num2str(num_above)])
%              %axis([min(below_cloud) max(above_cloud) 1e-5 1e1])
%              zoom on
%           end
         below_lo = height(min(below_cloud));
         below_hi = height(max(below_cloud));
         above_lo = height(min(above_cloud));
         above_hi = height(max(above_cloud));
      else
         cloud_optical_depth = -1;
         below_lo = height(min(below_cloud));
         below_hi = height(max(below_cloud));
         above_lo = height(min(above_cloud));
         above_hi = height(max(above_cloud));
      end;

    
      %         below_ratio = min(atten(below_cloud)./backscatter(below_cloud,t));  
   else %Either the cloud is too low to the ground (preventing below cloud determination)
      %or there aren't enough bins above the cloud with significant molecular signal 
      cloud_optical_depth = -1;
      below_lo = 0;
      below_hi = 0;
      above_lo = 0;
      above_hi = 0;
   end;
   
else %no cloud was detected, so set cloud optical depth = 0.
   flag = flag + 1;
   cloud_optical_depth = 0;
   below_lo = 0;
   below_hi = max(height);
   above_lo = 0;
   above_hi = max(height);
end;
if above_hi>40
   disp('what the?');
end
cod = cloud_optical_depth;

%end;