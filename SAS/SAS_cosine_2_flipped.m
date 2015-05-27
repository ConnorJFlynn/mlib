% Cosine response of head rotated with 180-degree juxtaposition:
% Head in position 1 with angular response from horizon to horizon
% Head rotated by 180 degrees with response from horizon to horizon
%%
close('all'); clear
%%
Plus90 = SAS_cosine_2;
Neg90 = SAS_cosine_2;
%%
flipped.Angle = Plus90.Angle(2:end);
flipped.cos_corr = (Plus90.cos_corr(2:end,:)+ flipud(Neg90.cos_corr(2:end,:)))./2;
flipped.cos_corr_dwn = downsample(flipped.cos_corr,20,2);
flipped.nm = Plus90.nm;
flipped.nm_dwn = downsample(flipped.nm,20);
%%

figure; lines = plot(flipped.Angle, flipped.cos_corr_dwn(:,20:4:40),'.');
% lines = recolor(lines, flipped.nm_dwn(20:4:40));colorbar
axis(v);
% Then flip Neg90 and take mean of combined.

