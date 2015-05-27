function gen = read_AMF1_gen_log
% gen = read_AMF1_gen_log
fid = fopen('D:\Genset_operating.dat.txt','r');
A = textscan(fid,'%s %f %f %f %f','headerlines',5,'delimiter',',','treatasempty','"NAN"','emptyvalue',NaN);
% "TIMESTAMP","RECORD","PTemp","batt_V","Gen_V"

fclose(fid);

t_str = A{1}; t_str = strrep(t_str,'"','');
gen.time = datenum(t_str,'yyyy-mm-dd HH:MM:SS');
gen.recordN = A{2};
gen.PTemp = A{3};
gen.batt_V = A{4};
gen.mV = A{5};
gen.ON = gen.mV>15;
% figure; plot(gen.time, gen.mV,'.',gen.time(gen.ON), gen.mV(gen.ON),'r.');


return



