function [aos,fid] = read_ds_2006(filename);
%This reads ONLY the special file ds_2006.amf containing raw CNC and supersats...
if ~exist('filename', 'var')||~exist(filename,'file')
   filename = getfullname('ds_2006.amf','noaa_aos','Select a NOAA AOS a_ file.');
end
% Stn,year,time,N_ccn_raw,calc_%SS
% AMF,2006,001.00001,00639.09,00.638
fid = fopen(filename);
[pname, fname,ext] = fileparts(filename);
if fid>0
   aos.fname = [fname ext];
   format_str = ['%3s %f %f %f %f ']; 
   txt = textscan(fid,format_str,'headerlines',1,'delimiter',',');
   aos.station = char(txt{1}(1));
   aos.time = (datenum(txt{2}(:),1,1)+txt{3}(:)-1);
   aos.N_ccn_raw = txt{4};
   aos.supersat_calc = txt{5};
   NaNs = (aos.supersat_calc>2) | (aos.N_ccn_raw> 7e4);
   aos.N_ccn_raw(NaNs) = NaN;
   aos.supersat_calc(NaNs) = NaN;
   
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


