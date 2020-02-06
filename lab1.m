%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
close all
clear

filename = 'lenaG';
temp_dir = 'temp';
files_dir = 'files';
warning('off', 'MATLAB:MKDIR:DirectoryExists');
mkdir(temp_dir)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% A.1
bmp_path = fullfile(files_dir, strcat(filename, '.bmp'));
bmp_img = imread(bmp_path);
%% A.2
copy_path = fullfile(temp_dir, strcat(filename, '_2.bmp'));
imwrite(bmp_img, copy_path);

%% A.3
jpg_path = fullfile(temp_dir, strcat(filename, '.jpg'));
imwrite(bmp_img, jpg_path);

%% A.4
jpg_img = imread(jpg_path);
figure()
subplot(1, 3, 1)
imshow(bmp_img)
subplot(1, 3, 2)
imshow(jpg_img)
subplot(1, 3, 3)
imshowpair(bmp_img, jpg_img, 'diff') 

%% A.5
midpoint = size(bmp_img) / 2;
xs = midpoint(1) - 5:midpoint(1) + 5;
ys = midpoint(2) - 5: midpoint(2) + 5;
extracted = bmp_img(xs, ys);
figure()
imshow(extracted)

%% A.6 (imcomplement)
neg_img = intmax('uint8') - bmp_img;
figure()
imshow(neg_img)

%% A.7
ks = [2, 2];
input = bmp_img;
input_size = size(input);
output_size = [ceil(input_size(1) / ks(1)), ceil(input_size(2) / ks(2))];
scaled = zeros(output_size, 'uint8');
for i=1:output_size(1)
    for j=1:output_size(2)
        x = (i - 1) * ks(1);
        y = (j - 1) * ks(2);
        xs = x+1:min(x+ks(1), input_size(1));
        ys = y+1:min(y+ks(2), input_size(2));
        scaled(i, j) = mean(input(xs, ys), 'all');
    end
end
figure()
imshow(scaled)
%% A.8
ks = [2, 2];
input = bmp_img;
input_size = size(input);
output_size = input_size;
pixelated = zeros(output_size, 'uint8');
for i=1:(ceil(input_size(1) / ks(1)))
    for j=1:(ceil(input_size(2) / ks(2)))
        x = (i - 1) * ks(1);
        y = (j - 1) * ks(2);
        xs = x+1:min(x+ks(1), input_size(1));
        ys = y+1:min(y+ks(2), input_size(2));
        pixelated(xs, ys) = mean(input(xs, ys), 'all');
    end
end
figure()
subplot(1, 3, 1)
imshow(bmp_img)
subplot(1, 3, 2)
imshow(pixelated)
subplot(1, 3, 3)
imshowpair(bmp_img, pixelated, 'diff') 

%% A.9
bit_cnt = 8;
bits = cell(8);
figure()
for i=1:bit_cnt
    bits{i} = bitand(bmp_img, bitshift(1, i - 1));
    bits{i}(bits{i} > 0) = intmax('uint8');
    subplot(2, 4, i)
    imshow(bits{i})
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

