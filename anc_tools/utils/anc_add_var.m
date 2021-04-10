function anc = anc_add_var(anc,var,dims,vatts);
% Adds a supplied variable in "var" to an existing anc struct.
% Var must be a struct containing the field to be added.
% The name of the field will become the name of the variable field.
% The variable type will match the class of the var field.
% datatype_to_id(dtype)
% updates 
%     anc.ncdef.vars.(var)
%     anc.ncdef.vars.(var).atts.(vatts)
%     anc.vdata.(var)
%     anc.vatts.(var)

field = fieldnames(var);
if iscell(field)&&~isempty(field)
    field = field{1};
end
% vars.(field).datatype = datatype_to_id(var.(field));
anc.ncdef.vars.(field).datatype = class_to_dtype(var.(field));
anc.ncdef.vars = init_ids(anc.ncdef.vars);
if isavar('dims')
    anc.ncdef.vars.(field).dims = dims;
else
    anc.ncdef.vars.(field).dims = {''};
end
if isavar('vatts')
    vatt_names = fieldnames(vatts);
    for vatt = 1:length(vatt_names)
        vattname = vatt_names{vatt};
        att = []; att.(vattname) = vatts.(vattname);
        anc = anc_add_att(anc,field, att);
    end
end

% Check for required vatts...