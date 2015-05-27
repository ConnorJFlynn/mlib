function this = cat_dot_timeseries(this,that);
% this = cat_dot_timeseries(this,that);
% Concatenates time-series with time and .t structure along the time
% coordinate dimension.
if size(this.time,1)==1
   [the_times,ii] = unique([this.time, that.time]);
else
   [the_times,ii] = unique([this.time; that.time]);

end
flds = fieldnames(that);
init_time1 = this.time;
init_time2 = that.time;
if isfield(this,'fname')
    if ~isfield(this,'file_num')
        this.file_num = ones(size(this.time));
        fname = this.fname;
        this = rmfield(this,'fname');
        this.fname(1) = {fname};
        this.start_time = this.time(1);
        this.end_time = this.time(end);
    end
    this.fname(length(this.fname)+1) = {that.fname};
    that.file_num = ones(size(that.time)).*length(this.fname);
    this.start_time(end+1) = that.time(1);
    this.end_time(end+1) = that.time(end);

end
flds = fieldnames(that); % Now with 'file_num' included
for f = length(flds):-1:1
               catdim = find(size(this.(flds{f}))==length(init_time1)&size(that.(flds{f}))==length(init_time2));               
            if catdim ==1
                [this_data,NSHIFTS] = shiftdim(this.(flds{f}),catdim-1);
                [that_data,NSHIFTS] = shiftdim(that.(flds{f}),catdim-1);
                this_data = [this_data; that_data];
                this.(flds{f}) = this_data(ii,:);
                this.(flds{f}) = shiftdim(this.(flds{f}),NSHIFTS);
            elseif catdim > 1
                [this_data,NSHIFTS] = shiftdim(this.(flds{f}),catdim-1);
                [that_data,NSHIFTS] = shiftdim(that.(flds{f}),catdim-1);
                this_data = [this_data; that_data];
                this.(flds{f}) = this_data(ii,:);
                this.(flds{f}) = shiftdim(this.(flds{f}),NSHIFTS);
            else
                % Not a time-series field.  Test to see if same in both
                % files.  If not, then concat 
            end
end
if isfield(this,'t')&&isfield(that,'t')
    flds = fieldnames(that.t);
    for f = length(flds):-1:1
        catdim = find(size(this.t.(flds{f}))==length(init_time1)&size(that.t.(flds{f}))==length(init_time2));
        [this_data,NSHIFTS] = shiftdim(this.t.(flds{f}),catdim-1);
        [that_data,NSHIFTS] = shiftdim(that.t.(flds{f}),catdim-1);
        this_data = [this_data; that_data];
        this.t.(flds{f}) = this_data(ii,:);
        this.t.(flds{f}) = shiftdim(this.t.(flds{f}),NSHIFTS);
    end
end
if isfield(this,'t_')&&isfield(that,'t_')
    flds = fieldnames(that.t_);
    for f = length(flds):-1:1
        catdim = find(size(this.t_.(flds{f}))==length(init_time1)&size(that.t_.(flds{f}))==length(init_time2));
        [this_data,NSHIFTS] = shiftdim(this.t_.(flds{f}),catdim-1);
        [that_data,NSHIFTS] = shiftdim(that.t_.(flds{f}),catdim-1);
        this_data = [this_data; that_data];
        this.t_.(flds{f}) = this_data(ii,:);
        this.t_.(flds{f}) = shiftdim(this.t_.(flds{f}),NSHIFTS);
        this.t_ij.(flds{f}) = find(this.t_.(flds{f}));
    end
end


return