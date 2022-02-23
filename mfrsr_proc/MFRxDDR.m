function M1 = MFRxDDR(C1, E13);

if ~isavar('C1')
   C1 = anc_bundle_files;
end
if ~isavar('E13')
   E13 = anc_bundle_files;
end

[cine, einc] = nearest(C1.time, E13.time);
[C1, C1x] = anc_sift(C1, cine);C1x.time;
[E13,E13x] = anc_sift(E13, einc);E13x.time;

ddrd = C1.vdata.direct_diffuse_ratio_filter1./E13.vdata.direct_diffuse_ratio_filter1;
ddrd = ddrd + C1.vdata.direct_diffuse_ratio_filter2./E13.vdata.direct_diffuse_ratio_filter2;
ddrd = ddrd + C1.vdata.direct_diffuse_ratio_filter3./E13.vdata.direct_diffuse_ratio_filter3;
ddrd = ddrd + C1.vdata.direct_diffuse_ratio_filter2./E13.vdata.direct_diffuse_ratio_filter4;
ddrd = ddrd + C1.vdata.direct_diffuse_ratio_filter2./E13.vdata.direct_diffuse_ratio_filter5;
ddrd == ddrd./5; % Use mean of all five DDR ratios

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
C1.vdata.direct_diffuse_ratio_filter1 = (C1.vdata.direct_diffuse_ratio_filter1 .* ddrd.^2 + E13.vdata.direct_diffuse_ratio_filter1 .* (1./ddrd).^2)./(ddrd.^2 + ddrd.^-2);
C1.vdata.direct_diffuse_ratio_filter2 = (C1.vdata.direct_diffuse_ratio_filter2 .* ddrd.^2 + E13.vdata.direct_diffuse_ratio_filter2 .* (1./ddrd).^2)./(ddrd.^2 + ddrd.^-2);
C1.vdata.direct_diffuse_ratio_filter3 = (C1.vdata.direct_diffuse_ratio_filter3 .* ddrd.^2 + E13.vdata.direct_diffuse_ratio_filter3 .* (1./ddrd).^2)./(ddrd.^2 + ddrd.^-2);
C1.vdata.direct_diffuse_ratio_filter4 = (C1.vdata.direct_diffuse_ratio_filter4 .* ddrd.^2 + E13.vdata.direct_diffuse_ratio_filter4 .* (1./ddrd).^2)./(ddrd.^2 + ddrd.^-2);
C1.vdata.direct_diffuse_ratio_filter5 = (C1.vdata.direct_diffuse_ratio_filter5 .* ddrd.^2 + E13.vdata.direct_diffuse_ratio_filter5 .* (1./ddrd).^2)./(ddrd.^2 + ddrd.^-2);

if isfield(C1.vdata, 'direct_diffuse_ratio_filter7') && isfield(E13.vdata, 'direct_diffuse_ratio_filter7')
   C1.vdata.direct_diffuse_ratio_filter7 = (C1.vdata.direct_diffuse_ratio_filter7 .* ddrd.^2 + E13.vdata.direct_diffuse_ratio_filter6 .* (1./ddrd).^2)./2;
elseif ~isfield(C1.vdata, 'direct_diffuse_ratio_filter7') && isfield(E13.vdata, 'direct_diffuse_ratio_filter7')
   C1.vdata.direct_diffuse_ratio_filter7 = E13.vdata.direct_diffuse_ratio_filter7;
   C1x.vdata.direct_diffuse_ratio_filter7 = NaN(size(C1x.vdata.direct_diffuse_ratio_filter5 )); %add to C1x since it exists in E13
end

M1 = anc_mesh(C1, C1x,'time'); M1.time;
M1 = anc_mesh(M1, E13x, 'time');
newout = [M1.fname,'.mat'];
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
