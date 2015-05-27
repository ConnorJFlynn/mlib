%%
plots_ppt
%%
figure(12); plot(bias_good_CARL_ext,CARL_Altitude, 'b',bias_good_MPL_ext,MPL_Altitude, 'g');
line([0,0],[0,8],'linestyle','--','color','black')
title('Extinction bias: Lidar - AATS','FontSize',14);
ylabel('altitude MSL','FontSize',14);
xlabel('extinction bias (1/km)','FontSize',14);
legend('CARL','MPL')
set(gca, 'FontSize',14);
%
figure(13); plot(bias_good_CARL_aod,CARL_Altitude, 'b',bias_good_MPL_aod,MPL_Altitude, 'g');
line([0,0],[0,8],'linestyle','--','color','black')
title('Integrated Optical Depth bias: Lidar - AATS','FontSize',14);
ylabel('altitude MSL','FontSize',14);
xlabel('optical depth bias','FontSize',14);
legend('CARL','MPL');
set(gca, 'FontSize',14);
%%

figure(21); plot(mean_good_MPL,MPL_Altitude,'g.',mean_good_CARL,CARL_Altitude,'b.');
line([0,0],[0,8],'linestyle','--','color','black')
legend('MPL','CARL')
%% 
plots_default