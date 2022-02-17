function [struct, struct_] = cut_struct(struct,keep);
% newstruct = cut_struct(struct, struct);
% Concatenates two like-formed structure

[r,c] = size(keep);
if r==1 && c~=1
    dim1 = 2; dim2 = 1;
elseif r~=1 && c==1
    dim1 = 1; dim2 = 2;
else
    disp('keep must be either a column or row vector')
end
      
fields = fieldnames(struct);
  
    for fld = 1:length(fields)
        field = fields{fld};
        if size(struct.(field),1)==length(keep) && size(struct.(field),2)~=length(keep)
            struct_.(field) = struct.(field)(~keep,:);
            struct.(field) = struct.(field)(keep,:);
        elseif size(struct.(field),2)==length(keep)&& size(struct.(field),1)~=length(keep)
            struct_.(field) = struct.(field)(:,~keep);
            struct.(field) = struct.(field)(:,keep);            
        elseif size(struct.(field),1)==length(keep) && size(struct.(field),2)==length(keep)
            struct_.(field) = struct.(field)(~keep,~keep);
            struct.(field) = struct.(field)(keep,keep);  
        else
            struct_.(field) = struct.(field);           
        end
    end

return