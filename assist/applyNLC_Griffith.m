function [ correctedIgram ] = applyNLC_Griffith(laser_freq, wavenumbers, igram, zpdPos )
%APPLYNLC_GRIFFITH Summary of this function goes here
%   Detailed explanation goes here
    
    wnRange = 100;
    aWn = 400;
    bWn = 7800;
    cWn = 7000;

    spectrum = ftirFFT(igram, zpdPos);
    spectrum = spectrum(length(spectrum)/2 + 1 : length(spectrum));
    
    [~, aWnStart]= min(abs(wavenumbers-aWn+(wnRange/2)));
    [~, aWnStop]= min(abs(wavenumbers-aWn-(wnRange/2))); 
    [~, bWnStart]= min(abs(wavenumbers-bWn+(wnRange/2)));
    [~, bWnStop]= min(abs(wavenumbers-bWn-(wnRange/2))); 
    [~, cWnStart]= min(abs(wavenumbers-cWn+(wnRange/2)));
    [~, cWnStop]= min(abs(wavenumbers-cWn-(wnRange/2))); 
    
    aWnSpc = mean(real(spectrum(aWnStart:aWnStop, :)), 1);
    bWnSpc = mean(real(spectrum(bWnStart:bWnStop, :)), 1);
    cWnImagSpc = mean(imag(spectrum(cWnStart:cWnStop, :)), 1);
    
    aa = 2 * pi * aWn / laser_freq;
    bb = 2 * pi * bWn / laser_freq;
    cc = 2 * pi * cWn / laser_freq;

    eq = [-1, -cos(aa), -cos(-aa); -1, -cos(bb), -cos(-bb); 0, sin(cc), sin(-cc)];
    res = [aWnSpc, bWnSpc, cWnImagSpc]';
    A = (eq\res)';
    
    correctedIgram = igram;
    correctedIgram(zpdPos, :) = correctedIgram(zpdPos, :) + A(1);
    correctedIgram(zpdPos-1, :) = correctedIgram(zpdPos-1, :) + A(2);
    correctedIgram(zpdPos+1, :) = correctedIgram(zpdPos+1, :) + A(3);
    
%     x =  linspace(-16384, 16384, 32768);
%     figure; plot(x, igram, x, correctedIgram);
end

