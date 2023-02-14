function [ARMrawtoken] = getARMrawtoken
% [ARMtoken] = getARMrawtoken
% Saves the userkey for ADRSWS provided by Karen
if isafile([getfilepath('tokenpath'),'ARMrawtoken.mat'])
   ARMrawtoken = load(getfullname('ARMrawtoken.mat','tokenpath'));
else
   rawtok = input('Enter ARM raw token:','s');
   ARMrawtoken = rawtok;
   disp(ARMrawtoken);
   tokenpath = getfilepath('tokenpath','set ARMrawtoken path',true);
   save([tokenpath,'ARMrawtoken.mat'],'ARMrawtoken');
end
if isfield(ARMrawtoken,'ARMrawtoken')
   ARMrawtoken = ARMrawtoken.ARMrawtoken;
end
end