% I = nlayerIntensity(x, m, Io, ang, polarisation);
%
% Io is the incident light’s power.
% Polarisation is an option for incident light polarisation state
% as opposed to the reference scattering plane:
% Polarisation = 0 ==> unpolarised
% Polarisation = 1 ==> perpendicular
% Polarisation = 2 ==> parallel
function I = nlayerIntensity(x, m, Io, ang, polarisation)
S = nlayerAmp(m, x, ang);
if polarisation == 0
% assuming incident light is unpolarised
I = (1/(max(x))^2) .* S(1,:) .* Io;
elseif polarisation == 1
% assuming incident light is polarised parallel
% to the scattering plane
I = (1/(max(x))^2) .* (S(1,:) + S(2,:)) .* Io;
elseif polarisation == 2
% assuming incident light is polarised perpendicular
% to the scattering plane
I = (1/(max(x))^2) .* (S(1,:) - S(2,:)) .* Io;
end