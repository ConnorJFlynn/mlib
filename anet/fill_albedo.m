function albedo = fill_albedo(w, bdrf)
% albedo = fill_albedo(w, bdrf);
% Returns the corresponding bdrf albedo model parameters interpolated
% versus wavelength
% Uses a default bdrf table unless one is specified. 
if ~exist('w','var');
    return
end
if ~exist('bdrf','var')
    %From afurioser PPL input file for Mongu
bdrf = [...
0.4396     0.055512  0.022449   0.008419
0.470000   0.067240    0.027194    0.010200
0.555000   0.108978    0.060570    0.017047
0.659000   0.141437    0.072853    0.023392
0.6744     0.152176    0.078386    0.025169  
0.858000   0.297880    0.187778    0.031746
0.8709     0.301597    0.190119    0.032142
1.0189     0.343633    0.216591    0.036617
1.240000   0.388916    0.209137    0.030475
1.640000   0.365568    0.195644    0.039100
2.130000   0.278419    0.129853    0.046204];
% 0.4396     0.055512  0.022449   0.008419          Band 9
% 0.470000   0.067240    0.027194    0.010200   Band 3
% 0.555000   0.108978    0.060570    0.017047   Band 4
% 0.659000   0.141437    0.072853    0.023392   Band 1
% 0.6744     0.152176    0.078386    0.025169   Band 12 or 14?
% 0.858000   0.297880    0.187778    0.031746   Band 2
% 0.8709     0.301597    0.190119    0.032142
% 1.0189     0.343633    0.216591    0.036617   
% 1.240000   0.388916    0.209137    0.030475   Band 5
% 1.640000   0.365568    0.195644    0.039100   Band 6
% 2.130000   0.278419    0.129853    0.046204]; Band 7
end

for wi = length(w):-1:1
    albedo(wi,1) = interp1(bdrf(:,1), bdrf(:,2),w(wi), 'linear','extrap');
    albedo(wi,2) = interp1(bdrf(:,1), bdrf(:,3),w(wi), 'linear','extrap');
    albedo(wi,3) = interp1(bdrf(:,1), bdrf(:,4),w(wi), 'linear','extrap');
end

return
    
    
    