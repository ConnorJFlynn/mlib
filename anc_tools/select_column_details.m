function prefs = select_column_details(anc, prefs)

% This function will identify all time-dimensioned fields and will let
% the user select, sort, and  provide details (format, units, missing, qc_mode)


vspec = order_edit_columns(vspec);

% for v = length(vlist):-1:1
%     vname = vlist{v};
%     if isfield(anc.vdata, ['qc_',vname])
%         done = false;
%         qc_mode = 'Full';
%         while ~done
%             qc = menu(['Select qc mode for ',vname,': <',qc_mode,'> '], 'Full', 'Summary','No BAD','Only GOOD','No QC', 'DONE');
%             if qc==1
%                 qc_mode = 'Full';
%             elseif qc==2
%                 qc_mode = 'Summary';
%             elseif qc==3
%                 qc_mode = 'No BAD';
%                 
%             elseif qc==4
%                 qc_mode = 'Only GOOD';
%             elseif qc==5
%                 qc_mode = 'No QC';
%             elseif qc==6
%                 done = true;
%             end
%         end
%         vspec.(vname).qc_mode = qc_mode;
%     end
% end
% for v = length(vlist):-1:1
%     vname = vlist{v};
%     if isfield(anc.vatts.(vname),'missing_value')
%         vspec.(vname).missing_in = anc.vatts.(vname).missing_value;
%     elseif isfield(anc.gatts,'missing_value')
%         vspec.(vname).missing_in = anc.gatts.missing_value;
%     else
%         done = false;
%         miss = -9999;
%         
%         while ~done
%             if ~ischar(miss)
%                 miss_str = num2str(miss);
%             else
%                 miss_str = ['''',miss,''''];
%             end
%             if isnan(miss)
%                 miss_str = ['''NaN'''];
%             end
%             mis = menu({['Select the stored value that denotes a missing '];['value for ',vname,': <',miss_str,'>']},'-9999','''-9999''','NaN','Custom...', 'DONE');
%             if mis == 1
%                 miss = -9999;
%             elseif mis ==2
%                 miss = '-9999';
%             elseif mis ==3
%                 miss = NaN;
%             elseif mis ==4
%                 miss = input('Enter value denoting missing (include quotes for string value): ');
%             elseif mis ==5
%                 done = true;
%             end
%         end
%     end
% end


% attempt to convert 2D char into strings
%       if anc.ncdef.vars.(vname).datatype==2 && length(anc.ncdef.vars.(vname).dims)==2
%          anc.ncdef.vars.(vname).dims = anc.ncdef.vars.time.dims;
%          for t = length(anc.time):-1:1
%             vdata(t) = {anc.vdata.(vname)(:,t)'};
%          end
%          anc.vdata_.(vname) = vdata;
%          clear vdata
%       end
prefs.vspec = vspec;

return

