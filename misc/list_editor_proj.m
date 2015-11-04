function [listing,pname] = list_editor_proj;
% lists the editor project files ('*.ed and *.prev)

[listing,pname] = dir_('*.ed; *.prev','editor_projs');
%     projname = [prefdir,filesep,'MATLABDesktop.xml.prev'];
AZ = [1:length(listing)];
for n = length(AZ):-1:1
    dates(n) = listing(n).datenum;
end
[age,ij] = sort(dates);
done = false
while ~done
    OK = menu('Sort by: ','A-Z','By date','DONE');
    if OK==1
        ord = AZ;
    elseif OK==2
        ord = ij;
    end    
    if OK==3
        done = true;
    else
        
        for n = AZ
            disp([datestr(listing(ord(n)).datenum,'yyyy-mm-dd HH:MM   '),listing(ord(n)).name]);
        end
    end
end

return

