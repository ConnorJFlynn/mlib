function machol 
mpl_dir = 'C:\case_studies\tnmpl\day_mat\';
mpl_png = 'C:\case_studies\tnmpl\day_png\';
mpl_txt = 'C:\case_studies\tnmpl\day_txt\';
ol_corr_ray = loadinto(['C:\case_studies\tnmpl\ol_corr_frac.mat']);
if ~exist(mpl_dir,'dir')
   mpl_dir = getdir('tnmpl');
end
mpl_file = dir([mpl_dir, '*.mat']);

for m = 1:length(mpl_file)
   mplz_day = loadinto([mpl_dir, mpl_file(m).name]);
   mplz_day.prof =    mplz_day.prof.*(ol_corr_ray.ol_corr * ones(size(mplz_day.time)));

   z_0=(mplz_day.hk.zenith<1);
   z_45 = (mplz_day.hk.zenith<50)&(mplz_day.hk.zenith>10);
   %Stitching these together.
   % Interpolate from one height grid to the other.
   cos45 = cos(mean(mplz_day.hk.zenith(z_45))*pi/180);
   %coarser grid native to zenith beam.

% figure(1); axx(1,1) = subplot(2,1,1);
%      figure(1); 
%      imagesc([1:sum(z_0)], mplz_day.range(mplz_day.r.lte_5), real(log10(mplz_day.prof(mplz_day.r.lte_5,z_0)))); 
%      colorbar; axis('xy'); caxis([1,3])
%      axx(1,2) = subplot(2,1,2);
%      imagesc([1:sum(z_45)], mplz_day.range(mplz_day.r.lte_10), real(log10(mplz_day.prof(mplz_day.r.lte_10,z_45)))); 
%      colorbar; axis('xy'); caxis([1,3])
%      linkaxes(axx(1,:), 'xy')
     
   prof_0a = mplz_day.prof(mplz_day.r.lte_5,z_0);
%    prof_0b = interp1(mplz_day.range(mplz_day.r.lte_10).*cos45, mplz_day.prof(mplz_day.r.lte_10,z_45), mplz_day.range(mplz_day.r.lte_5));
%    a_ii = find(z_0);
%    b_ii = find(z_45);
%    [ii, inds] = sort([a_ii, b_ii]);
%    tmp = [prof_0a, prof_0b];
%    prof_0 = tmp(:,inds);
%       figure(1); imagesc(serial2doy(mplz_day.time(z_0)), mplz_day.range(mplz_day.r.lte_5), real(log10(prof_0a))); colorbar; axis('xy'); caxis([1,3])
   figure(2); 
   imagesc(serial2doy(mplz_day.time(z_0)), mplz_day.range(mplz_day.r.lte_5), real(log10(prof_0a))); colorbar; axis('xy'); caxis([1,3])
   title(['MPL attenuated backscatter profile for ', datestr(mplz_day.time(1), 'yyyy_mm_dd')], 'interp', 'none');
   xlabel('day of year (Jan. 1 = 1)')
   ylabel('height (km AGL)');
   pause(.05);
   aax(2,1) = gca;
   ax(1) = gca;
   outname = [mpl_png, 'tnmpl.attn_bscat_vs_height.zenith_0.',datestr(mplz_day.time(1),'yyyy_mm_dd'), '.png'];
   saveas(gcf, outname);
   pause(0.05);

%    figure(3); 
%    imagesc(serial2doy(mplz_day.time(z_45)), mplz_day.range(mplz_day.r.lte_5), real(log10(prof_0b))); colorbar; axis('xy'); caxis([1,3])
%    pause(.05);
%    aax(2,2) = gca;
%    pause(.05);
%    figure(4); 
%    imagesc(serial2doy(mplz_day.time(z_0|z_45)), mplz_day.range(mplz_day.r.lte_5), real(log10(prof_0))); colorbar; axis('xy'); caxis([1,3])
%    pause(.05);
%    aax(2,3) = gca;
%    pause(.05);
%    linkaxes(aax(2,:),'xy');
   
   
   prof_45a = interp1(mplz_day.range(mplz_day.r.lte_10), mplz_day.prof(mplz_day.r.lte_10,z_0), mplz_day.range(mplz_day.r.lte_10).*cos45);
   prof_45b = mplz_day.prof(mplz_day.r.lte_10,z_45);
   a_ii = find(z_0);
   b_ii = find(z_45);
   [ii, inds] = sort([a_ii, b_ii]);
   tmp = [prof_45a, prof_45b];
   prof_45 = tmp(:,inds);
%    figure(5); imagesc(serial2doy(mplz_day.time(z_0)), mplz_day.range(mplz_day.r.lte_10).*cos45, real(log10(prof_45a))); colorbar; axis('xy'); caxis([1,3])
%       pause(.05);
%    ax(5,1) = gca;
%       pause(.05);
   figure(6); imagesc(serial2doy(mplz_day.time(z_45)), mplz_day.range(mplz_day.r.lte_10).*cos45, real(log10(prof_45b))); colorbar; axis('xy'); caxis([1,3])
      title({['MPL attenuated backscatter profile for ', datestr(mplz_day.time(1), 'yyyy_mm_dd')],...
         ['Vertical profile from cosine of 45-degree range profile']},'interp', 'none');
   xlabel('day of year (Jan. 1 = 1)')
   ylabel('height (km AGL)');
      pause(.05);
%    ax(5,2) = gca;
   ax(2) = gca;
   outname = [mpl_png, 'tnmpl.attn_bscat_vs_height.zenith_45.',datestr(mplz_day.time(1),'yyyy_mm_dd'), '.png'];

   saveas(gcf, outname);

      pause(.05);
   figure(7); imagesc(serial2doy(mplz_day.time(z_0|z_45)), mplz_day.range(mplz_day.r.lte_10).*cos45, real(log10(prof_45))); colorbar; axis('xy'); caxis([1,3])
         title({['MPL attenuated backscatter profile for ', datestr(mplz_day.time(1), 'yyyy_mm_dd')],...
         ['Vertical profile from composite of zenith and 45-degree profiles.']},'interp', 'none');
   xlabel('day of year (Jan. 1 = 1)')
   ylabel('height (km AGL)');
      pause(.05);
%    ax(5,3) = gca;
   ax(3) = gca;
%       outname = [mpl_png, 'tnmpl.attn_bscat_vs_height.zen_0_45.png'];
   outname = [mpl_png, 'tnmpl.attn_bscat_vs_height.zen_0_45.',datestr(mplz_day.time(1),'yyyy_mm_dd'), '.png'];      
   saveas(gcf, outname);

      pause(.05);
   linkaxes(ax,'xy');
%    pause
   out_0 = [mpl_txt, 'lidar_profiles.zenith.',datestr(mplz_day.time(1),'yyyy_mm_dd'), '.txt'];
   out_45 = [mpl_txt, 'lidar_profiles.45deg.',datestr(mplz_day.time(1),'yyyy_mm_dd'), '.txt'];
   txt_out_(mplz_day.time(z_0), mplz_day.range(mplz_day.r.lte_5),prof_0a, out_0);
   txt_out_(mplz_day.time(z_45), mplz_day.range(mplz_day.r.lte_10).*cos45, prof_45b, out_45);

   %
   %    figure; ax(1) = subplot(2,1,1);
   %    imagegap(serial2Hh(mplz_day.time(z_0)), mplz_day.range(mplz_day.r.lte_5), real(log10(mplz_day.prof(mplz_day.r.lte_5,z_0)))); colorbar
   % %    imagegap(serial2Hh(mplz_day.time(z_0)), mplz_day.range(mplz_day.r.lte_5), real(log10(mplz_day.prof(mplz_day.r.lte_5,z_0).*(ol_corr_ray.ol_corr(mplz_day.r.lte_5) * ones([1,sum(z_0)]))))); colorbar
   %    ax(2) = subplot(2,1,2);
   %    imagegap(serial2Hh(mplz_day.time(z_45)), mplz_day.range(mplz_day.r.lte_10).*cos(mean(mplz_day.hk.zenith(z_45))*pi/180), real(log10(mplz_day.prof(mplz_day.r.lte_10,z_45)))); colorbar
   % %    imagegap(serial2Hh(mplz_day.time(z_45)), mplz_day.range(mplz_day.r.lte_10).*cos(mean(mplz_day.hk.zenith(z_45))*pi/180), real(log10(mplz_day.prof(mplz_day.r.lte_10,z_45).*(ol_corr_ray.ol_corr(mplz_day.r.lte_10) * ones([1,sum(z_45)]))))); colorbar
   disp('');
end

function txt_out_(mpl_time, height, prof, fname);
% This function simply outputs the time-varying fields (including an
% additional profile from an MPL structure) a text ascii file.
V = datevec(mpl_time);
yyyy = V(:,1);
mm = V(:,2);
dd = V(:,3);
HH = V(:,4);
MM = V(:,5);
SS = V(:,6);
doy = serial2doy(mpl_time)';
HHhh = (doy - floor(doy)) *24;
% txt_out needs to be composed of data oriented as column vectors.

header_row = ['yyyy, mm, dd, HH, MM, SS, day_of_year, HHhh, '];
header_row = [header_row, sprintf('%1.0f_m, ' ,height*1000)];
header_row([end-1 end]) = [];

txt_out = [yyyy, mm, dd, HH, MM, SS, doy, HHhh, ...
    prof'];
%

format_str = ['%d, %d, %d, %d, %d, %0.f, %3.6f, %2.4f, '];
format_str = [format_str, repmat('%1.4e, ',[1,length(height)])];
format_str([end-1 end]) = [];
format_str = [format_str, ' \n'];

fid = fopen(fname,'wt');
fprintf(fid,'%s \n',header_row );
fprintf(fid,format_str,txt_out');
fclose(fid);




% for all daily files
% load file
% apply overlap
% select zenith profiles
% image zenith profiles
% Output text file with zenith lidar profiles.