function mpl = mpl102_alive(mpl)

if nargin==0
    [fname, pname] = uigetfile('C:\case_studies\Alive\data\flynn-mpl-102\Nov2006\day\*.day');
    mpl = read_mpl([pname, fname]);
end
if isfield(mpl, 'pname')
    pname = mpl.pname;
end
mpl.range = mpl.range + .24;
r = mpl.r;
r.lte_5 = find((mpl.range>.045)&(mpl.range<=5));
r.lte_10 = find((mpl.range>.045)&(mpl.range<=10));
r.lte_15 = find((mpl.range>.045)&(mpl.range<=15));
r.lte_20 = find((mpl.range>.045)&(mpl.range<=20));
r.lte_25 = find((mpl.range>.045)&(mpl.range<=25));
r.lte_30 = find((mpl.range>.045)&(mpl.range<=30));
mpl.r = r;
clear r
mpl = apply_dtc_to_mpl(mpl, 'dtc_apd10101');
mpl = apply_ap_to_mpl(mpl, ap_mpl102_20050911(mpl.range));

load mpl4_ol_30
ol_corr = interp1(mpl4_ol_30.range, mpl4_ol_30.ol_corr, mpl.range(mpl.r.lte_30),'linear','extrap');
%less = min(length(mpl.r.lte_30), length(mpl102_ol_d.ol_corr));

mpl.prof(mpl.r.lte_30,:) = mpl.prof(mpl.r.lte_30,:) .* (ol_corr*ones(size(mpl.time)));
status = quicklooks(mpl, pname);
% hh = serial2Hh(mpl.time);
% interval = intervals(hh);
% grid = [0:interval(1):24];
% [prof, hh] = fill_img(mpl.prof,hh, grid);
% 
% figure(101); imagesc(hh, mpl.range(mpl.r.lte_20), real(log10(prof(mpl.r.lte_20,:)))); 
% axis('xy'); v = axis; axis([v(1), v(2), 0, 15]);caxis([-.5,2]);colorbar
% title(['log_1_0(atten\_bscat) MPL102: ',datestr(mpl.time(1), 'yyyy-mm-dd')]);
% ylabel('range AGL (km)');
% xlabel('time (UTC)')
% 
% figure(102); imagesc(hh, mpl.range(mpl.r.lte_20), ((prof(mpl.r.lte_20,:)))); 
% axis('xy'); axis([v(1), v(2), 0, 15, 0, 25, 0, 25]);colorbar; cv = caxis;
% title(['MPL Normalized Attenuated Backscatter ', datestr(mpl.time(1),1)]);
% xlabel('time (HH UTC)');
% ylabel('range (km AGL)');
% print(gcf, [pname, '..\plots\mpl102_atten_prof.',datestr(mpl.time(1),'yyyymmdd'),'.png'],'-dpng');

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
   doy = sprintf('%.3d',floor(serial2doy(mpl.time(1))));
   ds_name = [outdir, ds_name_stem, '.', begin_datestr, '.doy_',doy, '.'];
   %', DOY
   %',datestr(mpl.time(1),10),'\_',num2str(floor(serial2doy(mpl.time(1))))])
end;
hh = serial2Hh(mpl.time);
interval = intervals(hh);
grid = [0:interval(1):24];
[prof, hh] = fill_img(mpl.prof,hh, grid);

figure(101); imagesc(hh, mpl.range(mpl.r.lte_20), real(log10(prof(mpl.r.lte_20,:)))); 
axis('xy'); v = axis; axis([v(1), v(2), 0, 15]);caxis([-.5,2]);colorbar
title(['log_1_0(atten\_bscat) MPL102: ',datestr(mpl.time(1), 'yyyy-mm-dd')]);
ylabel('range AGL (km)');
xlabel('time (UTC)')

 file_label = 'log10_atten_bscat.';
 if ~isempty(out_ext)
    fn = [ds_name, file_label, out_ext];
    print( 101, [options], fn );
    disp(['Writing ', fn]);
%      fn = [ds_name, file_label, 'fig'];
%      saveas(101,fn)
    %close(101);
 end
 

figure(102); imagesc(hh, mpl.range(mpl.r.lte_20), ((prof(mpl.r.lte_20,:)))); 
axis('xy'); axis([v(1), v(2), 0, 15, 0, 25, 0, 25]);colorbar; cv = caxis;
title(['MPL Normalized Attenuated Backscatter ', datestr(mpl.time(1),1)]);
xlabel('time (HH UTC)');
ylabel('range (km AGL)');


 file_label = 'atten_bscat.';
 if ~isempty(out_ext)
    fn = [ds_name, file_label, out_ext];
    print( 102, [options], fn );
    disp(['Writing ', fn]);
%      fn = [ds_name, file_label, 'fig'];
%      saveas(101,fn)
    %close(101);
 end

%  figure(101); colormap('jet')
%  imagesc(serial2Hh(mpl.time), mpl.range(mpl.r.lte_20),mpl.prof(mpl.r.lte_20,:));
%  axis('xy'); axis([0,24,0,16,0,6,0,6]);colorbar; zoom
%  title(['normalized MPL backscatter: ' num2str(datestr(mpl.time(1),1)), ', DOY ',datestr(mpl.time(1),10),'\_',num2str(floor(serial2doy(mpl.time(1))))])
%  xlabel('time (HH.hh)');
%  ylabel('range (km)');
   
status = 1;
return
