% read in raw sws file
% compute dark-count subtracted average
% save in growing structure

% add angles to growing structure
% Look at intensity vs angle at different wl.
clear; close('all')
fov_dir = 'C:\case_studies\SWS\FOV data\with_notes\';
fov_files = dir([fov_dir,'*.dat']);
%%
[sws1] = read_sws_raw([fov_dir, fov_files(1).name]);
%%
for f = 2:length(fov_files)
   sws1 = cat_sws_raw(sws1,read_sws_raw([fov_dir,fov_files(f).name]));
end
%%
sws1.Si_dark = mean(sws1.Si_DN(:,sws1.shutter==1),2);
sws1.In_dark = mean(sws1.In_DN(:,sws1.shutter==1),2);
%% 
% figure; lines = plot(sws1.Si_lambda, sws1.Si_DN(:,sws1.shutter==0)-sws1.Si_dark*ones([1,sum(sws1.shutter==0)]),'-'); recolor(lines,[1:sum(sws1.shutter==0)])
%%
figure; subplot(2,1,1); lines = plot(sws1.Si_lambda, sws1.Si_DN(:,sws1.shutter==1),'-'); recolor(lines,[1:sum(sws1.shutter==1)])
subplot(2,1,2); lines = plot(sws1.In_lambda, sws1.In_DN(:,sws1.shutter==1),'-'); recolor(lines,[1:sum(sws1.shutter==1)])
%%
dstr = datestr(sws1.time(1),'yyyy-mm-dd');
FOV1.time_str = {'18:53:45','18:55:00','18:56:00','18:57:00','18:58:00','18:59:00','19:00:00','19:02:00',...
   '19:03:30', '19:04:45','19:06:15','19:07:15','19:08:15','19:09:15','19:10:15','19:11:25','19:12:30',...
   '19:13:30','19:14:30','19:15:50','19:20:00','19:21:00','19:22:00','19:23:00','19:24:00','19:25:00','19:26:00',...
   '19:27:00','19:28:00',...
   '19:29:00', '19:30:00','19:31:00','19:32:00','19:33:00','19:34:00','19:35:00','19:36:00','19:37:00',...
   '19:38:00','19:39:00','19:40:00','19:50:00'};
FOV1.deg = [0,.5,1,1.5,2,2.5,3,3.5,4,4.5,5,6,7,8,9,10,20,30,40,50,0,0,-.5,-1,-1.5,-2,-2.5,-3,-3.5,...
   -4,-4.5,-5,-6,-7,-8,-9,-10,-20,-30,-40,-50];
for t = 1:length(FOV1.time_str)-1
FOV1.time(t) = datenum([dstr, ' ',FOV1.time_str{t}],'yyyy-mm-dd HH:MM:SS');
FOV1.time_stop(t) = datenum([dstr, ' ',FOV1.time_str{t+1}],'yyyy-mm-dd HH:MM:SS');
times = sws1.time>=FOV1.time(t)&sws1.time<FOV1.time_stop(t)&sws1.shutter==0;
darks = sws1.time>=FOV1.time(t)&sws1.time<FOV1.time_stop(t)&sws1.shutter==1;
times = find(times);
if length(times)>2
times([1 end]) = [];
end
darks = find(darks);
if length(darks)>2

darks([1 end]) = [];
end
% FOV1.Si(:,t) = mean(sws1.Si_DN(:,times),2)-sws1.Si_dark;
% FOV1.In(:,t) = mean(sws1.In_DN(:,times),2)-sws1.In_dark;
FOV1.Si(:,t) = mean(sws1.Si_DN(:,times),2)-mean(sws1.Si_DN(:,darks),2);
FOV1.In(:,t) = mean(sws1.In_DN(:,times),2)-mean(sws1.In_DN(:,darks),2);

end
FOV1.Si_norm = FOV1.Si./(max(FOV1.Si,[],2)*ones(size(FOV1.time)));
FOV1.In_norm = FOV1.In./(max(FOV1.In,[],2)*ones(size(FOV1.time)));
FOV1.Si_lambda = sws1.Si_lambda;
FOV1.In_lambda = sws1.In_lambda;
wl_Si = FOV1.Si_lambda>=500 & FOV1.Si_lambda<=1000;
wl_In = FOV1.In_lambda>=1100 & FOV1.In_lambda<=2000;
%%
degs = (FOV1.deg>-1 & FOV1.deg<3);
good = isfinite(FOV1.Si_norm(30,:));
[good_degs,good_ii] = sort(FOV1.deg(good&degs));
trace = FOV1.Si_norm(30,good&degs);
trace = trace(good_ii);

cm = trapz(good_degs,good_degs.*trace)./trapz(good_degs,trace);


figure; lines_Si = semilogy(FOV1.deg-cm, FOV1.Si_norm(wl_Si,:),'.-');
ax1(1) = gca;
lines_Si = recolor(lines_Si,sws1.Si_lambda(wl_Si)); 
cb1 = colorbar;set(get(cb1,'title'),'string','wavelen(nm)');
title('SWS FOV scan 1, Si response vs angle');
ylabel('normalized signal');
xlabel('degrees')

figure; lines_In = semilogy(FOV1.deg-cm, FOV1.In_norm(wl_In,:),'.-');
ax1(2) = gca;
lines_In = recolor(lines_In,sws1.In_lambda(wl_In)); 
cb2 = colorbar;set(get(cb2,'title'),'string','wavelen(nm)');
title('SWS FOV scan 1, InGaAs response vs angle');
ylabel('normalized signal');
xlabel('degrees')
linkaxes(ax1,'x');
xlim([-11,11]);

figure; lines_sws = semilogy(FOV1.deg-cm, [FOV1.Si_norm(wl_Si,:);FOV1.In_norm(wl_In,:)],'.-');
ax1(3) = gca;
lines_sws = recolor(lines_sws,[sws1.Si_lambda(wl_Si);sws1.In_lambda(wl_In)]); 
cb2 = colorbar;set(get(cb2,'title'),'string','wavelen(nm)');
title('SWS FOV scan 1, both detectors response vs angle');
ylabel('normalized signal');
xlabel('degrees');
linkaxes(ax1,'x');
xlim([-11,11]);
%%

