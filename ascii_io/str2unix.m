function txt = str2unix(txt,force)
%status = str2unix(txt,force)
if ~exist('force', 'var')
   force = false;
end
% Windows: \r\n
% UNIX: \n x0A 10
% Mac: \r x0D 13

% Replace all \r\n with \n  [13 10] with [10]
% replace all \r with \n [13] with [10]

% for txt2dos, first call txt2unix then replace [10] with [13 10]
% for txt2mac, first call txt2unix then replace [10] with [13]
   if ~any(txt>127)|force
      txt = char(txt');
      txt = regexprep(txt, char([13 10]),char(10));
      txt = regexprep(txt, char([13]),char(10));
      %Either force is true or no high ascii codes found
   else %Probably a binary file.
      txt = [];
   end
