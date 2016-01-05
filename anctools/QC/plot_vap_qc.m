function [status,ax,time_,qc_impact] = plot_vap_qc(anc, field)
% [status,ax,time_,qc_impact] = plot_vap_qc(anc, field);
% Generates plot of time-series qc_field for field following VAP QC conventions.
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
    qc_params = qc_bits;
    for n = length(qc_params):-1:1
        tmp = qc_params{n};
        if strcmp(tmp,'long_name')||strcmp(tmp,'units')||strcmp(tmp,'description')||...
                (~isempty(strfind(tmp,'bit_'))&&(~isempty(strfind(tmp,'_assessment'))||~isempty(strfind(tmp,'_description'))))
            qc_params(n) = [];
        end
    end
    %%
    if isfield(var.atts,'valid_min')
        qc_params(end+1) = {'valid_min'};
    end
    if isfield(var.atts,'valid_max')
        qc_params(end+1) = {'valid_max'};
    end
    if isfield(var.atts,'valid_delta')
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
        qc_tests = zeros([tests,length(qc.data)]);
        for t = tests:-1:1
            if isfield(qc.atts, ['bit_',num2str(t),'_assessment'])
                bad = findstr(upper(qc.atts.(['bit_',num2str(t),'_assessment']).data),'BAD');
                if bad
                    qc_tests(t,:) = 2*bitget(uint32(qc.data), t);
                else
                    qc_tests(t,:) = bitget(uint32(qc.data), t);
                end
                desc{t} = ['test #',num2str(t),': ',[qc.atts.(['bit_',num2str(t),'_description']).data]];
                for n = length(qc_params):-1:1
                    if isfield(var.atts,qc_params{n})
                        desc{t} = strrep(desc{t},qc_params{n},sprintf('%g',var.atts.(qc_params{n}).data));
                    elseif isfield(qc.atts,qc_params{n})
                        desc{t} = strrep(desc{t},qc_params{n},sprintf('%g',qc.atts.(qc_params{n}).data));
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
    
    %%
    fields = fieldnames(anc.vars);
    
    for X = length(fields):-1:1
        named = false; D = 1;
        while ~named && D<=length(desc)
            named = D .* ~isempty(strfind(desc{D},fields{X}));
            D = D +1;
        end
        if ~isempty(strfind(fields{X},'qc_')) || strcmp(fields{X},field) || strcmp(fields{X},'time') || ...
                strcmp(fields{X},'time_offset')  || ~all(strcmp(anc.vars.(fields{X}).dims,anc.recdim.name)) || ~named
            fields(X) = [];
        end
    end
    %%
      if isempty(dt)
         time_ = (anc.time - datenum(datestr(first_time,'yyyy-mm-dd HH:MM:00'),'yyyy-mm-dd HH:MM:SS'))*24*60*60;
         time_str = 'seconds from 00:00 UTC';
      elseif dt <= 1/(24*60)
         time_ = (anc.time - datenum(datestr(first_time,'yyyy-mm-dd HH:MM:00'),'yyyy-mm-dd HH:MM:SS'))*24*60*60;
         time_str = 'seconds from start of minute';
      elseif (dt<=1/24)
         time_ = (anc.time - datenum(datestr(first_time,'yyyy-mm-dd HH:00'),'yyyy-mm-dd HH:MM'))*24*60;
         time_str = 'minutes from top of hour UTC';
      elseif (dt<=1)
         time_ = (anc.time - datenum(datestr(first_time,'yyyy-mm-dd'),'yyyy-mm-dd'))*24;
         time_str = 'hours from 00:00 UTC';
      elseif (dt<=31)
         time_ = (anc.time - datenum(datestr(first_time,'yyyy-mm-01'),'yyyy-mm-01'));
         time_str = ['days since ', datestr(first_time, 'mmm 1, yyyy')];
        elseif (dt<=730)
         time_ = (anc.time - datenum(datestr(first_time,'yyyy-01-01'),'yyyy-01-01'));
         time_str = ['days since ', datestr(first_time, 'Jan 1, yyyy')];
      else 
         time_ = (anc.time - datenum(datestr(first_time,'yyyy-01-01'),'yyyy-01-01'))./365.25;
         time_str = ['years since ', datestr(first_time, 'Jan 1, yyyy')];
      end
    %plot figure 2 first so that figure 1 window is current / on top at end
    %       fig(1) = figure(1);
    ax(1) = subplot(2,1,1); cla(ax(1))
    plot(time_(~missing&(qc_impact==2)),var.data(~missing&(qc_impact==2)),'r.');
    hold('on');
    plot(time_(~missing&(qc_impact==1)),var.data(~missing&(qc_impact==1)),'.','color',[1,230./255,50./255]);
    plot(time_(~missing&(qc_impact==0)),var.data(~missing&(qc_impact==0)),'g.');
    hold('off');
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
        %      set(tx(x),'units','data','clipping','on')
    end
    var_fig = gcf;
    panes = length(fields);
    if panes>0
        fig_pos = get(var_fig,'position');
        figure(55);
        set(gcf,'position',[fig_pos(1)+1.05.*fig_pos(3), fig_pos(2),fig_pos(3), fig_pos(4)]);
        ax(3) = subplot(panes,1,1);
        cla(ax(3));
        if isfield(anc.vars,['qc_',fields{1}])
            qc_impact = qc_impacts(anc.vars.(['qc_',fields{1}]));
        else
            qc_impact = zeros(size(anc.vars.(fields{1}).data));
        end
        missing = anc.vars.(fields{1}).data< -9990;
        plot(time_(~missing&(qc_impact==2)),anc.vars.(fields{1}).data(~missing&(qc_impact==2)),'k.',...
            time_(~missing&(qc_impact==2)),anc.vars.(fields{1}).data(~missing&(qc_impact==2)),'r.');
        hold('on');
        plot(time_(~missing&(qc_impact==1)),anc.vars.(fields{1}).data(~missing&(qc_impact==1)),'.','color',[1,230./255,50./255]);
        plot(time_(~missing&(qc_impact==0)),anc.vars.(fields{1}).data(~missing&(qc_impact==0)),'g.');
        hold('off');
        lg = legend(fields{1}); set(lg,'interp','none') ;
        title(['QC fields for ' field],'interp','none')
        
        for pane = 2:panes
            ax(2+pane) = subplot(panes,1,pane);
            cla(ax(pane+2));
            if isfield(anc.vars,['qc_',fields{pane}])
                qc_impact = qc_impacts(anc.vars.(['qc_',fields{pane}]));
            else
                qc_impact = zeros(size(anc.vars.(fields{pane}).data));
            end
            missing = anc.vars.(fields{pane}).data< -9990;
            plot(time_(~missing&(qc_impact==2)),anc.vars.(fields{pane}).data(~missing&(qc_impact==2)),'k.',...
                time_(~missing&(qc_impact==2)),anc.vars.(fields{pane}).data(~missing&(qc_impact==2)),'r.');
            hold('on');
            plot(time_(~missing&(qc_impact==1)),anc.vars.(fields{pane}).data(~missing&(qc_impact==1)),'.','color',[1,230./255,50./255]);
            plot(time_(~missing&(qc_impact==0)),anc.vars.(fields{pane}).data(~missing&(qc_impact==0)),'g.');
            hold('off');
            lg = legend(fields{pane}); set(lg,'interp','none')
        end
        xlabel(time_str,'interpreter','none');

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
        figure(var_fig);
    end
        linkaxes(ax,'x');
        zoom('on')
end

