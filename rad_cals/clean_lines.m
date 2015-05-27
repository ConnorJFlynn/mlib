function [clean, notclean] = clean_lines(lib)
%% [clean, notclean] = clean_lines(lib)
% Strips out spectral lines with comments (that tend to indicate less
% optimal lines)
[Comments, ii_, jj_]  = unique(lib.Comment);
dmp = false(size(lib.Wavelength'));
for x = length(Comments):-1:2
    dmp = dmp | any(lib.Comment==Comments(x));    
end
clean = lib;
clean.Comment(:,dmp) = [];
clean.Intensity(dmp) = [];
clean.Wavelength(dmp) = [];
clean.Ionization(dmp) = [];

notclean = lib;
notclean.Comment(:,~dmp) = [];
notclean.Intensity(~dmp) = [];
notclean.Wavelength(~dmp) = [];
notclean.Ionization(~dmp) = [];
%%

return
