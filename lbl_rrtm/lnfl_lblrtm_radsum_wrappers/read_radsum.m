function [read_radsum_output] = read_radsum(read_radsum_input)
%function [read_radsum_output] = read_radsum(read_radsum_input)
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
%This function will read in the radsum output files.
%
%read_radsum_input.filename = filename of radsum output file

% 
%Output:
%spectral_heating_rate (K/day/cm^-1)

s_identify = 'read_radsum.m';

s = strcat(read_radsum_input.filename);
press_levs = read_radsum_input.pz_levs;

%Get number of lines in file
s = strcat(['wc -l ',s,' >foo.txt']);
system(s);
fid = fopen('foo.txt','r');
linenumber = fscanf(fid,'%g',1);
fclose(fid);
delete('foo.txt');

%%find number of pressure levels
fid = fopen(read_radsum_input.filename,'r');
for i=1:5
  fgetl(fid);
end
pz_levs = 0;
loop = 1;
while loop
  s = fgetl(fid);
  if length(s)>1
    pz_levs = pz_levs + 1;
  else
    loop = 0;
  end
end
fseek(fid,0,'bof');

%%read in pressure levels
p_levs = zeros(1,pz_levs);
for i=1:5
  fgetl(fid);
end
for i=1:pz_levs
  p_levs(i) = fscanf(fid,'%g',1);
  fgetl(fid);
end
fseek(fid,0,'bof');

%find wavenumber spacing
fgetl(fid);
fscanf(fid,'%s',2);
a = fscanf(fid,'%g',1);
fscanf(fid,'%s',1);
b = fscanf(fid,'%g',1);
fseek(fid,0,'bof');

spectral_heating_rate = zeros(floor(linenumber/(pz_levs+5)),pz_levs);
v1 = a;
dv = b-a;
v2 = v1+dv*floor(linenumber/(pz_levs+5));
wavenumber = [v1:dv:v2-dv];
flux_up = zeros(size(spectral_heating_rate));
flux_down = zeros(size(spectral_heating_rate));
flux_net = zeros(size(spectral_heating_rate));

index = 1;
for i=v1:dv:v2-dv
  %[v1 i v2]
  for j=1:5
    fgetl(fid);
  end
  for j=1:length(p_levs)
    fscanf(fid,'%g',1); %level number
    fscanf(fid,'%s',1); %pressure level
    flux_up(index,j) = fscanf(fid,'%g',1); %flux up (W/m^2)
    flux_down(index,j) = fscanf(fid,'%g',1); %flux up (W/m^2)
    flux_net(index,j) = fscanf(fid,'%g',1); %flux up (W/m^2)
    spectral_heating_rate(index,j) = fscanf(fid,'%g',1);
    fgetl(fid);
  end
  index = index + 1;
end
fclose(fid);

read_radsum_output.spectral_heating_rate = spectral_heating_rate/dv;
read_radsum_output.flux_up               = flux_up;
read_radsum_output.flux_down             = flux_down;
read_radsum_output.flux_net              = flux_net;
read_radsum_output.wavenumber            = wavenumber;
read_radsum_output.pz_levs               = p_levs;

return
