function skyrad = pnlsky(filename);
% skyrad = pnlsky(filename);
% Time in skyrad files is not always consistent. Sometimes need to correct
% to get UTC from local by adding either 7 or 8 hours depending on
% daylight savings.
if ~exist('filename', 'var')
   [fname, pname] = uigetfile('*.sky');
   filename = [pname, fname];
end
while ~exist(filename, 'file')
   [pname, fname, ext] = fileparts(filename);
   if exist(pname, 'dir')
      [fname, pname] = uigetfile([pname,'\*.sky']);
   else
      [fname, pname] = uigetfile('*.sky');
   end
   filename = [pname, fname];
end
pnl_sky = load(filename, '-ascii');
skyrad.time = datenum(pnl_sky(:,2),01,01,floor(pnl_sky(:,4)/100),mod(pnl_sky(:,4),100),0) + pnl_sky(:,3)-1 ;
skyrad.dirn = pnl_sky(:,12);
skyrad.dif = pnl_sky(:,14);
missed = find(skyrad.dif<0|skyrad.dirn<0);
skyrad.dirn(missed) = NaN;
skyrad.dif(missed) = NaN;
figure; plot(serial2doy0(skyrad.time), skyrad.dirn, '.')
title(['PNNL skyrad NIP for ',datestr(floor(mean(skyrad.time)))])
xlabel('time (day of year, Jan. 1 = 0)')
ylabel('direct normal irradiance (W/m_2)')