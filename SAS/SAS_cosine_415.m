function spec = SAS_cosine_4(infile)
% spec = SAS_cosine_4(indir)
% This version reads files containing multiple spectra, darks and lights at
% varying angles, zeros only periodically.
% 
spec = SAS_read_Albert_csv(getfullname('*.csv','ava','Select cosine correction data'));
%% The cosine correction measurement alternates between normal and angle
%% theta as theta goes from 0 to +/- 95 degrees.  A few darks are taken
%% distributed over the course of the measurements. 
wl_r = spec.nm>415&spec.nm<870;
wl_415 = spec.nm>400&spec.nm<430;
wl_500 = spec.nm>490&spec.nm<510;
wl_615 = spec.nm>605&spec.nm<625;
wl_675 = spec.nm>665&spec.nm<685;
wl_870 = spec.nm>860&spec.nm<880;


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
base_675 = mean(no_darks(:,wl_675),2);
base_870 = mean(no_darks(:,wl_870),2);

base_0 = base_;
base_415_ = base_415;
base_500_ = base_500;
base_615_ = base_615;
base_675_ = base_675;
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
base_675_(spec.Angle~=0|spec.Shuttered_0==0) = interp1(find(spec.Angle==0&spec.Shuttered_0~=0),...
   base_675(spec.Angle==0&spec.Shuttered_0~=0),...
   find(spec.Angle~=0|spec.Shuttered_0==0), 'linear','extrap');
base_870_(spec.Angle~=0|spec.Shuttered_0==0) = interp1(find(spec.Angle==0&spec.Shuttered_0~=0),...
   base_870(spec.Angle==0&spec.Shuttered_0~=0),...
   find(spec.Angle~=0|spec.Shuttered_0==0), 'linear','extrap');

%this first plot show the baseline
figure; plot([1:length(base_)],base_,'-',[1:length(base_0)],base_0,'k-');
title('Baseline mean from 600-700, dark subtracted')

%%
plot([1:length(base_)],spec.Angle,'o')
%%
first = false(size(spec.time));
second = first;
mid = floor(length(spec.Angle)./2);
first(1:mid) = true;
second(mid:end) = true;
angs = spec.Angle~=0&spec.Shuttered_0~=0&abs(spec.Angle)<=85;
angs_pos = spec.Angle~=0&spec.Shuttered_0~=0&(spec.Angle>=0)&(spec.Angle<=85);
angs_neg = spec.Angle~=0&spec.Shuttered_0~=0&(spec.Angle<=0)&(spec.Angle>=-85);
cos_corr = base_./(cos(pi.*spec.Angle./180).*base_0);
cos_corr_415 = base_415./(cos(pi.*spec.Angle./180).*base_415_);
cos_corr_500 = base_500./(cos(pi.*spec.Angle./180).*base_500_);
cos_corr_615 = base_615./(cos(pi.*spec.Angle./180).*base_615_);
cos_corr_675 = base_675./(cos(pi.*spec.Angle./180).*base_675_);
cos_corr_870 = base_870./(cos(pi.*spec.Angle./180).*base_870_);

%%
% figure(1); 
s1(1)=subplot(2,1,1);
plot(spec.Angle(first&angs_neg), base_(first&angs_neg)./(cos(pi.*spec.Angle(first&angs_neg)./180).*base_0(first&angs_neg)), 'o-',...
   spec.Angle(first&angs_pos), base_(first&angs_pos)./(cos(pi.*spec.Angle(first&angs_pos)./180).*base_0(first&angs_pos)), 'o-',...
   spec.Angle(second&angs_pos), base_(second&angs_pos)./(cos(pi.*spec.Angle(second&angs_pos)./180).*base_0(second&angs_pos)), '*-',...
   spec.Angle(second&angs_neg), base_(second&angs_neg)./(cos(pi.*spec.Angle(second&angs_neg)./180).*base_0(second&angs_neg)), '*-');
%
title({char(spec.fname);spec.pname},'interp','none');
xlabel('degrees off normal');
ylabel('cosine-corrected signal')
legend('-90 to 0', '0 to 90','90 to 0','0 to -90');
s1(2)=subplot(2,1,2);
plot(abs(spec.Angle(first&angs_neg)), base_(first&angs_neg)./(cos(pi.*spec.Angle(first&angs_neg)./180).*base_0(first&angs_neg)), 'o-',...
   abs(spec.Angle(first&angs_pos)), base_(first&angs_pos)./(cos(pi.*spec.Angle(first&angs_pos)./180).*base_0(first&angs_pos)), 'o-',...
   abs(spec.Angle(second&angs_pos)), base_(second&angs_pos)./(cos(pi.*spec.Angle(second&angs_pos)./180).*base_0(second&angs_pos)), '*-',...
   abs(spec.Angle(second&angs_neg)), base_(second&angs_neg)./(cos(pi.*spec.Angle(second&angs_neg)./180).*base_0(second&angs_neg)), '*-');
%
title({char(spec.fname);spec.pname},'interp','none');
xlabel('degrees off normal');
ylabel('cosine-corrected signal')
legend('-90 to 0', '0 to 90','90 to 0','0 to -90');
linkaxes(s1,'y');
%%
 figure
s2(1) = subplot(2,1,1);
plot(spec.Angle(first&angs), [cos_corr_415(first&angs),cos_corr_500(first&angs),...
   cos_corr_615(first&angs),cos_corr_870(first&angs)], '-',...
   spec.Angle(first&angs), [cos_corr(first&angs)], 'k-');
%
title({char(spec.fname);spec.pname},'interp','none');
xlabel('degrees off normal');
ylabel('cosine-corrected signal')
legend('415','500','615','675','870','600-700');
s2(2) = subplot(2,1,2);
plot(spec.Angle(second&angs), [cos_corr_415(second&angs),cos_corr_500(second&angs),...
   cos_corr_615(second&angs),cos_corr_675(second&angs),cos_corr_870(second&angs)], '-',...
   spec.Angle(second&angs), [cos_corr(second&angs)], 'k-');
%
title({char(spec.fname);spec.pname},'interp','none');
xlabel('degrees off normal');
ylabel('cosine-corrected signal')
legend('415','500','615','675','870','600-700');

linkaxes(s2,'x')

%%
v = axis;
%%
axis(v);

 figure
s2(1) = subplot(2,1,1);
plot(spec.Angle(first&angs), 1./[cos_corr_415(first&angs),cos_corr_500(first&angs),...
   cos_corr_615(first&angs),cos_corr_675(first&angs),cos_corr_870(first&angs)], '-',...
   spec.Angle(first&angs), 1./[cos_corr(first&angs)], 'k-');
%
title({char(spec.fname);spec.pname},'interp','none');
xlabel('degrees off normal');
ylabel('cosine-corrected signal')
legend('415','500','615','675','870','600-700');
s2(2) = subplot(2,1,2);
plot(spec.Angle(second&angs), 1./[cos_corr_415(second&angs),cos_corr_500(second&angs),...
   cos_corr_615(second&angs),cos_corr_675(second&angs),cos_corr_870(second&angs)], '-',...
   spec.Angle(second&angs), 1./[cos_corr(second&angs)], 'k-');
%
title({char(spec.fname);spec.pname},'interp','none');
xlabel('degrees off normal');
ylabel('cosine-corrected signal')
legend('415','500','615','675','870','600-700');

linkaxes(s2,'x')
%%
 figure
s2(1) = subplot(2,1,1);
plot(1./cosd(spec.Angle(first&angs)), 1./[cos_corr_415(first&angs),cos_corr_500(first&angs),...
   cos_corr_615(first&angs),cos_corr_675(first&angs),cos_corr_870(first&angs)], '-',...
   1/cosd(spec.Angle(first&angs)), 1./[cos_corr(first&angs)], 'k-');
%
title({char(spec.fname);spec.pname},'interp','none');
xlabel('airmass');
ylabel('cosine-corrected signal')
legend('415','500','615','675','870','600-700');
s2(2) = subplot(2,1,2);
plot(1./cosd(spec.Angle(second&angs)), 1./[cos_corr_415(second&angs),cos_corr_500(second&angs),...
   cos_corr_615(second&angs),cos_corr_675(second&angs),cos_corr_870(second&angs)], '-',...
   1./cosd(spec.Angle(second&angs)), 1./[cos_corr(second&angs)], 'k-');
%
title({char(spec.fname);spec.pname},'interp','none');
xlabel('airmass');
ylabel('cosine-corrected signal')
legend('415','500','615','675','870','600-700');

linkaxes(s2,'x')

return
     