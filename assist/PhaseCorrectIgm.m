function [ pcIgram, spcPhase ] = PhaseCorrectIgm( igram, I, spcPhase)
%PHASECORRECTIGM Summary of this function goes here
%   Detailed explanation goes here
    % Based on Mertz method described at http://chemwiki.ucdavis.edu/Analytical_Chemistry/Instrumental_Analysis/Spectrometer/How_an_FTIR_instrument_works
        
    % Apodize using triangular apodization function
    if (~exist('spcPhase', 'var'))
        middle = size(igram, 1)/2;
        lrIgm = triangWindow(igram(middle-255:middle+256));
        % Zero the centerburst
        lrSpc = ftirFFT(lrIgm, I-middle+256);

        spcPhase = atan(imag(lrSpc) ./ real(lrSpc));

        spectrum = ftirFFT(igram, I);

        spcPhase = interp1(linspace(0, 1, size(spcPhase, 1)), spcPhase, linspace(0, 1, size(spectrum, 1)))';
    else
        spectrum = ftirFFT(igram, I);
    end
    pcSpectrumReal = (real(spectrum) .* cos(spcPhase)) + (imag(spectrum) .* sin(spcPhase));
    
    pcIgram = fftshift(ifft(fftshift(pcSpectrumReal)));
end

