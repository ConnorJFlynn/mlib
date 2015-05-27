function mpl = mpl106_sgp(mpl)
% I computed dark counts and afterpulse from files provided from the MPL 106
% These are saved as *.dk and *.ap files.
% I also determined the overlap and saved it as mpl_106_ol_corr.dat
if nargin==0
    mpl = read_mpl;
end


mpl = apply_dtc_to_mpl(mpl, 'dtc_apd12862');
% mpl = apply_ap_to_mpl(mpl, ap_mpl004_20050805(mpl.range));
% mpl = apply_ol_to_mpl(mpl,ol_horiz_mpl004_20050805(mpl.range) );

% figure; imagesc(serial2Hh(mpl.time), mpl.range(mpl.r.lte_20), real(log10(mpl.prof(mpl.r.lte_20,:)))); axis('xy');
% v = axis; axis([v(1), v(2), 0, 15, -2.5, 3, -2.5, 3]);
% title(['MPL log10(Normalized Attenuated Backscatter) ', datestr(mpl.time(1),1)]);
% xlabel('time (HH UTC)');
% ylabel('range (km AGL)');

figure; imagesc(serial2Hh(mpl.time), mpl.range(mpl.r.lte_20), ((mpl.prof(mpl.r.lte_20,:)))); axis('xy');
v = axis; axis([v(1), v(2), 0, 15, 0, 2.5, 0, 2.5]);caxis([0,3.5]);
title(['MPL Normalized Attenuated Backscatter ', datestr(mpl.time(1),1)]);
xlabel('time (HH UTC)');
ylabel('range (km AGL)');

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
