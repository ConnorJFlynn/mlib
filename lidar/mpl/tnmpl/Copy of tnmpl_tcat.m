function mpl = tnmpl_tcat(mpl, mpl2);
% mpl = tnmpl_tcat(mpl);
% This function concatenates two mpl structures along time.
[mpl.time, ind] = sort([mpl.time, mpl2.time]);
mpl.prof = [mpl.prof,mpl2.prof];
mpl.prof = mpl.prof(:,ind);
mpl.noise_MHz = [mpl.noise_MHz,mpl2.noise_MHz];
mpl.noise_MHz = mpl.noise_MHz(:,ind);
hk_fields = fieldnames(mpl.hk);
for hk = 1:length(hk_fields)
   mpl.hk.(char(hk_fields(hk)))= [mpl.hk.(char(hk_fields(hk))),mpl2.hk.(char(hk_fields(hk)))];
   mpl.hk.(char(hk_fields(hk)))= eval(['mpl.hk.',char(hk_fields(hk)),'(ind)']);
end