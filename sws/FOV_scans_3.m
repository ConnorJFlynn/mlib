% read in raw sws file
% compute dark-count subtracted average
% save in growing structure

% add angles to growing structure
% Look at intensity vs angle at different wl.
clear; close('all')
fov_dir = 'C:\case_studies\SWS\High Dynamic Range data\';
fov_files = dir([fov_dir,'*.dat']);
FOV1.deg = [50,45,40,35,30,25,20,15,10,9,8,7,6,5,4.5,4,3.5,3,2.5,2,1.5,1,0.5];
FOV1.deg = [-1*(FOV1.deg),0,fliplr(FOV1.deg)]; 

%%
[sws1] = read_sws_raw([fov_dir, fov_files(end).name]);
%%

dark = sws1.shutter==1;
FOV1.Si_lambda = sws1.Si_lambda;
FOV1.In_lambda = sws1.In_lambda;
FOV1.time(length(FOV1.deg)) = mean(sws1.time(~dark));
dark_ii = find(dark);
dark_ii([1 end]) = [];
light = sws1.shutter==0;
light_ii = find(light);
light_ii([1 end]) = [];
FOV1.Si_dark(:,length(FOV1.deg)) = mean(sws1.Si_DN(:,dark_ii),2)./mean(sws1.Si_ms(dark_ii));
FOV1.In_dark(:,length(FOV1.deg)) = mean(sws1.In_DN(:,dark_ii),2)./mean(sws1.In_ms(dark_ii));
FOV1.Si(:,length(FOV1.deg)) = mean(sws1.Si_DN(:,light_ii),2)./mean(sws1.Si_ms(light_ii));
FOV1.In(:,length(FOV1.deg)) = mean(sws1.In_DN(:,light_ii),2)./mean(sws1.In_ms(light_ii));


%%
for f = (length(fov_files)-1):-1:1
   sws2 = read_sws_raw([fov_dir,fov_files(f).name]);
   
   dark = sws2.shutter==1;
FOV1.time(f) = mean(sws2.time(~dark));
dark_ii = find(dark);
dark_ii([1 end]) = [];
light = sws2.shutter==0;
light_ii = find(light);
light_ii([1 end]) = [];
FOV1.Si_dark(:,f) = mean(sws2.Si_DN(:,dark_ii),2)./mean(sws1.Si_ms(dark_ii));
FOV1.In_dark(:,f) = mean(sws2.In_DN(:,dark_ii),2)./mean(sws1.In_ms(dark_ii));
FOV1.Si(:,f) = mean(sws2.Si_DN(:,light_ii),2)./mean(sws1.Si_ms(light_ii));
FOV1.In(:,f) = mean(sws2.In_DN(:,light_ii),2)./mean(sws1.In_ms(light_ii));
   
   sws1 = cat_sws_raw(sws1,sws2);
end
%%
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

