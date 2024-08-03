function run_xap(xap_name, xap_port);
% function accepts namestem for instrument and com port
% Checks for existence of data directory based on namestem.
% If not found, prompt with getfullame
% Once found, checks for white.mat file.
% If white.mat not found, generates it by connecting to com port issuing "hide", "spot 0", "spot
% 2024-07-02: apparently a bug regarding the name of filter.*.mat (using previous
% filter num instead of new one) that causes the compiled version to crash out after
% it creates a new filter.*.mat file, but it runs fine the next time

global xap
global done

me = menu('Select XAP to collect from:','CLAP10','TAP12','TAP13', 'CLAP19');
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
   xap_name = 'CLAP19';
   xap_port = '19';
else
   xap_name = 'xap_test';
   xap_port = '10';
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

xap_line = readline(xap); pause(1);
xap_line = readline(xap);
if ~isempty(xap_line)
   xap_line = xap_line{1};
   xap_Trs = xap_1line(xap_line);
end


Tr_min = 0.7;
white_filter = ['white.',num2str(xap_Trs.filter_id),'.mat'];
if isafile([xap_path,white_filter])
   white = load([xap_path,white_filter]);
else
   flush(xap); writeline(xap,'main');  readline(xap);readline(xap);readline(xap)
   flush(xap); writeline(xap,['hide']); readline(xap)
   flush(xap); writeline(xap,['spot=0']);readline(xap)
   flush(xap); writeline(xap,['stop']);readline(xap)

   menu('Change filter.  Press OK when done','OK')
   flush(xap); writeline(xap,['go']);pause(1); readline(xap)
   white_dat =  ['white.',datestr(now,'yyyymmdd.HHMM'),'.dat'];
   write_white(xap, xap_path, white_dat)
   white = load([xap_path,white_filter]);
end

% At this point, we have a white file.  We'll read records until Tr<Tr_min or we get
% a keystroke to execute a XAP menu item or exit.
h_fig = figure_(300 + sscanf(xap_port,'%f'));
title({'Select this figure to update the display '; ['or hit any key while it has focust to modify ',xap_name]});
set(h_fig,'KeyPressFcn', @myfun);

done = false;
while ~done
   data_file = [xap_path, [xap_name, datestr(now,'.yyyymmdd.HH'), '.dat']];
   xap_line = readline(xap);
   if ~isempty(xap_line)
      xap_line = xap_line{1};
      commas = length(strfind(xap_line,','));
      if length(xap_line)>1 && strcmp(xap_line(1:2),'03')&&(commas==48 ||commas==50)
         did = fopen(data_file,'a'); fprintf(did,'%s \n',xap_line); fclose(did);
         xap_Trs = xap_1line(xap_line);
         if xap_Trs.spot>0
            Tr = xap_Trs.Tr_raw./[white.Tr_blu_init(xap_Trs.spot), white.Tr_blu_init(xap_Trs.spot), white.Tr_blu_init(xap_Trs.spot)];
         else
            Tr = 0;
         end
         if (any(Tr<Tr_min))
            if (xap_Trs.spot < 8)
               flush(xap); writeline(xap,['spot=',num2str(xap_Trs.spot+1)]);readline(xap)
            else
               disp('Change filter ASAP!!')
            end
         end
         if xap_Trs.filter_id~=white.filter_id
            white_filter = ['white.',num2str(xap_Trs.filter_id),'.mat'];
            white_dat =  ['white.',datestr(now,'yyyymmdd.HHMM'),'.dat'];
            write_white(xap, xap_path, white_dat)
            white = load([xap_path,white_filter]);
         end
      end
   end
  pause(.9)
end %break through myfun

delete(serialportfind)
close(h_fig);
return


function myfun(src,event)
global xap
global done
pause(1)
xap_line = readline(xap)
xap_Tr = xap_1line(xap_line);
nxt_spot = min([8,xap_Tr.spot+1]);
men = menu('Select an action:','Exit Program','Advance spot','Change Filter');
if men  ==1
   done = true;
elseif men ==2
   flush(xap); writeline(xap,['spot=',num2str(nxt_spot)]);flush(xap);
elseif men ==3
   flush(xap); writeline(xap,'main');  readline(xap);readline(xap);readline(xap)
   flush(xap); writeline(xap,['hide']); readline(xap)
   flush(xap); writeline(xap,['spot=0']);readline(xap)
   flush(xap); writeline(xap,['stop']);readline(xap)

   menu('Change filter.  Press OK when done','OK')
   flush(xap); writeline(xap,['go']);readline(xap)
end


return


