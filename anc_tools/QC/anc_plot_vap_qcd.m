function [status,ax,time_,qc_impact,qc_fig] = anc_plot_vap_qcd(anc, field)
% [status,ax,time_,qc_impact] = anc_plot_vap_qcd(anc, field);
% Generates plot of time-series qc_field for field following VAP QC conventions.
% field must be a character string matching a valid field name in anc.
% Would be good to add a non-time series plot too.
% incorporated dynamicDateTicks
status = 0;
ryg =      [0     1     0;      1     1     0;     1     0     0];
ryg_w = [[1,1,1];ryg];

if isfield(anc.vdata,field)&& isfield(anc.vdata,['qc_',field])&& ~isempty(strfind(anc.ncdef.recdim.name,char(anc.ncdef.vars.(field).dims)))
    [pname, fname,ext] = fileparts(anc.fname);
    fname = [fname,ext];
    status = 1;
    qc_field = ['qc_',field];
    var = anc.vdata.(field);
    vatts = anc.vatts.(field);
    qc = anc.vdata.(qc_field);
    qatts = anc.vatts.(qc_field);
    %
    qc_bits = fieldnames(anc.vatts.(qc_field));
    qc_params = qc_bits;
    for n = length(qc_params):-1:1
        tmp = qc_params{n};
        if strcmp(tmp,'long_name')||strcmp(tmp,'units')||strcmp(tmp,'description')||...
                (~isempty(strfind(tmp,'bit_'))&&(~isempty(strfind(tmp,'_assessment'))||~isempty(strfind(tmp,'_description'))))
            qc_params(n) = [];
        else
           if isfield(qatts,qc_params(n))&&ischar(qatts.(qc_params{n}))
              qatts.(qc_params{n}) = sscanf(qatts.(qc_params{n}),'%g');
                            
           end
        end
    end
    %%
    if isfield(anc.vatts.(field),'valid_min')
        qc_params(end+1) = {'valid_min'};
    end
    if isfield(anc.vatts.(field),'valid_max')
        qc_params(end+1) = {'valid_max'};
    end
    if isfield(anc.vatts.(field),'valid_delta')
        qc_params(end+1) = {'valid_delta'};
    end
    %%
    
    tests = [];
    i = 0;
    while isempty(tests)&&(i< length(qc_bits))
        tests = sscanf(qc_bits{end-i},'bit_%d');
        i = i+1;
    end
    if ~isempty(tests)
        qc_tests = zeros([tests,length(qc)]);
        for t = tests:-1:1
            if isfield(qatts, ['bit_',num2str(t),'_assessment'])
                bad = strfind(upper(qatts.(['bit_',num2str(t),'_assessment'])),'BAD');
                if bad
                    qc_tests(t,:) = 2*bitget(uint32(qc), t);
                else
                    qc_tests(t,:) = bitget(uint32(qc), t);
                end
                desc{t} = ['test #',num2str(t),': ',[qatts.(['bit_',num2str(t),'_description'])]];
                for n = length(qc_params):-1:1
                    if isfield(vatts,qc_params{n})
                        desc{t} = strrep(desc{t},qc_params{n},sprintf('%g',vatts.(qc_params{n})));
                    elseif isfield(qatts,qc_params{n})
                        desc{t} = strrep(desc{t},qc_params{n},sprintf('%g',qatts.(qc_params{n})));
                    end
                end
                desc{t} = strrep(desc{t},'Value is equal to missing_value',[field,' is set to missing_value']);
                desc{t} = strrep(desc{t},'Value is greater than the ',[field,' > ']);
                desc{t} = strrep(desc{t},'Value is less than the ',[field,' < ']);
            else
                disp('Error in qc definition!');
                disp(['No ',['bit_',num2str(t),'_assessment']]);
            end
            
        end
        if tests>1
            qc_impact = max(qc_tests);
        else
            qc_impact = qc_tests;
        end
        missing = isNaN(var)|(var<-500);
        %       if all(missing)
        %          first_time =  min(anc.time);
        %          last_time = max(anc.time);
        %       else
        %          first_time =  min(anc.time(~missing));
        %          last_time = max(anc.time(~missing));
        %       end
        time_ = anc.time;
        time_str = ['time [UTC]'];
%         first_time =  min(anc.time);
%         last_time = max(anc.time);
%         first_V = datevec(first_time);
%         last_V = datevec(last_time);
%         dt = last_time - first_time;
    end
    
    %% Look for fields named explicitely in qc_bit descriptions
    fields = fieldnames(anc.vdata);
    
    for X = length(fields):-1:1
        named = false; D = 1;
        while ~named && D<=length(desc)
            named = D .* ~isempty(strfind(desc{D},fields{X}));
            D = D +1;
        end
        if ~isempty(strfind(fields{X},'qc_')) || strcmp(fields{X},field) || strcmp(fields{X},'time') || ...
                strcmp(fields{X},'time_offset')  || ~all(strcmp(anc.ncdef.vars.(fields{X}).dims,anc.ncdef.recdim.name)) || ~named
            fields(X) = [];
        end
    end
    %%
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
    %plot figure 2 first so that figure 1 window is current / on top at end
    %       fig(1) = figure(1);
%     ax(1) = subplot(2,1,1); cla(ax(1))
cla(gca)
    plot(time_(~missing&(qc_impact==2)),var(~missing&(qc_impact==2)),'r.');
    hold('on');
    plot(time_(~missing&(qc_impact==1)),var(~missing&(qc_impact==1)),'.','color',[1,.85,0]);
%          if length(plt)>1
%          set(plt(2),'color',[1,.85,0])
%      end
    plot(time_(~missing&(qc_impact==0)),var(~missing&(qc_impact==0)),'g.');
    hold('off');
    zoom('on');
    ax(1) = gca;
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
    ylabel(vatts.units);
    %       ylim(ylim);
    title(ax(1),{fname, field},'interpreter','none');
    set(gcf,'units','normalized');
    pos1 = get(gcf,'Position');
    pos2 = pos1;
    pos2(4) = 0.045.*length(desc);
    pos2(2) = max([pos1(2)-1.2.*pos2(4),0]);
    if pos2(2)<0
       pos2(2) = pos1(2) + pos1(4) + .125;
    end
    dplot = gcf;   
    figure(double(gcf)+1); 
    set(gcf,'units','normalized','position',pos2);
    mid =  imagegap(time_,[1:tests],qc_tests);
    zoom('xon')
    ax(2)=gca; 
    xlim(xl);
    
    ylabel('test number','interpreter','none');
    xlabel(time_str,'interpreter','none');
    set(gca,'ytick',[1:tests]);
    %       colormap(ryg);
    %       caxis([0,2]);
    colormap(ryg_w);
    caxis([-1,2]);
    
    title(ax(2),['QC tests for ',field],'interpreter','none');
    set(ax(2), 'Tickdir','out');
    for x = 1:length(desc)
        tx(x) = text('string', desc(x),'interpreter','none','units','normalized','position',[0.01,(x-.5)/tests],...
            'fontsize',8,'color','black','linestyle','-','edgecolor',[.5,.5,.5]);
        %      set(tx(x),'units','data','clipping','on')
    end
    qc_fig = gcf;
    figure_(dplot);
%     panes = length(fields);
%     if panes>0
%        fig_pos = get(var_fig,'position');
%        figure(55);
%        set(gcf,'position',[fig_pos(1)+1.05.*fig_pos(3), fig_pos(2),fig_pos(3), fig_pos(4)]);
%        %  ax(3) = subplot(panes,1,1);
%        subplot(panes,1,1); cla(gca);
% %         cla(ax(3));
%         if isfield(anc.vdata,['qc_',fields{1}])
%             qc_impact = anc_qc_impacts(anc.vdata.(['qc_',fields{1}]),anc.vatts.(['qc_',fields{1}]));
%         else
%             qc_impact = zeros(size(anc.vdata.(fields{1})));
%         end
%         missing = anc.vdata.(fields{1})< -9990;
%         plot(time_(~missing&(qc_impact==2)),anc.vdata.(fields{1})(~missing&(qc_impact==2)),'k.',...
%             time_(~missing&(qc_impact==2)),anc.vdata.(fields{1})(~missing&(qc_impact==2)),'r.');
%         hold('on');
%         plot(time_(~missing&(qc_impact==1)),anc.vdata.(fields{1})(~missing&(qc_impact==1)),'.','color',[1,230./255,50./255]);
%         plot(time_(~missing&(qc_impact==0)),anc.vdata.(fields{1})(~missing&(qc_impact==0)),'g.');
%         hold('off');
%         lg = legend(fields{1}); set(lg,'interp','none') ;
%         title(['QC fields for ' field],'interp','none')
%         
%         for pane = 2:panes
%            %  ax(2+pane) = subplot(panes,1,pane);
%            subplot(panes,1,pane); cla(gca);
% %             cla(ax(pane+2)); 
%             if isfield(anc.vdata,['qc_',fields{pane}])
%                 qc_impact = anc_qc_impacts(anc.vdata.(['qc_',fields{pane}]),anc.vatts.(['qc_',fields{pane}]));
%             else
%                 qc_impact = zeros(size(anc.vdata.(fields{pane})));
%             end
%             missing = anc.vdata.(fields{pane})< -9990;
%             plot(time_(~missing&(qc_impact==2)),anc.vdata.(fields{pane})(~missing&(qc_impact==2)),'k.',...
%                 time_(~missing&(qc_impact==2)),anc.vdata.(fields{pane})(~missing&(qc_impact==2)),'r.');
%             hold('on');
%             plot(time_(~missing&(qc_impact==1)),anc.vdata.(fields{pane})(~missing&(qc_impact==1)),'.','color',[1,230./255,50./255]);
%             plot(time_(~missing&(qc_impact==0)),anc.vdata.(fields{pane})(~missing&(qc_impact==0)),'g.');
%             hold('off');
%             lg = legend(fields{pane}); set(lg,'interp','none')
%         end
%         xlabel(time_str,'interpreter','none');
% 
%         %
%         %    fig(2) = figure(2); clf(fig(2));
%         %    %pause(.1); close(gcf);pause(.1); figure(2)
%         %    set(gca,'units','normalized','position',[.05,.05,.9,.9],'visible','on','xtick',[],'ytick',[]);
%         %    tx = text('string','','interpreter','none','units','normalized','position',[0.05,.8],'fontsize',8);
%         %    set(tx,'string',desc);
%         %    title({['Test descriptions for qc_',field]},'interpreter','none');
%         %    % else
%         %    %    disp(['Field ''',field,''' was not found in the netcdf
%         %    file.'])
%         figure(var_fig);
%     end
%         linkaxes(ax,'x');
%         dynamicDateTicks(ax,'link')

end

return
