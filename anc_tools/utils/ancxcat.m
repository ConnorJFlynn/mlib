function [nc, nc_] = ancxcat(nc, nc2);
% nc = ancxcat(nc, nc2)
% concatenates even non-identical DODs along the time dimension
% unless coordinate dimensions are mismatched.
% Creates matching (empty) variables in both nc structs
% Then merges the two using anccat

dims = setxor(['time'],union(fieldnames(nc.dims),fieldnames(nc2.dims)));
mismatch = false;
dimsize = size(dims);
if dimsize(1)>1 && dimsize(2)==1
    dims = dims';
end
for d = dims
    d= char(d);
    mismatch = mismatch||(nc.dims.(d).length~=nc2.dims.(d).length);
end

if mismatch
    disp('Mismatched coordinate dims');
    nc_ = nc;
    nc = nc2;
else
    nc_ = [];
    var1 = fieldnames(nc.vars);
    var2 = fieldnames(nc2.vars);
    
    for v = length(var1):-1:1
        if ~anystrfind(var2, var1{v})
            % we need to create this field in nc2
            disp(['Creating ', var1{v},'in nc2'])
            nc2.vars.(var1{v}) = nc.vars.(var1{v});
            SZ = size(nc.vars.(var1{v}).data);
            SZ(end) = length(nc2.time);
            nc2.vars.(var1{v}).data = NaN(SZ);
        end
    end
    
    for v = length(var2):-1:1
        if ~anystrfind(var1, var2{v})
            % we need to create this field in nc
            disp(['Creating ', var2{v},'in nc'])
            nc.vars.(var2{v}) = nc2.vars.(var2{v});
            SZ = size(nc2.vars.(var2{v}).data);
            SZ(end) = length(nc.time);
            nc.vars.(var2{v}).data = NaN(SZ);
        end
    end
    
    nc = anccat(nc, nc2);
end
return
