aps_dS = aps_dN;
aps_dS = rmfield(aps_dS,'sdist');
aps_dS.D = aps_dN.D;
aps_dS.SAdist =  pi.*aps_dN.sdist.*(ones(size(aps_dN.time))*(aps_dN.D./100).^2);
aps_dS.fname = strrep(aps_dS.fname, 'size','SA');
save([aps_dS.pname, strrep(aps_dS.fname, '.csv','.mat')],'-struct','aps_dS');
%%
SizeDist_Optics(1.55+0.001i, aps_dN.D.*1000, aps_dN.sdist(2000,:), 550,'cut',5000, 'nephscats',true,'normalized',false);


ans = 

    extinction: 20.8826
    scattering: 20.6761
    absorption: 0.2065
      backscat: 1.9137
      nephscat: 16.8981
     nephbscat: 1.8906
           ssa: 0.9901
          asym: 0.7043
       forceff: -219.6123