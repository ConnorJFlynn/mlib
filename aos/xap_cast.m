function xap = xap_cast(xap)
% This function applies "typecast" to generate single-precision floating
% point number from the TAP and CLAP raw streams.  It first attempts the
% computationally efficient block-conversion but on error will step through
% each line of raw input
xap.signal_dark_raw = NaN(10,length(xap.time));
xap.signal_blue_raw = NaN(10,length(xap.time));
xap.signal_green_raw = NaN(10,length(xap.time));
xap.signal_red_raw =  NaN(10,length(xap.time));

% try processing entire string blocks
try
   for ch = 10:-1:1
      tmp_str = ['DN_Dark_',num2str(mod(ch,10))];
      xap.signal_dark_raw(ch,:) = typecast(uint32(hex2dec(xap.(tmp_str))),'single');
      tmp_str = ['DN_Red_',num2str(mod(ch,10))];
      xap.signal_red_raw(ch,:) = typecast(uint32(hex2dec(xap.(tmp_str))),'single');
      tmp_str = ['DN_Grn_',num2str(mod(ch,10))];
      xap.signal_green_raw(ch,:) = typecast(uint32(hex2dec(xap.(tmp_str))),'single');
      tmp_str = ['DN_Blu_',num2str(mod(ch,10))];
      xap.signal_blue_raw(ch,:) = typecast(uint32(hex2dec(xap.(tmp_str))),'single');
   end
catch
   
   for t = length(xap.secs_hex):-1:1
      % Test one record at a time, evaluating records in the order they
      % appeear in the original string.  As soon as any fails, skip the
      % rest of the time record.
      try
         for ch = 10:-1:1
            tmp_str = ['DN_Dark_',num2str(mod(ch,10))];
            tmp_hex = xap.(tmp_str){t};
            xap.signal_dark_raw(ch,t) = typecast(uint32(hex2dec(tmp_hex)),'single');
            tmp_str = ['DN_Red_',num2str(mod(ch,10))];
            tmp_hex = xap.(tmp_str){t};
            xap.signal_red_raw(ch,:) = typecast(uint32(hex2dec(tmp_hex)),'single');
            tmp_str = ['DN_Grn_',num2str(mod(ch,10))];
            tmp_hex = xap.(tmp_str){t};
            xap.signal_green_raw(ch,:) = typecast(uint32(hex2dec(tmp_hex)),'single');
            tmp_str = ['DN_Blu_',num2str(mod(ch,10))];
            tmp_hex = xap.(tmp_str){t};
            xap.signal_blue_raw(ch,:) = typecast(uint32(hex2dec(tmp_hex)),'single');
         end
      catch
         disp(['Skipping record: ',num2str(t)])
      end
      
   end
end
xap.signal_dark_raw = xap.signal_dark_raw';
xap.signal_blue_raw = xap.signal_blue_raw';
xap.signal_green_raw = xap.signal_green_raw';
xap.signal_red_raw =  xap.signal_red_raw';
xap.signal_blue = xap.signal_blue_raw - xap.signal_dark_raw;
xap.signal_green = xap.signal_green_raw - xap.signal_dark_raw;
xap.signal_red = xap.signal_red_raw - xap.signal_dark_raw;

return