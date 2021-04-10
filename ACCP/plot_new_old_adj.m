new_QI_adj = QI_adj;
old_QI_adj = QI_adj;
% QI_adj(H,P,L,m) =73x4x3x3 L = [NAN,NAD,OND], m = [LNDD,LNDV,OCEN];

figure; 
ss(1) = subplot(3,2,1)
plot(1:73, squeeze(new_QI_adj(:,:,1,1)),'o',[1:73],squeeze(old_QI_adj(:,:,1,1)),'k.'); legend('SSP0','SSP1','SSP2','SSG3'); title('Adj QS'); ylabel('NAN')
ss(2) = subplot(3,2,2)
plot(1:73, squeeze(new_QI_adj(:,:,1,1))-squeeze(old_QI_adj(:,:,1,1)),'o'); title('new-old')
ss(3) = subplot(3,2,3)
plot(1:73, squeeze(new_QI_adj(:,:,2,1)),'o',[1:73],squeeze(old_QI_adj(:,:,2,1)),'k.');  title('Adj QS'); ylabel('NAD')
ss(4) = subplot(3,2,4)
plot(1:73, squeeze(new_QI_adj(:,:,2,1))-squeeze(old_QI_adj(:,:,2,1)),'o'); title('new-old')
ss(5) = subplot(3,2,5)
plot(1:73, squeeze(new_QI_adj(:,:,3,1)),'o',[1:73],squeeze(old_QI_adj(:,:,3,1)),'k.');  title('Adj QS') ;ylabel('OND')
ss(6) = subplot(3,2,6)
plot(1:73, squeeze(new_QI_adj(:,:,3,1))-squeeze(old_QI_adj(:,:,3,1)),'o'); title('new-old')
linkaxes(ss,'x');
   mt = mtit(['LNDD']);
    set(mt.th,'fontsize',15,'position',[0.5000    1.0700]);

figure; 
ss(1) = subplot(3,2,1)
plot(1:73, squeeze(new_QI_adj(:,:,1,2)),'o',[1:73],squeeze(old_QI_adj(:,:,1,2)),'k.'); legend('SSP0','SSP1','SSP2','SSG3'); title('Adj QS'); ylabel('NAN')
ss(2) = subplot(3,2,2)
plot(1:73, squeeze(new_QI_adj(:,:,1,2))-squeeze(old_QI_adj(:,:,1,2)),'o'); title('new-old')
ss(3) = subplot(3,2,3)
plot(1:73, squeeze(new_QI_adj(:,:,2,2)),'o',[1:73],squeeze(old_QI_adj(:,:,2,2)),'k.');  title('Adj QS'); ylabel('NAD')
ss(4) = subplot(3,2,4)
plot(1:73, squeeze(new_QI_adj(:,:,2,2))-squeeze(old_QI_adj(:,:,2,2)),'o'); title('new-old')
ss(5) = subplot(3,2,5)
plot(1:73, squeeze(new_QI_adj(:,:,3,2)),'o',[1:73],squeeze(old_QI_adj(:,:,3,2)),'k.');  title('Adj QS') ;ylabel('OND')
ss(6) = subplot(3,2,6)
plot(1:73, squeeze(new_QI_adj(:,:,3,2))-squeeze(old_QI_adj(:,:,3,2)),'o'); title('new-old')
linkaxes(ss,'x');
   mt = mtit(['LNDV']);
    set(mt.th,'fontsize',15,'position',[0.5000    1.0700]);

figure; 
ss(1) = subplot(3,2,1)
plot(1:73, squeeze(new_QI_adj(:,:,1,3)),'o',[1:73],squeeze(old_QI_adj(:,:,1,3)),'k.'); legend('SSP0','SSP1','SSP2','SSG3'); title('Adj QS'); ylabel('NAN')
ss(2) = subplot(3,2,2)
plot(1:73, squeeze(new_QI_adj(:,:,1,3))-squeeze(old_QI_adj(:,:,1,3)),'o'); title('new-old')
ss(3) = subplot(3,2,3)
plot(1:73, squeeze(new_QI_adj(:,:,2,3)),'o',[1:73],squeeze(old_QI_adj(:,:,2,3)),'k.');  title('Adj QS'); ylabel('NAD')
ss(4) = subplot(3,2,4)
plot(1:73, squeeze(new_QI_adj(:,:,2,3))-squeeze(old_QI_adj(:,:,2,3)),'o'); title('new-old')
ss(5) = subplot(3,2,5)
plot(1:73, squeeze(new_QI_adj(:,:,3,3)),'o',[1:73],squeeze(old_QI_adj(:,:,3,3)),'k.');  title('Adj QS') ;ylabel('OND')
ss(6) = subplot(3,2,6)
plot(1:73, squeeze(new_QI_adj(:,:,3,3))-squeeze(old_QI_adj(:,:,3,3)),'o'); title('new-old')
linkaxes(ss,'x');
   mt = mtit(['OCEN']);
    set(mt.th,'fontsize',15,'position',[0.5000    1.0700]);
