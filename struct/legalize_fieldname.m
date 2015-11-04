function newname = legalize_fieldname(oldname)
% Replaces illegal characters in names of structure elements.
if ((oldname(1)>47)&(oldname(1)<58))
oldname = ['n_',oldname];
end
newname = strrep(oldname,' ','');
newname = strrep(newname,'.','');
newname = strrep(newname,',','');
newname = strrep(newname,'<=','lte_');
newname = strrep(newname,'>=','gte_');
newname = strrep(newname,'<','lt_');
newname = strrep(newname,'>','gt_');
newname = strrep(newname,'==','eeq_');
newname = strrep(newname,'=','eq_');
newname = strrep(newname,'-','__dash__');
newname = strrep(newname,'+','__plus__');
newname = strrep(newname,'(','__leftpar__');
newname = strrep(newname,')','__rightpar__');
newname = strrep(newname,')','__rightpar__');
newname = strrep(newname,'#','__hash__');
newname = strrep(newname,'/','__fslash__');
newname = strrep(newname,'\','__bslash__');
newname = strrep(newname,'^','__caret__');
newname = strrep(newname,'%','__pct__');

if newname(1) == '_'
    newname = ['underbar__',newname(2:end)];
end

return