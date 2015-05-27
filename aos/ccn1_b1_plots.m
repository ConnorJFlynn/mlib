% Examine Oct 1,
function ccn1 = ccn_plots ( ccn1)
if ~exist('ccn1','var')
ccn1 = anc_bundle_files;
end

[~,fname] = fileparts(ccn1.fname);
[fname,rest] = strtok(fname,'.');
fname = [fname, '.',strtok(rest,'.')];


dT3 = ccn1.vdata.T_read_TEC3-ccn1.vdata.T_read_TEC1;
% std_dT3 = stdwint(dT3,ccn1.time, 30);
std_dT3 = stdwin(dT3, 30);
bad_dT3 = std_dT3>0.03;
dT_OPC = (ccn1.vdata.T_OPC - ccn1.vdata.T_read_TEC3);
bad_OPC = dT_OPC<2.25 | dT_OPC>3.1;
bad_trans = ccn1.vdata.seconds_after_transition<160;
miss = ccn1.vdata.T_read_TEC3<-9000 | ccn1.vdata.T_read_TEC1<-9000 | ccn1.vdata.temp_unstable>0;
% ss_bad = ccn1.vdata.supersaturation_set_point ~= round(1000.*ccn1.vdata.supersaturation_set_point)./1000;

ss_offset = -0.0;
pos = ccn1.vdata.supersaturation_set_point>0;
ccn1.vdata.supersaturation_set_point(pos) = ccn1.vdata.supersaturation_set_point(pos) - ss_offset;
neg = ccn1.vdata.supersaturation_set_point<0;
ccn1.vdata.supersaturation_set_point(neg) = NaN;

% bads = bad_dT3|bad_OPC|ss_bad|miss;
bads = bad_dT3|bad_OPC|miss|bad_trans;
grad_meas = ccn1.vdata.T_read_gradient;
grad_meas(miss) = NaN; ccn1.vdata.reported_temperature_gradient(miss) = NaN;
% [ss_sets,ii] = unique(round(1000.*ccn1.vdata.supersaturation_set_point(~(miss|bad_dT3|bad_OPC|ss_bad)))./1000);
[ss_sets,ii] = unique(round(1000.*ccn1.vdata.supersaturation_set_point(~(miss|bad_dT3|bad_OPC)))./1000);
low_ss = -0.01;
 cv = [0,max(ss_sets)];
% colormap(jet_rgb);
% figure; plot(serial2doys(ccn1.time), ccn1.vdata.temperature_gradient, 'bo',...
%     serial2doys(ccn1.time), grad_meas,'cx');legend('in file','my diff')
% figure; scatter(serial2doys(ccn1.time(~miss)), grad_meas(~miss),32,ccn1.vdata.temperature_gradient(~miss),'filled');legend('in file','my diff')
%%
% figure; plot(serial2hs(ccn1.time), ccn1.vdata.N_CCN,'k.',serial2hs(ccn1.time(bad_dT3)), ccn1.vdata.N_CCN(bad_dT3),'r.',...
%    serial2hs(ccn1.time(bad_OPC)), ccn1.vdata.N_CCN(bad_OPC),'b.',serial2hs(ccn1.time(ss_bad)), ccn1.vdata.N_CCN(ss_bad),'g.');
% ccn1 = anc_sift(ccn1, ~(miss|bad_dT3|bad_OPC|ss_bad));
ccn1 = anc_sift(ccn1, ~(bads));
[pname,fname,~] = fileparts(ccn1.fname);
fstem = strtok(fname, '.');
% cpcs = dir([pname, filesep,strrep(fstem,'aosccn100','aoscpc'),'.*.',datestr(ccn1.time(1),'yyyymmdd'),'.*']);
% if length(cpcs)==1
%    cpc = anc_load([pname, filesep,cpcs.name]);
%    [ainb, bina] = nearest(ccn1.time, cpc.time);
% cpc = anc_sift(cpc, bina);
% end

% grad_meas = ccn1.vdata.T_read_TEC3 - ccn1.vdata.T_read_TEC1;

miss = ccn1.vdata.T_read_TEC3<-9000 | ccn1.vdata.T_read_TEC1<-9000 | ccn1.vdata.temp_unstable>0;
% ss_bad = ccn1.vdata.supersaturation_set_point ~= round(1000.*ccn1.vdata.supersaturation_set_point)./1000;
if isfield(ccn1.vdata, 'temperature_std')
   std_bad = ccn1.vdata.temperature_std>0.045;
else
   std_bad = false(size(ccn1.vdata.first_stage_monitor_voltage));
end
hr = [floor(min(serial2doys(ccn1.time))):1/24:ceil(max(serial2doys(ccn1.time)))];
doy = serial2doys(ccn1.time);
that = false(size(ccn1.time));
%%
for hh = length(hr):-1:2;
   miss = ccn1.vdata.T_read_TEC3<-9000 | ccn1.vdata.T_read_TEC1<-9000 | ccn1.vdata.temp_unstable>0;
%    this = ~(miss|std_bad|ss_bad) & doy>=hr(hh-1)&doy<hr(hh)&ccn1.vdata.supersaturation_set_point>low_ss;
   this = ~(miss|std_bad) & doy>=hr(hh-1)&doy<hr(hh)&ccn1.vdata.supersaturation_set_point>low_ss;
   
   for s = length(ss_sets):-1:1
      ss_good = this & (round(100.*ccn1.vdata.supersaturation_set_point)./100 == round(100.*ss_sets(s))./100);
      ss_good(ss_good) = inner(ccn1.vdata.N_CCN(ss_good));
      that(ss_good) = true;
      hour(hh).ss(s) = ss_sets(s);
      hour(hh).N_CCN(s) = meannonan(ccn1.vdata.N_CCN(ss_good));
%       if exist('cpc','var')
%       hour(hh).N_CPC(s) = mean(cpc.vdata.concentration(ss_good));
%       end
      hour(hh).std_N_CCN(s) = std(ccn1.vdata.N_CCN(ss_good));
      hour(hh).N_num(s) = sum(ss_good);
      hour(hh).N_CCN_dN(:,s) = mean(ccn1.vdata.N_CCN_dN(:,ss_good),2);
   end
   pos = hour(hh).ss>0&~isNaN(hour(hh).N_CCN);
   hour(hh).P = polyfit(log10(hour(hh).ss(pos)), hour(hh).N_CCN(pos),1);
   hour(hh).maxN = hour(hh).P(end);
   hour(hh).P = hour(hh).P./hour(hh).maxN;
   
   
   figure(94)
   scatter(serial2hs(ccn1.time(this)), ccn1.vdata.N_CCN(this),32,[0.5,0.5,0.5],'filled');
   hold('on');
   scatter(serial2hs(ccn1.time(this&that)), ccn1.vdata.N_CCN(this&that),32,ccn1.vdata.supersaturation_set_point(this&that),'filled');colorbar

%    scatter(serial2hs(ccn1.time(this)), ccn1.vdata.N_CCN(this)./cpc.vdata.concentration(this),32,[0.5,0.5,0.5],'filled');
%    hold('on');
%    scatter(serial2hs(ccn1.time(this&that)), ccn1.vdata.N_CCN(this&that)./cpc.vdata.concentration(this&that),32,ccn1.vdata.supersaturation_set_point(this&that),'filled');colorbar
   hold('off')
   ax_1(3) = gca;
   cb2 = colorbar;
   xlabel('time [UTC]');
   ylabel('N_C_C_N / cm^3')
   colormap(jet_rgb);
   caxis(cv);
   
   tl = title({fname, ;datestr(min(ccn1.time(this)),'yyyy-mm-dd at HH:00 UTC')}); set(tl,'interp','none');
   yl = ylim;  ylim([0,yl(2)]);
     
   figure(95);
   clf
%    s(1)=subplot(2,1,2); 
   scatter(ccn1.vdata.supersaturation_set_point(this), ccn1.vdata.N_CCN(this),32,[.5,.5,.5],'filled');
   hold('on');
   scatter(ccn1.vdata.supersaturation_set_point(this&that), ccn1.vdata.N_CCN(this&that),32,ccn1.vdata.supersaturation_calculated(this&that),'filled');
   hold('off');
   cb=colorbar;
   xlabel('ss% set point');
   ylabel('N_C_C_N / cm^3');
   colormap(jet_rgb);
      caxis(cv);
%    s(2)=subplot(2,1,1); 
 
%    s(1)=subplot(2,1,2);
   hold('on')
   ss_fit = [0.005:0.005:0.05 0.05:.05:[min([1,max(ss_sets)+.1])]];
   plot(ss_fit, polyval(hour(hh).P,log10(ss_fit)).*hour(hh).maxN,'k-', hour(hh).ss, hour(hh).N_CCN, 'ko');
   hold('off')
   xlabel('ss%');
   ylabel('mean N_C_C_N / cm^3');
   colormap(jet_rgb);
   tl = title({fname; datestr(min(ccn1.time(this)),'yyyy-mm-dd at HH:00 UTC')}); set(tl,'interp','none');
   yl = ylim;  ylim([0,yl(2)]);
   
   figure(96);
   if ~isfield(ccn1.vdata,'size_bin')
      ccn1.vdata.size_bin = [1:size(ccn1.vdata.N_CCN_dN,1)];
   end
   nbins = length(ccn1.vdata.size_bin);
   these = plot([1:nbins], ccn1.vdata.N_CCN_dN(:,this),'-');
   colormap(jet_rgb);
   recolor(these,ccn1.vdata.supersaturation_set_point(this)); colorbar
   xlabel('bin number');
   ylabel('N_C_C_N / cm^3 / bin')
   tl = title([fname,': ', datestr(min(ccn1.time(this)),'yyyy-mm-dd HH:00')]); set(tl,'interp','none')
   
   these = plot([1:nbins], hour(hh).N_CCN_dN,'-');
   colormap(jet_rgb);
   recolor(these,hour(hh).ss); colorbar
   xlabel('bin number');
   ylabel('N_C_C_N / cm^3 / bin')
   tl = title({fname; datestr(min(ccn1.time(this)),'yyyy-mm-dd HH:00')}); set(tl,'interp','none')
      caxis(cv);
   
%    figure(99);
%    % this figure plots the data after sorting by supersaturation set point, so the x-axis is more or less good if the durations
%    % of the supersaturations are similar.
%    this_ii = find(this);
%    [by_ss.ss_sets, ij] = sort(ccn1.vdata.supersaturation_set_point(this_ii));
%    by_ss.N_dN = ccn1.vdata.N_dN(1:nbins,this_ii(ij));
%    imagesc(by_ss.ss_sets, [1:nbins],by_ss.N_dN); axis('xy'); cl =colorbar;
%    colormap(jet_rgb);
%    xlabel('% super-saturation');
%    ylabel('bin number');
%    cl_title = get(cl,'title'); set(cl_title,'string','N_C_C_N / cm^3','unit','norm');
%    pos = get(cl_title,'position'); new_pos = pos; new_pos(1) = 1; new_pos(2) = -0.075; set(cl_title,'position',new_pos);
   
   figure(101);
   [by_ss.ss_sets, ij] = sort(hour(hh).ss);
   by_ss.N_CCN_dN = hour(hh).N_CCN_dN(:,ij);
   imagesc(by_ss.ss_sets, [1:nbins],by_ss.N_CCN_dN); axis('xy'); cl =colorbar;
   colormap(jet_rgb);
   xlabel('% super-saturation');
   ylabel('bin number');
   cl_title = get(cl,'title'); set(cl_title,'string','N_C_C_N / cm^3','unit','norm');
   pos = get(cl_title,'position'); new_pos = pos; new_pos(1) = 1; new_pos(2) = -0.075; set(cl_title,'position',new_pos);
%       caxis(cv);
%    % this figure plots the data chronologically as collected, so the x-axis is bogus.
%    figure(97);
%    imagesc(serial2hs(ccn1.time(this)), [1:nbins],(ccn1.vdata.N_dN(1:nbins,this))); axis('xy'); cl =colorbar;
%    xlabel('time (UTC)');
%    ylabel('bin number');
%    colormap(jet_rgb);
%    tl = title({fname; datestr(min(ccn1.time(this)),'yyyy-mm-dd HH:00')}); set(tl,'interp','none');
%    cl_title = get(cl,'title'); set(cl_title,'string','N_C_C_N / cm^3','unit','norm');
%    pos = get(cl_title,'position'); new_pos = pos; new_pos(1) = 1; new_pos(2) = -0.075; set(cl_title,'position',new_pos);
%    disp('');
   
 end
%%
disp('')

%%
return