function nc = anc_stat2rec(nc);
% nc = anc_stat2rec(nc);
% This function removes existing record dimension data and converts static
% data (global atts and static fields) to single-instance unlimited
% dimension suitable for concatenation with like-shaped DODs.
if ~exist('nc','var')
    nc = ancload;
end
if ~isstruct(nc) && exist(nc,'file')
    nc = ancload(nc);
end
% disp(nc.fname)
nc.time = mean(nc.time);

% Remove all record-dimensioned fields.
var = fieldnames(nc.vars);
disp(['   Removing time-dimensioned vars'])
for v = length(var):-1:1
    tmp = strfind(nc.vars.(var{v}).dims, nc.recdim.name);
    if ~isempty(tmp{1})
%         disp(['Removing ',var{v}])
        nc.vars = rmfield(nc.vars,var{v});
    end
end
var = fieldnames(nc.vars);

% Convert global atts to static fields.

gat = fieldnames(nc.atts);

disp(['   Converting global atts to static fields'])
for gg = length(gat):-1:1
    tmp = gat{gg};
    new_var = anc_gatt2stat(nc.atts.(gat{gg}), gat{gg});
    if ~isempty(new_var)
        over = 3;
        if anystrfind(var,gat{gg})
            over = menu(['   Field ',gat{gg},' already exists. Skip or overwrite?'],'Skip','Overwrite');
        end
        if over>1
%             disp(['Converted ',gat{gg}, ' = ',sprintf('%g',new_var.data)])
            nc.vars.(gat{gg}) = new_var;
        end
    end
    nc.atts = rmfield(nc.atts, gat{gg});
end

var = fieldnames(nc.vars);
% Convert static fields into rec-dimensioned unless coordinate fields
coord_dims = setxor(fieldnames(nc.dims),nc.recdim.name);

for v = length(var):-1:1
    if ~anystrfind(coord_dims,var)
        tmp = nc.vars.(var{v}).dims;
        if isempty(tmp{1})
            nc.vars.(var{v}).dims = {nc.recdim.name};
        else
            nc.vars.(var{v}).dims = {nc.vars.(var{v}).dims{:},nc.recdim.name};
        end
    end
end

nc = timesync(nc);

return