cdfid = 0;
filenum = 0;
while cdfid > -1
  cdfid = getoldnc;
  if cdfid > 0
    filenum = filenum + 1;
    [name, records] = mexcdf('diminq', cdfid, 0);
    mean_diff = mean(diff(mexcdf('VARGET',cdfid,1,0,records)));

    %Max_altitude is attnum=3
    temp1 = mexcdf('attget', cdfid, -1, mexcdf('attname',cdfid, -1,3));
    for i = 1:length(temp1)
      temp2 = str2num(temp1(1:i));
      if length(temp2) > 0
        value = temp2;
      else 
        break;
      end;
    end;
    Max_alt = value;

   %Avg_int is attnum=5
    temp1 = mexcdf('attget', cdfid, -1, mexcdf('attname',cdfid, -1,5));
    for i = 1:length(temp1)
      temp2 = str2num(temp1(1:i));
      if length(temp2) > 0
        value = temp2;
      else 
        break;
      end;
    end;
    Avg_int = value;

   %Bin_size is attnum=6
    temp1 = mexcdf('attget', cdfid, -1, mexcdf('attname',cdfid, -1,6));
    for i = 1:length(temp1)
      temp2 = str2num(temp1(1:i));
      if length(temp2) > 0
        value = temp2;
      else 
        break;
      end;
    end;
    Bin_size = value;

    A(filenum,:) = [Max_alt, Avg_int, Bin_size, mean_diff]
    mexcdf('CLOSE', cdfid);
  end;
end;
global A;

