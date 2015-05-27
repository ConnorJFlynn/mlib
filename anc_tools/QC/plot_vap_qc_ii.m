function [ax, status, time_, qc_impact] = plot_vap_qc_ii(anc, field,qc_field);
% [ax, status] = plot_vap_qc_ii(anc, field,qc_field);
% Generates plot of time-series qc_field for field following VAP QC conventiona.
% field must be a character string matching a valid field name in anc.
% Would be good to add a non-time series plot too.
status = 0;
ryg =      [0     1     0;      1     1     0;     1     0     0];
ryg_w = [[1,1,1];ryg];
if isfield(anc.vars,field)&& isfield(anc.vars,['qc_',field])&& ~isempty(findstr(anc.recdim.name,char(anc.vars.(field).dims)))
   [pname, fname,ext] = fileparts(anc.fname);
   fname = [fname,ext];
   status = 1;

   var = anc.vars.(field);
   if exist('qc_field','var')
      qc = qc_field;
   else
   qc_field = ['qc_',field];
   qc = anc.vars.(qc_field);
   end
   %
   qc_bits = fieldnames(qc.atts);
   tests = [];
   i = 0;
   while isempty(tests)&&(i< length(qc_bits))
      tests = sscanf(qc_bits{end-i},'bit_%d');
      i = i+1;
   end
   if ~isempty(tests)
      qc_tests = zeros([tests,length(qc.data)]);
      for t = tests:-1:1
         bad = findstr(upper(qc.atts.(['bit_',num2str(t),'_assessment']).data),'BAD');
         if bad
            qc_tests(t,:) = 2*bitget(uint32(qc.data), t);
         else
            qc_tests(t,:) = bitget(uint32(qc.data), t);
         end
         desc{t} = ['test #',num2str(t),': ',[qc.atts.(['bit_',num2str(t),'_description']).data]];
      end
      if tests>1
         qc_impact = max(qc_tests);
      else
         qc_impact = qc_tests;
      end
      missing = isNaN(var.data)|(var.data<-500);
      time_ = [1:length(anc.time)];
      time_str = ['time index (1:end)'];
   end
      %plot figure 2 first so that figure 1 window is current / on top at end
%       fig(1) = figure(1);
      ax(1) = subplot(2,1,1);
      plot(time_(~missing&(qc_impact==2)),var.data(~missing&(qc_impact==2)),'rx', ...
         time_(~missing&(qc_impact==1)),var.data(~missing&(qc_impact==1)),'y+',...
         time_(~missing&(qc_impact==0)),var.data(~missing&(qc_impact==0)),'go');
      if all(missing)
         plot(xlim,ylim,'w.')
         leg_str = ['No valid values.'];
      else
         leg_str = {};
      end
      xl = xlim;
      if any(~missing&(qc_impact==2))
         leg_str = {leg_str{:},'bad'};
      end
      if any(~missing&(qc_impact==1))
         leg_str = {leg_str{:},'caution'};
      end
      if any(~missing&(qc_impact==0))
         leg_str = {leg_str{:},'good'};
      end
      leg = legend(ax(1),leg_str);
      ylabel(var.atts.units.data);
%       ylim(ylim);
      title(ax(1),{fname, field},'interpreter','none');
      ax(2)=subplot(2,1,2); mid =  imagegap(time_,[1:tests],qc_tests);
      xlim(xl);
      linkaxes(ax,'x');
      ylabel('test number','interpreter','none');
      xlabel(time_str,'interpreter','none');
      set(gca,'ytick',[1:tests]);
%       colormap(ryg);
%       caxis([0,2]);
      colormap(ryg_w);
      caxis([-1,2]);

      title(ax(2),(qc.atts.long_name.data),'interpreter','none');
      set(ax(2), 'Tickdir','out');
      for x = 1:length(desc)
      tx(x) = text('string', desc(x),'interpreter','none','units','normalized','position',[0.01,(x-.5)/tests],...
         'fontsize',12,'color','black','linestyle','-','edgecolor',[.5,.5,.5]);
%       set(tx(x),'units','data');
      end
      zoom('on')
      %
      %    fig(2) = figure(2); clf(fig(2));
      %    %pause(.1); close(gcf);pause(.1); figure(2)
      %    set(gca,'units','normalized','position',[.05,.05,.9,.9],'visible','on','xtick',[],'ytick',[]);
      %    tx = text('string','','interpreter','none','units','normalized','position',[0.05,.8],'fontsize',8);
      %    set(tx,'string',desc);
      %    title({['Test descriptions for qc_',field]},'interpreter','none');
      %    % else
      %    %    disp(['Field ''',field,''' was not found in the netcdf
      %    file.'])
   end
end

