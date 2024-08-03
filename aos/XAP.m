function XAP
% Prompts for XAP from which to collect data
% Checks for existence of data directory.
% If not found, prompt with getfullpath
% Once found, checks for white.(filter_id).mat file.
% If white.(filter_id).mat not found, generates it by connecting to com port issuing "hide", "spot 0", "spot
% 2024-07-02: apparently a bug regarding the name of filter.*.mat (using previous
% filter num instead of new one) that causes the compiled version to crash out after
% it creates a new filter.*.mat file, but it runs fine the next time
% 2024-07-13: Trying to fix the above bug, add display, and set desired filter Tr_min
% 2024-07-24: Significant rework. Using xap.NumBytesAvailable<461 and
% isgraphics(H_fig) seems to be helping responsiveness a lot


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
   ports = serialportlist;
   mn = menu('Click one: ',ports{:}); 
   if mn==0 ; mn = length(ports); end
   xap_port = sscanf(ports(mn),'COM%d');
   xap_port = sprintf('%d',xap_port);
end

xap_path = getfilepath(xap_name);
try
   xap = serialport(['com',xap_port],57600);
catch
   delete(serialportfind);
   xap = serialport(['com',xap_port],57600);
end
xap.Timeout = 0.2;
configureTerminator(xap,"CR/LF")
% Flush the buffer, wait till a record is available
% Then read until the buffer is clear.
flush(xap,'input');
xap_Trs = [];
while isempty(xap_Trs)
   while xap.NumBytesAvailable<461; end
   xap_Trs = xap_1line(readline(xap));
end
% default Tr_min = 0.7;
Tr_min = .7;
update = 10;
h_fig = figure_(300 + sscanf(xap_port,'%f'));
sg = sgtitle(h_fig, {['Setting up ',xap_name],['Close this figure to stop saving data and exit ']});
sg.Interpreter = 'None';
%Check for a white filter with this filter ID.
% If exist, load it, else prompt for new filter OK.
white_filter = ['white.',num2str(xap_Trs.filter_id),'.mat'];
if isafile([xap_path,white_filter])
   white = load([xap_path,white_filter]);
else
   flush(xap,'output'); writeline(xap,'main');pause(.05);
   flush(xap,'output'); writeline(xap,'main');pause(.05);
   flush(xap,'output'); writeline(xap,'hide'); pause(.05);
   flush(xap,'output'); writeline(xap,'hide');pause(.05);
   flush(xap, 'input');
   flush(xap,'output'); writeline(xap,'show');pause(.05);

   white_dat =  ['white.',datestr(now,'yyyymmdd.HHMM'),'.dat'];
   white_filter = write_white(xap, xap_path, white_dat);
   white = load([xap_path,white_filter]);
   white.Tr_min = Tr_min;
   white.loaded = false; % Assume filter is not exhausted to start.
   save([xap_path,white_filter],'-struct','white')
end



% At this point, we have a white file.  We'll read records until Tr<Tr_min or we get
% a keystroke to execute a XAP menu item or exit.

% title({['Select this figure and then press any key to modify ',xap_name];'Close this figure to stop saving data and exit program'});
% h_fig = figure_(300 + sscanf(xap_port,'%f'));
XAP_adjust( xap, xap_path, white_filter);
% set(h_fig,'KeyPressFcn', {@XAP_KeyPressed, xap, xap_path, white_filter});
sg.String = ['Close this figure to stop saving data and exit ',xap_name];
pause(.1);
xap_Trs = [];
while isempty(xap_Trs)
   while xap.NumBytesAvailable<461, end
   xap_Trs = xap_1line(readline(xap));
end
while xap_Trs.spot(end)==0
   pause(.05); writeline(xap,'spot 1'); pause(0.05); flush(xap,'input');
   xap_Trs = [];
   while isempty(xap_Trs)
      while xap.NumBytesAvailable<461, end
      xap_Trs = xap_1line(readline(xap));
   end
end
xap_Trs_ = xap_Trs;
done = false;
while ~done
   tic;
   while toc<update & ~done
      data_file = [xap_path, [xap_name, datestr(now,'.yyyymmdd.HH'), '.dat']];
      if xap.NumBytesAvailable>2000
         flush(xap,'input');
         disp('Tossed surplus records')
      end
      xap_line = [];
      while isempty(xap_line)
         while xap.NumBytesAvailable<461, end
         xap_line = readline(xap);
      end
      % while xap.NumBytesAvailable<461; end;
      % xap_line = readline(xap);
      laptime = now;
      DT = datestr(laptime,'yyyy-mm-dd, HH:MM:SS');
      did = fopen(data_file,'a');
      fprintf(did,'%s, %s \n',DT, xap_line);
      fclose(did);
      if length(xap_line{1})>450
         xap_Trs = [];
         while isempty(xap_Trs)
            while xap.NumBytesAvailable<461, end
            xap_Trs = xap_1line(readline(xap));
         end
         xap_Trs_ = cat_xap( xap_Trs_,xap_Trs);
      end
      if xap_Trs.spot>0
         Tr = xap_Trs.Tr_raw./[white.Tr_blu_init(xap_Trs.spot); white.Tr_blu_init(xap_Trs.spot); white.Tr_blu_init(xap_Trs.spot)];
      else
         Tr = NaN.*xap_Trs.Tr_raw;
      end
      xap_Trs.Tr = Tr;
      count = ceil(update-toc); count = max([0,count]);
      if isgraphics(h_fig)
      sg.String ={['Close this figure to stop saving data and exit ',xap_name];['Countdown: ',num2str(count)]};
      sg.Interpreter = 'none';
      else 
         done = true;
      end
      pause(0.05)
   end
      if xap_Trs.spot>0
         xap_Trs_.Tr = xap_Trs_.Tr_raw./[white.Tr_blu_init(xap_Trs.spot); white.Tr_blu_init(xap_Trs.spot); white.Tr_blu_init(xap_Trs.spot)];
      else
         xap_Trs_.Tr = NaN.*xap_Trs.Tr_raw;
      end

   if isfield(white,'Tr_min')&&white.Tr_min~=Tr_min
      Tr_min = white.Tr_min;
   end

   if any(Tr<Tr_min)
      if (xap_Trs.spot == 8) && any(Tr<Tr_min) % On spot 8 , filter exhausted
         white = load([xap_path,white_filter]);
         white.loaded = true;
         white.Tr_min = white.Tr_min - 0.05;
         save([xap_path,white_filter],'-struct','white')
      end
      % Advance to next spot, wrapping around if necessary
      new_spot = xap_Trs.spot+1; if new_spot==9; new_spot =1; end
      flush(xap); writeline(xap,['spot=',num2str(new_spot)]);readline(xap)
   end
   if xap_Trs.filter_id~=white.filter_id
      white_filter = ['white.',num2str(xap_Trs.filter_id),'.mat'];
      white_dat =  ['white.',datestr(now,'yyyymmdd.HHMM'),'.dat'];
      write_white(xap, xap_path, white_dat)
      white = load([xap_path,white_filter]);
   end
   done = ~isgraphics(h_fig);
    if ~done
      figure_(h_fig);
      % set(h_fig,'KeyPressFcn', {@XAP_KeyPressed, xap, xap_path, white_filter});
      if ~isavar('an')
         an(1) = annotation('TextBox',[0.1256    0.9-.05    0.1162    0.0455],'String',['Filter: ',num2str(white.filter_id)]);
         an(2) = annotation('TextBox',[0.25    0.9-.05    0.1353    0.0455],'String',['Spot : ',num2str(xap_Trs_.spot(end))]);%xap_Trs_.spot(end)
         an(3) = annotation('TextBox',[0.395    0.9-.05    0.15    0.0455],'String',['Flow [LPM]: ',num2str(xap_Trs_.flow_lpm(end))]);%xap_Trs_.flow_lpm(end)
         an(4) = annotation('TextBox',[0.5534    0.9-.05   0.1812    0.0455],'String',['Sample: ',num2str(xap_Trs_.T_sample(end)),' C']);%xap_Trs_.T_sample(end)
         an(5) = annotation('TextBox',[0.7433    0.9-.05   0.17    0.0455],'String',['Case: ',num2str(xap_Trs_.T_case(end)),' C']); %xap_Trs_.T_case(end)
         if xap_Trs_.spot(end)>0
            an(6) = annotation('TextBox',[0.1256    0.8241-.05    0.1264    0.0455],'String',...
               sprintf('Tr: %1.3f',xap_Trs_.Tr_raw(1)./white.Tr_red_init(xap_Trs_.spot(end))),'Color','r');
            an(7) = annotation('TextBox',[0.26    0.8241-.05    0.1264    0.0455],'String',...
               sprintf('Tr: %1.3f',xap_Trs_.Tr_raw(2)./white.Tr_grn_init(xap_Trs_.spot(end))),'Color',[0,.65,0]);
            an(8) = annotation('TextBox',[0.4    0.8241-.05   0.1264    0.0455],'String',...
               sprintf('Tr: %1.3f',xap_Trs_.Tr_raw(3)./white.Tr_blu_init(xap_Trs_.spot(end))),'Color','b');
         end
         if isfield(white,'loaded')&&  white.loaded
            an(9) =annotation('TextBox',[0.5983    0.7436    0.2195    0.0775],'String',['Filter is FULLY LOADED. Change filter ASAP!'],...
               'Color',[.8,0,0], 'FontWeight','bold','EdgeColor' , 'r');
         end
      else
         an(1).String = ['Filter: ',num2str(white.filter_id)];
         an(2).String = ['Spot: ',num2str(xap_Trs_.spot(end))];%xap_Trs_.spot(end)
         an(3).String = ['Flow [LPM]: ',num2str(xap_Trs_.flow_lpm(end))];%xap_Trs_.flow_lpm(end)
         an(4).String = ['Sample: ',num2str(xap_Trs_.T_sample(end)),' C'];%xap_Trs_.T_sample(end)
         an(5).String = ['Case: ',num2str(xap_Trs_.T_case(end)),' C']; %xap_Trs_.T_case(end)
         if xap_Trs_.spot(end)>0
            an(6).String = sprintf('Tr: %1.3f',xap_Trs_.Tr_raw(1)./white.Tr_red_init(xap_Trs_.spot(end)));
            an(7).String = sprintf('Tr: %1.3f',xap_Trs_.Tr_raw(2)./white.Tr_grn_init(xap_Trs_.spot(end)));
            an(8).String = sprintf('Tr: %1.3f',xap_Trs_.Tr_raw(3)./white.Tr_blu_init(xap_Trs_.spot(end)));
         end
         if length(an)==9
            if isfield(white,'loaded')&&  white.loaded
               an(9).String =['Filter is FULLY LOADED. Change filter ASAP!'];
            else
               an(9).String = '';
            end
         end
      end
      Hs = serial2hs(xap_Trs_.time);
      sb(2) = subplot(4,1,2); % For Tr

      plot(Hs, [xap_Trs_.Tr],'.-'); legend('Tr (red)','Tr (grn)','Tr (blu)'); ylabel('Tr [unitless]');
      % xl = xlim; xlim([floor(xl(1)), ceil(xl(2))])

      sb(3) = subplot(4,1,3); % for Flow
      plot(Hs, [xap_Trs_.flow_lpm],'x-'); legend('Sample Flow'); ylabel('flow [LPM]');
      % xl = xlim; xlim([floor(xl(1)), ceil(xl(2))]);
      sb(4) = subplot(4,1,4); % for Temp
      plot(Hs, [xap_Trs_.T_sample; xap_Trs_.T_case],'-o'); legend('T Sample','T Case'); ylabel('Temp [C]');
      % xl = xlim; xlim([floor(xl(1)), ceil(xl(2))]);
      xlabel('Time [UT]');
      if max(Hs)>24
      xticklabels(num2str(rem(xticks,24)));
      end
      pause(.05);
    end
    Hs = serial2hs(xap_Trs_.time);
    if (max(Hs)-min(Hs))>7
       dmp = floor(Hs)==floor(Hs(1));
       xap_Trs_.time(dmp) = [];xap_Trs_.secs(dmp) = [];xap_Trs_.flags(dmp) = [];
       xap_Trs_.spot(dmp) = [];xap_Trs_.spot_vol(dmp) = [];xap_Trs_.filter_id(dmp) = [];
       xap_Trs_.flow_lpm(dmp) = [];xap_Trs_.T_case(dmp) = [];xap_Trs_.T_sample(dmp) = []; 
       xap_Trs_.signal_dark_raw(:,dmp) = [];xap_Trs_.signal_blue_raw(:,dmp) = [];
       xap_Trs_.signal_green_raw(:,dmp) = [];xap_Trs_.signal_red_raw(:,dmp) = [];
       xap_Trs_.signal_blue(:,dmp) = [];xap_Trs_.signal_green(:,dmp) = [];xap_Trs_.signal_red(:,dmp) = [];
       xap_Trs_.Tr_raw(:,dmp) = [];xap_Trs_.Tr(:,dmp) = [];
    end
    
end

delete(serialportfind)

return

function XAP_adjust(xap, xap_path,white_filter)

dev = fliplr(strtok(fliplr(xap_path),filesep));
done = false;
flush(xap,'input');
while xap.NumBytesAvailable<461; end
xap_Trs = [];
while isempty(xap_Trs)
   while xap.NumBytesAvailable<461, end
   xap_Trs = xap_1line(readline(xap));
end
white = load([xap_path,white_filter]);
if isfield(white,'Tr_min')
   Tr_min = white.Tr_min;
else
   Tr_min = 0.7;
end
while ~done
   flush(xap,'input');
   xap_Trs = [];
   while isempty(xap_Trs)
      while xap.NumBytesAvailable<461, end
      xap_Trs = xap_1line(readline(xap));
   end
   men = menu(['Select an action for ',dev],['Advance spot <',num2str(xap_Trs.spot),'>'],...
      ['Change Filter <',num2str(xap_Trs.filter_id),'>'],['Set Tr_min <',num2str(Tr_min),'>'],'Done');
   if men  ==1
      flush(xap,'input');
      xap_Trs = [];
      while isempty(xap_Trs)
         while xap.NumBytesAvailable<461, end
         xap_Trs = xap_1line(readline(xap));
      end
      nxt_spot = xap_Trs.spot+1;
      if nxt_spot==9; nxt_spot=1; end
      flush(xap); writeline(xap,['spot ',num2str(nxt_spot)]);flush(xap);
   elseif men ==2
      mn =menu('Change filter. Really? Then click OK when done, else select Skip','OK','Skip');
      if mn ==1
         flush(xap); writeline(xap,'main');  readline(xap);readline(xap);readline(xap);
         flush(xap); writeline(xap,['hide']); readline(xap);
         flush(xap); writeline(xap,['spot=0']);readline(xap);
         flush(xap); writeline(xap,['stop']);readline(xap);
         flush(xap); writeline(xap,['go']);pause(1); readline(xap);
         white_dat =  ['white.',datestr(now,'yyyymmdd.HHMM'),'.dat'];
         white_filter = write_white(xap, xap_path, white_dat);
         white = load([xap_path,white_filter]);
         white.Tr_min = 0.7;
         white.loaded = false; % Assume filter is not exhausted to start.
         save([xap_path,white_filter],'-struct','white')
         flush(xap); writeline(xap,['go']);readline(xap)
      end
   elseif men==3
      if isafile([xap_path,white_filter])
         white = load([xap_path,white_filter]);
      end
      if ~isfield(white,'Tr_min')
         white.Tr_min = 0.7;
      end
      tenths = floor(white.Tr_min*10)./10;
      hunths = rem(white.Tr_min*100,10)./100;
      don = false;
      while ~don
         dd = menu(sprintf('Tr_min = %01.2f',white.Tr_min), 'Change 10ths place', 'Change 100ths place','Done');
         if dd ==1
            tenths = (menu('Select tenths place:','.5','.6','.7','.8','.9')+4)/10;
         elseif dd ==2
            hunths = (menu('Select hundreths place: 0-9','0','1','2','3','4','5','6','7','8','9')-1)./100;
         elseif dd == 3
            don = true;
         end
         Tr_min = tenths+hunths;
         white.Tr_min = Tr_min;
      end
      save([xap_path,white_filter],'-struct','white');
   else
      done = true;
   end
end
return

function xap = cat_xap(xap, xap_)

[~, ind] = sort([xap.secs, xap_.secs]);
fields = fieldnames(xap_);
for f = 1:length(fields)
   tmp = [xap.(fields{f}), xap_.(fields{f})];
   xap.(fields{f}) = tmp(:,ind);
end

return



