function [serial] = epoch2serial(epoch);

  DAYS_TO_1970 = 719529;
  SEC_PER_DAY  = 86400;

  index = (epoch / SEC_PER_DAY);
  serial = index + DAYS_TO_1970;