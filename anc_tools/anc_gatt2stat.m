function var = anc_gatt2stat(att, name);
% var = anc_gatt2stat(att, name);
% Attempts to convert a global attribute to static field
% Parses data element of attribute with textscan(str,'%f %s')
% Attributes initial numeric value as data, trailing string a units.

CC = textscan(att.data,'%f %s');
if ~isempty(CC{1})
    var.data = CC{1};
    var.atts.long_name.id = 0;
    var.atts.long_name.datatype = 2;
    var.atts.long_name.data = char(name);
    var.atts.units.id = 1;
    var.atts.units.datatype = 2;
    if ~isempty(CC{2})
    var.atts.units.data = CC{2};
    else
        var.atts.units.data = 'unitless';
    end
    var.dims = {''};
else
    var = [];
end
    
end
    
    