function [resp_stem, resp_dir] = gen_sasze_resp_file(in_cal,header, time, tint, resp_dir)
% gen_sasze_resp_file(in_cal,header,vis_cal.time, vis_cal.t_int_ms(vt),vis.pname);
%%

if any(in_cal(1,:)>500&in_cal(1,:)<600)
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
resp_stem = [SAS_unit,'.resp_func.',datestr(time,'yyyymmdd0000'),det_str,num2str(tint),'ms',db,'.dat'];
if strcmp(resp_stem(1),'.')
    SAS_unit = 'sws';
    resp_stem = ['sws',resp_stem];
end
n =1;
while exist([resp_dir,resp_stem],'file')
    n = n+1;
    db = ['_',num2str(n)];
    resp_stem = [SAS_unit,'.resp_func.',datestr(time,'yyyymmdd0000'),det_str,num2str(tint),'ms',db,'.dat'];
end

fid = fopen([resp_dir,resp_stem],'w');
for s = 1:length(header)
    fprintf(fid,'%s \n', header{s});
%     sprintf('%s \n', header{s});
end

out_cal = [1:length(in_cal(1,:)); in_cal];

fprintf(fid, '%4d %8.1f %9.4g %8.3f %10.3f %10.3f %10.3f %9.3f \n',out_cal);
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