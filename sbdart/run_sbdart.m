function w = run_sbdart(input);
%w = run_sbdart(input);
w = [];

input = set_input;

sbdart_path = ['c:\cygwin\usr\local\sbdart\test2\'];
fid = fopen([sbdart_path, 'INPUT'],'wt');

y = (['&INPUT']);
fprintf(fid,'%s \n',y);

fields = fieldnames(input);
for i = 1:length(fields)
   %this = [char(fields(i)), ' = ', sprintf('%6.6f ', input.(char(fields(i))))];
   this = [char(fields(i)), ' = ', input.(char(fields(i)))];
   that = sprintf('%s \n', this);
%    disp(that)
   fprintf(fid,'%s \n', this);
end
y = (['/']);
fprintf(fid,'%s \n',y);
fclose(fid);

pname = pwd;
cd(sbdart_path)
[s,w] = system(['C:\cygwin\bin\bash -c sbdart']);
cd(pname);
IOUT = sscanf(input.IOUT,'%d');
if IOUT == 6
   [phi, uzen, sa, full_sa,pp] = plot_iout6(w,input)
end
if (IOUT == 20)|(IOUT == 21)|(IOUT == 23)
   [phi, uzen, sa, full_sa,pp] = plot_iout20(w,input)
end
%%
function input = set_input(input);
%Setting them all as strings 
input.IDATM = '2';
input.WLINF = '0.453';
input.WLSUP = '0.453';
input.NF = '0';
input.NSTR = '20';
% input.isalb = '0';
% input.albcon = '0';
input.SZA = '40';
input.SAZA = '180';
input.IDAY = '0';
% input.IAER = '0';
input.iaer = '2';
input.wlbaer= '0.453';
input.tbaer= '0.1';
input.wbaer= '0.9';
input.gbaer= '0.8';
input.phi = '0,180';
input.vzen=  '90,89,85,80,70,60,50,45,40,20,10,5,1,0';
input.CORINT = 'FALSE';
input.IOUT = '6';
