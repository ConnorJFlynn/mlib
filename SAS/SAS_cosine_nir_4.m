function spec = SAS_cosine_4(infile)
% spec = SAS_cosine_4(indir)
% This version reads files containing multiple spectra, darks and lights at
% varying angles, zeros only periodically.
% 
spec = SAS_read_Albert_csv(getfullname('*.csv','ava','Select cosine correction data'));
spec.nm(spec.nm<=0) = NaN;
%%
wl_r = spec.nm>950&spec.nm<1700;
wl_1050 = spec.nm>1000&spec.nm<1100;
wl_1150 = spec.nm>1100&spec.nm<1200;
wl_1250 = spec.nm>1200&spec.nm<1300;
wl_1350 = spec.nm>1300&spec.nm<1400;
wl_1450 = spec.nm>1400&spec.nm<1500;
wl_1550 = spec.nm>1500&spec.nm<1600;
wl_1650 = spec.nm>1600&spec.nm<1700;

wl_dk = spec.nm>1745&spec.nm<1771;;
dark_ii = find(spec.Shuttered_0==0);
first_dark = (spec.spec(dark_ii(1),:));
mean_dark = mean(spec.spec(dark_ii,:),1);
norm_dark = first_dark./mean(first_dark(wl_dk));
norm_dark = mean_dark./mean(mean_dark(wl_dk));
dark_wt = mean(spec.spec(:,wl_dk),2);
darks = dark_wt * norm_dark;
no_darks = spec.spec -darks;
base_ = mean(no_darks(:,wl_r),2);
base_1050 = mean(no_darks(:,wl_1050),2);
base_1150 = mean(no_darks(:,wl_1150),2);
base_1250 = mean(no_darks(:,wl_1250),2);
base_1350 = mean(no_darks(:,wl_1350),2);
base_1450 = mean(no_darks(:,wl_1450),2);
base_1550 = mean(no_darks(:,wl_1550),2);
base_1650 = mean(no_darks(:,wl_1650),2);

base_0 = base_;
base_1050_ = base_1050;
base_1150_ = base_1150;
base_1250_ = base_1250;
base_1350_ = base_1350;
base_1450_ = base_1450;
base_1550_ = base_1550;
base_1650_ = base_1650;
%%
base_0(spec.Angle~=0|spec.Shuttered_0==0) = interp1(find(spec.Angle==0&spec.Shuttered_0~=0),...
   base_(spec.Angle==0&spec.Shuttered_0~=0),...
   find(spec.Angle~=0|spec.Shuttered_0==0), 'linear','extrap');
base_1050_(spec.Angle~=0|spec.Shuttered_0==0) = interp1(find(spec.Angle==0&spec.Shuttered_0~=0),...
   base_1050(spec.Angle==0&spec.Shuttered_0~=0),...
   find(spec.Angle~=0|spec.Shuttered_0==0), 'linear','extrap')';
base_1150_(spec.Angle~=0|spec.Shuttered_0==0) = interp1(find(spec.Angle==0&spec.Shuttered_0~=0),...
   base_1150(spec.Angle==0&spec.Shuttered_0~=0),...
   find(spec.Angle~=0|spec.Shuttered_0==0), 'linear','extrap')';
base_1250_(spec.Angle~=0|spec.Shuttered_0==0) = interp1(find(spec.Angle==0&spec.Shuttered_0~=0),...
   base_1250(spec.Angle==0&spec.Shuttered_0~=0),...
   find(spec.Angle~=0|spec.Shuttered_0==0), 'linear','extrap')';
base_1350_(spec.Angle~=0|spec.Shuttered_0==0) = interp1(find(spec.Angle==0&spec.Shuttered_0~=0),...
   base_1350(spec.Angle==0&spec.Shuttered_0~=0),...
   find(spec.Angle~=0|spec.Shuttered_0==0), 'linear','extrap')';
base_1450_(spec.Angle~=0|spec.Shuttered_0==0) = interp1(find(spec.Angle==0&spec.Shuttered_0~=0),...
   base_1450(spec.Angle==0&spec.Shuttered_0~=0),...
   find(spec.Angle~=0|spec.Shuttered_0==0), 'linear','extrap')';
base_1550_(spec.Angle~=0|spec.Shuttered_0==0) = interp1(find(spec.Angle==0&spec.Shuttered_0~=0),...
   base_1550(spec.Angle==0&spec.Shuttered_0~=0),...
   find(spec.Angle~=0|spec.Shuttered_0==0), 'linear','extrap')';
base_1650_(spec.Angle~=0|spec.Shuttered_0==0) = interp1(find(spec.Angle==0&spec.Shuttered_0~=0),...
   base_1650(spec.Angle==0&spec.Shuttered_0~=0),...
   find(spec.Angle~=0|spec.Shuttered_0==0), 'linear','extrap')';

figure; plot([1:length(base_)],base_,'-',[1:length(base_0)],base_0,'k-');
title('Baseline mean from 600-700, dark subtracted')

%%
figure; plot([1:length(base_)],spec.Angle,'o')
%%
first = false(size(spec.time));
second = first;
mid = floor(length(spec.Angle)./2);
first(1:mid) = true;
second(mid:end) = true;
angs = spec.Angle~=0&spec.Shuttered_0~=0&abs(spec.Angle)<88;
angs_pos = spec.Angle~=0&spec.Shuttered_0~=0&(spec.Angle>=0)&(spec.Angle<=85);
angs_neg = spec.Angle~=0&spec.Shuttered_0~=0&(spec.Angle<=0)&(spec.Angle>=-85);
cos_corr = base_./(cos(pi.*spec.Angle./180).*base_0);
cos_corr_1050 = base_1050./(cos(pi.*spec.Angle./180).*base_1050_);
cos_corr_1150 = base_1150./(cos(pi.*spec.Angle./180).*base_1150_);
cos_corr_1250 = base_1250./(cos(pi.*spec.Angle./180).*base_1250_);
cos_corr_1350 = base_1350./(cos(pi.*spec.Angle./180).*base_1350_);
cos_corr_1450 = base_1450./(cos(pi.*spec.Angle./180).*base_1450_);
cos_corr_1550 = base_1550./(cos(pi.*spec.Angle./180).*base_1550_);
cos_corr_1650 = base_1650./(cos(pi.*spec.Angle./180).*base_1650_);

%%
% figure(1); 
subplot(2,1,1);
plot(spec.Angle(first&angs_neg), base_(first&angs_neg)./(cos(pi.*spec.Angle(first&angs_neg)./180).*base_0(first&angs_neg)), '-',...
   spec.Angle(first&angs_pos), base_(first&angs_pos)./(cos(pi.*spec.Angle(first&angs_pos)./180).*base_0(first&angs_pos)), '-',...
   spec.Angle(second&angs_pos), base_(second&angs_pos)./(cos(pi.*spec.Angle(second&angs_pos)./180).*base_0(second&angs_pos)), '-',...
   spec.Angle(second&angs_neg), base_(second&angs_neg)./(cos(pi.*spec.Angle(second&angs_neg)./180).*base_0(second&angs_neg)), '-');
%
title({char(spec.fname);spec.pname},'interp','none');
xlabel('degrees off normal');
ylabel('cosine-corrected signal')
legend('-90 to 0', '0 to 90','90 to 0','0 to -90');
subplot(2,1,2);
plot(abs(spec.Angle(first&angs_neg)), base_(first&angs_neg)./(cos(pi.*spec.Angle(first&angs_neg)./180).*base_0(first&angs_neg)), '-',...
   abs(spec.Angle(first&angs_pos)), base_(first&angs_pos)./(cos(pi.*spec.Angle(first&angs_pos)./180).*base_0(first&angs_pos)), '-',...
   abs(spec.Angle(second&angs_pos)), base_(second&angs_pos)./(cos(pi.*spec.Angle(second&angs_pos)./180).*base_0(second&angs_pos)), '-',...
   abs(spec.Angle(second&angs_neg)), base_(second&angs_neg)./(cos(pi.*spec.Angle(second&angs_neg)./180).*base_0(second&angs_neg)), '-');
%
title({char(spec.fname);spec.pname},'interp','none');
xlabel('degrees off normal');
ylabel('cosine-corrected signal')
legend('-90 to 0', '0 to 90','90 to 0','0 to -90');

%%
figure; 
subplot(2,1,1);
lines = plot(spec.Angle(first&angs), [cos_corr_1050(first&angs),cos_corr_1150(first&angs),...
   cos_corr_1250(first&angs),cos_corr_1350(first&angs),cos_corr_1450(first&angs),...
   cos_corr_1550(first&angs),cos_corr_1650(first&angs)], '-',...
   spec.Angle(first&angs), [cos_corr(first&angs)], 'k-');
recolor(lines(1:7), [1050,1150,1250,1350,1450,1550,1650]);colorbar
%
title({char(spec.fname);spec.pname},'interp','none');
xlabel('degrees off normal');
ylabel('cosine-corrected signal')
legend('1050','1150','1250','1350','1450','1550','1650' );
subplot(2,1,2);
lines_2 = plot(spec.Angle(second&angs), [cos_corr_1050(second&angs),cos_corr_1150(second&angs),...
   cos_corr_1250(second&angs),cos_corr_1350(second&angs),...
   cos_corr_1450(second&angs),cos_corr_1550(second&angs),...
   cos_corr_1550(second&angs)], '-',...
   spec.Angle(second&angs), [cos_corr(second&angs)], 'k-');
recolor(lines_2(1:7), [1050,1150,1250,1350,1450,1550,1650]);colorbar
%
title({char(spec.fname);spec.pname},'interp','none');
xlabel('degrees off normal');
ylabel('cosine-corrected signal')
legend('1050','1150','1250','1350','1450','1550','1650' );



%%

return
     