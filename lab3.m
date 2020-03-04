%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
close all
clear
output_dir = 'output';
warning('off', 'MATLAB:MKDIR:DirectoryExists');
mkdir(output_dir)
img_idx = 0;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% C1
filename = 'lenaG';
files_dir = 'files';
bmp_path = fullfile(files_dir, strcat(filename, '.bmp'));
bmp_img = imread(bmp_path);
img_fft_plot(bmp_img);
set(gcf, 'Name', "FFT Plot")
set(gcf,'Position',[100 100 600 200])
saveas(gcf, fullfile(output_dir, strcat('fft_plot', '.png')))

%% C2
img_dct_plot(bmp_img);
set(gcf, 'Name', "DCT Plot")
set(gcf,'Position',[100 100 400 200])
saveas(gcf, fullfile(output_dir, strcat('dct_plot', '.png')))

%% C3
img_fht_plot(bmp_img);
set(gcf, 'Name', "FHT Plot")
set(gcf,'Position',[100 100 400 200])
saveas(gcf, fullfile(output_dir, strcat('fht_plot', '.png')))

%% C4/C5/C6/C7/C8
gn_img.name = 'Gaussian 20';
gn_img.img = add_gaussian_noise(bmp_img, 20);
un_img.name = 'Uniform (0.25)';
un_img.img = add_uniform_noise(bmp_img, 0.5);
imgs = {gn_img, un_img};

for i=1:length(imgs)
    img = imgs{i}.img;
    img_name = imgs{i}.name;
    double_img = im2double(img);
   
    kernels = {};
    % Create Gaussian Kernels
    gk_sds = [10, 20, 30, 5, 3];
    for g=1:length(gk_sds)
        sd = gk_sds(g);
        gk.name = sprintf('SD = %d', sd);
        gk.kernel = fspecial('gaussian', size(double_img), sd);
        kernels{length(kernels) + 1} = gk;
    end
    % Create Box Kernels
    box_xys = {[5, 5], [10, 10], [20, 20]};
    for b=1:length(box_xys)
        xy = box_xys{b};
        bk.name = sprintf('Box [%d x %d]', xy(1), xy(2));
        bk.kernel = make_box_kernel(size(double_img), xy);
        kernels{length(kernels) + 1} = bk;
    end
    % Process Kernel Filtering
    for k=1:length(kernels)
        kernel = kernels{k}.kernel;
        f_kernel = rot90(kernel, 2);
        conv_img = conv2(double_img, f_kernel);
        fft_conv_img = fftshift(ifft2(fft2(double_img) .* fft2(kernel)));
        assert(all(real(fft_conv_img), 'all'), "Inverse FFT got Complex Result")
        
        fig_name = kernels{k}.name;
        figure('Name', fig_name)
        tiledlayout(1, 3)
        nexttile
        imshow(double_img)
        title(fig_name)
        nexttile
        [xs, ys] = get_centre_indexes(size(conv_img), size(double_img));
        imshow(conv_img)
        title("Convolution")
        nexttile
        imshow(fft_conv_img)
        title("FFT Convolution")
        
        set(gcf,'Position',[100 100 600 200])
        [img_idx, filename] = make_filename(img_idx, img_name, fig_name);
        saveas(gcf, fullfile(output_dir, strcat(filename, '.png')))
    end
    
    % Median Filtering
    med_xys = [3, 5, 7];
    for m=1:length(med_xys)
        xy = med_xys(m);
        med_img = medfilt2(double_img, [xy, xy]);
        fig_name = sprintf('Median [%d x %d]', xy, xy);;
        figure('Name', fig_name)
        tiledlayout(1, 2)
        nexttile
        imshow(double_img)
        title(fig_name);
        nexttile
        imshow(med_img)
        title('Filtered');
        
        set(gcf,'Position',[100 100 400 200])
        [img_idx, filename] = make_filename(img_idx, img_name, fig_name);
        saveas(gcf, fullfile(output_dir, strcat(filename, '.png')))
    end
    
end

%% FUNCTIONS

function [n_img] = add_gaussian_noise(img, sd)
n_img = img + uint8(sd*randn(size(img)));
end

function [n_img] = add_uniform_noise(img, power)
multiplier = mean(img, 'all') * power * 2;
n_img = img + uint8(multiplier * (rand(size(img)) - 0.5));
end

function fh = img_fft_plot(img)
fft_res = fft2(img);
fft_res = double(fftshift(fft_res));
fft_magnitude = abs(fft_res);
fft_angle = angle(fft_res);

% Plot Space Domain
fh = figure();
tiledlayout(1, 3)
nexttile
imshow(img)
title('Space Domain')
% Plot FFT Magnitude
nexttile
imshow(mat2gray(log(fft_magnitude)));
title('Magnitude')
% Plot FFT Phase
nexttile
imshow(mat2gray(fft_angle));
title('Phase')
end

function fh = img_dct_plot(img)
dct_res = dct2(img);

% Plot Space Domain
fh = figure();
tiledlayout(1, 2)
nexttile
imshow(img);
title('Space Domain')
% Plot FFT Magnitude
nexttile
imshow(log(abs(dct_res)), []);
colormap(gca, gray)
colorbar
title('Coefficents')
end

function Hf = fht(f)
F = fft(f);
Hf = real(F) - imag(F);
end

function fh = img_fht_plot(img)
fht_res = fht(img);

% Plot Space Domain
fh = figure();
tiledlayout(1, 2)
nexttile
imshow(img);
title('Space Domain')
% Plot FFT Magnitude
nexttile
imshow(log(abs(fht_res)), []);
colormap(gca, gray)
colorbar
title('Coefficents')
end

function [kernel] = make_box_kernel(os, ks)
kernel = zeros(os, 'double');
[rxs, rys] = get_centre_indexes(os, ks);
kernel(rxs, rys) = 1 / (numel(rxs) * numel(rys));
end

function [xs, ys] = get_centre_indexes(os, ks)
xs = fix(os(1) / 2 - ks(1) / 2):fix(os(1) / 2 + ks(1) / 2);
ys = fix(os(2) / 2 - ks(2) / 2):fix(os(2) / 2 + ks(2) / 2);
end

function [i, filename] = make_filename(i, img_name, fig_title)
filename = sprintf("%d_%s_%s", i, img_name, fig_title);
filename = lower(filename);
filename = strrep(filename, ' ', '_');
i = i + 1;
end