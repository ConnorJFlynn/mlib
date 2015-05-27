profsize = 836;
bins = 200;
fid = getfile('*.1*');
fidstart = ftell(fid);
fseek(fid,0,1);
fidend = ftell(fid);
fseek(fid,0,-1);
numprofs = fix((fidend-fidstart)/profsize);
if(numprofs ~= (fidend-fidstart)/profsize))
  disp('Bad file format, not integral number of profiles.')
  break;
else
  disp('Good file format...')
  bigarray = zeros(profsize,((fidend-fidstart)/profsize));
  bigarray(:) = fread(fid);
end;
  ID = bigarray(1,:);
  bigarray(1,:) = [];

  date = bigarray(3,:) + 100*bigarray(2,:) + 100^2*bigarray(1,:);
  bigarray(1:3,:) = [];

  time = bigarray(4,:)/100 + bigarray(3,:) + 100*bigarray(2,:) + 100^2*bigarray(1,:);
  bigarray(1:4,:) = [];

  shots_summed = bigarray(4,:) + 256*bigarray(3,:) + 256^2*bigarray(2,:) + 256^3*bigarray(1,:);
  bigarray(1:4,:) = [];

  PRF = bigarray(2,:) + 256*bigarray(1,:);
  bigarray(1:2,:) = [];

  e_monitor = (bigarray(2,:) + 256*bigarray(1,:))/1000;
  bigarray(1:2,:) = [];

  detector_temp = (bigarray(2,:) + 256*bigarray(1,:))/100;
  bigarray(1:2,:) = [];

  filter_temp = (bigarray(2,:) + 256*bigarray(1,:))/100;
  bigarray(1:2,:) = [];

  case_temp = (bigarray(2,:) + 256*bigarray(1,:))/100;
  bigarray(1:2,:) = [];

  laser_temp = (bigarray(2,:) + 256*bigarray(1,:))/100;
  bigarray(1:2,:) = [];

  V_10 = (bigarray(2,:) + 256*bigarray(1,:))/1000;
  bigarray(1:2,:) = [];

  V_5 = (bigarray(2,:) + 256*bigarray(1,:))/1000;
  bigarray(1:2,:) = [];

  V_15 = (bigarray(2,:) + 256*bigarray(1,:))/1000;
  bigarray(1:2,:) = [];

  cbh = bigarray(2,:) + 256*bigarray(1,:);
  bigarray(1:2,:) = [];

  bkgnd = bigarray(4,:) + 256*bigarray(3,:) + 256^2*bigarray(2,:) + 256^3*bigarray(1,:);
  bigarray(1:4,:) = [];

profbins = zeros(4,bins*numprofs);
profbins(:) = bigarray(1:bins,:);
profbins(1,:) = profbins(4,:) + 256*profbins(3,:) + 256^2*profbins(2,:) + 256^3*profbins(1,:);
raw = zeros(bins,numprofs);
raw(:) = profbins;
whos