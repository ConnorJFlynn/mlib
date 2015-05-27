
function defopts = anc_diff (nc1, nc2, options)

% defopts = ANC_DIFF (NC1, NC2)
%
%   Prints differences between two input ncstructs.  The optional
%   options structure is composed of the following elements:
%
%       OPTIONS.VERBOSE = [true|false], default: false
%       OPTIONS.INCVARS = [true|false], default: true
%       OPTIONS.INCDIMS = [true|false], default: true
%       OPTIONS.INCATTS = [true|false], default: true
%
%     $Revision: 1.1 $
%     $Date: 2013/12/11 00:49:08 $
%
%   See also ANC_CHECK, ANC_STRUCT.
%

%-------------------------------------------------------------------
% VERSION INFORMATION:
%
%   $RCSfile: ancdiff.m,v $
%   $Revision: 1.1 $
%   $Date: 2013/12/11 00:49:08 $
%
%   $Log: ancdiff.m,v $
%   Revision 1.1  2013/12/11 00:49:08  cflynn
%   Committing anctools
%
%   Revision 1.1  2011/04/08 13:49:28  cflynn
%   *** empty log message ***
%
%   Revision 1.1  2007/11/09 01:24:19  cflynn
%   This repository is for Matlab m-files
%
%   Revision 1.1  2007/09/05 08:08:56  cflynn
%   Creating Matlab Library for central ARM distribution of matlab scripts and functions
%
%   Revision 1.2  2006/06/19 18:41:47  sbeus
%   Added back CVS log information.
%
%
%-------------------------------------------------------------------
!! in progress
% Check options.
default.verbose = false;
default.incvars = true;
default.incdims = true;
default.incatts = true;
if (nargin > 2)
    opts = options;
    if (~isfield(opts, 'verbose'))
        opts.verbose = default.verbose;
        defopts = opts;
    end
    if (~isfield(opts, 'incvars'))
        opts.incvars = default.incvars;
        defopts = opts;
    end
    if (~isfield(opts, 'incdims'))
        opts.incdims = default.incdims;
        defopts = opts;
    end
    if (~isfield(opts, 'incatts'))
        opts.incatts = default.incatts;
        defopts = opts;
    end
else
    defopts.verbose = default.verbose;
    defopts.incvars = default.incvars;
    defopts.incdims = default.incdims;
    defopts.incatts = default.incatts;
    
    opts = defopts;
end

if (nargout == 1)
    defopts = opts;
end

% Messages to print when a given comparison element is unmatched.
nfmsg1 = ['Not found in "', upper(inputname(1)),'"'];
nfmsg2 = ['Not found in "', upper(inputname(2)),'"'];

%===================================================================
% DIMENSIONS >

if (opts.incdims)
    dims1 = fieldnames(nc1.ncdef.dims);
    for d = 1:length(dims1)
        if (~isfield(nc2.ncdef.dims, dims1{d}))
            dispdiff('dim', dims1{d}, nfmsg2);
            continue;
        end
        dim1 = nc1.ncdef.dims.(dims1{d});
        dim2 = nc2.ncdef.dims.(dims1{d});
        if (dim1.length ~= dim2.length)
            dispdiff('dim', dims1{d}, 'Length mismatch', num2str(dim1.length), num2str(dim2.length), opts);
        end
        if (dim1.isunlim ~= dim2.isunlim)
            dispdiff('dim', dims1{d}, 'Unlimited flag mismatch', num2str(dim1.isunlim), num2str(dim2.isunlim), opts);
        end
    end

    dims2 = fieldnames(nc2.ncdef.dims);
    for d = 1:length(dims2)
        if (~isfield(nc1.ncdef.dims, dims2{d}))
            dispdiff('dim', dims2{d}, nfmsg1);
            continue;
        end
    end
end


%===================================================================
% GLOBAL ATTRIBUTES >

compatts(nfmsg1, nfmsg2, '', nc1.ncdef.atts, nc2.ncdef.atts, opts);


%===================================================================
% VARIABLES >

if (opts.incvars)
    vars1 = fieldnames(nc1.ncdef.vars);
    for v = 1:length(vars1)
        if (~isfield(nc2.ncdef.vars, vars1{v}))
            dispdiff('var', vars1{v}, nfmsg2);
            continue;
        end
        var1 = nc1.ncdef.vars.(vars1{v});
        var2 = nc2.ncdef.vars.(vars1{v});
        vdata1 = nc1.vdata.(vars1{v});
        vdata2 = nc2.vdata.(vars1{v});

        if (var1.datatype ~= var2.datatype)
            dispdiff('var', vars1{v}, 'Type mismatch', anctype(var1.datatype), anctype(var2.datatype), opts);
        else
            shape1 = size(vdata1);
            shape2 = size(vdata2);
            if (length(shape1) ~= length(shape2) | any(shape1 ~= shape2))
                dispdiff('var', vars1{v}, 'Shape mismatch', shape2str(shape1), shape2str(shape2), opts);
            else
                if (any(vdata1 ~= vdata2))
                    dispdiff('var', vars1{v}, 'Values differ', vdata1, vdata2, opts);
                end
            end
        end
        
        compatts(nfmsg1, nfmsg2, vars1{v}, var1.atts, var2.atts, opts);
    end

    vars2 = fieldnames(nc2.vars);
    for v = 1:length(vars2)
        if (~isfield(nc1.vars, vars2{v}))
            dispdiff('var', vars2{v}, nfmsg1);
            continue;
        end
    end
end

return



function compatts(nfmsg1, nfmsg2, parent, attstr1, attstr2, opts)
% Compares attributes.

if (opts.incatts)
    atts1 = fieldnames(attstr1);
    for a = 1:length(atts1)
        if (~isfield(attstr2, atts1{a}))
            dispdiff('att', [parent,':',atts1{a}], nfmsg2);
            continue;
        end
        att1 = attstr1.(atts1{a});
        att2 = attstr2.(atts1{a});
        if (att1.datatype ~= att2.datatype)
            dispdiff('att', [parent,':',atts1{a}], 'Type mismatch', anctype(att1.datatype), anctype(att2.datatype), opts);
            continue;
        end
        if (length(att1.data) ~= length(att2.data))
            dispdiff('att', [parent,':',atts1{a}], 'Length mismtach', num2str(length(att1.data)), num2str(length(att2.data)), opts);
            continue;
        end
        if (att1.datatype == mexnc('PARAMETER', 'NC_CHAR'))
            if (~strcmp(att1.data,att2.data))
                dispdiff('att', [parent,':',atts1{a}], 'String values differ', att1.data, att2.data, opts);
            end
        else
            if (any(att1.data ~= att2.data))
                dispdiff('att', [parent,':',atts1{a}], 'Numeric values differ', att1.data, att2.data, opts);
            end
        end
    end

    atts2 = fieldnames(attstr2);
    for a = 1:length(atts2)
        if (~isfield(attstr1, atts2{a}))
            dispdiff('att', [parent,':',atts2{a}], nfmsg1);
            continue;
        end
    end
end

return



function str = shape2str(shape)
% Returns display string for shape vector.

str = '(';
str = strcat(str, [num2str(shape(1)), 'r x']);
for d = 2:length(shape)
    str = strcat(str, [' ', num2str(shape(d)), 'c']);
    if (d < length(shape))
        str = strcat(str, ' x');
    end
end
str = strcat(str, ')');

return



function dispdiff(elem, elemname, msg, diff1, diff2, opts)
% Displays difference.

disp([upper(elem), ' > ', upper(elemname), ': ', msg]);
if (nargin > 5)
    pad = '       ';
    % Check opts.
    if (opts.verbose)
        if (isstr(diff1) & isstr(diff2))
            disp([pad,'1 > ', diff1]);
            disp([pad,'2 > ', diff2]);
        else
            data1 = diff1;
            data2 = diff2;
            inds = find(data1 ~= data2);
            maxdisp = 10;
            showtotal = false;
            for v = 1:length(inds)
                disp([pad,'[',num2str(inds(v)), '] 1 > ',num2str(data1(inds(v))),', 2 > ',num2str(data2(inds(v)))]);
                if (v == maxdisp)
                    showtotal = true;
                    break;
                end
            end
            if (showtotal)
                disp([pad,'... ', num2str(length(inds)) ,' total value differences']);
            end
        end
    end
end

return
