function [vspec] = order_edit_columns(vspec)
% vspec = order_edit_columns(vspec)
% Adjust column order, toggle ON/OFF, and edit properties
done = false;
vlist = fieldnames(vspec); mlist = vlist;
nvars = length(vlist);
for v = nvars:-1:1
    if vspec.(vlist{v}).extract 
        mlist(v) = {[vlist{v}, ': Y']};
    else
        mlist(v) = {[vlist{v}, ': N']};
    end        
end


flip = true ; edit = false ;UP = false  ; DOWN = false; 
T_ON = ':ON'; E_ON = ''    ; UP_ON = '' ; DN_ON = '';

while ~done
    v_menu = menu({'Select to adjust order, toggle display, or edit settings.'},...
       [{'DONE';''; ['Toggle' T_ON]; ['Edit' E_ON];['Move UP' UP_ON];['Move DOWN' DN_ON]; ''};mlist]);   
   if v_menu ==1
       done = true;
   
   elseif v_menu == 3 % Toggle selected
       flip = true; edit = false; UP = false; DOWN = false;
       T_ON = ':ON'; E_ON = ''    ; UP_ON = '' ; DN_ON = '';
   elseif v_menu == 4 % Edit selected
       flip = false; edit = true; UP = false; DOWN = false;
       T_ON = ''; E_ON = ':ON'    ; UP_ON = '' ; DN_ON = '';
   elseif v_menu == 5 % Move UP selected
       flip = false; edit = false; UP = true; DOWN = false;
       T_ON = ''; E_ON = ''    ; UP_ON = ':ON' ; DN_ON = '';
   elseif v_menu == 6 % Move Down selected
       flip = false; edit = false; UP = false; DOWN = true;
       T_ON = ''; E_ON = ''    ; UP_ON = '' ; DN_ON = ':ON';
   else % field selected
       v = v_menu-7;
       if flip
           if vspec.(vlist{v}).extract
               mlist(v) = {[vlist{v}, ': N']};
           else
               mlist(v) = {[vlist{v}, ': Y']};
           end
           vspec.(vlist{v}).extract = ~vspec.(vlist{v}).extract;
       elseif UP
           if v==1
               tmp = vlist(1); vlist([1:end-1]) = vlist(2:end); vlist(end) = tmp; clear tmp;
               tmp = mlist(1); mlist([1:end-1]) = mlist(2:end); mlist(end) = tmp; clear tmp;
           elseif v>1
               tmp = vlist(v-1); vlist(v-1) = vlist(v); vlist(v) = tmp; clear tmp;
               tmp = mlist(v-1); mlist(v-1) = mlist(v); mlist(v) = tmp; clear tmp;
           end
       elseif DOWN
           if v==nvars
               tmp = vlist(end); vlist(2:end) = vlist([1:end-1]); vlist(1) = tmp; clear tmp;
               tmp = mlist(end); mlist(2:end) = mlist([1:end-1]); mlist(1) = tmp; clear tmp;
           elseif v<nvars
               tmp = vlist(v+1); vlist(v+1) = vlist(v); vlist(v) = tmp; clear tmp;
               tmp = mlist(v+1); mlist(v+1) = mlist(v); mlist(v) = tmp; clear tmp;
           end
       elseif edit
           vspec.(vlist{v}) = edit_vspec(vlist{v},vspec);
       end
   end
           
end


return