function [status,ax, time_, qc_impact]= anc_plot_good_qc(anc, field);
%  [status,ax, time_,qc_impact]= anc_plot_good_qc((anc, field);
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
if isfield(anc.vdata,field)&& isfield(anc.vdata,['qc_',field])&& ...
      ~isempty(strfind(anc.ncdef.vars.(field).dims{end},anc.ncdef.recdim.name))
   [pname, fname,ext] = fileparts(anc.fname); fname = [fname,ext];
   status = 1;
   qc_field = ['qc_',field];
   var = anc.vdata.(field);
   qc = anc.vdata.(qc_field);
   vatts = anc.vatts.(field);
   qatts = anc.vatts.(qc_field);
   %
   qc_bits = fieldnames(qatts);
   tests = 4;
   qc_tests = zeros([tests,length(qc)]);
   t = 0;
   t = t+1; qc_tests(t,:) = 2*bitget(uint32(qc), t);
   desc{t} = ['test #1: data is missing'];
   t = t+1; qc_tests(t,:) = 2*bitget(uint32(qc), t);
   desc{t} = ['test #2: data < valid_min'];
   t = t+1; qc_tests(t,:) = 2*bitget(uint32(qc), t);
   desc{t} = ['test #3: data > valid_max'];
   t = t+1; qc_tests(t,:) = 2*bitget(uint32(qc), t);
   desc{t} = ['test #4: abs(data(t)-data(t-1)) > valid_delta'];
   qc_impact = max(qc_tests);
   missing = isNaN(var)|(var<-500);
   time_ = anc.time;
   time_str = ['time [UTC]'];
%    first_time =  min(anc.time);
%    last_time = max(anc.time);
%       if all(missing)
%          first_time =  min(anc.time);
%          last_time = max(anc.time);
%       else
%          first_time =  min(anc.time(~missing));
%          last_time = max(anc.time(~missing));
%       end
%       first_V = datevec(first_time);
%       last_V = datevec(last_time);
%       dt = last_time - first_time;
%       if isempty(dt)
%          time_ = (anc.time - datenum(datestr(first_time,'yyyy-mm-dd HH:MM:00'),'yyyy-mm-dd HH:MM:SS'))*24*60*60;
%          time_str = 'seconds from 00:00 UTC';
%       elseif dt <= 1/(24*60)
%          time_ = (anc.time - datenum(datestr(first_time,'yyyy-mm-dd HH:MM:00'),'yyyy-mm-dd HH:MM:SS'))*24*60*60;
%          time_str = 'seconds from start of minute';
%       elseif (dt<=1/24)
%          time_ = (anc.time - datenum(datestr(first_time,'yyyy-mm-dd HH:00'),'yyyy-mm-dd HH:MM'))*24*60;
%          time_str = 'minutes from top of hour UTC';
%       elseif (dt<=1)
%          time_ = (anc.time - datenum(datestr(first_time,'yyyy-mm-dd'),'yyyy-mm-dd'))*24;
%          time_str = 'hours from 00:00 UTC';
%       elseif (dt<=31)
%          time_ = (anc.time - datenum(datestr(first_time,'yyyy-mm-01'),'yyyy-mm-01')+1);
%          time_str = ['days since ', datestr(first_time, 'mmm 1, yyyy')];
%         elseif (dt<=730)
%          time_ = (anc.time - datenum(datestr(first_time,'yyyy-01-01'),'yyyy-01-01')+1);
%          time_str = ['days since ', datestr(first_time, 'Jan 1, yyyy')];
%       else 
%          time_ = (anc.time - datenum(datestr(first_time,'yyyy-01-01'),'yyyy-01-01'))./365.25;
%          time_str = ['years since ', datestr(first_time, 'Jan 1, yyyy')];
%       end
%    ax(1) = subplot(2,1,1);
   cla(gca)
   plot(time_(~missing&(qc_impact==2)),var(~missing&(qc_impact==2)),'r.', ...
      time_(~missing&(qc_impact==0)),var(~missing&(qc_impact==0)),'g.');
   xl = xlim;
   ax(1) = gca;
   leg_str = {};
   if any(~missing&(qc_impact==2))
      leg_str = {leg_str{:},'bad'};
   end
   if any(~missing&(qc_impact==0))
      leg_str = {leg_str{:},'good'};
   end

   leg = legend(ax(1),leg_str,'Location','best');

   ylabel(vatts.units);
   %       ylim(ylim);
   title(ax(1),{fname, field},'interpreter','none');
   set(gcf,'units','normalized');
    pos1 = get(gcf,'Position');
    pos2 = pos1;
    pos2(4) = 0.045.*length(desc);
    pos2(2) = pos1(2)-1.1.*pos2(4)+.05 ;
    if pos2(2)<0
       pos2(2) = pos1(2) + pos1(4) + .125;
    end
    
    figure(double(gcf)+1);
%     ax(2)=subplot(2,1,2); 
    mid =  imagegap(time_,[1:tests],qc_tests);
    zoom('on'); ax(2) = gca;
   xlim(xl);
   linkaxes(ax,'x');
   ylabel('test number','interpreter','none');
   xlabel(time_str,'interpreter','none');
   set(gca,'ytick',[1:tests]);
   colormap(ryg_w);
   caxis([-1,2]);

   title(ax(2),(qatts.long_name),'interpreter','none');
   set(ax(2), 'Tickdir','out');
   for x = 1:tests
      tx(x) = text('string', desc(x),'interpreter','none','units','normalized','position',[0.01,(x-.5)/tests],...
         'fontsize',8,'color','black','linestyle','-','edgecolor',[.5,.5,.5]);
   end
   zoom('on')
end
