function [ARMtoken] = setARMusertoken
% [ARMtoken] = setARMusertoken

%Gets the userkey from: https://adc.arm.gov/armlive/register
usr = input('Enter ARM user name:','s');
web('https://adc.arm.gov/armlive/home');
menu('Copy the API Access Token, click OK to continue','OK')
tok = input('Paste or enter your API Access Token: ','s');
ARMtoken = [usr,':',tok];
disp(ARMtoken);
tokenpath = [fileparts(which('setARMusertoken')),filesep];
tokenpath = strrep(tokenpath,[filesep filesep], filesep);
% tokenpath = getfilepath('tokenpath','set ARMToken path',true);
save([tokenpath,'ARMtoken.mat'],'ARMtoken');

end