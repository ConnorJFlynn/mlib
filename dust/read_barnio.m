function barn = read_barnio(filename);
%This reads Jim Barnard's Io files from Niamey and Banizoumbou.  Not fully tested...
if ~exist('filename', 'var')||~exist(filename,'file')
   [fid,fname, pname] = getfile('*.txt','barnio');
   fclose(fid);
   filename = [pname, fname];
end
% No header, time is yyyy.ffff followed by five columns of Io values 
fid = fopen(filename);
if fid>0
   format_str = '%f %f %f %f %f %f ';
   txt = textscan(fid,format_str);
end
fclose(fid);
% txt{1} = round(txt{1}*1e4)/1e4;
barn.time = datenum(txt{1},1,1)-1./24;
barn.filter1_Vo = txt{2};
barn.filter2_Vo = txt{3};
barn.filter3_Vo = txt{4};
barn.filter4_Vo = txt{5};
barn.filter5_Vo = txt{6};
