%%
clear
%This is to determine high cloud day. 20030201
warning('off','MATLAB:dispatcher:InexactMatch')
% gname = 'C:\matlab_sandbox\scarps\aerosolbe1turn\';
%
% fgname = [gname  'aerosolbe1turn_parameter.cdf'];
%fgname = getfullname('*.cdf','abe')
fgname = 'C:\mlib\abe\aerosolbe1turn_parameter.cdf';

abe = ancload(fgname);
close all
%%
% First, clean up data supplied by Dave.
% Namely, the winter profiles for high bins are unreliable, so replace with 
% scaled versions of lower bins. 
season = 1; %DJF
aod_bin6 = trapz(abe.vars.height.data, abe.vars.ext_mean.data(season, 6, :));
aod_bin5 = trapz(abe.vars.height.data, abe.vars.ext_mean.data(season, 5, :));
abe.vars.ext_mean.data(season, 6, :) = (aod_bin6./aod_bin5).* squeeze(abe.vars.ext_mean.data(season, 5, :));

% Simlarly, the lowest bin in JJA is unreliable, so replace it with a
% scaled version of bin 2.

season = 3; %JJA
aod_bin1 = trapz(abe.vars.height.data, abe.vars.ext_mean.data(season, 1, :));
aod_bin2 = trapz(abe.vars.height.data, abe.vars.ext_mean.data(season, 2, :));
abe.vars.ext_mean.data(season, 1, :) = (aod_bin1./aod_bin2).* squeeze(abe.vars.ext_mean.data(season, 2, :));

% Next, find min below 6.5 km and shift profile accordingly.
r.lte_6p5 = abe.vars.height.data<=6.5;
% next, rescale profile to match previous aod.
tic % start timing Connor's code

new_ext = zeros(size(abe.vars.ext_mean.data));
corr_ext = zeros(size(abe.vars.ext_mean.data));

for season = abe.dims.season.length:-1:1
   for bin = abe.dims.bin.length:-1:1
      ext = squeeze(abe.vars.ext_mean.data(season, bin, :));
      aod = squeeze(abe.vars.aot_mean.data(season,bin,:));
      min_ext = min([0,min(ext(r.lte_6p5))]);
      corr_ext_ = ext - min_ext;
      aod(~isfinite(aod)) = 0;
      aod_mean = trapz(abe.vars.height.data, ext);
      aod_corr = trapz(abe.vars.height.data, corr_ext_);
      abe.vars.ext_mean.data(season, bin, :) = ext;
      corr_ext(season,bin,:) = corr_ext_;
      new_ext(season,bin,:) = corr_ext_ * (aod_mean./aod_corr);
      new_ext(season,bin,~r.lte_6p5) = 0;
      tmp = squeeze(new_ext(season,bin,:));
      tmp(isnan(tmp))=0;
      tmp(~isfinite(tmp))=0;
      new_ext(season,bin,:) = tmp;
      
   end %bin
end %season loop;
abe.vars.ext_mean.data = new_ext;
[pname,fname,ext] = fileparts(abe.fname);
abe.fname = [pname, filesep, fname, '_2',ext];
abe.clobber = true;
anccheck(abe);
ancsave(abe);
toc % stop timing Connor code
%========================================================
for season = abe.dims.season.length:-1:1

figure;
if (season == 1)
   mo = 'DJF';
elseif (season == 2)
   mo = 'MAM';
elseif (season ==3)
   mo = 'JJA';
elseif (season == 4)
   mo = 'SON';

end

subplot(1,3,1); % subplot (# of rows, # of columns, number). The number
%increments each time to the next row i.e. 12 th plot will be
% (4, 3,12);

plot (squeeze(abe.vars.ext_mean.data(season, 1, :)), abe.vars.height.data, 'r', ...
   squeeze(abe.vars.ext_mean.data(season, 2, :)), abe.vars.height.data, 'b', ...
   squeeze(abe.vars.ext_mean.data(season, 3, :)), abe.vars.height.data, 'g', ...
   squeeze(abe.vars.ext_mean.data(season, 4, :)), abe.vars.height.data, 'k' , ...
   squeeze(abe.vars.ext_mean.data(season, 5, :)), abe.vars.height.data, 'r', ...
   squeeze(abe.vars.ext_mean.data(season, 6, :)), abe.vars.height.data, 'b');
title({'Extinction profile for the season', mo});
xlabel('Exinction (km -1)');
ylabel('Altitude (km)');
ylim([0, 7]);

subplot(1,3,2);
plot(squeeze(corr_ext(season,1,:)), abe.vars.height.data, 'r.', ...
   squeeze(corr_ext(season,2,:)), abe.vars.height.data, 'b.', ...
   squeeze(corr_ext(season,3,:)), abe.vars.height.data, 'g.',...
   squeeze(corr_ext(season,4,:)), abe.vars.height.data, 'k.', ...
   squeeze(corr_ext(season,5,:)), abe.vars.height.data, 'r.',...
   squeeze(corr_ext(season,6,:)), abe.vars.height.data, 'b.');
title({'Corrected Extinction profile for the season', mo});
xlabel('Exinction (km -1)');
ylabel('Altitude (km)');
subplot(1,3,3);
plot(squeeze(new_ext(season,1,:)), abe.vars.height.data, 'rx-' , ...
   squeeze(new_ext(season,2,:)), abe.vars.height.data, 'bx-', ...
   squeeze(new_ext(season,3,:)), abe.vars.height.data, 'gx-',...
   squeeze(new_ext(season,4,:)), abe.vars.height.data, 'kx-', ...
   squeeze(new_ext(season,5,:)), abe.vars.height.data, 'rx-',...
   squeeze(new_ext(season,6,:)), abe.vars.height.data, 'bx-');
title({'New Extinction profile for the season', mo});
xlabel('Exinction (km -1)');
ylabel('Altitude (km)');


end

abe = ancload(abe.fname);
for season = abe.dims.season.length:-1:1

figure;
if (season == 1)
   mo = 'DJF';
elseif (season == 2)
   mo = 'MAM';
elseif (season ==3)
   mo = 'JJA';
elseif (season == 4)
   mo = 'SON';

end

subplot(1,3,1); % subplot (# of rows, # of columns, number). The number
%increments each time to the next row i.e. 12 th plot will be
% (4, 3,12);

plot (squeeze(abe.vars.ext_mean.data(season, 1, :)), abe.vars.height.data, 'r', ...
   squeeze(abe.vars.ext_mean.data(season, 2, :)), abe.vars.height.data, 'b', ...
   squeeze(abe.vars.ext_mean.data(season, 3, :)), abe.vars.height.data, 'g', ...
   squeeze(abe.vars.ext_mean.data(season, 4, :)), abe.vars.height.data, 'k' , ...
   squeeze(abe.vars.ext_mean.data(season, 5, :)), abe.vars.height.data, 'r', ...
   squeeze(abe.vars.ext_mean.data(season, 6, :)), abe.vars.height.data, 'b');
title({'Extinction profile for the season', mo});
xlabel('Exinction (km -1)');
ylabel('Altitude (km)');
ylim([0, 7]);

subplot(1,3,2);
plot(squeeze(corr_ext(season,1,:)), abe.vars.height.data, 'r.', ...
   squeeze(corr_ext(season,2,:)), abe.vars.height.data, 'b.', ...
   squeeze(corr_ext(season,3,:)), abe.vars.height.data, 'g.',...
   squeeze(corr_ext(season,4,:)), abe.vars.height.data, 'k.', ...
   squeeze(corr_ext(season,5,:)), abe.vars.height.data, 'r.',...
   squeeze(corr_ext(season,6,:)), abe.vars.height.data, 'b.');
title({'Corrected Extinction profile for the season', mo});
xlabel('Exinction (km -1)');
ylabel('Altitude (km)');
subplot(1,3,3);
plot(squeeze(new_ext(season,1,:)), abe.vars.height.data, 'rx-' , ...
   squeeze(new_ext(season,2,:)), abe.vars.height.data, 'bx-', ...
   squeeze(new_ext(season,3,:)), abe.vars.height.data, 'gx-',...
   squeeze(new_ext(season,4,:)), abe.vars.height.data, 'kx-', ...
   squeeze(new_ext(season,5,:)), abe.vars.height.data, 'rx-',...
   squeeze(new_ext(season,6,:)), abe.vars.height.data, 'bx-');
title({'New Extinction profile for the season', mo});
xlabel('Exinction (km -1)');
ylabel('Altitude (km)');


end

%







