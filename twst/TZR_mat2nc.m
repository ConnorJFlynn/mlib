function TZR_mat2nc

infile = getfullname('TZR.*.mat','TASZERS','Select a TZR mat file');

if ~iscell(infile)
   infile = {infile};
end
for in = 1:length(infile)
   [pname, fname] = fileparts(infile{in});
   mat = load(infile{in});

   inst = 'Ze1';
   write_TZR_nc(pname, inst, mat.Lat, mat.Lon, mat.time, mat.sza, mat.wl.vis1, mat.wl.nir1, mat.rad1_vis, mat.rad1_nir);

   inst = 'Ze2';
   write_TZR_nc(pname, inst, mat.Lat, mat.Lon, mat.time, mat.sza, mat.wl.vis2, mat.wl.nir2, mat.rad2_vis, mat.rad2_nir);

   inst = 'TWST10';
   write_TZR_nc(pname, inst, mat.Lat, mat.Lon, mat.time, mat.sza, mat.wl.A10, mat.wl.B10, mat.rad10_A, mat.rad10_B);

   inst = 'TWST11';
   write_TZR_nc(pname, inst, mat.Lat, mat.Lon, mat.time, mat.sza, mat.wl.A11, mat.wl.B11, mat.rad11_A, mat.rad11_B);
end

return

TASZERS was supported by DOE Grant  A25-0097. 
TWST development was supported under DOE SBIR Grant DE-SC0020473.
