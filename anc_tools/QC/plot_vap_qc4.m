function [status,ax,time_,qc_impact] = plot_vap_qc4(anc, field);
% [status,ax,time_,qc_impact] = plot_vap_qc4(anc, field);
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
   qc_field = ['qc_',field];
   var = anc.vars.(field);
   qc = anc.vars.(qc_field);
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
%       if all(missing)
%          first_time =  min(anc.time);
%          last_time = max(anc.time);
%       else
%          first_time =  min(anc.time(~missing));
%          last_time = max(anc.time(~missing));
%       end
      first_time =  min(anc.time);
      last_time = max(anc.time);
      first_V = datevec(first_time);
      last_V = datevec(last_time);
      dt = last_time - first_time;
   end
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
      %plot figure 2 first so that figure 1 window is current / on top at end
%       fig(1) = figure(1);
      ax(1) = subplot(2,1,1);
      plot(time_(~missing&(qc_impact==2)),var.data(~missing&(qc_impact==2)),'r.', ...
         time_(~missing&(qc_impact==1)),var.data(~missing&(qc_impact==1)),'y.',...
         time_(~missing&(qc_impact==0)),var.data(~missing&(qc_impact==0)),'g.');
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
         'fontsize',8,'color','black','linestyle','-','edgecolor',[.5,.5,.5]);
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

