function [BT_output,chan_prime] = ...
    convert_to_BT(rad_input,chan)
%function [BT_output,chan_prime] = ...
%    convert_to_BT(rad_input,chan)
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
%This function will convert radiance input into
%brightness temperature output for AIRS channels only
%
%%%%%%%%%%%%%%%%%%%%%
%%Input variable(s)%%
%%%%%%%%%%%%%%%%%%%%%
%rad_input = vector of input radiances (mW/m^2/sr/cm^-1 or W/cm^2/sr/cm^-1)
%chan      = vector of wavenumbers (cm^-1)
%
%%%%%%%%%%%%%%%%%%%%%%
%%Output variable(s)%%
%%%%%%%%%%%%%%%%%%%%%%
%BT_output  = vector of output brightness temperature (K)
%chan_prime = vector of channel values (cm^-1)

alpha1 = 1.1910427e-05;
alpha2 = 1.4387752;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Convert rad_input to mW/m^2/sr/cm^-1%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if max(rad_input)<1e-3
  rad_input = rad_input*1e7;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Parse only for positive radiance data%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
neg_count = 0;
for i=1:length(rad_input)
  if rad_input(i)<=0
    neg_count = neg_count + 1;
  end
end
rad_input_prime = zeros(1,length(rad_input)-neg_count);
for i=1:length(rad_input)
  if rad_input(i) > 0
    rad_input_prime(i) = rad_input(i);
    chan_prime(i) = chan(i);
  else
    rad_input_prime(i) = NaN;
    chan_prime(i) = chan(i);
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Convert to brightness temperature%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
BT_output = zeros(size(chan_prime));
BT_output = alpha2*chan_prime./ ...
    log(1+(alpha1*chan_prime.^3./rad_input_prime));
for i=1:length(BT_output)
  if imag(BT_output(i))~=0
    BT_output(i) = 0 ;
  end
end
