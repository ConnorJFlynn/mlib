function H2OVAPPMBsat = vappres_Vaisala(dewptK)
%  Calculates saturation water vapor vapor pressure using the formula in appendix 5 of the Vaisala HMP240
%  users manual.  

    C = [0.4931358  -0.46094296e-02  0.13746454e-04  -0.12743214e-07];
    
    Theta=0;
    for i=1:4,
        Theta = Theta + C(i)*dewptK.^(i-1);
    end
    Theta = dewptK - Theta;
    
    B = [-0.58002206e4  0.13914993e1  -0.48640239e-01  0.41764768e-4  -0.14452093e-7  6.5459673];
    
    ln_vappressat=0;
    for i = 1:5,
        ln_vappressat = ln_vappressat + B(i)*Theta.^(i-2);
    end
    ln_vappressat = ln_vappressat + B(6)*log(Theta);
    H2OVAPPMBsat = exp(ln_vappressat)/100;  %convert from Pascals to mb   
return
