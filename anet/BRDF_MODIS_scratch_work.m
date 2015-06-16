for lin = 1:length(line_num)
    disp(sprintf(line_num{lin}));
end
%%
% MODIS, BRDF, HDF...
BRDF_file = getfullname('*.hdf','modis');
BRDF_info = hdfinfo(BRDF_file);
% Data field names:
BRDF_info.Vgroup.Vgroup(1).SDS(1).Name
% Import data with hdfread:
%%
BRDF_Albedo_Parameters_Band1 = hdfread(BRDF_file,'/MOD_Grid_BRDF/Data Fields/BRDF_Albedo_Parameters_Band1', 'Index', {[1  1  1],[1  1  1],[2400   2400     3]});
filled = BRDF_Albedo_Parameters_Band1==32767;
BRDF_Albedo_Parameters_Band1 = double(BRDF_Albedo_Parameters_Band1)./1000;
BRDF_Albedo_Parameters_Band1(filled) = NaN;

figure; plot(BRDF_Albedo_Parameters_Band1(1,:,1),'o')
%%
figure; imagesc(BRDF_Albedo_Parameters_Band1);colorbar
%%
% Example values for Bandn = 
bands = [1 645.5     .035     .043      .005
 2 856.5     .255    .175     .020
 3 465.6     .023     .065      .003
 4 553.6     .050     .065      .006
 5 1241.6     .271    .193     .035
 6 1629.1     .191    .121     .042
 7 2114.1     .080     .054     .017]

% After getting the band wavelengths from Wikipedia/NASA, and multiplying
% by 1e-3, these values look like the quantities desired by AERONET
% But how to represent the X and Y in lat and lon?
  UpperLeftPointMtrs=(-6671703.118000,5559752.598333)
       LowerRightMtrs=(-5559752.598333,4447802.078667)

Wikipedia modis bands:

1	620-670	 	645.5	250m	Land/Cloud/Aerosols Boundaries
2	841-876	 	856.5	250m
3	459-479	 	465.6	500m	Land/Cloud/Aerosols Properties
4	545-565	 	553.6	500m
5	1230-1250	 	1241.6	500m
6	1628-1652	 	1629.1	500m
7	2105-2155	 	2114.1	500m