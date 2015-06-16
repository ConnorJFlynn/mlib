function sasze_radcals_nonlinear

infile = getfullname('SASZe*radcals.*.mat','radcals','Select "All Lamp" radcals file.');
cals = load(infile);

[pname, fname, ext] = fileparts(infile); pname = [pname, filesep];
fields = fieldnames(cals);
for f = length(fields):-1:1;
    if ~isempty(strfind(fields{f},'Lamps_'))
        Lamps(f) = sscanf(fields{f}(strfind(fields{f},'Lamps_')+length('Lamps_'):end),'%f');
    end
end
Lamps = unique(Lamps); 
% Loop through each lamp combination and traverse the structure to pull out
% well depth WD and responsivity to populate an array with integration time
% and wavelength as dimensions.
% Within the lamp combination loop, for each pixel (nm) compute the mean 
% well depth averaged over all integration times, and normalize the 
% responsivities versus this mean to yield nresp
for LL = Lamps
    lamp_str =['Lamps_',num2str(LL)];
    for spc = {'vis','nir'}
        clear WD resp pin_val
        spc = char(spc);
        cal = cals.(['Lamps_',sprintf('%g',LL)]).(char(spc));
        for t = length(cal.t_int_ms):-1:1
            ms_str = strrep(sprintf('%g',cal.t_int_ms(t)),'.','p');
            WD(t,:) = cal.(['welldepth_',ms_str,'_ms']);
            resp(t,:) = cal.(['resp_',ms_str,'_ms']);
        end
        nm = cal.lambda;
        for nm_ = length(nm):-1:1
            [wells, ij] = unique(WD(:,nm_));
            meanWD = meannonan(wells);
            nonlin.(lamp_str).(spc).mean_WD(nm_) = meanWD;
            if length(ij)>2
                [P,S] =polyfit(wells, resp(ij,nm_),2);
                pin_val = polyval(P,meanWD,S);
                %             hiss_rad.STAR_VIS.(['lamps_',LL]).pin_val(nm_) = interp1(wells, hiss_rad.STAR_VIS.(['lamps_',LL]).resp(ij,nm_),.45,'linear');
            else
                pin_val =NaN;
            end
            nonlin.(lamp_str).(spc).wells(:,nm_) = WD(:,nm_);
            nonlin.(lamp_str).(spc).pin_val(nm_) = pin_val;
            nonlin.(lamp_str).(spc).nresp(:,nm_) = resp(:,nm_)./pin_val;
            %         disp(nm_)
        end
    end
end
%
nm_ = 505;
figure; plot(nonlin.Lamps_1.vis.wells(:,nm_), nonlin.Lamps_1.vis.nresp(:,nm_),'o-',...
    nonlin.Lamps_2.vis.wells(:,nm_), nonlin.Lamps_2.vis.nresp(:,nm_),'o-',...
    nonlin.Lamps_3.vis.wells(:,nm_), nonlin.Lamps_3.vis.nresp(:,nm_),'o-',...
    nonlin.Lamps_6.vis.wells(:,nm_), nonlin.Lamps_6.vis.nresp(:,nm_),'o-',...
    nonlin.Lamps_9.vis.wells(:,nm_), nonlin.Lamps_9.vis.nresp(:,nm_),'o-',...
    nonlin.Lamps_12.vis.wells(:,nm_), nonlin.Lamps_12.vis.nresp(:,nm_),'o-');
legend('1 lamp','2 lamps','3 lamps','6 lamps','9 lamps','12 lamps');
xlabel('well depth')
ylabel('normalized responsivity')
title(['normalized responsivity vs well depth for vis pixel ',num2str(nm_)])
%
figure; lines = plot(nonlin.Lamps_9.vis.wells, nonlin.Lamps_9.vis.nresp,'-'); recolor(lines,cals.Lamps_3.vis.lambda)


figure; lines = plot(fliplr(nonlin.Lamps_9.vis.wells), fliplr(nonlin.Lamps_9.vis.nresp),'-'); recolor(lines,fliplr(cals.Lamps_3.vis.lambda))
% Now, go back through the various nresp (that were normalized against
% their own value at their mean well depth) to match against nresp
% curves from different lamp combos and pixels. 
figure
for LL = fliplr(Lamps)
    for spc = {'vis','nir'} ;
        spc = spc{:};
        lamp_str = ['Lamps_',num2str(LL)];
        if strcmp(spc,'vis')
            xl = [400:900];
        else
            xl = [980:1600];
        end
%         xl_i = find(cals.Lamps_1.(spc).lambda>=xl(1)&cals.Lamps_1.(spc).lambda<=xl(2));
        xl_i = unique(interp1(cals.Lamps_1.(spc).lambda, [1:length(cals.Lamps_1.(spc).lambda)],xl,'nearest'));
        WD = nonlin.(lamp_str).(spc).wells(:,xl_i);
        maxWD = max(WD);
        nresp = nonlin.(lamp_str).(spc).nresp(:,xl_i);
        
        [maxs, ij] = sort(maxWD);
        
        for nm_i = length(ij):-1:2
            top_nresp = nresp(:,ij(nm_i)); top_good = ~isNaN(top_nresp); top_nresp = top_nresp(top_good);
            bot_nresp = nresp(:,ij(nm_i-1));  bot_good = ~isNaN(bot_nresp); bot_nresp = bot_nresp(bot_good);
            top_WD = WD(:,ij(nm_i)); top_WD = top_WD(top_good);
            bot_WD = WD(:,ij(nm_i-1)); bot_WD = bot_WD(bot_good);
            if ~isempty(top_WD)&&~isempty(bot_WD)
                len = length(bot_WD);half = max([1,floor(len./2)]);
                top_nr = interp1(top_WD,top_nresp,bot_WD(half:end),'linear');
                len = length(bot_nresp);half = max([1,floor(len./2)]);
                bot_nr = bot_nresp(half:end);
                w = madf(top_nr./bot_nr -1, 3);
                repin = mean(top_nr(w)./bot_nr(w));
            end
            nresp(:,ij(nm_i-1)) = nresp(:,ij(nm_i-1)) .*repin;
        end
        nonlin.(lamp_str).(spc).nresp = NaN(size(nonlin.(lamp_str).(spc).nresp));
        nonlin.(lamp_str).(spc).nresp(:,xl_i) = nresp;
        good = ~isNaN(nonlin.(lamp_str).(spc).nresp);
        nonlin.(lamp_str).(spc).nresp_by_wd = nonlin.(lamp_str).(spc).nresp(good);
        nonlin.(lamp_str).(spc).wd = nonlin.(lamp_str).(spc).wells(good);
        [nonlin.(lamp_str).(spc).wd, ij] = sort(nonlin.(lamp_str).(spc).wd);
        nonlin.(lamp_str).(spc).nresp_by_wd = nonlin.(lamp_str).(spc).nresp_by_wd(ij);
        nonlin.(lamp_str).(spc).wd_smoothed = [min(nonlin.(lamp_str).(spc).wd):0.001:max(nonlin.(lamp_str).(spc).wd)];
            nonlin.(lamp_str).(spc).nresp_smoothed = NaN.*nonlin.(lamp_str).(spc).wd_smoothed;
            
                            
            for dWD = 2:length(nonlin.(lamp_str).(spc).wd_smoothed)
                W = 0.001 + 0.1.*nonlin.(lamp_str).(spc).wd_smoothed(dWD);
                wd_ = nonlin.(lamp_str).(spc).wd>=(nonlin.(lamp_str).(spc).wd_smoothed(dWD -1)-W) & ...
                    nonlin.(lamp_str).(spc).wd<= (nonlin.(lamp_str).(spc).wd_smoothed(dWD)+W);
                [P,S] = polyfit(nonlin.(lamp_str).(spc).wd(wd_), nonlin.(lamp_str).(spc).nresp_by_wd(wd_),2);
                nonlin.(lamp_str).(spc).nresp_smoothed(dWD) = polyval(P,nonlin.(lamp_str).(spc).wd_smoothed(dWD),S);
            end
            wd_ = nonlin.(lamp_str).(spc).wd>=(nonlin.(lamp_str).(spc).wd_smoothed(1)-.001) & ...
                    nonlin.(lamp_str).(spc).wd<= (nonlin.(lamp_str).(spc).wd_smoothed(1)+0.001);
                [P,S] = polyfit(nonlin.(lamp_str).(spc).wd(wd_), nonlin.(lamp_str).(spc).nresp_by_wd(wd_),2);
                nonlin.(lamp_str).(spc).nresp_smoothed(1) = polyval(P,nonlin.(lamp_str).(spc).wd_smoothed(1),S);

        if strcmp(spc,'vis')   
        figure(10); 
        else
            figure(11); 
        end

            lines = plot(nonlin.(lamp_str).(spc).wells(:,xl_i), nresp,'.'); 
            recolor(lines,cals.(lamp_str).(spc).lambda(xl_i));
            hold('on');
            plot(nonlin.(lamp_str).(spc).wd_smoothed, nonlin.(lamp_str).(spc).nresp_smoothed,'k-');

        hold('off')
        xlabel('well depth')
        ylabel('sensitivity')
        title(['Relative sensitivity to well-depth for ',spc, ' with ',lamp_str],'interp','none'); 
        saveas(10,[pname, 'welldepth_sensitivity.',lamp_str,'_',spc,'.fig']);
        saveas(10,[pname, 'welldepth_sensitivity.',lamp_str,'_',spc,'.png']);
    end
  OK =menu('continue or exit?','Continue','Exit')
  if OK==2
      break
  end
end

return