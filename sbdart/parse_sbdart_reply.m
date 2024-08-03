function out = parse_sbdart_reply(w,qry,fig)
% out = parse_sbdart_reply(w,qry);
% Parse reply "w" based on qry.IOUT value
% out is a struct with some default and some optional fields


if isfield(qry,'IOUT')
   iout = qry.IOUT;
elseif isfield(qry,'iout')
   iout = qry.iout;
else  
   iout=10;
end

   if iout == 1
      A = textscan(w,'%f %f %f %f %f %f %f %f ', 'headerlines',3);
      out.WL = A{1}; out.FFV = A{2}; out.TOPDN = A{3}; out.TOPUP = A{4}; out.TOPDIR = A{5};
      out.BOTDN = A{6}; out.BOTUP = A{7}; out.BOTDIR = A{8}; 
      out.BOTDIF = out.BOTDN-out.BOTDIR; out.DIRN2DIF = out.BOTDIR./out.BOTDIF;
   elseif iout == 6 % sky scan with radiances
      out = parse_iout6_(w,qry);
     if isavar('fig') 
        out = plot_iout6_(out,qry,fig);
     end
   elseif iout == 10
      A = textscan(fid,'%f %f %f %f %f %f %f %f ', 'headerlines',3);
      out.WLINF = A{1}; out.WLSUP = A{2}; out.FFEW = A{3}; out.TOPDN = A{4}; out.TOPUP = A{5}; out.TOPDIR = A{6};
      out.BOTDN = A{7}; out.BOTUP = A{8}; out.BOTDIR = A{9}; 
      out.BOTDIF = out.BOTDN-out.BOTDIR; out.DIRN2DIF = out.BOTDIR./out.BOTDIF;
   elseif iout == 21 %PPL or ALM
      warning('Use iout 6 instead of iout 21');
      % out = parse_iout21_(w,qry);
      % out = plot_iout21(out,fig);

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
