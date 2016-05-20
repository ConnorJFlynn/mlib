function [in] = rd_noaa_(infile);
% Read cleaned NOAA CLAP and PSAP data from Anne 2016
if ~exist('infile','var')
   infile = getfullname('SGP*psap*.csv','NOAA_edited_psap','Select an NOAA edited PSAP file.');
end
if exist(infile,'file')
   %   Detailed explanation goes here
   fid = fopen(infile);
else
   disp('No valid file selected.')
   return
end
% DateTimeUTC,F1_A11,F1_A12,F2_A11,F2_A12,
% BaB0_A11,BaB0_A12,BaG0_A11,BaG0_A12,BaR0_A11,BaR0_A12,BaO0_A11,BaO0_A12,  10-micron mode
% BaB1_A11,BaB1_A12,BaG1_A11,BaG1_A12,BaR1_A11,BaR1_A12,BaO1_A11,BaO1_A12,   1-micron mode
% BaB0g_A11,BaB0g_A12,BaG0g_A11,BaG0g_A12,BaR0g_A11,BaR0g_A12,BaO0g_A11,BaO0g_A12,
% BaB1g_A11,BaB1g_A12,BaG1g_A11,BaG1g_A12,BaR1g_A11,BaR1g_A12,BaO1g_A11,BaO1g_A12,

% Ff0_A11,Ff0_A12,Fn0_A12,IrB0_A11,IrB0_A12,IrG0_A11,IrG0_A12,IrR0_A11,IrR0_A12,L0_A11,L0_A12,Ff1_A11,Ff1_A12,Fn1_A12,IrB1_A11,IrB1_A12,IrG1_A11,IrG1_A12,IrR1_A11,IrR1_A12,L1_A11,L1_A12,Ff0g_A11,Ff0g_A12,Fn0g_A12,IrB0g_A11,IrB0g_A12,IrG0g_A11,IrG0g_A12,IrR0g_A11,IrR0g_A12,L0g_A11,L0g_A12,Ff1g_A11,Ff1g_A12,Fn1g_A12,IrB1g_A11,IrB1g_A12,IrG1g_A11,IrG1g_A12,IrR1g_A11,IrR1g_A12,L1g_A11,L1g_A12
% 9999-99-99T99:99:99Z;FFFF;FFFF;0;9999.99;9999.99;9999.99;9.9999999;9.9999999;9.9999999;99999.999;9999.99
fmt_str = ['%s %s %s %s %s %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f ' repmat('%f ',[1,60])]; % Date/time, "I"

header = fgetl(fid);
this = [];
while ~feof(fid) &&  (isempty(this)||strcmp(this(1),'!'))
   mark = ftell(fid);
   this = fgetl(fid);
end

if ~feof(fid)
   fseek(fid,mark,-1);
   A = textscan(fid,fmt_str, 'delimiter',',','EmptyValue',NaN);
end
fclose(fid);

ds = A{1}; ds = strrep(ds, '"','');
try
in.time = datenum(ds,'yyyy-mm-dd HH:MM:SS')
catch
    in.time = datenum(ds{1},'mm-dd-yy HH:MM')
end
in.Ba_B_10um_psap = A{6};in.Ba_B_10um_clap = A{7};
in.Ba_G_10um_psap = A{8};in.Ba_G_10um_clap = A{9};
in.Ba_R_10um_psap = A{10};in.Ba_R_10um_clap = A{11};
in.Ba_O_10um_psap = A{12};in.Ba_O_10um_clap = A{13};
in.Ba_B_1um_psap = A{14};in.Ba_B_1um_clap = A{15};
in.Ba_G_1um_psap = A{16};in.Ba_G_1um_clap = A{17};
in.Ba_R_1um_psap = A{18};in.Ba_R_1um_clap = A{19};
in.Ba_O_1um_psap = A{20};in.Ba_O_1um_clap = A{21};

figure; plot(serial2doys(in.time), [in.Ba_G_1um_psap,in.Ba_G_1um_clap],'.'); legend('PSAP 1um G','CLAP 1 um G')
figure; plot((in.time), [in.Ba_G_1um_psap,in.Ba_G_1um_clap],'.'); dynamicDateTicks; legend('PSAP 1um G','CLAP 1 um G')

% figure; plot(serial2doys(in.time), in.Ba_G_1um_psap,'.',serial2doys(in.time),in.Ba_G_10um_psap,'o'); legend('PSAP 1um G','PSAP 10 um G')

return
