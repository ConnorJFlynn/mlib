function trh = rd_trh_govee(fname)
while ~isavar('fname')||~isafile(fname)
   fname = getfullname('H5074*.csv','govee','Select Govee TRH file:');
end
fid = fopen(fname,'r');

A = textscan(fid,'%s %f %f','delimiter',',','HeaderLines',1);

trh.time = datenum(A{1},'yyyy-mm-dd HH:MM:SS');
trh.T_F = A{2};
trh.T_C = (trh.T_F - 32).*5./9;
trh.RH = A{3};
trh.T_dp = calc_dp(trh.T_C, trh.RH)-273.15;

end