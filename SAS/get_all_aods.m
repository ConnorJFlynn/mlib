function all_aods = get_all_aods(in)
%
% This routine should accept
if ~exist('in','var')
   in = getfullname('*sashe*','sashe','Select SASHE AOD file.');
end
if isstruct(in)&&isfield(in,'fname')
   in = in.fname;
end
if ischar(in)
   if exist(in,'file')
      [pname, fname, ext] = fileparts(in);
      [~,tok] = strtok(fliplr(fname),'.');
      in = fliplr(strtok(tok,'.'));
      
   end
   try
      in=datenum(in,'yyyymmdd');
   catch
      in = datenum(in,'yyyy-mm-dd');
   end
end
if in>datenum(2011,1,1) && in < now
   in_date = datestr(in,'yyyymmdd');
else
   error('Couldn''t identify the date')
end

masks = ['sgpmfrsraod1mich*.c1.',in_date,'.*'];
[mfr_list,mfr_pname] = dir_(masks,'mfrsraod');
if isempty(mfr_list)
   [mfr_list, mfr_pname] = dir_list(masks,'mfrsraod');
end

masks = ['sgpsashevisaod*.c1.',in_date,'.*'];
[sashev_list,sashev_pname] = dir_(masks,'sashevisaod');
if isempty(sashev_list)
   [sashev_list, sashev_pname] = dir_list(masks,'sashevisaod');
end

masks = ['sgpsasheniraod*.c1.',in_date,'.*'];
[sashen_list,sashen_pname] = dir_(masks,'sasheniraod');
if isempty(sashen_list)
   [sashen_list, sashen_pname] = dir_list(masks,'sasheniraod');
end


mfr = anc_bundle_files(dirlist_to_filelist(mfr_list(1),mfr_pname));
sashevis = anc_bundle_files(dirlist_to_filelist(sashev_list, sashev_pname));
sashenir = anc_bundle_files(dirlist_to_filelist(sashen_list, sashen_pname));
[vinn, ninv] = nearest(sashevis.time, sashenir.time);
sashevis = anc_sift(sashevis, vinn); sashenir = anc_sift(sashenir, ninv);
% save(['D:\case_studies\Eli\data\anet\100101_151231_Cart_Site.lev20.mat'],'-struct','anet');
% anet = read_cimel_aod;
anet = load(['D:\case_studies\Eli\data\anet\100101_151231_Cart_Site.lev20.mat']);
% Then use anc_bundle to get mfrsr file for this date followed by
% sashevis and sashenir and aeronet.
% Use anc_sift to get just the sashe wavelengths we want
% Plot

vi = interp1(sashevis.vdata.wavelength, [1:length(sashevis.vdata.wavelength)],[500,615,676,870],'nearest');
ni = interp1(sashenir.vdata.wavelength, [1:length(sashenir.vdata.wavelength)],[1020,1033,1555,1628],'nearest');
good_mfr = any([anc_qc_impacts(mfr.vdata.qc_aerosol_optical_depth_filter2, mfr.vatts.qc_aerosol_optical_depth_filter2)<2;
   anc_qc_impacts(mfr.vdata.qc_aerosol_optical_depth_filter3, mfr.vatts.qc_aerosol_optical_depth_filter3)<2;
   anc_qc_impacts(mfr.vdata.qc_aerosol_optical_depth_filter4, mfr.vatts.qc_aerosol_optical_depth_filter4)<2;
   anc_qc_impacts(mfr.vdata.qc_aerosol_optical_depth_filter5, mfr.vatts.qc_aerosol_optical_depth_filter5)<2]);
good_sas = any(sashevis.vdata.aerosol_optical_depth(vi,:) > 0) | any(sashenir.vdata.aerosol_optical_depth(ni,:) > 0) & ...
   any(anc_qc_impacts(sashevis.vdata.qc_aerosol_optical_depth(vi,:),sashevis.vatts.qc_aerosol_optical_depth)<2);

midday = serial2hs(sashenir.time)>16 & serial2hs(sashenir.time)<21;
ot_offset = min(min([sashenir.vdata.aerosol_optical_depth(ni,midday).*(ones([length(ni),1])*(sashenir.vdata.airmass(midday)))]'));
od_offset = -ot_offset./sashenir.vdata.airmass;
% od_offset = 

[ainb, bina] = nearest(anet.time', sashevis.time(good_sas));
% ainb = unique([ainb, ainb2]);

 figure(9); dots0 = plot(serial2hs(sashevis.time(good_sas)), od_offset(good_sas)+sashevis.vdata.aerosol_optical_depth(vi(1),good_sas),'ko',...
    serial2hs(mfr.time(good_mfr)), mfr.vdata.aerosol_optical_depth_filter2(good_mfr),'k.',...
    serial2hs(anet.time(ainb)), anet.AOT_500(ainb),'k+', ...
    serial2hs(sashenir.time(good_sas)), od_offset(good_sas)+sashenir.vdata.aerosol_optical_depth(ni(1),good_sas),'kx');
    legend('sashevis','mfrsr','aeronet','sashenir'); title(['AODs for ',in_date]);
 hold('on');
%  dotsn1 = plot(serial2hs(sashevis.time), sashevis.vdata.aerosol_optical_depth(vi,:),'.'); set(dotsn1,'color',[.3,.3,.3])
 dots1 = plot(serial2hs(sashevis.time(good_sas)), ones([length(vi),1])*od_offset(good_sas)+sashevis.vdata.aerosol_optical_depth(vi,good_sas),'o');
 
 dots2 = plot(serial2hs(mfr.time(good_mfr)), [mfr.vdata.aerosol_optical_depth_filter2(good_mfr);mfr.vdata.aerosol_optical_depth_filter3(good_mfr);...
    mfr.vdata.aerosol_optical_depth_filter4(good_mfr);mfr.vdata.aerosol_optical_depth_filter5(good_mfr)],'.');
% recolor([dots1;dots2],[sashevis.vdata.wavelength(vi);500;615;676;870]); colorbar
dots4 = plot(serial2hs(anet.time(ainb)), [anet.AOT_500(ainb), anet.AOT_675(ainb), anet.AOT_870(ainb),anet.AOT_1020(ainb)],'+');
recolor([dots1;dots2;dots4],[sashevis.vdata.wavelength(vi);500;615;676;870;500;675;870;1020]); colorbar
dots3 = plot(serial2hs(sashenir.time(good_sas)), ones([length(ni),1])*od_offset(good_sas)+sashenir.vdata.aerosol_optical_depth(ni,good_sas),'x');

   
hold('off');
done = false;
while ~done
   figure(9)
OK = menu('zoom in to good time for angstrom plot?','OK','SKIP');
   
if OK==1
   xl = xlim;
   xl_1 = serial2hs(sashevis.time)>=xl(1)&serial2hs(sashevis.time)<=xl(2);
   xl_2 = serial2hs(mfr.time)>=xl(1)&serial2hs(mfr.time)<=xl(2);
   xl_3 = serial2hs(anet.time(ainb)')>=xl(1)&serial2hs(anet.time(ainb)')<=xl(2);
 figure(5);
   if sum(xl_3)==0
   loglog((sashevis.vdata.wavelength(vi)), (mean(sashevis.vdata.aerosol_optical_depth(vi,good_sas&xl_1),2)),'-o',...
      ([500,615,676,870]), (mean([mfr.vdata.aerosol_optical_depth_filter2(good_mfr&xl_2);...
      mfr.vdata.aerosol_optical_depth_filter3(good_mfr&xl_2);mfr.vdata.aerosol_optical_depth_filter4(good_mfr&xl_2);...
      mfr.vdata.aerosol_optical_depth_filter5(good_mfr&xl_2)],2)),'-r.',...
      (sashenir.vdata.wavelength(ni)), (mean(sashenir.vdata.aerosol_optical_depth(ni,good_sas&xl_1),2)),'-x')
   legend('sasvis','mfrsr','sasnir');
   else
      loglog(sashevis.vdata.wavelength(vi), mean(sashevis.vdata.aerosol_optical_depth(vi,good_sas&xl_1),2),'-o',...
      [500,615,676,870], mean([mfr.vdata.aerosol_optical_depth_filter2(good_mfr&xl_2);...
      mfr.vdata.aerosol_optical_depth_filter3(good_mfr&xl_2);mfr.vdata.aerosol_optical_depth_filter4(good_mfr&xl_2);...
      mfr.vdata.aerosol_optical_depth_filter5(good_mfr&xl_2)],2),'-r.',...
      sashenir.vdata.wavelength(ni), mean(sashenir.vdata.aerosol_optical_depth(ni,good_sas&xl_1),2),'-x',...
      [500,675,870,1020], [anet.AOT_500(ainb(xl_3)), anet.AOT_675(ainb(xl_3)), anet.AOT_870(ainb(xl_3)),anet.AOT_1020(ainb(xl_3))],'k-');
   legend('sasvis','mfrsr','sasnir', 'anet');
   end
   xlabel('wavelength [nm]');ylabel('aod');
   title(['Angstrom plot for ',datestr(mean(sashevis.time(xl_1)),'yyyy-mm-dd HH:MM UTC')]);
   KO = menu('Adjust and save?','skip','save');
   if KO ==2
   saveas(gcf,[mfr_pname, filesep,'../sgpsasheaod_ang_compare.',datestr(mean(sashevis.time(xl_1)),'yyyymmdd.HHMM_UTC'),'.fig']);
   saveas(gcf,[mfr_pname, filesep,'../sgpsasheaod_ang_compare.',datestr(mean(sashevis.time(xl_1)),'yyyymmdd.HHMM_UTC'),'.png']);
   end
else
   done = true;
end
end






return