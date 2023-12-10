function [out] = qry_sbdart(in_args,fig)
%w = qry_sbdart(in_args,fig);
% Writes qry (in_args) to INPUT, runs SBDART
% parses output depending on iout

% if ~exist('in_path','var')|~exist(in_path,'dir')
%     in_path = getdir;
% end
if ~isavar('fig')
   fig = [];
end
in_path = getpath('sbdart.exe','sbdart.mat','Select path to SBDART executable.');
% if ~isavar('outs')||isempty('outs')
%    outs = 'outs.dat';
% end
% if ~isavar('how')||isempty('how')
%    how = '>';
% end
% how = [' ',how,' '];


if ~iscell(in_args)
   qry = in_args;
   field = fieldnames(qry);
   for f = 1:length(field)
      if ~strcmp(upper(field{f}),field{f})
         qry.(upper(field{f})) = qry.(field{f});
         qry = rmfield(qry,field{f});
      end
   end
   in_args = qry;

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
% system([[in_path,'sbdart.exe '],how, outs]);
[s,w] = system([in_path,'sbdart.exe ']);
% system(['bash -c /cygdrive/c/mlib/sbdart/sbdart_exe.exe > out.dat']); [s,w] = system(['C:\cygwin\bin\bash -c sbdart']);
cd(ret);
if isfield(qry,'IOUT')
   iout = qry.IOUT;
else 
   iout=10;
end

   if iout == 1
      out = textscan(w,'%f %f %f %f %f %f %f %f ', 'headerlines',3);
   elseif iout == 6 % sky scan with radiances
         out = plot_iout6(in_args,w,fig);
   elseif iout == 10
      out = textscan(fid,'%f %f %f %f %f %f %f %f ', 'headerlines',3);
   elseif iout == 21 %PPL or ALM
      warning('Use iout 6 instead of iout 21');
      line_1 = []; fid = w;
      while isempty(line_1)
         [line_1,fid] = getl(fid);
      end

      A = textscan(line_1,'%f'); A = A{1}; out.wl = mean(A(1:2));
      out.BOTDN = A(7); out.BOTDIR = A(9); out.BOTDIF = A(7)-A(9); out.DIRN2DIF = A(9)./out.BOTDIF;
      [line_2,fid] = getl(fid); B = textscan(line_2,'%f'); B = B{:}; nphi = B(1); nzen=B(2);
      out.phi = [];
      for i = 1:ceil(nphi./10)
         [C,fid] = getl(fid); C = textscan(C,'%f'); C = C{:}; out.phi = [out.phi; C];
      end
      out.ZA = [];
      for i = 1:ceil(nzen./10)
         [D,fid] = getl(fid); D = textscan(D,'%f'); D = D{:}; out.ZA = [out.ZA; D];
      end
      rads = [];
      for r = 1:nzen
         rad = [];
         for c = 1:ceil(nphi./20)
            [E,fid] = getl(fid); E = textscan(E,'%f'); E = E{:};
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
         aod = ang_coef(in_args.QBAER(1), in_args.ABAER, in_args.WLBAER(1), out.wl);
         ssa = polyval(polyfit(in_args.WLBAER, in_args.WBAER, 1),out.wl);
         txt_str = {sprintf('SZA = %2.1f',in_args.SZA); sprintf('AOD = %1.3f',aod); sprintf('WL = %3.2f nm',out.wl*1e3);...
            sprintf('SSA = %0.3f',ssa); sprintf('Dir2DifH = %1.2f',out.DIRN2DIF)};

         if nzen>nphi %Then it is PPL

            figure_(21);close(21); figure_(21)

            out.zrad = interp1(out.degs, out.rads, 0,'linear','extrap');
            plot(out.degs(out.degs<qry.SZA), out.rads(out.degs<qry.SZA),'-',...
               out.degs(out.degs>qry.SZA), out.rads(out.degs>qry.SZA),'r-',...
               0,out.zrad,'mo'); logy;


            xlabel('Zenith Angle [degrees]'); ylabel('radiance [W/(m^2 um sr)]');yl = ylim; hold('on'); plot([qry.SZA, qry.SZA], yl,'k--')
            tb = annotation('textbox','string',txt_str, 'position',[.1589,.6545,.23,.25])
            tx = text(5,zrad,sprintf('zrad = %1.3f',zrad),'color', 'm');
            hold('on');
            figure;
            plot(abs(out.degs(out.degs<qry.SZA)-qry.SZA), out.rads(out.degs<qry.SZA),'-',abs(out.degs(out.degs>qry.SZA)-qry.SZA), out.rads(out.degs>qry.SZA),'r-');
            xlabel('Scattering Angle[degrees]'); ylabel('radiance [W/(m^2 um sr)]'); yl = ylim;logy;
            title(['SBART PPL Sky Scan ', sprintf('SZA = %g',qry.SZA)]); hold('off');
            tb = annotation('textbox','string',txt_str, 'position',[.6589,.6545,.23,.25])

         else
            if isgraphics(44)
               figure_(44);
               hold('on')
            else
               figure_(11);hold('off')
            end

            out.SA = scat_ang_degs(ones(size(out.degs)).*in_args.SZA, ones(size(out.degs)).*0, ones(size(out.degs)).*in_args.SZA, out.phi);

            % plot(out.degs(out.degs<=180), out.rads(out.degs<=180),'r-');
            % xlabel('degrees'); ylabel('radiance [W/(m^2 um sr)]');logy;
            % title(['SBART ALM Sky Scan ', sprintf('SZA = %g',qry.SZA)]);
            % tb = annotation('textbox','string',txt_str, 'position',[.6589,.6545,.23,.25])
            %
            % figure;
            plot(out.SA(out.degs<=180), out.rads(out.degs<=180),'r-'); logy;
            xlabel('Scattering Angle [deg]'); ylabel('radiance [W/(m^2 um sr)]');
            % title(['SBART ALM Sky Scan ', sprintf('SZA = %g',qry.SZA)]);
            tb = annotation('textbox','string',txt_str, 'position',[.6589,.6545,.23,.25]);
         end
      end
   else
      out = fprintf('%s',w);
   end
   % 
   % fclose(fid);
   % delete(fout);
end
%%
