function [ftrace,raw_filter] = read_filter_file(filename, ftrace);
% [raw_filter, trace] = read_filter_file(filename);
% Attempts to read provided file as an MFRSR filter file
%  Two formats are supported, either the multi-column format or a
%  2-column file
if ~exist('filename', 'var')
    [fname, pname] = uigetfile('*.*');
    filename = [pname, fname];
end
if ~exist('ftrace', 'var')
    ftrace = struct([]);
end
%%
[pname, fname, ext] = fileparts(filename);
pname = [pname, filesep];
fname = [fname, ext];
nominal =[415, 500, 615, 673, 870, 940];
% This process expects filter files white space delimited, to have no header row, and to have an
% uninterupted wavelength field as column 2.  (Column 1 is monochromator
% step (unused by us).  Col 3 = ch 1 (broadband), Col 4 = ch 2 (415 nm) etc
% User is to iteratively select one or more filter files until each filter
% a ftrace has been obtained for each filter.  Previous filter data will be
% overwritten by subsequent data in same channel.
raw_file = read_rawfile([pname, fname]);
if size(raw_file,2)==2
    % Then this file only contains a filter ftrace for only one filter.
    for i =1:length(nominal)
        sub = find(abs(nominal(i)-raw_file(:,1))<20);
        gap = find(diff(sub)> 2*(mean(diff(sub))));
        if any(gap)
            sub = sub(1:(gap-1));
        end
        if length(sub)>10
            raw_filter.nominal = nominal(i);
            raw_filter.nm = raw_file(sub,1);
            raw_filter.T = raw_file(sub,2);
            %          [max_T, max_ind] = max(raw_file(:,2));
            %          if any(abs(nominal(i)-raw_file(max_ind,1))<10)
            %             raw_filter.nominal = nominal(i);
            %             raw_filter.nm = raw_file(:,1);
            %             raw_filter.T = raw_file(:,2);
            ftrace{i} = process_mfr_filter(raw_filter);
            figure; plot(ftrace{i}.nm, ftrace{i}.normed.T, 'bx', ftrace{i}.nm, ftrace{i}.normed.T, 'b');v = axis;
            hold('on');plot([ftrace{i}.normed.cw, ftrace{i}.normed.cw], [v(3), v(4)],'r:'); hold('off');
            titlestr1 = sprintf('Nominal wavelength = %3.0f \n',ftrace{i}.nominal);
            titlestr2 = sprintf('CWL = %3.1f, FWHM = %3.1f ',(ftrace{i}.normed.cw),(ftrace{i}.normed.FWHM));
            title([titlestr1, titlestr2]);
            text(ftrace{i}.normed.cw + .5, 0, 'CWL', 'color', 'red')
            print(gcf,'-dpng',[pname, fname, '.filter',num2str(i),'.png'])

            pause(1);
        end
    end
elseif size(raw_file,2)==3
    %nominal =[415, 500, 615, 673, 870, 940];
    % Then this file contains Joe/Gary format files
    for i = 1:6
        sub = find(abs(nominal(i)-raw_file(:,1))<20);
        if length(sub)>10
            raw_filter.nominal = nominal(i);
            raw_filter.nm = raw_file(sub,2);
            raw_filter.T = raw_file(sub,3);
            ftrace{i} = process_mfr_filter(raw_filter);
            figure; plot(ftrace{i}.nm, ftrace{i}.normed.T, 'bx', ftrace{i}.nm, ftrace{i}.normed.T, 'b');v = axis;
            hold('on');plot([ftrace{i}.normed.cw, ftrace{i}.normed.cw], [v(3), v(4)],'r:'); hold('off');
            titlestr1 = sprintf('Nominal wavelength = %3.0f \n',ftrace{i}.nominal);
            titlestr2 = sprintf('CWL = %3.1f, FWHM = %3.1f ',(ftrace{i}.normed.cw),(ftrace{i}.normed.FWHM));
            title([titlestr1, titlestr2]);
            text(ftrace{i}.normed.cw + .5, 0, 'CWL', 'color', 'red')
            print(gcf,'-dpng',[pname, fname, '.filter',num2str(i),'.png'])

            pause(1);
        end
    end
elseif size(raw_file,2)==9
    raw_filter.nm = raw_file(:,2);
    for i = 1:6
        if any(abs(raw_filter.nm-nominal(i))<2)
            raw_filter.nominal = nominal(i);
            raw_filter.T = raw_file(:,3+i);
            ftrace{i} = process_mfr_filter(raw_filter);
            figure; plot(ftrace{i}.nm, ftrace{i}.normed.T, 'bx', ftrace{i}.nm, ftrace{i}.normed.T, 'b');v = axis;
            hold('on');plot([ftrace{i}.normed.cw, ftrace{i}.normed.cw], [v(3), v(4)],'r:'); hold('off');
            titlestr1 = sprintf('Nominal wavelength = %3.0f \n',ftrace{i}.nominal);
            titlestr2 = sprintf('CWL = %3.1f, FWHM = %3.1f ',(ftrace{i}.normed.cw),(ftrace{i}.normed.FWHM));
            title([titlestr1, titlestr2]);
            text(ftrace{i}.normed.cw + .5, 0, 'CWL', 'color', 'red')
            print(gcf,'-dpng',[pname, fname, '.filter',num2str(i),'.png'])

            pause(1);
        end
    end
elseif size(raw_file,2)==10
    raw_filter.nm = raw_file(:,1);
    for i = 1:6
        if any(abs(raw_filter.nm-nominal(i))<2)
            raw_filter.nominal = nominal(i);
            raw_filter.T = raw_file(:,4+i);
            ftrace{i} = process_mfr_filter(raw_filter);
            figure; plot(ftrace{i}.nm, ftrace{i}.normed.T, 'bx', ftrace{i}.nm, ftrace{i}.normed.T, 'b');v = axis;
            hold('on');plot([ftrace{i}.normed.cw, ftrace{i}.normed.cw], [v(3), v(4)],'r:'); hold('off');
            titlestr1 = sprintf('Nominal wavelength = %3.0f \n',ftrace{i}.nominal);
            titlestr2 = sprintf('CWL = %3.1f, FWHM = %3.1f ',(ftrace{i}.normed.cw),(ftrace{i}.normed.FWHM));
            title([titlestr1, titlestr2]);
            text(ftrace{i}.normed.cw + .5, 0, 'CWL', 'color', 'red')
            print(gcf,'-dpng',[pname, fname, '.filter',num2str(i),'.png'])
            pause(1);
        end
    end
end
end