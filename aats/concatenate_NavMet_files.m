%concatenate_ICARTT_J31_NavMet_files.m
clear
close all

pathname='c:\beat\data\alive\navmet\20050910\';
D=dir(strcat(pathname,'*.txt'));

fidwrt=fopen([pathname 'concat.txt'],'w');

for i=1:length(D),
    if D(i).bytes>0
        fid=fopen([pathname D(i).name]);
        for j=1:10000,
         fline=fgetl(fid);%fgets(fid);
         if fline==-1 break; end
         if ~isempty(fline)
             fprintf(fidwrt,'%s\r\n',fline);
         end
        end
        fclose(fid)
    end
end

fclose(fidwrt)