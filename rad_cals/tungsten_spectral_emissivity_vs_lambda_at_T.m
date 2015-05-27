function emis = tungsten_spectral_emissivity_vs_lambda_at_T(W,T,nm)
% Return emissivity as a functon wavelength at supplied temperature T)
% If wavelength is not provided then default to wavelength scale in W)
%%
if T>=min(W.T1_K) || T<=max(W.T1_K)
    for wl = length(W.um):-1:1        
        em(wl) = interp1(W.T1_K,W.emis_v_T1(wl,:),T,'cubic');      
    end
else
    for wl = length(W.um):-1:1
        [P,S] = polyfit(W.T1_K./1000,W.emis_v_T1(wl,:),2);
        em(wl) = polyval(P,T./1000,S);
    end
end
if exist('nm','var')
emis = interp1(W.um, em, nm./1000,'cubic');
wl_ = (nm./1000)<min(W.um)|(nm./1000)>max(W.um);
if any(wl_)
[P,S] = polyfit(W.um,em',2);
emis(wl_) = polyval(P,nm(wl_)./1000,S);
end
else
    emis = em;
end
return
%%