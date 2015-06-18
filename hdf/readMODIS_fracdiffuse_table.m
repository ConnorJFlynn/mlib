function [table_AOD,table_SZA,table_fracdiffuse]=readMODIS_fracdiffuse_table
%readMODIS_fracdiffuse_table.m
table_AOD=[0:0.02:0.98];
fidrd=fopen('c:\johnmatlab\MODIS surface albedo\skyl_lut_bbshortwave.dat');
for i=1:2,
    linetext=fgetl(fidrd);
end
[A,count]=fscanf(fidrd,'%f',[51,inf]);
fclose(fidrd);
table_SZA=A(1,:);
table_fracdiffuse=A(2:51,:);
clear A

flag_plot='no';
if strcmp(flag_plot,'yes')
    figure
    plot(table_SZA,table_fracdiffuse,'-')
    set(gca,'fontsize',16)
    xlabel('SZA (deg)','fontsize',20)
    ylabel('Diffuse fraction','fontsize',20)
    title('broadband SW (0.25-4.0 \mum) for AOD:[0:0.02:0.98]','fontsize',14)
end