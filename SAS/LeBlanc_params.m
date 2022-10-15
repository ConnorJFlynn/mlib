function eta = LeBlanc_params(wl, L)

% Adhoc stitching HOU SASZe vis and nir together
% vis_wl = vis.vdata.wavelength>340 & vis.vdata.wavelength<977.8;
% nir_wl = nir.vdata.wavelength>978&nir.vdata.wavelength<1690;


if min(wl)>1
   wl = wl./1000;
end
if (length(wl)==length(L)) && (iscolumn(wl)&&iscolumn(L) || iscolumn(wl)&&isrow(L) || isrow(wl)&&iscolumn(L) || isrow(wl)&&isrow(L))

eta(1) = LB_eta_1(wl,L); % Curvature over 1 to 1.1

eta(2) = LB_eta_2(wl,L); % Derivative at 1.2
eta(3) = LB_eta_2(wl,L); % Derivative at 1.5
eta(4) = LB_eta_4(wl,L); % Ratio of L1p23/L1p237

eta(5) = LB_eta_5(wl,L); % Mean over 1.235 to 1.27
eta(6) = LB_eta_6(wl,L); % Mean over 1.565 to 1.64
eta(7) = LB_eta_7(wl,L); % Mean over 1 to 1.05

eta(8) = LB_eta_8(wl,L); % Curvature over 1.49 to 1.6

eta(9) = LB_eta_9(wl,L); % Slope of derivative from 1.0 to 1.08
eta(10) = LB_eta_10(wl,L); % Slope of derivative from 1.2 to 1.31
eta(11) = LB_eta_11(wl,L); % Slope from .53 to .61

eta(12) = LB_eta_12(wl,L); % normalized radiance L1p04

eta(13) = LB_eta_13(wl,L); % Ratio L1/L1p065
eta(14) = LB_eta_14(wl,L); % Ratio Lp6/Lp87

eta(15) = LB_eta_15(wl,L); % Slope 1.565 to 1.634

else
  warning('wl and L must be the same length and each must be single dimensioned');
  eta = [];
end


end


function eta =LB_eta_1(wl,L) %Curvature between 1 and 1.1 microns
L1 = interp1(wl, L, 1,'linear'); 
L = L./L1; % May need to multiply L1 by the appropriate ones vector
WL_ = wl>=1 & wl<=1.1;
[wl_ab] = find(WL_);
[P,S] = polyfit(wl(WL_), L(WL_),1); 
lin = polyval(P,wl(wl_ab(1):wl_ab(end)),S);
eta = sum(L(WL_)-lin);
end

function eta =LB_eta_2(wl,L) %derivative at 1.2
L1 = L./ interp1(wl,L, 1, 'linear');
WL_= wl>=1 & wl<=1.2;
P = polyfit(wl(WL_), L1(WL_), 1); 
D = polyder(P); 
eta = polyval(D,1.2); 
end

function eta = LB_eta_3(wl,L) %derivative at 1.5
L1 = L./ interp1(wl,L, 1, 'linear');
WL_= wl>=1 & wl<=1.5;
P = polyfit(wl(WL_), L1(WL_), 1); 
D = polyder(P); 
eta = polyval(D,1.5); 
end

function eta = LB_eta_4(wl,L) % Ratio between 1200 and 1237 um
L_ab = interp1(wl, L, [1.2 1.237],'linear'); 
eta = L_ab(:,1)./L_ab(:,2);
end

function eta = LB_eta_5(wl,L) % Mean from 1245 and 1270 um
L = L./max(L);
ab = [1235:1270]./1000;
wl_ab = interp1(wl, [1:length(wl)],ab, 'nearest'); 
LB_eta_5_ = mean(L(wl_ab(1):wl_ab(end)));
% Option 2:
eta = mean(interp1(wl, L, ab,'linear'));
disp('Compare option 1 and 2, eta(5)');
end

function eta = LB_eta_6(wl,L) % Mean from 1565 and 1640 um
L = L./max(L);
ab = [1565:1640]./1000;
wl_ab = interp1(wl, [1:length(wl)],ab, 'nearest'); 
LB_eta_6_ = mean(L(wl_ab(1):wl_ab(end)));
% Option 2:
eta = mean(interp1(wl, L, ab,'linear'));
disp('Compare option 1 and 2');
end

function eta = LB_eta_7(wl,L) % Mean from 1000 and 1050 um
L = L./max(L);
ab = [1000:1050]./1000;
wl_ab = interp1(wl, [1:length(wl)],ab, 'nearest'); 
LB_eta_7_ = mean(L(wl_ab(1):wl_ab(end)));
% Option 2:
eta = mean(interp1(wl, L, ab,'linear'));
disp('Compare option 1 and 2');
end

function eta = LB_eta_8(wl,L) %Curvature between 1.49 and 1.6 microns
L1 = interp1(wl, L, 1,'linear'); 
L = L./L1; % May need to multiply L1 by the appropriate ones vector
WL_ = wl>=1.49 & wl<=1.6;
[wl_ab] = find(WL_);
[P,S] = polyfit(wl(WL_), L(WL_),1); 
lin = polyval(P,wl(wl_ab),S);
eta = sum(L(WL_)-lin);
end

function eta = LB_eta_9(wl,L) %Slope of derivative from 1 to 1.08
ab = [1,1.08]
L1 = interp1(wl, L, 1,'linear'); 
L = L./L1; % May need to multiply L1 by the appropriate ones vector
WL_ = wl>=ab(1) & wl<=ab(2);
[P] = polyfit(wl(WL_), L(WL_),1); 
D = polyder(P);
eta = (polyval(D,ab(2))-polyval(D,ab(1)))./(ab(2)-ab(1));
end

function eta = LB_eta_10(wl,L) %Slope of derivative from 1.2 to 1.31
ab = [1.2,1.31]
L1 = interp1(wl, L, 1,'linear'); 
L = L./L1; % May need to multiply L1 by the appropriate ones vector
WL_ = wl>=ab(1) & wl<=ab(2);
[P] = polyfit(wl(WL_), L(WL_),1); 
D = polyder(P);
eta = (polyval(D,ab(2))-polyval(D,ab(1)))./(ab(2)-ab(1));
end

function eta = LB_eta_11(wl,L) % slope  from .53 to .61
L = L./max(L);
ab = [.53, .61];
L_ab = interp1(wl,L,ab,'linear');
eta = diff(L_ab)./diff(ab);
end

function eta = LB_eta_12(wl,L) % normalized radiance
L = L./max(L);
ab = [1.04];
L_ab = interp1(wl,L,ab,'linear');
eta = L_ab;
end

function eta = LB_eta_13(wl,L) % Ratio
ab = [1, 1.065];
L_ab = interp1(wl,L,ab,'linear');
eta = L_ab(1)./L_ab(2);
end

function eta = LB_eta_14(wl,L) % Ratio
ab = [.6, .87];
L_ab = interp1(wl,L,ab,'linear');
eta = L_ab(1)./L_ab(2);
end

function eta = LB_eta_15(wl,L) % Slope
ab = [1.565, 1.634];
L_ab = interp1(wl,L,ab,'linear');
eta = (L_ab(2)./L_ab(1) - 1)./diff(ab);
end

