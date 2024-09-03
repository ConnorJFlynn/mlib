function XAP5
% Prompts for XAP from which to collect data
% Checks for existence of data directory.
% If not found, prompt with getfullpath
% 2024-07-02: apparently a bug regarding the name of filter.*.mat (using previous
% filter num instead of new one) that causes the compiled version to crash out after
% it creates a new filter.*.mat file, but it runs fine the next time
% 2024-07-13: Trying to fix the above bug, add display, and set desired filter Tr_min
% 2024-07-24: Significant rework. Using xap.NumBytesAvailable<461 and
% isgraphics(H_fig) seems to be helping responsiveness a lot
% 2024-08-09: Trying to avoid error on delete by testing with serialportlist and
% fixing cause of 2-sec reporting
% Forcing initial white filter 
% 2024-08-12: Re-introduce onkeypress for settings
% 2024-08-12: New no-white filter approach
% 2024-08-15: Moved legends to NW
% 2024-08-24: Fixed failure to save xap_filter.Tr_min after change


% cc = [0 0.4470 0.7410; 0.8500 0.3250 0.0980; 0.9290  0.6940  0.1250;...
%  0.4940  0.1840  0.5560; 0.4660 0.6740 0.1880;0.3010 0.7450 0.9330; ...
%  0.6350 0.0780 0.1840];
% old 2014a colororder
cc = [ 0 0  1;  0 0.5 0; 1 0 0; 0 .75 .75; .75 0 .75; .75 .75 0; .25 .25 .25];
set(groot,'DefaultAxesColorOrder', cc);
clear cc
set(groot,'DefaultFigureColorMap',jet);     

ports = serialportlist('all');
me = menu('Select XAP to collect from:','CLAP10','TAP12','TAP13', 'CLAP92', 'Test');
if me==1
   xap_name = 'CLAP10';
   xap_port = '10';
elseif me==2
   xap_name = 'TAP12';
   xap_port = '12';
elseif me==3
   xap_name = 'TAP13';
   xap_port = '13';
elseif me==4
   xap_name = 'CLAP92';
   xap_port = '92';
else
   xap_name = 'XAP_test';
   mn = menu('Click one: ',ports{:});
   if mn==0 ; mn = length(ports); end
   xap_port = sscanf(ports(mn),'COM%d');
   xap_port = sprintf('%d',xap_port);
end

xap_path = getfilepath(xap_name);

try
   xap = serialport(['com',xap_port],57600);
catch
   xap = serialportfind;
   delete(xap); pause(.1);
   xap = serialport(['com',xap_port],57600);
end
xap.Timeout = 0.2;
configureTerminator(xap,"CR/LF")
len = 462;
% default Tr_min = 0.7;
Tr_min = .7;
Tr_updates = 6;
update = 10;
max_hours = 6;

spot_time= NaN([8,1]);
% Flush the buffer, wait till a record is available
% Then read until the buffer is clear.
flush(xap); pause(.05); writeline(xap,'show');pause(.05);
xap_sig = [];
while isempty(xap_sig)&&~isstruct(xap_sig)
   while xap.NumBytesAvailable<len; end
   xap_line = readline(xap);
   xap_sig = xap_1line_(xap_line);
end
while xap_sig.spot(end)==0
   flush(xap); pause(.05); writeline(xap,'spot 1'); pause(0.05); flush(xap,'input');
   xap_sig = [];
   while isempty(xap_sig)
      while xap.NumBytesAvailable<len, end
      xap_line = readline(xap);
      xap_sig = xap_1line_(xap_line);
   end
end
spot_time(xap_sig.spot) = now;
% Belt and suspenders
% Check whether reported filter ID matches existing XAP filter file.
xap_filter_file = [xap_path, xap_name, 'filter.',num2str(xap_sig.filter_ID),'.mat'];
if isafile(xap_filter_file)
   % menu({'XAP expects an unused filter. If the filter is new, select "OK"'; 'Otherwise, change the filter and click "OK" when finished.'},'OK')
   flush(xap); writeline(xap,'main');  readline(xap);readline(xap);readline(xap);
   flush(xap); writeline(xap,['hide']); readline(xap);
   flush(xap); writeline(xap,['spot=0']);readline(xap);
   flush(xap); writeline(xap,['stop']);
   flush(xap); writeline(xap,['go']); while xap.NumBytesAvailable<len, end; readline(xap);
   flush(xap); writeline(xap,['spot=1']); while xap.NumBytesAvailable<len, end;
   xap_line = readline(xap);
   xap_sig = xap_1line_(xap_line);
end
   while isempty(xap_sig)
      while xap.NumBytesAvailable<len, end
      xap_line = readline(xap);
      xap_sig = xap_1line_(xap_line);
   end
S_mark = [xap_sig.signal_blue,xap_sig.signal_green,xap_sig.signal_red];
xap_filter_file = [xap_path, xap_name, 'filter.',num2str(xap_sig.filter_ID),'.mat'];
xap_filter.filter_ID = xap_sig.filter_ID;
try 
   xap_filter.time_str = {datestr(spot_time(xap_sig.spot),'yyyy-mm-dd HH:MM:SS ')};
catch
   spot_time(xap_sig.spot) = now;
   xap_filter.time_str = {datestr(spot_time(xap_sig.spot),'yyyy-mm-dd HH:MM:SS ')};
end
xap_filter.line = {xap_line};
xap_filter.Tr_min = Tr_min;
xap_filter.loaded = false; % Assume filter is not exhausted to start
xap_filter.S_mark = S_mark;
save(xap_filter_file,'-struct','xap_filter');

h_fig = figure_(300 + sscanf(xap_port,'%f'));
sg = sgtitle(h_fig, {['Select figure window and press any key to modify ',xap_name];['Close this figure to stop saving data and exit ']});
sg.Interpreter = 'None';
set(h_fig,'KeyPressFcn', {@XAP_adjust, xap, xap_path, xap_filter_file});

% At this point, we have a current filter file that matches the reported record.
% Record records until Tr<Tr_min (then we advance a spot), we get a keystroke (and we run XAP_Adjust)
% or the Window is closed (and we exit)

% It should start automatically by default.  Don't bring up XAP_adjust unless the
% user hits a key



pause(.1);
xap_sig = [];
while isempty(xap_sig)
   while xap.NumBytesAvailable<len, end
   xap_sig = xap_1line_(readline(xap));
end
while xap_sig.spot(end)==0
   pause(.05); writeline(xap,'spot 1'); pause(0.05); flush(xap,'input');
   xap_sig = [];
   while isempty(xap_sig)
      while xap.NumBytesAvailable<len, end
      xap_sig = xap_1line_(readline(xap));
   end
end
% S_mark = [xap_sig.signal_blue,xap_sig.signal_green,xap_sig.signal_red];
S_normed = [xap_sig.signal_blue,xap_sig.signal_green,xap_sig.signal_red]./S_mark; % Unity for first point
not_spot = [1:10];
if xap_sig.spot>0
   not_spot(xap_sig.spot)=[];
end
So = mean(S_normed(not_spot,:));
Tr = S_normed(xap_sig.spot,:)./So;
% xap_sig.S_normed = S_normed';
xap_sig.So = So';
xap_sig.Tr = Tr';
xap_sig_ = xap_sig;
don = false;
while ~don
   if isnan(spot_time(xap_sig.spot))
      spot_time(xap_sig.spot) = now;
   end
   tic;
   xap_filter = load(xap_filter_file);
   S_mark = xap_filter.S_mark; Tr_min = xap_filter.Tr_min;
   while (toc<update) && ~don
      data_file = [xap_path, [xap_name, datestr(now,'.yyyymmdd.HH'), '.dat']];
      if xap.NumBytesAvailable>(2*len)
         flush(xap,'input');
         if isvalid(sg)
            sg.String ={['Select figure window and press any key to modify ',xap_name];...
               ['Close this figure to stop saving data and exit '];...
               ['Discarded surplus records...']};
            sg.Interpreter = 'none';
         else
            sg = sgtitle(h_fig, {['Select figure window and press any key to modify ',xap_name];...
              ['Close this figure to stop saving data and exit '];...
               ['Discarded surplus records...']});
            sg.Interpreter = 'none';
         end
         xap_filter = load(xap_filter_file);
         S_mark = xap_filter.S_mark;
      end
      xap_line = [];
      while isempty(xap_line)
         while xap.NumBytesAvailable<len, end
         xap_line = readline(xap);
      end
      laptime = now;
      DT = datestr(laptime,'yyyy-mm-dd, HH:MM:SS');
      did = fopen(data_file,'a');
      fprintf(did,'%s, %s \n',DT, xap_line);
      fclose(did);
      if length(xap_line{1})>450
         xap_sig = xap_1line_(xap_line);

         S_normed = [xap_sig.signal_blue,xap_sig.signal_green,xap_sig.signal_red]./S_mark; % Unity for first point
         not_spot = [1:10]; not_spot(xap_sig.spot)=[];
         So = mean(S_normed(not_spot,:));
         Tr = S_normed(xap_sig.spot,:)./So;
         % xap_sig.S_normed = S_normed';
         xap_sig.So = So';
         xap_sig.Tr = Tr';
         xap_sig_ =  cat_timeseries(xap_sig_,xap_sig );% cat_xap( xap_sig_,xap_sig);
      end
      count = ceil(update-toc); count = max([0,count]);
      if isgraphics(h_fig)
         if isvalid(sg)
            sg.String ={['Select figure window and press any key to modify ',xap_name];...
               ['Close this figure to stop saving data and exit '];...
               ['Countdown: ',num2str(count)]};
            sg.Interpreter = 'none';
         else
            sg = sgtitle(h_fig, {['Select figure window and press any key to modify ',xap_name];...
               ['Close this figure to stop saving data and exit ']});
            sg.Interpreter = 'none';
         end
      else
         don = true;
      end
      pause(0.5)
   end
   

   if isfield(xap_filter,'Tr_min')&&xap_filter.Tr_min~=Tr_min
      Tr_min = xap_filter.Tr_min;
   end
   %
   if any(Tr(:,end)<Tr_min)
      xap_filter = load(xap_filter_file);
      if (xap_sig.spot == 8) && any(Tr(:,end)<Tr_min) % On spot 8 , filter exhausted         
         xap_filter.loaded = true;
         xap_filter.Tr_min = xap_filter.Tr_min - 0.05;
      end
      % Advance to next spot, wrapping around if necessary
      new_spot = xap_sig.spot+1; if new_spot==9; new_spot =1; end
      flush(xap); writeline(xap,['spot=',num2str(new_spot)]);
      xap_line = [];
      while isempty(xap_line)
         while xap.NumBytesAvailable<len, end
         xap_line = readline(xap);
      end
      xap_filter.time_str(end+1)  = {datestr(now,'yyyy-mm-dd HH:MM:SS ')};
      xap_filter.line(end+1) = {xap_line};
      save(xap_filter_file,'-struct','xap_filter')
   end
   if xap_sig.filter_ID>xap_filter.filter_ID
      xap_filter_file = [xap_path, xap_name, 'filter.',num2str(xap_sig.filter_ID),'.mat'];
      xap_filter = load([xap_filter_file]);
   end
   don2 = ~isgraphics(h_fig);
   if ~don2
      figure_(h_fig);
      if ~isavar('an')
         an(1) = annotation('TextBox',[0.1256    0.7866    0.1162    0.0455],'String',['Filter: ',num2str(xap_filter.filter_ID)]);
         an(2) = annotation('TextBox',[0.25    0.7866    0.1353    0.0455],'String',['Spot : ',num2str(xap_sig_.spot(end))]);%xap_sig_.spot(end)
         an(3) = annotation('TextBox',[0.3950 0.7866 0.1500 0.0455],'String',['Flow [LPM]: ',num2str(xap_sig_.flow_lpm(end))]);%xap_sig_.flow_lpm(end)
         an(4) = annotation('TextBox',[0.5534    0.7866   0.1812    0.0455],'String',['Sample: ',num2str(xap_sig_.T_sample(end)),' C']);%xap_sig_.T_sample(end)
         an(5) = annotation('TextBox',[0.7433    0.7866   0.17    0.0455],'String',['Case: ',num2str(xap_sig_.T_case(end)),' C']); %xap_sig_.T_case(end)
         if xap_sig_.spot(end)>0
            an(6) = annotation('TextBox',[0.1256 0.7088 0.1264 0.0455],'String',...
               sprintf('Tr: %1.4f',xap_sig_.Tr(3,end)),'Color','r');
            an(7) = annotation('TextBox',[0.26    0.7088 0.1264 0.0455],'String',...
               sprintf('Tr: %1.4f',xap_sig_.Tr(2,end)),'Color',[0,.65,0]);
            an(8) = annotation('TextBox',[0.4    0.7088 0.1264 0.0455],'String',...
               sprintf('Tr: %1.4f',xap_sig_.Tr(1,end)),'Color','b');
         end
         if isfield(xap_filter,'loaded')&&  xap_filter.loaded
            an(9) =annotation('TextBox',[0.5983    0.7088 0.1264 0.0455],'String',['Filter is FULLY LOADED. Change filter ASAP!'],...
               'Color',[.8,0,0], 'FontWeight','bold','EdgeColor' , 'r');
         end
      else
         an(1).String = ['Filter: ',num2str(xap_filter.filter_ID)];
         an(2).String = ['Spot: ',num2str(xap_sig_.spot(end))];%xap_sig_.spot(end)
         an(3).String = ['Flow [LPM]: ',num2str(xap_sig_.flow_lpm(end))];%xap_sig_.flow_lpm(end)
         an(4).String = ['Sample: ',num2str(xap_sig_.T_sample(end)),' C'];%xap_sig_.T_sample(end)
         an(5).String = ['Case: ',num2str(xap_sig_.T_case(end)),' C']; %xap_sig_.T_case(end)
         if xap_sig_.spot(end)>0
            an(6).String = sprintf('Tr: %1.3f',xap_sig_.Tr(3,end));
            an(7).String = sprintf('Tr: %1.3f',xap_sig_.Tr(2,end));
            an(8).String = sprintf('Tr: %1.3f',xap_sig_.Tr(1,end));
         end
         if length(an)==9
            if isfield(xap_filter,'loaded')&&  xap_filter.loaded
               an(9).String =['Filter is FULLY LOADED. Change filter ASAP!'];
            else
               an(9).String = '';
            end
         end
      end
      Hs = serial2hs(xap_sig_.time);
      sb(2) = subplot(4,1,2); % For Tr

      plot(Hs, [xap_sig_.Tr],'.-'); legend('Tr (blue)','Tr (grn)','Tr (red)','Location','Northwest'); 
      ylabel('Tr [unitless]');
      % xl = xlim; xlim([floor(xl(1)), ceil(xl(2))])

      sb(3) = subplot(4,1,3); % for Flow
      plot(Hs, [xap_sig_.flow_lpm],'x-'); legend('Sample Flow','Location','Northwest'); ylabel('flow [LPM]');
      % xl = xlim; xlim([floor(xl(1)), ceil(xl(2))]);
      sb(4) = subplot(4,1,4); % for Temp
      plot(Hs, [xap_sig_.T_sample; xap_sig_.T_case],'-o'); legend('T Sample','T Case','Location','Northwest'); ylabel('Temp [C]');
      % xl = xlim; xlim([floor(xl(1)), ceil(xl(2))]);
      xlabel('Time [UT]');
      if max(Hs)>24
         xticklabels(num2str(rem(xticks,24)));
      end
      pause(.05);
   end
   Hs = serial2hs(xap_sig_.time);
   if (max(Hs)-min(Hs))>max_hours
      dmp = floor(Hs)==floor(Hs(1));
      xap_sig_.time(dmp) = [];xap_sig_.secs(dmp) = [];xap_sig_.flags(dmp) = [];
      xap_sig_.spot(dmp) = [];xap_sig_.spot_vol(dmp) = [];xap_sig_.filter_ID(dmp) = [];
      xap_sig_.flow_lpm(dmp) = [];xap_sig_.T_case(dmp) = [];xap_sig_.T_sample(dmp) = [];
      xap_sig_.signal_dark_raw(:,dmp) = [];xap_sig_.signal_blue_raw(:,dmp) = [];
      xap_sig_.signal_green_raw(:,dmp) = [];xap_sig_.signal_red_raw(:,dmp) = [];
      xap_sig_.signal_blue(:,dmp) = [];xap_sig_.signal_green(:,dmp) = [];xap_sig_.signal_red(:,dmp) = [];
      xap_sig_.So(:,dmp) = []; xap_sig_.Tr(:,dmp) = [];
   end
   if isempty(xap_sig_.time)
      xap_sig_ = xap_sig;
   end
end

return

% Merge XAP_adjust and XAP_KeyPressed
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


% Normalization approach
% Tr_blue = NaN(size(clap.time));
% for spot = 1:8
%    not_spot = [1:10]; not_spot(spot) = [];
%    sig_med = median(clap.signal_blue(:,clap.spot_active==spot),2);
%    nmed_blue = clap.signal_blue(:,clap.spot_active==spot)./sig_med;
%    Tr_blue(clap.spot_active==spot) = nmed_blue(spot,:)./mean(nmed_blue(not_spot,:))
% end
% bad = diff2(clap.spot_active); bad(abs(bad)>0) = NaN; bad(2:end) = bad(1:end-1)+bad(2:end)
% figure; plot([1:length(clap.time)],Tr_blue,'-',[1:length(clap.time)],Tr_blue+bad,'ro')
