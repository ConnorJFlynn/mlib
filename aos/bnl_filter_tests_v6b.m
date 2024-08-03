
function bnl_psap_filter_tests_v6(ss)
% Reorganizing. Read PSAPs first, then TAPs (manually?) ,then Neph & CAPS
% Then compute various properties for PSAPs and TAPs
% Then save mat file and csv files for each PSAP & TAP (which includes Bs,
% Bx converted to those wavelengths)
% Then produce 3 plots, one for each color, for PSAP + TAP, for Tr, Ba,
% And another plot, one per system (so 6 PSAP + 2 TAP) with RGB of same
% props above.
% Then as above for the various AAE pairs.
% v1: did not handle bad CAPS G period
% v2: compute extinction only from good caps WL, depending on date/time
% v3: catch case where there are not good CAPS valu
% v4: interpolate from CAPS R if G is not good instead of from B.  
% v4: apply fixed time grid to output ASCII file.
% v5: minor tweak to gridding logic for TAP files that extend beyond maxt
% v6: modifying read_psap_ir, read_psap3w_bnli and read_psap3w_bnlr to
% handle files devoid of non-missing values
% Must have forgotten to change the filename when going from v4 to v5.  
% Corrected the filename to bnl_filter_tests_v5 on 2019-08-08
if ~isavar('ss')
   ss = 60;
end
ss = 60;
dt = ss./(24*60*60);
ver = 6;
% PSAP SN 046
% C:\case_studies\BNL_PSAP_filter_tests\from_salwen\psap3wI_VM1-046
% ins_ = strrep(ins,[filesep,'dryneph',filesep],[filesep,'psap3wI_VM1-046',filesep]);
%bnllabVM1.046psap3wI.01s.00.20180711.030000.raw

outdir = getnamedpath('filter_study_out');

psap_046 = load(getfullname([outdir,'*.046psap3w*.mat'],'filter_study_out'));
psap_077 = load(getfullname([outdir,'*.077psap3w*.mat'],'filter_study_out'));
psap_090 = load(getfullname([outdir,'*.090psap3w*.mat'],'filter_study_out'));
psap_092 = load(getfullname([outdir,'*.092psap3w*.mat'],'filter_study_out'));
psap_107 = load(getfullname([outdir,'*.107psap3w*.mat'],'filter_study_out'));
psap_110 = load(getfullname([outdir,'*.110psap3w*.mat'],'filter_study_out'));
% tap_14 = load(getfullname([outdir,'*.mat'],'filter_study_out'));
% tap_15 = load(getfullname([outdir,'*.mat'],'filter_study_out'));

SN =          {'psap_046','psap_077','psap_090','psap_092','psap_107','psap_110', 'tap_14','tap_15'};
SN =          {'psap_046','psap_077','psap_090','psap_092','psap_107','psap_110'};
% SN =          {'psap_046','psap_077'};
filter_type = {'Azu','E70','EMF','SAV','Wha','E70'};
legs = {'046 Azumi', '077 E70', '090 Emfab', '092 Savil', '107 Whatman','110 E70'};
legs = SN;


% SN =          {'tap_14','tap_15'};
mint = []; maxt = [];
for sn = 1:length(SN)
   NNN = SN{sn};
   psap = eval(NNN);
   mint = min([mint, psap.time(1)]);
   maxt = max([maxt, psap.time(end)]);
end
% mint = max([mint,datenum('2018-07-23 16:31','yyyy-mm-dd HH:MM')]);datestr(mint)
% maxt = min([maxt, datenum('2018-08-06 13:51','yyyy-mm-dd HH:MM')]); datestr(maxt)

mint = max([mint,datenum('2018-09-24 17:40','yyyy-mm-dd HH:MM')]);datestr(mint)
maxt = min([maxt, datenum('2018-09-27 12:40','yyyy-mm-dd HH:MM')]); datestr(maxt)

 out_time = [mint: (1/(24*60*60)) : maxt]'; outs = length(out_time);
 outdir = getnamedpath('filter_study_out');

 
for sn = 1:length(SN)
   NNN = SN{sn};
   psap = eval(NNN);
   title_str = [NNN];
   clear out; pair = NaN([outs,2]); p = 1;  
   jj = 1;   ii = 1; ds = round((psap.time(ii)-out_time(jj))*24*60*60);
   while ds<0 && ii<length(psap.time)
      ii = ii+1;ds = round((psap.time(ii)-out_time(jj))*24*60*60);
   end
   while ii<length(psap.time) && psap.time(ii)<=maxt      
      while ds>0 &&(jj<outs)
         jj = jj+1; 
         ds = round((psap.time(ii)-out_time(jj))*24*60*60);
      end
      pair(p,:) = [jj,ii]; p = p+1;
      ii = ii +1;
      ds = round((psap.time(ii)-out_time(jj))*24*60*60);  
      if mod(ii,10000)==0
         disp(ii)
      end
   end
   [paired,ij] = unique(pair(:,1)); paired(:,2)= pair(ij,2);
   nans = isnan(paired(:,1)); paired(nans,:) = [];
   nans = isnan(paired(:,2));paired(nans,:) = [];
   fields = fieldnames(psap);
   ts = size(psap.time);
   for fld = 1:length(fields)
      field = fields{fld};
      if all(size(psap.(field))==ts)
         bloop = NaN.*out_time;
         out.(field) = bloop;
         out.(field)(paired(:,1)) = psap.(field)(paired(:,2));
      else
         out.(field) = psap.(field);
      end
   end
   out.time = out_time;
   disp(['Writing ',NNN])
      file_out = ['filter_test.',NNN,'.from_',datestr(out.time(1),'yyyymmdd_HHMM')...
      ,'-',datestr(out.time(end),'yyyymmdd_HHMM'),'.v',num2str(ver),'.csv'];
   tic
   write_out_csv(out, file_out);
   toc
end
return

function ins_ = fix_file_timestamp(ins_)
for L = length(ins_):-1:1;
   [pname, fstem,x] = fileparts(ins_{L});
   G = textscan(fstem,'%s','delimiter','.'); G = G{1};
   time_str = ['.',G{6},'.'];
   time_str00 = time_str; time_str00(6:7) = '00';
   time_str01 = time_str; time_str01(6:7) = '01';
   time_str02 = time_str; time_str02(6:7) = '02';
   time_str03 = time_str; time_str03(6:7) = '03';
   time_str04 = time_str; time_str04(6:7) = '04';
   if ~isafile(ins_{L})
      if isafile(strrep(ins_{L},time_str,time_str00))
         ins_(L) = {strrep(ins_{L},time_str,time_str00)};
      elseif isafile(strrep(ins_{L},time_str,time_str01))
         ins_(L) = {strrep(ins_{L},time_str,time_str01)};
      elseif isafile(strrep(ins_{L},time_str,time_str02))
         ins_(L) = {strrep(ins_{L},time_str,time_str02)};
      elseif isafile(strrep(ins_{L},time_str,time_str03))
         ins_(L) = {strrep(ins_{L},time_str,time_str03)};
      elseif isafile(strrep(ins_{L},time_str,time_str04))
         ins_(L) = {strrep(ins_{L},time_str,time_str04)};
      else
         ins_(L) = [];
      end
   end
end

return
function write_out_csv(psap, file_out)
outdir = getnamedpath('filter_study_out');
fields = fieldnames(psap);
yyyy = datestr(psap.time,'yyyy-mm-dd'); HHMM = datestr(psap.time,'HH:MM:SS');
fid = fopen([outdir,file_out],'w');
for f = 1:length(fields)
   fld = fields{f};
   if all(size(psap.(fld))==1)&&~iscell(psap.(fld))
      fprintf(fid,'%% %s: %d \n',fld,psap.(fld));
   end
end

% outfield = fields;
% for f = length(fields):-1:1
%    fld = outfield{f};
%    if ~all(size(psap.(fld))==size(psap.time)) || strcmp(fld,'time') || ~isfloat(psap.(fld))
%       outfield(f) = [];
%    end
% end
outfield = [   {'flow_SLPM'          }
   {'flow_smooth'        }
   {'dV_ss'              }
   {'dL_ss'              }
   {'transmittance_blue' }
   {'transmittance_green'}
   {'transmittance_red'  }
   {'Tr_B_ss'            }
   {'Tr_G_ss'            }
   {'Tr_R_ss'            }
   {'Ba_B_raw'           }
   {'Ba_G_raw'           }
   {'Ba_R_raw'           }
   {'Weiss_f_B'          }
   {'Weiss_f_G'          }
   {'Weiss_f_R'          }
   {'Ba_B_Weiss'         }
   {'Ba_G_Weiss'         }
   {'Ba_R_Weiss'         }
   {'Bs_B_unc'           }
   {'Bs_G_unc'           }
   {'Bs_R_unc'           }
   {'Ba_B_Bond'          }
   {'Ba_G_Bond'          }
   {'Ba_R_Bond'          }
   {'Bs_B'               }
   {'Bs_G'               }
   {'Bs_R'               }
   {'Ba_B_Virk_Sca'      }
   {'Ba_G_Virk_Sca'      }
   {'Ba_R_Virk_Sca'      }
   {'AAE_BG_raw'         }
   {'AAE_BG_Weiss'       }
   {'AAE_BG_Bond'        }
   {'AAE_BG_Virk_Sca'    }
   {'AAE_BR_raw'         }
   {'AAE_BR_Weiss'       }
   {'AAE_BR_Bond'        }
   {'AAE_BR_Virk_Sca'    }
   {'AAE_GR_raw'         }
   {'AAE_GR_Weiss'       }
   {'AAE_GR_Bond'        }
   {'AAE_GR_Virk_Sca'    }
   {'Bx_B'               }
   {'Bx_G'               }
   {'Bx_R'               }
   {'Ba_B_Virk_Ext'      }
   {'Ba_G_Virk_Ext'      }
   {'Ba_R_Virk_Ext'      }
   {'AAE_BG_Virk_Ext'    }
   {'AAE_BR_Virk_Ext'    }
   {'AAE_GR_Virk_Ext'    }];
out_str = [   {', %1.3f'          }
   {', %1.3f'        }
   {', %1.3f'              }
   {', %1.3f'              }
   {', %1.7f' }
   {', %1.7f'}
   {', %1.7f'  }
   {', %1.7f'            }
   {', %1.7f'            }
   {', %1.7f'            }
   {', %1.3f'           }
   {', %1.3f'           }
   {', %1.3f'           }
   {', %1.2f'          }
   {', %1.2f'          }
   {', %1.2f'          }
   {', %1.3f'         }
   {', %1.3f'         }
   {', %1.3f'         }
   {', %1.3f'           }
   {', %1.3f'           }
   {', %1.3f'           }
   {', %1.3f'          }
   {', %1.3f'          }
   {', %1.3f'          }
   {', %1.3f'               }
   {', %1.3f'            }
   {', %1.3f'               }
   {', %1.3f'      }
   {', %1.3f'      }
   {', %1.3f'      }
   {', %1.3f'         }
   {', %1.3f'       }
   {', %1.3f'        }
   {', %1.3f'    }
   {', %1.3f'         }
   {', %1.3f'       }
   {', %1.3f'        }
   {', %1.3f'    }
   {', %1.3f'         }
   {', %1.3f'       }
   {', %1.3f'        }
   {', %1.3f'    }
   {', %1.3f'               }
   {', %1.3f'               }
   {', %1.3f'               }
   {', %1.3f'      }
   {', %1.3f'      }
   {', %1.3f'      }
   {', %1.3f'    }
   {', %1.3f'    }
   {', %1.3f'    }];
fprintf(fid,['yyyy-mm-dd, HH:MM:SS',repmat(', %s',[1,length(outfield)]), '\n'], outfield{:});
all_t = length(psap.time);
for t = 1:all_t;
   fprintf(fid,['%s, %s'],yyyy(t,:), HHMM(t,:));
   for f = 1:length(outfield)
      fld = outfield{f};
      fprintf(fid,out_str{f},psap.(fld)(t));
   end
   fprintf(fid,'\n');
   if mod(t,1000)==0
      disp(num2str(all_t - t));
   end
end
fclose(fid)
return

