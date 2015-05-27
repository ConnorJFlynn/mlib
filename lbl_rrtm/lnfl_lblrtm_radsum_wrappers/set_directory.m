function [Directory_Mat_output] = ...
    set_directory(Directory_Mat_input,Directory_List,dir_name,new_dir);
%function [Directory_Mat_output] = ... 
%    set_directory(Directory_Mat_input,Directory_List,dir_name,new_dir);
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
%This function will change the entry for a directory in
%Directory_Mat from dir_name to dir_name2
%
%%%%%%%%%%%%%%%%%%%%%
%%Input variable(s)%%
%%%%%%%%%%%%%%%%%%%%%
%Directory_Mat_input = matrix of directory of strings padded w/blanks
%Directory_List      = matrix of strings describing directory
%dir_name            = original name of directory in Directory_List
%new_dir           = renamed actual directory for Directory_Mat
%
%%%%%%%%%%%%%%%%%%%%%%
%%Output variable(s)%%
%%%%%%%%%%%%%%%%%%%%%%
%Directory_Mat_output = modified directory of strings padded w/blanks

s_identify = 'set_directory.m';

%Find line_entry
line_entry = 0;
for i=1:length(Directory_List(:,1))
  s = Directory_List(i,:);
  loop = 1;
  while loop
    trip = 0;
    for j=1:length(s)
      if strcmpi(s(j),' ')
	trip = 1;
	s(j) = [];
	break
      end
    end
    if trip == 0
      loop = 0;
    end
  end
  if strcmpi(s,dir_name)==1
    line_entry = i;
  end
end
if line_entry == 0
  line_entry = length(Directory_List(:,1)) + 1;
end

Directory_Mat_output = Directory_Mat_input;

a = length(Directory_Mat_input(1,:));
new_dir_padded = new_dir;
if length(new_dir_padded) <  a
  loop = 1;
  while loop
    new_dir_padded(length(new_dir_padded)+1) = ' ';
    if length(new_dir_padded) == a
      loop = 0;
    end
  end
elseif length(new_dir_padded) > a
  b = length(new_dir_padded) - length(Directory_Mat_input(1,:));
  for i=1:b
    for j=1:length(Directory_Mat_input(:,1))
      Directory_Mat_input(j,a+i) = ' ';
    end
  end  
end

Directory_Mat_output = Directory_Mat_input;

for i=1:length(Directory_Mat_input(:,1))
  if i~=line_entry
    Directory_Mat_output(i,:) = Directory_Mat_input(i,:);
  else
    Directory_Mat_output(i,:) = new_dir_padded;
  end
end

return

