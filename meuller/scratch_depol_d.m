%% circ and linear depol stuff
% Having some difficulty testing my recent model with a quarter-wave Fresnel rhomb and
% mirror. I want to test this configuration with a range of incident
% polarizations but am having some difficulty expressing this satisfactorily in
% Mueller matrix notation.

% We want to specify the rhomb such that circ pol is always returned
% unchanged while lin pol changes relative to original as a function of
% angle relative to rhomb axes.

in_c = S_CR;
in_l = S_LH;
%%
clear out_l
a = [0:.001:90];
% arb_c = M_HW_theta(a./2)*in_c; %initial polarization rotated through an arbitrary angle
% arb_l = M_HW_theta(a./2)*in_l; %initial polarization rotated through an arbitrary angle

%
for i = length(a):-1:1
rhomb = M_QW_theta(a(i)) * M_mir * M_QW_theta(-a(i));
M_22(i) =rhomb(2,2);
M_33(i) = rhomb(3,3);
M_23(i) = rhomb(2,3);
M_32(i) = rhomb(3,2);
M_44(i) = rhomb(4,4);
out_l(:,i) = rhomb * S_LH;
% [arb_c, out_c, arb_l, out_l]
end
mean_M = zeros(size(4,4));
mean_M(1,1) = 1;
mean_M(2,2) = mean(M_22);
mean_M(2,3) = mean(M_23);
mean_M(3,2) = mean(M_32);
mean_M(3,3) = mean(M_33);

mean_M(4,4) = mean(M_44);
