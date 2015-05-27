function [RadianceSpc] = RadiometricCalibration_(RawSpc, CalSet);
% Returns the calibrated radiance
% RawSpc contains the raw spectra
% CalSet is the radiometric calibration dataset

if isfield(RawSpc,'Header')
RadianceSpc.Header = RawSpc.Header;
end
RadianceSpc.x = RawSpc.x;
% RadianceSpc.y = 0*RawSpc.y;
for ll = size(RawSpc.y, 1):-1:1
    RadianceSpc.y(ll,:) = (RawSpc.y(ll,:) - CalSet.Offset) .* CalSet.Gain;
end
