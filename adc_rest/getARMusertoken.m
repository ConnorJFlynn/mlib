function [ARMtoken] = getARMusertoken
% [ARMtoken] = getARMusertoken

%% Checks whether username and token have already been saved in "ARMtoken.mat"  
% If so, load it and return in struct ARMtoken
tokenpath = [fileparts(which('setARMusertoken')),filesep];
tokenpath = strrep(tokenpath,[filesep filesep], filesep);
if isafile([tokenpath,'ARMtoken.mat'])
   ARMtoken = load([tokenpath,'ARMtoken.mat']);
else %Gets the userkey from: https://adc.arm.gov/armlive/register
   ARMtoken = setARMusertoken;
end
if isfield(ARMtoken,'ARMtoken')
   ARMtoken = ARMtoken.ARMtoken;
end
end