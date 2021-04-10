function d = DoP(S)
% d = DoP(S); % Returns the degree of polarization 
d = 100.*sqrt(s(2).^2 + s(3).^2 + s(4).^2)./s(1);
end