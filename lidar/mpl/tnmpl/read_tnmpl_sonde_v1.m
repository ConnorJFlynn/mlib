function sonde = read_tnmpl_sonde_v1(filename);
%%

if ~exist('filename', 'var')
    [fname, pname] = uigetfile('C:\case_studies\tnmpl\sondes\*.txt');
    filename = [pname, fname];
end

fid = fopen(filename);
%%
%   Record name:    Unit:           Data type:          Divisor: Offset:
%    ---------------------------------------------------------------------
%     time            sec             float (4)          1        0       
%     Pscl            ln              short (2)          1        0       
%     T               K               short (2)          10       0       
%     RH              %               short (2)          1        0       
%     v               m/s             short (2)          -100     0       
%     u               m/s             short (2)          -100     0       
%     Height          m               short (2)          1        30000   
%     P               hPa             short (2)          10       0       
%     TD              K               short (2)          10       0       
%     MR              g/kg            short (2)          100      0       
%     DD              dgr             short (2)          1        0       
%     FF              m/s             short (2)          10       0       
%     AZ              dgr             short (2)          1        0       
%     Range           m               short (2)          0.01     0       
%     Lon             dgr             short (2)          100      0       
%     Lat             dgr             short (2)          100      0       
%     SpuKey          bitfield        unsigned short (2) 1        0       
%     UsrKey          bitfield        unsigned short (2) 1        0       
%     RadarH          m               short (2)          1        30000   

[pname, fname, ext] = fileparts(filename);
base_time = datenum(fname, 'yyyymmddHHMM');
txt = textscan(fid,'%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f','headerlines',39,'delimiter','\t');
sonde.time = txt{1} + datenum(fname, 'yyyymmddHHMM') -1;
sonde.T_K = txt{3};
sonde.RH = txt{4};
sonde.v = txt{5};
sonde.u = txt{6};
sonde.alt = txt{7};
sonde.P_mB = txt{8};
sonde.dewpoint = txt{9};
sonde.MR = txt{10};
sonde.driftdirection = txt{11};
sonde.FF = txt{12};
sonde.AZ = txt{13};
sonde.Range = txt{14};
sonde.lon = txt{15};
sonde.lat = txt{16};
return;