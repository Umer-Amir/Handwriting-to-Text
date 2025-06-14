close all;

% Step 1: Load the image


imageFile = 'b.png';
% imageFile = 'a.png'; % Replace with your image file path
img = imread(imageFile);  % Read the image

% Check if the image is RGB
if size(img, 3) == 3  % RGB images have 3 color channels
    gray_img = rgb2gray(img);  % Convert to grayscale
else
    gray_img = img;  % If already grayscale, use as is
end

% Display the grayscale image
figure, imshow(gray_img);
title('Grayscale Image');

% Step 2: Check Contrast Using Standard Deviation
figure, imhist(gray_img);
title('Histogram of Grayscale Image');

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
end  % <-- Missing `end` added here


% Step 3: Apply Otsu's Thresholding
threshold_value = graythresh(enhanced_img);  % Calculate optimal threshold
bin_img = imbinarize(enhanced_img, threshold_value);  % Convert to binary image

% Display the binary image
figure, imshow(bin_img);
title('Binarized Image');

% Optional: Invert the binary image if needed (white background, black text)
bin_img = ~bin_img;
figure, imshow(bin_img);
title('Inverted Binary Image');

% Define a structuring element
se = strel('disk', 1);  % 'disk' with radius 1

% Original binary image
figure, imshow(bin_img);
title('Original Binary Image');

% Apply opening (removes small noise)
opened_img = imopen(bin_img, se);
figure, imshow(opened_img);
title('After Morphological Opening');

% Apply closing (fills small holes)
closed_img = imclose(bin_img, se);
figure, imshow(closed_img);
title('After Morphological Closing');

% Combined: Apply opening followed by closing
processed_img = imclose(opened_img, se);
figure, imshow(processed_img);
title('After Opening + Closing');

% Compare: Difference between original and processed
difference_img = xor(bin_img, processed_img);  % Highlight changed areas
figure, imshow(difference_img);
title('Difference Between Original and Processed');

% Step 4.1: Remove Small Dots or Anomalies

% Label connected components
[L, num] = bwlabel(bin_img);

% Get properties of the labeled regions
stats = regionprops(L, 'Area');

% Define a size threshold (adjust based on your image)
area_threshold = 50;  % Components smaller than this will be removed

% Create a new binary image excluding small components
filtered_img = bin_img;  % Start with the original binary image
for i = 1:num
    if stats(i).Area < area_threshold
        % Set small components to 0 (black)
        filtered_img(L == i) = 0;
    end
end

% Display the filtered image
figure, imshow(filtered_img);
title('Filtered Image (Small Components Removed)');

% Step 4.2: Remove Small Lines (Based on Aspect Ratio and Size)

% Label connected components
[L, num] = bwlabel(filtered_img);

% Get properties of the labeled regions
stats = regionprops(L, 'BoundingBox', 'Area');

% Define thresholds
area_threshold = 50;         % Minimum size to keep
aspect_ratio_threshold = 10; % Aspect ratio to classify as a line

% Create a new binary image excluding lines
cleaned_img = filtered_img;  % Start with the filtered image
for i = 1:num
    % Get bounding box dimensions
    bbox = stats(i).BoundingBox;  % [x, y, width, height]
    width = bbox(3);
    height = bbox(4);
    
    % Calculate aspect ratio
    aspect_ratio = max(width / height, height / width);
    
    % Remove components classified as lines
    if stats(i).Area < area_threshold || aspect_ratio > aspect_ratio_threshold
        cleaned_img(L == i) = 0;  % Set to 0 (black) if too small or line-like
    end
end

% Display the cleaned image
figure, imshow(cleaned_img);
title('Cleaned Image (Lines Removed)');

% Step 5: Segmentation with Dynamic Thresholding and Final Visualization

% Label connected components in the cleaned binary image
[L, num_components] = bwlabel(cleaned_img);

% Get properties of the labeled regions
stats = regionprops(L, 'BoundingBox', 'Area');

% Dynamically calculate thresholds
areas = [stats.Area];
min_size = median(areas) * 0.5;  % Use half the median area for filtering
char_min_size = min_size * 0.2;  % Use a smaller size for character filtering
disp(['Dynamic min_size: ', num2str(min_size)]);
disp(['Dynamic char_min_size: ', num2str(char_min_size)]);

% Initialize total letter count
total_letters = 0;

% Create a copy of the cleaned image for visualization
marked_img = cleaned_img;

% Open a figure for marking detected segments
figure, imshow(cleaned_img);
hold on;
title('Detected Segments');

% Process each valid line/region
for i = 1:num_components
    % Skip regions smaller than the minimum size
    if stats(i).Area < min_size
        continue;
    end

    % Get bounding box of the valid component
    bbox = stats(i).BoundingBox;

    % Draw a rectangle around the valid component (line/region)
    rectangle('Position', bbox, 'EdgeColor', 'r', 'LineWidth', 2);

    % Crop the image for the valid component
    line_img = imcrop(cleaned_img, bbox);

    % Label connected components (characters) within the line
    [L_char, num_chars] = bwlabel(line_img);
    char_stats = regionprops(L_char, 'BoundingBox', 'Area');

    % Filter valid characters by size
    valid_char_stats = char_stats([char_stats.Area] >= char_min_size);

    % Draw rectangles around valid characters
    for j = 1:length(valid_char_stats)
        char_bbox = valid_char_stats(j).BoundingBox;
        % Adjust bounding box to the original image coordinates
        char_bbox(1) = char_bbox(1) + bbox(1);
        char_bbox(2) = char_bbox(2) + bbox(2);
        rectangle('Position', char_bbox, 'EdgeColor', 'g', 'LineWidth', 1);
    end

    % Update the total letter count
    total_letters = total_letters + length(valid_char_stats);
end

hold off;

% Display the total number of letters found
disp(['Total number of letters detected: ', num2str(total_letters)]);


