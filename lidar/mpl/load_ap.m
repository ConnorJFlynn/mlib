function [status, ap_fit] = load_ap; 
% [status, ap_fit] = load_ap;
% Interactively selects afterpulse file to load.
% This should be an ascii file output from tablecurve
% containing ap_range and ap_fit in log(cpus)

disp('Select an afterpulse fit file.')
[status, ap_fit, fname, pname] = loadfile('*.txt','ap_fit');

if (status<=0)
    disp('Bad file selected!');
else
    ap_fit(:,2) = exp(ap_fit(:,2));
end
