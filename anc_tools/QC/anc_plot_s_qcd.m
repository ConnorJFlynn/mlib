function [status,ax, time_,susp] = anc_plot_s_qcd(anc, field);
% [status,ax, time_,susp] = anc_plot_s_qcd(anc, field);
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
% check whether this is actually a summary file or not.  If not, then we
% need to parse the qc with anc_qc_impacts.

if isfield(anc.vdata,field)&& isfield(anc.vdata,['qc_',field])
   [pname, fname,ext] = fileparts(anc.fname); fname = [fname,ext];
   status = subplot(1,1,1);
   qc_field = ['qc_',field];
   var = anc.vdata.(field);
   qc = anc_qc_impacts(anc.vdata.(qc_field), anc.vatts.(qc_field));
   good = qc==0;
   susp = qc==1;
   if isfield(anc.vdata,field)&& isfield(anc.vdata,['qc_',field])&& ...
         ~isempty(findstr(anc.ncdef.recdim.name,anc.ncdef.vars.(field).dims{end}))
      status = 1;     
      time_ = anc.time;
      time_str = ['time [UTC]'];

      leg_str = {};

      ax(1) = subplot(1,1,1);
      if sum(good>0)
         leg_str = {leg_str{:}, 'good'};
      end
      if sum(susp>0)
         leg_str = {leg_str{:}, 'suspect'};
      end

      plot(time_(good),var(good),'g.');
      hold('on');
      pts = plot(time_(susp),var(susp),'.','color',[1,.85,0]);
      hold('off')
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
