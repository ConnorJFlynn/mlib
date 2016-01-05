function anc = plot_qcs(anc);
%Applies QC to interactively selected fields.  Also generates a
%red/yellow/green image representing the qc tests
if ~exist('anc','var')
   anc = ancload;
end
fields = fieldnames(anc.vars);
% var_ids = [1:length(fields)];

%Keep only time series fields
for i = length(fields):-1:1
   if ~isfield(anc.vars,fields{i})||isempty(findstr(anc.recdim.name,anc.vars.(fields{i}).dims{end}))
      fields(i) = [];
%       var_ids(i) = [];
   end
end
%And strip out the qc fields with matching fields.  They will be displayed as
%colors of other fields.
for i = length(fields):-1:1
   if strcmp('qc_',fields{i}(1:3))&&isfield(anc.vars, fields{i}(4:end))
      fields(i) = [];
%       var_ids(i) = [];
   end
end

fields_order = fields;
[fields_az,id_to_az] = sort(upper(fields));
[dump, az_to_id] = sort(id_to_az);
fields_az = fields(id_to_az);


if length(fields)>0
   f = 1;
   while (f>0)
      field = fields{f};
      %plot field
      %determine qc type, if any
      if isfield(anc.vars,fields{f})&&isfield(anc.vars,['qc_',fields{f}])
         if isfield(anc.vars.(['qc_',fields{f}]).atts,'bit_1_description')
            %This is VAP QC
            status = plot_vap_qc(anc, field);
         else
            status = plot_mentor_qc(anc, field);
         end
      else
         %This is not a qc field
         status = plot_no_qc(anc, field);
      end
      %       first = f;
      %       last = min([f+11,length(fields)]);
      %       menu_str = fields(first:last);
      ok = menu('',{'Next';'Previous';'Pick Field...';'New Figure';'Save image...';'Done'});
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
         listed = 0;
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
         fig=figure;
      elseif ok==5
         %save image
         if exist('field','var')
            [fname, pname] = uiputfile([field,'.png']);
            saveas(gcf, fullfile(pname,fname));
         else
            disp('No field selected yet.')
         end
      elseif ok==6
         f = -1;
      end
   end
   % close(fig);
else
   disp('No time-series field to plot?')
end

function status = plot_no_qc(anc, field);
% plot_no_qc(anc, field);
% Generates plot of time-series for field having unrecognized or no qc format.
status = 0;
subplot(1,1,1);
if isfield(anc.vars,field)'
   if (length(anc.vars.(field).dims)==1)
      if ~isempty(findstr(anc.recdim.name,anc.vars.(field).dims{end}))
         status = 1;
         var = anc.vars.(field);
         missing = isNaN(var.data)|(var.data<-5000);
         plot(serial2Hh(anc.time(~missing)),real(var.data(~missing)),'b.');
         ylabel(var.atts.units.data);
         ylim(ylim);
         title({field,var.atts.long_name.data},'interpreter','none');
      else %not dimensioned against time, recdim
      end
   else (length(anc.vars.(field).dims)==2)
      if ~isempty(findstr(anc.recdim.name,anc.vars.(field).dims{end}))
         status = 1;
         var = anc.vars.(field);
         missing = any(isNaN(var.data),1)|any(var.data<-5000,1);
         xax = serial2Hh(anc.time);
         xlab = 'time (UTC hours)';
         if isfield(anc.vars,anc.vars.(field).dims{1})
            yax = anc.vars.(anc.vars.(field).dims{1}).data;
            ylab =[anc.vars.(field).dims{1}, ' ',anc.vars.(anc.vars.(field).dims{1}).atts.units.data];
         else
            yax = [1:size(anc.vars.(field).data,1)];
            ylab = 'index value';
         end
         imagegap(xax(~missing),yax,var.data(:,~missing));
         axis('xy');
         colorbar;
         colormap('jet');
         xlabel(xlab);
         ylabel(ylab);
         title({field,var.atts.long_name.data},'interpreter','none');
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
         xlabel(xlab);
         title({field,var.atts.long_name.data},'interpreter','none');
      end
   end
end

