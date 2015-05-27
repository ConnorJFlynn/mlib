function [status,ax]= plot_mentor_qc3(anc, field);
%  [status,ax]= plot_mentor_qc3(anc, field);
% Plots old-style mentor QC with 2-panel plot.

%This is old-style mentor-edit QC
% bit1 : missing
% bit2 : < min
% bit3 : > max
% bit4 :  delta >
%     :qc_method = "Standard Mentor QC";
%     :qc_bit_1_description = "Value is equal to missing_value";
%     :qc_bit_1_assessment  = "Bad";
%     :qc_bit_2_description = "Value is less than the valid_min";
%     :qc_bit_2_assessment  = "Bad";
%     :qc_bit_3_description = "Value is greater than the valid_max";
%     :qc_bit_3_assessment  = "Bad";
%     :qc_bit_4_description = "Difference between current and previous sample values exceeds valid_delta limit";
%     :qc_bit_4_assessment  = "Bad";

status = 0;
ryg =      [0     1     0;      1     1     0;     1     0     0];
   ryg_w = [[1,1,1];ryg];
   colormap(ryg_w);
   caxis([-1,2]);
if isfield(anc.vars,field)&& isfield(anc.vars,['qc_',field])&& ...
      ~isempty(findstr(anc.recdim.name,anc.vars.(field).dims{end}))
   [pname, fname,ext] = fileparts(anc.fname); fname = [fname,ext];
   status = 1;
   qc_field = ['qc_',field];
   var = anc.vars.(field);
   qc = anc.vars.(qc_field);
   %
   qc_bits = fieldnames(qc.atts);
   tests = 4;
   qc_tests = zeros([tests,length(qc.data)]);
   t = 0;
   t = t+1; qc_tests(t,:) = 2*bitget(uint32(qc.data), t);
   desc{t} = ['test #1: data is missing'];
   t = t+1; qc_tests(t,:) = 2*bitget(uint32(qc.data), t);
   desc{t} = ['test #2: data < valid_min'];
   t = t+1; qc_tests(t,:) = 2*bitget(uint32(qc.data), t);
   desc{t} = ['test #3: data > valid_max'];
   t = t+1; qc_tests(t,:) = 2*bitget(uint32(qc.data), t);
   desc{t} = ['test #4: abs(data(t)-data(t-1)) > valid_delta'];
   qc_impact = max(qc_tests);
   missing = isNaN(var.data)|(var.data<-500);
   first_time =  min(anc.time);
   last_time = max(anc.time);
%       if all(missing)
%          first_time =  min(anc.time);
%          last_time = max(anc.time);
%       else
%          first_time =  min(anc.time(~missing));
%          last_time = max(anc.time(~missing));
%       end
      first_V = datevec(first_time);
      last_V = datevec(last_time);
      dt = last_time - first_time;
if dt <= 1/(24*60)
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
   ax(1) = subplot(2,1,1);
   plot(time_(~missing&(qc_impact==2)),var.data(~missing&(qc_impact==2)),'r.', ...
      time_(~missing&(qc_impact==0)),var.data(~missing&(qc_impact==0)),'g.');
   xl = xlim;

   leg_str = {};
   if any(~missing&(qc_impact==2))
      leg_str = {leg_str{:},'bad'};
   end
   if any(~missing&(qc_impact==0))
      leg_str = {leg_str{:},'good'};
   end

   leg = legend(ax(1),leg_str,'Location','best');

   ylabel(var.atts.units.data);
   %       ylim(ylim);
   title(ax(1),{fname, field},'interpreter','none');
   ax(2)=subplot(2,1,2); mid =  imagegap(time_,[1:tests],qc_tests);
   xlim(xl);
   linkaxes(ax,'x');
   ylabel('test number','interpreter','none');
   xlabel(time_str,'interpreter','none');
   set(gca,'ytick',[1:tests]);
%    colormap(ryg_w);
   caxis([-1,2]);

   title(ax(2),(qc.atts.long_name.data),'interpreter','none');
   set(ax(2), 'Tickdir','out');
   for x = 1:tests
      tx(x) = text('string', desc(x),'interpreter','none','units','normalized','position',[0.01,(x-.5)/tests],...
         'fontsize',8,'color','black','linestyle','-','edgecolor',[.5,.5,.5]);
   end
   zoom('on')
end
