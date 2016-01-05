function anc = ancstatic2rec(anc,field)
% anc = ancstatic2rec(anc,field)
% Converts a static field into an unlimited dimensioned field of constant
% value.
anc.vars.(field).dims = anc.vars.time.dims;
anc.vars.(field).data = anc.vars.(field).data(1) .* ones(size(anc.vars.time.data));
