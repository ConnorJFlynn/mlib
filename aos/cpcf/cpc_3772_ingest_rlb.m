% ingest raw txt files for qa/qc

clear variables
close all

clc
%clf
fclose('all');

pref.site_code = 'ACX';
pref.filter = 1;
pref.id_string = 'cpc3772'; 
pref.time_res = '01s';
pref.save_ext = 'tsv';
pref.save_plots = 0;
pref.view_plots = 0;
pref.plot_type.fig = 1;
pref.plot_type.jpg = 1;
pref

% function = cpc_3772_ingest(date);
basepath = 'C:\Users\rbullard\Documents\MATLAB\ARM_DATA_PROCESSING\';
rawpath = [basepath pref.site_code '\cpcf\' 'RAW\'];
if ~exist(rawpath)
    mkdir(rawpath)
end
tarpath = [rawpath 'TAR\'];
if ~exist(tarpath)
    mkdir(tarpath)
end
tsvpath = [rawpath 'TSV\'];
if ~exist(tsvpath)
    mkdir(tsvpath)
end
savepath = [basepath pref.site_code '\cpcf\' 'FLAGGED\'];
if ~exist(savepath)
    mkdir(savepath)
end
plotpath = [basepath pref.site_code '\cpcf\' 'PLOTS\'];
if ~exist(plotpath)
    mkdir(plotpath)
end
%Get the Configuration File Information First
if pref.filter
    fname = 'cpc3772_Data_Configuration.txt';
    fid = fopen(fname,'r');
    comment_line_1 = fgetl(fid);comment_line_1 = fgetl(fid);
%     if strcmp(line,'FALSE')
%         pref.flow_correction = 0;
%     elseif strcmp(line,'TRUE');
%         pref.flow_correction = 1;
%     end
%     clear line
    fclose(fid);
    fid = fopen(fname,'r');
    hlines = 3;
    data_type = '%s%s%f%f%s';
    M = textscan(fid,data_type,'HeaderLines',hlines,'Delimiter','\t');
    var_names = M{2};
    lo_limit = M{3};
    hi_limit = M{4};
    fclose(fid);
    
    fname2 = [rawpath 'header.txt'];
end

%We find all the *.tar files, untar them, leave the *.tsv files here
% and move the *.tar files to the TAR directory
tar_structure = dir([rawpath '*.tar']);
if ~isempty(tar_structure)
    nt = length(tar_structure);
    
    for i = 1:nt
        
        untar([rawpath tar_structure(i).name],rawpath);
        movefile([rawpath tar_structure(i).name],[tarpath tar_structure(i).name]);
        
    end
end
% find all files with extension *.tsv
dir_structure = dir([rawpath '*.tsv']);
nf = length(dir_structure);
for i = 1:nf
    file_names{i,1} = dir_structure(i).name;
    ind1 = findstr(file_names{i,1},pref.id_string);
    ind2 = length(pref.id_string);
    temp1 = file_names{i,1}(ind1+ind2+8:ind1+ind2+15);
    temp2 = file_names{i,1}(ind1+ind2+17:ind1+ind2+22);
    file_times(i) = datenum(str2num(temp1(1:4)),str2num(temp1(5:6)),...
        str2num(temp1(7:8)),str2num(temp2(1:2)),str2num(temp2(3:4)),...
        str2num(temp2(5:6)));
    clear temp
    clear temp2
    clear ind1
    clear ind2
    
end
[file_times sort_ind] = sort(file_times);
file_names = file_names(sort_ind); clear sort_ind
file_dates = unique(floor(file_times));
n_days = max(size(file_dates));


    if pref.filter
        save_info = file_names{i,1};
        ind = findstr(save_info,'.');
        savename1 = save_info(1:ind(1)-1);
        savecode = 'b1';
        savelevel = save_info(ind(4)+1:ind(5)-1);
        saveinstr = pref.id_string;
        savetimres = pref.time_res;
        saveextension = pref.save_ext;
        %savename2 = save_info(ind(5)+1:ind(6)-1);
%         saveinstr = save_info(ind(6)+1:ind(7)-1);
%         savetimres = save_info(ind(7)+1:ind(8)-1);
%         saveextension = save_info(ind(12):end);
    end

%date = '20150127';
%ind1 = find(strcmp(date,file_times) == 1);
for i = 1:n_days
    gi = find(floor(file_times)==file_dates(i));
    if pref.filter
        temp = datevec(file_dates(i));
        
        savedate = [num2str(temp(1),'%4d') num2str(temp(2),'%02d') num2str(temp(3),'%02d')];
%         if strcmp(pref.site_code,'MAG')
%             savename = [savename1 '.' savecode '.' savedate '.' savelevel '.' ...
%                 saveinstr '.' savetimres '.' savecode '.' ...
%                 savedate '.' savelevel saveextension];
%         else
            savename = [savename1 '.' savecode '.' savedate '.' savelevel '.' ...
                saveinstr '.' savetimres '.' saveextension];
%         end
        clear temp
    end
    for j = 1:max(size(gi))
        fn = [rawpath file_names{gi(j)}];
        fid3 = fopen(fn,'r');
        startrow = 39;
        %%% Lets Read and Save the Header Information If needed
        if pref.filter
            if ~exist(fname2)
                fid2 = fopen(fname2,'w');
                clear l
                l = 1;
                while l <= startrow
                    line = fgetl(fid3);
                    if max(size(line))> 16
                    if l == 5
                        fprintf(fid2,'%s\n',line(1:22));
                    elseif l == 9
                        fprintf(fid2,'%s\n',line(1:19));
                    elseif l == 10
                        fprintf(fid2,'%s\n',line(1:39));
                    elseif l == 13
                        fprintf(fid2,'%s\n',line(1:30));
                    elseif l == 14
                        fprintf(fid2,'%s %s\n',line(1:15),comment_line_1);
                    elseif l == 35
                        fprintf(fid2,'%s\t%s\n',line(1:9),'Particle Number Concentration');
                    elseif l == 37
                        fprintf(fid2,'%s\t%s\t%s\n',line(1:10),'HH:MM:SS.FF','Particles Per Cubic Centimeter');
                    else
                        fprintf(fid2,'%s\n',line);
                    end
                    end
                    l = l+1;
                    
                end
                clear line
                
                fclose(fid2);
                fclose(fid3);
                fid3 =fopen(fn,'r');
            end
        end
        
        
        
        %%%
        
        delimiter = '\t';
        %startrow = 39;
        formatSpec = '%s %s %f %s %f %f %f %f %f %f %f %f %s %f %s %f %f %*[^\n]';
        header_format = '%s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %*[^\n]';
        textscan(fid3,header_format,startrow,'Delimiter', delimiter);
        dataArray = textscan(fid3, formatSpec, 'Delimiter', delimiter, 'EmptyValue' ,NaN,'ReturnOnError', false);
        fclose(fid3);
        if max(size(dataArray{1})) > max(size(dataArray{2}))
            dataArray{1} = dataArray{1}(1:end-1);
        end
        temp = strcat(dataArray{1},dataArray{2});
        dataArray{1} = datenum(temp,'yyyy-mm-ddHH:MM:SS.FFF');
        
        if(exist('Date_Time','var'))
            temp=vertcat(Date_Time,dataArray{:,1});
            Date_Time=temp;
        else Date_Time = dataArray{:, 1};
        end
        
        if(exist('Concentration','var'))
            temp = vertcat(Concentration,dataArray{:,3});
            Concentration = temp;
        else Concentration = dataArray{:, 3};
        end
        
        %     if(exist('InstrErrs','var'))
        %         temp = vertcat(InstrErrs,dataArray{:,4});
        %         InstrErrs = temp;
        %     else InstrErrs = dataArray{:, 4};
        %     end
        %     errorcode = str2num(cell2mat(InstrErrs));
        
        
        if(exist('Temp_sat','var'))
            temp = vertcat(Temp_sat,dataArray{:,5});
            Temp_sat = temp;
        else Temp_sat = dataArray{:, 5};
        end
        if(exist('Temp_con','var'))
            temp = vertcat(Temp_con,dataArray{:,6});
            Temp_con = temp;
        else Temp_con = dataArray{:, 6};
        end
        if(exist('Temp_opt','var'))
            temp = vertcat(Temp_opt,dataArray{:,7});
            Temp_opt = temp;
        else Temp_opt = dataArray{:, 7};
        end
        if(exist('Temp_cab','var'))
            temp = vertcat(Temp_cab,dataArray{:,8});
            Temp_cab = temp;
        else Temp_cab = dataArray{:, 8};
        end
        
        if(exist('Press_amb','var'))
            temp = vertcat(Press_amb,dataArray{:,9});
            Press_amb = temp;
        else Press_amb = dataArray{:, 9};
        end
        if(exist('Press_orf','var'))
            temp = vertcat(Press_orf,dataArray{:,10});
            Press_orf = temp;
        else Press_orf = dataArray{:, 10};
        end
        if(exist('Press_noz','var'))
            temp = vertcat(Press_noz,dataArray{:,11});
            Press_noz = temp;
        else Press_noz = dataArray{:, 11};
        end
        
        if(exist('Liq_lvl','var'))
            temp = vertcat(Liq_lvl,dataArray{:,14});
            Liq_lvl = temp;
        else Liq_lvl = dataArray{:, 14};
        end
        
        if(exist('DilFlow_sp','var'))
            temp = vertcat(DilFlow_sp,dataArray{:,16});
            DilFlow_sp = temp;
        else DilFlow_sp = dataArray{:, 16};
        end
        
        if(exist('DilFlow_rd','var'))
            temp = vertcat(DilFlow_rd,dataArray{:,17});
            DilFlow_rd = temp;
        else DilFlow_rd = dataArray{:, 17};
        end
        
    end
    
    flag.data = 1;
    if pref.filter
        flag.data = 0;
        Concentration_corrected = Concentration;
        for k = 1:max(size(var_names))
            temp_gi = find(and(eval(var_names{k})>lo_limit(k),eval(var_names{k})<hi_limit(k)));
            if isempty(temp_gi);
                fprintf('No Valid "%s" Data For %s \n',var_names{k},datestr(file_dates(i)));
                flag.data = 0;
            else
                fprintf('%s, %5.0f of %5.0f Points Within %5.1f - %5.1f \n',var_names{k},max(size(temp_gi)),max(size(Concentration(find(~isnan(Concentration))))),lo_limit(k),hi_limit(k));
                temp_bi = find(or(eval(var_names{k})<=lo_limit(k),eval(var_names{k})>hi_limit(k)));
                if ~isempty(temp_bi)
                    eval_str = [var_names{k} '(temp_bi)= NaN;'];
                    eval(eval_str);
                    flag.data = 1;
                    Concentration_corrected(temp_bi) = NaN;
                end
                
            end
            clear temp_gi
            clear temp_bi
            clear eval_str
        end
    end
    
    s1= datestr(file_dates(i));
    
    if flag.data
        pref.spacing.units = 'sec';
        pref.spacing.val = 1;
        [Flagged_Time Flagged_Concentration] = fixed_time_grid(Date_Time,Concentration_corrected,pref);
        if pref.view_plots
            figure(1)
            % set(gcf,'DefaultAxesColorOrder',[0 0 1;1 0 0;0 1 0]);
            subplot(4,1,1)
            plot(Flagged_Time,Flagged_Concentration,'b-');hold on
            %plot(Date_Time,Concentration,'b-'); hold on
            % plot(Date_Time,Concentration_corrected,'k'); hold on
            line([Date_Time(1) Date_Time(end)],[1e4 1e4]); hold on
            hold off
            datetick('x');
            legend(s1);
            ylim([1e0 1e5])
            set(gca,'yscale','log')
            set(gca,'ytick',logspace(0,5,6))
            xlabel('Time, UTC');
            ylabel('Number Concentration [#/cm^3]');
            title('3772 Condensation Particle Counter [>10 nm]');
            
            subplot(4,1,2)
            plot(Date_Time,Temp_opt,'g-','linewidth',2); hold on
            plot(Date_Time,Temp_sat,'k-','linewidth',2); hold on
            plot(Date_Time,Temp_cab,'r-','linewidth',2); hold on
            plot(Date_Time,Temp_con,'b-','linewidth',2); hold on
            legend ('optics','saturator','cabinet','condenser')
            hold off
            datetick('x');
            xlabel('Time, UTC');
            ylabel('Temperatures [C]');
            % title('3772 Condensation Particle Counter [>10 nm]');
            
            subplot(4,1,3)
            plot(Date_Time,Press_amb,'r-','linewidth',2); hold on
            plot(Date_Time,Press_orf,'b-','linewidth',2); hold on
            plot(Date_Time,Press_noz,'g-','linewidth',2); hold on
            legend ('ambient','orifice','nozzle')
            hold off
            datetick('x');
            set(gca,'yscale','log')
            ylim([1e0 1.1e2])
            xlabel('Time, UTC');
            ylabel('Presssures [kPa]');
            
            subplot(4,1,4)
            plot(Date_Time,Liq_lvl,'r-','linewidth',2); hold on
            ylim([0 1])
            hold off
            datetick('x');
            xlabel('Time, UTC');
            ylabel('Butanol Level [fractional]');
            if pref.save_plots
                if pref.plot_type.jpg
                    plot_str = [plotpath savedate '_Conc_Temp_Press_Liq'];
                    saveas(gca,plot_str,'jpeg');
                end
                if pref.plot_type.fig
                    plot_str2 = [plotpath 'Conc_Temp_Press_Liq_' savedate];
                    saveas(gca,plot_str2,'fig');
                end
                clear plot_str
            end
            %%
            figure(2)
            subplot(3,1,1)
            plot(Flagged_Time,Flagged_Concentration,'b-');hold on
            %plot(Date_Time,Concentration,'b-'); hold on
            hold off
            datetick('x');
            % legend(s1);
            ylim([1e1 1e5])
            set(gca,'yscale','log')
            % set(gca,'ytick',logspace(0,5,6))
            xlabel(horzcat(s1,', Time, UTC'),'fontsize',14);
            ylabel('Number Concentration [#/cm^3]','fontsize',14);
            title('3772 Condensation Particle Counter [> 3 nm]','fontsize',14);
            set(gca,'fontsize',14)
            grid on
            set(gca,'yminorgrid','off')
            
            subplot(3,1,2)
            % plot(Date_Time,Press_amb,'r-','linewidth',2); hold on
            % plot(Date_Time,Press_orf,'b-','linewidth',2); hold on
            plot(Date_Time,Press_noz,'r-','linewidth',2); hold on
            legend ('Nozzle Pressure');
            hold off
            datetick('x');
            % set(gca,'yscale','log')
            % ylim([1 3])
            xlabel('Time, UTC');
            ylabel('Presssures [kPa]');
            
            subplot(3,1,3)
            % plot(Date_Time,Press_amb,'r-','linewidth',2); hold on
            plot(Date_Time,Press_orf,'k-','linewidth',2); hold on
            % plot(Date_Time,Press_noz,'r-','linewidth',2); hold on
            legend ('Orifice Pressure');
            hold off
            datetick('x');
            % set(gca,'yscale','log')
            % ylim([1 3])
            xlabel('Time, UTC');
            ylabel('Presssures [kPa]');
            
            %Now we will get the data on a fixed time axis and prepare for saving
            
            
            if pref.save_plots
                if pref.plot_type.jpg
                    plot_str = [plotpath savedate '_Conc_Press'];
                    saveas(gca,plot_str,'jpeg');
                end
                if pref.plot_type.fig
                    plot_str2 = [plotpath 'Conc_Press' savedate];
                    saveas(gca,plot_str2,'fig');
                end
                clear plot_str
            end
            
            
            
            
            
            figure(3)
            
            % set(gcf,'DefaultAxesColorOrder',[0 0 1;1 0 0;0 1 0]);
            subplot(2,1,1)
            plot(Date_Time,Concentration,'b-'); hold on
            % plot(Date_Time,Concentration_corrected,'k'); hold on
            %line([Date_Time(1) Date_Time(end)],[1e4 1e4]); hold on
            hold off
            
            datetick('x');
            xlim([min(Flagged_Time) max(Flagged_Time)]);
            %legend(s1);
            
            
            ylim([1e0 1e5])
            set(gca,'yscale','log')
            set(gca,'ytick',logspace(0,5,6))
            xlabel('Time, UTC');
            ylabel('Number Concentration [#/cm^3]');
            title('3772 CPC, No Filtering, No Time Adjustment');
            
            subplot(2,1,2)
            plot(Flagged_Time,Flagged_Concentration,'b-'); hold on
            % plot(Date_Time,Concentration_corrected,'k'); hold on
            %line([Date_Time(1) Date_Time(end)],[1e4 1e4]); hold on
            hold off
            %xlim([min(Flagged_Time) max(Flagged_Time)]);
            datetick('x');
            xlim([min(Flagged_Time) max(Flagged_Time)]);
            %legend(s1);
            ylim([1e0 1e5])
            set(gca,'yscale','log')
            set(gca,'ytick',logspace(0,5,6))
            xlabel('Time, UTC');
            ylabel('Number Concentration [#/cm^3]');
            title('3772 CPC, Uniform Time Axis, Filtered From Config File');
            
            
            if pref.save_plots
                if pref.plot_type.jpg
                    plot_str = [plotpath savedate '_Conc_Before_After_Flagging'];
                    saveas(gca,plot_str,'jpeg');
                end
                if pref.plot_type.fig
                    plot_str2 = [plotpath 'Conc_Before_After_Flagging' savedate];
                    saveas(gca,plot_str2,'fig');
                end
                clear plot_str
            end
        end
        
        fprintf('%s \n',datestr(floor(min(Flagged_Time))));
        
        %Now Saving the file to the target directory
        close all
        save_str = [savepath savename];
        movefile(fname2,save_str);
        fid4 = fopen(save_str,'a');
        %         fprintf(fid,'%s\t%s\t%s\n','Date','Time','Particle Number Concentration (# of particles per cubic centimeter)');
        %         fclose(fid);
        
        %         fid = fopen(save_str,'a');
        
        Flagged_Vec = datevec(Flagged_Time);
        for k = 1:max(size(Flagged_Time));
            %             temp_date_str = [num2str(Flagged_Vec(k,1),'%04d') '-' num2str(Flagged_Vec(k,2),'%02d')...
            %                 '-' num2str(Flagged_Vec(k,3),'%02d')];
            %             temp_time_str = [num2str(Flagged_Vec(k,4),'%02d') ':' num2str(Flagged_Vec(k,5),'%02d')...
            %                 ':' num2str(Flagged_Vec(k,6),'%02d')];
            %
            temp_date_str = datestr(Flagged_Time(k),'yyyy-mm-dd');
            temp_time_str = datestr(Flagged_Time(k),'HH:MM:SS.FFF');
            temp_time_str = temp_time_str(1:end-1);
            fprintf(fid4,'%s\t%s\t%0.1f\n',temp_date_str,temp_time_str,Flagged_Concentration(k));
            clear temp_date_str
            clear temp_time_str
            
        end
        fclose(fid4);
        
    end
    for j = 1:max(size(gi))
        fn = [rawpath file_names{gi(j)}];
        
        movefile(fn,tsvpath);
        clear fn
    end
    clear Date_Time
    clear savename
    clear save_str
    clear savedate
    clear gi
    clear fn
    clear fileID
    clear dataArray
    clear Date_Time
    clear Concentration
    clear Temp_sat
    clear Temp_con
    clear Temp_opt
    clear Temp_cab
    clear Press_amb
    clear Press_orf
    clear Press_noz
    clear Liq_lvl
    clear DilFlow_sp
    clear DilFlow_rd
    clear s1
    clear Flagged_*
    
    
    
    
end



