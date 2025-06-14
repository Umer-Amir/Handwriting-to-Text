close all;

% Read the input image
img = imread('a.png');

% Convert to grayscale if the image is in RGB
if size(img, 3) == 3
    img = rgb2gray(img);
end

% 1. Global contrast enhancement using histogram equalization
img_eq = histeq(img);

% 2. Local contrast enhancement using adaptive histogram equalization
img_adapthist = adapthisteq(img);

% 3. Contrast stretching with dynamic range adjustment (ignoring outliers)
percentile_low = 0.02; % Ignore lower 2% of pixel intensities
percentile_high = 0.98; % Ignore top 2% of pixel intensities
low_limit = prctile(img(:), percentile_low * 100);
high_limit = prctile(img(:), percentile_high * 100);
contrast_stretched = imadjust(img, [low_limit / 255, high_limit / 255], []);

% 4. Adaptive thresholding (local binarization)
bw_img_eq = imbinarize(img_eq, 'adaptive', 'ForegroundPolarity', 'dark', 'Sensitivity', 0.5);
bw_img_adapthist = imbinarize(img_adapthist, 'adaptive', 'ForegroundPolarity', 'dark', 'Sensitivity', 0.5);
bw_img_contrast_stretched = imbinarize(contrast_stretched, 'adaptive', 'ForegroundPolarity', 'dark', 'Sensitivity', 0.5);

% 5. Light smoothing (Gaussian filter) to reduce jagged edges
bw_img_contrast_stretched_smooth = imgaussfilt(double(bw_img_contrast_stretched), 0.5);

% Create folder for saving segmented images
output_folder = 'Segmented_Images';
if ~exist(output_folder, 'dir')
    mkdir(output_folder);
end

% Segmentation: Label connected components in the binary image
[L, num] = bwlabel(bw_img_contrast_stretched_smooth);

% Get bounding boxes for each component
stats = regionprops(L, 'BoundingBox');

% Save each segmented component as an image
for i = 1:num
    bbox = stats(i).BoundingBox;
    cropped_img = imcrop(bw_img_contrast_stretched_smooth, bbox); % Crop the component
    resized_img = imresize(cropped_img, [128, 128]); % Resize to 128x128 for uniformity
    
    % Save the segmented image
    output_path = fullfile(output_folder, sprintf('segmented_%d.png', i));
    imwrite(resized_img, output_path);
end

% Display the original and processed images
figure;
imshow(img);
title('Original Image');

figure;
imshow(contrast_stretched);
title('Contrast Stretched');

figure;
imshow(bw_img_contrast_stretched_smooth, []);
title('Smoothed Binary (Contrast Stretched)');

% Highlight segmented regions
figure;
imshow(bw_img_contrast_stretched_smooth, []);
title('Segmented Regions');
hold on;
for i = 1:num
    rectangle('Position', stats(i).BoundingBox, 'EdgeColor', 'r', 'LineWidth', 2);
end
hold off;

disp(['Segmented images saved in folder: ', output_folder]);
