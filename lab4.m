%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
close all
clear
output_dir = 'output';
warning('off', 'MATLAB:MKDIR:DirectoryExists');
mkdir(output_dir)
img_idx = 0;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% https://www.cis.rit.edu/class/simg712-01/notes/Basic_principles_notes-6-19-2005.pdf
% https://homepages.inf.ed.ac.uk/rbf/HIPR2/stretch.htm

%% D1
filename = 'lenaG.bmp';
files_dir = 'files';
bmp_path = fullfile(files_dir, filename);
bmp_lena_img = imread(bmp_path);
bmp_img = bmp_lena_img;
figure('Name', 'D1_Bins')
bins = {10, 20, 100, 256};
for i=1:numel(bins)
    subplot(1, numel(bins), i);
    imhist(bmp_img, bins{i})
    title(sprintf('Bins: %d', bins{i}))
end
[hist_counts, hist_255_bins] = imhist(bmp_img);
fprintf("PIXEL COUNTS | 52: %d | 181: %d | 232: %d\n", ...
    hist_counts(53), hist_counts(182), hist_counts(233))

%% D2
hist_1_bins = hist_255_bins ./ double(intmax('uint8'));

%% D3
hist_probs = hist_counts ./ sum(hist_counts);
fprintf("PIXEL PROBS | 52: %s | 181: %s | 232: %s\n", ...
    hist_probs(53), hist_probs(182), hist_probs(233))
figure('Name', 'Probability Histogram')
stem(hist_1_bins, hist_probs, 'Marker', 'none')
style_histplot(1)

%% D4
bmp_img_noise = add_gaussian_noise(bmp_img, 20);
fprintf("Min: %d | Max: %d\n", ...
    min(bmp_img_noise, [], 'all'), ...
    max(bmp_img_noise, [], 'all'))

% a
stretched_img = hist_stretch(bmp_img_noise);
% b
clipped_stretch_img = hist_stretch(bmp_img_noise, [0.05, 0.95]);

% c

figure('Name', 'Scaling Methods')
subplot(2, 4, 1)
imshow(bmp_img_noise)
title('Normal')
subplot(2, 4, 5)
[counts, bins] = imhist(bmp_img_noise);
stem(bins, counts, 'Marker', 'none')
style_histplot(255)

subplot(2, 4, 2)
imshow(stretched_img)
title('Stretched')
subplot(2, 4, 6)
[counts, bins] = imhist(stretched_img);
stem(bins, counts, 'Marker', 'none')
style_histplot(255)

subplot(2, 4, 3)
imshow(clipped_stretch_img)
title('Clipped Stretch')
subplot(2, 4, 7)
[counts, bins] = imhist(clipped_stretch_img);
stem(bins, counts, 'Marker', 'none')
style_histplot(255)



%% D6
figure();
ps = {1/2, 1/3, 1/5, 2};

for i=1:numel(ps)
    p_img = mat2gray(bmp_img) .^ ps{i};
    subplot(2, numel(ps), i);
    imshow(p_img)
    title(sprintf('p = %.2f', ps{i}))
    subplot(2, numel(ps), numel(ps) + i);
    [counts, bins] = imhist(p_img);
    stem(bins, counts, 'Marker', 'none')
    style_histplot(1)
end


%% D7
neg_bmp_img = intmax('uint8') - bmp_img;

%% D8
inv_bmp_img = 1 ./ double(bmp_img);
inv_bmp_img = hist_stretch(inv_bmp_img);
figure('Name', 'Test')
subplot(2, 2, 1)
imshow(neg_bmp_img)
title('Negated')
subplot(2, 2, 3)
[counts, bins] = imhist(neg_bmp_img);
stem(bins, counts, 'Marker', 'none')
style_histplot(255)

subplot(2, 2, 2)
imshow(inv_bmp_img)
title('Inverted')
subplot(2, 2, 4)
[counts, bins] = imhist(inv_bmp_img);
stem(bins, counts, 'Marker', 'none')
style_histplot(255)

%% D5
filename = 'NaturalView.jpg';
files_dir = 'files';
bmp_path = fullfile(files_dir, filename);
bmp_natural_img = imread(bmp_path);
bmp_img = bmp_natural_img;
stretch_bmp_img = hist_stretch(bmp_img);


%% D9
[eq_bmp_img, eq_map] = histeq(bmp_img);
figure('Name', 'Stretch_Equalisation')
subplot(2, 3, 1)
imshow(bmp_img)
title('Normal')
subplot(2, 3, 4)
[counts, bins] = imhist(bmp_img);
stem(bins, counts, 'Marker', 'none')
style_histplot(255)

subplot(2, 3, 2)
imshow(stretch_bmp_img)
title('Stretched')
subplot(2, 3, 5)
[counts, bins] = imhist(stretch_bmp_img);
stem(bins, counts, 'Marker', 'none')
style_histplot(255)

subplot(2, 3, 3)
imshow(eq_bmp_img)
title('Equalisation')
subplot(2, 3, 6)
[counts, bins] = imhist(eq_bmp_img);
stem(bins, counts, 'Marker', 'none')
style_histplot(255)


function style_histplot(mval)
hAx = gca;
set(hAx, 'XLim',[0 1], 'XTickLabel',[], 'Box','on')
hAx2 = axes('Position',get(hAx,'Position'), 'HitTest','off');
image(0:mval, [0 1], repmat(linspace(0,1,256),[1 1 3]), 'Parent',hAx2)
set(hAx2, 'XLim',[0 mval], 'YLim',[0 1], 'YTick',[], 'Box','on')
set(hAx, 'Units','pixels')
p = get(hAx, 'Position');
set(hAx, 'Position',[p(1) p(2)+26 p(3) p(4)-26])
set(hAx, 'Units','normalized')
set(hAx2, 'Units','pixels')
p = get(hAx2, 'Position');
set(hAx2, 'Position',[p(1:3) 26])
set(hAx2, 'Units','normalized')
linkaxes([hAx;hAx2], 'x')
set(gcf, 'CurrentAxes',hAx)
end

function [n_img] = add_gaussian_noise(img, sd)
n_img = img + uint8(sd*randn(size(img)));
end


function [res] = hist_stretch(img, percentiles)
if ~exist('percentiles','var')
    percentiles = [0.001 1.0];
end
% Convert to use double
use_int = ~isa(img, 'double');
dimg = double(img);

% Set output bounds
a = 0;
if use_int
    b = double(intmax('uint8'));
else
    b = 1;
end
% Calculate CDF
[counts, bins] = imhist(img);
cdf = cumsum(counts);
cdf = cdf/cdf(end);
% Get clipped min and max
c = bins(find(cdf >= percentiles(1), 1));
d = bins(find(cdf >= percentiles(2), 1));
% Apply normalisation
res = (img - c) * ((b - a) / (d - c)) + a;
if use_int
    res = uint8(res);
end
end
