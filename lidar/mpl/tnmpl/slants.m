% plot 2D slice from one end of scan to other
%%

figure; 
   this = scatter(mplz_day.range.*sin(mplz_day.hk.zenith(tt(1))*pi/180), mplz_day.range.*cos(mplz_day.hk.zenith(tt(1))*pi/180),'.');
   this = recolor_scatr(this,mplz_day.prof(:,tt(1)));
hold('on')
%%
for t = tt(1):tt(2)

   this = scatter(mplz_day.range.*sin(mplz_day.hk.zenith(t)*pi/180), mplz_day.range.*cos(mplz_day.hk.zenith(t)*pi/180),'.');
   this = recolor_scatr(this,mplz_day.prof(:,t));
end
hold('off')
zoom('on')