function PXAP_VI
% Prompts for PSAP from which to collect data
% Checks for existence of data directory.
% If not found, prompt with getfullpath
% 2024-07-25: Significant rework. Using xap.NumBytesAvailable<461 and
% isgraphics(H_fig) seems to be helping responsiveness a lot
% 2024-12-20: Adding display (similar to IN102_VI) and 

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

xap_path = getfilepath(xap_name);
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
%Check for a white filter with this filter ID.
% If exist, load it, else prompt for new filter OK.

% We'll read records until Tr<Tr_min or we get
% a keystroke to execute a XAP menu item or exit.

pause(.1);flush(xap,'input');xap.NumBytesAvailable;
sline = [];
while isempty(sline)
   while xap.NumBytesAvailable<len, end
   sline = readline(xap);
end

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
         % skip this record
      else
         oline = xap_line;
         pid = fopen(pfile,'a');
         fprintf(pid,'%s %s ',DT, xap_line);
         fclose(pid);
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

   done = ~isgraphics(h_fig);
    % if ~done
    %   figure_(h_fig);
    %   % set(h_fig,'KeyPressFcn', {@XAP_KeyPressed, xap, xap_path, white_filter});
    %   if ~isavar('an')
    %      an(3) = annotation('TextBox',[0.395    0.9-.05    0.15    0.0455],'String',['Flow [LPM]: ',num2str(xap_Trs_.flow_lpm(end))]);%xap_Trs_.flow_lpm(end)
    %      an(4) = annotation('TextBox',[0.5534    0.9-.05   0.1812    0.0455],'String',['Sample: ',num2str(xap_Trs_.T_sample(end)),' C']);%xap_Trs_.T_sample(end)
    %      an(5) = annotation('TextBox',[0.7433    0.9-.05   0.17    0.0455],'String',['Case: ',num2str(xap_Trs_.T_case(end)),' C']); %xap_Trs_.T_case(end)
    %      if xap_Trs_.spot(end)>0
    %         an(6) = annotation('TextBox',[0.1256    0.8241-.05    0.1264    0.0455],'String',...
    %            sprintf('Tr: %1.3f',xap_Trs_.Tr_raw(1)./white.Tr_red_init(xap_Trs_.spot(end))),'Color','r');
    %         an(7) = annotation('TextBox',[0.26    0.8241-.05    0.1264    0.0455],'String',...
    %            sprintf('Tr: %1.3f',xap_Trs_.Tr_raw(2)./white.Tr_grn_init(xap_Trs_.spot(end))),'Color',[0,.65,0]);
    %         an(8) = annotation('TextBox',[0.4    0.8241-.05   0.1264    0.0455],'String',...
    %            sprintf('Tr: %1.3f',xap_Trs_.Tr_raw(3)./white.Tr_blu_init(xap_Trs_.spot(end))),'Color','b');
    %      end
    %      if isfield(white,'loaded')&&  white.loaded
    %         an(9) =annotation('TextBox',[0.5983    0.7436    0.2195    0.0775],'String',['Filter is FULLY LOADED. Change filter ASAP!'],...
    %            'Color',[.8,0,0], 'FontWeight','bold','EdgeColor' , 'r');
    %      end
    %   else
    %      an(1).String = ['Filter: ',num2str(white.filter_id)];
    %      an(2).String = ['Spot: ',num2str(xap_Trs_.spot(end))];%xap_Trs_.spot(end)
    %      an(3).String = ['Flow [LPM]: ',num2str(xap_Trs_.flow_lpm(end))];%xap_Trs_.flow_lpm(end)
    %      an(4).String = ['Sample: ',num2str(xap_Trs_.T_sample(end)),' C'];%xap_Trs_.T_sample(end)
    %      an(5).String = ['Case: ',num2str(xap_Trs_.T_case(end)),' C']; %xap_Trs_.T_case(end)
    %      if xap_Trs_.spot(end)>0
    %         an(6).String = sprintf('Tr: %1.3f',xap_Trs_.Tr_raw(1)./white.Tr_red_init(xap_Trs_.spot(end)));
    %         an(7).String = sprintf('Tr: %1.3f',xap_Trs_.Tr_raw(2)./white.Tr_grn_init(xap_Trs_.spot(end)));
    %         an(8).String = sprintf('Tr: %1.3f',xap_Trs_.Tr_raw(3)./white.Tr_blu_init(xap_Trs_.spot(end)));
    %      end
    %      if length(an)==9

    %         if isfield(white,'loaded')&&  white.loaded
    %            an(9).String =['Filter is FULLY LOADED. Change filter ASAP!'];
    %         else
    %            an(9).String = '';
    %         end
    %      end
    %   end
    %   Hs = serial2hs(xap_Trs_.time);
    %   sb(2) = subplot(4,1,2); % For Tr
    % 
    %   plot(Hs, [xap_Trs_.Tr],'.-'); legend('Tr (red)','Tr (grn)','Tr (blu)'); ylabel('Tr [unitless]');
    %   % xl = xlim; xlim([floor(xl(1)), ceil(xl(2))])
    % 
    %   sb(3) = subplot(4,1,3); % for Flow
    %   plot(Hs, [xap_Trs_.flow_lpm],'x-'); legend('Sample Flow'); ylabel('flow [LPM]');
    %   % xl = xlim; xlim([floor(xl(1)), ceil(xl(2))]);
    %   sb(4) = subplot(4,1,4); % for Temp
    %   plot(Hs, [xap_Trs_.T_sample; xap_Trs_.T_case],'-o'); legend('T Sample','T Case'); ylabel('Temp [C]');
    %   % xl = xlim; xlim([floor(xl(1)), ceil(xl(2))]);
    %   xlabel('Time [UT]');
    %   if max(Hs)>24
    %   xticklabels(num2str(rem(xticks,24)));
    %   end
    %   pause(.05);
    % end
    % Hs = serial2hs(xap_Trs_.time);
    % if (max(Hs)-min(Hs))>7
    %    dmp = floor(Hs)==floor(Hs(1));
    %    xap_Trs_.time(dmp) = [];xap_Trs_.secs(dmp) = [];xap_Trs_.flags(dmp) = [];
    %    xap_Trs_.spot(dmp) = [];xap_Trs_.spot_vol(dmp) = [];xap_Trs_.filter_id(dmp) = [];
    %    xap_Trs_.flow_lpm(dmp) = [];xap_Trs_.T_case(dmp) = [];xap_Trs_.T_sample(dmp) = []; 
    %    xap_Trs_.signal_dark_raw(:,dmp) = [];xap_Trs_.signal_blue_raw(:,dmp) = [];
    %    xap_Trs_.signal_green_raw(:,dmp) = [];xap_Trs_.signal_red_raw(:,dmp) = [];
    %    xap_Trs_.signal_blue(:,dmp) = [];xap_Trs_.signal_green(:,dmp) = [];xap_Trs_.signal_red(:,dmp) = [];
    %    xap_Trs_.Tr_raw(:,dmp) = [];xap_Trs_.Tr(:,dmp) = [];
    % end
end

delete(serialportfind)

return


function adjust_xlim(src,event )
menu('Adjust xlim as desired, press OK when done','OK');
return
