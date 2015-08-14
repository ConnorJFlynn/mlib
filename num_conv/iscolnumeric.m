function pass = iscolnumeric(this_col)
% this function tests a cell array of strings to see if they are all valid
% string representations of numeric value
pass = true;
n = length(this_col);
while n > 0 && pass
   el = this_col{n};
   if ~isempty(el)
   A = str2num(el);
   B = sscanf(el,'%f');
   if numel(A)~=1 || numel(B)~=1 || A~=B
      pass = false;
   end
   end
   n = n -1;
end
   
return