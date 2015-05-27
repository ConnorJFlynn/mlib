function aip = compute_wet_scaling(aip);
if ~exist('aip','var')
   aip = ancload;
elseif ~isstruct(aip)&&exist(aip,'file')
   aip =ancload(aip);
end

%%
%fig = figure;
for B_str = {'Bbs_','Bs_'}
   B_str = char(B_str);
   for C_str = {'B_','G_','R_'}
      C_str = char(C_str);
      for sz_str = {'10um_','1um_'}
fig = figure;
         sz_str = char(sz_str);
         %
         rat = ['Wet_Dry_Ratio_',B_str,C_str,sz_str,'Neph3W'];
         dry = [B_str,C_str,'Dry_',sz_str,'Neph3W_1'];
         wet = [B_str,C_str,'Wet_',sz_str,'Neph3W_2'];
         %
         
         good = aip.vars.(rat).data>0 & ...
            aip.vars.(dry).data>0 & ...
            aip.vars.(wet).data>0  ;
         good_n_dry = good & aip.vars.calculated_RH_NephVol_Wet.data >0 & ...
            aip.vars.calculated_RH_NephVol_Wet.data < 40 & ...
            aip.vars.RH_NephVol_Dry.data > 0 & ...
            aip.vars.RH_NephVol_Dry.data < 20;
         
         %
         rh_wet_by_dry = aip.vars.calculated_RH_NephVol_Wet.data./aip.vars.RH_NephVol_Dry.data;
         wet_by_dry = aip.vars.(wet).data./...
            aip.vars.(dry).data;
         
         %

         scatter(aip.vars.(dry).data(good_n_dry), aip.vars.(wet).data(good_n_dry),8,rh_wet_by_dry(good_n_dry));
         colorbar
         xl = xlim;
         yl = ylim;
         xy_lims = [min([xl,yl]),max([xl,yl])];
         hold('on');
%          [P, S, mu] = rmad_polyfit(aip.vars.(dry).data(good_n_dry), aip.vars.(wet).data(good_n_dry),1);
         [P, S, mu] = rmad_bisec(aip.vars.(dry).data(good_n_dry), aip.vars.(wet).data(good_n_dry));        

        display_slope=P(1)./mu(2);
	display_offset=P(1).*(-1.*mu(1))./mu(2) + P(2);
   
        table1=double([display_slope, display_offset])
        % This will work if table1 is type "double", but not for "single".
	save ('slopes.txt', 'table1', '-ascii', '-append')
   % Alternately, use fopen like this:
   fid = fopen('slopes_2.txt','a');
   fprintf(fid,'%3.4f %3.4f \n',table1);;
   fclose(fid);

         figure(fig);
         plot(xy_lims,xy_lims,'k--');  
         plot(xy_lims,polyval(P,xy_lims,[],mu),'r-');
%          plot([0,max([xl,yl])],[0,max([xl,yl])],'k--');
%          plot(aip.vars.(dry).data(good_n_dry),polyval(P,aip.vars.(dry).da
%          ta(good_n_dry),[],mu),'r-');
         title({[B_str, C_str, sz_str,': WetNeph vs DryNeph, low RH'];...
            [sprintf('Slope=%2.2f, Offset=%2.2f',[P(1)./mu(2),P(1).*(-1.*mu(1))./mu(2) + P(2)])]},...
            'interp','none');
	
	table2=[B_str, C_str, sz_str]


         xlabel('dry Neph total scattering, RH < 20%');
         ylabel('wet Neph total scattering, RH < 40%');
         grid('on');
         
         xlim([min([xl,yl]),max([xl,yl])]);
         ylim(xlim);
         hold('off');
%  The following code tested bi-directional fit as the mean of a fit of x
%  vs y and then y vs x.  It appears to be slightly inferior to the robust
%  fit already being used.
%          Px = polyfit(aip.vars.(dry).data(good_n_dry), aip.vars.(wet).data(good_n_dry),1);
%          Py = polyfit( aip.vars.(wet).data(good_n_dry),aip.vars.(dry).data(good_n_dry),1);
%          m_bar = (Px(1)+1./Py(1))./2;
%          yint_bar = (Px(2)-Py(2)./Py(2))./2;
%       %%
%       hold('on')
%       plot(aip.vars.(dry).data(good_n_dry),polyval([m_bar,yint_bar],aip.vars.(dry).data(good_n_dry)),'b-')
%       
%       


      %%
         [pname,fname,ext] = fileparts(aip.fname);
         [~,fname_] = strtok(fliplr(fname),'.');fname_ = fliplr(fname_)
         saveas(gcf,[pname,filesep,fname_, B_str,C_str,sz_str,'_WetNeph_vs_DryNeph_bisec.png'])
      end %size loop
   end %color loop
end %Bs,Bbs loop
%%
figure; 
ax(1) = subplot(2,1,1);
plot(serial2doy(aip.time(good)), [aip.vars.(wet).data(good);aip.vars.(dry).data(good)],'o');
legend('wet','dry')
title([B_str,C_str,sz_str],'interp','none')
ax(2) = subplot(2,1,2);
plot(serial2doy(aip.time(good)), aip.vars.(wet).data(good) - aip.vars.(dry).data(good),'r.');
title('Wet - Dry')

good_rh = aip.vars.calculated_RH_NephVol_Wet.data>0 & aip.vars.RH_NephVol_Dry.data>0;
figure; 
plot(serial2doy(aip.time(good_rh)), aip.vars.calculated_RH_NephVol_Wet.data(good_rh),'k.',...
   serial2doy(aip.time(good_rh)), aip.vars.RH_NephVol_Dry.data(good_rh),'r.');
ax(3) = gca;
lg= legend('calculated_RH_NephVol_Wet','Dry_RH');
set(lg ,'interp','none');
linkaxes(ax,'x')
%%
%
figure; plot(serial2Hh(aip.time(good)), aip.vars.(rat).data(good),'k.',...
serial2Hh(aip.time(good)),wet_by_dry(good),'rx');
title([B_str,C_str,sz_str],'interp','none');
legend('file','bias subtracted')

%%
figure; plot(serial2Hh(aip.time(good)), aip.vars.(dry).data(good),'k.',...
serial2Hh(aip.time(good)),aip.vars.(wet).data(good),'b.');
title([B_str,C_str,sz_str],'interp','none');
legend('dry','wet')


return