function [OWQadj,OWQ] = ObjQIS(QIS,out);
% [OWQadj,OWQ] = ObjQIS(QIS,out);
% if out = true then output data files

if ~isavar('out')
    out = true;
end
if isempty(out)
    out = false;
end 
out = logical(out);
%v1, 2020-10-28: refactoring existing functions to avoid ambiguous VF mat files that don't distinguish between adjusted and unadjusted input

% Incorporates "apply_Oct_adj_to_QIS" function and "apply_QWCS_C1_v1" capability

OWQ = apply_OWCs_C1_v2(QIS);
if out
    OWQ_out = output_OWCs_C1(OWQ);
end
[QISadj] = apply_Oct_adj_to_QIS(QIS);
OWQadj = apply_OWCs_C1_v2(QISadj);
if out
    OWQadj_out = output_OWCs_C1(OWQadj, true);
end

return