function var =  edit_vspec(vname, vspec)
if isavar('vname')&&isavar('vspec')&&isfield(vspec,vname)
    if ~isfield(vspec.(vname), 'format')
        vspec.(vname).format = '%g';
    end
    if ~isfield(vspec.(vname), 'units')
        vspec.(vname).units = 'unitless';
    end
    if ~isfield(vspec.(vname), 'qc_mode')
        vspec.(vname).qc_mode = 'No QC';
    end
    if ~isfield(vspec.(vname), 'missing_in')
        vspec.(vname).missing_in = -9999;
    end
    if ~isfield(vspec.(vname), 'missing_out')
        vspec.(vname).missing_out = -9999;
    end
    if ~isfield(vspec.(vname), 'extract')
        vspec.(vname).extract = true;
    end
    done = false;
    testnum = 0.0123;
    while ~done
        if vspec.(vname).extract
            ext_str = 'True';
        else
            ext_str= 'False';
        end
        fmt_str = vspec.(vname).format;
        mn = menu([vname, ' details:'], ['format: <',fmt_str, ' ==> ',sprintf(fmt_str,testnum),'>'],...
            ['units: <',vspec.(vname).units, '>'],...
            ['qc mode: <',vspec.(vname).qc_mode, '>'],...
            ['missing (in): <',num2str(vspec.(vname).missing_in), '>'],...
            ['missing (out): <',num2str(vspec.(vname).missing_out), '>'],...
            ['extract: <',ext_str, '>'],...
            'Done');
        if mn ==1 %Select format string
            fdone = false;
            while ~fdone
                fmn = menu({['Input a sample number or a format string.'];...
                    [num2str(testnum), ' with ',fmt_str, ' yields: ',sprintf(fmt_str,testnum)]},...
                    'Sample number', 'format string','Done')
                if fmn==1
                    testnum = input('Enter a test number to format: ');
                elseif fmn ==2
                    fmt_str = input('Enter a format string (do not include quotes): ','s');
                elseif fmn ==3
                    fdone = true;
                end
                vspec.(vname).format = fmt_str;
            end
        elseif mn ==2 % Enter units string
            vspec.(vname).units = input('Enter the units', 's');
        elseif mn==3 % Select qc_mode
            vspec.(vname).qc_mode = set_qc_options;
        elseif mn==4 % Select missing value in input stream
            vspec.(vname).missing_in = input(['Enter missing value expected in the input file: ']);
        elseif mn==5 % Select value to use for missing in the output file
            vspec.(vname).missing_out = input('Enter value for missings in output file (include quotes if needed): ');
        elseif mn==6
            x = menu(['Extract ',vname],'Yes','No');
            if x==1
                vspec.(vname).extract = true;
            else
                vspec.(vname).extract = false;
            end
        else
            done = true;
        end

           
    end
    var = vspec.(vname);
else
    var = [];

    
end

   function qc_opts = set_qc_options;
    opts = {'only GOOD','no BAD','no QC','summary','detailed'};
    mn = menu('Select the level of QC to include in the export:', 'only GOOD values','no BAD values','No QC applied','summary','detailed');
    qc_opts = opts{mn};
   end

end