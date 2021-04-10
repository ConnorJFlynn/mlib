function XY_regression_of_timeseries(hfig,extras)
% XY_regression_of_timeseries(hfig,extras)
% Intended to generate an XY regresssion of two time-series plots
% Plot must contain only two time-series.  Regression will be computed with
% each as independent and dependent, and several statistics embedded in the
% plot as gtext
% 

if isempty(who('hfig'))|| isempty(hfig)
    fig = menu('Select an open figure window or a file:','Figure Window','Select a File...');
    if fig>1
        fig_file = getfullname('*.fig','fig','Select a Matlab figure file.');
        hfig = open(fig_file);
        menu({'Zoom as desired.';'Only VISIBLE data will be used.';'Then select OK...'},'OK');
    else
        menu({'Select an image and zoom as desired.';'Only VISIBLE data will be used.';'Then select OK...'},'OK');
        hfig = gcf;
    end
else
    menu({'Select an image and zoom as desired.';'Only VISIBLE data will be used.';'Then select OK...'},'OK');
end
extras.trim = true;

leg = findobj(hfig,'Type','legend');
if length(leg)>1
    menu('Select the axes to extract.  Hit OK when ready.','OK');
    pause(0.25);
    leg = get(gca,'Legend');
end
if ~isempty(leg)
  leg_str = leg.String;
else
    leg_str(1) = {'Series 1'}; leg_str(2) = {'Series 2'};
end

d = findall(gca, '-property', 'xdata');
xydatas = flipud(arrayfun(@(h) get(h, {'xdata','ydata', 'type'}), d, 'Uniform', 0));

v = axis; xl = [v(1) v(2)]; yl = [v(3) v(4)];
if length(xydatas)==2
    % We have two data sets, now we check the legends
    done = false;
    while ~done
        lg = menu('Modify legend or Done',['Series 1: ',leg_str{1}], ['Series 2: ',leg_str{2}],'Done');
        if lg==1
            leg_str(1) = {input(['Enter legend for Series 1: <',leg_str{1},'> '],'s')};
        elseif lg==2
            leg_str(2) = {input(['Enter legend for Series 2: <',leg_str{2},'> '],'s')};
        elseif lg==3
            done = true;
        end
    end
    one.x = xydatas{1}{1,1};
    one.y = xydatas{1}{1,2};
    if ~isempty(who('extras'))&&isfield(extras,'trim')&&extras.trim
        trim = one.x<min(xl)|one.x>max(xl)|one.y<min(yl)|one.y>max(yl);
        one.x(trim) = []; one.y(trim) = [];
        nans = isnan(one.x)|isnan(one.y);
        one.x(nans) = []; one.y(nans) = [];
    end
    two.x = xydatas{2}{1,1};
    two.y = xydatas{2}{1,2};
    if ~isempty(who('extras'))&&isfield(extras,'trim')&&extras.trim
        trim = two.x<min(xl)|two.x>max(xl)|two.y<min(yl)|two.y>max(yl);
        two.x(trim) = []; two.y(trim) = [];
        nans = isnan(two.x)|isnan(two.y);
        two.x(nans) = []; two.y(nans) = [];
    end
    
    one.y2 = interp1(two.x, two.y, one.x,'linear','extrap');
    [P_one, S_one, mu_one] = polyfit(one.y, one.y2, 1);
    stats_one = fit_stat(one.y, one.y2, P_one, S_one, mu_one);
    figure; plot(one.y, one.y2, 'o'); axis('square'); v_one = axis;
    tl = title([leg_str{2}, ' treated as dependent']);
    set(tl,'interp','none');
    xlabel(leg_str{1},'interp','none'); ylabel(leg_str{2},'interp','none');
    XX = [min(min(v_one)), max(max(v_one))];
    hold('on'); plot(XX, polyval(P_one, XX, S_one,mu_one),'r-'); 
    xlim(XX); ylim(XX);
    txt_one = {['N = ', num2str(stats_one.N)],...
    ['bias (y-x) =  ',sprintf('%1.1g',stats_one.bias)], ...
    ['slope = ',sprintf('%1.3f',P_one(1)./mu_one(2))], ...
    ['Y\_int = ', sprintf('%0.02f',polyval(P_one,0, S_one, mu_one))],...
    ['R^2 = ',sprintf('%1.3f',stats_one.R_sqrd)],...
    ['RMSE = ',sprintf('%1.3f',stats_one.RMSE)]};
    gt = gtext(txt_one);
    
    two.y2 = interp1(one.x, one.y, two.x, 'linear','extrap');
    [P_two, S_two,mu_two] = polyfit(two.y, two.y2, 1);
    stats_two = fit_stat(two.y, two.y2, P_two, S_two, mu_two);
    figure; plot(two.y, two.y2, 'o'); axis('square'); v_two = axis;
    tl = title([leg_str{1}, ' treated as dependent']);
    set(tl,'interp','none');
    xlabel(leg_str{2},'interp','none'); ylabel(leg_str{1},'interp','none');
    XX = [min(min(v_two)), max(max(v_two))];
    hold('on'); plot(XX, polyval(P_two, XX, S_two,mu_two),'r-'); 
    xlim(XX); ylim(XX);
    txt_two = {['N = ', num2str(stats_two.N)],...
    ['bias (y-x) =  ',sprintf('%1.1g',stats_two.bias)], ...
    ['slope = ',sprintf('%1.3f',P_two(1)./mu_two(2))], ...
    ['Y\_int = ', sprintf('%0.02f',polyval(P_two, 0, S_two,mu_two))],...
    ['R^2 = ',sprintf('%1.3f',stats_two.R_sqrd)],...
    ['RMSE = ',sprintf('%1.3f',stats_two.RMSE)]};
    gt = gtext(txt_two);
    
    [ainb, bina] = nearest(one.x, two.x);
    xy.x = one.x(ainb);
    xy.y = one.y(ainb); 
    xy.y2 = two.y(bina);
    [Pp_one] = polyfit(xy.y, xy.y2, 1);
    [Pp_two] = polyfit(xy.y2, xy.y, 1);
    % Now we need to construct the combined Pp. 
    Pp(1) = (Pp_one(1)+1./Pp_two(1))./2;
    X_int = Pp_two(2)./Pp_two(1);
    Pp(2) = (Pp_one(2) + X_int)./2;
    stats_xy.bias = mean(xy.y) - mean(xy.y2);
    figure; plot(xy.y, xy.y2, 'o'); axis('square'); v_xy = axis;
    tl = title('Both fields treated as independent');
    set(tl,'interp','none')
    xlabel(leg_str{1},'interp','none'); ylabel(leg_str{2},'interp','none');
    XX = [min(min(v_xy)), max(max(v_xy))];
    hold('on'); plot(XX, polyval(Pp, XX),'r-'); 
    xlim(XX); ylim(XX);
    txt_xy = {['N = ', num2str(length(xy.x))],...
    ['bias (y-x) =  ',sprintf('%1.1g',stats_xy.bias)], ...
    ['slope = ',sprintf('%1.3f',Pp(1))], ...
    ['Y\_int = ', sprintf('%0.02f',Pp(2))]};
    gt = gtext(txt_xy);
else
    disp('XY regression requires time-series of EXACTLY two fields!');
end

return