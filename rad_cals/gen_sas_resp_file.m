function [resp_stem, resp_dir] = gen_sas_resp_file(header, col_hedr, fmt,dat , time, tint, fstem, resp_dir)
% [resp_stem, resp_dir] = gen_sas_resp_file(header, col_hedr, fmt,dat , time, tint, fstem, resp_dir)
% Modified for consistency with existing SASZe resp files, except for addition of the word "cal" after fstem
% CJF: 2022-05-26, somehow lost track of sas format resp file and produced
% a  mishmash of sws name and sasze content.  Trying to recover a
% consistent format for both now.
%%
if iscell(col_hedr); col_hedr = col_hedr{:}; end
if any(dat(1,:)>500&dat(1,:)<600)
    det_str = '.si.';
else
    det_str = '.ir.';
end
%%
i = 0;done = false;
while ~done
    i = i+1;
    SAS_unit_i = strfind(upper(header{i}),upper('SAS_unit:'));
    if ~isempty(SAS_unit_i)||(i==length(header))
        done =true;
    end
end
SAS_unit_i = findstr(upper(header{i}),upper('SAS_unit:'));
SAS_unit = lower(header{i}(SAS_unit_i+9:end));
db = '';
resp_stem = [fstem,'.cal.',datestr(time,'yyyymmdd_0000.'),num2str(tint),'ms',db,'.dat'];
if strcmp(resp_stem(1),'.')
    SAS_unit = 'sws';
    resp_stem = ['sws',resp_stem];
end
n =1;
while isafile([resp_dir,resp_stem])
    n = n+1;
    db = ['_',num2str(n)];
    resp_stem = [fstem,'.cal.',datestr(time,'yyyymmdd_0000.'),num2str(tint),'ms',db,'.dat'];
end

fid = fopen([resp_dir,resp_stem],'w');
for s = 1:length(header)
    fprintf(fid,'%s \n', header{s});
%     sprintf('%s \n', header{s});
end
fprintf(fid,'%%s \n', col_hedr);
% out_dat = [1:length(dat(1,:)); dat];

fprintf(fid, fmt,dat);
% sprintf('%d      %6.1f      %5.3f    %5.3f   %5.3f    %5.3f    %5.3f    %5.3f \n',[1],in_cal(1,1), in_cal(2:end,1));
fclose(fid);

%%
% figure(19)
% sb(1) = subplot(2,1,1);
% plot(nir_cal.lambda, nir_cal.(['rate_',num2str(nir_cal.t_int_ms(vt)),'_ms']), 'b-');
% title(['NIR spectrometer: ',lamp,' Lamps, t_int_ms=',num2str(nir_cal.t_int_ms(vt))],'interp','none');
% legend('rate')
% sb(2) = subplot(2,1,2);
% plot(nir_cal.lambda, nir_cal.(['resp_',num2str(nir_cal.t_int_ms(vt)),'_ms']), 'r-');
% legend('resp');
% linkaxes(sb,'x');axis(sb(1),v1);axis(sb(2),v2);

%         save([resp_dir, strrep(resp_stem,'.dat','.mat')],'-struct','vis_cal');
%         saveas(gcf,[resp_dir,strrep(resp_stem,'.dat','.fig')]);
%%

return