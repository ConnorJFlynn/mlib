function dummy = truncate_header(truncate_header_input)
%function dummy = truncate_header(truncate_header_input)
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
%This function will truncate the header of the input file
%
%%%%%%%%%%%%%%%%%%%%%
%%Input variable(s)%%
%%%%%%%%%%%%%%%%%%%%%
%truncate_header_input structure variables:
%.input_file  = string of input file
%.output_file = string of output file
%.header_size = length of header (in lines)
%
%%%%%%%%%%%%%%%%%%%%%%
%%Output variable(s)%%
%%%%%%%%%%%%%%%%%%%%%%
%dummy = generic output variable

s_identify = 'truncate_header.m';

%Assign real variables from input structure
input_file  = truncate_header_input.input_file;
output_file = truncate_header_input.output_file;
header_size = truncate_header_input.header_size;

%get total number of lines
s = strcat(['wc -l ',input_file,' >blah']);
system(s);
fid2 = fopen('blah','r');
linenumber = fscanf(fid2,'%g',1);
fclose(fid2);
system('rm blah');

%split input_file and remove header file
s_init = 'B';
s_base = s_init;
file_start = input_file;
current_line = linenumber/26;

%loop to split up file 
trip = 0;
loop = 1;
num_deep = 0;
while loop
  if current_line >header_size
    s1 = strcat(['split -a1 -l',int2str(ceil(current_line)),...
		 ' ',file_start,' ',s_base]);
    system(s1);
    file_start = strcat(s_base,'a');
    s_base = strcat(s_base,'a');
    current_line = current_line/26;
  elseif current_line<header_size & trip == 0
    %current_line=26;
    current_line = header_size;
    s1 = strcat(['split -a1 -l',int2str(current_line),...
		 ' ',file_start,' ',s_base]);
    system(s1);
    file_start = strcat(s_base,'a');
    s_base = strcat(s_base,'a');
    trip = 1;
  else
    loop = 0;
  end
  num_deep = num_deep + 1;
end
num_deep = num_deep - 1;

%erase files and subfiles that include header
s_base2 = s_base;
loop = 1;
while loop
  system(['rm ',s_base2]);
  s_base2(length(s_base2)) = [];
  if strcmp(s_base2,s_init)
    loop = 0;
  end
end

s = str2mat('a','b','c','d','e','f','g','h','i','j','k','l',...
	    'm','n','o','p','q','r','s','t','u','v','w','x','y','z');

s1 = s_init;
for i=1:num_deep
  s1 = strcat(s1,'a');
end
s1(length(s1)) = 'b';

%concatenate all remaining files
%system(['cat ',s1,' >blah']);
for i=1:num_deep
  if i==1
    s1 = 'cat ';
  else
    s1 = 'cat blah ';
  end
  add_on = [];
  for j=1:num_deep-i
    add_on = strcat(add_on,'a');
  end
  for j=2:length(s)
    s1 = strcat([s1,s_init,add_on,s(j)]);
    s1(length(s1)+1) = ' ';
  end
  s1 = strcat([s1,' >blah2']);
  system(s1);
  system('mv blah2 blah');
end
system(['mv blah ',output_file]);

system(['rm ',s_init,'*']);

dummy = 0;
return
