function [ spectrum ] = ftirFFT(igram, zpdIndex)
%FTIRFFT Gets the single beam spectrum from a raw interferogram.
% The data is truncated from the ZPD position received as parameter and
% missing data points are zero padded to get a power of 2 number of points.

    %igram = igram(zpdPosition: length(igram)); 
    
    %n = 2 ^ nextpow2(length(igram));
    
    spectrum = fftshift(fft(lrt_fftshift(igram, zpdIndex)));
end

