%plot_gridcellboundaries_and_points.m
figure(222)
% latuse=ones(length(jxuse),1)*latMODalb(jyuse);
% lonuse=lonMODalb(jxuse)'*ones(1,length(jyuse));
% inval=inpolygon(lonuse,latuse,lonout(jj,:),latout(jj,:));
% [ri,rj]=find(inval==1);
plot(lonout(jj,:),latout(jj,:),'bo--','markersize',10,'markerfacecolor','b','linewidth',2)
hold on
plot(Longitude_fl(iguse(jj)),Latitude_fl(iguse(jj)),'bo','markersize',10,'linewidth',2)
plot(lonuse(unique(ri),unique(rj)),latuse(unique(ri),unique(rj)),'c.','markersize',8)
[rizero,rjzero]=find(inval==0);
if ~isempty(rizero) & ~isempty(rjzero)
 plot(lonuse(unique(rizero),unique(rjzero)),latuse(unique(rizero),unique(rjzero)),'rs','markersize',9)
end   
