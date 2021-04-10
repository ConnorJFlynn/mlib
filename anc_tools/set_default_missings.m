function prefs = set_default_missings(prefs)
% Set the default missing values for floating point, signed int, unsigned int,
% and char strings for input and separately for output.
if ~isfield(prefs,'missing_in')||isempty(prefs.missing_in)
    prefs.missing_in = set_missing_in;
end
if isfield(prefs, 'missing_in')&&~isempty(prefs.missing_in)&&(~isfield(prefs,'missing_out')||isempty(prefs.missing_out))
    prefs.missing_out = set_missing_out(prefs.missing_in);
else
    prefs.missing_out = set_missing_out(prefs.missing_out);
end

end

function missing_in = set_missing_in
% Floating point missing
done = false;
miss = -9999;
while ~done
    if ~ischar(miss)
        miss_str = num2str(miss);
    else
        miss_str = ['''',miss,''''];
    end
    if isnan(miss)
        miss_str = ['''NaN'''];
    end
    mis = menu({['Select the EXPECTED value for missing floats: <',miss_str,'>']},'-9999','NaN','Custom...', 'DONE');
    if mis == 1
        miss = -9999;
    elseif mis ==2
        miss = NaN;
    elseif mis ==3
        miss = input('Enter value denoting floating point missing value: ');
    elseif mis ==4
        done = true;
    end
end
missing_in.float = miss;

% Signed integer missing
done = false;
miss = -9999;
while ~done
    if ~ischar(miss)
        miss_str = num2str(miss);
    else
        miss_str = ['''',miss,''''];
    end
    if isnan(miss)
        miss_str = ['''NaN'''];
    end
    mis = menu({['Select the EXPECTED value for missing SIGNED integers: <',miss_str,'>']},'-99','-9999','Custom...', 'DONE');
    if mis == 1
        miss = -99;
    elseif mis ==2
        miss = -9999;
    elseif mis ==3
        miss = floor(input('Enter value denoting unsigned integer missing value: '));
%         mis8 = intmax('uint8');  mis16 = intmax('uint16');
%         mis32 = intmax('uint32');
    elseif mis ==4
        done = true;
    end
end
missing_in.signed = miss;

% Unsigned integer missing
done = false;
miss = 9999;
while ~done
    if ~ischar(miss)
        miss_str = num2str(miss);
    else
        miss_str = ['''',miss,''''];
    end
    if isnan(miss)
        miss_str = ['''NaN'''];
    end
    mis = menu({['Select the EXPECTED value for missing UNSIGNED integers: <',miss_str,'>']},'99','9999','Custom...', 'DONE');
    if mis == 1
        miss = 99;
    elseif mis ==2
        miss = 9999;
    elseif mis ==3
        miss = floor(abs(input('Enter value denoting unsigned integer missing value: ')));
%         mis8 = intmax('uint8');  mis16 = intmax('uint16');
%         mis32 = intmax('uint32');
    elseif mis ==4
        done = true;
    end
end
missing_in.unsigned = miss;

% Char string missing
done = false;
miss = -9999;

while ~done
    miss_str = num2str(miss);
    
    mis = menu({['Select the EXPECTED value for missing char strings: <''',miss_str,'''>']},'''-9999''','''NaN''','Custom...', 'DONE');
    if mis == 1
        miss = -9999;
    elseif mis ==2
        miss = NaN;
    elseif mis ==3
        miss = input('Enter value denoting missing (include quotes for string value): ');
    elseif mis ==4
        done = true;
    end
end
missing_in.char = num2str(miss);

end

function miss_out = set_missing_out(miss_out)
% Returns the default missing value to use for floating point, unsigned
% integer, and char fields as miss_out.float, miss_out.unsigned, and
% miss_out.char

% Floating point missing
done = false;
if isavar('miss_out')&&isfield(miss_out,'float')
    miss = miss_out.float;
else
    miss = -9999;
end
while ~done
    miss_str = num2str(miss);
    mis = menu({['Select the default missing value to output for floating point fields: <',miss_str,'>']},'-9999','NaN','Custom...', 'DONE');
    if mis == 1
        miss = -9999;
    elseif mis ==2
        miss = NaN;
    elseif mis ==3
        miss = input('Enter value denoting floating point missing value: ');
    elseif mis ==4
        done = true;
    end
end
miss_out.float = miss;

% Signed integer missing
done = false;
if isfield(miss_out,'signed')
    miss = miss_out.signed;
else
    miss = -9999;
end
while ~done
    miss_str = num2str(miss);
    mis = menu({['Select the default missing value to output for SIGNED integer fields: <',miss_str,'>']},'-99','-9999','Custom...', 'DONE');
    if mis == 1
        miss = -99;
    elseif mis ==2
        miss = -9999;
    elseif mis ==3
        miss = input('Enter value denoting signed integer missing value: ');
    elseif mis ==4
        done = true;
    end
end
miss_out.signed = miss;

% Unsigned integer missing
done = false;
if isfield(miss_out,'unsigned')
    miss = miss_out.unsigned;
else
    miss = 9999;
end
while ~done
    miss_str = num2str(miss);
    mis = menu({['Select the default missing value to output for UNSIGNED integer fields: <',miss_str,'>']},'99','9999','Custom...', 'DONE');
    if mis == 1
        miss = 99;
    elseif mis ==2
        miss = 9999;
    elseif mis ==3
        miss = input('Enter value denoting unsigned integer missing value: ');
    elseif mis ==4
        done = true;
    end
end
miss_out.unsigned = miss;

% Char string missing
done = false;
if isfield(miss_out,'char')
    miss = miss_out.char;
else
    miss = -9999;
end

while ~done
    miss_str = num2str(miss);
    
    mis = menu({['Select the default missing value to output for char strings: <''',miss_str,'''>']},'''-9999''','''NaN','Custom...', 'DONE');
    if mis == 1
        miss = -9999;
    elseif mis ==2
        miss = NaN;
    elseif mis ==3
        miss = input('Enter value denoting missing (include quotes for string value): ');
    elseif mis ==4
        done = true;
    end
end
miss_out.char = num2str(miss);
end
