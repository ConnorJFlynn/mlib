function spec = SAS_cosine_3(infile)
% spec = SAS_cosine_3(indir)
% This version reads files containing multiple spectra, darks and lights at
% varying angles with 0 between each angle.
% 
spec = SAS_read_ava(getfullname('*.csv','ava','Select cosine correction data'));
%%
wl_r = spec.nm>600&spec.nm<700;
wl_415 = spec.nm>410&spec.nm<420;
wl_500 = spec.nm>495&spec.nm<505;
wl_615 = spec.nm>610&spec.nm<620;
wl_870 = spec.nm>865&spec.nm<875;

wl_dk = spec.nm>=280&spec.nm<=380;
dark_ii = find(spec.Shuttered_0==0);
first_dark = (spec.spec(dark_ii(1),:));
mean_dark = mean(spec.spec(dark_ii,:),1);
norm_dark = first_dark./mean(first_dark(wl_dk));
norm_dark = mean_dark./mean(mean_dark(wl_dk));
dark_wt = mean(spec.spec(:,wl_dk),2);
darks = dark_wt * norm_dark;
no_darks = spec.spec -darks;
base_ = mean(no_darks(:,wl_r),2);
base_415 = mean(no_darks(:,wl_415),2);
base_500 = mean(no_darks(:,wl_500),2);
base_615 = mean(no_darks(:,wl_615),2);
base_870 = mean(no_darks(:,wl_870),2);

base_0 = base_;
base_415_ = base_415;
base_500_ = base_500;
base_615_ = base_615;
base_870_ = base_870;
%%
base_0(spec.Angle~=0|spec.Shuttered_0==0) = interp1(find(spec.Angle==0&spec.Shuttered_0~=0),...
   base_(spec.Angle==0&spec.Shuttered_0~=0),...
   find(spec.Angle~=0|spec.Shuttered_0==0), 'linear','extrap');
base_415_(spec.Angle~=0|spec.Shuttered_0==0) = interp1(find(spec.Angle==0&spec.Shuttered_0~=0),...
   base_415(spec.Angle==0&spec.Shuttered_0~=0),...
   find(spec.Angle~=0|spec.Shuttered_0==0), 'linear','extrap')';
base_500_(spec.Angle~=0|spec.Shuttered_0==0) = interp1(find(spec.Angle==0&spec.Shuttered_0~=0),...
   base_500(spec.Angle==0&spec.Shuttered_0~=0),...
   find(spec.Angle~=0|spec.Shuttered_0==0), 'linear','extrap');
base_615_(spec.Angle~=0|spec.Shuttered_0==0) = interp1(find(spec.Angle==0&spec.Shuttered_0~=0),...
   base_615(spec.Angle==0&spec.Shuttered_0~=0),...
   find(spec.Angle~=0|spec.Shuttered_0==0), 'linear','extrap');
base_870_(spec.Angle~=0|spec.Shuttered_0==0) = interp1(find(spec.Angle==0&spec.Shuttered_0~=0),...
   base_870(spec.Angle==0&spec.Shuttered_0~=0),...
   find(spec.Angle~=0|spec.Shuttered_0==0), 'linear','extrap');

% figure; plot([1:length(base_)],base_,'-',[1:length(base_0)],base_0,'k-');
% title('Baseline mean from 600-700, dark subtracted')

%%
% figure; plot([1:length(base_)],spec.Angle,'o')
%%
first = false(size(spec.time));
second = first;
mid = floor(length(spec.Angle)./2);
first(1:mid) = true;
second(mid:end) = true;
% first(1:81) = true;
% second(83:end) = true;
angs = spec.Angle~=0&spec.Shuttered_0~=0&abs(spec.Angle)<88;
angs_pos = spec.Angle~=0&spec.Shuttered_0~=0&(spec.Angle>=0)&(spec.Angle<=85);
angs_neg = spec.Angle~=0&spec.Shuttered_0~=0&(spec.Angle<=0)&(spec.Angle>=-85);
cos_corr = base_./(cos(pi.*spec.Angle./180).*base_0);
cos_corr_415 = base_415./(cos(pi.*spec.Angle./180).*base_415_);
cos_corr_500 = base_500./(cos(pi.*spec.Angle./180).*base_500_);
cos_corr_615 = base_615./(cos(pi.*spec.Angle./180).*base_615_);
cos_corr_870 = base_870./(cos(pi.*spec.Angle./180).*base_870_);
%%
figure; 
subplot(2,1,1);
plot(spec.Angle(first&angs_neg), base_(first&angs_neg)./(cos(pi.*spec.Angle(first&angs_neg)./180).*base_0(first&angs_neg)), '-',...
   spec.Angle(first&angs_pos), base_(first&angs_pos)./(cos(pi.*spec.Angle(first&angs_pos)./180).*base_0(first&angs_pos)), '-',...
   spec.Angle(second&angs_pos), base_(second&angs_pos)./(cos(pi.*spec.Angle(second&angs_pos)./180).*base_0(second&angs_pos)), '-',...
   spec.Angle(second&angs_neg), base_(second&angs_neg)./(cos(pi.*spec.Angle(second&angs_neg)./180).*base_0(second&angs_neg)), '-');
%
title({char(spec.fname);spec.pname},'interp','none');
xlabel('degrees off normal');
ylabel('cosine-corrected signal')
legend('-90 to 0', '0 to 90','90 to 0','0 to -90','location','South');
ylim([.65,1.05])

subplot(2,1,2);
plot(abs(spec.Angle(first&angs_neg)), base_(first&angs_neg)./(cos(pi.*spec.Angle(first&angs_neg)./180).*base_0(first&angs_neg)), '-',...
   abs(spec.Angle(first&angs_pos)), base_(first&angs_pos)./(cos(pi.*spec.Angle(first&angs_pos)./180).*base_0(first&angs_pos)), '-',...
   abs(spec.Angle(second&angs_pos)), base_(second&angs_pos)./(cos(pi.*spec.Angle(second&angs_pos)./180).*base_0(second&angs_pos)), '-',...
   abs(spec.Angle(second&angs_neg)), base_(second&angs_neg)./(cos(pi.*spec.Angle(second&angs_neg)./180).*base_0(second&angs_neg)), '-');
%
title({char(spec.fname);spec.pname},'interp','none');
xlabel('degrees off normal');
ylabel('cosine-corrected signal')
legend('-90 to 0', '0 to 90','90 to 0','0 to -90', 'location','Southwest');
ylim([.65,1.05])
%%
% figure(1); 
% subplot(2,1,1);
% plot(spec.Angle(first&angs), [cos_corr_415(first&angs),cos_corr_500(first&angs),...
%    cos_corr_615(first&angs),cos_corr_870(first&angs)], '-',...
%    spec.Angle(first&angs), [cos_corr(first&angs)], 'k-');
% %
% title({char(spec.fname);spec.pname},'interp','none');
% xlabel('degrees off normal');
% ylabel('cosine-corrected signal')
% legend('500','615','870','600-700');
% subplot(2,1,2);
% plot(spec.Angle(second&angs), [cos_corr_415(second&angs),cos_corr_500(second&angs),...
%    cos_corr_615(second&angs),cos_corr_870(second&angs)], '-',...
%    spec.Angle(second&angs), [cos_corr(second&angs)], 'k-');
% %
% title({char(spec.fname);spec.pname},'interp','none');
% xlabel('degrees off normal');
% ylabel('cosine-corrected signal')
% legend('500','615','870','600-700');




%%

return
     