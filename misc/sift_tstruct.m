function [A,B] = sift_tstruct(A,inA);
%function [A,B] = sift_tstruct(A,inA);
% Separate supplied struct into disjouint logical pieces.
% At this initial point, for expediency assume a struct with same length fields

fields = fieldnames(A);
for f = 1:length(fields)
   fld = fields{f};
   this = A.(fld);
   if ~any(size(this)==length(inA))
      B.(fld) = this;
      A.(fld) = this;
   else
      if any(size(this)==length(inA)) && any(size(this)==1)
         B.(fld) = this;
         B.(fld)(inA) = [];
         A.(fld) = this(inA);
      else
         ord = [1:ndims(this)];
         ind = find(size(this)==length(inA))-1;
         that = permute(this, circshift(ord,ind));
         B.(fld) = that;
         B.(fld)(inA,:) = [];
         A.(fld) = that(inA,:);
         B.(fld) = permute(B.(fld), circshift(ord,-ind));
         A.(fld) = permute(A.(fld), circshift(ord,-ind));
      end
   end
end
end