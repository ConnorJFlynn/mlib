function [read_rrtm_output] = read_rrtm_sw(read_rrtm_input)
%function [read_rrtm_output] = read_rrtm(read_rrtm_input)
%
%(C) Dan Feldman 2009, all rights retained
%    Disclaimer of Warranty. DANIEL FELDMAN PROVIDES THE SOFTWARE AND THE SERVICES "AS IS" WITHOUT WARRANTY 
%    OF ANY KIND EITHER EXPRESS, IMPLIED OR STATUTORY, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
%    OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. ALL RISK OF QUALITY AND PERFORMANCE OF THE 
%    SOFTWARE OR SERVICES REMAINS WITH YOU. THIS DISCLAIMER OF WARRANTY CONSTITUTES AN ESSENTIAL PART OF THIS AGREEMENT.
%
%    Limitation of Remedies. IN NO EVENT WILL DANIEL FELDMAN, DISTRIBUTORS, DIRECTORS OR AGENTS BE LIABLE 
%    FOR ANY INDIRECT DAMAGES OR OTHER RELIEF ARISING OUT OF YOUR USE OR INABILITY TO USE THE SOFTWARE OR 
%    SERVICES INCLUDING, BY WAY OF ILLUSTRATION AND NOT LIMITATION, LOST PROFITS, LOST BUSINESS OR LOST  
%    OPPORTUNITY, OR ANY INDIRECT, SPECIAL, INCIDENTAL OR CONSEQUENTIAL OR EXEMPLARY DAMAGES,  
%    INCLUDING LEGAL FEES, ARISING OUT OF SUCH USE OR INABILITY TO USE THE PROGRAM, EVEN IF DANIEL FELDMAN 
%    OR AN AUTHORIZED LICENSOR DEALER, DISTRIBUTOR OR SUPPLIER HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES, 
%    OR FOR ANY CLAIM BY ANY OTHER PARTY. BECAUSE SOME STATES OR JURISDICTIONS DO NOT ALLOW THE EXCLUSION OR THE  
%    LIMITATION OF LIABILITY FOR CONSEQUENTIAL OR INCIDENTAL DAMAGES, IN SUCH STATES OR JURISDICTIONS, 
%    DANIEL FELDMAN'S LIABILITY SHALL BE LIMITED TO THE EXTENT PERMITTED BY LAW.
%
%    Daniel Feldman's Liability. Daniel Feldman assumes no liability hereunder for, 
%    and shall have no obligation to defend you or to pay costs, damages or attorney's fees for, 
%    any claim based upon: (i) any method or process in which the Software or Services may be used by you; 
%    (ii) any results of using the Software or Services; 
%    (iii) any use of other than a current unaltered release of the Software; or 
%    (iv) the combination, operation or use of any of the Software or Services furnished hereunder 
%    with other programs or data if such infringement would have been avoided by the combination, 
%    operation, or use of the Software or Services with other programs or data. 
%
%    If you do not agree to these terms, discontinue use of this software immediately.
%    Daniel Feldman is not affiliated with AER, Inc.
%
%This function will read in the rrtm output files.
%
%read_rrtm_input.filename = filename of rrtm output file

% 
%Output:
%spectral_heating_rate (K/day/cm^-1)

s_identify = 'read_rrtm_sw.m';
s = read_rrtm_input.filename;

%Read in 15 bands:
channels = [820 50000;
	    2600 3250;
	    3250 4000;
	    4000 4650;
	    4650 5150;
	    5150 6150;
	    6150 7700;
	    7700 8050;
	    8050 12850;
	    12850 16000;
	    16000 22650;
	    22650 29000;
	    29000 38000;
	    38000 50000;
	    820   2600];

fid = fopen(s,'r');
if read_rrtm_input.channel == 0
  for i=1:3
    fgetl(fid);
  end
  a = zeros(length(read_rrtm_input.full_atm(:,1)),6);
  for i=1:length(a(:,1))
    a(i,:) = fscanf(fid,'%g',6);
    fgetl(fid);
  end 
  fclose(fid); 
  spectral_heating_rate = a(:,6);
  flux_up = a(:,3);
  flux_down = a(:,4);
  net_flux = a(:,5);
else
  num_levs = length(read_rrtm_input.full_atm(:,1));
  spectral_heating_rate = zeros(15,num_levs);
  flux_up = zeros(size(spectral_heating_rate));
  flux_down = zeros(size(spectral_heating_rate));
  net_flux = zeros(size(spectral_heating_rate));

  index = 1;
  for i=1:15
    for j=1:5
      fgetl(fid);
    end
    for j=1:num_levs
      fscanf(fid,'%g',2); %LEVEL,PRESSURE
      flux_up(i,j) = fscanf(fid,'%g',1);
      flux_down(i,j) = fscanf(fid,'%g',1);
      net_flux(i,j) = fscanf(fid,'%g',1);
      fscanf(fid,'%g',2);
      spectral_heating_rate(i,j) = fscanf(fid,'%g',1);
      fgetl(fid);
    end
    fgetl(fid);
  end
  fclose(fid);
end

read_rrtm_output.spectral_heating_rate = spectral_heating_rate;
read_rrtm_output.flux_up               = flux_up;
read_rrtm_output.flux_down             = flux_down;
read_rrtm_output.net_flux              = net_flux;
read_rrtm_output.channels              = channels;
read_rrtm_output.press_levs            = flipud(read_rrtm_input.full_atm(:,2));

return
