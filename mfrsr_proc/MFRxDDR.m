function M1 = MFRxDDR(C1, E13)
% Combines two MFRSR streams, in particular meshing DDR to favor the higher
% of the two sources weighted in the square of the mean deviation from unity 
% Maybe rename to meshMFRSR or MFRSRmesh?

if ~isavar('C1')
   C1 = anc_bundle_files(getfullname('sgpmfrsr*.b1.*', 'mfrsrC1'));
end
if ~isavar('E13')
   E13 = anc_bundle_files(getfullname('sgpmfrsr*.b1.*', 'mfrsrE13'));
end
% Replace this logic with creating the unique union of the times

[cine, einc] = nearest(C1.time, E13.time);
[C1, C1x] = anc_sift(C1, cine);C1x.time;
[E13,E13x] = anc_sift(E13, einc);E13x.time;

ddrd = C1.vdata.direct_diffuse_ratio_filter1./E13.vdata.direct_diffuse_ratio_filter1;
ddrd(2,:) = C1.vdata.direct_diffuse_ratio_filter2./E13.vdata.direct_diffuse_ratio_filter2;
ddrd(3,:) = C1.vdata.direct_diffuse_ratio_filter3./E13.vdata.direct_diffuse_ratio_filter3;
ddrd(4,:) = C1.vdata.direct_diffuse_ratio_filter5./E13.vdata.direct_diffuse_ratio_filter5;
ddrd(5,:) = mean(ddrd(1:4,:)); % Use mean of all five DDR ratios
good = C1.vdata.airmass>=1 & C1.vdata.airmass<6 ;
good = good & C1.vdata.direct_diffuse_ratio_filter1 > 1 & C1.vdata.direct_diffuse_ratio_filter1 < 5 & C1.vdata.direct_normal_narrowband_filter1 >0;
good = good & C1.vdata.direct_diffuse_ratio_filter2 > 1 & C1.vdata.direct_diffuse_ratio_filter2 < 8 & C1.vdata.direct_normal_narrowband_filter2 >0;
good = good & C1.vdata.direct_diffuse_ratio_filter3 > 1 & C1.vdata.direct_diffuse_ratio_filter3 < 15 & C1.vdata.direct_normal_narrowband_filter3 >0;
good = good & C1.vdata.direct_diffuse_ratio_filter5 > 1 & C1.vdata.direct_diffuse_ratio_filter5 < 30 & C1.vdata.direct_normal_narrowband_filter5 >0;
good = good & E13.vdata.direct_diffuse_ratio_filter1 > 1 & E13.vdata.direct_diffuse_ratio_filter1 < 5 & E13.vdata.direct_normal_narrowband_filter1 >0;
good = good & E13.vdata.direct_diffuse_ratio_filter2 > 1 & E13.vdata.direct_diffuse_ratio_filter2 < 8 & E13.vdata.direct_normal_narrowband_filter2 >0;
good = good & E13.vdata.direct_diffuse_ratio_filter3 > 1 & E13.vdata.direct_diffuse_ratio_filter3 < 15 & E13.vdata.direct_normal_narrowband_filter3 >0;
good = good & E13.vdata.direct_diffuse_ratio_filter5 > 1 & E13.vdata.direct_diffuse_ratio_filter5 < 30 & E13.vdata.direct_normal_narrowband_filter5 >0;
figure; plot(C1.time(good), ddrd(:,good),'.',C1.time(good), mean(ddrd(:,good)),'k.'); dynamicDateTicks; zoom('on'); xlim(xl)
xl_ = C1.time>=xl(1) & C1.time<xl(2);
figure; plot(C1.time(good), [C1.vdata.direct_diffuse_ratio_filter1(good); C1.vdata.direct_diffuse_ratio_filter2(good); C1.vdata.direct_diffuse_ratio_filter3(good); C1.vdata.direct_diffuse_ratio_filter5(good)],'.'); xlim(xl);
hold('on'); plot(E13.time(good), E13.vdata.direct_diffuse_ratio_filter5(good),'k.');
figure; plot(C1.vdata.airmass(xl_), mean(ddrd(xl_,good)),'k.');

tz = double(C1.vdata.lon./15)
tts = 0: (1./6) : 24-(1./(24.*12));
ddrd_iqm = NaN(size(tts)); mass = NaN(size(tts));
for ti = 1:length(tts)
   ti_ = good&(serial2Hh(C1.time+double(C1.vdata.lon./15./24))>=tts(ti) & serial2Hh(C1.time+double(C1.vdata.lon./15./24)) < (tts(ti)+1./(24.*12)));
   mass(ti) = nanmean(C1.vdata.airmass(ti_));
   if sum(ti_)>5
%       sum(ti_)
      ddi = ddrd(:,ti_);
      ddrd_iqm(ti) = mean(ddi(IQ(ddi(:),.1)));
   end
end
figure;   plot(tts, (ddrd_iqm),'*m');
ddrd_t = NaN(size(C1.time));
ddrd_t(good) = interp1(tts, ddrd_iqm, serial2Hh(C1.time(good))+tz,'linear');
ddrd_t(isnan(ddrd_t)) = interp1(tts, ddrd_iqm, serial2Hh(C1.time(isnan(ddrd_t)))+tz,'nearest','extrap');
figure; plot(C1.time(good), ddrd_t(good),'k.'); xlim(xl); dynamicDateTicks




bad = C1.vdata.direct_diffuse_ratio_filter1 < 0 | E13.vdata.direct_diffuse_ratio_filter1 < 0;
ddrd(bad) = NaN;
bad = C1.vdata.direct_diffuse_ratio_filter2 < 0 | E13.vdata.direct_diffuse_ratio_filter2 < 0;
ddrd(bad) = NaN;
bad = C1.vdata.direct_diffuse_ratio_filter3 < 0 | E13.vdata.direct_diffuse_ratio_filter3 < 0;
ddrd(bad) = NaN;
bad = C1.vdata.direct_diffuse_ratio_filter4 < 0 | E13.vdata.direct_diffuse_ratio_filter4 < 0;
ddrd(bad) = NaN;
bad = C1.vdata.direct_diffuse_ratio_filter5 < 0 | E13.vdata.direct_diffuse_ratio_filter5 < 0;
ddrd(bad) = NaN;

%Weight by the square of the ratio, so high values are favored.
% Replace values in C1 with weighted average from both with weighting
% favoring the higher of the two
C1.vdata.direct_diffuse_ratio_filter1 = (C1.vdata.direct_diffuse_ratio_filter1 .* ddrd_t.^2 + E13.vdata.direct_diffuse_ratio_filter1 .* (1./ddrd_t).^2)./(ddrd_t.^2 + ddrd_t.^-2);
C1.vdata.direct_diffuse_ratio_filter2 = (C1.vdata.direct_diffuse_ratio_filter2 .* ddrd_t.^2 + E13.vdata.direct_diffuse_ratio_filter2 .* (1./ddrd_t).^2)./(ddrd_t.^2 + ddrd_t.^-2);
C1.vdata.direct_diffuse_ratio_filter3 = (C1.vdata.direct_diffuse_ratio_filter3 .* ddrd_t.^2 + E13.vdata.direct_diffuse_ratio_filter3 .* (1./ddrd_t).^2)./(ddrd_t.^2 + ddrd_t.^-2);
C1.vdata.direct_diffuse_ratio_filter4 = (C1.vdata.direct_diffuse_ratio_filter4 .* ddrd_t.^2 + E13.vdata.direct_diffuse_ratio_filter4 .* (1./ddrd_t).^2)./(ddrd_t.^2 + ddrd_t.^-2);
C1.vdata.direct_diffuse_ratio_filter5 = (C1.vdata.direct_diffuse_ratio_filter5 .* ddrd_t.^2 + E13.vdata.direct_diffuse_ratio_filter5 .* (1./ddrd_t).^2)./(ddrd_t.^2 + ddrd_t.^-2);
C1.vdata.direct_diffuse_ratio_filter7 = (C1.vdata.direct_diffuse_ratio_filter7 .* ddrd_t.^2 + E13.vdata.direct_diffuse_ratio_filter7 .* (1./ddrd_t).^2)./(ddrd_t.^2 + ddrd_t.^-2);
hold('on'); plot(C1.time, C1.vdata.direct_diffuse_ratio_filter5, 'm.'); dynamicDateTicks; xlim(xl);


% if isfield(C1.vdata, 'direct_diffuse_ratio_filter7') && isfield(E13.vdata, 'direct_diffuse_ratio_filter7')
%    C1.vdata.direct_diffuse_ratio_filter7 = (C1.vdata.direct_diffuse_ratio_filter7 .* ddrd_t.^2 + E13.vdata.direct_diffuse_ratio_filter6 .* (1./ddrd).^2)./2;
% elseif ~isfield(C1.vdata, 'direct_diffuse_ratio_filter7') && isfield(E13.vdata, 'direct_diffuse_ratio_filter7')
%    C1.vdata.direct_diffuse_ratio_filter7 = E13.vdata.direct_diffuse_ratio_filter7;
%    C1x.vdata.direct_diffuse_ratio_filter7 = NaN(size(C1x.vdata.direct_diffuse_ratio_filter5 )); %add to C1x since it exists in E13
% end

M1 = anc_mesh(C1, C1x,'time'); M1.time;
M1 = anc_mesh(M1, E13x, 'time');
[pname, fname, ext] = fileparts(M1.fname);  pname = strrep([pname, filesep], [filesep filesep], filesep); 
fname = strrep(fname, 'C1','mesh');
%sgpmfrsrmesh.mat
newout = [pname, fname,'.mat']; 
save(newout,'-struct','M1');

end

% ARM_display_beta(M1)
% % I think this is the merged DDR product.
% % Now, we use this in fix_sas_ddr to obtain sashe DDR that agrees with
% % collocated MFRSR(s).
% 
% 
% 
% 
% 
% figure_(44)
% ss(1) = subplot(2,2,1) % Plot filters 1-2 with same colors for same filters
% plot(C1.time, [C1.vdata.direct_diffuse_ratio_filter1;C1.vdata.direct_diffuse_ratio_filter2;C1.vdata.direct_diffuse_ratio_filter3],'-');
% set(gca,'ColorOrderIndex',1); hold('on')
% plot(E13.time, [E13.vdata.direct_diffuse_ratio_filter1;E13.vdata.direct_diffuse_ratio_filter2;E13.vdata.direct_diffuse_ratio_filter3],'-');
% dynamicDateTicks; yl = ylim; ylim([0,yl(2)]); legend('filter1','filter 2','filter 3');
% 
% ss(2) = subplot(2,2,2) % Plot filters 1-2 with same colors for same filters
% plot(C1.time, [C1.vdata.direct_diffuse_ratio_filter1./E13.vdata.direct_diffuse_ratio_filter1;...
%    C1.vdata.direct_diffuse_ratio_filter2./E13.vdata.direct_diffuse_ratio_filter2;...
%    C1.vdata.direct_diffuse_ratio_filter3./E13.vdata.direct_diffuse_ratio_filter3],'-');
% dynamicDateTicks; yl = ylim; ylim([0,yl(2)]); legend('filter1','filter 2','filter3');
% 
% ss(3) = subplot(2,2,3) % Plot filters 4-5 with same colors for same filters
% set(gca,'ColorOrderIndex',3); hold('on')
% plot(C1.time, [C1.vdata.direct_diffuse_ratio_filter4;C1.vdata.direct_diffuse_ratio_filter5],'-');
% set(gca,'ColorOrderIndex',3); hold('on')
% plot(E13.time, [E13.vdata.direct_diffuse_ratio_filter4;E13.vdata.direct_diffuse_ratio_filter5],'-');
% dynamicDateTicks; yl = ylim; ylim([0,yl(2)]); legend('filter4','filter 5');
% 
% ss(4) = subplot(2,2,4) % Plot filters 4-5 with same colors for same filters
% set(gca,'ColorOrderIndex',3); hold('on')
% plot(C1.time, [C1.vdata.direct_diffuse_ratio_filter4./E13.vdata.direct_diffuse_ratio_filter4;...
%    C1.vdata.direct_diffuse_ratio_filter5./E13.vdata.direct_diffuse_ratio_filter5],'-');
% dynamicDateTicks; yl = ylim; ylim([0,yl(2)]);  legend('filter4','filter 5');
% linkaxes(ss,'x')
