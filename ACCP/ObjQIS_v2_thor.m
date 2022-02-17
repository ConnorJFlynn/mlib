function [OWQadj,OWQ,OWQadj_LO] = ObjQIS_v2_thor(QIS,out,adj);
% [OWQadj,OWQ,OWQadj_LO] = ObjQIS_v2_thor(QIS,out,adj);
% if out = true then output data files

%v1, 2020-10-28: refactoring existing functions to avoid ambiguous VF mat files that don't distinguish between adjusted and unadjusted input
%v2, 2021-01-03: cleaning up order of execution and loops to output lidar-only
%v2_thor, 2022-01-05; Modifying for Tyler Thorsen to break out NADLC0,
%NADLC1, NADBC0 and NAN
if ~isavar('out')
    out = true;
end
if isempty(out)
    out = false;
end 
out = logical(out);
if ~isavar('adj')
    adj = [];
end

% Incorporates "apply_Oct_adj_to_QIS" function and "apply_QWCS_C1_v1" capability
[QISadj] = apply_Oct_adj_to_QIS(QIS);
OWQadj = apply_OWs_C1_thor_v1(QISadj,adj);
if out
    OWQadj_out = output_OWs_C1_v2(OWQadj, 'Adj');
end

return