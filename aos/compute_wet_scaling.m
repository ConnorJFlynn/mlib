function [aip,wet_scaling] = compute_wet_scaling(aip);
% [aip,wet_scaling] = compute_wet_scaling(aip);
% Computes scaling to match wet neph to dry neph at low RH
if ~exist('aip','var')
   aip = ancload;
elseif ~isstruct(aip)&&exist(aip,'file')
   aip =ancload(aip);
end
%%
fig = figure;
sz_num = 0;
for sz_str = {'10um_','1um_'}
   sz_str = char(sz_str);
%    sz_num = sz_num + 1;
%    wet_scaling.size_cut{sz_num} = sz_str;
   C_num = 0;
   for C_str = {'B_','G_','R_'}
      C_str = char(C_str);
      C_num = C_num + 1;
      wet_scaling.color{C_num} = C_str;
      B_num = 0;
      for B_str = {'Bbs_','Bs_'}
         B_str = char(B_str);
         B_num = B_num + 1;
         wet_scaling.coef{B_num} = B_str;
         %
         rat = ['Wet_Dry_Ratio_',B_str,C_str,sz_str,'Neph3W'];
         dry = [B_str,C_str,'Dry_',sz_str,'Neph3W_1'];
         wet = [B_str,C_str,'Wet_',sz_str,'Neph3W_2'];
         %
         
%          good =  ...
         good = aip.vars.(rat).data>0 & aip.vars.(wet).data>0  ;
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
         slope = P(1)./mu(2);
         wet_scaling.(['size_',char(sz_str)]).slope(B_num,C_num)=slope;
         offset = P(1).*(-1.*mu(1))./mu(2) + P(2);
         wet_scaling.(['size_',char(sz_str)]).offset(B_num,C_num)= offset;
         scaling = 1./slope;
         wet_scaling.(['size_',char(sz_str)]).scaling(B_num,C_num)=scaling;
         
         figure(fig);
         plot(xy_lims,xy_lims,'k--');
         plot(xy_lims,polyval(P,xy_lims,[],mu),'r-');
         %          plot([0,max([xl,yl])],[0,max([xl,yl])],'k--');
         %          plot(aip.vars.(dry).data(good_n_dry),polyval(P,aip.vars.(dry).da
         %          ta(good_n_dry),[],mu),'r-');
         title({[B_str, C_str, sz_str,': WetNeph vs DryNeph, low RH'];...
            [sprintf('Slope=%2.2f, Offset=%2.2f',[P(1)./mu(2),P(1).*(-1.*mu(1))./mu(2) + P(2)])]},...
            'interp','none');
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
      end %Bs,Bbs loop
   end %color loop
end %size loop
%%
wet_scaling.size_10um_.slope
wet_scaling.size_10um_.offset
wet_scaling.size_1um_.slope
wet_scaling.size_1um_.offset


%%
return
