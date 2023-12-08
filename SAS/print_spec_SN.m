ins = getfullname('*sas*','sas');

for f = 1:length(ins)
   infile = anc_load(ins{f});
   [~,fname,~] = fileparts(ins{f});
   if isfield(infile.gatts,'serial_number_spectrometer_nir')
      disp( {fname, infile.gatts.serial_number_spectrometer_nir })
   elseif isfield(infile.gatts,'serial_number_spectrometer')
      disp( {fname, infile.gatts.serial_number_spectrometer })
   else
      disp( {fname , infile.gatts.serial_number   })
   end
end