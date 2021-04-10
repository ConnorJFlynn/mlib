
close all
%% GV counter
h=1
%% group counter
i=1
%% typ counter
j=1
%% pltf counter
k=1
%% obs counter
l=1
%% srfc counter 
m=1
%% res counter
n=1

%% there are eight combinations of group and typ that have priority - they 
%% can be labeled: 
%% NLP-DRSall,NLS-DRSall,NGE-DRSall,OUX-DRSall,NLB-ICAall,OUX-ICAall,NLS-SPA,NGE-SPA  
%% They correspond to the following group/typ index combinations:
%% 1/13, 3/13, 4/13, 5/13, 2/3, 5/3, 3/1, 4/1
%% 

% indx = (i,:,:,1,1,1,1)
%%
%% NLP-DRSall is something like QIS(h, 1, 13, k, l, m, n)
%% would like to plot four pltf's as grouped bars, so
%% NLP-DRSall is QIS(h, 1, 13, :, l, m, n)
%% NLS-DRSall is QIS(h, 3, 13, :, l, m, n)
%% NGE-DRSall is QIS(h, 4, 13, :, l, m, n)
%% OUX-DRSall is QIS(h, 5, 13, :, l, m, n)
%% NLB-ICAall is QIS(h, 2,  3, :, l, m, n)
%% OUX-ICAall is QIS(h, 5,  3, :, l, m, n)
%% NLS-SPA    is QIS(h, 3,  1, :, l, m, n)
%% NGE-SPA    is QIS(h, 4,  1, :, l, m, n)


figure(h)
clear lg
for l=1:3
    new_QIS = squeeze([QIS(h, 1, 13, :, l, m, n) QIS(h, 3, 13, :, l, m, n) ...
        QIS(h, 4, 13, :, l, m, n) QIS(h, 5, 13, :, l, m, n) ...
        QIS(h, 2,  3, :, l, m, n) QIS(h, 5,  3, :, l, m, n) ...
        QIS(h, 3,  1, :, l, m, n) QIS(h, 4,  1, :, l, m, n)]);
    
    subplot(3,3,1+3*(l-1))
    % bar(squeeze(QIS(h,1:end-1,[1 3:end],k,l,1,1)),'BarWidth',0.99)
    bar(new_QIS,'BarWidth',0.99)
    t=title(strjoin(['QI Score   ',GVnames(h),obs(l),srfc(m)]))
    set(t,'Interpreter','none')
    if ~exist('lg','var')
    lg=legend('SSP0', 'SSP1', 'SSP2', 'SSG3','Location','NorthWest')
    set(lg,'Position', [0.0490    0.8488    0.0602    0.0804]);
    end
    set(gca,'XTickLabel',{'NLP-DRS','NLS-DRS','NGE-DRS','OUX-DRS',...
        'NLB-ICA','OUX-ICA','NLS-SPA','NGE-SPA' })
    set(gca,'XTickLabelRot',30)
    set(gca,'FontSize',8)
    
    new_MER = squeeze([MER(h, 1, 13, :, l, m, n) MER(h, 3, 13, :, l, m, n) ...
        MER(h, 4, 13, :, l, m, n) MER(h, 5, 13, :, l, m, n) ...
        MER(h, 2,  3, :, l, m, n) MER(h, 5,  3, :, l, m, n) ...
        MER(h, 3,  1, :, l, m, n) MER(h, 4,  1, :, l, m, n)]);
    
    subplot(3,3,2+3*(l-1))
    %bar(squeeze(MER(h,1:end-1,[1 3:end],k+1,l,1,1)))
    bar(new_MER,'BarWidth',0.99)
    t=title(strjoin(['Mean err    ',GVnames(h),obs(l),srfc(m)]))
    set(t,'Interpreter','none')
    set(gca,'XTickLabel',{'NLP-DRS','NLS-DRS','NGE-DRS','OUX-DRS',...
        'NLB-ICA','OUX-ICA','NLS-SPA','NGE-SPA' })
    set(gca,'XTickLabelRot',30)
    set(gca,'FontSize',8)
    
    new_RMS = squeeze([RMS(h, 1, 13, :, l, m, n) RMS(h, 3, 13, :, l, m, n) ...
        RMS(h, 4, 13, :, l, m, n) RMS(h, 5, 13, :, l, m, n) ...
        RMS(h, 2,  3, :, l, m, n) RMS(h, 5,  3, :, l, m, n) ...
        RMS(h, 3,  1, :, l, m, n) RMS(h, 4,  1, :, l, m, n)]);
    
    subplot(3,3,3*l)
    %bar(squeeze(RMS(h,1:end-1,[1 3:end],k+2,l,1,1)))
    bar(new_RMS,'BarWidth',0.99)
    %title(GVnames(h))
    t=title(strjoin(['RMSE    ',GVnames(h),obs(l),srfc(m)]))
    set(t,'Interpreter','none')
    %ylabel('RMSE')
    set(gca,'XTickLabel',{'NLP-DRS','NLS-DRS','NGE-DRS','OUX-DRS',...
        'NLB-ICA','OUX-ICA','NLS-SPA','NGE-SPA' })
    set(gca,'XTickLabelRot',30)
    set(gca,'FontSize',8)
end



% l=l+1
% new_QIS = squeeze([QIS(h, 1, 13, :, l, m, n) QIS(h, 3, 13, :, l, m, n) ...
%                QIS(h, 4, 13, :, l, m, n) QIS(h, 5, 13, :, l, m, n) ...
%                QIS(h, 2,  3, :, l, m, n) QIS(h, 5,  3, :, l, m, n) ...
%                QIS(h, 3,  1, :, l, m, n) QIS(h, 4,  1, :, l, m, n)]);
% 
% subplot(3,3,4)
% %bar(squeeze(QIS(h,1:end-1,[1 3:end],k,l+1,1,1)),'BarWidth',0.99)
% bar(squeeze(QIS(h,1:end-1,[1 3 13],k,l+1,1,1)),'BarWidth',0.99)
% t=title(strjoin(['QI Score',GVnames(h),pltf(k),obs(l+1),srfc(m)]))
% set(t,'Interpreter','none')
% %ylabel('QI Score')
% set(gca,'XTickLabel',{'NLP','NLB','NLS','NGE','OUX'})
% set(gca,'FontSize',10)
% 
% new_MER = squeeze([MER(h, 1, 13, :, l, m, n) MER(h, 3, 13, :, l, m, n) ...
%                MER(h, 4, 13, :, l, m, n) MER(h, 5, 13, :, l, m, n) ...
%                MER(h, 2,  3, :, l, m, n) MER(h, 5,  3, :, l, m, n) ...
%                MER(h, 3,  1, :, l, m, n) MER(h, 4,  1, :, l, m, n)]);
% 
% subplot(3,3,5)
% %bar(squeeze(MER(h,1:end-1,[1 3:end],k+1,l+1,1,1)))
% bar(squeeze(MER(h,1:end-1,[1 3 13],k+1,l+1,1,1)),'BarWidth',0.99)
% %title(GVnames(h))
% t=title(strjoin(['Mean err',GVnames(h),pltf(k+1),obs(l+1),srfc(m)]))
% set(t,'Interpreter','none')
% %ylabel('Mean error')
% set(gca,'XTickLabel',{'NLP','NLB','NLS','NGE','OUX'})
% set(gca,'FontSize',10)
% 
% new_RMS = squeeze([RMS(h, 1, 13, :, l, m, n) RMS(h, 3, 13, :, l, m, n) ...
%                RMS(h, 4, 13, :, l, m, n) RMS(h, 5, 13, :, l, m, n) ...
%                RMS(h, 2,  3, :, l, m, n) RMS(h, 5,  3, :, l, m, n) ...
%                RMS(h, 3,  1, :, l, m, n) RMS(h, 4,  1, :, l, m, n)]);
% subplot(3,3,6)
% %bar(squeeze(RMS(h,1:end-1,[1 3:end],k+2,l+1,1,1)))
% bar(squeeze(RMS(h,1:end-1,[1 3 13],k+2,l+1,1,1)),'BarWidth',0.99)
% %title(GVnames(h))
% t=title(strjoin(['RMSE',GVnames(h),pltf(k+2),obs(l+1),srfc(m)]))
% set(t,'Interpreter','none')
% %ylabel('RMSE')
% set(gca,'XTickLabel',{'NLP','NLB','NLS','NGE','OUX'})
% set(gca,'FontSize',10)
% 
% l=l+1
% new_QIS = squeeze([QIS(h, 1, 13, :, l, m, n) QIS(h, 3, 13, :, l, m, n) ...
%                QIS(h, 4, 13, :, l, m, n) QIS(h, 5, 13, :, l, m, n) ...
%                QIS(h, 2,  3, :, l, m, n) QIS(h, 5,  3, :, l, m, n) ...
%                QIS(h, 3,  1, :, l, m, n) QIS(h, 4,  1, :, l, m, n)]);
% 
% 
% subplot(3,3,7)
% %bar(squeeze(QIS(h,1:end-1,[1 3:end],k,l+2,1,1)),'BarWidth',0.99)
% bar(squeeze(QIS(h,1:end-1,[1 3 13],k,l+2,1,1)),'BarWidth',0.99)
% t=title(strjoin(['QI Score',GVnames(h),pltf(k),obs(l+2),srfc(m)]))
% set(t,'Interpreter','none')
% %ylabel('QI Score')
% set(gca,'XTickLabel',{'NLP','NLB','NLS','NGE','OUX'})
% set(gca,'FontSize',10)
% 
% new_MER = squeeze([MER(h, 1, 13, :, l, m, n) MER(h, 3, 13, :, l, m, n) ...
%                MER(h, 4, 13, :, l, m, n) MER(h, 5, 13, :, l, m, n) ...
%                MER(h, 2,  3, :, l, m, n) MER(h, 5,  3, :, l, m, n) ...
%                MER(h, 3,  1, :, l, m, n) MER(h, 4,  1, :, l, m, n)]);
% 
% subplot(3,3,8)
% %bar(squeeze(MER(h,1:end-1,[1 3:end],k+1,l+2,1,1)))
% bar(squeeze(MER(h,1:end-1,[1 3 13],k+1,l+2,1,1)),'BarWidth',0.99)
% %title(GVnames(h))
% t=title(strjoin(['Mean err',GVnames(h),pltf(k+1),obs(l+2),srfc(m)]))
% set(t,'Interpreter','none')
% %ylabel('Mean error')
% set(gca,'XTickLabel',{'NLP','NLB','NLS','NGE','OUX'})
% set(gca,'FontSize',10)
% 
% new_RMS = squeeze([RMS(h, 1, 13, :, l, m, n) RMS(h, 3, 13, :, l, m, n) ...
%                RMS(h, 4, 13, :, l, m, n) RMS(h, 5, 13, :, l, m, n) ...
%                RMS(h, 2,  3, :, l, m, n) RMS(h, 5,  3, :, l, m, n) ...
%                RMS(h, 3,  1, :, l, m, n) RMS(h, 4,  1, :, l, m, n)]);
% 
% subplot(3,3,9)
% %bar(squeeze(RMS(h,1:end-1,[1 3:end],k+2,l+2,1,1)))
% bar(squeeze(RMS(h,1:end-1,[1 3 13],k+2,l+2,1,1)),'BarWidth',0.99)
% %title(GVnames(h))
% t=title(strjoin(['RMSE',GVnames(h),pltf(k+2),obs(l+2),srfc(m)]))
% set(t,'Interpreter','none')
% %ylabel('RMSE')
% set(gca,'XTickLabel',{'NLP','NLB','NLS','NGE','OUX'})
% set(gca,'FontSize',10)
