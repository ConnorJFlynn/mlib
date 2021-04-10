% Sequence of components:
% Vis  36u1
% NIR  47u1
% Splitter F9823
% Shutter
% 10m SAS fiber
%% Transmission of 10 m fiber, 600 micron solid core (10m / Shutter)

bare = SAS_read_Albert_csv;
darks = bare.spec(sum(bare.spec,2)==min(sum(bare.spec,2)),:);
figure; lines = plot(bare.nm,(100./unique(bare.Integration)).*(bare.spec-ones(size(bare.time))*darks), '-'); recolor(lines, [1:length(lines)]); colorbar
bare.peak = (100./unique(bare.Integration)).*bare.spec(sum(bare.spec,2)==max(sum(bare.spec,2)),:);
title('Bare fiber signal levels (per ms)');
%%
Radin = SAS_read_Albert_csv;
darks = Radin.spec(sum(Radin.spec,2)==min(sum(Radin.spec,2)),:);
figure; lines = plot(Radin.nm,(1./unique(Radin.Integration)).*(Radin.spec-ones(size(Radin.time))*darks), '-'); recolor(lines, [1:length(lines)]); colorbar
title('Radin signal levels');
Radin.peak = (Radin.spec(sum(Radin.spec,2)==max(sum(Radin.spec,2)),:))./unique(Radin.Integration);

%%
half = SAS_read_Albert_csv;
darks = half.spec(sum(half.spec,2)==min(sum(half.spec,2)),:);
figure; lines = plot(half.nm,(1./unique(half.Integration)).*(half.spec-ones(size(half.time))*darks), '-'); recolor(lines, [1:length(lines)]); colorbar
title('half signal levels');
half.peak = (1./unique(half.Integration)).*(half.spec(sum(half.spec,2)==max(sum(half.spec,2)),:));

%%
one_in = SAS_read_Albert_csv;
darks = one_in.spec(sum(one_in.spec,2)==min(sum(one_in.spec,2)),:);
figure; lines = plot(one_in.nm,(1./unique(one_in.Integration)).*(one_in.spec-ones(size(one_in.time))*darks), '-'); recolor(lines, [1:length(lines)]); colorbar
title('one_in signal levels');
one_in.peak = (1./unique(one_in.Integration)).*(one_in.spec(sum(one_in.spec,2)==max(sum(one_in.spec,2)),:));
%%

figure; plot(bare.nm, 100.*Radin.peak./bare.peak, 'r-', ...
   bare.nm, 100.*half.peak./bare.peak, 'b-', ...
   bare.nm, 100.*one_in.peak./bare.peak, 'g-');
xlabel('wavelength [nm]');
ylabel('transmission %');
legend('diffuser','1/2" lens', '1" lens')




%%
half = SAS_read_Albert_csv;
darks = half.spec(sum(half.spec,2)==min(sum(half.spec,2)),:);
figure; lines = plot(half.nm,(1./unique(half.Integration)).*(half.spec-ones(size(half.time))*darks), '-'); recolor(lines, [1:length(lines)]); colorbar
title('half signal levels');
half.peak = (1./unique(half.Integration)).*(half.spec(sum(half.spec,2)==max(sum(half.spec,2)),:));

%%
one_in = SAS_read_Albert_csv;
darks = one_in.spec(sum(one_in.spec,2)==min(sum(one_in.spec,2)),:);
figure; lines = plot(one_in.nm,(1./unique(one_in.Integration)).*(one_in.spec-ones(size(one_in.time))*darks), '-'); recolor(lines, [1:length(lines)]); colorbar
title('one_in signal levels');
one_in.peak = (1./unique(one_in.Integration)).*(one_in.spec(sum(one_in.spec,2)==max(sum(one_in.spec,2)),:));
%%
