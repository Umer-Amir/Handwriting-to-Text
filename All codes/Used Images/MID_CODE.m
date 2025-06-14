close all;

% Step 1: Load the image
imageFile = 'a.png';  % Replace with your image file path
img = imread(imageFile);  % Read the image

% Check if the image is RGB
if size(img, 3) == 3  % RGB images have 3 color channels
    gray_img = rgb2gray(img);  % Convert to grayscale
else
    gray_img = img;  % If already grayscale, use as is
end

% Display the grayscale image
% figure, imshow(gray_img);
% title('Grayscale Image');

% Step 2: Check Contrast Using Standard Deviation
% figure, imhist(gray_img);
% title('Histogram of Grayscale Image');

% Calculate standard deviation of pixel intensities
intensity_std = std(double(gray_img(:)));  % Convert to double for precision

% Define a threshold for the standard deviation
std_threshold = 20;  % Example threshold; adjust if needed
disp(['Calculated Standard Deviation: ', num2str(intensity_std)]);

if intensity_std < std_threshold
    disp('Low contrast detected based on standard deviation. Applying histogram equalization.');
    enhanced_img = histeq(gray_img);  % Perform histogram equalization
    figure, imshow(enhanced_img);
    title('Histogram Equalized Image');
else
    disp('Sufficient contrast detected. Skipping histogram equalization.');
    enhanced_img = gray_img;  % Use the original grayscale image
end

% Step 3: Apply Otsu's Thresholding
threshold_value = graythresh(enhanced_img);  % Calculate optimal threshold
bin_img = imbinarize(enhanced_img, threshold_value);  % Convert to binary image

% Invert the binary image if needed (white background, black text)
bin_img = ~bin_img;

% Define a structuring element
se = strel('disk', 1);  % 'disk' with radius 1

% Apply opening (removes small noise)
opened_img = imopen(bin_img, se);

% Apply closing (fills small holes)
processed_img = imclose(opened_img, se);

% Step 4.1: Remove Small Dots or Anomalies
[L, num] = bwlabel(processed_img);
stats = regionprops(L, 'Area');
area_threshold = 50;  % Components smaller than this will be removed
filtered_img = processed_img;
for i = 1:num
    if stats(i).Area < area_threshold
        filtered_img(L == i) = 0;
    end
end

% Step 4.2: Remove Small Lines (Based on Aspect Ratio and Size)
[L, num] = bwlabel(filtered_img);
stats = regionprops(L, 'BoundingBox', 'Area');
area_threshold = 50;
aspect_ratio_threshold = 10;
cleaned_img = filtered_img;
for i = 1:num
    bbox = stats(i).BoundingBox;
    width = bbox(3);
    height = bbox(4);
    aspect_ratio = max(width / height, height / width);
    if stats(i).Area < area_threshold || aspect_ratio > aspect_ratio_threshold
        cleaned_img(L == i) = 0;
    end
end

% Step 5: Segmentation with Dynamic Thresholding and Saving Segments
[L, num_components] = bwlabel(cleaned_img);
stats = regionprops(L, 'BoundingBox', 'Area');
areas = [stats.Area];
min_size = median(areas) * 0.5;
char_min_size = min_size * 0.2;
disp(['Dynamic min_size: ', num2str(min_size)]);
disp(['Dynamic char_min_size: ', num2str(char_min_size)]);

% Create folder to save segmented images
output_folder = 'Seg Imgs';
if ~exist(output_folder, 'dir')
    mkdir(output_folder);
end

% Initialize total letter count
total_letters = 0;

% Process each valid line/region
for i = 1:num_components
    if stats(i).Area < min_size
        continue;
    end

    % Get bounding box of the valid component
    bbox = stats(i).BoundingBox;

    % Crop the image for the valid component
    line_img = imcrop(cleaned_img, bbox);

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

disp(' ')
disp(' ')
disp('Saved to Seg Imgs!')
disp('Please use model to convert to text')
