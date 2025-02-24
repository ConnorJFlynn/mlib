function [A,B] = sift_tstruct(A,inA);
%function [A,B] = sift_tstruct(A,inA);
% Separate supplied struct into disjouint logical pieces.
% At this initial point, for expediency assume a struct with same length fields 
   
fields = fieldnames(A);
for f = 1:length(fields)
   fld = fields{f};
   B.(fld) = A.(fld);
   B.(fld)(inA) = [];
   A.(fld) = A.(fld)(inA);
end
end