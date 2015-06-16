function [aos,fid] = read_cpcCCN_2006(filename);
%This reads ONLY the special file CpcCNN2006.amf containing corrected CPC and CCN counts...
% Don't use the flags, they are corrupt.
if ~exist('filename', 'var')||~exist(filename,'file')
   filename = getfullname('CpcCCN2006.amf','noaa_aos','Select a NOAA AOS a_ file.');
end
% Year, time,flag,N_cpc_corr,N_ccn_corr
% 2006,001.00000,0F00,99999.9,01090.8
fid = fopen(filename);
[pname, fname,ext] = fileparts(filename);
if fid>0
   aos.fname = [fname ext];
   format_str = ['%f %f %4s %f %f ']; 
   txt = textscan(fid,format_str,'headerlines',1,'delimiter',',');
   aos.station = 'AMF';
   aos.time = (datenum(txt{1}(:),1,1)+txt{2}(:)-1);
   aos.hex_flags = txt{3};
   aos.flags = uint32(hex2dec(txt{3}(:)));
   aos.cpc_corr = txt{4};
   aos.ccn = txt{5};
   NaNs = (aos.cpc_corr>99999) | (aos.ccn> 99999);
   aos.cpc_corr(NaNs) = NaN;
   aos.ccn(NaNs) = NaN;
   
   %    
%    [AinB,BinA] = nearest(aos.time, aos_flags.time');
%    aos.flags(AinB) = bitset(aos.flags(AinB),5,aos_flags.flags(BinA));
%    for ff = 5:length(label_str)
%       label_str{ff} = fliplr(deblank(fliplr(deblank(label_str{ff}))));
%       aos.(label_str{ff}) = txt{ff};
%    end
   fclose(fid);
else
   aos = [];
end


