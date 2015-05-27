function out = grid_avg(in,n,dim)
if ~exist('dim','var')
    dim = 'time';
end
if ~isfield(in,dim)
    disp('No field matching default or supplied dimension.')
    return
end
first = floor(in.(dim)(1));
last = ceil(in.(dim)(end));
sz = size(in.(dim));
fld = fieldnames(in);
% Strip out dim field and any fields that aren't the same size as the dim
% field.
for f = length(fld):-1:1
    if strcmp(dim,fld{f})
        fld(f) = [];
    elseif ~all(sz==size(in.(fld{f})))
        fld(f) = [];
    end
end
out_dim = first:1./n:last;
out.(dim) = out_dim(1:end-1);
for t = length(out.(dim)):-1:1
%     disp(t)
    t_ = in.(dim)>=out_dim(t) & in.(dim)<out_dim(t+1);
    if sum(t_)>0
        out.N(t) = sum(t_);
        for f = 1:length(fld)
            out.(fld{f})(t) = mean(in.(fld{f})(t_));
            out.min.(fld{f})(t) = min(in.(fld{f})(t_));
            out.max.(fld{f})(t) = max(in.(fld{f})(t_));
        end
    else
        out.(dim)(t) = [];
        if isfield(out,'N')
            out.N(t) = [];
            
            for f = 1:length(fld)
                out.(fld{f})(t) = [];
                out.min.(fld{f})(t) = [];
                out.max.(fld{f})(t) = [];
            end
        end
    end
end

return