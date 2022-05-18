function spec_panel = srt_sn_2784;
% Loads existing mat file 'srt_sn_2784.mat' containing nm and Refl for spectralon panel
tmp = which("srt_sn_2784.mat");
if ~isempty(tmp)&&isafile(tmp)
   spec_panel = load(tmp);
end

end