function in = make_true(in);
% out = make_true(in);
if isnumeric(in)||islogical(in)
   in = true(size(in));
elseif isstruct(in)
   % Recursively casts contents of in into a logical class
   fields = fieldnames(in);
   for f = 1:length(fieldnames(in))
      in.(fields{f}) = make_true(in.(fields{f}));
   end
end