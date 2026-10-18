% Filter data
d_filt = op_filter(d, 5);
specs = d.specs;
specs_filt = d_filt.specs;

% Calculate noise floor
nf = mean(abs(specs(1:300)));

% Identify peaks (regardless of phasing)
[~, loc, ~, ~] = findpeaks(flip(real(specs_filt)), flip(d.ppm),'MinPeakDistance',0.2,'MinPeakProminence',nf*3,'MaxPeakWidth',3);
% [pks2, loc2, ~, prom2] = findpeaks(-flip(specs), flip(d2.ppm),'MinPeakDistance',0.2,'MinPeakProminence',nf,'MaxPeakWidth',3);
% pks = [pks, pks2]; loc = [loc, loc2]; prom = [prom, prom2];

% Remove peaks near water (if water-suppressed)
if d.flags.isWaterSuppressed
    wl = find(loc < 4.65-0.5);
    wr = find(loc > 4.65+0.5);
    loc = [loc(wl), loc(wr)];
end

% Find peak indices
pkidx = zeros(length(loc),1);
for i = 1:length(loc)
    pkidx(i) = find(d.ppm == loc(i));
end

% Measure phase of peaks
pkph = angle(specs(phidx));