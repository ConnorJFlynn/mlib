function [SUCCESS,MESSAGE,MESSAGEID] = recover_prev
% recovers previous editor state to recover from inadvertently close
prevname = [prefdir,filesep,'MATLABDesktop.xml.prev']
n = 1;
while exist(prevname,'file')
    n = n +1;
    prevname = [prefdir,filesep,'MATLABDesktop.xml.prev',num2str(n)];
end
copyfile([prefdir,filesep,'MATLABDesktop.xml'],prevname);
[SUCCESS,MESSAGE,MESSAGEID] = copyfile([prefdir,filesep,'MATLABDesktop.xml.prev'],[prefdir,filesep,'MATLABDesktop.xml'],'f');
return