Ad = 100;
Au = 0;
Bd = 0;
Bu = 0;
Cd = 0;
Cu = 0;
Dd = 0;
Du = 0;
X_T = 0.1; X_R = 1-X_T;
Y_T = 0.001; Y_R = 1-Y_T;
Z_T = 1.;
Z_R = 1-Z_T;
i = 0;

for i = 1:50
Au = X_R.*Ad + X_T.*Bu;
Bd = X_T .* Ad + X_R.*Bu;
Bu = Y_R .* Bd + Y_T.* Cu;
Cd = Y_T .* Bd + Y_R.*Cu;
Cu = Z_R .* Cd + Z_T.* Du;
Dd = Cd .* Z_T;

end
[1 X_T, Y_T, Z_T, Dd./Ad;
 Ad   Bd Cd Dd Cd./Ad]
%%