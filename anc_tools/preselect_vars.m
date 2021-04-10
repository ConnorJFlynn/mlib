function vspec = preselect_vars(anc, prefs)
% vspec = preselect_vars(anc, prefs)
if ~isavar('anc')
    anc = anc_bundle_files;
end
if ~isavar('prefs')
    prefs = set_textport_prefs(anc);
end
if ~isfield(prefs,'qc_mode')
    prefs.qc_mode = set_qc_mode;
end
if ~isfield(prefs,'missing_in')||~isfield(prefs,'missing_out')
    prefs.missing_in.float = -9999;
    prefs.missing_in.unsigned = -9999;
    prefs.missing_in.signed = 9999;
    prefs.missing_in.char = '-9999';
    prefs.missing_out.float = NaN;
    prefs.missing_out.unsigned = -9999;
    prefs.missing_out.signed = 9999;
    prefs.missing_out.char = 'NaN';
end
vlist = fieldnames(anc.vdata);
% Need to check this list against what may already be in prefs.
% If found in prefs but not in vlist, then add it and let them be missing?
% If found in vlist but not in prefs, them prompt to ignore or add.

% remove qc_fields and datafields with no record dimension because we're going
% to let them be implied by the record-dimensioned fields the user selects.
for v = length(vlist):-1:1
    vname = vlist{v};
    %    if strfind(vname,'qc_')==1
    %       vnames(v) = [];
    %    end
    if ~any(strcmp(anc.ncdef.recdim.name, anc.ncdef.vars.(vname).dims))||...
            ~isempty(strfind(vname,'qc_'))&&length(strfind(vname,'qc_'))==1&&(strfind(vname,'qc_')==1)
        vlist(v) = []; % Remove vars that aren't time dimensioned.
    end
end
vlist(strcmp(vlist,'time')) = [];vlist(strcmp(vlist,'time_offset')) = [];
% Now for each surviving field, populate default values for format, units,
% qc_mode, and missings.
vlist = flipud(vlist);
for v = length(vlist):-1:1
    vname = vlist{v};
    if anc.ncdef.vars.(vname).datatype == 1
        vspec.(vname).format = '%d';
    elseif anc.ncdef.vars.(vname).datatype ==2
        vspec.(vname).format = '%s';
    else
        vspec.(vname).format = '%g';
    end
    if isfield(anc.vatts.(vname),'units')&&~isempty(anc.vatts.(vname).units)
        vspec.(vname).units = anc.vatts.(vname).units;
    else
        vspec.(vname).units = 'unitless';
    end
    vspec.(vname).qc_mode = 'No QC';
    if isfield(anc.vatts, ['qc_',vname])
        vspec.(vname).qc_mode = prefs.qc_mode;
    end
    if isfloat(anc.vdata.(vname))
        vspec.(vname).missing_in  = prefs.missing_in.float;
        vspec.(vname).missing_out  = prefs.missing_out.float;
    elseif isa(anc.vdata.(vname),'int8')||isa(anc.vdata.(vname),'int16')||...
            isa(anc.vdata.(vname),'int32')||isa(anc.vdata.(vname),'int64')
        vspec.(vname).missing_in  = prefs.missing_in.signed;
        vspec.(vname).missing_out  = prefs.missing_out.signed;
    elseif isa(anc.vdata.(vname),'uint8')||isa(anc.vdata.(vname),'uint16')||...
            isa(anc.vdata.(vname),'uint32')||isa(anc.vdata.(vname),'uint64')
        vspec.(vname).missing_in  = prefs.missing_in.unsigned;
        vspec.(vname).missing_out  = prefs.missing_out.unsigned;
    elseif ischar(anc.vdata.(vname))||isstring(anc.vdata.(vname))
        vspec.(vname).missing_in  = prefs.missing_in.char;
        vspec.(vname).missing_out  = prefs.missing_out.char;
    end
    vspec.(vname).extract = true;
end
return

function qc_mode = set_qc_mode;
opts = {'only GOOD','no BAD','no QC','summary','detailed'};
mn = menu('Select the level of QC to include in the export:', 'only GOOD values','no BAD values','No QC applied','summary','detailed');
qc_mode = opts{mn};
return