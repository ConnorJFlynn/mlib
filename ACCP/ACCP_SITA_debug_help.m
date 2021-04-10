GRP = ["NLP", "NLB", "NLS", "NGE", "OUX"];  
PFM = ["SSP0", "SSP1", "SSP2", "SSG3"];                     %4  
OBI = ["NADLC0", "NADBC0", "NANLC0", "ONDPC0","NADLC1","NANLC1","NADLC2","NANLC2"];    
SFC_ = ["LNDD", "LNDV", "OCEN","LAND","NONE"]; %labels parsed but not in QIS, RMS, MER
SFC = ["LAND","OCEN"];
REZ = ["RES1", "RES2", "RES3", "RES4", "RES5"];    

Ocean_cases= ["8a","8b","8c","8g","8h","8k","8l"]; 
Land_cases= ["8d","8e","8f","8i","8j","8m","8n","8o"];
ocen_case = [1:3 7:8 11:12]; 
land_case = [4:6 9:10 13:15];
case1 = 0; case2 = 15;
DRS = 0; ICA = 30;

% QIS = NaN([65,length(GRP),length(TYP),length(PFM),length(OBI),length(SFC),length(REZ)]);

HH = 64; g_i = 5; typ_i = 4; p_i = 1; obi_i = 1; sfc_i = 1; 
squeeze(RMS(HH,g_i,typ_i,:,obi_i,sfc_i,1))
squeeze(RMS(64,5,land_case,1,1,1,1))