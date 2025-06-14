% Full Handwriting Segmentation Code with Enhanced Robustness
% Step 1: Load the image
imageFile = 'new.jpg';  % Replace with your image file path
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

% Step 2: Preprocessing for Illumination Correction
% Correct uneven illumination
background = imopen(gray_img, strel('disk', 15));  % Adjust radius as needed
corrected_img = imsubtract(gray_img, background);

% Display illumination-corrected image
figure, imshow(corrected_img);
title('Illumination Corrected Image');

% Step 3: Contrast Adjustment
% Calculate entropy to decide if histogram equalization is needed
entropy_val = entropy(corrected_img);
disp(['Entropy of the image: ', num2str(entropy_val)]);

if entropy_val < 5  % Apply histogram equalization if entropy is low
    enhanced_img = histeq(corrected_img);
    disp('Low contrast detected. Applying histogram equalization.');
else
    enhanced_img = corrected_img;
    disp('Sufficient contrast detected. Skipping histogram equalization.');
end

% Display enhanced image
figure, imshow(enhanced_img);
title('Contrast Enhanced Image');

% Step 4: Thresholding
% Use adaptive thresholding for robust binarization
bin_img = imbinarize(enhanced_img, 'adaptive', ...
    'ForegroundPolarity', 'dark', 'Sensitivity', 0.5);

% Invert binary image if needed (white background, black text)
bin_img = ~bin_img;

% Display binarized image
figure, imshow(bin_img);
title('Binarized Image');

% Step 5: Morphological Processing
% Calculate dynamic structuring element size
stats = regionprops(bin_img, 'Area');
avg_area = mean([stats.Area]);
se_radius = max(1, round(sqrt(avg_area) / 20));
se = strel('disk', se_radius);

% Apply morphological operations
processed_img = imclose(imopen(bin_img, se), se);

% Display processed image
figure, imshow(processed_img);
title('Morphologically Processed Image');

% Step 6: Remove Small Dots and Lines
% Remove small components
[L, num] = bwlabel(processed_img);
stats = regionprops(L, 'BoundingBox', 'Area');

% Dynamically set thresholds
median_area = median([stats.Area]);
std_area = std([stats.Area]);
area_threshold = max(50, median_area - std_area);  % Minimum size
aspect_ratio_threshold = 10;  % Aspect ratio for line detection
extent_threshold = 0.2;  % Minimum extent for valid components

% Filter components
cleaned_img = processed_img;
for i = 1:num
    bbox = stats(i).BoundingBox;
    width = bbox(3);
    height = bbox(4);
    extent = stats(i).Area / (width * height);

    % Remove small components or line-like components
    if stats(i).Area < area_threshold || max(width / height, height / width) > aspect_ratio_threshold || extent < extent_threshold
        cleaned_img(L == i) = 0;
    end
end

% Display cleaned image
figure, imshow(cleaned_img);
title('Cleaned Image (Small Dots and Lines Removed)');

% Step 7: Segmentation with Final Visualization
% Label connected components in the cleaned binary image
[L, num_components] = bwlabel(cleaned_img);

% Get properties of the labeled regions
stats = regionprops(L, 'BoundingBox', 'Area');

% Dynamically calculate thresholds
min_size = max(50, median([stats.Area]) * 0.5);  % Minimum size for lines
char_min_size = min_size * 0.2;  % Minimum size for characters
disp(['Dynamic min_size: ', num2str(min_size)]);
disp(['Dynamic char_min_size: ', num2str(char_min_size)]);

% Initialize total letter count
total_letters = 0;

% Open a figure for marking detected segments
figure, imshow(cleaned_img);
hold on;
title('Detected Segments');

% Process each valid line/region
for i = 1:num_components
    if stats(i).Area < min_size  % Skip regions smaller than the minimum size
        continue;
    end

    % Draw a rectangle around the valid component
    rectangle('Position', stats(i).BoundingBox, 'EdgeColor', 'r', 'LineWidth', 2);

    % Crop the image for the valid component
    line_img = imcrop(cleaned_img, stats(i).BoundingBox);

    % Label connected components (characters) within the line
    [L_char, num_chars] = bwlabel(line_img);
    char_stats = regionprops(L_char, 'BoundingBox', 'Area');

    % Filter valid characters by size
    valid_char_stats = char_stats([char_stats.Area] >= char_min_size);

    % Draw rectangles around valid characters
    for j = 1:length(valid_char_stats)
        char_bbox = valid_char_stats(j).BoundingBox;
        char_bbox(1) = char_bbox(1) + stats(i).BoundingBox(1);
        char_bbox(2) = char_bbox(2) + stats(i).BoundingBox(2);
        rectangle('Position', char_bbox, 'EdgeColor', 'g', 'LineWidth', 1);
    end

    % Update the total letter count
    total_letters = total_letters + length(valid_char_stats);
end

hold off;

% Display the total number of letters found
disp(['Total number of letters detected: ', num2str(total_letters)]);
