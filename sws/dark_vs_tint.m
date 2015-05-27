% Read in the concatenated dark file 
[sws_darks] = read_sws_raw
 %%
 [Si_tints,Si_inds] = sort(sws_darks.Si_ms);
 [In_tints,In_inds] = sort(sws_darks.In_ms);
 
 %%
 for x = length(sws_darks.Si_lambda):-1:1
    [P_Si(x,:)] = polyfit(sws_darks.Si_ms, sws_darks.Si_DN(x,:),1);
    [Pp_Si(x,:),S,Mu_Si(x,:)] = polyfit(sws_darks.Si_ms, sws_darks.Si_DN(x,:),1);
    [P_In(x,:)] = polyfit(sws_darks.Si_ms, sws_darks.In_DN(x,:),1);
 end
%%
figure; Si_ax(1) = subplot(2,1,1); plot(sws_darks.Si_lambda, P_Si(:,2),'.b-'); title('Si dark t_o');
Si_ax(2) = subplot(2,1,2); plot(sws_darks.Si_lambda, P_Si(:,1),'.b-'); title('Si dark counts per ms');
linkaxes(Si_ax,'x');
figure; In_ax(1) = subplot(2,1,1); plot(sws_darks.In_lambda, P_In(:,2),'.r-'); title('In dark t_o');
In_ax(2) = subplot(2,1,2); plot(sws_darks.In_lambda, P_In(:,1),'.r-'); title('In dark counts per ms');
linkaxes(In_ax,'x');
figure; ms_ax(1) = subplot(2,1,2); Si_lines = plot(sws_darks.Si_ms, sws_darks.Si_DN); Si_lines = recolor(Si_lines,sws_darks.Si_lambda);
colorbar
xlabel('integration time (ms)');
ylabel('dark counts');
title('Si detector darks')
ms_ax(2) = subplot(2,1,1); In_lines = plot(sws_darks.In_ms, sws_darks.In_DN); In_lines = recolor(In_lines,sws_darks.In_lambda);
linkaxes(ms_ax,'x');
colorbar
xlabel('integration time (ms)');
ylabel('dark counts');
title('InGaAs detector darks')

%%
 windowSize=1;
%  filter(ones(1,windowSize)/windowSize,1,
figure; Si_ax(1) = subplot(2,1,1); plot(sws_darks.Si_lambda, filter(ones(1,windowSize)/windowSize,1,P_Si(:,2)),'.b-'); title('Si dark t_o');
Si_ax(2) = subplot(2,1,2); plot(sws_darks.Si_lambda, filter(ones(1,windowSize)/windowSize,1,P_Si(:,1)),'.b-'); title('Si dark counts per ms');
linkaxes(Si_ax,'x');
figure; In_ax(1) = subplot(2,1,1); plot(sws_darks.In_lambda, filter(ones(1,windowSize)/windowSize,1,P_In(:,2)),'.r-'); title('In dark t_o');
In_ax(2) = subplot(2,1,2); plot(sws_darks.In_lambda, filter(ones(1,windowSize)/windowSize,1,P_In(:,1)),'.r-'); title('In dark counts per ms');
linkaxes(In_ax,'x');
figure; ms_ax(1) = subplot(2,1,2); Si_lines = plot(sws_darks.Si_ms, filter(ones(1,windowSize)/windowSize,1,sws_darks.Si_DN)); Si_lines = recolor(Si_lines,sws_darks.Si_lambda);
colorbar
xlabel('integration time (ms)');
ylabel('dark counts');
title('Si detector darks')
ms_ax(2) = subplot(2,1,1); In_lines = plot(sws_darks.In_ms, filter(ones(1,windowSize)/windowSize,1,sws_darks.In_DN)); In_lines = recolor(In_lines,sws_darks.In_lambda);
linkaxes(ms_ax,'x');
colorbar
xlabel('integration time (ms)');
ylabel('dark counts');
title('InGaAs detector darks')
figure; ms_ax(1) = subplot(2,1,2); plot(sws_darks.Si_ms, filter(ones(1,windowSize)/windowSize,1,sws_darks.Si_DN),'.'); 
xlabel('integration time (ms)');
ylabel('dark counts');
title('Si detector darks')
ms_ax(2) = subplot(2,1,1); plot(sws_darks.In_ms, filter(ones(1,windowSize)/windowSize,1,sws_darks.In_DN),'.'); 
linkaxes(ms_ax,'x');
xlabel('integration time (ms)');
ylabel('dark counts');
title('InGaAs detector darks')
 
%%
%This plot shows the saw-tooth darks of the Si detector and also the
%unexpected positive correlation between the InGaAs dark t_o and the dark
%rate. Still don't know if this also affects the gain per bin.  
 windowSize=2;
 figure; 
 subplot(2,1,1);
 plot(P_In(:,1)-filter(ones(1,windowSize)/windowSize,1,P_In(:,1)), P_In(:,2)-filter(ones(1,windowSize)/windowSize,1,P_In(:,2)), '.')
 title('InGaAs')
 subplot(2,1,2);
 plot(P_Si(:,1)-filter(ones(1,windowSize)/windowSize,1,P_Si(:,1)), P_Si(:,2)-filter(ones(1,windowSize)/windowSize,1,P_Si(:,2)), '.')
title('Si')