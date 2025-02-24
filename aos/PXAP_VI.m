function PXAP_VI
% Prompts for PSAP from which to collect data
% Checks for existence of data directory.
% If not found, prompt with getfullpath
% 2024-07-25: Significant rework. Using xap.NumBytesAvailable<461 and
% isgraphics(H_fig) seems to be helping responsiveness a lot
% 2024-12-20: Adding display (similar to IN102_VI) and 
plots_default; close(gcf)
me = menu('Select PSAP to collect from:','PSAP 77','PSAP 110','PSAP123', 'Test');
if me==1
   xap_name = 'PSAP77';
   xap_port = '77';
elseif me==2
   xap_name = 'PSAP110';
   xap_port = '110';
elseif me==3
   xap_name = 'PSAP123';
   xap_port = '123';
else
   xap_name = 'PSAP_test';
   ports = serialportlist;
   mn = menu('Click one: ',ports{:}); 
   if mn==0 ; mn = length(ports); end
   xap_port = sscanf(ports(mn),'COM%d');
   xap_port = sprintf('%d',xap_port);
end
try
xap_path = getfilepath(xap_name);
catch
 xap_path = setfilepath(xap_name);
end
seps = find(xap_path==filesep);
dot_path = [xap_path(1:seps(1)),'..',xap_path(seps(end-3):end)];
try
   xap = serialport(['com',xap_port],9600);
catch
   delete(serialportfind);
   xap = serialport(['com',xap_port],9600);
end
xap.Timeout = 0.2;
len = 133;
% configureTerminator(xap,"CR/LF")
% Flush the buffer, wait till a record is available
% Then read until the buffer is clear.
flush(xap,'input');xap.NumBytesAvailable;
sline = [];
while isempty(sline)
   while xap.NumBytesAvailable<len; end
   sline = readline(xap);
end
% default Tr_min = 0.7;
Tr_min = .7;
update = 10;
h_fig = figure_(300 + sscanf(xap_port,'%f'));
sg = sgtitle(h_fig, {['Saving data in ',dot_path];['Close this figure to stop saving data and exit ',xap_name]});
sg.Interpreter = 'None';
% set(h_fig,'KeyPressFcn', {@adjust_xlim});
%Check for a white filter with this filter ID.
% If exist, load it, else prompt for new filter OK.

% We'll read records until Tr<Tr_min or we get
% a keystroke to execute a XAP menu item or exit.

pause(.1);flush(xap,'input');xap.NumBytesAvailable;
sline = [];pdata = [];
while isempty(sline)||isempty(pdata)
   while xap.NumBytesAvailable<len, end
   sline = readline(xap); sline = sline{1};
   pdata = parse_sline(sline);
end

% IN = parse_IN102(sline);

done = false;
while ~done
   tic;
   while toc<update & ~done
      
      ntime = now;
      rfile = [xap_path, [xap_name,'.R.' datestr(ntime,'.yyyymmdd.HH'), '.dat']];
      pfile = [xap_path, [xap_name,'.o.' datestr(ntime,'.yyyymmdd.HH'), '.dat']];
      if xap.NumBytesAvailable>(2.*len)
         flush(xap,'input');
         disp('Tossed surplus records')
      end
      xap_line = [];
      while isempty(xap_line)
         while xap.NumBytesAvailable<len, end
         xap_line = readline(xap); xap_line = xap_line{1};
      end
      % while xap.NumBytesAvailable<461; end;
      % xap_line = readline(xap);
      laptime = now;
      DT = datestr(laptime,'yyyy-mm-dd HH:MM:SS');
      if strcmp(xap_line(1),'R')
         rline = xap_line;
         rid = fopen(rfile,'a');
         fprintf(rid,'%s %s ',DT, xap_line);
         fclose(rid);
      elseif  strcmp(xap_line(1),'F') || strcmp(xap_line(1),'S') || strcmp(xap_line(1),'I')
         sline = xap_line;
         pdata = cat_timeseries(pdata, parse_sline(sline));
      else
         oline = xap_line;
         pid = fopen(pfile,'a');
         fprintf(pid,'%s %s ',DT, xap_line);
         fclose(pid);
         try
         sline = xap_line; pdata_ = parse_sline(sline)
         catch
            pdata_ = [];
         end
         if ~isempty(pdata_)
         pdata = cat_timeseries(pdata,pdata_);
         end
      end
      
      % count = ceil(update-toc); count = max([0,count]);
      % if isgraphics(h_fig)
      % sg.String ={['Close this figure to stop saving data and exit ',xap_name];['Countdown: ',num2str(count)]};
      % sg.Interpreter = 'none';
      % else 
      %    done = true;
      % end
      pause(0.05)
   end
      if isavar('sb')
         xl = xlim;
         xl_i = interp1(pdata.time,[1:length(pdata.time)],xl(1),'nearest','extrap');
      else
         xl_i = [];
      end
      if isgraphics(h_fig)

         sb(3) = subplot(3,1,3); %Babs
         plot(pdata.time, pdata.Ba_B,'o',pdata.time, pdata.Ba_G, '+', pdata.time, pdata.Ba_R,'x');
         lg_1 = legend('Absorption'); dynamicDateTicks;        
         xl = xlim; xl_j = interp1(pdata.time,[1:length(pdata.time)],xl(1),'nearest','extrap');
         sb(1) = subplot(3,1,1); % T, T_dp
         plot(pdata.time, pdata.Tr_B,'-',pdata.time, pdata.Tr_G, '-', pdata.time, pdata.Tr_R,'-');
         lg_2 = legend('Tr'); set(lg_2,'interp','tex'); dynamicDateTicks;

         sb(2) = subplot(3,1,2); % Target_flow, Flow
         plot(pdata.time, pdata.Flow_LPM, 'o-');
         lg_3= legend('FLOW LPM'); dynamicDateTicks;
         t_diff = abs(pdata.time(end)-pdata.Itime(end));
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
         % pause(update/2);
         
         if ~isempty(xl_i) && xl_i~=xl_j
           M = menu('Select an option for x-axis','Trim to lower x-limit','Reset entirely', 'Cancel');
           xl_ = xlim;
           keep = true(size(pdata.time));
           if M ==1
              keep = pdata.time >= xl_(1);
           elseif M ==2
              keep(1:end-2) = false
           end
           if sum(keep)<length(keep)
              fields = fieldnames(pdata);
              for f = 1:length(fields)
                 fld = fields{f};
                 pdata.(fld) = pdata.(fld)(keep);
              end    
           end
         end
         xl = xlim;
      end
   done = ~isgraphics(h_fig);

end

delete(serialportfind)

return

function pdata = parse_sline(sline);

   % 100111142547 -.12 -.13 -.09 1.000 1.000 1.000 1.971 2577 15 0083\
if ~strcmp(sline(1),'R')&&length(sline)>= 63
   sline = strrep(sline,'F ',''); sline = strrep(sline,'S ','');
   sline = deblank(sline); enils = fliplr(sline); enils = deblank(enils);
   sline = fliplr(enils);
   A = textscan(sline,'%s %f %f %f %f %f %f %f %f %f %s');
   D = A{1}; DT = ['20',D{1}];
   pdata.time = now;
   pdata.Itime = datenum(DT,'yyyymmddHHMMSS');
   pdata.Ba_B = A{2}; pdata.Ba_G = A{3}; pdata.Ba_R = A{4};
   pdata.Tr_B = A{5}; pdata.Tr_G = A{6}; pdata.Tr_R = A{7};
   pdata.Flow_LPM = A{8};
else
   pdata = [];
end
return




% function adjust_xlim(src,event )
% menu('Adjust xlim as desired, press OK when done','OK');
% return
