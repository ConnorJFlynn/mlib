function mpl = tnmpl_tcut(mpl, ind);
% mpl = tnmpl_tcut(mpl,ind);
% Returns the only the specified indice(s) from an mpl struct
if any(ind)
   mpl.time = (mpl.time(ind));
   mpl.prof = (mpl.prof(:,ind));
   mpl.noise_MHz = (mpl.noise_MHz(:,ind));
   hk_fields = fieldnames(mpl.hk);
   for hk = 1:length(hk_fields)
      mpl.hk.(char(hk_fields(hk)))= eval(['(mpl.hk.',char(hk_fields(hk)),'(ind))']);
   end
else
   mpl = [];
end
