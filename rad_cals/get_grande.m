function rad = get_grande(in);
% rad = get_grande(in);

if ~exist('in','var')
    in = ['C:\case_studies\radiation_cals\spheres\GSFC_Grande\20130523_Grande.txt'];
else
    while exist(in,'dir')
        in = getfullname([in,filesep,'*.txt'],'radcals','Select a calibrated radiance file');
    end
    
end
fid = fopen(in);
in_line = fgetl(fid);
while isempty(strfind(in_line,'Data:'))&&~feof(fid)
    in_line = fgetl(fid);
end
while (isempty(strfind(in_line,'lamps'))&&isempty(strfind(in_line,'lamp'))&&(isempty(strfind(in_line,'Lamps'))&&isempty(strfind(in_line,'Lamp'))))&&~feof(fid)
    in_line = fgetl(fid);
end
mark = ftell(fid);
first_row = fgetl(fid);
fseek(fid,mark,-1);
tmp = textscan(first_row,'%f ');
tmp = textscan(fid,repmat('%f ',[1,length(tmp{:})]));
%
fclose(fid);
%%
lamps = strrep(in_line,'lamps','');lamps = strrep(lamps,'lamp','');
lamps = strrep(in_line,'Lamps','');lamps = strrep(lamps,'Lamp','');
mult = findstr(lamps,'1');
if length(mult)>1
lamps = lamps(1:(mult(2)-1));
end
lamps = textscan(lamps,'%s');lamps = lamps{:};
rad.nm = tmp{1};
for lmp = 1:length(lamps)
   lamp = strrep(lamps{lmp},'.','p');
   rad.(['lamps_',lamp]) = tmp{lmp+1};
end
% rad.lamps_8 = tmp{2};
% rad.lamps_7 = tmp{3};
% rad.lamps_6 = tmp{4};
% rad.lamps_5 = tmp{5};
% rad.lamps_4 = tmp{6};
% rad.lamps_3 = tmp{7};
% rad.lamps_2 = tmp{8};
% rad.lamps_1 = tmp{9};
% if length(tmp)>9
%     rad.lamps_1_att_100 = tmp{10};
%     rad.lamps_1_att_50 = tmp{11};
%     rad.lamps_1_att_30 = tmp{12};
% end

while isNaN(rad.nm(end))
    fld = fieldnames(rad); 
    for ff = 1:length(fld)
        rad.(fld{ff})(end) = [];
    end
%     rad.nm(end) = [];
%     rad.lamps_8(end) = [];
%     rad.lamps_7(end) = [];
%     rad.lamps_6(end) = [];
%     rad.lamps_5(end) = [];
%     rad.lamps_4(end) = [];
%     rad.lamps_3(end) = [];
%     rad.lamps_2(end) = [];
%     rad.lamps_1(end) = [];
%     if length(tmp)>9
%         rad.lamps_1_att_100(end) = [];
%         rad.lamps_1_att_50(end) = [];
%         rad.lamps_1_att_30(end) = [];
%     end
end
rad.units = 'W/(m^2.sr.um)';
return