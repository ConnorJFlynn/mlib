function cos_corr = sgpsashe_coscorr_vs_nimfr(sza);
% cos_corr = sgpsashe_coscorr(sza);
corr = sgpsashe_coscorr_vs_nimfr_;
cos_corr = interp1(corr(:,1), corr(:,2), sza,'pchip');
he_vis_2.new_cos_corr = interp1(cos(corr(1,:).*pi./180), corr(2,:),cos(sza.*pi./180),'pchip','extrap');


return;
