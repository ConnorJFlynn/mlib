function mpl = mpl004_alive(mpl)

if ~exist('mpl','var')
    mpl = read_mpl;
elseif ~isstruct(mpl)&&exist(mpl,'file')
   mpl = read_mpl(mpl);
end


if isfield(mpl, 'pname')
    pname = mpl.pname;
end

mpl = apply_dtc_to_mpl(mpl, 'dtc_apd8126');
mpl = apply_ap_to_mpl(mpl, ap_mpl004_20050805(mpl.range));

%First, adjust to match MPL 102 profile
load mpl4_to_102
mpl4_to_102.factor = mpl4_to_102.factor ./ min(mpl4_to_102.factor);
less = min(length(mpl.r.lte_30), length(mpl4_to_102.factor));
mpl.prof(mpl.r.lte_30(1:less),:) = mpl.prof(mpl.r.lte_30(1:less),:) .* (mpl4_to_102.factor(1:less)*ones(size(mpl.time)));
%Then, apply overlap

load mpl4_ol_30
ol_corr = interp1(mpl4_ol_30.range, mpl4_ol_30.ol_corr, mpl.range(mpl.r.lte_30));

% less = min(length(mpl.r.lte_30), length(mpl4_ol_30.ol_corr));

mpl.prof(mpl.r.lte_30,:) = mpl.prof(mpl.r.lte_30,:) .* (ol_corr*ones(size(mpl.time)));
load('mpl_alive_sub_olcorr.mat')
disp('Applying new correction to lower range.')
mpl.prof(mpl.r.lte_10,:) = mpl.prof(mpl.r.lte_10,:).* (sub_olcorr.olcorr*ones(size(mpl.time)));

% hh = serial2Hh(mpl.time);
% interval = intervals(hh);
% grid = [0:interval(1):24];
% [prof, hh] = fill_img(mpl.prof,hh, grid);

% figure(41); imagesc(serial2Hh(mpl.time), mpl.range(mpl.r.lte_20), real(log10(prof(mpl.r.lte_20,:)))); 
% axis('xy'); v = axis; axis([v(1), v(2), 0, 15]); caxis([-.85, 1.15]);colorbar
% title(['log_1_0(atten\_bscat) MPL04: ',datestr(mpl.time(1), 'yyyy-mm-dd')]);
% ylabel('range AGL (km)');
% xlabel('time (UTC)')
% % print(gcf, [mpl.statics.pname, '..\plots\mpl004_log_prof.',datestr(mpl.time(1),'yyyymmdd'),'.png'],'-dpng');
% 
% figure(42); imagesc(serial2Hh(mpl.time), mpl.range(mpl.r.lte_20), ((prof(mpl.r.lte_20,:)))); axis('xy');
% axis([v(1), v(2), 0, 15]);caxis([0, 5]);colorbar;
% title(['MPL 004 Normalized Attenuated Backscatter ', datestr(mpl.time(1),1)]);
% xlabel('time (HH UTC)');
% ylabel('range (km AGL)');
% print(gcf, [mpl.statics.pname, '..\plots\mpl004_atten_prof.',datestr(mpl.time(1),'yyyymmdd'),'.png'],'-dpng');

%  disp('Skipping bin normalization.');
% disp('Applying de-trended bin normalization.');
%  mean_bin3 = mean(mpl.prof(mpl.r.lte_5(3),:));
%  norm3 =  1 ./ mpl.prof(mpl.r.lte_5(3),:);
%  norm_baseline = smooth(serial2Hh(mpl.time), norm3, 200, 'rloess')';
%  %mpl.hk.norm3 = mean_bin3*norm3;
%  old_norm3 = mean_bin3*norm3;
%  mpl.hk.norm3 = norm3./norm_baseline;
%  %figure; plot(serial2Hh(mpl.time), old_norm3, 'r', serial2Hh(mpl.time), mpl.hk.norm3 , 'b')
% 
%  mpl.prof.*(ones([length(mpl.range),1])*mpl.hk.norm3);
%  figure; imagesc(serial2Hh(mpl.time), mpl.range(mpl.r.lte_20), ((mpl.prof(mpl.r.lte_20,:).*(ones([length(mpl.r.lte_20),1])*mpl.hk.norm3)))); axis('xy');
% v = axis; axis([v(1), v(2), 0, 15, 0, 2.5, 0, 2.5]);caxis([0,10]);
% title(['MPL 004 bin3 Normalized Attenuated Backscatter ', datestr(mpl.time(1),1)]);
% xlabel('time (HH UTC)');
% ylabel('range (km AGL)');

% 
% mpl.nobg = mpl.rawcts - ones(size(mpl.range))*mpl.hk.bg;
% figure; imagesc(serial2Hh(mpl.time), mpl.range(mpl.r.lte_10), real(log10(mpl.nobg(mpl.r.lte_10,:)))); axis('xy');
% colormap('jet');caxis([-3.1000, 0.9000]);colorbar
% title(['MPL 004 log_1_0(raw - bg) ', datestr(mpl.time(1),1)]);
% xlabel('time (HH UTC)');
% ylabel('range (km AGL)');
% % print(gcf, [mpl.statics.pname, '..\plots\mpl004_log_raw.',datestr(mpl.time(1),'yyyymmdd'),'.png'],'-dpng');


function status = quicklooks(mpl,  outdir , options)
%status = quicklooks(mplps, output, outdir, fname)
%if 'options' is provided it must be a string exactly as matlab print function expects. 
if nargin==1
   outdir = [];
   options = []; 
   out_ext = [];
else
   if nargin==2
      options = ['-dmeta'];
      out_ext = 'emf';
   else
      if findstr(options, 'png')
         out_ext = 'png';
      elseif findstr(options, 'meta')
         out_ext = 'xmf';
      elseif findstr(options, 'jpeg')
         out_ext = 'jpeg';
      end;
   end
   %construct output file name with outdir, time, and output format
   ds_name_stem = strtok(mpl.statics.datastream, '.');
   begin_date = floor(mpl.time(1));
   begin_datestr = [datestr(begin_date,10), datestr(begin_date,5), datestr(begin_date,7)];
   doy = sprintf('%.3d',floor(serial2doy0(mpl.time(1))));
   ds_name = [outdir, ds_name_stem, '.', begin_datestr, '.doy_',doy, '.'];
   %', DOY
   %',datestr(mpl.time(1),10),'\_',num2str(floor(serial2doy0(mpl.time(1))))])
end;

 figure(101); colormap('jet')
 imagesc(serial2Hh(mpl.time), mpl.range(mpl.r.lte_20),mpl.prof(mpl.r.lte_20,:));
 axis('xy'); axis([0,24,0,16,0,6,0,6]);caxis= [0,50];colorbar; zoom
 title(['normalized MPL backscatter: ' num2str(datestr(mpl.time(1),1)), ', DOY ',datestr(mpl.time(1),10),'\_',num2str(floor(serial2doy0(mpl.time(1))))])
 xlabel('time (HH.hh)');
 ylabel('range (km)');
 
 file_label = 'atten_bscat.';
 if ~isempty(out_ext)
    fn = [ds_name, file_label, out_ext];
    print( 101, [options], fn );
    disp(['Writing ', fn]);
%      fn = [ds_name, file_label, 'fig'];
%      saveas(101,fn)
    %close(101);
 end
   
status = 1;
return
