function lang_out_txt(lang_common, txt_fname);
% Generates interpolated Io values between smoothed filtered IQF results
% and outputs these results to an ASCII file.
%%
noNaNii =find(~isNaN(lang_common.time));
fiq.time = [floor(lang_common.time(noNaNii(1))):floor(lang_common.time(noNaNii(end)))];
for f = 5:-1:1
   fiq.(['filter',num2str(f)]) = interp1(lang_common.IQF.time, lang_common.IQF.(['filter',num2str(f)]),fiq.time,'pchip', 'extrap');
end
%%
% figure;plot(serial2doy(fiq.time), [fiq.filter1;fiq.filter2;fiq.filter3;fiq.filter4;fiq.filter5],'.');
% legend('415','500','615','670','870')
%%

jt = serial2joe(fiq.time);
yyyymmdd = datestr(fiq.time, 'yyyymmdd');

%%
for t = 1:length(jt)
   these(t) = sscanf(yyyymmdd(t,:),'%d')';
end
bloc = [floor(jt);fiq.filter1;fiq.filter2;fiq.filter3;fiq.filter4;fiq.filter5;these];

%%


% bloc = [floor(jt(t));fiq.filter1(t);fiq.filter2(t);fiq.filter3(t);fiq.filter4(t);fiq.filter5(t);these];
%    sprintf('%d %3.3f %3.3f %3.3f %3.3f %3.3f ', bloc)
%    sprintf('%s \n', yyyymmdd(t,:))
fid = fopen(txt_fname, 'w');
fprintf(fid,'%d %3.3f %3.3f %3.3f %3.3f %3.3f %8.0f \n', bloc);
%    fprintf(fid,'%s \n', yyyymmdd(t,:));
%
% end
fclose(fid);

return
