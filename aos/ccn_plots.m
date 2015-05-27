% Examine Oct 1,
function ccn_plots ( ccn100)
if ~exist('ccn100','var')
ccn100 = anc_bundle_files;
end
% ccn100 = anc_plot_qcs_sets;

[~,fname] = fileparts(ccn100.fname);
[fname,rest] = strtok(fname,'.');
fname = [fname, '.',strtok(rest,'.')];

%%
if isfield(ccn100.vdata, 'CCN_temperature_std')
   std_bad = ccn100.vdata.CCN_temperature_std>0.045;
else
   std_bad = false(size(ccn100.vdata.CCN_baseline_monitor));
end
if isfield(ccn100.vdata, 'CCN_t_read_TEC3')
   ccn100.vdata.CCN_T_read_TEC3 = ccn100.vdata.CCN_t_read_TEC3; ccn100.vdata = rmfield(ccn100.vdata, 'CCN_t_read_TEC3');
   ccn100.vdata.CCN_T_read_TEC2 = ccn100.vdata.CCN_t_read_TEC2; ccn100.vdata = rmfield(ccn100.vdata, 'CCN_t_read_TEC2');
   ccn100.vdata.CCN_T_read_TEC1 = ccn100.vdata.CCN_t_read_TEC1; ccn100.vdata = rmfield(ccn100.vdata, 'CCN_t_read_TEC1');
   ccn100.vdata.CCN_supersaturation_set_point = ccn100.vdata.CCN_ss_set; ccn100.vdata = rmfield(ccn100.vdata, 'CCN_ss_set');
   
   ccn100.ncdef.vars.CCN_T_read_TEC3 = ccn100.ncdef.vars.CCN_t_read_TEC3; ccn100.ncdef.vars = rmfield(ccn100.ncdef.vars, 'CCN_t_read_TEC3');
   ccn100.ncdef.vars.CCN_T_read_TEC2 = ccn100.ncdef.vars.CCN_t_read_TEC2; ccn100.ncdef.vars = rmfield(ccn100.ncdef.vars, 'CCN_t_read_TEC2');
   ccn100.ncdef.vars.CCN_T_read_TEC1 = ccn100.ncdef.vars.CCN_t_read_TEC1; ccn100.ncdef.vars = rmfield(ccn100.ncdef.vars, 'CCN_t_read_TEC1');
   ccn100.ncdef.vars.CCN_supersaturation_set_point = ccn100.ncdef.vars.CCN_ss_set; ccn100.ncdef.vars = rmfield(ccn100.ncdef.vars, 'CCN_ss_set');
end
if isfield(ccn100.vdata,'CCN_temp_stabilized')
   ccn100.vdata.CCN_temp_unstable = ccn100.vdata.CCN_temp_stabilized;
   ccn100.vdata = rmfield(ccn100.vdata, 'CCN_temp_stabilized');
   ccn100.ncdef.vars.CCN_temp_unstable = ccn100.ncdef.vars.CCN_temp_stabilized;
   ccn100.ncdef.vars = rmfield(ccn100.ncdef.vars, 'CCN_temp_stabilized');
elseif isfield(ccn100.vdata, 'CCN_temp_unstable_flag')
   ccn100.vdata.CCN_temp_unstable = ccn100.vdata.CCN_temp_unstable_flag;
   ccn100.vdata = rmfield(ccn100.vdata,'CCN_temp_unstable_flag');
   ccn100.ncdef.vars.CCN_temp_unstable = ccn100.ncdef.vars.CCN_temp_unstable_flag;
   ccn100.ncdef.vars = rmfield(ccn100.ncdef.vars,'CCN_temp_unstable_flag');
end
% miss = ccn100.vdata.CCN_T_read_TEC3<-9000 | ccn100.vdata.CCN_T_read_TEC1<-9000 | ccn100.vdata.CCN_temp_stabilized>0;
% ss_bad = ccn100.vdata.CCN_supersaturation_set_point ~= round(100.*ccn100.vdata.CCN_supersaturation_set_point)./100
% grad_meas = ccn100.vdata.CCN_T_read_TEC3 - ccn100.vdata.CCN_T_read_TEC1;
% [ss_sets,ii] = unique(round(100.*ccn100.vdata.CCN_supersaturation_set_point(~(miss|std_bad)))./100);
% else
% std_bad = abs(diffN(ccn100.vdata.CCN_T_read_TEC3))>0.06;
miss = ccn100.vdata.CCN_T_read_TEC3<-9000 | ccn100.vdata.CCN_T_read_TEC1<-9000 | ccn100.vdata.CCN_temp_unstable>0;
ss_bad = ccn100.vdata.CCN_supersaturation_set_point ~= round(100.*ccn100.vdata.CCN_supersaturation_set_point)./100;
grad_meas = ccn100.vdata.CCN_T_read_TEC3 - ccn100.vdata.CCN_T_read_TEC1;
grad_meas(miss) = NaN; ccn100.vdata.CCN_temperature_gradient(miss) = NaN;
[ss_sets,ii] = unique(round(100.*ccn100.vdata.CCN_supersaturation_set_point(~(miss|std_bad)))./100);
% min_ss = min(ss_sets); 
% ss_sets = ss_sets - min(ss_sets);
% ccn100.vdata.CCN_supersaturation_set_point - min_ss;
low_ss = -0.01;
% end

% ss_bad = ccn100.vdata.CCN_ss_set ~= round(100.*ccn100.vdata.CCN_ss_set)./100


% colormap(jet_rgb);
% figure; plot(serial2doys(ccn100.time), ccn100.vdata.CCN_temperature_gradient, 'bo',...
%     serial2doys(ccn100.time), grad_meas,'cx');legend('in file','my diff')
% figure; scatter(serial2doys(ccn100.time(~miss)), grad_meas(~miss),32,ccn100.vdata.CCN_temperature_gradient(~miss),'filled');legend('in file','my diff')
%%
ccn100 = anc_sift(ccn100, ~(miss|ss_bad|std_bad));
[pname,fname,~] = fileparts(ccn100.fname);
fstem = strtok(fname, '.');
cpcs = dir([pname, filesep,strrep(fstem,'aosccn100','aoscpc'),'.*.',datestr(ccn100.time(1),'yyyymmdd'),'.*']);
if length(cpcs)==1
   cpc = anc_load([pname, filesep,cpcs.name]);
   [ainb, bina] = nearest(ccn100.time, cpc.time);
cpc = anc_sift(cpc, bina);
end

% grad_meas = ccn100.vdata.CCN_T_read_TEC3 - ccn100.vdata.CCN_T_read_TEC1;

miss = ccn100.vdata.CCN_T_read_TEC3<-9000 | ccn100.vdata.CCN_T_read_TEC1<-9000 | ccn100.vdata.CCN_temp_unstable>0;
ss_bad = ccn100.vdata.CCN_supersaturation_set_point ~= round(100.*ccn100.vdata.CCN_supersaturation_set_point)./100;
if isfield(ccn100.vdata, 'CCN_temperature_std')
   std_bad = ccn100.vdata.CCN_temperature_std>0.045;
else
   std_bad = false(size(ccn100.vdata.CCN_baseline_monitor));
end
hr = [floor(min(serial2doys(ccn100.time))):1/24:ceil(max(serial2doys(ccn100.time)))];
doy = serial2doys(ccn100.time);
that = false(size(ccn100.time));
%%
for hh = length(hr):-1:2;
   miss = ccn100.vdata.CCN_T_read_TEC3<-9000 | ccn100.vdata.CCN_T_read_TEC1<-9000 | ccn100.vdata.CCN_temp_unstable>0;
   this = ~(miss|std_bad|ss_bad) & doy>=hr(hh-1)&doy<hr(hh)&ccn100.vdata.CCN_supersaturation_set_point>low_ss;
   
   for s = length(ss_sets):-1:1
      ss_good = this & (ccn100.vdata.CCN_supersaturation_set_point == ss_sets(s));
      ss_good(ss_good) = inner(ccn100.vdata.N_CCN(ss_good));
      that(ss_good) = true;
      hour(hh).ss(s) = ss_sets(s);
      hour(hh).N_CCN(s) = mean(ccn100.vdata.N_CCN(ss_good));
%       if exist('cpc','var')
%       hour(hh).N_CPC(s) = mean(cpc.vdata.concentration(ss_good));
%       end
      hour(hh).std_N_CCN(s) = std(ccn100.vdata.N_CCN(ss_good));
      hour(hh).N_CCN_num(s) = sum(ss_good);
      hour(hh).N_CCN_dN(:,s) = mean(ccn100.vdata.N_CCN_dN(:,ss_good),2);
   end
   pos = hour(hh).ss>0&~isNaN(hour(hh).N_CCN);
   hour(hh).P = polyfit(log10(hour(hh).ss(pos)), hour(hh).N_CCN(pos),2);
   hour(hh).maxN = hour(hh).P(end);
   hour(hh).P = hour(hh).P./hour(hh).maxN;
   
   
   
   figure(95);clf
   s(1)=subplot(2,1,2); scatter(ccn100.vdata.CCN_supersaturation_set_point(this), ccn100.vdata.N_CCN(this),32,[.5,.5,.5],'filled');
   hold('on');
   scatter(ccn100.vdata.CCN_supersaturation_set_point(this&that), ccn100.vdata.N_CCN(this&that),32,ccn100.vdata.CCN_supersaturation_set_point(this&that),'filled');
   hold('off');
   colorbar
   xlabel('ss% set point');
   ylabel('N_C_C_N / cm^3');
   colormap(jet_rgb);
   
   s(2)=subplot(2,1,1); 
%    figure(94)
   scatter(serial2hs(ccn100.time(this)), ccn100.vdata.N_CCN(this),32,[0.5,0.5,0.5],'filled');
   hold('on');
   scatter(serial2hs(ccn100.time(this&that)), ccn100.vdata.N_CCN(this&that),32,ccn100.vdata.CCN_supersaturation_set_point(this&that),'filled');colorbar

%    scatter(serial2hs(ccn100.time(this)), ccn100.vdata.N_CCN(this)./cpc.vdata.concentration(this),32,[0.5,0.5,0.5],'filled');
%    hold('on');
%    scatter(serial2hs(ccn100.time(this&that)), ccn100.vdata.N_CCN(this&that)./cpc.vdata.concentration(this&that),32,ccn100.vdata.CCN_supersaturation_set_point(this&that),'filled');colorbar
   hold('off')
   ax_1(3) = gca;
   colorbar
   xlabel('time [UTC]');
   ylabel('N_C_C_N / cm^3')
   colormap(jet_rgb);
   
   tl = title([fname, ' : ',datestr(min(ccn100.time(this)),'yyyy-mm-dd at HH:00 UTC')]); set(tl,'interp','none')
   
   s(1)=subplot(2,1,2);
   hold('on')
   plot(hour(hh).ss, polyval(hour(hh).P,log10(hour(hh).ss)).*hour(hh).maxN,'k-', hour(hh).ss, hour(hh).N_CCN, 'ko');
   hold('off')
   xlabel('ss% set point');
   ylabel('mean N_C_C_N / cm^3');
   colormap(jet_rgb);
   
   figure(96);
   if ~isfield(ccn100.vdata,'size_bin')
      ccn100.vdata.size_bin = [1:size(ccn100.vdata.N_CCN_dN,1)];
   end
   nbins = length(ccn100.vdata.size_bin);
   these = plot([1:nbins], ccn100.vdata.N_CCN_dN(:,this),'-');
   colormap(jet_rgb);
   recolor(these,ccn100.vdata.CCN_supersaturation_set_point(this)); colorbar
   xlabel('bin number');
   ylabel('N_C_C_N / cm^3 / bin')
   tl = title([fname,': ', datestr(min(ccn100.time(this)),'yyyy-mm-dd HH:00')]); set(tl,'interp','none')
   
   these = plot([1:nbins], hour(hh).N_CCN_dN,'-');
   colormap(jet_rgb);
   recolor(these,hour(hh).ss); colorbar
   xlabel('bin number');
   ylabel('N_C_C_N / cm^3 / bin')
   tl = title({fname; datestr(min(ccn100.time(this)),'yyyy-mm-dd HH:00')}); set(tl,'interp','none')
   
   
%    figure(99);
%    % this figure plots the data after sorting by supersaturation set point, so the x-axis is more or less good if the durations
%    % of the supersaturations are similar.
%    this_ii = find(this);
%    [by_ss.ss_sets, ij] = sort(ccn100.vdata.CCN_supersaturation_set_point(this_ii));
%    by_ss.N_CCN_dN = ccn100.vdata.N_CCN_dN(1:nbins,this_ii(ij));
%    imagesc(by_ss.ss_sets, [1:nbins],by_ss.N_CCN_dN); axis('xy'); cl =colorbar;
%    colormap(jet_rgb);
%    xlabel('% super-saturation');
%    ylabel('bin number');
%    cl_title = get(cl,'title'); set(cl_title,'string','N_C_C_N / cm^3','unit','norm');
%    pos = get(cl_title,'position'); new_pos = pos; new_pos(1) = 1; new_pos(2) = -0.075; set(cl_title,'position',new_pos);
%    
%    figure(101);
%    [by_ss.ss_sets, ij] = sort(hour(hh).ss);
%    by_ss.N_CCN_dN = hour(hh).N_CCN_dN(:,ij);
%    imagesc(by_ss.ss_sets, [1:nbins],by_ss.N_CCN_dN); axis('xy'); cl =colorbar;
%    colormap(jet_rgb);
%    xlabel('% super-saturation');
%    ylabel('bin number');
%    cl_title = get(cl,'title'); set(cl_title,'string','N_C_C_N / cm^3','unit','norm');
%    pos = get(cl_title,'position'); new_pos = pos; new_pos(1) = 1; new_pos(2) = -0.075; set(cl_title,'position',new_pos);
%    
%    % this figure plots the data chronologically as collected, so the x-axis is bogus.
%    figure(97);
%    imagesc(serial2hs(ccn100.time(this)), [1:nbins],(ccn100.vdata.N_CCN_dN(1:nbins,this))); axis('xy'); cl =colorbar;
%    xlabel('time (UTC)');
%    ylabel('bin number');
%    colormap(jet_rgb);
%    tl = title({fname; datestr(min(ccn100.time(this)),'yyyy-mm-dd HH:00')}); set(tl,'interp','none');
%    cl_title = get(cl,'title'); set(cl_title,'string','N_C_C_N / cm^3','unit','norm');
%    pos = get(cl_title,'position'); new_pos = pos; new_pos(1) = 1; new_pos(2) = -0.075; set(cl_title,'position',new_pos);
%    disp('');
   
end
%%
disp('')

%%
return