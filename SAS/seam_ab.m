function AB = seam_ab(wl, A,B)
% AB = seam(wl, A,B)
% Generates AB as wl-weighted sum
% wl, A, B all same size

min_wl = min(wl); max_wl = max(wl); W = wl(end)-wl(1);
wB = (wl-min_wl)./W;
wA = 1-wB;
AB = wA.*A + wB.*B;

end