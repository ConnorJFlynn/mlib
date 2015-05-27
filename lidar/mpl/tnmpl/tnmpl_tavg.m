function mpl = tnmpl_tavg(mpl, ind);
% mpl = tnmpl_tavg(mpl,ind);
% Returns the mean of the specified indice(s) from an mpl struct
if length(ind)>1
   mpl.time = mean(mpl.time(ind));
   mpl.prof = mean(mpl.prof(:,ind)')';
   mpl.noise_MHz = mean(mpl.noise_MHz(:,ind)')';
   hk_fields = fieldnames(mpl.hk);
   for hk = 1:length(hk_fields)
      mpl.hk.(char(hk_fields(hk)))= eval(['mean(mpl.hk.',char(hk_fields(hk)),'(ind))']);
   end
else
   mpl.time = mpl.time(ind);
   mpl.prof = mpl.prof(:,ind);
   mpl.noise_MHz = mpl.noise_MHz(:,ind);
   hk_fields = fieldnames(mpl.hk);
   for hk = 1:length(hk_fields)
      mpl.hk.(char(hk_fields(hk)))= eval(['mpl.hk.',char(hk_fields(hk)),'(ind)']);
   end
end
