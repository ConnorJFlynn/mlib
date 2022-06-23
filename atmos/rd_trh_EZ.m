function trh = rd_trh_EZ(fname)
while ~isavar('fname')||~isafile(fname)
   fname = getfullname('EZ_TRH*.txt','EZ_TRH','Select EZ_TRH file:');
end
fid = fopen(fname,'r');
headr = fgetl(fid);
A = textscan(fid,'%*d %s %f %f %f %*[^\n]','delimiter',',');
fclose(fid)
trh.time = datenum(A{1},'yyyy-mm-dd HH:MM:SS');

if foundstr(headr,'Celcius')
   trh.T_C = A{2}; trh.T_F = trh.T_C.*9./5 - 32;
   trh.RH = A{3};
   trh.T_dp_EZ = A{4};
else
   trh.T_F = A{2}; trh.T_C = (trh.T_F - 32).*5./9;
   trh.RH = A{3};
   trh.T_dp_EZ = (A{4}-32).*5./9;
end
trh.T_dp = calc_dp(trh.T_C, trh.RH)-273.15;

end