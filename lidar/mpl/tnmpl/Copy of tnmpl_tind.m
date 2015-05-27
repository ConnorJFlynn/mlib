function mpl = tnmpl_tind(mpl, ind);
% mpl = tnmpl_tind(mpl,ind);
% Returns only the specified indice(s) from an mpl struct
mpl.time = mpl.time(ind);
mpl.prof = mpl.prof(:,ind);
mpl.noise_MHz = mpl.noise_MHz(:,ind);
hk_fields = fieldnames(mpl.hk);
for hk = 1:length(hk_fields)
   mpl.hk.(char(hk_fields(hk)))= mpl.hk.(char(hk_fields(hk)))(ind)];
end