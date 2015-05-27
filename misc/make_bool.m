function out = make_bool(in); 
% Recursively casts contents of in into a logical class
% out = make_bool(in);
fields = fieldnames(in);
for f = 1:length(fieldnames(in))
   if isnumeric(in.(fields{f}))||islogical(in.(fields{f}))
      % Set to true of not zero
%             in.(fields{f}) = logical(size(in.(fields{f})));
            in.(fields{f}) = ~(in.(fields{f})==0);
   else
            in.(fields{f}) = make_bool(in.(fields{f}));
   end
end