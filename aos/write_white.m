function white_filter = write_white(xap, xap_path, white_dat)
W_secs = 10;
fig = 300+sscanf(xap.Port,'com%d' );
figH = figure_(fig);
sgtitle(figH,['Creating ',white_dat]) 
fid = fopen([xap_path,white_dat],'w+');
   if fid
      flush(xap); pause(1.25); xap_line = readline(xap);
      if isempty(xap_line)
         writeline(xap,'show');
         % disp('spot=0, show...');
      end
      %First, set each spot for 3 seconds, just to tamp filter.
      for f = 8:-1:1
         n = 0;
         sgtitle(figH,['Setting spot = ',num2str(f)])
         writeline(xap,['spot=',num2str(f)]);
         flush(xap);
         while n < 3
            while xap.NumBytesAvailable<461; end
            xap_line = readline(xap);
            if ~isempty(xap_line)
               xap_line = xap_line{1};
               if strcmp(xap_line(1:2),'03')
                  n = n +1;
                  % disp({n,xap_line})
               end
            end
         end
         pause(.1);
      end
      %Next, set each spot for W_secs while saving data (currently 10, longer may be better)
      for f = 8:-1:1
         n = 0;         
         writeline(xap,['spot=',num2str(f)]);
         flush(xap);pause(.1); flush(xap); pause(.1);
         while n < W_secs
            sgtitle(figH,{['Setting spot = ',num2str(f)];[num2str(W_secs -n)]})
            while xap.NumBytesAvailable<461; end
            xap_line = readline(xap);
            if ~isempty(xap_line)
               xap_line = xap_line{1};
               if length(xap_line)>1 && strcmp(xap_line(1:2),'03')
                  fprintf(fid,'%s \n',xap_line);
                  n = n +1;
                  % disp({n,xap_line});
               end
            end
            pause(0.1)
         end
      end
   end
   fclose(fid);
   tmp = xap_1line(xap_line);
   white_filter = ['white.',num2str(tmp.filter_id),'.mat'];
   white_xap = xap_white([xap_path,white_dat]);
   save([xap_path,white_filter],'-struct','white_xap');
   
   end