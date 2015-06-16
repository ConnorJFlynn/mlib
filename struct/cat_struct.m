function newstruct = cat_struct(struct1, struct2);
% newstruct = cat_struct(struct1, struct2);
% Concatenates two like-formed structure
% This is distinct from "catstruct" that was developed to handle Matlab
% program versions

fields1 = fieldnames(struct1);
fields2 = fieldnames(struct2);
newstruct = struct2;
if size(fields1)==size(fieldnames(struct2))
    for fieldnum = 1:length(fields1)
        if char(fields1(fieldnum))==char(fields2(fieldnum))
            V1 = getfield(struct1, char(fields1(fieldnum)));
            V2 = getfield(struct2, char(fields2(fieldnum)));
            V = [V1; V2];
            newstruct = setfield(newstruct, char(fields1(fieldnum)),V);
        else
            disp('These aren''t like-formed structures!!');
            break;
        end
    end
else
    disp('These aren''t like-formed structures!!');
    return;
end;

return