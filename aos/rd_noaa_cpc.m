function cpc = rd_noaa_cpc(infile);

if ~exist('infile','var')
    infile = getfullname_('N61_*','NOAA_AOS_raw','Select an N61 cpc file.');
end
if exist(infile,'file')
    %   Detailed explanation goes here
    fid = fopen(infile);
else
    disp('No valid file selected.')
    return
end

n = 1;
while ~feof(fid)
    this = fgetl(fid);
    if strfind(this,'N61a,')==1
        % N61a;STN;EPOCH;DateTime;F1_N61;F2_N61;N_N61
        A = textscan(this,'%s %s %f %s %f %f %f', 'delimiter',',');
        time_str = A{4};
        cpc.time(n) = datenum(time_str,'yyyy-mm-ddTHH:MM:SS');
        cpc.conc(n) = A{7};
         n = n+1;
    end
end
fclose(fid)
% cpc data in  N61_20140331T180302Z
% !row;colhdr;N61a,N61a;STN;EPOCH;DateTime;F1_N61;F2_N61;N_N61
% !row;mvc;N61a,N61a;ZZZ;0;9999-99-99T99:99:99Z;FFFF;FFFF;99999.9
% N61a,AMF,1396310640,2014-04-01T00:04:00Z,0000,0000,02388.7

% myriad flows that actually come from other files but for QL quality we'll
% use these nominal values.


dilution_flow = 11;
neph_flow = 29;
ccn_flow = 0.5;
psap_flow = 0.8;
clap_flow= 1.0;
cpc_flow =0.996;

sample_flow = (cpc_flow + clap_flow+psap_flow+neph_flow + ccn_flow+dilution_flow);
dcf = sample_flow/ (sample_flow - dilution_flow);

cpc.conc = cpc.conc*dcf;
return
