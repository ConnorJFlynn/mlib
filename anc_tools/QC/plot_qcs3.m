function anc = plot_qcs3(anc);
% anc = plot_qcs3(anc);
% attempting to link x-axes for plots with same x-data.
%Applies QC to interactively selected fields.  Also generates a
%red/yellow/green image representing the qc tests

% Fixed bug identifying qc fields (spotted by Justin) when fieldnames are
% less than 3 chars long.
if ~exist('anc','var')
   anc = ancload;
end
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
            [status,ax{axi}] = plot_vap_qc3(anc, field);
         elseif ~isempty(strfind(anc.atts.zeb_platform.data,'.s1')>0)||...
               (isfield(anc.vars.(['qc_',fields{f}]).atts,'description')...
               &&(~isempty(findstr('0 = Good',anc.vars.(['qc_',fields{f}]).atts.description.data)))...
               &&(~isempty(findstr('1 = Indeterminate',anc.vars.(['qc_',fields{f}]).atts.description.data)))...
               &&(~isempty(findstr('2 = Bad',anc.vars.(['qc_',fields{f}]).atts.description.data)))...
               &&(~isempty(findstr('3 = Missing',anc.vars.(['qc_',fields{f}]).atts.description.data))))
               
            %Then this is S level QC
            [status,ax{axi}] = plot_s_qc3(anc, field);

         else
            [status,ax{axi}] = plot_mentor_qc3(anc, field);
         end
      else
         %This is not a qc field
         [status,ax{axi}] = plot_no_qc3(anc, field);
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
      elseif ok==4
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
         
      elseif ok==5
         %save image
         if exist('field','var')
            [fname, pname] = uiputfile([field,'.png']);
            saveas(gcf, fullfile(pname,fname));
         else
            disp('No field selected yet.')
         end
      elseif ok==6 %Generate histogram
         last_ax = gca;
         last_lim = xlim(last_ax);
         newpos = get(gcf,'Position');
         newpos(1) = newpos(1)+50;newpos(2) = newpos(2)-50;
         % Now, generate figure with histogram of last field within
         % last_lim. Take input for N bins. If possible, segregate or color according to
         % QC_impact.
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
         %!
      elseif ok==7
         f = -1;
      end

   end
   % close(fig);
else
   disp('No time-series field to plot?')
end

function [status,ax] = plot_no_qc3(anc, field);
%[status,ax] = plot_no_qc3(anc, field);
% Generates plot of time-series for field having unrecognized or no qc format.
status = 0;
ax = subplot(1,1,1);

if isfield(anc.vars,field)
   status = 1;
   [pname, fname,ext] = fileparts(anc.fname); fname = [fname,ext];
   if (length(anc.vars.(field).dims)==1)
               var = anc.vars.(field);
         missing = isNaN(var.data)|(var.data<-500);
         first_time =  min(anc.time);
         last_time = max(anc.time);
         first_V = datevec(first_time);
         last_V = datevec(last_time);
         dt = last_time - first_time;
         
         if isempty(dt)
            time_ = (anc.time - first_time)*24*60*60;
            time_str = 'seconds from start';
         elseif dt <= 1/(24*60)
            time_ = (anc.time - first_time)*24*60*60;
            time_str = 'seconds from start';
         elseif (dt<=1/24)
            time_ = (anc.time - first_time)*24*60;
            time_str = 'minutes from start';
         elseif (dt<=1)
            time_ = (anc.time - first_time)*24;
            time_str = 'hours from start';
         elseif (dt<=31)
            time_ = (anc.time - first_time);
            time_str = 'days from start';
         elseif (dt<=140)
            time_ = (anc.time - first_time)./7;
            time_str = 'weeks from start';
         elseif (dt<=365)
            V = datevec(anc.time);
            time_ = V(:,1) + serial2doy(anc.time);
         end
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

