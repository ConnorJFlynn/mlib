function [Q_sca,Q_ext,Q_back,Q_abs] = nlayerEfficiencies(m,x)
nc = ceil(max(x)+4.05*(max(x)^(1/3))+2); 
[a,b] = nlayerScaCoeff(m,x,nc);
% scattering efficiency
Q_sca = (2/(max(x)^2)) .* sum((2*length(a)+1) .* (abs(a).^2 + abs(b).^2));
% extinction efficiency
% BEWARE OF THE EXTINCTION PARADOX [Bohren and Huffman 1998, p107]
Q_ext = (2/(max(x)^2)) .* sum((2*length(a)+1) .* (real(a + b)));
% backscatter efficiency
Q_back = (1/(max(x)^2)) .* ((abs(sum((2*length(a)+1) .* (-1^(length(b))) .* (a - b)))).^2);
% heuristic efficiency for radiation pressure
% (ie the force exerted on the particle by the laser beam)
% Q_h_pressure = Q_ext -
% (4/(max(x)^2)) * (sum( (nc*(nc+2)/(nc+1)) .* real(a .* conj([0 a(nc+1,:)]) +
% b .* conj([0 b(nc+1,:)])) ) + sum((2*nc+1/n^2 + nc) .* real(a.*conj(b))))
% approximate value for the absorption efficiency Q_abs
Q_abs = Q_ext - Q_sca;