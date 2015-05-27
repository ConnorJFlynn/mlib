function [ax, status, time_, susp] = plot_s_qc_ii(anc, field);
% [ax, status,time_, susp] = plot_s_qc_ii(anc, field);
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

if isfield(anc.vars,field)&& isfield(anc.vars,['qc_',field])
   [pname, fname,ext] = fileparts(anc.fname); fname = [fname,ext];
   status = subplot(1,1,1);
   qc_field = ['qc_',field];
   var = anc.vars.(field);
   qc = anc.vars.(qc_field);
   good = qc.data==0;
   susp = qc.data==1;
   if isfield(anc.vars,field)&& isfield(anc.vars,['qc_',field])&& ...
         ~isempty(findstr(anc.recdim.name,anc.vars.(field).dims{end}))
      status = 1;      
      time_ = [1:length(anc.time)];
      time_str = ['time index (1:end)'];
      
      leg_str = {};

      ax(1) = subplot(1,1,1);
      if sum(good>0)
         leg_str = {leg_str{:}, 'good'};
      end
      if sum(susp>0)
         leg_str = {leg_str{:}, 'suspect'};
      end

      plot(time_(good),var.data(good),'g.', ...
         time_(susp),var.data(susp),'y.');
      xl = xlim;
      if ~isempty(leg_str)
         leg = legend(leg_str,'Location','best');
      else
         txt = text(.5,.5,['No valid data'], 'color','red','units','normalized','Horiz','center','vertical','middle','fontsize',20,'fontweight','bold');
      end
      ylabel(var.atts.units.data);
      %       ylim(ylim);
      title(ax(1),{fname, field,var.atts.long_name.data},'interpreter','none');
%       ylabel('test number','interpreter','none');
      xlabel(time_str,'interpreter','none');
      zoom('on')
   end
end
