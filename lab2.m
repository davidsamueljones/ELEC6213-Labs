%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
close all
clear

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% B.1 / B.2
fs = 200;
X = linspace(0, 2 * pi, fs);
sigs = {};
sigs{1}.title = 'sin, f=1, p=0';
sigs{1}.Y = sin(X * 1/1);
sigs{2}.title = 'sin, f=5, p=\pi / 2';
sigs{2}.Y = sin((X + pi / 2) * 5);
sigs{3}.title = 'sin, f=10, p=0';
sigs{3}.Y = sin(X * 10);
for i=1:length(sigs)
    sigs{i}.X = X;
end
b1_plot(sigs)

%% B.3
% a) cos
fs = 200;
X = linspace(0, 2 * pi, fs);
sigs = {};
sigs{1}.title = 'cos, f=1, p=0';
sigs{1}.Y = cos(X * 1/1);
sigs{2}.title = 'cos, f=5, p=\pi / 2';
sigs{2}.Y = cos((X + pi / 2) * 5);
sigs{3}.title = 'cos, f=10, p=0';
sigs{3}.Y = cos(X * 10);
for i=1:length(sigs)
    sigs{i}.X = X;
end
b1_plot(sigs)

% b) Unit Step
t = (-1:0.01:1)';
unitstep = t>=0;
sigs = {};
sigs{1}.title = 'unit step';
sigs{1}.X = t;
sigs{1}.Y = unitstep;
b1_plot(sigs)

% c) Impulse
impulse = t==0;
sigs = {};
sigs{1}.title = 'impulse';
sigs{1}.X = t;
sigs{1}.Y = impulse;
b1_plot(sigs)

%% B.4
phase = pi / 2;
f = 5;
sf = 0.1;
xs = 0:sf:2*pi;
ys = 0:sf:2*pi;
[X, Y] = meshgrid(xs, ys);
XY = Y*cos(phase) + X*sin(phase);
Z = sin(2*XY);
b4_plot(X, Y, Z);
Z = sin(5*XY);
b4_plot(X, Y, Z);

%% B.5

% Box Function
y = 100;
x = 100;
rx = 10;
ry = 5;
[X, Y] = meshgrid(1:1:x, 1:1:y);
Z = zeros([x, y]);
rxs = (size(Z, 1) / 2 - rx):(size(Z, 1) / 2 + rx);
rys = (size(Z, 2) / 2 - ry):(size(Z, 2) / 2 + ry);
Z(rxs, rys) = 1;
fh = b4_plot(X, Y, Z);

% Gaussian Function
Z = fspecial('gaussian', 100, 10);
[X, Y] = meshgrid(1:1:size(Z, 1), 1:1:size(Z, 2));
b4_plot(X, Y, Z);


%% B.6
filename = 'lenaG';
files_dir = 'files';
bmp_path = fullfile(files_dir, strcat(filename, '.bmp'));
bmp_img = imread(bmp_path);
b6_plot(bmp_img);

%% B.7
bmp_img_fft = fft2(bmp_img);
bmp_img_inv = ifft2(bmp_img_fft);

%% B.8
bmp_img_fft = fft2(bmp_img);
bmp_img_inv_zero_phase = ifft2(abs(bmp_img_fft));

%% B.9
bmp_img_fft = fft2(bmp_img);
ang = angle(bmp_img_fft);
unit_mag = max(abs(bmp_img_fft), [], 'all');
re = unit_mag * cos(ang);
im = unit_mag * sin(ang);
bmp_img_inv_unit_mag = ifft2(complex(re, im));

figure()
tiledlayout(1, 3)
nexttile
imshow(mat2gray(bmp_img_inv))
title('IFFT(FFT(bmp)')
nexttile
imshow(mat2gray(log(fftshift(bmp_img_inv_zero_phase))))
title('Zero Phase (log)')
nexttile
imshow(mat2gray(real(bmp_img_inv_unit_mag)))
title('Unit Magnitude')

%% B.10;
b6_plot(bmp_img');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% FUNCTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function b1_plot(sigs)
figure()
tiledlayout(length(sigs), 4)
for i=1:length(sigs)
    X = sigs{i}.X;
    Y = sigs{i}.Y;
    sig_fft = fft(Y);
    sig_inv = ifft(sig_fft);
    nexttile
    plot(X, Y)
    dx = (max(X) - min(X)) / 10;
    dy = (max(Y) - min(Y)) / 10;
    xs = xlim;
    ys = ylim;
    xlim([xs(1) - dx, xs(2) + dx]);
    ylim([ys(1) - dy, ys(2) + dy]);
    title(sigs{i}.title)
    nexttile
    SS = singlesided(abs(sig_fft));
    FS = (0:length(SS)-1);
    plot(FS, SS)
    dx = (max(X) - min(X)) / 10;
    dy = (max(SS) - min(SS)) / 10;
    xs = xlim;
    ys = ylim;
    xlim([xs(1) - dx, xs(2) + dx]);
    ylim([ys(1) - dy, ys(2) + dy]);
    title('Magnitude')
    nexttile
    SS = sindlesidedphase(angle(sig_fft));
    plot(FS, SS)
    dx = (max(X) - min(X)) / 10;
    dy = (max(SS) - min(SS)) / 10;
    xs = xlim;
    ys = ylim;
    xlim([xs(1) - dx, xs(2) + dx]);
    ylim([ys(1) - dy, ys(2) + dy]);
    title('Phase')
    nexttile
    plot(X, sig_inv)
    dx = (max(X) - min(X)) / 10;
    dy = (max(SS) - min(SS)) / 10;
    xs = xlim;
    ys = ylim;
    xlim([xs(1) - dx, xs(2) + dx]);
    ylim([ys(1) - dy, ys(2) + dy]);
    title('Inverse FFT')
end
end

function SS = singlesided(DS)
L = length(DS);
DS = abs(DS / L);
SS = DS(1:fix(L/2)+1);
SS(2:end-1) = 2*SS(2:end-1);
end

function SS = sindlesidedphase(DS)
L = length(DS);
SS=DS(1:fix(L/2)+1);
SS(2:end-1)=2*SS(2:end-1);
end
function fh = b4_plot(X, Y, Z)
x_lims = [X(1), X(end)];
y_lims = [Y(1), Y(end)];

fft_res = fft2(Z);
fft_res = fftshift(fft_res);
% Plot Space Domain
fh = figure();
subplot(1, 3, 1)
h = surf(X, Y, Z);
title('Space Domain')
colormap gray
set(h, 'edgecolor', 'none')
view(2)
xlim(x_lims)
ylim(y_lims)
pbaspect([1, 1, 1])
% Plot FFT Magnitude
subplot(1, 3, 2)
h = surf(X, Y, abs(fft_res));
title('Magnitude')
colormap gray
set(h, 'edgecolor', 'none')
view(2)
xlim(x_lims)
ylim(y_lims)
pbaspect([1, 1, 1])
% Plot FFT Phase
subplot(1, 3, 3)
h = surf(X, Y, angle(fft_res));
title('Phase')
colormap gray
set(h, 'edgecolor', 'none')
view(2)
xlim(x_lims)
ylim(y_lims)
pbaspect([1, 1, 1])
end

function fh = b6_plot(img)
fft_res = fft2(img);
fft_res = double(fftshift(fft_res));
fft_magnitude = abs(fft_res);
fft_angle = angle(fft_res);

% Plot Space Domain
fh = figure();
subplot(1, 3, 1)
imshow(img)
title('Space Domain')
% Plot FFT Magnitude
subplot(1, 3, 2)
imshow(mat2gray(log(fft_magnitude)));
title('Magnitude')
% Plot FFT Phase
subplot(1, 3, 3)
imshow(mat2gray(fft_angle));
title('Phase')
end


