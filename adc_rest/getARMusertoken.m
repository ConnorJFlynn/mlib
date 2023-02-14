function [ARMtoken] = getARMusertoken
% [ARMtoken] = getARMusertoken

%% Checks whether username and token have already been saved in "ARMtoken.mat"  
% If so, load it and return in struct ARMtoken
if isafile([getfilepath('tokenpath'),'ARMtoken.mat'])
   ARMtoken = load(getfullname('ARMtoken.mat','tokenpath'));
else %Gets the userkey from: https://adc.arm.gov/armlive/register
   usr = input('Enter ARM user name:','s');
   disp('Open this website: https://adc.arm.gov/armlive/home')
   disp('Login with ARM user name')
   menu('Copy the API Access Token, click OK to continue','OK')
   tok = input('Paste or enter your API Access Token: ','s');
   ARMtoken = [usr,':',tok];
   disp(ARMtoken);
   tokenpath = getfilepath('tokenpath','set ARMToken path',true);
   save([tokenpath,'ARMtoken.mat'],'ARMtoken');
end
if isfield(ARMtoken,'ARMtoken')
   ARMtoken = ARMtoken.ARMtoken;
end
end