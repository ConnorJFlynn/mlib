function [ma, raw] = rd_ma(infile);

if ~isavar('infile')
   infile = getfullname('MA350*.csv','ma_amice','Select MA-350 from AMICE.');
end

if iscell(infile)&&length(infile)>1
   [ma, raw] = rd_ma(infile{1});
   raw.time = ma.time; ma.fname = raw.fname;
   [ma2, raw2] = rd_ma(infile(2:end));
   raw2.time = ma2.time;ma2.fname = raw2.fname;
   %    ma_.fname = unique([ma.fname,ma2.fname]);
   raw_.fname = unique([raw.fname, raw2.fname]);
   raw = cat_timeseries(raw, raw2);raw.fname = raw_.fname;
   ma = cat_timeseries(ma, ma2); ma.fname = raw.fname; ma.pname = raw.pname;
else
   if iscell(infile); infile = infile{1}; end
   if isafile(infile)
      [raw.pname,raw.fname, ext] = fileparts(infile); raw.fname = [raw.fname, ext];
      if iscell(raw.fname)
         raw.fname = raw.fname{1};
      end
      [~, fname] = fileparts(raw.fname);

      raw.pname = {[raw.pname, filesep]}; raw.fname = {[raw.fname, ext]};
      ma.fname = raw.fname; ma.pname = raw.pname;
      %   Raw MA-350 format:
      %       "Serial number","Datum ID","Session ID","Data format version","Firmware version","App version","Date / time local","Timezone offset (mins)","Date local (yyyy/MM/dd)","Time local (hh:mm:ss)","GPS lat (ddmm.mmmmm)","GPS long (dddmm.mmmmm)","GPS speed (km/h)","GPS sat count","Timebase (s)","Status","Battery remaining (%)","Accel X","Accel Y","Accel Z","Tape position","Flow setpoint (mL/min)","Flow total (mL/min)","Flow1 (mL/min)","Flow2 (mL/min)","Sample temp (C)","Sample RH (%)","Sample dewpoint (C)","Internal pressure (Pa)","Internal temp (C)","Optical config","UV Sen1","UV Sen2","UV Ref","UV ATN1","UV ATN2","UV K","Blue Sen1","Blue Sen2","Blue Ref","Blue ATN1","Blue ATN2","Blue K","Green Sen1","Green Sen2","Green Ref","Green ATN1","Green ATN2","Green K","Red Sen1","Red Sen2","Red Ref","Red ATN1","Red ATN2","Red K","IR Sen1","IR Sen2","IR Ref","IR ATN1","IR ATN2","IR K","UV BC1","UV BC2","UV BCc","Blue BC1","Blue BC2","Blue BCc","Green BC1","Green BC2","Green BCc","Red BC1","Red BC2","Red BCc","IR BC1","IR BC2","IR BCc","Readable status","UV BC1 smoothed  (ng/m^3)","UV BCc smoothed  (ng/m^3)","Blue BC1 smoothed  (ng/m^3)","Blue BCc smoothed  (ng/m^3)","IR BC1 smoothed  (ng/m^3)","IR BCc smoothed  (ng/m^3)","Cref","AAE biomass","AAE fossil fuel","Biomass BCc  (ng/m^3)","Fossil fuel BCc  (ng/m^3)","AAE","BB (%)","Delta-C  (ng/m^3)","Pump drive","Reporting Temp (C)","Reporting Pressure (Pa)","WiFi RSSI"
      %       "MA350-0492","3924","16","3","1.13","1.6","2024-07-25T21:07:00","0","2024/07/25","21:07:00","36.60542833805084","-97.48571193218231","0.1","9","60","131138","100","-446","-361","-536","1","150","150.17","117.09","33.09","29.98","31.2","11.13","98304","30.75","DUALSPOT-UV-BLUE-GREEN-RED-IR","917007","785432","881594","0.000000","0.000000","0.000000","942950","862471","851722","0.000000","0.000000","0.000000","927914","867603","877318","0.000000","0.000000","0.000000","954475","899531","961651","0.000000","0.000000","0.000000","788804","867526","931066","0.000000","0.000000","0.000000","","","","","","","","","","","","","","","","Start up-DualSpot on-Ext. power","","","","","","","1.30","2.00","1.00","","","","","","217","24.514999389648438","1.408178839784652e-40","-127"
      %        "MA350-0492","3930","16","3","1.13","1.6","2024-07-25T21:13:00","0","2024/07/25","21:13:00","36.60538601875305","-97.48563942313194","0.1","9","60","131136","100","267","-235","794","1","150","150.17","116.64","33.53","30.49","26.8","9.29","98280","31.31","DUALSPOT-UV-BLUE-GREEN-RED-IR","914041","783352","879517","0.027805","0.005956","0.000000","945865","865192","854584","0.003314","0.000256","0.000000","908387","849304","859038","0.001377","-0.000397","0.000000","955048","900033","962439","0.003399","0.001811","0.000000","787495","866573","930004","0.019481","-0.000409","0.000000","195","193","195","12","-148","12","3","61","3","73","112","73","341","-66","341","DualSpot on-Ext. power","253","253","40","40","419","419","1.30","2.00","1.00","0","419","-2.74","0","-166","211","24.514999389648438","1.408178839784652e-40","-127"

      fmt_str =  ['%s         %f    %f   %f   %f     %f     %s                 %f    %s            %s         %f                      %f             %f   %f  %f    %f       %f     %f    %f      %f   %f   %f     %f      %f        %f     %f      %f      %f     %f      %f         %s                             %f       %f       %f        %f        %f         %f        %f       %f       %f         %f        %f        %f        %f         %f        %f        %f         %f         %f       %f        %f      %f        %f         %f         %f        %f      %f        %f         %f        %f        %f         %f   %f     %f   %f     %f    %f  %f  %f  %f  %f     %f   %f   %f   %f    %f      %s                     %f    %f    %f   %f    %f   %f    %f     %f      %f     %f  %f    %f   %f    %f     %f     %f                    %f                     %f '];
      fmt_str = strrep(fmt_str,' ','');fmt_str = strrep(fmt_str,'%',' %');
      fid = fopen(infile);
      hdr = fgetl(fid); hdr = strrep(hdr,'"',''); hdr = strrep(hdr,' ','');
      tmp = char(fread(fid,'char'))'; tmp = strrep(tmp,'"','');tmp = strrep(tmp,' ','');
      % start = ftell(fid); fseek(fid,start,-1)
      labls = textscan(hdr,'%s','delimiter',','); labls = labls{:};
      test2 = textscan(tmp,[fmt_str, '%*[^\n]'],'delimiter',',','EmptyValue',NaN);
      raw.time = datenum(test2{7},'yyyy-mm-ddTHH:MM:SS');
      for L = 1:length(labls)
         lab = legalize_fieldname(labls{L});
         raw.(lab) = test2{L};
      end
      raw.nm = [375, 470, 528, 625, 880];
      ma.time = raw.time;
      ma.nm = raw.nm;
      ma.lat = raw.GPSlat_lpar_ddmmmmmmm_rpar_;
      ma.lon = raw.GPSlong_lpar_dddmmmmmmm_rpar_;
      ma.status = raw.Status;
      ma.tape = raw.Tapeposition;
      ma.flow_setpt = raw.Flowsetpoint_lpar_mL_fslash_min_rpar_;
      ma.flow1       = raw.Flow1_lpar_mL_fslash_min_rpar_;
      ma.flow2 = raw.Flow2_lpar_mL_fslash_min_rpar_;
      ma.flow_tot = raw.Flowtotal_lpar_mL_fslash_min_rpar_;
      ma.Sen1(:,5) = raw.IRSen1; ma.Sen1(:,4) = raw.RedSen1; ma.Sen1(:,3) = raw.GreenSen1;  ma.Sen1(:,2) = raw.BlueSen1;  ma.Sen1(:,1) = raw.UVSen1;
      ma.Sen2(:,5) = raw.IRSen2; ma.Sen2(:,4) = raw.RedSen2; ma.Sen2(:,3) = raw.GreenSen2;  ma.Sen2(:,2) = raw.BlueSen2;  ma.Sen2(:,1) = raw.UVSen2;
      ma.Ref(:,5) = raw.IRRef; ma.Ref(:,4) = raw.RedRef; ma.Ref(:,3) = raw.GreenRef;  ma.Ref(:,2) = raw.BlueRef;  ma.Ref(:,1) = raw.UVRef;
      ma.ATN1(:,5) = raw.IRATN1; ma.ATN1(:,4) = raw.RedATN1; ma.ATN1(:,3) = raw.GreenATN1;  ma.ATN1(:,2) = raw.BlueATN1;  ma.ATN1(:,1) = raw.UVATN1;
      ma.ATN2(:,5) = raw.IRATN2; ma.ATN2(:,4) = raw.RedATN2; ma.ATN2(:,3) = raw.GreenATN2;  ma.ATN2(:,2) = raw.BlueATN2;  ma.ATN2(:,1) = raw.UVATN2;
      ma.K(:,5) = raw.IRK; ma.K(:,4) = raw.RedK; ma.K(:,3) = raw.GreenK;  ma.K(:,2) = raw.BlueK;  ma.K(:,1) = raw.UVK;
      ma.BC1(:,5) = raw.IRBC1; ma.BC1(:,4) = raw.RedBC1; ma.BC1(:,3) = raw.GreenBC1;  ma.BC1(:,2) = raw.BlueBC1;  ma.BC1(:,1) = raw.UVBC1;
      ma.BC2(:,5) = raw.IRBC2; ma.BC2(:,4) = raw.RedBC2; ma.BC2(:,3) = raw.GreenBC2;  ma.BC2(:,2) = raw.BlueBC2;  ma.BC2(:,1) = raw.UVBC2;
      ma.BCc(:,5) = raw.IRBCc; ma.BCc(:,4) = raw.RedBCc; ma.BCc(:,3) = raw.GreenBCc;  ma.BCc(:,2) = raw.BlueBCc;  ma.BCc(:,1) = raw.UVBCc;
      ma.BC1_sm(:,5) = raw.IRBC1smoothed_lpar_ng_fslash_m_caret_3_rpar_; ma.BC1_sm(:,1) = raw.UVBC1smoothed_lpar_ng_fslash_m_caret_3_rpar_;
      ma.BC1_sm(:,2) = raw.BlueBC1smoothed_lpar_ng_fslash_m_caret_3_rpar_;
      ma.BCc_sm(:,5) = raw.IRBCcsmoothed_lpar_ng_fslash_m_caret_3_rpar_; ma.BCc_sm(:,1) = raw.UVBCcsmoothed_lpar_ng_fslash_m_caret_3_rpar_;
      ma.BCc_sm(:,2) = raw.BlueBCcsmoothed_lpar_ng_fslash_m_caret_3_rpar_;
      ma.Cref = raw.Cref; 
      ma.BCc_biomass = raw.BiomassBCc_lpar_ng_fslash_m_caret_3_rpar_; ma.BCc_fossilfuel = raw.FossilfuelBCc_lpar_ng_fslash_m_caret_3_rpar_;
      ma.AAE = raw.AAE; ma.AAE_biomass = raw.AAEbiomass; ma.AAE_fossilfuel = raw.AAEfossilfuel;
      ma.BB_pct = raw.BB_lpar__pct__rpar_;
      ma.Delta_C = raw.Delta_dash_C_lpar_ng_fslash_m_caret_3_rpar_;
      ma.Pumpdrive = raw.Pumpdrive;
      ma.Temp_C = raw.ReportingTemp_lpar_C_rpar_;
      ma.Pres_PA = raw.ReportingPressure_lpar_Pa_rpar_;


      [tape, tape_ii] = unique(ma.tape); tape_ii = tape_ii+2;
      ma.nref = ma.Ref./ma.Ref(1,:);
      ma.nor1 = ma.Sen1./ma.Sen1(1,:);
      ma.nor2 = ma.Sen2./ma.Sen2(1,:);
      for ii = tape_ii'
         ma.nref(ii:end,:) = ma.Ref(ii:end,:)./ma.Ref(ii,:);
         ma.nor1(ii:end,:) = ma.Sen1(ii:end,:)./ma.Sen1(ii,:);
         ma.nor2(ii:end,:) = ma.Sen2(ii:end,:)./ma.Sen2(ii,:);
      end

      ma.Tr1 = ma.nor1./ma.nref;
      ma.Tr2 = ma.nor2./ma.nref;

   else
      disp('No valid file selected.')
      return
   end
  
end
return

% status
%1  * 1,2,4,8: 
%16 *
% 256
%4096
%65536 1, 2(Ext Power),3,4
%none
%16777216: 1(WiFi Timebase)
% none
% 4294967296: (1 WiFi data full)
