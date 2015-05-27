function m300 = plot_spp(m300, tag);

if ~exist('m300','var')
   m300 = read_m300(getfullname_('*.sea','m300'));
end
tags = fieldnames(m300.tag_types); tags(1) = [];
for t = length(tags):-1:1
   if m300.tag_types.(tags{t})(2)~=75
      tags(t) = [];
   end
end
if ~exist('tag','var')
   mm = menu('Select the tag for the SPP to plot.',tags);
   tag = str2double(tags{mm}(5:end));
else
   for t = length(tags):-1:1
      if ~isempty(findstr(tags{t},num2str(tag)))
         mm = t;
      end
   end
end
% Get the address for the tag of the SPP we're reading
addr = dec2hex(m300.tag_types.(tags{mm})(3));

m300 = parse_tag(m300,tag);
files = fieldnames(m300.files);
for f = 1:length(files)
   nlines = [0,find(real(m300.files.(files{f}).filedata)==10)];
   for n = 1:(length(nlines)-1)
      this_line = m300.files.(files{f}).filedata(1+nlines(n):nlines(n+1));
      if ~isempty(findstr('address',lower(this_line))) && ~isempty(findstr(addr,this_line))
         brd.brdname = m300.files.(files{f}).filename;
         %We've found the right file, so now parse for range, number of
         %channels, and channel def file
         this_spot = findstr('Range =',m300.files.(files{f}).filedata);
         brd.range = sscanf(m300.files.(files{f}).filedata(this_spot+length('range ='):end),'%d');
         this_spot = findstr('Channels =',m300.files.(files{f}).filedata);
         brd.channels = sscanf(m300.files.(files{f}).filedata(this_spot+length('Channels ='):end),'%d');
         this_spot = findstr('FileName =',m300.files.(files{f}).filedata);
         brd.filename = sscanf(m300.files.(files{f}).filedata(this_spot+length('FileName ='):end),'%s');
      end
   end
end
% Now go back and search for filename matching brd.filename
for f = 1:length(files)
   if strfind(m300.files.(files{f}).filename,brd.filename)
      brd.ch_def = m300.files.(files{f}).filedata;
   end
end

C = textscan(brd.ch_def,'%d %f %f %f %f', 'commentStyle',';');
brd.bin_threshold = C{brd.range+1};
brd.bin_width = [brd.bin_threshold(1);diff(brd.bin_threshold)];
tag_fields = fieldnames(m300.(tags{mm}));
offset = 0;
if brd.range >2
   offset = brd.range-2;
end
adjThreshold = brd.bin_threshold+double(4096*offset);
min_len = min([brd.channels length(adjThreshold)]);

[outpath, fstem,ext] = fileparts(m300.fullname);
tag_str = tags{mm};
figure;
ax(1) = subplot(2,1,1); pl = plot([1:min_len],adjThreshold(1:min_len),'ro');
set(pl,'markerfacecolor','b');
% set(get(gca,'children'),'markerfacecolor','b');
xlabel('Channel number'),ylabel('Threshold');
title_ln1 = [tags{mm},', Address:',addr, ', Board: ',brd.brdname(1:end-1)];
title_ln2 = ['Range ',num2str(brd.range),', ',num2str(brd.channels), ' channels, table: ',brd.filename];
title({title_ln1,title_ln2},'interpreter','none');
ax(2) = subplot(2,1,2); pl = plot([1:min_len],brd.bin_width(1:min_len),'bo');
set(pl,'markerfacecolor','r');
xlabel('Channel number'),ylabel('bin width');
linkaxes(ax,'x')
sav = menu('Save this plot?','No','Yes');
if sav>1
   print(gcf,[outpath,fstem,'.',tag_str,'.bin_settings.png'],'-dpng');
end
for tf = length(tag_fields):-1:1
   if ~isempty(findstr('Timebase_',tag_fields{tf}))
      %plot raw cts, and adjusted for bin-width
      figure;
      plot([1:brd.channels],cumsum(m300.(tags{mm}).(tag_fields{tf}).bins,2));
      xl = xlim; yl = ylim;
      [range_lims] = floor(interp1(adjThreshold(1:min_len),[1:min_len],[4096 2*4096],'linear','extrap'));
      if (brd.range > 2)||(brd.range == 1)
         line([range_lims(1), range_lims(1)], yl,'linestyle','--','color','k');
      end
      if (brd.range > 3)||(brd.range == 1)
         line([range_lims(2), range_lims(2)], yl,'linestyle','--','color','k');
      end
      ylabel('cumulative counts per bin')
      xlabel('bin number')
      title({title_ln1,fstem},'interpreter','none');
%       sav = menu('Save this plot?','No','Yes');
%       if sav>1
         print(gcf,[outpath,fstem,'.',tag_str,'.bin_cts.png'],'-dpng');
%       end

      figure;
      adjch = double(m300.(tags{mm}).(tag_fields{tf}).bins)...
         ./(double(brd.bin_width(1:30))*ones(size(m300.(tags{mm}).(tag_fields{tf}).time)));
      adjsum = cumsum(adjch,2);

      plot(adjThreshold(1:min_len),adjsum(1:min_len,:),'-')
      title({title_ln1, fstem},'interpreter','none');
      ylabel('cumulative counts/bin width')
      xlabel('bin threshold')
      % axes(ax(1));
      yl = ylim;
      if (brd.range > 2)||(brd.range == 1)
         line([4096, 4096], yl,'linestyle','--','color','k');
      end
      if (brd.range >3)||(brd.range == 1)
         line([2*4096, 2*4096], yl,'linestyle','--','color','k');
      end
      % Repeatedly zoom into the peak, computing cm until satisified

      done = false;
      
      zoom('on')
      while ~done
         zooming = true;
         while zooming
            zooming = menu('Done zooming?', 'OK');
            if zooming >0
               zooming = false;
            end
            vp = axis;
            pts = find((adjThreshold>=vp(1))&(adjThreshold<=vp(2)));
%             if size(adjsum,2)>1
               adjmax = adjsum(:,end);
%             else
%                adjmax = adjsum;
%             end
            [binpeak,peak_bin] = max(adjmax(pts));
            peakBin = adjThreshold(pts(peak_bin));
            cm = peakBin;
            % peak = d.adjThreshold(pts(peak_bin));
            %%
            if length(pts)>1
               cm = trapz(adjThreshold(pts), adjThreshold(pts).*adjmax(pts))./trapz(adjThreshold(pts), adjmax(pts));
            end
            anchor = [cm,mean([binpeak,vp(4)])];
           ll =  line([cm,cm], [vp(3),1.1*binpeak],'linestyle',':','color','r');
           txt =  text(anchor(1), 1.15*binpeak,{'center-weighted bin';sprintf('%g',cm)},'color','r','HorizontalAlignment','center','VerticalAlignment','bottom');
            % text(d.peakBin, binpeak*1.05,{'peak bin';num2str(d.peakBin)},'color','b','HorizontalAlignment','center','VerticalAlignment','bottom');
            CMBin = cm;
            ylim([vp(3),1.3*binpeak]);
            peak_ok = menu('Satisfied with peak?','No','Yes')
            if peak_ok>1
               disp(num2str(cm))
               done = true;
            else
               delete(txt);
               delete(ll);
            end
         end
      end
      sav = menu('Save this plot?','No','Yes');
      if sav>1
         print(gcf,[outpath,fstem,'.',tag_str,'.cts_per_binwidth.png'],'-dpng');
      end
   end
end
% At this point, we should have the tag number, packet type, and address
% Search through the config files to find the same address
% Find the range, number of bins, and the name of the chan.def file
% Search for chan.def file
% Load the bin table
% Now, we have the number of bins, the range, the bin definition, and the
% data, so plot each Timebase as in plot_pcasp.
