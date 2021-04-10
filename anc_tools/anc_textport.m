function txt = anc_textport(anc, prefs)
% txt = anc_textport(anc, pref)
% This function is expected to be preceeded by set_textport_prefs
% that lets the user select/exclude vlist, time_format, delimiter, vspec

% We will stil perform an additional check to make sure relevant dims and
% coordinate fields are provide, and output global atts and header.

if ~isavar('anc')
   anc = anc_bundle_files;
end
if ~isstruct(anc)&&isafile(anc)
   anc = anc_load(anc);
end
if ~isavar('pref')
   prefs = set_textport_prefs(anc);
end

 txt = anc_vdata_dump(anc, prefs);
 
end
