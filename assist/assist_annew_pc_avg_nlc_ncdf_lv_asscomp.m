function assist = assist_annew_pc_avg_nlc % ASSIST annew
% Apply processing step by step, confirming most recent LR Tech processing
%
% Review derived products
% Fine details to address:
% Apply NLC
%  New NLC technique: (from Dave Turner, Private Comm 2012)
%  (a) capture the sign of the Vdc value at ZPD,
%  (b) convert the interf to a spectrum,
%  (c) transform the complex spectrum into a magnitude spectrum,
%  (d) convert the magnitude spectrum back to an interf,
%  (e) determine the magnitude of the Vdc at ZPD, and
%  (f) assign the magnitude the sign of the value determined in step (a).
% This is the Vdc value that should be used in the nonlinearity correction given in BobK's paper.
% Naturally, the lab data (where the an2 and cold/hot ZPD values are determined) needs to be processed
% with this algorithm as does the sky data (i.e., need to use consistent processing).


% Refine effective wavenumber for chA and chB
% Cavity effect on emissivity
% Back-reflected radiance
% FFOV effects on line shape

% % Sept 28, 2011, modified April 18, 2014
% ASSIST corrections:
% 1. determination location, sign, and absolute magnitude of ZPD
% 2. Flip shift, FFT shift
% 3. Take FFT to yield uncalibrated complex spectra.
% 3. Wavenumber definition MUST be based on ZPD being centered within a cell
% 4. NLC (using DT magnitude and phase ZPD)
% 5. FFOV
% 6. non-unity emit
% 7. self-emit
% 8. derived products
% 9. LBLRTM: find effective laser WL to reduce skew in difference plots
% 10. LBLRTM: adjust FFOV to reduce residuals near sharp lines
% 11. Repeat/validate all derived products

% Later work:
% Where/how to apply Penny's responsivity screen.
% Assess whether adding the quadratic term improves the ASSIST AERI
% agreement at SGP.
% Need LBL runs for wavenumber registration
% (Explore flipping Reverse Igrams to yield R_,and see how
% different cals are for F, R, and R_.)
% Explore use of measured DC offset instead of modeled DC offset
% Explore Griffith NLC approach
%%

emis = load('emis.mat');
emis = repack_edgar(emis);

% nlc = getfullname__('nlc.*.mat','nlc','Select NLC correction file');
% if exist(nlc,'file')
%    nlc = load(nlc);
% end

folder_path = 'C:\Users\Lind256\Documents\ASSIST\data\assist_raw_from_finland\';
nlc =load([folder_path,'nlc.20110101_0150.mat']);
zip_dir = [folder_path, 'Zipped_Results\'];
temp_dir = [folder_path, 'temp\'];
ass_dir = [folder_path, 'assist_conc_files\'];
res_dir = [folder_path,'Results\']; 
rdir_in = [folder_path '*\**\*.piz'];
list = rdir(rdir_in);
proc_path = 'C:\Users\Lind256\Documents\ASSIST\data\Sept-2014\tmpassistM1.00.20140911.000401.raw.piz\';
rdir_pr = [proc_path '*.piz'];
proc_list = rdir(rdir_pr);

%size(proc_list)
%Loop through all the files
tic
for r_name = 1 : numel(list)

    proc_dir = [folder_path,'To-be-processed\'];
    if ~exist(proc_dir,'dir')
        mkdir(proc_dir);
    end
    if ~exist(res_dir,'dir')
        mkdir(res_dir);
    end
    if ~exist(temp_dir,'dir')
        mkdir(temp_dir);
    end

    label = list(r_name).name;
    unzipped = unzip(list(r_name).name, proc_dir);

    rdir_in = [proc_dir '*_ann_*.csv'];
    raw_files = rdir(rdir_in);
    size(raw_files);
% pick = menu('Process all files or just selected files?','All','Selected');
% pause(.01);
% if pick==1
%    raw_files = getfullname('*_ann_*.*','assist_dir','Select a file in the directory to bundle.');
%    if ~iscell(raw_files)
%       raw_files = {raw_files};
%    end
%    [pname, fname, ext] = fileparts(raw_files{1});
%    pname = [pname, filesep];
%    catdir = [pname, 'catdir',filesep];
%    if ~exist(catdir,'dir')
%       mkdir(catdir);
%    end
%    raw_files = dir([pname,'*_ann_*.*']);
%    raw_files = [raw_files;dir([pname,'*.nc'])];
% else
%    rawfiles = getfullname('*_ann_*.csv','assist_dir');
%    if ~iscell(rawfiles)
%       rawfiles = {rawfiles};
%    end
%    for L = length(rawfiles):-1:1
%       raw_files(L).name = rawfiles{L};
%    end
%    [pname, ~, ~] = fileparts(raw_files(1).name); pname = [pname, filesep];
% end
% while ~exist('pname','var')||~exist(pname, 'dir')
%     [pname] = getdir([],'assist');
% end
% raw_files = dir([pname, '*_ann_*.csv']);
%raw_files_ = rdir('*_ann_*.*')

N = length(raw_files);
n = 1;
% tic
while n<=N-2
   
   [pname,fstem,ext] = fileparts(raw_files(n).name); pname = [pname, filesep];
   [tok,metsf] = strtok(fliplr(fstem),'_');[tok,metsf] = strtok(metsf,'_');
   dstem{1} = fliplr(metsf);
   [~,fstem,ext] = fileparts(raw_files(n+1).name);
   [tok,metsf] = strtok(fliplr(fstem),'_');[tok,metsf] = strtok(metsf,'_');
   dstem{2} = fliplr(metsf);
   [~,fstem,ext] = fileparts(raw_files(n+2).name);
   [tok,metsf] = strtok(fliplr(fstem),'_');[tok,metsf] = strtok(metsf,'_');
   dstem{3} = fliplr(metsf);
   disp([num2str(N-n), ' calibration series to be read...'])
   if ~(...
         ((exist([pname, dstem{1},'ann_HC.csv'],'file')||(exist([pname, dstem{1},'ann_HC.xls'],'file')) && ...
         (exist([pname, dstem{1},'chA_HC.nc'],'file')|| exist([pname, dstem{1},'chA_HC.mat'],'file'))&& ...
         (exist([pname, dstem{1},'chB_HC.nc'],'file') || exist([pname, dstem{1},'chB_HC.mat'],'file')) && ...
         (exist([pname, dstem{2},'ann_SKY.csv'],'file')||exist([pname, dstem{2},'ann_SKY.xls'],'file')) && ...
         (exist([pname, dstem{2},'chA_SKY.nc'],'file')||exist([pname, dstem{2},'chA_SKY.mat'],'file')) && ...
         (exist([pname, dstem{2},'chB_SKY.nc'],'file')||exist([pname, dstem{2},'chB_SKY.mat'],'file')) && ...
         (exist([pname, dstem{3},'ann_CH.csv'],'file')||exist([pname, dstem{3},'ann_CH.xls'],'file')) && ...
         (exist([pname, dstem{3},'chA_CH.nc'],'file')||exist([pname, dstem{3},'chA_CH.mat'],'file')) && ...
         (exist([pname, dstem{3},'chB_CH.nc'],'file'))||exist([pname, dstem{3},'chB_CH.mat'],'file'))) ...
         || ...
         ((exist([pname, dstem{1},'ann_CH.csv'],'file')||exist([pname, dstem{1},'ann_CH.xls'],'file')) && ...
         (exist([pname, dstem{1},'chA_CH.nc'],'file')||exist([pname, dstem{1},'chA_CH.mat'],'file')) && ...
         (exist([pname, dstem{1},'chB_CH.nc'],'file')||exist([pname, dstem{1},'chB_CH.mat'],'file')) && ...
         (exist([pname, dstem{2},'ann_SKY.csv'],'file')||exist([pname, dstem{2},'ann_SKY.xls'],'file')) && ...
         (exist([pname, dstem{2},'chA_SKY.nc'],'file')||exist([pname, dstem{2},'chA_SKY.mat'],'file')) && ...
         (exist([pname, dstem{2},'chB_SKY.nc'],'file')||exist([pname, dstem{2},'chB_SKY.mat'],'file')) && ...
         (exist([pname, dstem{3},'ann_HC.csv'],'file')||exist([pname, dstem{3},'ann_HC.xls'],'file')) && ...
         (exist([pname, dstem{3},'chA_HC.nc'],'file')||exist([pname, dstem{3},'chA_HC.mat'],'file')) && ...
         (exist([pname, dstem{3},'chA_HC.nc'],'file')||exist([pname, dstem{3},'chA_HC.mat'],'file'))) ...
         || ...
         ((exist([pname, dstem{1},'ann_HC.csv'],'file')||(exist([pname, dstem{1},'ann_HC.xls'],'file')) && ...
         (exist([pname, dstem{1},'chA_HC.nc'],'file')|| exist([pname, dstem{1},'chA_HC.mat'],'file'))&& ...
         (exist([pname, dstem{1},'chB_HC.nc'],'file') || exist([pname, dstem{1},'chB_HC.mat'],'file')) && ...
         (exist([pname, dstem{2},'ann_SCENE.csv'],'file')||exist([pname, dstem{2},'ann_SCENE.xls'],'file')) && ...
         (exist([pname, dstem{2},'chA_SCENE.nc'],'file')||exist([pname, dstem{2},'chA_SCENE.mat'],'file')) && ...
         (exist([pname, dstem{2},'chB_SCENE.nc'],'file')||exist([pname, dstem{2},'chB_SCENE.mat'],'file')) && ...
         (exist([pname, dstem{3},'ann_CH.csv'],'file')||exist([pname, dstem{3},'ann_CH.xls'],'file')) && ...
         (exist([pname, dstem{3},'chA_CH.nc'],'file')||exist([pname, dstem{3},'chA_CH.mat'],'file')) && ...
         (exist([pname, dstem{3},'chB_CH.nc'],'file'))||exist([pname, dstem{3},'chB_CH.mat'],'file'))) ...
         || ...
         ((exist([pname, dstem{1},'ann_CH.csv'],'file')||exist([pname, dstem{1},'ann_CH.xls'],'file')) && ...
         (exist([pname, dstem{1},'chA_CH.nc'],'file')||exist([pname, dstem{1},'chA_CH.mat'],'file')) && ...
         (exist([pname, dstem{1},'chB_CH.nc'],'file')||exist([pname, dstem{1},'chB_CH.mat'],'file')) && ...
         (exist([pname, dstem{2},'ann_SCENE.csv'],'file')||exist([pname, dstem{2},'ann_SCENE.xls'],'file')) && ...
         (exist([pname, dstem{2},'chA_SCENE.nc'],'file')||exist([pname, dstem{2},'chA_SCENE.mat'],'file')) && ...
         (exist([pname, dstem{2},'chB_SCENE.nc'],'file')||exist([pname, dstem{2},'chB_SCENE.mat'],'file')) && ...
         (exist([pname, dstem{3},'ann_HC.csv'],'file')||exist([pname, dstem{3},'ann_HC.xls'],'file')) && ...
         (exist([pname, dstem{3},'chA_HC.nc'],'file')||exist([pname, dstem{3},'chA_HC.mat'],'file')) && ...
         (exist([pname, dstem{3},'chA_HC.nc'],'file')||exist([pname, dstem{3},'chA_HC.mat'],'file'))) ...
         || ...
         ((exist([pname, dstem{1},'ann_HC.csv'],'file')||(exist([pname, dstem{1},'ann_HC.xls'],'file')) && ...
         (exist([pname, dstem{1},'chA_HC.nc'],'file')|| exist([pname, dstem{1},'chA_HC.mat'],'file'))&& ...
         (exist([pname, dstem{1},'chB_HC.nc'],'file') || exist([pname, dstem{1},'chB_HC.mat'],'file')) && ...
         (exist([pname, dstem{2},'ann_SCENES.csv'],'file')||exist([pname, dstem{2},'ann_SCENES.xls'],'file')) && ...
         (exist([pname, dstem{2},'chA_SCENES.nc'],'file')||exist([pname, dstem{2},'chA_SCENES.mat'],'file')) && ...
         (exist([pname, dstem{2},'chB_SCENES.nc'],'file')||exist([pname, dstem{2},'chB_SCENES.mat'],'file')) && ...
         (exist([pname, dstem{3},'ann_CH.csv'],'file')||exist([pname, dstem{3},'ann_CH.xls'],'file')) && ...
         (exist([pname, dstem{3},'chA_CH.nc'],'file')||exist([pname, dstem{3},'chA_CH.mat'],'file')) && ...
         (exist([pname, dstem{3},'chB_CH.nc'],'file'))||exist([pname, dstem{3},'chB_CH.mat'],'file'))) ...
         || ...
         ((exist([pname, dstem{1},'ann_CH.csv'],'file')||exist([pname, dstem{1},'ann_CH.xls'],'file')) && ...
         (exist([pname, dstem{1},'chA_CH.nc'],'file')||exist([pname, dstem{1},'chA_CH.mat'],'file')) && ...
         (exist([pname, dstem{1},'chB_CH.nc'],'file')||exist([pname, dstem{1},'chB_CH.mat'],'file')) && ...
         (exist([pname, dstem{2},'ann_SCENES.csv'],'file')||exist([pname, dstem{2},'ann_SCENES.xls'],'file')) && ...
         (exist([pname, dstem{2},'chA_SCENES.nc'],'file')||exist([pname, dstem{2},'chA_SCENES.mat'],'file')) && ...
         (exist([pname, dstem{2},'chB_SCENES.nc'],'file')||exist([pname, dstem{2},'chB_SCENES.mat'],'file')) && ...
         (exist([pname, dstem{3},'ann_HC.csv'],'file')||exist([pname, dstem{3},'ann_HC.xls'],'file')) && ...
         (exist([pname, dstem{3},'chA_HC.nc'],'file')||exist([pname, dstem{3},'chA_HC.mat'],'file')) && ...
         (exist([pname, dstem{3},'chA_HC.nc'],'file')||exist([pname, dstem{3},'chA_HC.mat'],'file'))) ...
         )
      n = n + 1;
      disp(['Not a cal sequence, checking next triplet.']);
   else
      
      if exist([pname, dstem{1},'ann_HC.csv'],'file')
         disp(['HC _ Scene _ CH calibration sequence']);
         disp([dstem{1},'*_HC.*']);
         disp([dstem{2},'*_SCENE.*']);
         disp([dstem{3},'*_CH.*']);
      else
         disp(['CH _ Scene _ HC calibration sequence']);
         disp([dstem{1},'*_CH.*']);
         disp([dstem{2},'*_SCENE.*']);
         disp([dstem{3},'*_HC.*']);
      end
      disp([' '])
      % Calibrate this sequence...
      if exist([pname, dstem{2},'chA_SKY.nc'],'file')||...
            exist([pname, dstem{2},'chA_SCENE.nc'],'file')||...
            exist([pname, dstem{2},'chA_SCENES.nc'],'file')
         seq = load_cal_sequence_nc(pname, dstem);
      else
         seq = load_cal_sequence_mat(pname, dstem);
      end
      seq.emis = emis;
      seq = proc_cal_sequence(seq,nlc, dstem);
%       a_ = seq.chA.cxs.x>535&seq.chA.cxs.x<1840;
%       b_ = seq.chB.cxs.x>1830&seq.chB.cxs.x<3500;o
      
%       figure(8); these = semilogy(seq.chA.cxs.x(a_), mean(seq.chA.mrad.y(seq.logi.Sky,a_)),'r-',seq.chB.cxs.x(b_), mean(seq.chB.mrad.y(seq.logi.Sky,b_)),'b-',...
%          seq.chA.cxs.x(a_), mean(seq.chA.mrad.y(~seq.logi.Sky,a_)),'k-',seq.chB.cxs.x(b_), mean(seq.chB.mrad.y(~seq.logi.Sky,b_)),'c-');
%       
%       ax(1) = gca;
%       figure(9); those =plot(seq.chA.cxs.x(a_), chA.Tb_real_mean_sky -273.15,'r-',...
%          seq.chA.cxs.x(a_), chA.mean_Tb_real_sky -273.15,'b-',...
%          seq.chB.cxs.x(b_), chB.Tb_real_mean_sky-273.15,'r-', ...
%          seq.chB.cxs.x(b_), chB.mean_Tb_real_sky-273.15,'b-');
%       set(those(3),'color',[1,.45,.45]); set(those(4), 'color',[.45,.45,1]);
%       legend('Tb real mean','mean Tb')
%       xlabel('wavenumber [1/cm]');
%       ylabel('brightness temperature C');
%       ax(2) = gca;
%       linkaxes(ax,'x');
      
      seq = cut_seq(seq);
%       a_ = seq.chA.mrad.x>535&seq.chA.mrad.x<1840;
%       b_ = seq.chB.mrad.x>1830&seq.chA.mrad.x<3500;
%       figure(10); semilogy(seq.chA.mrad.x(a_), mean(seq.chA.mrad.y(seq.isSky,a_)),'r-',seq.chB.mrad.x(b_), mean(seq.chB.mrad.y(seq.isSky,b_)),'b-',...
%          seq.chA.mrad.x(a_), mean(seq.chA.mrad.y(~seq.isSky,a_)),'k-',seq.chB.mrad.x(b_), mean(seq.chB.mrad.y(~seq.isSky,b_)),'c-');
%       ax(3) = gca;
%       figure(11); plot(seq.chA.mrad.x(a_), mean(seq.chA.T_bt(seq.isSky,a_)-273.15),'r-',seq.chB.mrad.x(b_), mean(seq.chB.T_bt(seq.isSky,b_)-273.15),'-');
%       legend('chA T_b','chB T_b');
%       xlabel('wavenumber [1/cm]');
%       ylabel('brightness temperature C');
%       ax(4) = gca;
%       linkaxes(ax,'x');
      if exist('assist','var')
         %           assist.degraded = cat_ntimes(assist.degraded, seq.degraded, assist.down.time, seq.down.time);
         %           assist.down = cat_ntimes(assist.down, seq.down);
         assist = cat_ntimes(assist,seq);
      else
         assist = seq;
         clear seq
      end
      delete([pname, dstem{1},'*.*']);
      delete([pname, dstem{2},'*.*']);
      n  = n + 2;
      
      
   end
%      delete([pname, dstem{1},'*.*']);
%      delete([pname, dstem{2},'*.*']);
 end

%rmdir(proc_dir,'s');
[~,re_name,re_ext] = fileparts(label);
re_name = strrep(re_name,'tmpassistrawM1','tmpassistM1');
re_name = strrep(re_name, '_RAW','_PROCESSED');
re_name_mat = strrep(re_name,'_PROCESSED','_PROC_MAT'); 
zipf_name = [re_name, re_ext];
mat_zipf_name = [re_name_mat, re_ext];

proc_unz = unzip([proc_list(r_name).name],temp_dir);

listCSV=dir([temp_dir,'*_ExtraCSV*.csv']);
listCSV(size(listCSV,1)).name=[];

for i = 1:size(listCSV,1)-1    
%     movefile([temp_dir,listCSV.name],res_dir);
    movefile([temp_dir,listCSV(i).name],res_dir);
end

delete([temp_dir,'*_ann_*.csv']);
delete([temp_dir,'*_hkp_*.csv']);
delete([temp_dir,'*.nc']);

% movefile([temp_dir,'*_ExtraCSV*.csv'],res_dir);
% rmdir(temp_dir,'s');
zips(1) = {[res_dir,'*.nc']};
zips(2) = {[res_dir,'*ExtraCSV*.csv']};
zipped = zip([res_dir,strrep(zipf_name, '.piz','.zip')],zips);
%zipped = zip([res_dir,strrep(zipf_name, '.piz','.zip')],[res_dir,'*.nc']);
mat_zipped = zip([res_dir,strrep(mat_zipf_name, '.piz','.zip')],[res_dir,'*.mat']);

ass_name = strrep(re_name,'_PROCESSED','_PROC_assist.mat');
save([ass_dir,ass_name],'-struct','assist');
clear assist
movefile([res_dir,strrep(zipf_name, '.piz','.zip')],[zip_dir,strrep(zipf_name, '.piz','.zip')]);
movefile([res_dir,strrep(mat_zipf_name, '.piz','.zip')],[zip_dir,strrep(mat_zipf_name, '.piz','.zip')]);
delete([res_dir,'*.*']);
%rmdir(res_dir,'s');
toc
end
toc

%save([pname, filesep,'assist_degraded.mat'],'-struct','assist');

% chA = assist.chA.mrad.x>550 & assist.chA.mrad.x<1830;
% chB = assist.chB.mrad.x>1800&assist.chB.mrad.x<3200;
% sky = assist.isSky;
%
% aeri = ancload(getfullname('*sgpaerisummaryC1*.cdf','aeri'));
% xl = aeri.time>assist.time(1)&aeri.time<assist.time(end);
% aericha = ancload(getfullname('*sgpaeri*.cdf','aeri'));
% aericha = ancsift(aericha, aericha.dims.time, xl);
% %%
% figure; plot(aericha.vars.wnum.data, mean(aericha.vars.mean_rad.data,2),'k-',(1329.76./1329.93).*assist.chA.mrad.x(chA), mean(assist.chA.mrad.y(sky,chA)),'r-');
% title(['AERI and ASSIST sky radiances: ',datestr(aericha.time(1),'mmm dd yyyy')]);
% legend('AERI','ASSIST')
% %%
%
% figure; plot(aeri.vars.wnumsum11.data, mean(aeri.vars.SkyRadianceSpectralAveragesCh1.data(:,xl),2),'b-',...
%     aeri.vars.wnumsum12.data, mean(aeri.vars.SkyRadianceSpectralAveragesCh2.data(:,xl),2),'k-');
% title('AERI degraded radiances')
% %%
%
% figure;lines = plot((1329.76./1329.93).*assist.chA.mrad.x(chA), mean(assist.chA.mrad.y(sky,chA)),'r-',...
%     (2259.34./2259.63).*assist.chB.mrad.x(chB), mean(assist.chB.mrad.y(sky,chB)),'b-');
% %%
% figure;lines = plot((1329.76./1329.93).*assist.chA.mrad.x(chA), mean(assist.chA.T_bt(sky,chA)),'r-',...
%     (2259.34./2259.63).*assist.chB.mrad.x(chB), mean(assist.chB.T_bt(sky,chB)),'b-');
% %%
% figure; plot(aeri.vars.wnumsum11.data, mean(aeri.vars.SkyRadianceSpectralAveragesCh1.data(:,xl),2),'b-',...
%     aeri.vars.wnumsum12.data, mean(aeri.vars.SkyRadianceSpectralAveragesCh2.data(:,xl),2),'k-');
% title('AERI degraded radiances')
% %%
% figure; plot(aeri.vars.wnumsum13.data, mean(aeri.vars.SkyBrightnessTempSpectralAveragesCh1.data(:,xl),2),'b-',...
%     aeri.vars.wnumsum14.data, mean(aeri.vars.SkyBrightnessTempSpectralAveragesCh2.data(:,xl),2),'k-');
% title('AERI degraded brightness temperatures')
%
% %%
% figure;lines = plot(assist.chA.mrad.x(chA), mean(assist.chA.mrad.y(sky,chA)),'r-',aeri.vars.wnumsum11.data, mean(aeri.vars.SkyRadianceSpectralAveragesCh1.data(:,xl),2),'b-');
% legend('ASSIST','AERI')
% %%
% figure;lines = plot(assist.chB.mrad.x(chB), mean(assist.chB.mrad.y(sky,chB)),'g-',aeri.vars.wnumsum12.data, mean(aeri.vars.SkyRadianceSpectralAveragesCh2.data(:,xl),2),'k-');
% legend('ASSIST','AERI')
% %%
% figure;lines = plot(assist.chA.mrad.x(chA), mean(assist.chA.T_bt(sky,chA)),'r-',aeri.vars.wnumsum13.data, mean(aeri.vars.SkyBrightnessTempSpectralAveragesCh1.data(:,xl),2),'b-');
% legend('ASSIST','AERI')
% title('Brightness temperatures')
% %%
% figure;lines = plot(assist.chB.mrad.x(chB), mean(assist.chB.T_bt(sky,chB)),'g-',aeri.vars.wnumsum14.data, mean(aeri.vars.SkyBrightnessTempSpectralAveragesCh2.data(:,xl),2),'k-');
% legend('ASSIST','AERI')
% title('brightess temperatures')
% %%
% % assist.chA.spc.y = assist.chA.spc__.y;
% % assist.chB.spc.y = assist.chB.spc__.y;
% %
% % figure; plot(assist.chA.cxs.x, [mean(assist.chA.spc.y(assist.logi.A,:));mean(assist.chA.spc_.y(assist.logi.A,:));...
% %     mean(assist.chA.spc__.y(assist.logi.A,:));],'-');
% %
% % assist.chA.mrad.y = assist.chA.spc.y;
% % assist.chB.mrad.y = assist.chB.spc.y;
%
% % in = find(assist.logi.Sky_F);
% % [Cnu_,c2 ,c4] = ApplyFFOVCorr(assist.chA.cxs.x, assist.chA.spc.y(in,:),0.0225);
%
% %%
% % [rad,wnp,deltaC1,deltaC2] = ffovcmr(nu,Cm,fovHalfAngle,flagFFOVerr,XMAX,WNB);
% %
% % figure;
% % sx(1) = subplot(2,1,1);
% % plot(assist.chA.cxs.x, mean(assist.chA.spc.y(assist.logi.Sky_F,:)),'-',assist.chA.cxs.x, mean(assist.chA.mrad.y(assist.logi.Sky_F,:)),'-')
% % sx(2) = subplot(2,1,2);
% % plot(assist.chA.cxs.x, mean(assist.chA.spc.y(assist.logi.Sky_F,:))-mean(assist.chA.mrad.y(assist.logi.Sky_F,:)),'-')
% % linkaxes(sx,'x');
% % zoom('on')
% %%
%
%
% % downsample to N mono-directional scans
% N = 6; % downsample over 6
% %
% [rows,cols]= size(assist.time);
% retime = zeros([2.*N.*rows,cols./(2.*N)]);
% retime(:) = assist.time;
% %
% % retime =
% assist.down.time = retime(1,:);
% assist.down.isSky = downsample(assist.logi.Sky,2.*N)>0;
% assist.down.isHBB = downsample(assist.logi.H,2.*N)>0;
% assist.down.isABB = downsample(assist.logi.A,2.*N)>0;
%
% assist.down.Sky_ii = find(assist.down.isSky);
% assist.down.HBB_ii = find(assist.down.isHBB);
% assist.down.ABB_ii = find(assist.down.isABB);
%
% assist.down.chA.mrad.x = assist.chA.cxs.x;
% assist.down.chB.mrad.x = assist.chB.cxs.x;
% %Forward
% % Ch A
% assist.down.chA.ifg.F = downsample(assist.chA.y(assist.logi.F,:),N);
% assist.down.chA.cxs.F = downsample(assist.chA.cxs.y(assist.logi.F,:),N);
% assist.down.chA.mrad.F = downsample(assist.chA.mrad.y(assist.logi.F,:),N);
% assist.down.chA.var.F = downvariance(assist.chA.mrad.y(assist.logi.F,:),N);
% % Ch B
% assist.down.chB.ifg.F = downsample(assist.chB.y(assist.logi.F,:),N);
% assist.down.chB.cxs.F = downsample(assist.chB.cxs.y(assist.logi.F,:),N);
% assist.down.chB.mrad.F = downsample(assist.chB.mrad.y(assist.logi.F,:),N);
% assist.down.chB.var.F = downvariance(assist.chB.mrad.y(assist.logi.F,:),N);
%
% % Reverse
% % Ch A
% assist.down.chA.ifg.R = downsample(assist.chA.y(assist.logi.R,:),N);
% assist.down.chA.cxs.R = downsample(assist.chA.cxs.y(assist.logi.R,:),N);
% assist.down.chA.mrad.R = downsample(assist.chA.mrad.y(assist.logi.R,:),N);
% assist.down.chA.var.R = downvariance(assist.chA.mrad.y(assist.logi.R,:),N);
% % Ch B
% assist.down.chB.ifg.R = downsample(assist.chB.y(assist.logi.R,:),N);
% assist.down.chB.cxs.R = downsample(assist.chB.cxs.y(assist.logi.R,:),N);
% assist.down.chB.mrad.R = downsample(assist.chB.mrad.y(assist.logi.R,:),N);
% assist.down.chB.var.R = downvariance(assist.chB.mrad.y(assist.logi.R,:),N);
%
% % Combine F and R
% assist.down.chA.mrad.y = (assist.down.chA.mrad.F + assist.down.chA.mrad.R)./2;
% assist.down.chA.var.y = (assist.down.chA.var.F  + assist.down.chA.var.R);
% assist.down.chA.T_bt = BrightnessTemperature(assist.chA.cxs.x, real(assist.down.chA.mrad.y));
%
% assist.down.chB.mrad.y = (assist.down.chB.mrad.F + assist.down.chB.mrad.R)./2;
% assist.down.chB.var.y = (assist.down.chB.var.F  + assist.down.chB.var.R);
% assist.down.chB.T_bt = BrightnessTemperature(assist.chB.cxs.x, real(assist.down.chB.mrad.y));
% %%
% assist.degraded.chA.NEN1.F = downsample(sqrt(assist.down.chA.var.F),50,2).*(sqrt(15./120));
% assist.degraded.chB.NEN1.F = downsample(sqrt(assist.down.chB.var.F),50,2).*(sqrt(15./120));
% %%
%
% assist.degraded.chA.mrad.x = downsample(assist.chA.cxs.x,50);
% assist.degraded.chA.mrad.F = downsample(assist.down.chA.mrad.F,50,2);
% assist.degraded.chA.Resp_F = downsample(assist.chA.cal_F.Resp,50,2);
% assist.degraded.chA.Offset_ru_F = downsample(assist.chA.cal_F.Offset_ru,50,2);
% assist.degraded.chA.mrad.R = downsample(assist.down.chA.mrad.R,50,2);
% assist.degraded.chA.Resp_R = downsample(assist.chA.cal_R.Resp,50,2);
% assist.degraded.chA.Offset_ru_R = downsample(assist.chA.cal_R.Offset_ru,50,2);
% assist.degraded.chA.mrad.y = downsample(assist.down.chA.mrad.y,50,2);
% assist.degraded.chA.T_bt = BrightnessTemperature(assist.degraded.chA.mrad.x, ...
%     real(assist.degraded.chA.mrad.y));
%
% assist.degraded.chB.mrad.x = downsample(assist.chB.cxs.x,50);
% assist.degraded.chB.mrad.F = downsample(assist.down.chB.mrad.F,50,2);
% assist.degraded.chB.Resp_F = downsample(assist.chB.cal_F.Resp,50,2);
% assist.degraded.chB.Offset_ru_F = downsample(assist.chB.cal_F.Offset_ru,50,2);
% assist.degraded.chB.mrad.R = downsample(assist.down.chB.mrad.R,50,2);
% assist.degraded.chB.Resp_R = downsample(assist.chB.cal_R.Resp,50,2);
% assist.degraded.chB.Offset_ru_R = downsample(assist.chB.cal_R.Offset_ru,50,2);
% assist.degraded.chB.mrad.y = downsample(assist.down.chB.mrad.y,50,2);
% assist.degraded.chB.T_bt = BrightnessTemperature(assist.degraded.chB.mrad.x, ...
%     real(assist.degraded.chB.mrad.y ));
% %%
% NEN2_cxs_std = sqrt(downvariance(real(assist.down.chA.cxs.F(assist.down.HBB_ii(1),:)...
%     -assist.down.chA.cxs.F(assist.down.HBB_ii(2),:)),50,2));
% assist.degraded.chA.NEN2.F = abs(NEN2_cxs_std./assist.degraded.chA.Resp_F);
%
% NEN2_cxs_std = sqrt(downvariance(real(assist.down.chA.cxs.R(assist.down.HBB_ii(1),:)...
%     -assist.down.chA.cxs.R(assist.down.HBB_ii(2),:)),50,2));
% assist.degraded.chA.NEN2.R = abs(NEN2_cxs_std./assist.degraded.chA.Resp_R);
%
%
% NEN2_cxs_std = sqrt(downvariance(real(assist.down.chB.cxs.F(assist.down.HBB_ii(1),:)...
%     -assist.down.chB.cxs.F(assist.down.HBB_ii(2),:)),50,2));
% assist.degraded.chB.NEN2.F = abs(NEN2_cxs_std./assist.degraded.chB.Resp_F);
%
% NEN2_cxs_std = sqrt(downvariance(real(assist.down.chB.cxs.R(assist.down.HBB_ii(1),:)...
%     -assist.down.chB.cxs.R(assist.down.HBB_ii(2),:)),50,2));
% assist.degraded.chB.NEN2.R = abs(NEN2_cxs_std./assist.degraded.chB.Resp_R);
%
%
% assist.degraded.chA.sky_NEN.F =  sqrt(downvariance(mean(imag(assist.down.chA.mrad.F(3:8,:))),50,2))./sqrt(2);
% assist.degraded.chB.sky_NEN.F =  sqrt(downvariance(mean(imag(assist.down.chB.mrad.F(3:8,:))),50,2))./sqrt(2);
% assist.degraded.chA.sky_NEN.R =  sqrt(downvariance(mean(imag(assist.down.chA.mrad.R(3:8,:))),50,2))./sqrt(2);
% assist.degraded.chB.sky_NEN.R =  sqrt(downvariance(mean(imag(assist.down.chB.mrad.R(3:8,:))),50,2))./sqrt(2);
%
% %%
% IRT = irt_rel_resp;
% assist.IRT_resp = interp1(IRT.wn, IRT.rel_resp_wn,assist.chA.cxs.x,'cubic');
% assist.IRT_resp(assist.chA.cxs.x<min(IRT.wn)|assist.chA.cxs.x>max(IRT.wn))=0;
% assist.IRT_resp = assist.IRT_resp./trapz(assist.chA.cxs.x, assist.IRT_resp);
% assist.IRT_cwn = IRT.cwn;
% % figure; plot(IRT.wn, IRT.rel_resp_wn, 'ko', assist.chA.cxs.x, assist.IRT_resp, '.');
% assist.IRT_rad = trapz(assist.chA.cxs.x, (real(assist.down.chA.mrad.y.*...
%     (ones([size(assist.down.chA.mrad.y,1),1])*assist.IRT_resp)))');
% assist.IRT_K = BrightnessTemperature(assist.IRT_cwn, assist.IRT_rad);
% assist.IRT_C = assist.IRT_K-273.17;
%
%
% % Assess difference between Andre' and my derived products
% [pname_A] = getdir([],'assist_proc','Select location of Andre''s results');
% %%
% % So, first compare the spectral quantities
% % %%
% % % 20110324_051618_chA_HBBNen1.coad.mrad.pro.degraded.truncated.mat
% % infileA = getfullname([pname_A,'20110324_051618_chA_Nen.coad.mrad.pro.degraded.truncated.mat'],'edgar_mat','Select ch A truncated mrad')
% % matA = repack_edgar(infileA);
% % [mat_pname, mat_fname, ext] = fileparts(infileA);
% % [fname_a,fname_b]=strtok(mat_fname,'.');
% % infileB = strrep(infileA,'_chA_','_chB_');
% % matB = repack_edgar(infileB);
% % %
% % %%
% % posA = assist.degraded.chA.mrad.x>=500&assist.degraded.chA.mrad.x<=max(matA.x);
% % posB = assist.degraded.chB.mrad.x>=min(matB.x)&assist.degraded.chB.mrad.x<=max(matB.x);
% % %
% %
% % figure;
% % plot(matA.x,matA.y(1,:), 'k.',...
% %    assist.degraded.chA.mrad.x(posA), assist.degraded.chA.NEN1.F(assist.down.isSky,posA),'-ro',...
% %    matA.x,matA.y, 'k.',...
% %    assist.degraded.chB.mrad.x(posB), assist.degraded.chB.NEN1.F(assist.down.isSky,posB),'bo',...
% %    matB.x,matB.y , 'g.')
% % legend('Andre','Flynn')
% % xlim([550,3000]);
% % title({fname_a;[fname_b(2:end) ext]},'interp','none');
% % xlabel('wavenumber [1/cm]');
% % ylabel('radiance [RU]');
% %%
%
% infileA = getfullname([pname_A,'*_chA_SKY.coad.mrad.coad.merged.truncated.mat'],'edgar_mat','Select ch A truncated mrad')
% matA = repack_edgar(infileA);
% [mat_pname, mat_fname, ext] = fileparts(infileA);
% [fname_a,fname_b]=strtok(mat_fname,'.');
% infileB = strrep(infileA,'_chA_','_chB_');
% matB = repack_edgar(infileB);
%
% posA = assist.down.chA.mrad.x>=min(matA.x)&assist.down.chA.mrad.x<=max(matA.x);
% posB = assist.down.chB.mrad.x>=min(matB.x)&assist.down.chB.mrad.x<=max(matB.x);
%
% posAd = assist.degraded.chA.mrad.x>=500&assist.degraded.chA.mrad.x<=max(matA.x);
% posBd = assist.degraded.chB.mrad.x>=min(matB.x)&assist.degraded.chB.mrad.x<=max(matB.x);
%
% %%
% [meinaA, ainmeA] = nearest(assist.down.chA.mrad.x,matA.x);
% figure; plot(assist.down.chA.mrad.x(meinaA), min(assist.down.chA.mrad.y(3:8,meinaA)),'k-'); grid('on');zoom('on');
% title(['NLC A2 = ',sprintf('%2.4g',assist.chA.nlc.a2)]);
% axis([750,1000,-.5,3]);
% xl = xlim;
% %%
%
% figure;
% plot(assist.down.chA.mrad.x(meinaA), mean(assist.down.chA.T_bt(3:8,meinaA)),'b-'); grid('on');zoom('on');
% title(['NLC A2 = ',sprintf('%2.4g',assist.chA.nlc.a2)]);
% ylabel('brightness T');
% xlim(xl);
% %%
% figure;
% sb3(1) = subplot(2,1,1);
% plot(assist.down.chA.mrad.x(meinaA), assist.down.chA.mrad.y(3,meinaA),'k-', matA.x(ainmeA), matA.y(1,ainmeA),'r-');
% legend('mine','Andre''s')
% title('ch A comparisons');
% grid('on');
% sb3(2) = subplot(2,1,2);
% plot(assist.down.chA.mrad.x(meinaA), (assist.down.chA.mrad.y(3,meinaA) - matA.y(1,ainmeA)),'r-');
% legend('mine - Andre''s')
% grid('on');
% linkaxes(sb3,'x');
% title(['NLC A2 = ',sprintf('%2.4g',assist.chA.nlc.a2)]);
% %%
%
% [meinaB, ainmeB] = nearest(assist.down.chB.mrad.x,matB.x);
%
% figure;
% sb4(1) = subplot(2,1,1);
% plot(assist.down.chB.mrad.x(meinaB), assist.down.chB.mrad.y(3,meinaB),'k-', matB.x(ainmeB), matB.y(1,ainmeB),'r-');
% legend('mine','Andre''s');
% title('ch B comparisons')
% sb4(2) = subplot(2,1,2);
% plot(assist.down.chB.mrad.x(meinaB), (assist.down.chB.mrad.y(3,meinaB) - matB.y(1,ainmeB)),'r-');
% legend('mine - Andre''s')
% linkaxes(sb4,'x');
%
%
%
% %%
%
% infileA = getfullname([pname_A,'20110324_051618_chA_HBBNen2.coad.mrad.pro.degraded.truncated.mat'],'edgar_mat','Select ch A truncated mrad')
% matA = repack_edgar(infileA);
% [mat_pname, mat_fname, ext] = fileparts(infileA);
% [fname_a,fname_b]=strtok(mat_fname,'.');
% infileB = strrep(infileA,'_chA_','_chB_');
% matB = repack_edgar(infileB);
%
%
% posA = assist.degraded.chA.mrad.x>=500&assist.degraded.chA.mrad.x<=max(matA.x);
% posB = assist.degraded.chB.mrad.x>=min(matB.x)&assist.degraded.chB.mrad.x<=max(matB.x);
% %
%
% figure;
% plot(assist.degraded.chA.mrad.x(posA), assist.degraded.chA.NEN2.F(posA), 'r.',...
%     assist.degraded.chA.mrad.x(posA), assist.degraded.chA.NEN1.F(assist.down.isHBB,posA),'-ro',...
%     matA.x,matA.y, 'k.',...
%     assist.degraded.chB.mrad.x(posB), assist.degraded.chB.NEN2.F(posB),'b.',...
%     assist.degraded.chB.mrad.x(posB), assist.degraded.chB.NEN1.F(assist.down.isHBB,posB),'bo',...
%     matB.x,matB.y , 'g.')
% legend('NEN2','NEN1')
% xlim([550,3000]);
% title({fname_a;[fname_b(2:end) ext]},'interp','none');
% xlabel('wavenumber [1/cm]');
% ylabel('radiance [RU]');
% %%
% %%
%
% infileA = getfullname([pname_A,'20110324_051618_chA_Nen.coad.mrad.pro.degraded.truncated.mat'],'edgar_mat','Select ch A truncated mrad')
% matA = repack_edgar(infileA);
% [mat_pname, mat_fname, ext] = fileparts(infileA);
% [fname_a,fname_b]=strtok(mat_fname,'.');
% infileB = strrep(infileA,'_chA_','_chB_');
% matB = repack_edgar(infileB);
%
%
% posA = assist.degraded.chA.mrad.x>=500&assist.degraded.chA.mrad.x<=max(matA.x);
% posB = assist.degraded.chB.mrad.x>=min(matB.x)&assist.degraded.chB.mrad.x<=max(matB.x);
% %
%
% figure;
% plot(assist.degraded.chA.mrad.x(posA), assist.degraded.chA.sky_NEN.F(posA), 'r.',...
%     matA.x,matA.y, 'k.',...
%     assist.degraded.chB.mrad.x(posB), assist.degraded.chB.sky_NEN.F(posB),'b.',...
%     matB.x,matB.y , 'g.')
% legend('NEN2','NEN1')
% xlim([550,3000]);
% title({fname_a;[fname_b(2:end) ext]},'interp','none');
% xlabel('wavenumber [1/cm]');
% ylabel('radiance [RU]');
% %%
% figure;
% plot(matB.x,matB.y , '-')
% legend('1','2','3','4','5','6')
% xlim([1700,3000]);
% title({fname_a;[fname_b(2:end) ext]},'interp','none');
% xlabel('wavenumber [1/cm]');
% ylabel('radiance [RU]');
% %%
% p = 1;
% png_file = [mat_pname,filesep,mat_fname,'.',num2str(p), '.png'];
% while exist(png_file,'file')
%     p = p +1;
%     png_file = [mat_pname,filesep,mat_fname,'.',num2str(p), '.png'];
% end
% saveas(gcf,png_file);
%
% %%
%
% % Then, define the different sub-bands and compute related quantities
% % Then, load each mat file and check content.
% proc_pname = ['C:\case_studies\assist\data\post_Feb_repair\20110222_1157\one_sequence\processed'];
% infileA = getfullname('*_chA_BTemp_SKY*.mat','edgar_mat','Select ch A Brightness temperature')
% matA = repack_edgar_nc(infileA);
% [mat_pname, mat_fname, ext] = fileparts(infileA);
% [fname_a,fname_b]=strtok(mat_fname,'.');
% infileB = strrep(infileA,'_chA_','_chB_');
% matB = repack_edgar(infileB);
% %
% posA = assist.degraded.chA.mrad.x>=min(matA.x)&assist.degraded.chA.mrad.x<=max(matA.x);
% posB = assist.degraded.chB.mrad.x>=min(matB.x)&assist.degraded.chB.mrad.x<=max(matB.x);
% %
% posA = assist.degraded.chA.mrad.x>=min(matA.x)&assist.degraded.chA.mrad.x<=2000;
% posB = assist.degraded.chB.mrad.x>=1700&assist.degraded.chB.mrad.x<=max(matB.x);
%
% figure;
% plot(matA.x,matA.y(1,:)-273.15, 'k.',...
%     assist.degraded.chA.mrad.x(posA), assist.degraded.chA.T_bt(assist.down.isSky,posA)-273.15,'ro',...
%     matA.x,matA.y -273.15, 'k.',...
%     assist.degraded.chB.mrad.x(posB), assist.degraded.chB.T_bt(assist.down.isSky,posB)-273.15,'bo',...
%     matB.x,matB.y -273.15, 'g.')
% legend('Andre','Flynn')
% xlim([550,3000]);
% title({fname_a;[fname_b(2:end) ext]},'interp','none');
% xlabel('wavenumber [1/cm]');
% ylabel('brightness temperature [C]');
% %%
% p = 1;
% png_file = [mat_pname,filesep,mat_fname,'.',num2str(p), '.png'];
% while exist(png_file,'file')
%     p = p +1;
%     png_file = [mat_pname,filesep,mat_fname,'.',num2str(p), '.png'];
% end
% saveas(gcf,png_file);
% %%
% infileA = getfullname('*_chA_HBBNen1.coad.mrad.pro.truncated.degraded.mat','edgar_mat','Select ch A NEN1')
% matA = repack_edgar_nc(infileA);
% [mat_pname, mat_fname, ext] = fileparts(infileA);
% [fname_a,fname_b]=strtok(mat_fname,'.');
% infileB = strrep(infileA,'_chA_','_chB_');
% matB = repack_edgar_nc(infileB);
% %
% posA = assist.degraded.chA.mrad.x>=min(matA.x)&assist.degraded.chA.mrad.x<=max(matA.x);
% posB = assist.degraded.chB.mrad.x>=min(matB.x)&assist.degraded.chB.mrad.x<=max(matB.x);
%
% figure;
% plot(matA.x,matA.y(1,:), 'k.',...
%     assist.degraded.chA.mrad.x(posA), assist.degraded.chA.NEN1.F(assist.down.isSky,posA),'ro',...
%     matA.x,matA.y, 'k.',...
%     assist.degraded.chB.mrad.x(posB), assist.degraded.chB.NEN1.F(assist.down.isSky,posB),'ro',...
%     matB.x,matB.y , 'k.')
% legend('Andre','Flynn')
% xlim([550,3000]);
% title({fname_a;[fname_b(2:end) ext]},'interp','none');
% xlabel('wavenumber [1/cm]');
% ylabel('noise-equivalent radiance [RU]');
% %%
% p = 1;
% png_file = [mat_pname,filesep,mat_fname,'.',num2str(p), '.png'];
% while exist(png_file,'file')
%     p = p +1;
%     png_file = [mat_pname,filesep,mat_fname,'.',num2str(p), '.png'];
% end
% saveas(gcf,png_file);
% %%
% infileA = getfullname('*_chA_HBBNen2.coad.mrad.pro.truncated.degraded.mat','edgar_mat','Select ch A NEN2')
% matA = repack_edgar(infileA);
% [mat_pname, mat_fname, ext] = fileparts(infileA);
% [fname_a,fname_b]=strtok(mat_fname,'.');
% infileB = strrep(infileA,'_chA_','_chB_');
% matB = repack_edgar(infileB);
% %
% posA = assist.degraded.chA.mrad.x>=min(matA.x)&assist.degraded.chA.mrad.x<=max(matA.x);
% posB = assist.degraded.chB.mrad.x>=min(matB.x)&assist.degraded.chB.mrad.x<=max(matB.x);
%
% figure;
% plot(matA.x,matA.y(1,:), 'k.',...
%     assist.degraded.chA.mrad.x(posA), assist.degraded.chA.NEN2(posA),'ro',...
%     matA.x,matA.y, 'k.',...
%     assist.degraded.chB.mrad.x(posB), assist.degraded.chB.NEN2(posB),'ro',...
%     matB.x,matB.y , 'k.')
% legend('Andre','Flynn')
% xlim([550,3000]);
% title({fname_a;[fname_b(2:end) ext]},'interp','none');
% xlabel('wavenumber [1/cm]');
% ylabel('noise-equivalent radiance [RU]');
% %%
% p = 1;
% png_file = [mat_pname,filesep,mat_fname,'.',num2str(p), '.png'];
% while exist(png_file,'file')
%     p = p +1;
%     png_file = [mat_pname,filesep,mat_fname,'.',num2str(p), '.png'];
% end
% saveas(gcf,png_file);
% %%
% infileA = getfullname('*_chA_SKY.coad.mrad.coad.merged.truncated.degraded.mat','edgar_mat','Select ch A degraded mrad')
% matA = repack_edgar(infileA);
% [mat_pname, mat_fname, ext] = fileparts(infileA);
% [fname_a,fname_b]=strtok(mat_fname,'.');
% infileB = strrep(infileA,'_chA_','_chB_');
% matB = repack_edgar(infileB);
% %
% posA = assist.degraded.chA.mrad.x>=min(matA.x)&assist.degraded.chA.mrad.x<=max(matA.x);
% posB = assist.degraded.chB.mrad.x>=min(matB.x)&assist.degraded.chB.mrad.x<=max(matB.x);
%
% figure;
% plot(matA.x,matA.y(1,:), 'k.',...
%     assist.degraded.chA.mrad.x(posA), assist.degraded.chA.mrad.F(assist.down.isSky,posA),'ro',...
%     matA.x,matA.y, 'k.',...
%     assist.degraded.chB.mrad.x(posB), assist.degraded.chB.mrad.F(assist.down.isSky,posB),'ro',...
%     matB.x,matB.y , 'k.')
% legend('Andre','Flynn')
% xlim([550,3000]);
% title({fname_a;[fname_b(2:end) ext]},'interp','none');
% xlabel('wavenumber [1/cm]');
% ylabel('radiance [RU]');
% %%
% p = 1;
% png_file = [mat_pname,filesep,mat_fname,'.',num2str(p), '.png'];
% while exist(png_file,'file')
%     p = p +1;
%     png_file = [mat_pname,filesep,mat_fname,'.',num2str(p), '.png'];
% end
% saveas(gcf,png_file);
%
% %%
% % Load real and imaginary responsivity for Ch A and Ch B
% infileA = getfullname('*_chA_SKY_RESP_REAL_SKY.coad.mrad.pro.truncated.degraded.mat','edgar_mat','Select ch A real responsivity')
% Re_matA = repack_edgar(infileA);
% [mat_pname, mat_fname, ext] = fileparts(infileA);
% [fname_a,fname_b]=strtok(mat_fname,'.');
% infileB = strrep(infileA,'_chA_','_chB_');
% Re_matB = repack_edgar(infileB);
% infileA = getfullname('*_chA_SKY_RESP_IMA_SKY.coad.mrad.pro.truncated.degraded.mat','edgar_mat','Select ch A imag responsivity')
% Im_matA = repack_edgar(infileA);
% [mat_pname, mat_fname, ext] = fileparts(infileA);
% [fname_a,fname_b]=strtok(mat_fname,'.');
% infileB = strrep(infileA,'_chA_','_chB_');
% Im_matB = repack_edgar(infileB);
%
% infileA = getfullname('*_chA_SKY_OFF_REAL_SKY.coad.mrad.pro.truncated.degraded.mat','edgar_mat','Select ch A real offset')
% Re_offA = repack_edgar(infileA);
% [mat_pname, mat_fname, ext] = fileparts(infileA);
% [fname_a,fname_b]=strtok(mat_fname,'.');
% infileB = strrep(infileA,'_chA_','_chB_');
% Re_offB = repack_edgar(infileB);
% infileA = getfullname('*_chA_SKY_OFF_IMA_SKY.coad.mrad.pro.truncated.degraded.mat','edgar_mat','Select ch A imag offset')
% Im_offA = repack_edgar(infileA);
% [mat_pname, mat_fname, ext] = fileparts(infileA);
% [fname_a,fname_b]=strtok(mat_fname,'.');
% infileB = strrep(infileA,'_chA_','_chB_');
% Im_offB = repack_edgar(infileB);
% %
% posA = assist.degraded.chA.mrad.x>=min(Re_matA.x)&assist.degraded.chA.mrad.x<=max(Re_matA.x);
% posB = assist.degraded.chB.mrad.x>=min(Re_matB.x)&assist.degraded.chB.mrad.x<=max(Re_matB.x);
% %%
% figure;
% subplot(2,1,1);
% plot(Re_matA.x,Re_matA.y(1:2:end,:), 'k.',...
%     Im_matA.x,Im_matA.y(1:2:end,:), 'r.',...
%     assist.degraded.chA.mrad.x(posA), real(assist.degraded.chA.Resp_F(posA)),'k-',...
%     assist.degraded.chA.mrad.x(posA), imag(assist.degraded.chA.Resp_F(posA)),'r-',...
%     Re_matB.x,Re_matB.y(1:2:end,:), 'k.',...
%     Im_matB.x,Im_matB.y(1:2:end,:), 'r.',...
%     assist.degraded.chB.mrad.x(posB), real(assist.degraded.chB.Resp_F(posB)),'k-',...
%     assist.degraded.chB.mrad.x(posB), imag(assist.degraded.chB.Resp_F(posB)),'r-')
% legend('Re','Im')
% xlim([550,3000]);
% title({fname_a;[fname_b(2:end) ext]},'interp','none');
% xlabel('wavenumber [1/cm]');
% ylabel('radiance [RU]');
% subplot(2,1,2);
%
% plot(Re_offA.x,Re_offA.y(1,:), 'k.',...
%     Im_offA.x,Im_offA.y(1,:), 'r.',...
%     assist.degraded.chA.mrad.x(posA), real(assist.degraded.chA.Offset_ru_F(posA)),'k-',...
%     assist.degraded.chA.mrad.x(posA), imag(assist.degraded.chA.Offset_ru_F(posA)),'r-',...
%     Re_offB.x,Re_offB.y(1,:), 'k.',...
%     Im_offB.x,Im_offB.y(1,:), 'r.',...
%     assist.degraded.chB.mrad.x(posB), real(assist.degraded.chB.Offset_ru_F(posB)),'k-',...
%     assist.degraded.chB.mrad.x(posB), imag(assist.degraded.chB.Offset_ru_F(posB)),'r-')
% legend('Edgar Re','Edgar Im', 'Flynn Re','Flynn Im')
% xlim([550,3000]);
% title('Calibration offsets','interp','none');
% xlabel('wavenumber [1/cm]');
% ylabel('radiance [RU]');
%
% %%
% figure;
% subplot(2,1,1);
% plot(Re_matA.x,Re_matA.y(1,:), 'k.',...
%     Im_matA.x,Im_matA.y(1,:), 'r.',...
%     Re_matB.x,Re_matB.y(1,:), 'k.',...
%     Im_matB.x,Im_matB.y(1,:), 'r.')
% legend('Re','Im')
% xlim([550,3000]);
% title('forward scan responsivity and offsets','interp','none');
% xlabel('wavenumber [1/cm]');
% ylabel('radiance [RU]');
% subplot(2,1,2);
%
% plot(Re_offA.x,-Re_offA.y(1,:)./(1000.*Re_matA.y(1,:)), 'k.',...
%     Im_offA.x,-Im_offA.y(1,:)./(1000.*Im_matA.y(1,:)), 'r.',...
%     assist.degraded.chA.mrad.x(posA), -real(assist.degraded.chA.Offset_ru_F(posA)),'k-',...
%     assist.degraded.chA.mrad.x(posA), -imag(assist.degraded.chA.Offset_ru_F(posA)),'r-',...
%     Re_offB.x,-Re_offB.y(1,:)./(1000.*Re_matB.y(1,:)), 'k.',...
%     Im_offB.x,-Im_offB.y(1,:)./(1000.*Im_matB.y(1,:)), 'r.',...
%     assist.degraded.chB.mrad.x(posB), -real(assist.degraded.chB.Offset_ru_F(posB)),'k-',...
%     assist.degraded.chB.mrad.x(posB), -imag(assist.degraded.chB.Offset_ru_F(posB)),'r-')
% legend('Edgar Re','Edgar Im', 'Flynn Re','Flynn Im')
% xlim([550,3000]);
% xlabel('wavenumber [1/cm]');
% ylabel('radiance [RU]');

return



%
%
% [zpd_loc,zpd_mag] = find_zpd_edgar(RawIgm);
% %    [tmp,zpd_loc] = max(abs(RawIgm.y - mean(RawIgm.y)));
%     zpd_loc = zpd_loc - length(RawIgm.x)./2-1;
%     zpd_loc = mode(zpd_loc);
%
% RawSpc.y = fft(zpd_circshift(RawIgm.x,RawIgm.y,-zpd_loc),[],2);
% RawSpc.y = fftshift(RawSpc.y,2);
% return

function lab = legalize(lab)
lab = strrep(lab,' ','');
lab = strrep(lab,'-','');
lab = strrep(lab,'.','');
lab = strrep(lab,'(°)','');
return

% function mat = repack_edgar(edgar)
% if ~exist('edgar','var')
%    edgar =loadinto(getfullname('*.mat','edgar_mat','Select an Edgar mat file.'));
% end
% if ~isstruct(edgar)&&exist(edgar,'file')
%    edgar =loadinto(edgar);
% end
% if isfield(edgar,'mainHeaderBlock')
%     V = double([edgar.mainHeaderBlock.date.year,edgar.mainHeaderBlock.date.month,...
%         edgar.mainHeaderBlock.date.day,edgar.mainHeaderBlock.date.hours,...
%         edgar.mainHeaderBlock.date.minutes,edgar.mainHeaderBlock.date.seconds]);
%     nbPoints = edgar.mainHeaderBlock.nbPoints;
%     % xStep = (edgar.mainHeaderBlock.lastX-edgar.mainHeaderBlock.firstX)./(nbPoints-1);
%     mat.x = linspace(edgar.mainHeaderBlock.firstX, (edgar.mainHeaderBlock.lastX), double(nbPoints));
%     if isfield(edgar.mainHeaderBlock,'laserFrequency')
%         mat.laserFrequency = edgar.mainHeaderBlock.laserFrequency;
%     end
%
%     base_time = datenum(V);
% end
% if ~isfield(edgar,'subfiles')&isfield(edgar,'subfileData')
%     edgar.subfiles{1}.subfileHeader = edgar.subfileHeader;
%     edgar.subfiles{1}.subfileData = edgar.subfileData;
%     edgar = rmfield(edgar, 'subfileHeader');
%     edgar = rmfield(edgar, 'subfileData');
% end
% subs = length(edgar.subfiles);
% for s = subs:-1:1
% if exist('base_time','var')
% mat.time(s) = base_time +  double(edgar.subfiles{s}.subfileHeader.subStartingZ)./(24*60*60);
% end
% mat.flags(s) = edgar.subfiles{s}.subfileHeader.subFlags;
% if isfield(edgar.subfiles{s}.subfileHeader,'nbCoaddedScans')
%    mat.coads(s) = edgar.subfiles{s}.subfileHeader.nbCoaddedScans;
% end
% mat.subIndex(s) = edgar.subfiles{s}.subfileHeader.subIndex;
% mat.scanNb(s) = edgar.subfiles{s}.subfileHeader.scanNb;
% mat.HBBRawTemp(s) = edgar.subfiles{s}.subfileHeader.subHBBRawTemp;
% mat.CBBRawTemp(s) = edgar.subfiles{s}.subfileHeader.subCBBRawTemp;
% if isfield(edgar.subfiles{s}.subfileHeader,'zpdLocation')
% mat.zpdLocation(s) = edgar.subfiles{s}.subfileHeader.zpdLocation;
% end
% if isfield(edgar.subfiles{s}.subfileHeader,'zpdValue')
% mat.zpdValue(s) = edgar.subfiles{s}.subfileHeader.zpdValue;
% end
% mat.y(s,:) = edgar.subfiles{s}.subfileData;
% end
% mat.flags = uint8(mat.flags);
% return

% function mat1 = stitch_mats(mat1, mat2)
% time_len = length(mat1.time);
% [~, ii] = sort([mat1.scanNb,mat2.scanNb]);
% mat_fields = (fieldnames(mat1));
%
% for f = length(mat_fields):-1:1
%     jj = find(size(mat1.(mat_fields{f}))==time_len);
%     if jj==1
%         X = [mat1.(mat_fields{f});mat2.(mat_fields{f})];
%         mat1.(mat_fields{f}) = X(ii,:);
%     elseif jj==2
%         X = [mat1.(mat_fields{f}),mat2.(mat_fields{f})];
%         mat1.(mat_fields{f}) = X(:,ii);
%     end
% end
%
% return

function assist = flip_reverse_scans(assist)
% I flip the reverse scans to put both scans on the same physical frame.
assist.chA.y(assist.logi.R,:) = fliplr(assist.chA.y(assist.logi.R,:));
if isfield(assist,'chB');
   assist.chB.y(assist.logi.R,:) = fliplr(assist.chB.y(assist.logi.R,:));
end

return

function assist = select_scan_dir(assist,strip);
fields = fieldnames(assist);
for f = length(fields):-1:1
   scan_dim = find(size(assist.(fields{f}))==length(strip),1,'first')-1;
   if ~isempty(scan_dim)
      tmp = shiftdim(assist.(fields{f}),scan_dim);
      assist.(fields{f}) = shiftdim(tmp(strip,:),-scan_dim);
   elseif isstruct(assist.(fields{f}))
      assist.(fields{f}) = select_scan_dir(assist.(fields{f}),strip);
   end
end

return

function assist = rad_cal_def_M(assist, emis, T_ref)
% Just looking at chA right now to assess calibration from pre-merged data
% simplest, use mean temperatures and BB spectra over entire measurement
% Determines seperate calibrations from F, R, and premerged data set.

T_hot_F = mean(assist.HBB_C(assist.logi.HBB_F));
T_cold_F = mean(assist.ABB_C(assist.logi.ABB_F));
T_hot_R = mean(assist.HBB_C(assist.logi.HBB_R));
T_cold_R = mean(assist.ABB_C(assist.logi.ABB_R));% ratio between the uncalibrated spectral differences (C_sky – C_cold)/(C_hot – C_cold)
if ~exist('T_ref','var')
   T_ref =T_cold_F ;
end

% Coad the mono-directional BB spectra to improve robustness of calibration
% Compute uncalibrated variance spectra of BB mono-scans
in_spec.x = assist.chA.cxs.x;
in_spec.y = assist.chA.cxs.y(assist.logi.H&assist.logi.F,:);
HBB_F = CoaddData(in_spec);

in_spec.x = assist.chA.cxs.x;
in_spec.y = assist.chA.cxs.y(assist.logi.H&assist.logi.R,:);
HBB_R = CoaddData(in_spec);

in_spec.x = assist.chA.cxs.x;
in_spec.y = assist.chA.cxs.y(assist.logi.A&assist.logi.F,:);
ABB_F = CoaddData(in_spec);

in_spec.x = assist.chA.cxs.x;
in_spec.y = assist.chA.cxs.y(assist.logi.A&assist.logi.R,:);
ABB_R = CoaddData(in_spec);

in_spec.x = assist.chA.cxs.x;
in_spec.y = assist.chA.cxs.y(assist.logi.Sky&assist.logi.F,:);
SKY_F = CoaddData(in_spec);

in_spec.x = assist.chA.cxs.x;
in_spec.y = assist.chA.cxs.y(assist.logi.Sky&assist.logi.R,:);
SKY_R = CoaddData(in_spec);


if ~exist('emis','var')
   assist.chA.cal_F = CreateCalibrationFromCXS_(HBB_F,  273.15+T_hot_F, ABB_F,  273.15+T_cold_F);
   assist.chA.cal_R = CreateCalibrationFromCXS_(HBB_R,  273.15+T_hot_R, ABB_R,  273.15+T_cold_R);
else
   %     Tr = 28.65;
   %%
   [assist.chA.cal_F, assist.chA.cal_F_,assist.chA.cal_F__] = CreateCalibrationFromCXS_(HBB_F,  273.15+T_hot_F, ABB_F,  273.15+T_cold_F,273.15+T_ref, emis);
   
   %%
   
   [assist.chA.cal_R, assist.chA.cal_R_, assist.chA.cal_R__] = CreateCalibrationFromCXS_(HBB_R,  273.15+T_hot_R, ABB_R,  273.15+T_cold_R,273.15+T_ref, emis);
end

%%
% pos = in_spec.x>450&in_spec.x<2000;
% figure;
% sb3(1)= subplot(2,1,1);
% plot(in_spec.x(pos), real([assist.chA.cal_F.Resp(pos);assist.chA.cal_R.Resp(pos);assist.chA.cal_M.Resp(pos)]), '-')
% title('real(Resp)')
% legend('F','R', 'M');
% sb3(2)= subplot(2,1,2);
% plot(in_spec.x(pos), real([assist.chA.cal_F.Resp(pos);assist.chA.cal_R.Resp(pos);assist.chA.cal_M.Resp(pos)])...
%    - ones([3,1])*mean(real([assist.chA.cal_F.Resp(pos);assist.chA.cal_R.Resp(pos);assist.chA.cal_M.Resp(pos)]),1), '-')
% title('real(Resp)-mean(Resp)')
% legend('F','R', 'M');
% linkaxes(sb3,'x');
%%
% And now we do chB

in_spec.x = assist.chB.cxs.x;
in_spec.y = assist.chB.cxs.y(assist.logi.H&assist.logi.F,:);
HBB_F = CoaddData(in_spec);

in_spec.x = assist.chB.cxs.x;
in_spec.y = assist.chB.cxs.y(assist.logi.H&assist.logi.R,:);
HBB_R = CoaddData(in_spec);

in_spec.x = assist.chB.cxs.x;
in_spec.y = assist.chB.cxs.y(assist.logi.A&assist.logi.F,:);
ABB_F = CoaddData(in_spec);

in_spec.x = assist.chB.cxs.x;
in_spec.y = assist.chB.cxs.y(assist.logi.A&assist.logi.R,:);
ABB_R = CoaddData(in_spec);

if ~exist('emis','var')
   assist.chB.cal_F = CreateCalibrationFromCXS_(HBB_F,  273.15+T_hot_F, ABB_F,  273.15+T_cold_F);
   assist.chB.cal_R = CreateCalibrationFromCXS_(HBB_R,  273.15+T_hot_R, ABB_R,  273.15+T_cold_R);
else
   %     Tr = 28.65;
   %%
   [assist.chB.cal_F, assist.chB.cal_F_,assist.chB.cal_F__] = CreateCalibrationFromCXS_(HBB_F,  273.15+T_hot_F, ABB_F,  273.15+T_cold_F,273.15+T_ref, emis);
   
   %%
   
   [assist.chB.cal_R, assist.chB.cal_R_, assist.chB.cal_R__] = CreateCalibrationFromCXS_(HBB_R,  273.15+T_hot_R, ABB_R,  273.15+T_cold_R,273.15+T_ref, emis);
end

return

% function assist = load_cal_sequence_nc(pname, dstem)
% for ds = 1:length(dstem)
%     ann_ls = dir([pname, dstem{ds},'*ann*.csv']);
%     chA_ls = dir([pname, dstem{ds},'*chA_*.nc']);
%     chB_ls = dir([pname, dstem{ds},'*chB_*.nc']);
%     for a = length(ann_ls):-1:1
%         fname = ann_ls(a).name;
%         if ~isempty(strfind(fname,'.xls'))
%             [xl_num, xl_txt]= xlsread([pname, fname]);
%             xl_len = min([length(xl_txt(2,:)),length(xl_num(2,:))]);
%             for n = xl_len:-1:1
%                 if any(isnumeric(xl_num(:,n)))
%                     lab = legalize(xl_txt{2,n});
%                     ann.(lab) = xl_num(:,n);
%                 end
%             end
%         else
%             ann = rd_ann_csv([pname, fname]);
%         end
%         if ~exist('assist','var')
%             assist.ann = ann;
%         else
%             [scan_nm, ii] = sort([assist.ann.ScanNumber;ann.ScanNumber]);
%             ann_fields = (fieldnames(assist.ann));
%             for f = length(ann_fields):-1:3
%                 try
%                 X = [assist.ann.(ann_fields{f});ann.(ann_fields{f})];
%                 assist.ann.(ann_fields{f}) = X(ii);
%                 catch
%                     disp(['Problem with ', ann_fields{f}])
%                 end
%             end
%         end
%
%         fname = chA_ls(a).name;
%         edgar_nc = anc_load([pname, fname]);
%         %         edgar_mat = loadinto([pname,fname]);
%         flynn_mat = repack_edgar_nc(edgar_nc);
%         if ~isempty(strfind(fname,'_HC.nc'))
%             flynn_mat.flags(1:12) = bitset(flynn_mat.flags(1:12), 5,true);% bit 5 is HBB
%             flynn_mat.flags(13:end) = bitset(flynn_mat.flags(13:end), 6,true); % bit 6 is ABB
%         end
%         if ~isempty(strfind(fname,'_CH.nc'))
%             flynn_mat.flags(1:12) = bitset(flynn_mat.flags(1:12), 6,true);
%             flynn_mat.flags(13:end) = bitset(flynn_mat.flags(13:end), 5,true);
%         end
%         if ~exist('assist','var')||~isfield(assist,'chA')
%             assist.chA = flynn_mat;
%         else
%             assist.chA = stitch_mats(assist.chA,flynn_mat);
%         end
%
%         fname = chB_ls(a).name;
%         edgar_nc = anc_load([pname,fname]);
%         flynn_mat = repack_edgar_nc(edgar_nc);
%         if ~isempty(strfind(fname,'_HC.nc'))
%             flynn_mat.flags(1:12) = bitset(flynn_mat.flags(1:12), 5,true);
%             flynn_mat.flags(13:end) = bitset(flynn_mat.flags(13:end), 6,true);
%         end
%         if ~isempty(strfind(fname,'_CH.nc'))
%             flynn_mat.flags(1:12) = bitset(flynn_mat.flags(1:12), 6,true);
%             flynn_mat.flags(13:end) = bitset(flynn_mat.flags(13:end), 5,true);
%         end
%         if ~isfield(assist,'chB')
%             assist.chB = flynn_mat;
%         else
%             assist.chB = stitch_mats(assist.chB,flynn_mat);
%         end
%     end % next "a"
% end %next "ds"
% logi.F = bitget(assist.chA.flags,2)>0;
% logi.R = bitget(assist.chA.flags,3)>0;
% logi.H = bitget(assist.chA.flags,5)>0;
% logi.A = bitget(assist.chA.flags,6)>0;
% logi.Sky = ~(logi.H|logi.A);
% sky_ii = find(logi.Sky);
% logi.HBB_F = bitget(assist.chA.flags,2)&bitget(assist.chA.flags,5);
% logi.HBB_R = bitget(assist.chA.flags,3)&bitget(assist.chA.flags,5);
% logi.ABB_F = bitget(assist.chA.flags,2)&bitget(assist.chA.flags,6);
% logi.ABB_R = bitget(assist.chA.flags,3)&bitget(assist.chA.flags,6);
% logi.Sky_F = bitget(assist.chA.flags,2)& ~(bitget(assist.chA.flags,5)|bitget(assist.chA.flags,6));
% logi.Sky_R = bitget(assist.chA.flags,3)& ~(bitget(assist.chA.flags,5)|bitget(assist.chA.flags,6));
%
% assist.logi = logi;
% assist.time = assist.chA.time;
%
% return

function assist = proc_cal_sequence(assist, nlc, dstem)
% This version of 'proc_cal_sequence' applies several "nlc" corrections:
% Independent corrections for each scan direction as well as for the
% average, and corrections using the raw zpd intensities as well as the
% "phase-corrected" zpd intensities
if ~exist('nlc','var')
   error('nlc is a required input argument')
end
HBB_off = 0;
ABB_off = 0;
assist.HBB_C = HBB_off+double(assist.chA.HBBRawTemp)./500;
assist.ABB_C = ABB_off+double(assist.chA.CBBRawTemp)./500;
assist.chA.laser_wl = 632.8e-7;    % He-Ne wavelength in cm
assist.chA.laser_wl = 1./1.580098e4;    % from Andre
assist.chB.laser_wl = 1./1.579990e4;    % from Andre
assist.chA.laser_wn = 1./assist.chA.laser_wl; % wavenumber in 1/cm
assist.chB.laser_wn = 1./assist.chB.laser_wl; % wavenumber in 1/cm
% assist = flip_reverse_scans(assist);
dim_n = find(size(assist.chA.y)==length(assist.chA.x));

% ZPD Values:
%%
logi = assist.logi;
[~,maxii_HF] = max(abs(assist.chA.y(logi.HBB_F,:)),[],2); maxii_HF = mode(maxii_HF);
[~,maxii_HR] = max(abs(assist.chA.y(logi.HBB_R,:)),[],2); maxii_HR = mode(maxii_HR);
assist.chA.maxii_HF = maxii_HF;assist.chA.maxii_HR = maxii_HR;
assist.chA.zpd_shift = zeros(size(assist.time))'-length(assist.chA.x)./2 -1;
assist.chA.zpd_shift(logi.F) =  assist.chA.zpd_shift(logi.F) + maxii_HF;
assist.chA.zpd_shift(logi.R) =  assist.chA.zpd_shift(logi.R) + maxii_HR;

%Position detected zpd at center +1.
assist.chA.y =  sideshift(assist.chA.x, assist.chA.y, assist.chA.zpd_shift);
assist.chA.x = fftshift(assist.chA.x);
assist.chA.y = fftshift(assist.chA.y,dim_n);

%Implement new phase-shifted absolute magnitude ZPD ala Dave Turner
% This is inside RawIgm2RawSpc
%  (a) capture the sign of the Vdc value at ZPD,
%  (b) convert the interf to a spectrum,
%  (c) transform the complex spectrum into a magnitude spectrum,
%  (d) convert the magnitude spectrum back to an interf,
%  (e) determine the magnitude of the Vdc at ZPD, and
%  (f) assign the magnitude the sign of the value determined in step (a).

[assist.chA.cxs.x,assist.chA.cxs.y,assist.chA.cxs.zpd_ps] = RawIgm2RawSpc(assist.chA.x,assist.chA.y,assist.chA.laser_wl);
assist.chA.cxs.zpd_raw = assist.chA.y(:,1);
if any(assist.chA.cxs.zpd_raw ~= max(assist.chA.y,[],2))
   disp('ZPD_raw ~= max!')
end

[assist] = NLC_split_det_scandir(assist, nlc.PC_avg, assist.chA.cxs.zpd_ps,assist.logi.F|assist.logi.R);
% Now channel B, InSb
[~,maxii_HF] = max(abs(assist.chB.y(logi.HBB_F,:)),[],2); maxii_HF = mode(maxii_HF);
[~,maxii_HR] = max(abs(assist.chB.y(logi.HBB_R,:)),[],2); maxii_HR = mode(maxii_HR);
assist.chB.maxii_HF = maxii_HF;assist.chB.maxii_HR = maxii_HR;
assist.chB.zpd_shift = zeros(size(assist.time))'-length(assist.chB.x)./2 -1;
assist.chB.zpd_shift(logi.F) =  assist.chB.zpd_shift(logi.F) + maxii_HF;
assist.chB.zpd_shift(logi.R) =  assist.chB.zpd_shift(logi.R) + maxii_HR;
% assist.chB.zpd_shift = maxii-length(assist.chB.x)./2 -1;
assist.chB.y =  sideshift(assist.chB.x, assist.chB.y, assist.chB.zpd_shift);
assist.chB.x = fftshift(assist.chB.x);
assist.chB.y = fftshift(assist.chB.y,dim_n);
[assist.chB.cxs.x,assist.chB.cxs.y] = RawIgm2RawSpc(assist.chB.x,assist.chB.y,assist.chB.laser_wl);

% Temperature to be used for reflected emission.
% 3.5C (276.65k)

% assist = rad_cal_def_M(assist, emis, T_ref)
emis = assist.emis;
assist = rad_cal_def_M(assist, emis);


%
assist.chA.spc.y(assist.logi.F,:) = RadiometricCalibration_4(assist.chA.cxs.y(assist.logi.F,:), assist.chA.cal_F);
assist.chA.spc.y(assist.logi.R,:) = RadiometricCalibration_4(assist.chA.cxs.y(assist.logi.R,:), assist.chA.cal_R);

assist.chB.spc.y(assist.logi.F,:) = RadiometricCalibration_4(assist.chB.cxs.y(assist.logi.F,:), assist.chB.cal_F);
assist.chB.spc.y(assist.logi.R,:) = RadiometricCalibration_4(assist.chB.cxs.y(assist.logi.R,:), assist.chB.cal_R);


%%
% figure; plot(assist.chA.cxs.x, [mean(assist.chA.cxs.y(assist.logi.ABB_F,:));mean(assist_noNLC.chA.cxs.y(assist.logi.ABB_F,:))],'-')
%%

% Half-angle FOV to be used for FFOV correction.
% 0.0225; mrad
%
% This is a variant of SSEC ratio test.  Can you improve it, maybe replace
% with Penny's approach?
hot_minus_cold = mean(assist.chA.spc.y(logi.H,:))-mean(assist.chA.spc.y(logi.A,:));
sky_minus_cold = assist.chA.spc.y(logi.Sky,:)-ones([sum(logi.Sky),1])*mean(assist.chA.spc.y(logi.A,:));
abs_sky_minus_cold = max(abs(sky_minus_cold));
bad =  abs_sky_minus_cold./abs(hot_minus_cold) > 1.5 & assist.chA.cxs.x>550 & assist.chA.cxs.x<1820;
% figure; plot(assist.chA.cxs.x, abs_sky_minus_cold./abs(hot_minus_cold),'-');
% xlim([540,1800]);
% Next we'd need to compute the brightness temperature of some good sky
% spectra from 672-682 wavenumbers
wn_CO2 = assist.chA.cxs.x>=672&assist.chA.cxs.x<=682;
T_bt = mean(mean(BrightnessTemperature(assist.chA.cxs.x(wn_CO2),real(assist.chA.spc.y(logi.Sky,wn_CO2)))));
BB_CO2 = Blackbody(assist.chA.cxs.x, T_bt);
y_old = assist.chA.spc.y;
assist.chA.spc.y(logi.Sky,bad) = ones([sum(logi.Sky),1])*BB_CO2(bad);
% figure; plot(assist.chA.cxs.x, mean(assist.chA.spc.y(logi.Sky,:)),'-',assist.chA.cxs.x(bad),mean(y_old(logi.Sky,bad)),'ro');xlim([540,1800]);

assist.chA.mrad.y = ApplyFFOVCorr(assist.chA.cxs.x, assist.chA.spc.y,0.0225);
assist.chB.mrad.y = ApplyFFOVCorr(assist.chB.cxs.x, assist.chB.spc.y,0.0225);

%%
% figure(50); sp(1) = subplot(2,1,1);
% plot(assist.chA.cxs.x(chA), real([assist.chA.spc.y(sky_fi(1),chA);assist.chA.spc_.y(sky_fi(1),chA);assist.chA.spc__.y(sky_fi(1),chA)]),'-', ...
%     assist.chB.cxs.x(chB), real([assist.chB.spc.y(sky_fi(1),chB);assist.chB.spc_.y(sky_fi(1),chB);assist.chB.spc__.y(sky_fi(1),chB)]),'-');
% grid('on');
% legend('both','emis','none');
% title('Forward scans');
% sp(2) = subplot(2,1,2);
% plot(assist.chA.cxs.x(chA), real([assist.chA.spc.y(sky_ri(1),chA);assist.chA.spc_.y(sky_ri(1),chA);assist.chA.spc__.y(sky_ri(1),chA)]),'-',...
%     assist.chB.cxs.x(chB), real([assist.chB.spc.y(sky_ri(1),chB);assist.chB.spc_.y(sky_ri(1),chB);assist.chB.spc__.y(sky_ri(1),chB)]),'-');
% grid('on');
% legend('both','emis','none');
% title('Reverse scans');
% linkaxes(sp,'xy');
% if exist('v','var')
%     axis(v);
% end

% figure(51); spp(1) = subplot(2,1,1);
% plot(assist.chA.cxs.x(chA), real([assist.chA.spc.y(sky_fi(1),chA);assist.chA.mrad.y(sky_fi(1),chA)]),'-', ...
%     assist.chB.cxs.x(chB), real([assist.chB.spc.y(sky_fi(1),chB);assist.chB.mrad.y(sky_fi(1),chB)]),'-');
% grid('on');
% legend('both','FFOV');
% title('Forward scans');
% spp(2) = subplot(2,1,2);
% plot(assist.chA.cxs.x(chA), real([assist.chA.spc.y(sky_ri(1),chA);assist.chA.mrad.y(sky_ri(1),chA)]),'-',...
%     assist.chB.cxs.x(chB), real([assist.chB.spc.y(sky_ri(1),chB);assist.chB.mrad.y(sky_ri(1),chB)]),'-');
% grid('on');
% legend('both','FFOV');
% title('Reverse scans');
% linkaxes(spp,'xy');
% if exist('v','var')
%     axis(v);
% end

N = 6; % downsample over 6
%
[rows,cols]= size(assist.time);
retime = zeros([2.*N.*rows,cols./(2.*N)]);
retime(:) = assist.time;
%
% retime =
assist.down.time = retime(1,:);
assist.down.isSky = downsample(assist.logi.Sky,2.*N)>0;
assist.down.isHBB = downsample(assist.logi.H,2.*N)>0;
assist.down.isABB = downsample(assist.logi.A,2.*N)>0;

sky_fi = find(assist.logi.Sky_F);
sky_ri = find(assist.logi.Sky_R);
chA = assist.chA.cxs.x>350&assist.chA.cxs.x<1830;
chB = assist.chB.cxs.x>1750&assist.chB.cxs.x<3000;

assist.down.Sky_ii = find(assist.down.isSky);
assist.down.HBB_ii = find(assist.down.isHBB);
assist.down.ABB_ii = find(assist.down.isABB);

assist.down.chA.mrad.x = assist.chA.cxs.x;
assist.down.chB.mrad.x = assist.chB.cxs.x;
%Forward
% Ch A
assist.down.chA.ifg.F = downsample(assist.chA.y(assist.logi.F,:),N);
assist.down.chA.cxs.F = downsample(assist.chA.cxs.y(assist.logi.F,:),N);
assist.down.chA.mrad.F = downsample(assist.chA.mrad.y(assist.logi.F,:),N);
assist.down.chA.var.F = downvariance(assist.chA.mrad.y(assist.logi.F,:),N);

% Ch B
assist.down.chB.ifg.F = downsample(assist.chB.y(assist.logi.F,:),N);
assist.down.chB.cxs.F = downsample(assist.chB.cxs.y(assist.logi.F,:),N);
assist.down.chB.mrad.F = downsample(assist.chB.mrad.y(assist.logi.F,:),N);
assist.down.chB.var.F = downvariance(assist.chB.mrad.y(assist.logi.F,:),N);

% Reverse
% Ch A
assist.down.chA.ifg.R = downsample(assist.chA.y(assist.logi.R,:),N);
assist.down.chA.cxs.R = downsample(assist.chA.cxs.y(assist.logi.R,:),N);
assist.down.chA.mrad.R = downsample(assist.chA.mrad.y(assist.logi.R,:),N);
assist.down.chA.var.R = downvariance(assist.chA.mrad.y(assist.logi.R,:),N);


% Ch B
assist.down.chB.ifg.R = downsample(assist.chB.y(assist.logi.R,:),N);
assist.down.chB.cxs.R = downsample(assist.chB.cxs.y(assist.logi.R,:),N);
assist.down.chB.mrad.R = downsample(assist.chB.mrad.y(assist.logi.R,:),N);
assist.down.chB.var.R = downvariance(assist.chB.mrad.y(assist.logi.R,:),N);

% Combine F and R
assist.down.chA.mrad.y = (assist.down.chA.mrad.F + assist.down.chA.mrad.R)./2;
assist.down.chA.var.y = (assist.down.chA.var.F  + assist.down.chA.var.R);
assist.down.chA.T_bt = BrightnessTemperature(assist.chA.cxs.x, real(assist.down.chA.mrad.y));

assist.down.chB.mrad.y = (assist.down.chB.mrad.F + assist.down.chB.mrad.R)./2;
assist.down.chB.var.y = (assist.down.chB.var.F  + assist.down.chB.var.R);
assist.down.chB.T_bt = BrightnessTemperature(assist.chB.cxs.x, real(assist.down.chB.mrad.y));

%for the nc file, create varRad_SKY 1 x 16384 using the max values:
assist.down.chA.varRad_SKY = max(assist.down.chA.var.y(3:8,:));
assist.down.chB.varRad_SKY = max(assist.down.chB.var.y(3:8,:));

xl_A = assist.chA.cxs.x >= 520 & assist.chA.cxs.x <= 1800;
xl_B = assist.chB.cxs.x >= 1780 & assist.chB.cxs.x <= 3000;

% figure; plot(assist.chA.cxs.x(xl_A),assist.down.chA.var.y (xl_A),'-'); 
% ylabel('chA-SKY-var')
% figure; plot(assist.chB.cxs.x(xl_B),assist.down.chB.var.y (xl_B),'-'); 
% ylabel('chB-SKY-var')
%%
assist.degraded.chA.NEN1.F = downsample(sqrt(assist.down.chA.var.F),50,2).*(sqrt(15./120));
assist.degraded.chB.NEN1.F = downsample(sqrt(assist.down.chB.var.F),50,2).*(sqrt(15./120));
%%

assist.degraded.chA.mrad.x = downsample(assist.chA.cxs.x,50);
assist.degraded.chA.mrad.F = downsample(assist.down.chA.mrad.F,50,2);
assist.degraded.chA.Resp_F = downsample(assist.chA.cal_F.Resp,50,2);
assist.degraded.chA.Offset_ru_F = downsample(assist.chA.cal_F.Offset_ru,50,2);
assist.degraded.chA.mrad.R = downsample(assist.down.chA.mrad.R,50,2);
assist.degraded.chA.Resp_R = downsample(assist.chA.cal_R.Resp,50,2);
assist.degraded.chA.Offset_ru_R = downsample(assist.chA.cal_R.Offset_ru,50,2);
assist.degraded.chA.mrad.y = downsample(assist.down.chA.mrad.y,50,2);
assist.degraded.chA.T_bt = BrightnessTemperature(assist.degraded.chA.mrad.x, ...
   real(assist.degraded.chA.mrad.y));

assist.degraded.chB.mrad.x = downsample(assist.chB.cxs.x,50);
assist.degraded.chB.mrad.F = downsample(assist.down.chB.mrad.F,50,2);
assist.degraded.chB.Resp_F = downsample(assist.chB.cal_F.Resp,50,2);
assist.degraded.chB.Offset_ru_F = downsample(assist.chB.cal_F.Offset_ru,50,2);
assist.degraded.chB.mrad.R = downsample(assist.down.chB.mrad.R,50,2);
assist.degraded.chB.Resp_R = downsample(assist.chB.cal_R.Resp,50,2);
assist.degraded.chB.Offset_ru_R = downsample(assist.chB.cal_R.Offset_ru,50,2);
assist.degraded.chB.mrad.y = downsample(assist.down.chB.mrad.y,50,2);
assist.degraded.chB.T_bt = BrightnessTemperature(assist.degraded.chB.mrad.x, ...
   real(assist.degraded.chB.mrad.y ));


% %for .nc population I create the chA_OFF_IMA_SKY which is 53x12
% %FRFRFRFR....
% 
% assist.degraded.chA.OFF_IMA_SKY = [imag(assist.degraded.chA.Offset_ru_F); imag(assist.degraded.chA.Offset_ru_R);...
%     imag(assist.degraded.chA.Offset_ru_F); imag(assist.degraded.chA.Offset_ru_R);...
%     imag(assist.degraded.chA.Offset_ru_F); imag(assist.degraded.chA.Offset_ru_R);...
%     imag(assist.degraded.chA.Offset_ru_F); imag(assist.degraded.chA.Offset_ru_R);...
%     imag(assist.degraded.chA.Offset_ru_F); imag(assist.degraded.chA.Offset_ru_R);...
%     imag(assist.degraded.chA.Offset_ru_F); imag(assist.degraded.chA.Offset_ru_R)];
% assist.degraded.chB.OFF_IMA_SKY = [imag(assist.degraded.chB.Offset_ru_F); imag(assist.degraded.chB.Offset_ru_R);...
%     imag(assist.degraded.chB.Offset_ru_F); imag(assist.degraded.chB.Offset_ru_R);...
%     imag(assist.degraded.chB.Offset_ru_F); imag(assist.degraded.chB.Offset_ru_R);...
%     imag(assist.degraded.chB.Offset_ru_F); imag(assist.degraded.chB.Offset_ru_R);...
%     imag(assist.degraded.chB.Offset_ru_F); imag(assist.degraded.chB.Offset_ru_R);...
%     imag(assist.degraded.chB.Offset_ru_F); imag(assist.degraded.chB.Offset_ru_R)];
% 
% %for .nc population I create the chA_OFF_REAL_SKY which is 53x12
% %FRFRFRFR....
% 
% assist.degraded.chA.OFF_REAL_SKY = [real(assist.degraded.chA.Offset_ru_F); real(assist.degraded.chA.Offset_ru_R);...
%     real(assist.degraded.chA.Offset_ru_F); real(assist.degraded.chA.Offset_ru_R);...
%     real(assist.degraded.chA.Offset_ru_F); real(assist.degraded.chA.Offset_ru_R);...
%     real(assist.degraded.chA.Offset_ru_F); real(assist.degraded.chA.Offset_ru_R);...
%     real(assist.degraded.chA.Offset_ru_F); real(assist.degraded.chA.Offset_ru_R);...
%     real(assist.degraded.chA.Offset_ru_F); real(assist.degraded.chA.Offset_ru_R)];
% assist.degraded.chB.OFF_REAL_SKY = [real(assist.degraded.chB.Offset_ru_F); real(assist.degraded.chB.Offset_ru_R);...
%     real(assist.degraded.chB.Offset_ru_F); real(assist.degraded.chB.Offset_ru_R);...
%     real(assist.degraded.chB.Offset_ru_F); real(assist.degraded.chB.Offset_ru_R);...
%     real(assist.degraded.chB.Offset_ru_F); real(assist.degraded.chB.Offset_ru_R);...
%     real(assist.degraded.chB.Offset_ru_F); real(assist.degraded.chB.Offset_ru_R);...
%     real(assist.degraded.chB.Offset_ru_F); real(assist.degraded.chB.Offset_ru_R)];
% 
% %for .nc population I create the chA_RESP_IMA_SKY which is 53x12
% %FRFRFRFR....
% 
% assist.degraded.chA.RESP_IMA_SKY = [imag(assist.degraded.chA.Resp_F); imag(assist.degraded.chA.Resp_R);...
%     imag(assist.degraded.chA.Resp_F); imag(assist.degraded.chA.Resp_R);...
%     imag(assist.degraded.chA.Resp_F); imag(assist.degraded.chA.Resp_R);...
%     imag(assist.degraded.chA.Resp_F); imag(assist.degraded.chA.Resp_R);...
%     imag(assist.degraded.chA.Resp_F); imag(assist.degraded.chA.Resp_R);...
%     imag(assist.degraded.chA.Resp_F); imag(assist.degraded.chA.Resp_R)];
% assist.degraded.chB.RESP_IMA_SKY = [imag(assist.degraded.chB.Resp_F); imag(assist.degraded.chB.Resp_R);...
%     imag(assist.degraded.chB.Resp_F); imag(assist.degraded.chB.Resp_R);...
%     imag(assist.degraded.chB.Resp_F); imag(assist.degraded.chB.Resp_R);...
%     imag(assist.degraded.chB.Resp_F); imag(assist.degraded.chB.Resp_R);...
%     imag(assist.degraded.chB.Resp_F); imag(assist.degraded.chB.Resp_R);...
%     imag(assist.degraded.chB.Resp_F); imag(assist.degraded.chB.Resp_R)];
% 
% %for .nc population I create the chA_RESP_REAL_SKY which is 53x12
% %FRFRFRFR....
% 
% assist.degraded.chA.RESP_REAL_SKY = [real(assist.degraded.chA.Resp_F); real(assist.degraded.chA.Resp_R);...
%     real(assist.degraded.chA.Resp_F); real(assist.degraded.chA.Resp_R);...
%     real(assist.degraded.chA.Resp_F); real(assist.degraded.chA.Resp_R);...
%     real(assist.degraded.chA.Resp_F); real(assist.degraded.chA.Resp_R);...
%     real(assist.degraded.chA.Resp_F); real(assist.degraded.chA.Resp_R);...
%     real(assist.degraded.chA.Resp_F); real(assist.degraded.chA.Resp_R)];
% assist.degraded.chB.RESP_REAL_SKY = [real(assist.degraded.chB.Resp_F); real(assist.degraded.chB.Resp_R);...
%     real(assist.degraded.chB.Resp_F); real(assist.degraded.chB.Resp_R);...
%     real(assist.degraded.chB.Resp_F); real(assist.degraded.chB.Resp_R);...
%     real(assist.degraded.chB.Resp_F); real(assist.degraded.chB.Resp_R);...
%     real(assist.degraded.chB.Resp_F); real(assist.degraded.chB.Resp_R);...
%     real(assist.degraded.chB.Resp_F); real(assist.degraded.chB.Resp_R)];
% 
% %generate the right times for the 12 OFF and RESP .nc file:
% % first find the Sky forward scans - there are 36 and we need to average them by 6:
% 
% Sky_Fii = find(assist.logi.Sky_F);
% SF1_ii = Sky_Fii(1:6);
% SF2_ii = Sky_Fii(7:12);
% SF3_ii = Sky_Fii(13:18);
% SF4_ii = Sky_Fii(19:24);
% SF5_ii = Sky_Fii(25:30);
% SF6_ii = Sky_Fii(31:36);
% 
% % Similarly we find the reverse scans and group them by 6:
% 
% Sky_Rii = find(assist.logi.Sky_R);
% SR1_ii = Sky_Rii(1:6);
% SR2_ii = Sky_Rii(7:12);
% SR3_ii = Sky_Rii(13:18);
% SR4_ii = Sky_Rii(19:24);
% SR5_ii = Sky_Rii(25:30);
% SR6_ii = Sky_Rii(31:36);
% 
% % Now generate the time for the F and R scans grouped by 6 (take the
% % average time for each):
% 
% time_Sky_6scan_ave = [mean(assist.time(SF1_ii)); mean(assist.time(SR1_ii)); mean(assist.time(SF2_ii));...
%                     mean(assist.time(SR2_ii));mean(assist.time(SF3_ii));mean(assist.time(SR3_ii));...
%                     mean(assist.time(SF4_ii));mean(assist.time(SR4_ii));mean(assist.time(SF5_ii));...
%                     mean(assist.time(SF5_ii));mean(assist.time(SF6_ii));mean(assist.time(SR6_ii))];
% % I will do the same for the HBB and ABB, so I have the right times when
% % needed
% 
% ABB_Fii = find(assist.logi.ABB_F);
% ABBF1_ii = ABB_Fii(1:6);
% ABBF2_ii = ABB_Fii(7:12);
% 
% ABB_Rii = find(assist.logi.ABB_R);
% ABBR1_ii = ABB_Rii(1:6);
% ABBR2_ii = ABB_Rii(7:12);
% 
% time_ABB_6scan_ave = [mean(assist.time(ABBF1_ii)); mean(assist.time(ABBR1_ii));...
%                     mean(assist.time(ABBF2_ii)); mean(assist.time(ABBR2_ii))];
%                 
% HBB_Fii = find(assist.logi.HBB_F);
% HBBF1_ii = HBB_Fii(1:6);
% HBBF2_ii = HBB_Fii(7:12);
% 
% HBB_Rii = find(assist.logi.HBB_R);
% HBBR1_ii = HBB_Rii(1:6);
% HBBR2_ii = HBB_Rii(7:12);
% 
% time_HBB_6scan_ave = [mean(assist.time(HBBF1_ii)); mean(assist.time(HBBR1_ii));...
%                     mean(assist.time(HBBF2_ii)); mean(assist.time(HBBR2_ii))];

%%
NEN2_cxs_std = sqrt(downvariance(real(assist.down.chA.cxs.F(assist.down.HBB_ii(1),:)...
   -assist.down.chA.cxs.F(assist.down.HBB_ii(2),:)),50,2));
assist.degraded.chA.NEN2.F = abs(NEN2_cxs_std./assist.degraded.chA.Resp_F);

NEN2_cxs_std = sqrt(downvariance(real(assist.down.chA.cxs.R(assist.down.HBB_ii(1),:)...
   -assist.down.chA.cxs.R(assist.down.HBB_ii(2),:)),50,2));
assist.degraded.chA.NEN2.R = abs(NEN2_cxs_std./assist.degraded.chA.Resp_R);


NEN2_cxs_std = sqrt(downvariance(real(assist.down.chB.cxs.F(assist.down.HBB_ii(1),:)...
   -assist.down.chB.cxs.F(assist.down.HBB_ii(2),:)),50,2));
assist.degraded.chB.NEN2.F = abs(NEN2_cxs_std./assist.degraded.chB.Resp_F);

NEN2_cxs_std = sqrt(downvariance(real(assist.down.chB.cxs.R(assist.down.HBB_ii(1),:)...
   -assist.down.chB.cxs.R(assist.down.HBB_ii(2),:)),50,2));
assist.degraded.chB.NEN2.R = abs(NEN2_cxs_std./assist.degraded.chB.Resp_R);


assist.degraded.chA.sky_NEN.F =  sqrt(downvariance(mean(imag(assist.down.chA.mrad.F(3:8,:))),50,2))./sqrt(2);
assist.degraded.chB.sky_NEN.F =  sqrt(downvariance(mean(imag(assist.down.chB.mrad.F(3:8,:))),50,2))./sqrt(2);
assist.degraded.chA.sky_NEN.R =  sqrt(downvariance(mean(imag(assist.down.chA.mrad.R(3:8,:))),50,2))./sqrt(2);
assist.degraded.chB.sky_NEN.R =  sqrt(downvariance(mean(imag(assist.down.chB.mrad.R(3:8,:))),50,2))./sqrt(2);


% to populate the .nc files we need as follows:
assist.degraded.chA.NEN2 = [assist.degraded.chA.NEN2.F; assist.degraded.chA.NEN2.R];
assist.degraded.chB.NEN2 = [assist.degraded.chB.NEN2.F; assist.degraded.chB.NEN2.R];
assist.degraded.chA.sky_NEN = (assist.degraded.chA.sky_NEN.F  + assist.degraded.chA.sky_NEN.R);
assist.degraded.chB.sky_NEN = (assist.degraded.chB.sky_NEN.F + assist.degraded.chB.sky_NEN.R);

assist.degraded.chA.sky_NEN_6 = [assist.degraded.chA.sky_NEN; assist.degraded.chA.sky_NEN; assist.degraded.chA.sky_NEN; ...
    assist.degraded.chA.sky_NEN; assist.degraded.chA.sky_NEN; assist.degraded.chA.sky_NEN];
assist.degraded.chB.sky_NEN_6 = [assist.degraded.chB.sky_NEN; assist.degraded.chB.sky_NEN; assist.degraded.chB.sky_NEN; ...
    assist.degraded.chB.sky_NEN; assist.degraded.chB.sky_NEN; assist.degraded.chB.sky_NEN];

%%
IRT = irt_rel_resp;
assist.IRT_resp = interp1(IRT.wn, IRT.rel_resp_wn,assist.chA.cxs.x,'pchip');
assist.IRT_resp(assist.chA.cxs.x<min(IRT.wn)|assist.chA.cxs.x>max(IRT.wn))=0;
assist.IRT_resp = assist.IRT_resp./trapz(assist.chA.cxs.x, assist.IRT_resp);
assist.IRT_cwn = IRT.cwn;
% figure; plot(IRT.wn, IRT.rel_resp_wn, 'ko', assist.chA.cxs.x, assist.IRT_resp, '.');
assist.down.IRT_rad = trapz(assist.chA.cxs.x, (real(assist.down.chA.mrad.y.*...
   (ones([size(assist.down.chA.mrad.y,1),1])*assist.IRT_resp)))');
assist.down.IRT_K = BrightnessTemperature(assist.IRT_cwn, assist.down.IRT_rad);
assist.down.IRT_C = assist.down.IRT_K-273.17;
% Create a loop to populate each of the derived product files...

% Output "downsampled" products
% chA
% Truncate x chA and chB to match aeri limits;
xl_A = assist.chA.cxs.x >= 520 & assist.chA.cxs.x <= 1800;
xl_B = assist.chB.cxs.x >= 1780 & assist.chB.cxs.x <= 3000;
xld_A= assist.degraded.chA.mrad.x >= 520 & assist.degraded.chA.mrad.x <= 1800;
xld_B= assist.degraded.chB.mrad.x >= 1800 & assist.degraded.chB.mrad.x <= 3000;


% Load one by one the shell files that have to be populated with correct
% time and x-y data
%chA_SKY.coad.mrad.coad.merged.truncated.nc
%chA_varRad_SKY.coad.mrad.coad.truncated.pro.nc
%chA_varRad_HBB.coad.mrad.coad.truncated.pro.nc
%chB_SKY.coad.mrad.coad.merged.truncated.nc
%chB_varRad_SKY.coad.mrad.coad.truncated.pro.nc
%chB_varRad_HBB.coad.mrad.coad.truncated.pro.nc

% chA downsampled first; x_axis is 2654.

%mt = anc_load('C:\Users\Lind256\Documents\ASSIST\data\2014_02_17_00_04_10_Processed\20140216_233856_chA_SKY.coad.mrad.coad.merged.truncated.nc');
mt = anc_load('C:\Users\Lind256\Documents\ASSIST\data\assist_raw_from_finland\Shells\20140216_234615_chA_SKY.coad.mrad.coad.merged.truncated.nc');
time = (assist.down.time(assist.down.isSky)-assist.time(1))*24*60*60;
% [mtpath, ~, ~] = fileparts(mt.fname);
% ass_name = [mtpath,filesep, dstem{2},'assist.mat'];
% save(ass_name,'-struct','assist');
proc_tmp = pop_templateA(mt, assist.time(1), time,dstem, assist.chA.cxs.x(xl_A), assist.down.chA.mrad.y(assist.down.isSky,xl_A));

%figure; plot(proc_tmp.vdata.x_axis,proc_tmp.vdata.y_data,'-')

%mt = anc_load('C:\Users\Lind256\Documents\ASSIST\data\2014_02_17_00_04_10_Processed\20140216_233856_chA_varRad_HBB.coad.mrad.coad.truncated.pro.nc');
mt = anc_load('C:\Users\Lind256\Documents\ASSIST\data\assist_raw_from_finland\Shells\20140216_234615_chA_varRad_HBB.coad.mrad.coad.truncated.pro.nc');
time = (assist.down.time(assist.down.isHBB)-assist.time(1))*24*60*60;
proc_tmp = pop_templateA(mt, assist.time(1), time, dstem, assist.chA.cxs.x(xl_A), assist.down.chA.var.y(assist.down.isHBB,xl_A));
%figure; plot(proc_tmp.vdata.x_axis,proc_tmp.vdata.y_data,'-')

% HAS TO BE CHECKED! .nc file that needs to be populated has 1 nbSubfiles,
% while our assist.down.chA.var.y(assist.down.isSky,xl_A) has 6.
%solved this by taking the maximum value at each x. The time in the nc file
%is the average time of the sky times. 
%mt = anc_load('C:\Users\Lind256\Documents\ASSIST\data\2014_02_17_00_04_10_Processed\20140216_233856_chA_varRad_SKY.coad.mrad.coad.truncated.pro.nc');
mt = anc_load('C:\Users\Lind256\Documents\ASSIST\data\assist_raw_from_finland\Shells\20140216_234615_chA_varRad_SKY.coad.mrad.coad.truncated.pro.nc');
time = (mean(assist.down.time(assist.down.isSky)-assist.time(1)))*24*60*60;
proc_tmp = pop_templateA(mt, assist.time(1), time,dstem, assist.chA.cxs.x(xl_A), assist.down.chA.varRad_SKY(xl_A));
%figure; plot(proc_tmp.vdata.x_axis,proc_tmp.vdata.y_data,'-')

% chB downsampled now; x_axis is 2654.

%mt = anc_load('C:\Users\Lind256\Documents\ASSIST\data\2014_02_17_00_04_10_Processed\20140216_233856_chB_SKY.coad.mrad.coad.merged.truncated.nc');
mt = anc_load('C:\Users\Lind256\Documents\ASSIST\data\assist_raw_from_finland\Shells\20140216_234615_chB_SKY.coad.mrad.coad.merged.truncated.nc');
time = (assist.down.time(assist.down.isSky)-assist.time(1))*24*60*60;
proc_tmp = pop_templateB(mt, assist.time(1), time,dstem, assist.chB.cxs.x(xl_B), assist.down.chB.mrad.y(assist.down.isSky,xl_B));
%figure; plot(proc_tmp.vdata.x_axis,proc_tmp.vdata.y_data,'-')

%mt = anc_load('C:\Users\Lind256\Documents\ASSIST\data\2014_02_17_00_04_10_Processed\20140216_233856_chB_varRad_HBB.coad.mrad.coad.truncated.pro.nc');
mt = anc_load('C:\Users\Lind256\Documents\ASSIST\data\assist_raw_from_finland\Shells\20140216_234615_chB_varRad_HBB.coad.mrad.coad.truncated.pro.nc');
time = (assist.down.time(assist.down.isHBB)-assist.time(1))*24*60*60;
proc_tmp = pop_templateB(mt, assist.time(1), time,dstem, assist.chB.cxs.x(xl_B), assist.down.chB.var.y(assist.down.isHBB,xl_B));
%figure; plot(proc_tmp.vdata.x_axis,proc_tmp.vdata.y_data,'-')

%mt = anc_load('C:\Users\Lind256\Documents\ASSIST\data\2014_02_17_00_04_10_Processed\20140216_233856_chB_varRad_SKY.coad.mrad.coad.truncated.pro.nc');
mt = anc_load('C:\Users\Lind256\Documents\ASSIST\data\assist_raw_from_finland\Shells\20140216_234615_chB_varRad_SKY.coad.mrad.coad.truncated.pro.nc');
time = (mean(assist.down.time(assist.down.isSky)-assist.time(1)))*24*60*60;
proc_tmp = pop_templateB(mt, assist.time(1), time,dstem, assist.chB.cxs.x(xl_B),  assist.down.chB.varRad_SKY(xl_B));
%figure; plot(proc_tmp.vdata.x_axis,proc_tmp.vdata.y_data,'-')
return

function seq = cut_seq(seq)
% Have to be careful doing this
deg = seq.degraded;
seq = seq.down;

seq.degraded = deg;
seq.chA = rmfield(seq.chA,'ifg');
seq.chA = rmfield(seq.chA,'cxs');
seq.chB = rmfield(seq.chB,'ifg');
seq.chB = rmfield(seq.chB,'cxs');
return

function mt = pop_templateA(mt, filetime, time,dstem, x_data, y_data)

mt.ncdef.dims.x_axis.length = 2654;
mt.vdata.x_axis = x_data';
mt.vdata.y_data = y_data';
mt.vdata.time = time;
mt.vdata.base_time = serial2epoch(filetime)*1000;

% Create the new name
res_path = 'C:\Users\Lind256\Documents\ASSIST\data\assist_raw_from_finland\Results';
[mt_path,mt_fstem,mt_ext] = fileparts(mt.fname);
[token,remain1]=strtok(mt_fstem,'_');
[token,remain2]=strtok(remain1,'_');
new_name=[remain2,mt_ext];
%mt.fname = [mt_path,filesep, datestr(filetime,'yyyymmdd_HHMMSS'),new_name];
new_name=strrep(new_name, '_chA','chA');
%mt.fname = [mt_path,filesep, dstem{2},new_name];
mt.fname = [res_path,filesep, dstem{2},new_name];

mt.vdata.y_data = single(mt.vdata.y_data);
mt.vdata.time = single(mt.vdata.time);
mt.clobber = true;
%check that the nc file is free of errors then save it as mat file and nc
%file
mt.quiet = true;
mt = anc_check(mt);
mt.quiet = true;
save(strrep(mt.fname,'.nc','.mat'),'-struct','mt');
anc_save(mt);

% mt2 = anc_load(mt.fname);
return

function mt = pop_templateB(mt, filetime, time,dstem, x_data, y_data)

mt.ncdef.dims.x_axis.length = 2530;
mt.vdata.x_axis = x_data';
mt.vdata.y_data = y_data';
mt.vdata.time = time;
mt.vdata.base_time = serial2epoch(filetime)*1000;

% Create the new name
[mt_path,mt_fstem,mt_ext] = fileparts(mt.fname);
res_path = 'C:\Users\Lind256\Documents\ASSIST\data\assist_raw_from_finland\Results';
[token,remain1]=strtok(mt_fstem,'_');
[token,remain2]=strtok(remain1,'_');
new_name=[remain2,mt_ext];
%mt.fname = [mt_path,filesep, datestr(filetime,'yyyymmdd_HHMMSS'),new_name];
new_name=strrep(new_name, '_chB','chB');
%mt.fname = [mt_path,filesep, dstem{2},new_name];
mt.fname = [res_path,filesep, dstem{2},new_name];

mt.vdata.y_data = single(mt.vdata.y_data);
mt.vdata.time = single(mt.vdata.time);
mt.clobber = true;
mt.quiet = true;
%check that the nc file is free of errors then save it as mat file and nc
%file
mt = anc_check(mt);
mt.quiet = true;
save(strrep(mt.fname,'.nc','.mat'),'-struct','mt');
anc_save(mt);
% mt2 = anc_load(mt.fname);
return
