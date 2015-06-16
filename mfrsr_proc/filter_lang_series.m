function fiq = filter_lang_series(common_lang, good, W);
% fiq = filter_lang_series(common_lang, good, W);

% good = true(size(common_lang.time));
% for f = filt
%    good = good&(common_lang.(['Vo_filter',num2str(f)])>0);
% end
if ~exist('common_lang','var')
   common_lang = loadinto(getfullname('lang_Ios_raw*.mat','mfrIo','Select lang_Ios_raw mat file:'));
end
if ~exist('good','var')
   good = common_lang.status==true;
end
if ~exist('W','var');
   W = 30;
end
in_dir = common_lang.settings.indir;
if ~exist(in_dir,'dir')
   error('Specified input directory does not exist!')
end
Io_outdir = [in_dir,'lang_Io_mats',filesep];
if ~exist(Io_outdir,'dir')
   mkdir(Io_outdir);
end
%
   
fiq.time = common_lang.time(good);
day1 = datevec(fiq.time(1));
day0 = datenum([day1(1),1, 0,0,0,0]);

for ff = 1:5
mgood = good;
ggood = good;
figure(20+ff)
subplot(2,1,1);
%%
iq_filt = IQF_lang(common_lang.time(good)-day0, common_lang.(['Vo_filter',num2str(ff)])(good),W);
title(['Raw and filtered Vos for filter',num2str(ff)]);
ax(1) = gca;
mgood(good) = maadf(common_lang.(['Vo_filter',num2str(ff)])(good), iq_filt,3);
ggood(good) = gmaadf(common_lang.(['Vo_filter',num2str(ff)])(good), iq_filt,3);
%%
subplot(2,1,2);
common_lang.(['Vo_filter',num2str(ff)])(~mgood|~ggood) = NaN;
fiq.(['filter',num2str(ff)]) = IQF_lang(common_lang.time(good)-day0, common_lang.(['Vo_filter',num2str(ff)])(good),W);
xlabel('day of year');
title(['Vos after outlier rejection and resmooth for filter',num2str(ff)]);
ax(2) = gca; v = axis;
linkaxes(ax,'xy'); axis(v);
end

%    day_time = mean(day.time);
%    this.time(ff) = day_time;
%    P = gaussian(fiq.time,day_time,30);
%    for ii = 1:5;
%       Io_new.(['filter',num2str(ii)]) = trapz(fiq.time,fiq.(['filter',num2str(ii)]).*P)./trapz(fiq.time,P);
%    end
%    day = apply_Io_corr(Io_new, day);
% miq.filter1 = IQF_lang(serial2doy(fiq.time), common_lang.Vo_filter1(good),W);
% fiq.filter2 = IQF_lang(serial2doy(fiq.time), common_lang.Vo_filter2(good),W);
% fiq.filter2 = maadf(common_lang.Vo_filter2(good), fiq.filter2,2);
% fiq.filter3 = IQF_lang(serial2doy(fiq.time), common_lang.Vo_filter3(good),W);
% fiq.filter3 = maadf(common_lang.Vo_filter3(good), fiq.filter3,2);
% fiq.filter4 = IQF_lang(serial2doy(fiq.time), common_lang.Vo_filter4(good),W);
% fiq.filter4 = maadf(common_lang.Vo_filter4(good), fiq.filter4,2);
% fiq.filter5 = IQF_lang(serial2doy(fiq.time), common_lang.Vo_filter5(good),W);
% fiq.filter5 = maadf(common_lang.Vo_filter5(good), fiq.filter5,2);
common_lang.fiq = fiq;
%%
day1 = datevec(fiq.time(1));
day0 = datenum([day1(1),1, 0,0,0,0]);
figure; 
xx(1) = subplot(2,1,1);
plot(fiq.time-day0,[fiq.filter1; fiq.filter2; fiq.filter3; fiq.filter4; fiq.filter5], '.-');
title('Filter Vo values')
lg = legend('filter1','filter2','filter3','filter4','filter5');
set(lg,'location','EastOutside')
grid;

xx(2) = subplot(2,1,2); 
plot(fiq.time-day0,[fiq.filter1./mean(fiq.filter1); ...
   fiq.filter2./mean(fiq.filter2); fiq.filter3./mean(fiq.filter3); ...
   fiq.filter4./mean(fiq.filter4); fiq.filter5./mean(fiq.filter5)], '.-');
title('Normalized to mean');
xlabel(['days since ',datestr(day0,'mmm dd, yyyy')]);
lg=legend('filter1','filter2','filter3','filter4','filter5');
set(lg,'location','EastOutside')
grid;
linkaxes(xx,'x');

v = 1;   
while exist([Io_outdir,'smoothed_Ios.v',num2str(v),'.png'],'file')
   v = v+1;
end
Ios_out = [Io_outdir,'smoothed_Ios.v',num2str(v)];
display(['Saving ',Ios_out,'.png']);
saveas(gcf,[Ios_out,'.png']);
saveas(gcf,[Ios_out,'.fig']);
% txt_lang_out(fiq,[Ios_out,'.dat']); 
return


% function txt_lang_out(fiq, txt_fname);
% % Evgueni, write this part to provide Annette the Io format she needs.
% % I'll provide an ascii file as example.
% jt = serial2joe(fiq.time);
% yyyymmdd = datestr(fiq.time, 'yyyy_mm_dd');
% fid = fopen(txt_fname, 'w');
% for t = 1:length(jt)
%    %%
%    bloc = [floor(jt(t));fiq.filter1(t);fiq.filter2(t);fiq.filter3(t);fiq.filter4(t);fiq.filter5(t)];
% %    sprintf('%d %3.3f %3.3f %3.3f %3.3f %3.3f ', bloc)
% %    sprintf('%s \n', yyyymmdd(t,:))
%    fprintf(fid,'%d %3.3f %3.3f %3.3f %3.3f %3.3f ', bloc);
%    fprintf(fid,'%s \n', yyyymmdd(t,:));
%    %%
% end
% fclose(fid);   
% 
% return