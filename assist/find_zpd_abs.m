function [zpd_loc, zpd_mag] = find_zpd_abs(igram);
% Usage: [zpd_loc, zpd_mag] = find_zpd_abs(igram);
% Finds the location and signed magnitude of an igram zpd based on absolute
% magnitude only.

[mag,Ai] = max(abs(igram.y),[],2);
zpd_loc = Ai;
pmag = max(igram.y,[],2);
smag =(1-2*(mag>=pmag)).*mag;
zpd_mag = smag;
return %find_zpd_abs