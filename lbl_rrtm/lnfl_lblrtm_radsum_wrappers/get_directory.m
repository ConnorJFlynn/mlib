function s_out = get_directory(string_mat,string_list,dir_name)
%function s_out = get_directory(string_mat,string_list,dir_name)
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
%This function will compress a string row of a string matrix to
%remove any extra blank spaces added by str2mat.  For single string
%compression, simply use a regular string as the string_mat
%argument and "1" as the second argument.
%
%%%%%%%%%%%%%%%%%%%%%
%%Input variable(s)%%
%%%%%%%%%%%%%%%%%%%%%
%string_mat  = matrix of directory strings padded with zeros so as to make it
%              non-sparse. Rows represent different directory strings.
%string_list = matrix of strings describing directory
%dir_name    = name of directory
%
%%%%%%%%%%%%%%%%%%%%
%%Output arguments%%
%%%%%%%%%%%%%%%%%%%%
%s_out:      string w/out spaces

s_identify = 'get_directory.m';

%Find line_entry
line_entry = 0;
for i=1:length(string_list(:,1))
  s = deblank(string_list(i,:));
  if strcmpi(s,dir_name)==1
    line_entry = i;
  end
end

s_out = deblank(string_mat(line_entry,:));

return
