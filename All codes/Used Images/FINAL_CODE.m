clc;
clear;
close all;

% Step 1: Load the image
imageFile = 'image (9).jpeg';  % Replace with your image file path
img = imread(imageFile);  % Read the image

% Step 2: Convert to Grayscale if Necessary
if size(img, 3) == 3  % RGB images have 3 color channels
    gray_img = rgb2gray(img);  % Convert to grayscale
else
    gray_img = img;  % If already grayscale, use as is
end

% Step 3: Improve Image Quality (Contrast Adjustment and Noise Reduction)

% Adaptive histogram equalization to enhance contrast adaptively
clahe_img = adapthisteq(gray_img, 'ClipLimit', 0.02, 'Distribution', 'rayleigh');

% Apply median filter to reduce noise
filtered_img = medfilt2(clahe_img, [3 3]);

% Step 4: Correct Skewness using Hough Transform
edges_img = edge(filtered_img, 'canny');
[H, theta, rho] = hough(edges_img);
peaks = houghpeaks(H, 5);
lines = houghlines(edges_img, theta, rho, peaks);

% Compute the dominant angle
angles = [lines.theta];
if ~isempty(angles)
    avg_angle = mean(angles);
    rotated_img = imrotate(filtered_img, -avg_angle, 'bilinear', 'crop');
else
    rotated_img = filtered_img; % No rotation if no dominant angle detected
end

% Display processed grayscale image
figure, imshow(rotated_img);
title('Preprocessed Grayscale Image');

% Step 5: Check Contrast Using Standard Deviation
intensity_std = std(double(rotated_img(:)));  % Convert to double for precision

% Define a threshold for the standard deviation
std_threshold = 20;  % Adjust if needed
disp(['Calculated Standard Deviation: ', num2str(intensity_std)]);

if intensity_std < std_threshold
    disp('Low contrast detected. Applying histogram equalization.');
    enhanced_img = histeq(rotated_img);  % Perform histogram equalization
else
    disp('Sufficient contrast detected. Skipping histogram equalization.');
    enhanced_img = rotated_img;
end

% Step 6: Apply Otsu's Thresholding
threshold_value = graythresh(enhanced_img);  % Calculate optimal threshold
bin_img = imbinarize(enhanced_img, threshold_value);  % Convert to binary image

% Invert the binary image if needed (white background, black text)
bin_img = ~bin_img;

% Define a structuring element for morphological operations
se = strel('disk', 1);

% Apply opening (removes small noise)
opened_img = imopen(bin_img, se);

% Apply closing (fills small holes)
processed_img = imclose(opened_img, se);

% Step 7: Noise Removal
[L, num] = bwlabel(processed_img);
stats = regionprops(L, 'Area');

area_threshold = 50;  % Components smaller than this will be removed
filtered_img = processed_img;
for i = 1:num
    if stats(i).Area < area_threshold
        filtered_img(L == i) = 0;
    end
end

% Step 8: Character Segmentation
[L, num_components] = bwlabel(filtered_img);
stats = regionprops(L, 'BoundingBox', 'Area');

% Determine dynamic thresholds based on median area
areas = [stats.Area];
min_size = median(areas) * 0.5;
char_min_size = min_size * 0.2;
disp(['Dynamic min_size: ', num2str(min_size)]);
disp(['Dynamic char_min_size: ', num2str(char_min_size)]);

% Create folder to save segmented characters
output_folder = 'Seg_Imgs';
if ~exist(output_folder, 'dir')
    mkdir(output_folder);
end

total_letters = 0;

% Process each detected component
for i = 1:num_components
    if stats(i).Area < min_size
        continue;
    end

    % Get bounding box of the valid component
    bbox = stats(i).BoundingBox;

    % Crop the image for the valid component
    line_img = imcrop(filtered_img, bbox);

    % Label connected components (characters) within the line
    [L_char, num_chars] = bwlabel(line_img);
    char_stats = regionprops(L_char, 'BoundingBox', 'Area');

    % Filter valid characters by size
    valid_char_stats = char_stats([char_stats.Area] >= char_min_size);

    % Save each valid character
    for j = 1:length(valid_char_stats)
        char_bbox = valid_char_stats(j).BoundingBox;
        char_img = imcrop(line_img, char_bbox);

        % Save the segmented character
        total_letters = total_letters + 1;
        output_path = fullfile(output_folder, sprintf('char_%d.png', total_letters));
        imwrite(char_img, output_path);
    end
end

disp(['Total number of letters detected and saved: ', num2str(total_letters)]);

disp(' ');
disp(' ');
disp('Saved to Seg_Imgs!');
disp('Please use model to convert to text');
