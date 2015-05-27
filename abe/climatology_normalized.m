%%
%This is to determine high cloud day. 20030201
warning('off','MATLAB:dispatcher:InexactMatch')
gname = 'C:\matlab_sandbox\scarps\aerosolbe1turn\';

fgname = [gname  'aerosolbe1turn_parameter_norm.cdf'];
abe = ancload(fgname);
close all
%%

for season = 1:1:(abe.dims.season.length),
       ext1 = zeros(1, 177);
       corr_ext1 = zeros(1, 177);
       new_ext1 = zeros(1, 177);
       % ext1 = abe.vars.ext_mean.data(season, 1, :);
       for k =1:1:(abe.dims.height.length),
            ext1(k) = abe.vars.ext_mean.data(season, 1, k);
       end
       subrange= abe.vars.height.data <=6.7;
       min_ext1 = min(ext1(subrange));
       for k =1:1:(abe.dims.height.length),
            corr_ext1(k) = ext1(k)-min_ext1;
       end
%        aod_1 =abe.vars.aot_mean.data(season,1,:);
%        finite = isfinite(aod_1);
%        aod_1(~finite) = 0;

       for k =1:1:(abe.dims.height.length),
           if (isfinite(abe.vars.aot_mean.data(season,1,k)))
                aod_1(k) = abe.vars.aot_mean.data(season,1,k);
           else
                aod_1(k) = 0;
           end
       end
       %aod_mean_1 = trapz(aod_1, abe.vars.height.data);
       %aod_mean_1 = mean(aod_1);
       
       aod_mean_1 = trapz(ext1(subrange), abe.vars.height.data(subrange));
       
       aod_corr1 = trapz(corr_ext1(subrange), abe.vars.height.data(subrange));
       new_ext1 = ext1 * (aod_mean_1/aod_corr1);
       
       %========================================================
       ext2 = zeros(1, 177);
       corr_ext2 = zeros(1, 177);
       new_ext2 = zeros(1, 177);
       for k =1:1:(abe.dims.height.length),
            ext2(k) = abe.vars.ext_mean.data(season, 2, k);
       end
       min_ext2 = min(ext2);
       for k =1:1:(abe.dims.height.length),
            corr_ext2(k) = ext2(k)-min_ext2;
       end
       for k =1:1:(abe.dims.height.length),
           if (isfinite(abe.vars.aot_mean.data(season,2,k)))
                aod_2(k) = abe.vars.aot_mean.data(season,2,k);
           else
                aod_2(k) = 0;
           end
       end
       %aod_mean_2 = trapz(aod_2, abe.vars.height.data);
       %aod_mean_2 = mean(aod_2);
        aod_mean_2 = trapz(ext2(subrange), abe.vars.height.data(subrange));
       aod_corr2 = trapz(corr_ext2(subrange), abe.vars.height.data(subrange));
       new_ext2 = ext2 * (aod_mean_2/aod_corr2);
        %========================================================
       ext3 = zeros(1, 177);
       corr_ext3 = zeros(1, 177);
       new_ext3 = zeros(1, 177);
       for k =1:1:(abe.dims.height.length),
            ext3(k) = abe.vars.ext_mean.data(season, 3, k);
       end
       min_ext3 = min(ext3);
       for k =1:1:(abe.dims.height.length),
            corr_ext3(k) = ext3(k)-min_ext3;
       end
       for k =1:1:(abe.dims.height.length),
           if (isfinite(abe.vars.aot_mean.data(season,3,k)))
                aod_3(k) = abe.vars.aot_mean.data(season,3,k);
           else
                aod_3(k) = 0;
           end
       end
       %aod_mean_3 = trapz(aod_3, abe.vars.height.data);
       %aod_mean_3 = mean(aod_3);
        aod_mean_3 = trapz(ext3(subrange), abe.vars.height.data(subrange));
       aod_corr3 = trapz(corr_ext3(subrange), abe.vars.height.data(subrange));
       new_ext3 = ext3 * (aod_mean_3/aod_corr3);
        %========================================================
       ext4 = zeros(1, 177);
       corr_ext4 = zeros(1, 177);
       new_ext4 = zeros(1, 177);
       for k =1:1:(abe.dims.height.length),
            ext4(k) = abe.vars.ext_mean.data(season, 4, k);
       end
       min_ext4 = min(ext4);
       for k =1:1:(abe.dims.height.length),
            corr_ext4(k) = ext4(k)-min_ext4;
       end
       for k =1:1:(abe.dims.height.length),
           if (isfinite(abe.vars.aot_mean.data(season,4,k)))
                aod_4(k) = abe.vars.aot_mean.data(season,4,k);
           else
                aod_4(k) = 0;
           end
       end
       %aod_mean_4 = trapz(aod_4, abe.vars.height.data);
       %aod_mean_4 = mean(aod_4);
        aod_mean_4 = trapz(ext4(subrange), abe.vars.height.data(subrange));
       aod_corr4 = trapz(corr_ext4(subrange), abe.vars.height.data(subrange));
       new_ext4 = ext4 * (aod_mean_4/aod_corr4);
        %========================================================
       ext5 = zeros(1, 177);
       corr_ext5 = zeros(1, 177);
       new_ext5 = zeros(1, 177);
       for k =1:1:(abe.dims.height.length),
            ext5(k) = abe.vars.ext_mean.data(season, 5, k);
       end
       min_ext5 = min(ext5);
       for k =1:1:(abe.dims.height.length),
            corr_ext5(k) = ext5(k)-min_ext5;
       end
       for k =1:1:(abe.dims.height.length),
           if (isfinite(abe.vars.aot_mean.data(season,5,k)))
                aod_5(k) = abe.vars.aot_mean.data(season,5,k);
           else
                aod_5(k) = 0;
           end
       end
       %aod_mean_5 = trapz(aod_5, abe.vars.height.data);
       %aod_mean_5 = mean(aod_5);
        aod_mean_5 = trapz(ext5(subrange), abe.vars.height.data(subrange));
       aod_corr5 = trapz(corr_ext5(subrange), abe.vars.height.data(subrange));
       new_ext5 = ext5 * (aod_mean_5/aod_corr5);
        %========================================================
       ext6 = zeros(1, 177);
       corr_ext6 = zeros(1, 177);
       new_ext6 = zeros(1, 177);
       for k =1:1:(abe.dims.height.length),
            ext6(k) = abe.vars.ext_mean.data(season, 6, k);
       end
       min_ext6 = min(ext6);
       for k =1:1:(abe.dims.height.length),
            corr_ext6(k) = ext6(k)-min_ext6;
       end
       for k =1:1:(abe.dims.height.length),
           if (isfinite(abe.vars.aot_mean.data(season,6,k)))
                aod_6(k) = abe.vars.aot_mean.data(season,6,k);
           else
                aod_6(k) = 0;
           end
       end
       %aod_mean_6 = trapz(aod_6, abe.vars.height.data);
        %aod_mean_6 = mean(aod_6);
        aod_mean_6 = trapz(ext6(subrange), abe.vars.height.data(subrange));
       aod_corr6 = trapz(corr_ext6(subrange), abe.vars.height.data(subrange));
       new_ext6 = ext6 * (aod_mean_6/aod_corr6);
        %========================================================
       ext7 = zeros(1, 177);
       corr_ext7 = zeros(1, 177);
       new_ext7 = zeros(1, 177);
       for k =1:1:(abe.dims.height.length),
            ext7(k) = abe.vars.ext_mean.data(season, 7, k);
       end
       min_ext7 = min(ext7);
       for k =1:1:(abe.dims.height.length),
            corr_ext7(k) = ext7(k)-min_ext7;
       end
       for k =1:1:(abe.dims.height.length),
           if (isfinite(abe.vars.aot_mean.data(season,7,k)))
                aod_7(k) = abe.vars.aot_mean.data(season,7,k);
           else
                aod_7(k) = 0;
           end
       end
       %aod_mean_7 = trapz(aod_7, abe.vars.height.data);
       %aod_mean_7 = mean(aod_7);
       aod_mean_7 = trapz(ext7(subrange), abe.vars.height.data(subrange));
       aod_corr7 = trapz(corr_ext7(subrange), abe.vars.height.data(subrange));
       new_ext7 = ext7 * (aod_mean_7/aod_corr7);
       
        %=========================================================
      figure;
      ylim([0, 7]);
      xlim([0, 0.4]);
      subplot(1,1,1);
     
      plot (ext1, abe.vars.height.data, 'r', ...
           ext2, abe.vars.height.data, 'b', ...
           ext3, abe.vars.height.data, 'g', ...
           ext4, abe.vars.height.data, 'k' , ...
           ext5, abe.vars.height.data, 'r', ...
           ext6, abe.vars.height.data, 'b', ...        
           corr_ext1, abe.vars.height.data, 'r.', ...
           corr_ext2, abe.vars.height.data, 'b.', ...
           corr_ext3, abe.vars.height.data, 'g.',...
           corr_ext4, abe.vars.height.data, 'k.', ...
           corr_ext5, abe.vars.height.data, 'r.',...
           corr_ext6, abe.vars.height.data, 'b.',...
           new_ext1, abe.vars.height.data, 'rx-' , ...
           new_ext2, abe.vars.height.data, 'bx-', ...
           new_ext3, abe.vars.height.data, 'gx-',...
           new_ext4, abe.vars.height.data, 'kx-', ...
           new_ext5, abe.vars.height.data, 'rx-',...
           new_ext6, abe.vars.height.data, 'bx-');
          
     
      
      if (season == 1)
          mo = 'DJF';
      elseif (season == 2)
          mo = 'MAM';
      elseif (season ==3)
          mo = 'JJA';
      elseif (season == 4)
          mo = 'SON';
      
      end
                  
       title({'Mean Extinction profile for the season', mo});
       xlabel('Exinction (km -1)');
       ylabel('Altitude (km)');
       
       
      figure;
      ylim([0, 7]);
      xlim([0, 0.4]);
      
      subplot(1,3,1); % subplot (# of rows, # of columns, number). The number
      %increments each time to the next row i.e. 12 th plot will be
      % (4, 3,12);
     
      plot (ext1, abe.vars.height.data, 'r', ...
           ext2, abe.vars.height.data, 'b', ...
           ext3, abe.vars.height.data, 'g', ...
           ext4, abe.vars.height.data, 'k' , ...
           ext5, abe.vars.height.data, 'r', ...
           ext6, abe.vars.height.data, 'b');
       title({'Extinction profile for the season', mo});
       xlabel('Exinction (km -1)');
       ylabel('Altitude (km)');
       subplot(1,3,2);
       plot(corr_ext1, abe.vars.height.data, 'r.', ...
           corr_ext2, abe.vars.height.data, 'b.', ...
           corr_ext3, abe.vars.height.data, 'g.',...
           corr_ext4, abe.vars.height.data, 'k.', ...
           corr_ext5, abe.vars.height.data, 'r.',...
           corr_ext6, abe.vars.height.data, 'b.');
       title({'Corrected Extinction profile for the season', mo});
       xlabel('Exinction (km -1)');
       ylabel('Altitude (km)');
       subplot(1,3,3);
       plot(new_ext1, abe.vars.height.data, 'rx-' , ...
           new_ext2, abe.vars.height.data, 'bx-', ...
           new_ext3, abe.vars.height.data, 'gx-',...
           new_ext4, abe.vars.height.data, 'kx-', ...
           new_ext5, abe.vars.height.data, 'rx-',...
           new_ext6, abe.vars.height.data, 'bx-');
       title({'New Extinction profile for the season', mo});
       xlabel('Exinction (km -1)');
       ylabel('Altitude (km)');
      
      
end
           

%  





    
    
