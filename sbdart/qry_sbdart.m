function [out] = qry_sbdart(in_args,outs,how);
%w = qry_sbdart(in_args);
% Writes qry (in_args) to INPUT, runs SBDART
% Pipes stdout to "out". If "how" is > (or empty or absent) creates output
% If "how" is >>, concatenates to an existing file if any. 
% parses output depending on iout

% if ~exist('in_path','var')|~exist(in_path,'dir')
%     in_path = getdir;
% end
in_path = getpath('sbdart.exe','Select path to SBDART executable.');
if ~isavar('outs')||isempty('outs')
    outs = 'outs.dat';
end
if ~isavar('how')||isempty('how')
    how = '>';
end
how = [' ',how,' '];
if ~iscell(in_args)
    qry = in_args;
    fields = fieldnames(in_args);
    for ff = 1:length(fields)
        qry_cell(2*ff -1) = fields(ff);
        qry_cell(2*ff) = {in_args.(fields{ff})};
    end
else
    qry_cell = in_args;
end

fid = fopen([in_path, 'INPUT'],'wt');
y = (['&INPUT']);
fprintf(fid,'%s \n',y);

for ff = 1:2:length(qry_cell)
    fprintf(fid,'%s = ',upper(qry_cell{ff}));
    if isnumeric(qry_cell{ff+1})
        fprintf(fid, ' %g, ',qry_cell{ff+1});
    else fprintf(fid,'%s, ',qry_cell{ff+1});
    end
    fprintf(fid,' \n');
end
y = (['/']);
fprintf(fid,'%s \n',y);


fclose(fid);
ret = pwd;
cd(in_path);
system([[in_path,'sbdart.exe '],how, outs]);
% system(['bash -c /cygdrive/c/mlib/sbdart/sbdart_exe.exe > out.dat']);
cd(ret);
q = 1; iout = [];
while q< length(qry_cell) && isempty(iout)
    if ~isempty(strfind('iout',lower(qry_cell{q})))&&isnumeric(qry_cell{q+1})
        iout = qry_cell{q+1};
    end
    q = q +1;
end
fout = [in_path, 'outs.dat'];
if exist(fout,'file')
    fid = fopen(fout,'r');
    if iout == 10
        out = textscan(fid,'%f %f %f %f %f %f %f %f ', 'headerlines',3);
    elseif iout == 21 %PPL or ALM
       line_1 = [];
       while isempty(line_1)
        line_1 = fgetl(fid);
       end

        A = textscan(line_1,'%f'); A = A{1}; out.wl = mean(A(1:2));
        line_2 = fgetl(fid); B = textscan(line_2,'%f'); B = B{:}; nphi = B(1); nzen=B(2);
        out.phi = [];
        for i = 1:ceil(nphi./10)
            C = fgetl(fid); C = textscan(C,'%f'); C = C{:}; out.phi = [out.phi; C];
        end
        out.ZA = [];
        for i = 1:ceil(nzen./10)
            D = fgetl(fid); D = textscan(D,'%f'); D = D{:}; out.ZA = [out.ZA; D];
        end
        rads = [];
        for r = 1:nzen
            rad = [];
            for c = 1:ceil(nphi./20)
                E = fgetl(fid); E = textscan(E,'%f'); E = E{:};
                rad = [rad,E'];
            end
            rads = [rads; rad];
        end
        out.rads = [];
        if nzen>nphi
            for n = 1:nphi
                out.rads = [out.rads; rads(:,n)];
            end
            out.degs = [180-out.ZA;out.ZA-180];
        else
            for m = 1:nzen
                out.rads = [out.rads, rads(m,:)];
            end
            out.rads = out.rads';
            out.degs = out.phi;
        end
        [out.degs, ij] = unique(out.degs); out.rads = out.rads(ij);
        if nzen>1 || nphi > 1
           figure;
           if nzen>nphi
              plot(out.degs(out.degs<qry.SZA), out.rads(out.degs<qry.SZA),'-',out.degs(out.degs>qry.SZA), out.rads(out.degs>qry.SZA),'-');
              xlabel('degrees'); ylabel('radiance');yl = ylim; hold('on'); plot([qry.SZA, qry.SZA], yl,'k--');
              title(['SBART PPL Sky Scan ', sprintf('SZA = %g',qry.SZA)]); hold('off')
           else
              plot(out.degs(out.degs<=180), out.rads(out.degs<=180),'-');
              xlabel('degrees'); ylabel('radiance');
              title(['SBART ALM Sky Scan ', sprintf('SZA = %g',qry.SZA)]);
           end
        end
    else
       out = fprintf(fid,'%s');
    end

    fclose(fid);
    delete(fout);
end
%%
