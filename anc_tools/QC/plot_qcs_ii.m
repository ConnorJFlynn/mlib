function [anc,ax] = plot_qcs_ii(anc);
% [anc,ax] = plot_qcs_ii(anc);
% attempting to link x-axes for plots with same x-data.
%Applies QC to interactively selected fields.  Also generates a
%red/yellow/green image representing the qc tests
if ~exist('anc','var')
   anc = ancload;
end
N_edges = 50;% default value for histogram
fields = fieldnames(anc.vars);
% var_ids = [1:length(fields)];

%Keep only single-dimensioned time series fields
for i = length(fields):-1:1
   if ~isfield(anc.vars,fields{i})||isempty(findstr(anc.recdim.name,anc.vars.(fields{i}).dims{end}))...
         ||length(anc.vars.(fields{i}).dims)>1
      fields(i) = [];
      
      %       var_ids(i) = [];
   end
end
%And strip out the qc fields with matching fields.  They will be displayed as
%colors of other fields.

for i = length(fields):-1:1
   %%
   blah = findstr(fields{i},'qc_');
   if ~isempty(blah)&&isfield(anc.vars, fields{i}((blah+3):end))
      fields(i) = [];
      %       var_ids(i) = [];
   end
end
% %Keep only time series fields
% for i = length(fields):-1:1
%    if ~isfield(anc.vars,fields{i})||isempty(findstr(anc.recdim.name,anc.vars.(fields{i}).dims{end}))
%       fields(i) = [];
% %       var_ids(i) = [];
%    end
% end
% %And strip out the qc fields with matching fields.  They will be displayed as
% %colors of other fields.
% for i = length(fields):-1:1
%    if strcmp('qc_',fields{i}(1:3))&&isfield(anc.vars, fields{i}(4:end))
%       fields(i) = [];
% %       var_ids(i) = [];
%    end
% end

fields_order = fields;
[fields_az,id_to_az] = sort(upper(fields));
[dump, az_to_id] = sort(id_to_az);
fields_az = fields(id_to_az);


if ~isempty(fields)
   f = 1;
   axi = 1;
   
   while (f>0)
      field = fields{f};
      %plot field
      %determine qc type, if any
      if isfield(anc.vars,fields{f})&&isfield(anc.vars,['qc_',fields{f}])
         if isfield(anc.vars.(['qc_',fields{f}]).atts,'bit_1_description')
            %This is VAP QC
            [ax{axi},status,time_,qc_impact] = plot_vap_qc_ii(anc, field);
         elseif ~isempty(strfind(anc.atts.zeb_platform.data,'.s1')>0)||...
               (isfield(anc.vars.(['qc_',fields{f}]).atts,'description')...
               &&(~isempty(findstr('0 = Good',anc.vars.(['qc_',fields{f}]).atts.description.data)))...
               &&(~isempty(findstr('1 = Indeterminate',anc.vars.(['qc_',fields{f}]).atts.description.data)))...
               &&(~isempty(findstr('2 = Bad',anc.vars.(['qc_',fields{f}]).atts.description.data)))...
               &&(~isempty(findstr('3 = Missing',anc.vars.(['qc_',fields{f}]).atts.description.data))))
            
            %Then this is S level QC
            [ax{axi},status,time_,qc_impact] = plot_s_qc_ii(anc, field);
            
         else
            [ax{axi},status,time_,qc_impact] = plot_mentor_qc_ii(anc, field);
         end
      else
         %This is not a qc field
         [ax{axi},status,time_] = plot_no_qc_ii(anc, field);
      end
      zoom(gcf,'on');
      if (axi>1)
         all_ax = [];
         for xx = 1:axi
            all_ax = [all_ax, ax{xx}];
         end
         linkaxes(all_ax,'x');
      end
      if exist('last_lim','var')
         xlim(gca, last_lim);
      else
         last_ax = gca;
         last_lim = xlim(last_ax);
      end
      
      
      %       first = f;
      %       last = min([f+11,length(fields)]);
      %       menu_str = fields(first:last);
      ok = menu('',{'Next';'Previous';'Pick Field...';'New Figure';'Save image...';'Histogram';'Done'});
      % 1 'Next';
      % 2 'Previous';
      % 3 'Pick Field...';
      % 4 'New Figure';
      % 5 'Save image...';
      % 6 'Histogram';
      % 7 'Done'}
      last_ax = gca;
      last_lim = xlim(last_ax);
      if ok==1
         %Next
         f = f+1;
         if f>length(fields)
            f =1;
         end
      elseif ok==2
         f = f-1;
         if f<1
            f = length(fields);
         end
      elseif ok==3
         %Pick field from list
         first = f;
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
            end
         end
         %          f = f+12;
         %          if f>length(fields)
         %             f = 1;
         %          end
      elseif ok==4 % 'New Figure
         last_ax = gca;
         last_lim = xlim(last_ax);
         newpos = get(gcf,'Position');
         newpos(1) = newpos(1)+50;newpos(2) = newpos(2)-50;
         fig=figure;
         axi = axi+1;
         ax{axi} = gca;
         all_ax = [];
         for xx = 1:axi
            all_ax = [all_ax, ax{xx}];
         end
         linkaxes(all_ax,'x');
         xlim(all_ax(end), last_lim)
         set(gcf,'Position',newpos);
         
      elseif ok==5 %save image
         if exist('field','var')
            [fname, pname] = uiputfile([field,'.png']);
            saveas(gcf, fullfile(pname,fname));
         else
            disp('No field selected yet.')
         end
      elseif ok==6   % 6 Generate histogram
         last_ax = gca;
         last_lim = xlim(last_ax);
         lax = length(ax)
         while lax >0 && isempty(find(ax{lax}==gca))
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
         figure;
         while ~done_hist
            
            last_lims = axis(lax);
            good_ = (anc.vars.(field_str).data>=last_lims(3)) & ...
               (anc.vars.(field_str).data<=last_lims(4))&...
               time_>=last_lims(1) & time_<=last_lims(2);
            last_lims(3) = min(anc.vars.(field_str).data(good_));
            last_lims(4) = max(anc.vars.(field_str).data(good_));
            good_ = (anc.vars.(field_str).data>=last_lims(3)) & ...
               (anc.vars.(field_str).data<=last_lims(4))&...
               time_>=last_lims(1) & time_<=last_lims(2);
            %%
            
            N_in = sum(good_);
            [N_out,x_out] = hist(anc.vars.(field_str).data(good_),N_edges);
            [N_max,x_max_ii] = max(N_out);
            N_in = sum(good_);
            x_mode = x_out(x_max_ii);
            mean_val = mean(anc.vars.(field_str).data(good_));
            N_out_good = hist(anc.vars.(field_str).data(good_&qc_impact==0),x_out);
            N_out_bad = hist(anc.vars.(field_str).data(good_&qc_impact==2),x_out);
            %plot first bar graph
            
            hx(1) = subplot(2,1,1)
            norm_factor = N_edges./N_in;
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
            if exist('ann','var')&&ishandle(ann)
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
            [interp_x, inds] = unique(left_cumul);
            center_left = interp1(left_cumul(inds), x_out(inds),.5,'linear');
            right_cumul = fliplr(cumsum(fliplr(N_out.*norm_factor))./sum(N_out.*norm_factor));
            [interp_x, inds] = unique(right_cumul);
            right_left = interp1(right_cumul(inds), x_out(inds),.5,'linear');
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
               N_temp = floor(str2num(N_temp{:}));
               if N_temp<sum(N_out) && N_temp > 1
                  N_edges = N_temp;
               end
            elseif ok_hist==2 % Save the image
               [pname] = fileparts(anc.fname);
               [fname, pname] = uiputfile([pname, filesep,field_str,'.histogram.png']);
               saveas(gcf, fullfile(pname,fname));
            elseif ok_hist==3 % Exit histogram
               done_hist = true;
               figure(last_fig);
            end
            %%
         end % of while ~done_hist
      elseif ok==7 % Done
         
         f = -1;
      end
      
   end
   % close(fig);
else
   disp('No time-series field to plot?')
end

function [ax,status,time_] = plot_no_qc_ii(anc, field);
%[status,ax] = plot_no_qc_ii(anc, field);
% Generates plot of time-series for field having unrecognized or no qc format.
status = 0;
ax = subplot(1,1,1);

if isfield(anc.vars,field)
   status = 1;
   [pname, fname,ext] = fileparts(anc.fname); fname = [fname,ext];
   if (length(anc.vars.(field).dims)==1)
      var = anc.vars.(field);
      missing = isNaN(var.data)|(var.data<-500);
      time_ = [1:length(anc.time)];
      time_str = ['time index (1:end)'];
      
      if ~isempty(findstr(anc.recdim.name,anc.vars.(field).dims{end}))
         plot(time_(~missing),real(var.data(~missing)),'b.');
         ylabel(var.atts.units.data);
         ylim(ylim);
         title({field,var.atts.long_name.data},'interpreter','none');
      else %not dimensioned against time, recdim
      end
   elseif (length(anc.vars.(field).dims)==2)
      if ~isempty(findstr(anc.recdim.name,anc.vars.(field).dims{end}))
         %          xax = serial2doy(anc.time);
         %          xlab = 'time (UTC hours)';
         if isfield(anc.vars,anc.vars.(field).dims{1})
            yax = anc.vars.(anc.vars.(field).dims{1}).data;
            ylab =[anc.vars.(field).dims{1}, ' ',anc.vars.(anc.vars.(field).dims{1}).atts.units.data];
         else
            yax = [1:size(anc.vars.(field).data,1)];
            ylab = 'index value';
         end
         imagegap(time_(~missing),yax,var.data(:,~missing));
         axis('xy');
         colorbar;
         colormap('jet');
         xlabel(time_str);
         ylabel(ylab);
         title({fname,field,var.atts.long_name.data},'interpreter','none');
      else %not dimensioned against recdim (ie time)
         status = 1;
         var = anc.vars.(field);
         missing = any(isNaN(var.data),1)|any(var.data<-5000,1);
         if isfield(anc.vars,anc.vars.(field).dims{2})
            xax = anc.vars.(anc.vars.(field).dims{2}).data;
            xlab =[anc.vars.(field).dims{2}, ' ',anc.vars.(anc.vars.(field).dims{2}).atts.units.data];
         else
            xax = [1:size(anc.vars.(field).data,2)];
            xlab = 'index value';
         end
         if isfield(anc.vars,anc.vars.(field).dims{1})
            yax = anc.vars.(anc.vars.(field).dims{1}).data;
            ylab =[anc.vars.(field).dims{1}, ' ',char(anc.vars.(anc.vars.(field).dims{1}).atts.units.data)];
         else
            yax = [1:size(anc.vars.(field).data,1)];
            ylab = 'index value';
         end
         imagegap(xax(~missing),yax,var.data(:,~missing));
         axis('xy');
         colormap('jet');
         ylabel(ylab);
         xlabel(time_str);
         title({fname,field,var.atts.long_name.data},'interpreter','none');
      end
   end
end
