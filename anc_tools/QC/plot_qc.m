function status = plot_qc(anc, field);
% plot_qc(anc, field);
% Generates plot of time-series qc_field for field.
% field must be a character string matching a valid field name in anc.
% Would be good to add a non-time series plot too.
status = 0;
if isfield(anc.vars,field)&& isfield(anc.vars,['qc_',field])&& ~isempty(findstr(anc.recdim.name,char(anc.vars.(field).dims)))
   
   
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
   
   %plot figure 2 first so that figure 1 window is current / on top at end
    fig(2) = figure(2); clf(fig(2));
   %pause(.1); close(gcf);pause(.1); figure(2)
   set(gca,'units','normalized','position',[.05,.05,.9,.9],'visible','on','xtick',[],'ytick',[]);
   tx = text('string','','interpreter','none','units','normalized','position',[0.05,.8],'fontsize',8);
   set(tx,'string',desc);
   title({['Test descriptions for qc_',field]},'interpreter','none');
   % else
   %    disp(['Field ''',field,''' was not found in the netcdf file.'])
   
   
   fig(1) = figure(1);
   ax(1) = subplot(2,1,1);
   plot(serial2Hh(anc.time(~missing&(qc_impact==2))),var.data(~missing&(qc_impact==2)),'r.', ...
      serial2Hh(anc.time(~missing&(qc_impact==1))),var.data(~missing&(qc_impact==1)),'y.',...
      serial2Hh(anc.time(~missing&(qc_impact==0))),var.data(~missing&(qc_impact==0)),'g.');

   leg_str = {};
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

   % if any(~missing&(qc_impact==2))
   % hold('on');
   % plot(serial2Hh(anc.time(~missing&(qc_impact==2))),var.data(~missing&(qc_impact==2)),'r.');
   % hold('off');
   % else
   %    hold('on');
   % plot(NaN,NaN,'r.');
   % hold('off');
   % end
   %
   %  if any(~missing&(qc_impact==1))
   % hold('on');
   % plot(serial2Hh(anc.time(~missing&(qc_impact==1))),var.data(~missing&(qc_impact==1)),'y.');
   % hold('off');
   % else
   %    hold('on');
   % plot(NaN,NaN,'r.');
   % hold('off');
   %
   %  end
   %  if any(~missing&(qc_impact==0))
   % hold('on');
   % plot(serial2Hh(anc.time(~missing&(qc_impact==0))),var.data(~missing&(qc_impact==0)),'g.');
   % hold('off');
   % else
   %    hold('on');
   % plot(NaN,NaN,'r.');
   % hold('off');
   %
   %  end
   ylabel(var.atts.units.data);
   ylim(ylim);
   title(ax(1),{field,var.atts.long_name.data},'interpreter','none');
   ax(2)=subplot(2,1,2); mid =  imagegap(serial2Hh(anc.time),[1:tests],qc_tests);
   linkaxes(ax,'x');
   ylabel('test number','interpreter','none');
   xlabel('UTC (Hh)','interpreter','none');
   set(gca,'ytick',[1:tests]);
   load ryg; colormap(ryg);clear ryg
   caxis([0,2]);

   title(ax(2),(qc.atts.long_name.data),'interpreter','none');
   zoom('on')

end

