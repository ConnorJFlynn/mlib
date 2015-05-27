function [I_new] = gsmooth(t,I, W);
%[good] = IQF_lang(t,I, W);
% Applies a gaussian smoother over a window of width W
% W must be scalar or of length(I)
if numel(W)==1
    for ti = length(t):-1:1
%         P = gaussian(t,t(ti),W(ti));
        P = gaussian(t,t(ti),W);
        I_new(ti) = trapz(t,I.*P)./trapz(t,P);
    end
elseif numel(W)==numel(I)
    for ti = length(t):-1:1
        P = gaussian(t,t(ti),W(ti));
        I_new(ti) = trapz(t,I.*P)./trapz(t,P);
    end
else
    disp('W must be either scalar or same dimension as I')
end
