function mfr7_heads
% mfr7_heads written to identify changes in head ID or filter7 trace
files = getfullname('*mfrsr7nch*.*','mfr7');
   mfr7 = anc_loadcoords(files{1});
   old.head_id(1) = sscanf(mfr7.gatts.head_id,'%f');
   old.time(1) = mfr7.time(1);
   xfilt = mfr7.vdata.normalized_transmittance_filter7;
for m = 2: length(files)
   mfr7 = anc_loadcoords(files{m});
   if ~all(xfilt==mfr7.vdata.normalized_transmittance_filter7)||old.head_id(end)~=sscanf(mfr7.gatts.head_id,'%f')
      figure_(99); pos = mfr7.vdata.wavelength_filter7>0;
      plot(mfr7.vdata.wavelength_filter7(pos),xfilt(pos),'-',mfr7.vdata.wavelength_filter7(pos), mfr7.vdata.normalized_transmittance_filter7(pos), '-'); logy;
      title(datestr(mfr7.time(1),'yyyy-mm-dd HH:MM'));
      legend(dec2hex(old.head_id(end)), dec2hex(sscanf(mfr7.gatts.head_id,'%f')))

       old.time(end+1) = mfr7.time(1); 
       old.head_id(end+1) = sscanf(mfr7.gatts.head_id,'%f');
       xfilt = mfr7.vdata.normalized_transmittance_filter7;
   end

end
dec2hex(unique(old.head_id))

return