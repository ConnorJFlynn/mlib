function nimfr = get_nimfr(nimfr_pname);   
% nimfr = get_nimfr(nimfr_pname);
% Returns a structure containing all nimfr or mfrsr optical depths for all
% valid files found within nimfr_pname. 
list = dir([nimfr_pname, 'nimfr.aot.*']);

nimfr.raw = [];
for nimfr_file = 1:length(list)
   nimfr_in = load([nimfr_pname, list(nimfr_file).name], '-ascii');
   nimfr.raw = [nimfr.raw; nimfr_in];
   %disp(['loaded ', dirlist(nimfr_file).name]);
end

nimfr.time = datenum('00-Jan-2003') + nimfr.raw(:,2);
nimfr.aod415 = nimfr.raw(:,4);
nimfr.aod500 = nimfr.raw(:,5);
nimfr.aod615 = nimfr.raw(:,6);
nimfr.aod673 = nimfr.raw(:,7);
nimfr.aod870 = nimfr.raw(:,8);
%angstrom = -delta(ln tau)/delta(ln wavelength)
nimfr.angstrom = nimfr.raw(:,9);
nimfr.aod523 = nimfr.aod500.*((500/523).^nimfr.angstrom);
nimfr.airmass = 1./nimfr.raw(:,3);
nimfr = rmfield(nimfr, 'raw');
return