function xy_den_scat_rbifit(X,Y, xstr,ystr,title_str,M,dist)
% if ~isavar('H')
%    H = gcf;
% end
% if ~ishandle(H)
%    if isavar('M')
%       dist = M;
%       M = H;
%       H = gcf;
%    end
% end
if ~isavar('M')
   M = 3;
end
if ~isavar('dist')
   dist = 1./sqrt(length(X));
end
scale = 1;
[good,P_bar] = rbifit(X, Y,M,0);
D = ptdens(X,Y,dist.*scale);
% figure_(H);
scatter(X, Y,4,D,'filled'); axis('square'); cb =colorbar;

xl = xlim; yl = ylim;
xlim([0,floor(10.*min([xl(2),yl(2)]))./10]);
ylim(xlim); 
cv = caxis; caxis([0,cv(2)]);

hold('on'); 
plot(ylim, ylim, 'k--','LineWidth',4);
plot(ylim, polyval(P_bar,ylim),'b-','LineWidth',4); 
hold('off')

[gt,txt, stats] = txt_stat(X(good), Y(good),P_bar); set(gt,'color','b');
%Select figure to add stats

title({title_str_top; title_str_bot});
xlabel(x_str); ylabel(y_str);

return