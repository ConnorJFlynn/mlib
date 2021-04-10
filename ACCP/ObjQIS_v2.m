function [OWQadj,OWQ,OWQadj_LO] = ObjQIS_v2(QIS,out);
% [OWQadj,OWQ,OWQadj_LO] = ObjQIS_v2(QIS,out);
% if out = true then output data files

%v1, 2020-10-28: refactoring existing functions to avoid ambiguous VF mat files that don't distinguish between adjusted and unadjusted input
%v2, 2021-01-03: cleaning up order of execution and loops to output lidar-only
%v3, 2021-01-04; Added LIC, increment apply versions
if ~isavar('out')
    out = true;
end
if isempty(out)
    out = false;
end 
out = logical(out);


% Incorporates "apply_Oct_adj_to_QIS" function and "apply_QWCS_C1_v1" capability
[QISadj] = apply_Oct_adj_to_QIS(QIS);
OWQ = apply_OWs_C1_v3(QIS);
OWQadj = apply_OWs_C1_v3(QISadj);
OWQadj_LO = apply_OWs_C1_LO_v4(QISadj); % For VF group
if out
    OWQ_out = output_OWs_C1_v2(OWQ);
    OWQadj_out = output_OWs_C1_v2(OWQadj, 'Adj');
    OWQadj_LO_out = output_OWs_C1_v2(OWQadj_LO, 'AdjLO');
end

return