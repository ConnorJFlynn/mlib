function y_out = extrap1(x_in,y_in,x_out,method)
%function y_out = extrap1(x_in,y_in,x_out,method)
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
%This function is analogous to interp1.m but tests for NaN's
%associated with interp1.m
%
%%%%%%%%%%%%%%%%%%%%%
%%Input variable(s)%%
%%%%%%%%%%%%%%%%%%%%%
%x_in   = independent variable for input vector
%y_in   = dependent variable for input vector
%x_out  = independent variable for output vector
%method = interp1 methos
%        'nearest'  - nearest neighbor interpolation
%        'linear'   - linear interpolation
%        'spline'   - piecewise cubic spline interpolation (SPLINE)
%        'pchip'    - piecewise cubic Hermite interpolation (PCHIP)
%        'cubic'    - same as 'pchip'
%        'v5cubic'  - the cubic interpolation from MATLAB 5, which does not
%                   extrapolate and uses 'spline' if X is not equally spaced.
%
%%%%%%%%%%%%%%%%%%%%%%
%%Output variable(s)%%
%%%%%%%%%%%%%%%%%%%%%%
%y_out  = dependent variable for output vector

s_identify = 'extrap1.m';

y_out = interp1(x_in,y_in,x_out,method);

for i=1:length(y_out)
  if isnan(y_out(i)) | isinf(y_out(i))
    if strcmp(method,'nearest') | strcmp(method,'linear')
      %get nearest y_in(j)
      a = [1:length(y_in)];
      a_prime = zeros(size(a));
      index = 1;
      for j=1:length(a)
	if ~isnan(y_in(j))
	  a_prime(index) = a(j);
	  index = index + 1;
	end
      end
      a_prime = a_prime(1:index-1);
      %y_out(i) = y_out(a_prime(find(min(abs(x_out(a_prime)-x_out(i))))));
      diff = 1e9;
      for j=1:length(a_prime)
	diff_comp = abs(x_in(a_prime(j))-x_out(i));
	if diff_comp<diff
	  diff = diff_comp;
	  index = a_prime(j);
	end
      end
      y_out(i) = y_in(index);
    elseif strcmp(method,'pchip')
      y_prime = interp1(x_in,y_in,x_out,'cubic');
      y_out(i) = y_prime(i);
    end
  end
end
