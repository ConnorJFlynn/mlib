function out = merge_profs(prof1, prof2, w);
% out = merge_profs(prof1, prof2, w);
% Merges prof1 and prof2 according to weights w
% out = prof1 .* w + prof2 .* (1-w);
% if weights are provided they are normalized to 1
% Some useful weights follow...

% w_lin = [prof_len:-1:1]'./prof_len; % linear
% w_2 = w_lin.^2; % quadratic, steep drop, smooth end
% rad = (pi/2)*[0:1:(prof_len-1)]'/prof_len;
% w_cos = (cos(rad)); % cosine, smooth drop, steep end
% w_sin = (1-sin(rad)); % sine, steep drop, smooth end
% w_S = cos(rad).^2; % "S", smooth ends

if ~exist('w','var')
    w = [length(prof1):-1:1]'./length(prof1);
end
if max(abs(w))>1
w = abs(w)/max(abs(w));
end
out = prof1 .* w + prof2 .* (1-w);