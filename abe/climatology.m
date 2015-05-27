%%
%This is to determine high cloud day. 20030201
warning('off','MATLAB:dispatcher:InexactMatch')
 gname = 'C:\matlab_sandbox\scarps\aerosolbe1turn\';
% 
 fgname = [gname  'aerosolbe1turn_parameter.cdf'];
%fgname = getfullname('*.cdf','abe')
abe = ancload(fgname);
close all
%%

for season = 1:1:(abe.dims.season.length)
       ext1 = zeros(1, 177);
       corr_ext1 = zeros(1, 177);
       new_ext1 = zeros(1, 177);
       ext1 = squeeze(abe.vars.ext_mean.data(season, 1, :));
       min_ext1 = min(ext1)
       for k =1:1:(abe.dims.height.length),
            corr_ext1(k) = ext1(k)-min_ext1;
       end
       
       
       aod_mean_1 = trapz(abe.vars.height.data, ext1);
       
       aod_corr1 = trapz(abe.vars.height.data, corr_ext1);
       new_ext1 = corr_ext1 * (aod_mean_1/aod_corr1);
       %========================================================
       ext2 = zeros(1, 177);
       corr_ext2 = zeros(1, 177);
       new_ext2 = zeros(1, 177);
       
       ext2 = squeeze(abe.vars.ext_mean.data(season, 2, :));
       min_ext2 = min(ext2)
       
       for k =1:1:(abe.dims.height.length),
            corr_ext2(k) = ext2(k)-min_ext2;
       end
       %trapz(independent variable, dependent variable);
        aod_mean_2 = trapz(abe.vars.height.data, ext2);
       aod_corr2 = trapz(abe.vars.height.data, corr_ext2);
       new_ext2 = corr_ext2 * (aod_mean_2/aod_corr2);
        %========================================================
       ext3 = zeros(1, 177);
       corr_ext3 = zeros(1, 177);
       new_ext3 = zeros(1, 177);
       
       ext3 = squeeze(abe.vars.ext_mean.data(season, 3, :));
    
       min_ext3 = min(ext3)
       for k =1:1:(abe.dims.height.length),
            corr_ext3(k) = ext3(k)-min_ext3;
       end
       
       aod_mean_3 = trapz(abe.vars.height.data, ext3);
       aod_corr3 = trapz(abe.vars.height.data, corr_ext3);
       new_ext3 = corr_ext3 * (aod_mean_3/aod_corr3);
        %========================================================
       ext4 = zeros(1, 177);
       corr_ext4 = zeros(1, 177);
       new_ext4 = zeros(1, 177);
       ext4 = squeeze(abe.vars.ext_mean.data(season, 4, :));
       min_ext4 = min(ext4)
       for k =1:1:(abe.dims.height.length),
            corr_ext4(k) = ext4(k)-min_ext4;
       end
       
        aod_mean_4 = trapz(abe.vars.height.data, ext4);
       aod_corr4 = trapz(abe.vars.height.data, corr_ext4);
       new_ext4 = corr_ext4 * (aod_mean_4/aod_corr4);
        %========================================================
       ext5 = zeros(1, 177);
       corr_ext5 = zeros(1, 177);
       new_ext5 = zeros(1, 177);
       ext5 = squeeze(abe.vars.ext_mean.data(season, 5, :));
       min_ext5 = min(ext5)
       for k =1:1:(abe.dims.height.length),
            corr_ext5(k) = ext5(k)-min_ext5;
       end
       
       aod_mean_5 = trapz(abe.vars.height.data, ext5);
       aod_corr5 = trapz(abe.vars.height.data, corr_ext5);
       new_ext5 = corr_ext5 * (aod_mean_5/aod_corr5);
        %========================================================
       ext6 = zeros(1, 177);
       corr_ext6 = zeros(1, 177);
       new_ext6 = zeros(1, 177);
       
       ext6 = squeeze(abe.vars.ext_mean.data(season, 6, :));
       min_ext6 = min(ext6)
       for k =1:1:(abe.dims.height.length),
            corr_ext6(k) = ext6(k)-min_ext6;
       end
       
       aod_mean_6 = trapz(abe.vars.height.data, ext6);
       aod_corr6 = trapz(abe.vars.height.data, corr_ext6);
       new_ext6 = corr_ext6 * (aod_mean_6/aod_corr6);
        %========================================================
       ext7 = zeros(1, 177);
       corr_ext7 = zeros(1, 177);
       new_ext7 = zeros(1, 177);
      
       ext7 = squeeze(abe.vars.ext_mean.data(season, 7, :));
       min_ext7 = min(ext7)
       for k =1:1:(abe.dims.height.length),
            corr_ext7(k) = ext7(k)-min_ext7;
       end
       
       aod_mean_7 = trapz(abe.vars.height.data, ext7);
       aod_corr7 = trapz(abe.vars.height.data, corr_ext7);
       new_ext7 = corr_ext7 * (aod_mean_7/aod_corr7);
       
        %========================================================
      figure;
      
      subplot(1,1,1);
     
      plot (ext1, abe.vars.height.data, 'r', ...
           ext2, abe.vars.height.data, 'b', ...
           ext3, abe.vars.height.data, 'g', ...
           ext4, abe.vars.height.data, 'k' , ...
           ext5, abe.vars.height.data, 'r', ...
           ext6, abe.vars.height.data, 'b', ...     
           ext7, abe.vars.height.data, 'y', ...  
           corr_ext1, abe.vars.height.data, 'r.', ...
           corr_ext2, abe.vars.height.data, 'b.', ...
           corr_ext3, abe.vars.height.data, 'g.',...
           corr_ext4, abe.vars.height.data, 'k.', ...
           corr_ext5, abe.vars.height.data, 'r.',...
           corr_ext6, abe.vars.height.data, 'b.',...
           corr_ext7, abe.vars.height.data, 'y.',...
           new_ext1, abe.vars.height.data, 'rx-' , ...
           new_ext2, abe.vars.height.data, 'bx-', ...
           new_ext3, abe.vars.height.data, 'gx-',...
           new_ext4, abe.vars.height.data, 'kx-', ...
           new_ext5, abe.vars.height.data, 'rx-',...
           new_ext6, abe.vars.height.data, 'bx-', ...
           new_ext7, abe.vars.height.data, 'yx-');
          
      ylim([0, 7]); % after you plot always to limit
      xlim([0, 0.4]);
      
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
        ylim([0, 7]);
      xlim([0, 0.4]);
      
      
end
%%
%==========================================================================
% Calculate the min per aod bin.
%==========================================================================
           

%  
for season = 1:1:(abe.dims.season.length)
       ext1 = zeros(1, 177);
       corr_ext1 = zeros(1, 177);
       new_ext1 = zeros(1, 177);
       
       ext1 = squeeze(abe.vars.ext_mean.data(season,1, :));
       min_ext1 = min(min(abe.vars.ext_mean.data(:,1,:)))
       for k =1:1:(abe.dims.height.length),
            corr_ext1(k) = ext1(k)-min_ext1;
       end
       
       
       aod_mean_1 = trapz(abe.vars.height.data, ext1);  
       aod_corr1 = trapz(abe.vars.height.data, corr_ext1);
       new_ext1 = corr_ext1 * (aod_mean_1/aod_corr1);
       %===========================================================
       ext2 = zeros(1, 177);
       corr_ext2 = zeros(1, 177);
       new_ext2 = zeros(1, 177);
       
       ext2 = squeeze(abe.vars.ext_mean.data(season, 2, :));
       min_ext2 = min(min(abe.vars.ext_mean.data(:,2,:)))
       
       for k =1:1:(abe.dims.height.length),
            corr_ext2(k) = ext2(k)-min_ext2;
       end
       %trapz(independent variable, dependent variable);
        aod_mean_2 = trapz(abe.vars.height.data, ext2);
       aod_corr2 = trapz(abe.vars.height.data, corr_ext2);
       new_ext2 = corr_ext2 * (aod_mean_2/aod_corr2);
        %========================================================
       ext3 = zeros(1, 177);
       corr_ext3 = zeros(1, 177);
       new_ext3 = zeros(1, 177);
       
       ext3 = squeeze(abe.vars.ext_mean.data(season, 3, :));
        min_ext3 = min(min(abe.vars.ext_mean.data(:,3,:)))
       
       for k =1:1:(abe.dims.height.length),
            corr_ext3(k) = ext3(k)-min_ext3;
       end
       
       aod_mean_3 = trapz(abe.vars.height.data, ext3);
       aod_corr3 = trapz(abe.vars.height.data, corr_ext3);
       new_ext3 = corr_ext3 * (aod_mean_3/aod_corr3);
        %========================================================
       ext4 = zeros(1, 177);
       corr_ext4 = zeros(1, 177);
       new_ext4 = zeros(1, 177);
       ext4 = squeeze(abe.vars.ext_mean.data(season, 4, :));
       min_ext4 = min(min(abe.vars.ext_mean.data(:,4,:)))
       for k =1:1:(abe.dims.height.length),
            corr_ext4(k) = ext4(k)-min_ext4;
       end
       
        aod_mean_4 = trapz(abe.vars.height.data, ext4);
       aod_corr4 = trapz(abe.vars.height.data, corr_ext4);
       new_ext4 = corr_ext4 * (aod_mean_4/aod_corr4);
        %========================================================
       ext5 = zeros(1, 177);
       corr_ext5 = zeros(1, 177);
       new_ext5 = zeros(1, 177);
       ext5 = squeeze(abe.vars.ext_mean.data(season, 5, :));
       min_ext5 = min(min(abe.vars.ext_mean.data(:,5,:)))
       for k =1:1:(abe.dims.height.length),
            corr_ext5(k) = ext5(k)-min_ext5;
       end
       
       aod_mean_5 = trapz(abe.vars.height.data, ext5);
       aod_corr5 = trapz(abe.vars.height.data, corr_ext5);
       new_ext5 = corr_ext5 * (aod_mean_5/aod_corr5);
        %========================================================
       ext6 = zeros(1, 177);
       corr_ext6 = zeros(1, 177);
       new_ext6 = zeros(1, 177);
       
       ext6 = squeeze(abe.vars.ext_mean.data(season, 6, :));
       min_ext6 = min(min(abe.vars.ext_mean.data(:,6,:)))
       for k =1:1:(abe.dims.height.length),
            corr_ext6(k) = ext6(k)-min_ext6;
       end
       
       aod_mean_6 = trapz(abe.vars.height.data, ext6);
       aod_corr6 = trapz(abe.vars.height.data, corr_ext6);
       new_ext6 = corr_ext6 * (aod_mean_6/aod_corr6);
        %========================================================
       ext7 = zeros(1, 177);
       corr_ext7 = zeros(1, 177);
       new_ext7 = zeros(1, 177);
      
       ext7 = squeeze(abe.vars.ext_mean.data(season, 7, :));
       min_ext1 = min(min(abe.vars.ext_mean.data(:,7,:)))
       for k =1:1:(abe.dims.height.length),
            corr_ext7(k) = ext7(k)-min_ext7;
       end
       
       aod_mean_7 = trapz(abe.vars.height.data, ext7);
       aod_corr7 = trapz(abe.vars.height.data, corr_ext7);
       new_ext7 = corr_ext7 * (aod_mean_7/aod_corr7);
       
        %========================================================
      figure;
      
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
          
      ylim([0, 7]); % after you plot always to limit
      xlim([0, 0.4]);
      
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
       title({'Corrected by the minimum of each bin for the season', mo});
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
        ylim([0, 7]);
      xlim([0, 0.4]);
      
end

%%

%%
%==========================================================================
% Calculate the min per quarter.
%==========================================================================
           
close all
%  
for season = 1:1:(abe.dims.season.length)
       ext1 = zeros(1, 177);
       corr_ext1 = zeros(1, 177);
       new_ext1 = zeros(1, 177);
       
       ext1 = squeeze(abe.vars.ext_mean.data(season,1, :));
       min_ext1 = min(min(abe.vars.ext_mean.data(season,:,:)))
       for k =1:1:(abe.dims.height.length),
            corr_ext1(k) = ext1(k)-min_ext1;
       end
       
       %normalizing the data
       aod_mean_1 = trapz(abe.vars.height.data, ext1);  
       aod_corr1 = trapz(abe.vars.height.data, corr_ext1);
       new_ext1 = corr_ext1 * (aod_mean_1/aod_corr1);
       %===========================================================
       ext2 = zeros(1, 177);
       corr_ext2 = zeros(1, 177);
       new_ext2 = zeros(1, 177);
       
       ext2 = squeeze(abe.vars.ext_mean.data(season, 2, :));
       min_ext2 = min(min(abe.vars.ext_mean.data(season,:,:)))
       
       for k =1:1:(abe.dims.height.length),
            corr_ext2(k) = ext2(k)-min_ext2;
       end
       %trapz(independent variable, dependent variable);
       aod_mean_2 = trapz(abe.vars.height.data, ext2);
       aod_corr2 = trapz(abe.vars.height.data, corr_ext2);
       new_ext2 = corr_ext2 * (aod_mean_2/aod_corr2);
        %========================================================
       ext3 = zeros(1, 177);
       corr_ext3 = zeros(1, 177);
       new_ext3 = zeros(1, 177);
       
       ext3 = squeeze(abe.vars.ext_mean.data(season, 3, :));
       min_ext3 = min(min(abe.vars.ext_mean.data(season,:,:)))
       
       for k =1:1:(abe.dims.height.length),
            corr_ext3(k) = ext3(k)-min_ext3;
       end
       
       aod_mean_3 = trapz(abe.vars.height.data, ext3);
       aod_corr3 = trapz(abe.vars.height.data, corr_ext3);
       new_ext3 = corr_ext3 * (aod_mean_3/aod_corr3);
        %========================================================
       ext4 = zeros(1, 177);
       corr_ext4 = zeros(1, 177);
       new_ext4 = zeros(1, 177);
       ext4 = squeeze(abe.vars.ext_mean.data(season, 4, :));
       min_ext4 = min(min(abe.vars.ext_mean.data(season,:,:)))
       for k =1:1:(abe.dims.height.length),
            corr_ext4(k) = ext4(k)-min_ext4;
       end
       
       aod_mean_4 = trapz(abe.vars.height.data, ext4);
       aod_corr4 = trapz(abe.vars.height.data, corr_ext4);
       new_ext4 = corr_ext4 * (aod_mean_4/aod_corr4);
        %========================================================
       ext5 = zeros(1, 177);
       corr_ext5 = zeros(1, 177);
       new_ext5 = zeros(1, 177);
       ext5 = squeeze(abe.vars.ext_mean.data(season, 5, :));
       min_ext5 = min(min(abe.vars.ext_mean.data(season,:,:)))
       for k =1:1:(abe.dims.height.length),
            corr_ext5(k) = ext5(k)-min_ext5;
       end
       
       aod_mean_5 = trapz(abe.vars.height.data, ext5);
       aod_corr5 = trapz(abe.vars.height.data, corr_ext5);
       new_ext5 = corr_ext5 * (aod_mean_5/aod_corr5);
        %========================================================
       ext6 = zeros(1, 177);
       corr_ext6 = zeros(1, 177);
       new_ext6 = zeros(1, 177);
       
       ext6 = squeeze(abe.vars.ext_mean.data(season, 6, :));
       min_ext6 = min(min(abe.vars.ext_mean.data(season,:,:)))
       for k =1:1:(abe.dims.height.length),
            corr_ext6(k) = ext6(k)-min_ext6;
       end
       
       aod_mean_6 = trapz(abe.vars.height.data, ext6);
       aod_corr6 = trapz(abe.vars.height.data, corr_ext6);
       new_ext6 = corr_ext6 * (aod_mean_6/aod_corr6);
        %========================================================
       ext7 = zeros(1, 177);
       corr_ext7 = zeros(1, 177);
       new_ext7 = zeros(1, 177);
      
       ext7 = squeeze(abe.vars.ext_mean.data(season, 7, :));
       min_ext7 = min(min(abe.vars.ext_mean.data(season,:,:)))
       for k =1:1:(abe.dims.height.length),
            corr_ext7(k) = ext7(k)-min_ext7;
       end
       
       aod_mean_7 = trapz(abe.vars.height.data, ext7);
       aod_corr7 = trapz(abe.vars.height.data, corr_ext7);
       new_ext7 = corr_ext7 * (aod_mean_7/aod_corr7);
       
        %========================================================
      figure;
      
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
          
      ylim([0, 7]); % after you plot always to limit
      xlim([0, 0.4]);
      
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
       title({'Corrected by the quaterly minimum for the season', mo});
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
        ylim([0, 7]);
      xlim([0, 0.4]);
      
end
%%
close all
%% This is a global minimum applied to all ext profiles.
%% This may not work since the minimun for all periods is -538.1794

 
for season = 1:1:(abe.dims.season.length)
       ext1 = zeros(1, 177);
       corr_ext1 = zeros(1, 177);
       new_ext1 = zeros(1, 177);
       
       ext1 = squeeze(abe.vars.ext_mean.data(season,1, :));
       min_ext1 = min(min(abe.vars.ext_mean.data(:,:,:)))
       for k =1:1:(abe.dims.height.length),
            corr_ext1(k) = ext1(k)-min_ext1;
       end
       
       
       aod_mean_1 = trapz(abe.vars.height.data, ext1);  
       aod_corr1 = trapz(abe.vars.height.data, corr_ext1);
       new_ext1 = corr_ext1 * (aod_mean_1/aod_corr1);
       %===========================================================
       ext2 = zeros(1, 177);
       corr_ext2 = zeros(1, 177);
       new_ext2 = zeros(1, 177);
       
       ext2 = squeeze(abe.vars.ext_mean.data(season, 2, :));
       min_ext2 = min(min(abe.vars.ext_mean.data(:,:,:)))
       
       for k =1:1:(abe.dims.height.length),
            corr_ext2(k) = ext2(k)-min_ext2;
       end
       %trapz(independent variable, dependent variable);
       aod_mean_2 = trapz(abe.vars.height.data, ext2);
       aod_corr2 = trapz(abe.vars.height.data, corr_ext2);
       new_ext2 = corr_ext2 * (aod_mean_2/aod_corr2);
        %========================================================
       ext3 = zeros(1, 177);
       corr_ext3 = zeros(1, 177);
       new_ext3 = zeros(1, 177);
       
       ext3 = squeeze(abe.vars.ext_mean.data(season, 3, :));
       min_ext3 = min(min(abe.vars.ext_mean.data(:,:,:)))
       
       for k =1:1:(abe.dims.height.length),
            corr_ext3(k) = ext3(k)-min_ext3;
       end
       
       aod_mean_3 = trapz(abe.vars.height.data, ext3);
       aod_corr3 = trapz(abe.vars.height.data, corr_ext3);
       new_ext3 = corr_ext3 * (aod_mean_3/aod_corr3);
        %========================================================
       ext4 = zeros(1, 177);
       corr_ext4 = zeros(1, 177);
       new_ext4 = zeros(1, 177);
       ext4 = squeeze(abe.vars.ext_mean.data(season, 4, :));
       min_ext4 = min(min(abe.vars.ext_mean.data(:,:,:)))
       for k =1:1:(abe.dims.height.length),
            corr_ext4(k) = ext4(k)-min_ext4;
       end
       
       aod_mean_4 = trapz(abe.vars.height.data, ext4);
       aod_corr4 = trapz(abe.vars.height.data, corr_ext4);
       new_ext4 = corr_ext4 * (aod_mean_4/aod_corr4);
        %========================================================
       ext5 = zeros(1, 177);
       corr_ext5 = zeros(1, 177);
       new_ext5 = zeros(1, 177);
       ext5 = squeeze(abe.vars.ext_mean.data(season, 5, :));
       min_ext5 = min(min(abe.vars.ext_mean.data(:,:,:)))
       for k =1:1:(abe.dims.height.length),
            corr_ext5(k) = ext5(k)-min_ext5;
       end
       
       aod_mean_5 = trapz(abe.vars.height.data, ext5);
       aod_corr5 = trapz(abe.vars.height.data, corr_ext5);
       new_ext5 = corr_ext5 * (aod_mean_5/aod_corr5);
        %========================================================
       ext6 = zeros(1, 177);
       corr_ext6 = zeros(1, 177);
       new_ext6 = zeros(1, 177);
       
       ext6 = squeeze(abe.vars.ext_mean.data(season, 6, :));
       min_ext6 = min(min(abe.vars.ext_mean.data(:,:,:)))
       for k =1:1:(abe.dims.height.length),
            corr_ext6(k) = ext6(k)-min_ext6;
       end
       
       aod_mean_6 = trapz(abe.vars.height.data, ext6);
       aod_corr6 = trapz(abe.vars.height.data, corr_ext6);
       new_ext6 = corr_ext6 * (aod_mean_6/aod_corr6);
        %========================================================
       ext7 = zeros(1, 177);
       corr_ext7 = zeros(1, 177);
       new_ext7 = zeros(1, 177);
      
       ext7 = squeeze(abe.vars.ext_mean.data(season, 7, :));
       min_ext7 = min(min(abe.vars.ext_mean.data(:,:,:)))
       for k =1:1:(abe.dims.height.length),
            corr_ext7(k) = ext7(k)-min_ext7;
       end
       
       aod_mean_7 = trapz(abe.vars.height.data, ext7);
       aod_corr7 = trapz(abe.vars.height.data, corr_ext7);
       new_ext7 = corr_ext7 * (aod_mean_7/aod_corr7);
       
        %========================================================
      figure;
      
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
          
      ylim([0, 7]); % after you plot always to limit
      xlim([0, 0.4]);
      
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
       title({'Corrected by the quaterly minimum for the season', mo});
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
        ylim([0, 7]);
      xlim([0, 0.4]);
      
end

    
    
