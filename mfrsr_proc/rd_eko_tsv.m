function eko = rd_eko_tsv(in_file)
if ~isavar('in_file')||~isafile(in_file)
   in_file = getfullname('data_*.tsv','eko_tsv');
end

eko_dat = importdata(in_file);
eko.time = datenum(eko_dat(:,1),eko_dat(:,2),eko_dat(:,3),eko_dat(:,5),eko_dat(:,6),eko_dat(:,1)*0);
eko.pix_1 = eko_dat(:,7); eko.pix_2 = eko_dat(:,8); eko.pix_4 = eko_dat(:,9); eko.pix_5 = eko_dat(:,10);
eko.asza = eko_dat(:,11);eko.saz = eko_dat(:,12);eko.asel = eko_dat(:,13);
eko.filt_1 = eko_dat(:,14);eko.filt_2 = eko_dat(:,15);eko.filt_4 = eko_dat(:,16);eko.filt_5 = eko_dat(:,17);

eko.filt_1(eko.filt_1<=0) = NaN; eko.filt_2(eko.filt_2<=0) = NaN; 
eko.filt_4(eko.filt_4<=0) = NaN; eko.filt_5(eko.filt_5<=0) = NaN;

eko.pix_1(eko.pix_1<=0) = NaN; eko.pix_2(eko.pix_2<=0) = NaN;
eko.pix_4(eko.pix_4<=0) = NaN; eko.pix_5(eko.pix_5<=0) = NaN;


eko.AM = eko.saz<0 & (1./cosd(eko.asza))<9; eko.PM = eko.saz>0& (1./cosd(eko.asza))<9;

return