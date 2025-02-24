function IN102_VI
% Prompts for SerialPort to whcih IN102 is attached.
% Checks for existence of data directory.
% If not found, prompt with getfullpath
% 2024-12_17:  V 1.0 
% 2024-12_17:  V 2.0 Adds header row to new file


me = menu('Select COM Port collect from:','COM78','COM102', 'Test');
if me==1
   xap_name = 'IN102_SN78';
   xap_port = '78';
elseif me==2
   xap_port = '102';
   xap_name = 'IN102';
else
   xap_name = 'COM_test';
   ports = serialportlist;
   mn = menu('Click one: ',ports{:}); 
   if mn==0 ; mn = length(ports); end
   xap_port = sscanf(ports(mn),'COM%d');
   xap_port = sprintf('%d',xap_port);
end

xap_path = getfilepath(xap_name);
seps = find(xap_path==filesep);
dot_path = [xap_path(1:seps(1)),'..',xap_path(seps(end-3):end)];
try
   xap = serialport(['com',xap_port],19200);
catch
   delete(serialportfind);
   xap = serialport(['com',xap_port],19200);
end
xap.Timeout = 0.2;
len = 351;
% configureTerminator(xap,"CR/LF")
% Flush the buffer, wait till a record is available
% Then read until the buffer is clear.
flush(xap,'input');xap.NumBytesAvailable;
sline = [];
while isempty(sline)
   while xap.NumBytesAvailable<len; end
   sline = readline(xap);
end

sline = deblank(sline{1});
pax = fliplr(sline); pax = deblank(pax);
sline = fliplr(pax);
IN = parse_IN102(sline);
update = 4;

h_fig = figure_(300 + sscanf(xap_port,'%f'));
sg = sgtitle(h_fig, {['Saving data in ',dot_path];['Close this figure to stop saving data and exit ',xap_name]});
sg.Interpreter = 'None';




done = false;
while ~done
   tic;
   while toc<update & ~done
      ntime = now;
      nfile = [xap_path, [xap_name, datestr(ntime,'.yyyymmdd.HH'), '.csv']];
      if ~isafile(nfile)
         nid = fopen(nfile,'a');
         header = 'PC_DateTime, SN, DATE_TIME,YEAR,MONTH,DATE,HOUR,MINUTE,SECOND,RF_PMT,RF_REF,GF_PMT,GF_REF,BF_PMT,BF_REF,RB_PMT,RB_REF,GB_PMT,GB_REF,BB_PMT,BB_REF,TEMP,PRESSURE,RH,TEMP_RAW,PRESSURE_RAW,RH_RAW,PMT_DARK,FORW_DARK_REF,BACK_DARK_REF,BACK_SCATT_RED,BACK_SCATT_GREEN,BACK_SCATT_BLUE,TOTAL_SCATT_RED,TOTAL_SCATT_GREEN,TOTAL_SCATT_BLUE,FAN_RPM,FLOW_PRESSURE,FLOW,DAC,RF_CR,GF_CR,BF_CR,RB_CR,GB_CR,BB_CR,INDEX,CYCLE,TARGET_FLOW,SELECT,SAMPLE_COUNT,AMBIENT_COUNT';
         fprintf(nid,'%s, %s \n',header);
         fclose(nid);
      end
      if xap.NumBytesAvailable>(2.*len)
         flush(xap,'input');
         disp('Tossed surplus records')
      end
      xap_line = [];
      while isempty(xap_line)
         pause(5);
         while xap.NumBytesAvailable<len, end
         xap_line = readline(xap); 
      end
      xap_line = deblank(xap_line{1}); 
      pax = fliplr(xap_line); pax = deblank(pax);
      xap_line = fliplr(pax);
      laptime = now;
      DT = datestr(laptime,'yyyy-mm-dd HH:MM:SS');
      if strcmp(xap_line(1:2),'IN')
         nid = fopen(nfile,'a');
         fprintf(nid,'%s, %s \n',DT, xap_line);
         fclose(nid);
      end
      IN = cat_timeseries(IN, parse_IN102(xap_line));
      if isgraphics(h_fig)
         sb(1) = subplot(3,1,1); %scats
         plot(IN.time, IN.TOTAL_SCATT_BLUE,'o-',IN.time, IN.TOTAL_SCATT_GREEN, '+-', IN.time, IN.TOTAL_SCATT_RED,'x-');
         lg_1 = legend('Scattering'); dynamicDateTicks;


         sb(2) = subplot(3,1,2); % T, T_dp
         plot(IN.time, IN.TEMP, 'o-', IN.time, IN.T_dp,'x-');
         lg_2 = legend('T ATM', 'T_D_p'); set(lg_2,'interp','tex'); dynamicDateTicks;

         sb(3) = subplot(3,1,3); % Target_flow, Flow
         plot(IN.time, IN.TARGET_FLOW, 'o-',IN.time, IN.FLOW,'x-');
         lg_3= legend('Target Flow','FLOW'); dynamicDateTicks;
         t_diff = abs(laptime-IN.time(end));
         if abs(t_diff)>2
            day_str = [num2str(floor(abs(t_diff))),' days and'];
         elseif abs(t_diff)>1
            day_str = [num2str(floor(abs(t_diff))),' day and '];
         else
            day_str = [];
         end
         t_str = datestr(t_diff,'HH:MM:SS.fff');
      
         xlabel(['Difference between PC and IN102 is ',day_str, t_str])

         linkaxes(sb,'x');
         count = ceil(update-toc); count = max([0,count]);
         if isgraphics(h_fig)
            sg.String ={['Close this figure to stop saving data and exit ',xap_name]};
            sg.Interpreter = 'none';
         else
            done = true;
         end
      end
      pause(0.5)
   end
   cut_time = (floor(IN.time(end)*24)-4)./(24);
   old = IN.time < cut_time;
   if any(old)
      field = fieldnames(IN);
      for f = 1:length(field)
         fld = field{f};
         IN.(fld)(old) = [];
      end
   end




   done = ~isgraphics(h_fig);

end

delete(serialportfind)

return

function out = parse_IN102(sline)
header = 'SN,DATE_TIME,YEAR,MONTH,DATE,HOUR,MINUTE,SECOND,RF_PMT,RF_REF,GF_PMT,GF_REF,BF_PMT,BF_REF,RB_PMT,RB_REF,GB_PMT,GB_REF,BB_PMT,BB_REF,TEMP,PRESSURE,RH,TEMP_RAW,PRESSURE_RAW,RH_RAW,PMT_DARK,FORW_DARK_REF,BACK_DARK_REF,BACK_SCATT_RED,BACK_SCATT_GREEN,BACK_SCATT_BLUE,TOTAL_SCATT_RED,TOTAL_SCATT_GREEN,TOTAL_SCATT_BLUE,FAN_RPM,FLOW_PRESSURE,FLOW,DAC,RF_CR,GF_CR,BF_CR,RB_CR,GB_CR,BB_CR,INDEX,CYCLE,TARGET_FLOW,SELECT,SAMPLE_COUNT,AMBIENT_COUNT';
   head_str = textscan(header,'%s','Delimiter',',');
   head_str = head_str{1};
   fmt_str = ['IN%f %s ',repmat('%f ',[1,46]), '%s %f %f'];
   A = textscan(sline,fmt_str,'Delimiter',',');
  out.SN = A{1};
   out.time = datenum(A{2},'yyyy-mm-ddTHH:MM:SS');
   if out.time(1)<datenum(2020,1,1)
      V = datevec(out.time); 
      V(:,1) = 2024;
      out.time = datenum(V);
   end

   for col=9:51
      out.(head_str{col}) = A{col};
   end
 out.T_dp = dp_from_rh(out.TEMP+273.15, out.RH)-273.15;

return %from parse_IN102

function XAP_adjust(src,event,xap, xap_path, xap_filter_file )
len = 462;
dev = fliplr(strtok(fliplr(xap_path),filesep));
don = false;
xap_filter = load(xap_filter_file);
flush(xap,'input');
while xap.NumBytesAvailable<len; end
xap_sig = [];
while isempty(xap_sig)
   while xap.NumBytesAvailable<len, end
   xap_sig = xap_1line_(readline(xap));
end

if isfield(xap_filter,'Tr_min')
   Tr_min = xap_filter.Tr_min;
else
   Tr_min = 0.7;
end
while ~don
   if isafile(xap_filter_file)
      xap_filter = load(xap_filter_file);
   end
   flush(xap,'input');
   xap_sig = [];
   while isempty(xap_sig)
      while xap.NumBytesAvailable<len, end
      xap_line = readline(xap);
      xap_sig = xap_1line_(xap_line);
   end
   if isfield(xap_filter,'S_mark')
      S_mark = xap_filter.S_mark;
   else
      S_mark = [xap_sig.signal_blue,xap_sig.signal_green,xap_sig.signal_red];
   end
   S_normed = [xap_sig.signal_blue,xap_sig.signal_green,xap_sig.signal_red]./S_mark; % Unity for first point
   not_spot = [1:10]; 
   if xap_sig.spot>0
      not_spot(xap_sig.spot)=[];
   end
   So = mean(S_normed(not_spot,:));
   Tr = S_normed(xap_sig.spot,:)./So;

   men = menu(['Select an action for ',dev],['Advance spot <',num2str(xap_sig.spot),'>'],...
      ['Reset Tr <',sprintf('%1.2f ',Tr),'>'],...
      ['Set Tr_min <',num2str(Tr_min),'>'],'Done');
   if men==1 % Advance spot
      flush(xap,'input');
      xap_sig = [];
      while isempty(xap_sig)
         while xap.NumBytesAvailable<len, end
         xap_sig = xap_1line_(readline(xap));
      end
      nxt_spot = xap_sig.spot+1;
      if nxt_spot==9; nxt_spot=1; end
      while nxt_spot ~= xap_sig.spot
         flush(xap); writeline(xap,['spot ',num2str(nxt_spot)]);flush(xap); 
         xap_sig=[];
         while isempty(xap_sig)
            while xap.NumBytesAvailable<len, end
            xap_sig = xap_1line_(readline(xap));
         end
      end
      S_mark = [xap_sig.signal_blue,xap_sig.signal_green,xap_sig.signal_red];
      xap_filter.S_mark = S_mark;
      xap_filter.time_str(end+1) = {datestr(now,'yyyy-mm-dd HH:MM:SS ')};
      xap_filter.line(end+1) = {xap_line};
      % save(xap_filter_file,'-struct','xap_filter')
   elseif men==2 % Reset Tr
      S_mark = [xap_sig.signal_blue,xap_sig.signal_green,xap_sig.signal_red];
      xap_filter.S_mark = S_mark;
      xap_filter.time_str(end+1) = {datestr(now,'yyyy-mm-dd HH:MM:SS ')};
      xap_filter.line(end+1) = {xap_line};
      % save(xap_filter_file,'-struct','xap_filter')
      % Reset Tr
   elseif men==3 %Set Tr_min
      if ~isfield(xap_filter,'Tr_min')
         xap_filter.Tr_min = 0.7;
      end
      tenths = floor(xap_filter.Tr_min*10)./10;
      hunths = rem(xap_filter.Tr_min*100,10)./100;
      don = false;
      while ~don
         dd = menu(sprintf('Tr_min = %01.2f',xap_filter.Tr_min), 'Change 10ths place', 'Change 100ths place','Done');
         if dd ==1
            tenths = (menu('Select tenths place:','.5','.6','.7','.8','.9')+4)/10;
         elseif dd ==2
            hunths = (menu('Select hundreths place: 0-9','0','1','2','3','4','5','6','7','8','9')-1)./100;
         elseif dd == 3
            don = true;
         end
         Tr_min = tenths+hunths;
         xap_filter.Tr_min = Tr_min;
      end
      save(xap_filter_file,'-struct','xap_filter');
   else
      don = true;
   end
   if ~don 
      save(xap_filter_file,'-struct','xap_filter');
   end
end
return
