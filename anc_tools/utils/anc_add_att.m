function anc = anc_add_att(anc,field, att);

% if isempty field, then global

%
% updates 
%     anc.ncdef.vars.(var)
%     anc.vatts.(var)
if ~isavar('field')
    field = [];
end
if iscell(field)
    field = field{1};
end
att_name = fieldnames(att); 
if iscell(att_name)&&~isempty(att_name)
    att_name = att_name{1};
end
if ~isempty(field)
anc.ncdef.vars.(field).atts.(att_name).datatype = class_to_dtype(att.(att_name));
anc.ncdef.vars.(field).atts = init_ids(anc.ncdef.vars.(field).atts);
anc.vatts.(field).(att_name)= att.(att_name);

else
anc.ncdef.atts.(att_name).datatype = class_to_dtype(att.(att_name));
anc.ncdef.atts = init_ids(anc.ncdef.atts);
anc.gatts.(att_name)= att.(att_name);
    
end
return