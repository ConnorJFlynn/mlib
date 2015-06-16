mfr = ancload(getfullname('sgpmfrsr*.cdf','mfraod'));
good = mfr.vars.direct_normal_narrowband_filter1.data>0&mfr.vars.direct_normal_narrowband_filter2.data>0&...
mfr.vars.direct_normal_narrowband_filter3.data>0&mfr.vars.direct_normal_narrowband_filter4.data>0&...
mfr.vars.direct_normal_narrowband_filter5.data>0;
T = [mfr.vars.direct_normal_narrowband_filter1.data(good)./sscanf(mfr.atts.filter1_TOA_direct_normal.data,'%f');...
mfr.vars.direct_normal_narrowband_filter2.data(good)./sscanf(mfr.atts.filter2_TOA_direct_normal.data,'%f');...
mfr.vars.direct_normal_narrowband_filter3.data(good)./sscanf(mfr.atts.filter3_TOA_direct_normal.data,'%f');...
mfr.vars.direct_normal_narrowband_filter4.data(good)./sscanf(mfr.atts.filter4_TOA_direct_normal.data,'%f');...
mfr.vars.direct_normal_narrowband_filter5.data(good)./sscanf(mfr.atts.filter5_TOA_direct_normal.data,'%f')];
%%
subsample = 20;
T_ = T(:,[1:subsample:end]);
[t,n] = size(T_);
in_time = mfr.time(good);
sub_time = in_time(1:subsample:end);
am = mfr.vars.airmass.data(good);
in_am = am(1:subsample:end);
tau_ = (-log(T_));
figure; plot(serial2doy(sub_time),tau_' ,'.');
T_ = tau_
%%

% Seems pointless to compute svd with only 5 eigenvectors, so I'm trying
% swapping the time and variable coordinates. 
tic
covT = cov(T_);

[U,S] = svd(covT);
L = diag(S);
toc
%%

for k = n-1:-1:1
   Lo(k) = sum(L(k+1:n));
end

REk     = sqrt( Lo ./ (t.*(n-(1:(n-1)))) );
IND     = REk ./ (n-(1:(n-1))).^2;
npcs    = find(min(IND(1:floor(length(REk)./2))) == IND(1:floor(length(REk)./2)))
figure; semilogy([1:length(IND)],IND,'-b.',npcs,IND(npcs),'ro');
title(['Subsample: ',num2str(subsample), ',  npcs:',num2str(npcs)]);
%%
npcs    = find(min(IND(1:floor(length(REk)./2))) == IND(1:floor(length(REk)./2)));
figure; 
%%
% Compute coefs

M = mean(T_);
coefs = [(T_ - ones([t,1])*M)*U(:,1:npcs)]';
ts = U(:,1:npcs);
new_t_ = ts*coefs + M'*ones([1,t]);
%%

ax1(1)= subplot(2,1,1);
plot(serial2doy(sub_time),tau_','k-');
legend('1','2','3','4','5');
hold('on');
plot(serial2doy(sub_time),new_t_ ,'.');

title(['Number PCs: ',num2str(npcs)]);
ax1(2) = subplot(2,1,2);
plot(serial2doy(sub_time),tau_'-new_t_ ,'-');

linkaxes(ax1,'x')

%%  !
T_ = T';
[t,n] = size(T_);
in_time = mfr.time(good);
sub_time = in_time;
am = mfr.vars.airmass.data(good);
in_am = am;
tau_ = (-log(T_)./(in_am'*ones([1,5])));
figure; plot(serial2doy(sub_time),tau_ ,'.');
T_ = tau_;
%%

% Seems pointless to compute svd with only 5 eigenvectors, so I'm trying
% swapping the time and variable coordinates. 
tic
covT = cov(T_);

[U,S] = svd(covT);
L = diag(S);
toc
%%
Lo=[];
for k = n-1:-1:1
   Lo(k) = sum(L(k+1:n));
end
%%

REk     = sqrt( Lo ./ (t.*(n-(1:(n-1)))) );
IND     = REk ./ (n-(1:(n-1))).^2;
npcs    = find(min(IND(1:floor(length(REk)./2))) == IND(1:floor(length(REk)./2)));
figure; semilogy([1:length(IND)],IND,'-b.',npcs,IND(npcs),'ro');
title(['Subsample: ',num2str(subsample), ',  npcs:',num2str(npcs)]);
%%
% Compute coefs
npcs=1;
M = mean(T_);
coefs = [(T_ - ones([t,1])*M)*U(:,1:npcs)]';
new_t_ = U(:,1:npcs)*coefs + M'*ones([1,t]);
%%
figure; 
ax(1) = subplot(2,1,1);
plot(serial2doy(sub_time),tau_','k.');
hold('on');
plot(serial2doy(sub_time),new_t_ ,'.');
legend('1','2','3','4','5');
hold('off');
ax(2) = subplot(2,1,2);
plot(serial2doy(sub_time),tau_'-new_t_ ,'.');
linkaxes(ax,'x')
legend('1','2','3','4','5');


