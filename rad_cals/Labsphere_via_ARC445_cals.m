%%
clear; close('all')
ames_path = 'C:\case_studies\SWS\calibration\NASA_ARC_2011_03_07\March7_Monday\ps1_lampA\';
files = dir([ames_path,'*.dat']);
%%

sws = read_sws_raw([ames_path, files(1).name]);
for f = 2:length(files)
sws = cat_sws_raw(sws,read_sws_raw([ames_path, files(f).name]));
end

%%

figure; plot([1:length(sws.time)], max(sws.In_DN,[],1),'-o'); zoom('on');
%%
disp('Zoom into desired region and select OK');
OK = menu('When done zooming select OK.','OK');
xl = round(xlim);
%%
sws_ps1_A = crop_sws_time(sws,[xl(1):xl(2)]);
sws_ps1_A.Si_dark = mean(sws_ps1_A.Si_DN(:,sws_ps1_A.shutter==1),2);
sws_ps1_A.Si_spec = (sws_ps1_A.Si_DN-sws_ps1_A.Si_dark*ones(size(sws_ps1_A.time)))...
   ./(ones(size(sws_ps1_A.Si_lambda))*sws_ps1_A.Si_ms);
sws_ps1_A.mean_Si_spec = mean(sws_ps1_A.Si_spec,2);
sws_ps1_A.In_dark = mean(sws_ps1_A.In_DN(:,sws_ps1_A.shutter==1),2);
sws_ps1_A.In_spec = (sws_ps1_A.In_DN-sws_ps1_A.In_dark*ones(size(sws_ps1_A.time)))...
   ./(ones(size(sws_ps1_A.In_lambda))*sws_ps1_A.In_ms);
sws_ps1_A.mean_In_spec = mean(sws_ps1_A.In_spec,2);
%%
Si_resp =sws_Si_resp_201103;
In_resp =sws_In_resp_201103;
% Responsivity in cts/ms / radiance
% thus cts/ms / [W/(m^2.sr.µm)]

olap.min = 960; olap.max = 1040;
Si_rad = sws_ps1_A.mean_Si_spec./Si_resp(:,2);
In_rad = smooth(In_resp(:,1), sws_ps1_A.mean_In_spec./In_resp(:,2),5);
In_rad2 = smooth(In_resp(:,1),sws_ps1_A.mean_In_spec./In_resp(:,3),4);

Si_rad(Si_resp(:,1)>olap.max)=NaN;
In_rad(In_resp(:,1)<olap.min) = NaN;
In_rad2(In_resp(:,1)<olap.min) = NaN;
% SMOOTH(X,Y,'lowess')
%
Si_lap = Si_resp(:,1)>olap.min & Si_resp(:,1)<olap.max;
In_lap = In_resp(:,1)>olap.min & In_resp(:,1)<olap.max;
pin_In_to_Si = mean(Si_rad(Si_lap))./mean(In_rad2(In_lap));
%
rad = ARC455_20100921;
%Radiance in W/(m^2.sr.µm)

%
Labsphere_ARM_lampA_ps1_ = [[Si_resp(:,1);In_resp(In_resp(:,1)>olap.max,1)], [Si_rad; pin_In_to_Si*In_rad(In_resp(:,1)>olap.max)]];
Labsphere_ARM_lampA_ps1_(isNaN(Labsphere_ARM_lampA_ps1_(:,2)),:) = [];
Labsphere_ARM_lampA_ps1 = [[Si_resp(:,1);In_resp(In_resp(:,1)>olap.max,1)], [Si_rad; pin_In_to_Si*In_rad2(In_resp(:,1)>olap.max)]];
Labsphere_ARM_lampA_ps1(isNaN(Labsphere_ARM_lampA_ps1(:,2)),:) = [];

%
figure; plot(rad.nm, [rad.open,rad.A, rad.B, rad.C,rad.D],'-',...
   Labsphere_ARM_lampA_ps1_(:,1), Labsphere_ARM_lampA_ps1_(:,2), '.k-',...
   Labsphere_ARM_lampA_ps1(:,1), Labsphere_ARM_lampA_ps1(:,2), '.r-');
legend('ARC455 open', 'ARC455 A', 'ARC455 B','ARC455 C','ARC455 D','ARM 10" Labsphere','ARM 10" over peaks')
saveasp(Labsphere_ARM_lampA_ps1, 'Labsphere_ARM_lampA_ps1.m');


%% Now for 4STAR Labsphere
%%
ames_path = 'C:\case_studies\SWS\calibration\NASA_ARC_2011_03_07\March8_Tuesday\4STAR_Labsphere\';
files = dir([ames_path,'*.dat']);
%%

figure;

sws = read_sws_raw([ames_path, files(1).name]);
for f = 2:length(files)
sws = cat_sws_raw(sws,read_sws_raw([ames_path, files(f).name]));
end

%%

figure; plot([1:length(sws.time)], max(sws.In_DN,[],1),'-o'); zoom('on');
%%
disp('Zoom into desired region and select OK');
OK = menu('When done zooming select OK.','OK');
xl = round(xlim);
%%
sws_ps1_A = crop_sws_time(sws,[xl(1):xl(2)]);
sws_ps1_A.Si_dark = mean(sws_ps1_A.Si_DN(:,sws_ps1_A.shutter==1),2);
sws_ps1_A.Si_spec = (sws_ps1_A.Si_DN-sws_ps1_A.Si_dark*ones(size(sws_ps1_A.time)))...
   ./(ones(size(sws_ps1_A.Si_lambda))*sws_ps1_A.Si_ms);
sws_ps1_A.mean_Si_spec = mean(sws_ps1_A.Si_spec,2);
sws_ps1_A.In_dark = mean(sws_ps1_A.In_DN(:,sws_ps1_A.shutter==1),2);
sws_ps1_A.In_spec = (sws_ps1_A.In_DN-sws_ps1_A.In_dark*ones(size(sws_ps1_A.time)))...
   ./(ones(size(sws_ps1_A.In_lambda))*sws_ps1_A.In_ms);
sws_ps1_A.mean_In_spec = mean(sws_ps1_A.In_spec,2);
%%
Si_resp =sws_Si_resp_201103;
In_resp =sws_In_resp_201103;
olap.min = 960; olap.max = 1040;
Si_rad = sws_ps1_A.mean_Si_spec./Si_resp(:,2);
In_rad = smooth(In_resp(:,1), sws_ps1_A.mean_In_spec./In_resp(:,2),5);
In_rad2 = smooth(In_resp(:,1),sws_ps1_A.mean_In_spec./In_resp(:,3),4);
Si_rad(Si_resp(:,1)>olap.max)=NaN;
In_rad(In_resp(:,1)<olap.min) = NaN;
In_rad2(In_resp(:,1)<olap.min) = NaN;
% SMOOTH(X,Y,'lowess')
%
Si_lap = Si_resp(:,1)>olap.min & Si_resp(:,1)<olap.max;
In_lap = In_resp(:,1)>olap.min & In_resp(:,1)<olap.max;
pin_In_to_Si = mean(Si_rad(Si_lap))./mean(In_rad2(In_lap));
%
rad = ARC455_20100921;
%%
Labsphere_4STAR = [[Si_resp(:,1);In_resp(In_resp(:,1)>olap.max,1)], [Si_rad; pin_In_to_Si*In_rad2(In_resp(:,1)>olap.max)]];
Labsphere_4STAR(isNaN(Labsphere_4STAR(:,2)),:) = [];
Labsphere_4STAR_ = [[Si_resp(:,1);In_resp(In_resp(:,1)>olap.max,1)], [Si_rad; pin_In_to_Si*In_rad(In_resp(:,1)>olap.max)]];
Labsphere_4STAR_(isNaN(Labsphere_4STAR_(:,2)),:) = [];
%
figure; plot(rad.nm, [rad.open,rad.A, rad.B, rad.C,rad.D],'-',...
   Labsphere_4STAR(:,1), Labsphere_4STAR(:,2), '.g-',...
   Labsphere_4STAR(:,1), Labsphere_4STAR_(:,2), '.b-',...
   Labsphere_ARM_lampA_ps1(:,1), Labsphere_ARM_lampA_ps1(:,2), '.k-');
legend('ARC455 open', 'ARC455 A', 'ARC455 B','ARC455 C','ARC455 D','4STAR 6" Labsphere peaks','4STAR 6" Labsphere','ARM 10" Labsphere');
%%
pme = saveasp(Labsphere_4STAR, 'Labsphere_4STAR.m');
%%
Labsphere_4STARs = Labsphere_4STAR;
LabSphere.nm = [310:1:2220];
LabSphere.rad = interp1(Labsphere_4STARs(:,1),Labsphere_4STARs(:,2),LabSphere.nm,'pchip');
%%
fid = fopen([pme(1:end-1),'dat'],'w'); 
fprintf(fid,'Source:  4STAR 6" Labsphere via SWS to ARCS 455 \n');
fprintf(fid,'Date:    2010-03-08 \n');
fprintf(fid,'Units:   Radiance in W/(m^2.sr.um) \n');
fprintf(fid,'Source:  4STAR 6" Labsphere via SWS to ARCS 455 \n');
fprintf(fid,'Source:  6" sphere, 2" opening \n');
fprintf(fid,'Dist:  5.5" \n');
fprintf(fid,'nm ,   radiance \n');
fprintf(fid,'%4.2f, %4.4g \n',Labsphere_4STAR');
fclose(fid);
%%
fid = fopen(['C:\mlib\local\rad_cals\Labsphere_4STAR_nm.dat'],'w'); 
fprintf(fid,'Source:  4STAR 6" Labsphere via SWS to ARCS 455 \n');
fprintf(fid,'Date:    2010-03-08 \n');
fprintf(fid,'Units:   Radiance in mW/(m^2.sr.nm) \n');
fprintf(fid,'Source:  4STAR 6" Labsphere via SWS to ARCS 455 \n');
fprintf(fid,'Source:  6" sphere, 2" opening \n');
fprintf(fid,'Dist:  5.5" \n');
fprintf(fid,'nm ,   radiance \n');
fprintf(fid,'%4.2f, %4.5g \n',[LabSphere.nm; LabSphere.rad]);
fclose(fid);
