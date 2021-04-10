function [anc_, ax] = ARM_display(anc)
% anc = ARM_ds_display(anc);
% attempting to link x-axes for plots with same x-data.
%Applies QC to interactively selected fields.  Also generates affigu
%red/yellow/green image representing the qc tests

% Fixed bug identifying qc fields (spotted by Justin) when fieldnames are
% less than 3 chars long.
% Strips n-dimensioned fields
% Adding histgram creation, in progress
% Returning time vector from plot for aid in refining histogram bounds

% Eliminate figure(55) which held strip charts of fields identified via QC
% Just too many, figures became unviewable.
% Also split bi-panel plot into two figures
% See if dynamicDateTicks is slowing the plot update
% See about using dynamicDateTicks with serial dates and other hh, doys, ii
% as desired.
% See about incorporating interactive masking and output of flags field.
% see about incorporating DQR and/or identified qc fields
if isempty(who('anc'))
   anc = anc_bundle_files;
end
[~, ds] = fileparts(anc.fname); [ds_stem, ds] = strtok(ds,'.');ds_level = strtok(ds,'.');
ds_(1) = {[ds_stem,'.',ds_level]};


% Strip out the qc fields with matching fields.
fields = fieldnames(anc.vdata);
for i = length(fields):-1:1
   blah = strfind(fields{i},'qc_');
   if (~isempty(blah)&&isfield(anc.vdata, fields{i}((blah+3):end)))||strcmp(fields{i},'time_bounds')
      fields(i) = [];
   end
end
% fields_order = fields;
% [~,id_to_az] = sort(upper(fields));
% [~, az_to_id] = sort(id_to_az);
% fields_az = fields(id_to_az);


plt.Color = 'b';
plt.Marker = '.';
plt.MarkerSize = 6;
plt.LineStyle = 'none';
plt.LineWidth = 2;
plt.MarkerEdgeColor = 'b';
plt.MarkerFaceColor = 'none';
% plt.DisplayName = [];
forward = true;
qc_mode = 2; QCS = ['*no BAD*'];

if ~isempty(fields)
   
   f = 0;
%    axi = 0;
   fig.fig = [];
   fig.field = {};
   ax = [];
   fig_99 = 69; %default starting point for plots of static fields
   % allowing 30 static fields to be displayed before collision
   new_figure = false;
   overwrite = true;
   if overwrite
      hold_str = 'OFF';
      nextplot = 'replace';
   else
      hold_str = 'ON';
      nextplot = 'add'
   end
   
   while (f>=0)
      ok = menu('',{'Pick field...';'Next';'Previous';'New Figure';...
         ['Toggle Hold <',hold_str,'>'];['Set QC mode <',QCS,'>'];'Settings for Masked/NO QC';'Histogram';...
         'Trim time series';'Axes scale';'Get other data';'Export to ASCII';'Save image...';'Done'});
      % 1 'Select field...'
      % 2 'Next field'
      % 3 'Previous field'
      % 4  New figure
      % 5 Set Hold ON/OFF
      % 6 Select QC mode
      % 7 Modify plot settings
      % 8 Generate a histogram
      % 9 Trim the data set
      % 10 Axes scale
      % 11 Select some more data
      % 12 Export to ASCII
      % 13 Save the image to file
      % 14 'Done'}
      % clean up figures and axes
      bad_fig = ~ishandle(fig.fig);
      fig.fig(bad_fig) = [];
      fig.field(bad_fig) = [];
      ax(bad_fig) = [];
      axi = length(fig.fig);
      all_ax = [];
      for xx = 1:length(ax)
         all_ax = [all_ax, ax{xx}];
      end
      if ~isempty(who('field'))&&~isempty(anc.ncdef.vars.(field).dims{1}) ...
            && any(strcmp(anc.ncdef.recdim.name,anc.ncdef.vars.(field).dims))
         last_ax = gca;
         last_lim = xlim(last_ax);
      end
      
      if ok==1       % 3 'Pick Field...';
         f = menu_list(fields,f);
      elseif ok==2       % 1 'Next';
         forward = true;
      elseif ok==3       % 2 'Previous';
         forward = false;
      elseif ok==4       % 4 'New figure window';
         new_figure = true;
      elseif ok==5
         overwrite = ~overwrite;
         if overwrite
            hold_str = 'OFF';
            nextplot = 'replace';
         else
            hold_str = 'ON';
            nextplot = 'add';
         end
      elseif ok==6       % 5 'Set QC mode;
         QC = menu('Set QC mode:','no QC','no BAD','only GOOD', 'summary','detailed');
         qc_mode = QC;
         if QC==1
            QCS = ['*no QC*'];
         elseif QC==2
            QCS = ['*no BAD*'];
         elseif QC==3
            QCS = ['*only GOOD*'];
         elseif QC==4
            QCS = ['*QS*'];
         elseif QC==5
            QCS = ['*QC*'];
         end
      elseif ok==7 % Adjust plot settings...
         plt = adjust_plot_settings(plt);
      elseif ok==8   % Generate histogram
         gen_hist(anc, field,ax);
         
      elseif ok==9 % Trim time-series
         ready = menu('Zoom into a figure to define the time range to retain. Select OK when done','OK', 'Cancel');
         if ready==1
            xl = xlim;
            anc = anc_sift(anc, anc.time>=xl(1)&anc.time<=xl(2));
         end
      elseif ok==10 % Axes scale
         done_y = false;
%          answer = [-inf, inf];
         x_reset = menu('Reset X-axis limits?','No','Yes');
         if x_reset>1
            xlim(gca,[min(anc.time), max(anc.time)]); last_lim = xlim(gca);
         end
         while ~done_y
            %          while ~isempty(answer)
            lin_log = menu('y-axis type: ','Linear','Log10');
            if lin_log==1
               liny;
            else
               logy;
            end
            ylims = menu('Use manual or Auto y-limits? ','Manual','Auto');
            if ylims == 1
               set(gca, 'ylimmode','manual');
               ax_ylim = ylim;
               prompt = {'Y-max:','Y-min:'};            
               dlg_title = 'Enter y limits (select "Cancel" when applied limits are OK.)';
               num_lines = 1;
               def = {sprintf('%g',ax_ylim(2)),sprintf('%g',ax_ylim(1))}';
               options.WindowStyle = 'normal';               
               answer = inputdlg(prompt,dlg_title,num_lines,def,options);
               if ~isempty(answer)&&~(strcmp(def{1},answer{1})&&strcmp(def{2},answer{2}))
                  ylim([min(str2double(answer{2})), max(str2double(answer{1}))]);
               end
            elseif ylims ==2
               set(gca, 'ylimmode','auto');
            end
            done_y = menu('Done with y-axis settings?','No','Yes');
            if done_y==1
               done_y = false;
            else
               done_y = true;
            end
         end
%          set(gca,'ylim',ylim, 'ylimmode','manual');
      elseif ok==11 % Select more data
%          new_figure = true;
         if isempty(who('anc_'))
            anc_(1) = {anc};
         end
         % here was the change between brackets and braces
         DS = menu('Select DS',[ds_, {'Browse...'}]);
         if DS > length(ds_)
            clear anc
            anc = anc_bundle_files;
            [~, ds] = fileparts(anc.fname); [ds_stem, ds] = strtok(ds,'.');ds_level = strtok(ds,'.');
            dstream = [ds_stem,'.',ds_level];
            found = false; d = 0;
            while ~found && d< length(ds_)
               d = d+1;
               if strcmp(ds_(d),dstream)
                  anc = anc_cat(anc, anc_{d}); anc_(d) = {anc};
                  found = true;
               end
            end
            if ~found
               ds_(end+1) = {dstream};
               anc_(end+1) = {anc};
            end
         else
            anc = anc_{DS};
         end
         fields = fieldnames(anc.vdata);
         for i = length(fields):-1:1
            blah = strfind(fields{i},'qc_');
            if (~isempty(blah)&&isfield(anc.vdata, fields{i}((blah+3):end)))||strcmp(fields{i},'time_bounds')
               fields(i) = [];
            end
         end
         f = menu_list(fields,f);
%          fields_order = fields;
%          [~,id_to_az] = sort(upper(fields));
%          [~, az_to_id] = sort(id_to_az);
%          fields_az = fields(id_to_az);
         
      elseif ok==12       % 12  Export to ASCII
          if ~isempty(who('field'))
              [~,anc_fname] = fileparts(anc.fname);
              extras.pname = getnamedpath('ascii_out');
              extras.dsname = strtok(anc_fname,'.');
              extras.plotname = field;
              extras.trim = [];
              menu('Click on an image and then select OK...','OK')              
              extract_plot_data(gcf,extras);
          else
              disp('No field selected yet.')
          end
      elseif ok==13       % 13 save image
         if ~isempty(who('field'))
            [fname, pname] =putfile([field,'.png']);
            saveas(gcf, fullfile(pname,fname));
            [~, fn_, ~] = fileparts(fname);
            saveas(gcf, fullfile([pname,fn_, '.fig']));            
         else
            disp('No field selected yet.')
         end
      else
         f = -1;
      end
      % 1 'Select field...'
      % 2 'Next field'
      % 3 'Previous field'
      % 4  New figure
      % 5 Set Hold ON/OFF
      % 6 Select QC mode
      % 7 Modify plot settings
      % 8 Generate a histogram
      % 9 Trim the data set
      % 10 Y limits
      % 11 Select some more data
      % 12 Save the image to file
      % 13 'Done'}
      if ok==2 || ok==3 || ok==4 && f>=0
         f = f +double(forward) - double(~forward);
         if f>length(fields)
            f =1;
         elseif f<=0
            f = length(fields);
         end
      end
      if f>0
         if f>length(fields)
            f =1;
         elseif f<=0
            f = length(fields);
         end
         field = fields{f};
         %          if isempty(ax) && f>0
         %             axi = axi +1;
         %             fig(axi) = figure;
         %             new_figure = false;
         %          end
         if new_figure
            if isempty(anc.ncdef.vars.(field).dims{1})
               fig_99 = fig_99+1;
               fig_99 = figure_(fig_99);
               new_figure = false;
            else
               if ok~=8
                  axi = axi +1;
               end
               kids = double(allchild(0));
               if isempty(kids)
                  kids = 0;
               end
               next_fig =  100.*(max(floor(kids./100))+1) +1;
               fig.fig(axi) = figure_(next_fig);
               fig.field(axi) = {field};
               new_figure = false;
               if axi>1
                  set(fig.fig(axi-1),'units','normalized')
                  newpos = get(fig.fig(axi-1),'Position');
%                   newpos(1) = newpos(1)+0.9*newpos(3);
                  newpos(1) = newpos(1) + 0.02; newpos(2) = newpos(2) - 0.04; 
                  set(fig.fig(axi),'units','normalized','position',newpos);
               end
            end
         end
         
         % Determine kind of field: eg static, coord, rec, n-dim
         % If not changing overwrite, histogram, trimming, saving to file, or done
         if ~(ok==5 || ok==8|| ok==9 || ok==10 || ok==12 || ok==13 )
            if isempty(anc.ncdef.vars.(field).dims{1})
               if ~isempty(fig.fig)&&isempty(get(fig.fig(axi),'children'))
                  close(fig.fig(axi));
                  fig.fig(axi) = [];
                  axi = axi -1;
               end
               figure_(fig_99); % don't count these figures and axes.
               %This is a static field with no dimenion
               text_string = {[sprintf(['Static Field "',field,'" = ']),num2str(anc.vdata.(field))]};
               if ~isempty(strfind(field,'time'))
                  
                  if isfield(anc.vatts.(field),'string')
                     val = anc.vatts.(field).string;
                     text_string(end+1) = {val};
                     text_string(end+1) = {datestr(epoch2serial(anc.vdata.(field)),'yyyy-mm-dd HH:MM:SS')};
                  elseif ~isempty(strfind(anc.vatts.(field).units),'since')
                     units = anc.vatts.(field).units;
                     ii = strfind(units,'since') + 6;
                     units = units(ii:end);
                     val = datenum(units,'yyyy-mm-dd HH:MM:SS');
                     val = serial2epoch(val);
                     val = val + anc.vdata.(field);
                     val = epoch2serial(val);
                     text_string(end+1) = {[datestr(val),'yyyy-mm-dd HH:MM:SS.fff']};
                  else
                     disp('Unhandled time format')
                     text_string(end+1) = {num2str(anc.vdata.(field))};
                  end
               else
                  text_string = text_string{:};
               end
               clf;
               text(0.1,.5,text_string,'interp','none');
            elseif ~any(strcmp(anc.ncdef.recdim.name,anc.ncdef.vars.(field).dims))
               disp([field, ' is a static dimensioned field.'])
               % This is a static dimensioned field.
            elseif length(anc.ncdef.vars.(field).dims)==1
               
               disp([field, ' is a single-dimensioned time trace.'])
               % I think this must be a single-dimensioned time series
               %determine qc type, if any
               
               if axi==0
                  axi = 1;
                  kids = double(allchild(0));
                  if isempty(kids)
                     kids = 0;
                  end
                  next_fig =  100.*(max(floor(kids./100))+1) +1;
                  
                  fig.fig(axi) = figure_(next_fig);
                  new_figure = false;
                  %                else
                  %                   fig.field(axi) = {field};
                  %                   figure_(fig.fig(axi));
               end
               % Maybe use plot_no_qc for masked QC also.
               % Maybe update plotting syntax to use mask
               set(gca,'NextPlot',nextplot);
               if qc_mode<4 || ~isfield(anc.vdata,['qc_',field])
                  [~,ax{axi},~] = plot_masked_qc(anc, field,plt,qc_mode);
%                   [status,ax{axi},time_] = plot_masked_qc(anc, field,plt,qc_mode);
               elseif qc_mode==4 || (isfield(anc.gatts,'datastream')&&~isempty(strfind(anc.gatts.datastream,'.s1')>0))||...
                     (isfield(anc.vatts.(['qc_',fields{f}]),'description')...
                     &&(~isempty(findstr('0 = Good',anc.vatts.(['qc_',fields{f}]).description)))...
                     &&(~isempty(findstr('1 = Indeterminate',anc.vatts.(['qc_',fields{f}]).description)))...
                     &&(~isempty(findstr('2 = Bad',anc.vatts.(['qc_',fields{f}]).description)))...
                     &&(~isempty(findstr('3 = Missing',anc.vatts.(['qc_',fields{f}]).description)))) % plot summary qs
                  
                  [~,ax{axi},~] = anc_plot_s_qcd(anc, field);
               elseif qc_mode==5 % qc_mode ==5, so plot details as vap or mentor qc, as applicable
                  if isfield(anc.vatts.(['qc_',fields{f}]),'bit_1_description')
                     [~,ax{axi},~,~] = anc_plot_vap_qcd(anc, field);
                     
                  else
                     [~,ax{axi},~,~] = anc_plot_mentor_qcd(anc, field);
                  end
                  %                   elseif qc_mode == 3
                  %                      [status,ax{axi},time_,qc_impact] = anc_plot_good_qcd(anc, field);                  
               end                              
            else
               disp([field, ' is a multi-dimensioned time series.'])
               % Cases: 2D data, 1D QC
               set(gca,'NextPlot',nextplot);
               if isfield(anc.vdata,fields{f})&&isfield(anc.vdata,['qc_',fields{f}])
                  if isfield(anc.vatts.(['qc_',fields{f}]),'bit_1_description')&&(qc_mode==2)
                     %Plot detailed QC
                     [~,ax{axi},~,~] = anc_plot_vap_qcd(anc, field);
                  elseif ~isempty(strfind(anc.gatts.datastream,'.s1')>0)||...
                        (isfield(anc.vatts.(['qc_',fields{f}]),'description')...
                        &&(~isempty(findstr('0 = Good',anc.vatts.(['qc_',fields{f}]).description)))...
                        &&(~isempty(findstr('1 = Indeterminate',anc.vatts.(['qc_',fields{f}]).description)))...
                        &&(~isempty(findstr('2 = Bad',anc.vatts.(['qc_',fields{f}]).description)))...
                        &&(~isempty(findstr('3 = Missing',anc.vatts.(['qc_',fields{f}]).description))))
                     
                     %Then this is S level QC
                     [~,ax{axi},~] = anc_plot_s_qcd(anc, field);
                     
                  else
                     [~,ax{axi},~,~] = anc_plot_mentor_qcd(anc, field);
                  end
               else
                  %This is not a qc field
%                   [status,ax{axi},time_] = plot_no_qc(anc, field,plt);
               end
            end
         end
         
         if ~isempty(anc.ncdef.vars.(field).dims{1}) ...
               && any(strcmp(anc.ncdef.recdim.name,anc.ncdef.vars.(field).dims))
            
            bad_fig = ~ishandle(fig.fig);
            fig.fig(bad_fig) = [];
            fig.field(bad_fig) = [];
            ax(bad_fig) = [];axi = length(fig.fig);
            %             if ishandle(55)
            %                kids_55 = get(55,'children');
            %                not_axis = ~strcmp(get(kids_55,'type'),'axes');
            %                kids_55(not_axis) = [];
            %                not_axis = strcmp(get(kids_55,'tag'),'legend');
            %                kids_55(not_axis) = [];
            %             else
            %                kids_55 = [];
            %             end
            %             all_ax = kids_55';
            all_ax = [];
            for xx = 1:length(ax)
               all_ax = [all_ax, ax{xx}];
            end
            if (length(all_ax)>=1)
               
               linkaxes(all_ax,'x');
               dynamicDateTicks(all_ax,'linked','yyyy-mm-dd');
               if ~isempty(who('last_lim'))
                  xlim(last_lim);
               end
            end
            %             if exist('last_lim','var')
            %                xlim(gca, last_lim);
            %             else
            %                last_ax = gca;
            %                last_lim = xlim(last_ax);
            %             end
         end
      end % end of while
   end
   % close(fig);
   
end % End of if

if isempty(who('anc_')) || length(anc_)==1
   anc_ = anc;
end

return

function [status,ax, time_] = plot_masked_qc(anc, field,plt,qc_mode)
%[status,ax, time_] = plot_masked_qc(anc, field,plt, qc_mode);
% Generates plot with missings and qc masked out according to qc_mode
% qc_type==1 ==>> no QC
% qc_type==2 ==>> no BAD
% qc_type==3 ==>> only GOOD

% So, here's the idea.  If explicitly told "NO QC" (qc_mode==1) then plot
% the data 'as is', missings and all.
%Else, check whether there is any QC, and if so if it is detailed or
%summary.
% Next, mask out either "bad" or "bad"|"suspect"  depending on whether qc_mode is 2 or 3

qc_str = {' [no QC]', ' [no BAD]', ' [only GOOD]'};
status = 0;
if isempty(get(gcf,'children'))
   ax = subplot(1,1,1);
else
   ax = gca;
end

traces = length(legend(ax));
if traces>0 && strcmp(get(ax,'NextPlot'),'add')
   plt = adjust_plot_settings(plt);
end


if isfield(anc.vdata,field)

   status = 1;
   [~,fname,ext] = fileparts(anc.fname); fname = [fname,ext];
   
   var = double(anc.vdata.(field));
   vatt = anc.vatts.(field);
   if ~isfield(vatt,'units')
      vatt.units = 'unitless';
   end
   mask = zeros(size(anc.vdata.(field)));
   if ~(qc_mode==1)
      missing = isNaN(var)|((var<-9998)&(var>-10000))|~isfinite(var)|~isnumeric(var);
      mask(missing) = NaN;
      
      qc_field = ['qc_',field];
      if isfield(anc.vatts, qc_field)
         if isfield(anc.vatts, qc_field) && ...
               isfield(anc.vatts.(qc_field),'bit_1_assessment') && ...
               ~isfield(anc.vatts.(qc_field),'bit_1_description')
            anc.vatts.(qc_field).('bit_1_description') = '';
            anc.vatts.(qc_field).('bit_1_assessment') = 'Bad';
         end
         % check if already a summary qc field
         if ~isempty(strfind(anc.gatts.datastream,'.s1')>0)||...
               (isfield(anc.vatts, qc_field) && isfield(anc.vatts.(qc_field),'description')...
               &&(~isempty(findstr('0 = Good',anc.vatts.(qc_field).description)))...
               &&(~isempty(findstr('1 = Indeterminate',anc.vatts.(qc_field).description)))...
               &&(~isempty(findstr('2 = Bad',anc.vatts.(qc_field).description)))...
               &&(~isempty(findstr('3 = Missing',anc.vatts.(qc_field).description))))
            %Then this is S level QC
            impact = anc.vdata.(qc_field);
         elseif isfield(anc.vatts, qc_field) && isfield(anc.vatts.(qc_field),'bit_1_description')
            impact = anc_qc_impacts(anc.vdata.(qc_field), anc.vatts.(qc_field));
         end
         if qc_mode ==2 % mask out impact>1, but check dimensionality
            if all(size(anc.vdata.(field))==size(anc.vdata.(qc_field)))
               mask(impact>1) = NaN;
            else
               mask(:,impact>1) = NaN;
            end
         elseif qc_mode==3 % mask out impact>0, but check dimensionality
            if all(size(anc.vdata.(field))==size(anc.vdata.(qc_field)))
               mask(impact>0) = NaN;
            else
               mask(:,impact>0) = NaN;
            end            
         end
      else %no qc field, but supposed to apply QC mask so define impact based on missings
         mask(missing) = NaN;
         qc_mode = 1;
      end
      
   end
   
   time_ = anc.time;
   time_str = 'time [UTC]';
   %     first_time =  min(anc.time);
   %     last_time = max(anc.time);
   %     first_V = datevec(first_time);
   %     last_V = datevec(last_time);
   %     dt = last_time - first_time;
   %
   %
   %     if isempty(dt)
   %         time_ = (anc.time - datenum(datestr(first_time,'yyyy-mm-dd HH:MM:00'),'yyyy-mm-dd HH:MM:SS'))*24*60*60;
   %         time_str = 'seconds from 00:00 UTC';
   %     elseif dt <= 1/(24*60)
   %         time_ = (anc.time - datenum(datestr(first_time,'yyyy-mm-dd HH:MM:00'),'yyyy-mm-dd HH:MM:SS'))*24*60*60;
   %         time_str = 'seconds from start of minute';
   %     elseif (dt<=1/24)
   %         time_ = (anc.time - datenum(datestr(first_time,'yyyy-mm-dd HH:00'),'yyyy-mm-dd HH:MM'))*24*60;
   %         time_str = 'minutes from top of hour UTC';
   %     elseif (dt<=1)
   %         time_ = (anc.time - datenum(datestr(first_time,'yyyy-mm-dd'),'yyyy-mm-dd'))*24;
   %         time_str = 'hours from 00:00 UTC';
   %     elseif (dt<=31)
   %         time_ = (anc.time - datenum(datestr(first_time,'yyyy-mm-01'),'yyyy-mm-01')+1);
   %         time_str = ['days since ', datestr(first_time, 'mmm 1, yyyy')];
   %     elseif (dt<=730)
   %         time_ = (anc.time - datenum(datestr(first_time,'yyyy-01-01'),'yyyy-01-01')+1);
   %         time_str = ['days since ', datestr(first_time, 'Jan 1, yyyy')];
   %     else
   %         time_ = (anc.time - datenum(datestr(first_time,'yyyy-01-01'),'yyyy-01-01'))./365.25;
   %         time_str = ['years since ', datestr(first_time, 'Jan 1, yyyy')];
   %     end
   if (length(anc.ncdef.vars.(field).dims)==1)
      if ~isempty(findstr(anc.ncdef.recdim.name,anc.ncdef.vars.(field).dims{end}))
         %          if all(missing)
         %             plot(time_([1 end]),[0 1],'r-',time_([1 end]),[1 0],'r-');
         %             ylabel(vatt.units);
         %             lg = legend('all missing',field);
         %             set(lg,'interpreter','none')
         %             title(field,'interpreter','none');
         %
         %          else
         leg_str = get(legend,'string');
         if isempty(leg_str)||~strcmp(get(gca,'NextPlot'),'add')
            leg_str = {};
         end
         pt = plot(time_,real(var)+mask);
         %   pt = plot(time_(~missing),real(var(~missing)));
         for fld = fieldnames(plt)'
            set(pt,char(fld), plt.(char(fld)));
         end
         ylabel(vatt.units);
         ylim(ylim);
         try
            leg_str(end+1) = {[field,qc_str{qc_mode}]};
         catch
            warning('Catch this legend error...')
         end
         lg = legend(gca,leg_str);
         set(lg,'interp','none','Location','best');
         [~,fstem,~] = fileparts(anc.fname);
         [tok1,rest] = strtok(fstem,'.');
         [tok2,~]= strtok(rest,'.');
         title({[tok1,'.' tok2];vatt.long_name},'interpreter','none');
         xlabel(time_str);
         %          end
      else %not dimensioned against time, recdim
      end
   elseif (length(anc.ncdef.vars.(field).dims)==2)
      if ~isempty(findstr(anc.ncdef.recdim.name,anc.ncdef.vars.(field).dims{end}))
         %          xax = serial2doy(anc.time);
         %          xlab = 'time (UTC hours)';
         if isfield(anc.ncdef.vars,anc.ncdef.vars.(field).dims{1})
            yax = anc.vdata.(anc.ncdef.vars.(field).dims{1});
            ylab =[anc.ncdef.vars.(field).dims{1}, ' ',anc.vatts.(anc.ncdef.vars.(field).dims{1}).units];
         else
            yax = [1:size(anc.vdata.(field),1)];
            ylab = 'index value';
         end
         %             var = anc.vdata.(field);
         %             vatt = anc.vatts.(field);
         %             missing = isNaN(var)|(var<-500);
         %             first_time =  min(anc.time);
         %             last_time = max(anc.time);
         %             first_V = datevec(first_time);
         %             last_V = datevec(last_time);
         %             dt = last_time - first_time;
         %             missing = isNaN(var)|(var<-500);
         %          mask = ones(size(var));
         %          if all(size(var)==size(missing))
         %
         %             mask(missing) = NaN;
         %             %             var(missing) = NaN;
         %          else
         %             mask(:,missing) = NaN;
         %             %             var(:,missing) = NaN;
         %          end
         imagegap(time_,yax,var+mask);
         axis('xy');
         colorbar;
         colormap('jet');
         xlabel(time_str);
         ylabel(ylab);
         title({fname,field,vatt.long_name},'interpreter','none');
      else %not dimensioned against recdim (ie time)
         status = 1;
         var = anc.vdata.(field);
         vatt = anc.vatts.(field);
         %          missing = any(isNaN(var),1)|any(var<-5000,1);
         if isfield(anc.vdata,anc.ncdef.vars.(field).dims{2})
            xax = anc.vdata(anc.ncdef.vars.(field).dims{2});
%             xlab =[anc.ncdef.vars.(field).dims{2}, ' ',vatt.(vatts.(field).dims{2}).units];
         else
            xax = [1:size(anc.vdata.(field),2)];
%             xlab = 'index value';
         end
         if isfield(anc.vdata,vatt.(field).dims{1})
            yax = anc.vdata.(vatt.dims{1});
            ylab =[vatt.dims{1}, ' ',char(vatt.units)];
         else
            yax = [1:size(anc.vdata.(field),1)];
            ylab = 'index value';
         end
         %          mask = ones(size(var));
         %          if all(size(var)==size(missing))
         %
         %             mask(missing) = NaN;
         %             %             var(missing) = NaN;
         %          else
         %             mask(:,missing) = NaN;
         %             %             var(:,missing) = NaN;
         %          end
         %          imagegap(xax(~missing),yax,var(:,~missing));
         imagegap(xax,yax,var+mask);
         axis('xy');
         colormap('jet');
         ylabel(ylab);
         xlabel(time_str);
         title({fname,field,vatt.long_name},'interpreter','none');
      end
   end
end
return

function plt = adjust_plot_settings(plt)
%         plt.color = 'k';
% plt.Marker = '.';
% plt.MarkerSize = 6;
% plt.LineStyle = 'none';
% plt.LineWidth = 2;
% plt.MarkerEdgeColor = 'auto';
% plt.MarkerFaceColor = 'none';
done = false;
while ~done
   set_1 = menu('Select setting to modify:',...      
      ['Marker Color (edge) <',plt.MarkerEdgeColor,'>'],...
      ['Marker Color (face) <',plt.MarkerFaceColor,'>'],...
      ['Line Style <',plt.LineStyle,'>'],...
      ['Line Color <',plt.Color,'>'],...
      ['Marker type <',plt.Marker,'>'],...
      ['Marker size <',num2str(plt.MarkerSize),'>'],...
      'Done, Apply');
   if set_1 ==5 % set marker
      mk = menu('Select marker type:', '.','o','x','+','*','s','d','v','^','<','>','p','h','NONE','cancel');
      mark = {'.','o','x','+','*','s','d','v','^','<','>','p','h','NONE'};
      if mk<15
         plt.Marker = mark{mk};
      end
   elseif set_1 == 1 % set marker edge color
      col = menu('Select Marker Edge Color:', 'Blue','Green','Red','Cyan','Magenta','Yellow','Black','Gray','White','Cancel/Abort');
      colr = {'b','g','r','c','m','y','k',[.5,.5,.5],'w'};
      if col<10
         plt.MarkerEdgeColor = colr{col};
      end
   elseif set_1 == 2 % Set marker face color
      col = menu('Select Marker Face Color:', 'Blue','Green','Red','Cyan','Magenta','Yellow','Black','Gray','White','Cancel/Abort');
      colr = {'b','g','r','c','m','y','k',[.5,.5,.5],'w'};
      if col<10
         plt.MarkerFaceColor = colr{col};
      end
      
   elseif set_1 == 3 % Set LineStyle
      lin = menu('Select Line Style:','solid','dotted','dash-dot','dashed','none','Cancel/Abort');
      linstyle = {'-',':','-.','--','none'};
      if lin<6
         plt.LineStyle = linstyle{lin};
      end
   elseif set_1 == 4 % Set Line color
      col = menu('Select Line Color:', 'Blue','Green','Red','Cyan','Magenta','Yellow','Black','Gray','White','Cancel/Abort');
      colr = {'b','g','r','c','m','y','k',[.5,.5,.5],'w'};
      if col<10
         plt.Color = colr{col};
      end
   elseif set_1 == 6 % Set Marker Size
       MarkerSize = 0;
       while MarkerSize<1||MarkerSize>100
           MarkerSize = str2double(inputdlg('Enter the desired MarkSize:','MarkerSize',1,{num2str(plt.MarkerSize)}));
       end
       plt.MarkerSize = MarkerSize;
     elseif set_1 ==7 % Exit
      done = true;
   end
end
return

function f = menu_list(fields,f)
fields_order = fields;
[fields_az,id_to_az] = sort(upper(fields)); fields_az = fields(id_to_az);
[~, az_to_id] = sort(id_to_az);
f = max(f,1); first = f;
listed = 1;
while listed >= 0
   
   page = 10;
   last = min([first+page,length(fields)]);
   first = max([1,(last -page)]); %makes sure that we have a full page menu listing
   menu_str = fields(first:last)';
   listed = menu(' ',['Page up','Page down','A-Z','by ID', ' ',menu_str]);
   if listed==1
      %page up list
      if (first ==1)
         first = length(fields) - page;
      elseif first<=page
         first=1;
      else
         first = first - page;
      end
   elseif listed==2
      first = first + page;
      %page down list
      if first == (length(fields))
         first = 1;
      elseif first > (length(fields)-page)
         first = (length(fields)-page);
      end
   elseif listed==3
      %sort list alphabetically
      if strcmp(fields{f},fields_order{f})
         fields = fields_az;
         first = az_to_id(f);
      end
   elseif listed==4
      if strcmp(fields{f},fields_az{f})
         fields = fields_order;
         first = id_to_az(f);
      end
      %sort list by var id
   elseif listed==5
      listed=0;
   else
      %identify selected field
      % Need to fix this to keep track of pages.
      f = first  + listed - 6;
      listed = -1;
%       field_str = fields{f};
   end
end
return

function gen_hist(anc, field,ax)
N_edges = 50;
figure_(gcf);
% last_ax = gca;
% last_lim = xlim;
lax = length(ax);
while lax >0 && isempty(find(ax{lax}==gca,1))
   lax = lax -1;
end
if length(ax{lax})==1
   lax = ax{lax};
   titl = get(lax,'title');
   titl_str = get(titl,'string');
   field_str = titl_str{1};
else
   lax = ax{lax}(1);
   titl = get(lax,'title');
   titl_str = get(titl,'string');
   field_str = titl_str{2};
end
done_hist = false;
last_fig = gcf;
hfig = figure_;

while ~done_hist
   if isfield(anc.vdata,['qc_',field])
      qc_impact = anc_qc_impacts(anc.vdata.(['qc_',field]), anc.vatts.(['qc_',field]));
   else
      qc_impact = zeros(size(anc.vdata.(field)));
   end
   figure_(last_fig);
   last_lims = axis;
   good_ = (anc.vdata.(field)>=last_lims(3)) & ...
      (anc.vdata.(field)<=last_lims(4))&...
      anc.time>=last_lims(1) & anc.time<=last_lims(2);
   last_lims(3) = min(anc.vdata.(field)(good_));
   last_lims(4) = max(anc.vdata.(field)(good_));
   good_ = (anc.vdata.(field)>=last_lims(3)) & ...
      (anc.vdata.(field)<=last_lims(4))&...
      anc.time>=last_lims(1) & anc.time<=last_lims(2);
   %%
   
   [N_out,x_out] = hist(anc.vdata.(field)(good_),N_edges);
   [~,x_max_ii] = max(N_out);
   N_in = sum(good_);
   x_mode = x_out(x_max_ii);
   mean_val = mean(anc.vdata.(field)(good_));
   N_out_good = hist(anc.vdata.(field)(good_&qc_impact==0),x_out);
   N_out_bad = hist(anc.vdata.(field)(good_&qc_impact==2),x_out);
   %plot first bar graph
   figure_(hfig);
   hx(1) = subplot(2,1,1);
%    norm_factor = N_edges./N_in;
   norm_factor = 1;
   bb1=bar(x_out,N_out.*norm_factor);
   set(bb1,'FaceColor','y','EdgeColor','w')
   hold('on')
   bb2=bar(x_out,N_out_good.*norm_factor);
   set(bb2,'FaceColor','g','EdgeColor','w')
   bb3 = bar(x_out,N_out_bad.*norm_factor);
   set(bb3,'FaceColor','r','EdgeColor','w');
   v = axis;
   plot([mean_val, mean_val], [0,v(4)],'r--',[x_mode,x_mode],[0,v(4)],'k:');
   
   
   title(['Histogram for ',field_str,' with ',num2str(N_edges), ' bins'],'interp','none');
   ylabel('cts*steps/tot_cts','interp','none')
   if ~isempty(who('ann'))&&ishandle(ann)
      delete(ann);
   end
   
   ann = annotation('textbox',[0.15,.75,.3,.15]);
   set(ann,'string',{sprintf('"Good" points: %2.1f%%',100.*sum(N_out_good)./N_in);...
      sprintf('"Bad" points:  %2.1f%%',100.*sum(N_out_bad)./N_in);...
      sprintf('Total points: %d',N_in);...
      sprintf('Mean value: %2.2f ',mean_val);...
      sprintf('Most frequent: %2.2f ',x_mode)});
   set(ann,'fitbox','on');
   hold('off')
   %
   hx(2)=subplot(2,1,2);
   left_cumul = cumsum(N_out.*norm_factor)./sum(N_out.*norm_factor);
   [~, inds] = unique(left_cumul);
   center_left = interp1(left_cumul(inds), x_out(inds),.5,'linear');
   right_cumul = fliplr(cumsum(fliplr(N_out.*norm_factor))./sum(N_out.*norm_factor));
   [~, inds] = unique(right_cumul);
%    right_left = interp1(right_cumul(inds), x_out(inds),.5,'linear');
   com_cumul = min([left_cumul;right_cumul]);
   com_cumul(com_cumul<=0) = NaN;
   ymin = min(com_cumul);
   plot([mean_val, mean_val], [ymin,1],'r--',[x_mode,x_mode],[ymin,1],'k:',...
      [center_left, center_left],[ymin,1] ,'g-',x_out, com_cumul, '-bo');
   title('Least cumulative fraction toward center')
   lg = legend('mean value','frequent value', 'population center','population fraction','Location','best');
   ylabel('fraction')
   xlabel(field_str, 'interp','none');
   linkaxes(hx,'x')
   xy_anc = get(lg,'position');
   if xy_anc(1)>0.5
      ann_pos = get(ann, 'position');
      ann_pos(1) = xy_anc(1);
      set(ann,'position',ann_pos,'fitbox','on');
   end
   %%
   
   ok_hist = menu('Histogram menu',{['Set new number of edges (current:',num2str(N_edges),')'];'Save image...';'Return to QC plots'});
   if ok_hist==1 %Repeat with new number of edges.
      options.Resize='on';
      options.WindowStyle='normal';
      N_temp = inputdlg('Enter the number of divisions for the histogram:','Histogram divisions',1,{num2str(N_edges)},options);
      N_temp = floor(str2double(N_temp{:}));
      if N_temp<sum(N_out) && N_temp > 1
         N_edges = N_temp;
      end
   elseif ok_hist==2 % Save the image
      [pname] = fileparts(anc.fname);
      [fname, pname] = uiputfile([pname, filesep,field_str,'.histogram.png']);
      saveas(gcf, fullfile(pname,fname));
   elseif ok_hist==3 % Exit histogram
      done_hist = true;
      figure_(last_fig);
   end
   %%
end % of while ~done_hist
return

