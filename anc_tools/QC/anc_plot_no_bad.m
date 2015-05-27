function [status,ax, time_,susp] = anc_plot_no_bad(anc, field);
% [status,ax, time_,susp] = plot_s_qc(anc, field);
% Generates plot of time-series for field having "s" qc format.
% This is the storage format:
% This field contains qc values which should be interpreted as listed:
% 0 = Good: Data exists and passed all qc tests.
% 1 = Indeterminate: Data may be bad, further analysis recommended.
% 2 = Bad: Data has a bad value.
% 3 = Missing: Data is missing.

% I don't think we need a bit-wise display, so just color good, suspect,
% and bad as g y r.  Discard missing.
status = 0;
if isfield(anc.vdata,field)&& isfield(anc.vdata,['qc_',field])
   [pname, fname,ext] = fileparts(anc.fname); fname = [fname,ext];
   status = subplot(1,1,1);
   qc_field = ['qc_',field];
   var = anc.vdata.(field);
   qc = anc.vdata.(qc_field); 
   qc = anc_qc_impacts(qc, anc.vatts.(qc_field));
   good = qc==0;
   susp = qc==1;
   time_ = anc.time;
   time_str = ['time [UTC]'];
%    if isfield(anc.vdata,field)&& isfield(anc.vdata,['qc_',field])&& ...
%          ~isempty(findstr(anc.ncdef.recdim.name,anc.ncdef.vars.(field).dims{end}))
%       status = 1;      
%       first_time =  min(anc.time);
%       last_time = max(anc.time);
% %       if all(missing)
% %          first_time =  min(anc.time);
% %          last_time = max(anc.time);
% %       else
% %          first_time =  min(anc.time(~missing));
% %          last_time = max(anc.time(~missing));
% %       end
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
      
      leg_str = {};

      ax(1) = subplot(1,1,1);
      if sum(good>0)
         leg_str = {leg_str{:}, 'good'};
      end
      if sum(susp>0)
         leg_str = {leg_str{:}, 'suspect'};
      end

      plt = plot(time_(good),var(good),'g.', ...
         time_(susp),var(susp),'y.');
     if length(plt)>1
         set(plt(2),'color',[1,.85,0])
     end
      xl = xlim;
      if ~isempty(leg_str)
         leg = legend(leg_str,'Location','best');
      else
         txt = text(.5,.5,['No valid data'], 'color','red','units','normalized','Horiz','center','vertical','middle','fontsize',20,'fontweight','bold');
      end
      ylabel(anc.vatts.(field).units);
      %       ylim(ylim);
      title(ax(1),{fname, field,anc.vatts.(field).long_name},'interpreter','none');
%       ylabel('test number','interpreter','none');
      xlabel(time_str,'interpreter','none');
      zoom('on')
   end
end
