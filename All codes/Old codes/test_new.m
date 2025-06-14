close all;
% Read the input image
img = imread('new.jpg');  % Replace with your image file path

% Convert to grayscale if the image is in RGB
if size(img, 3) == 3
    img = rgb2gray(img);
end

% 1. Global contrast enhancement using histogram equalization
img_eq = histeq(img);

% 2. Local contrast enhancement using adaptive histogram equalization
img_adapthist = adapthisteq(img);

% 3. Apply contrast stretching (manual adjustment of pixel intensity)
min_img = double(min(img(:)));
max_img = double(max(img(:)));
contrast_stretched = uint8(255 * (double(img) - min_img) / (max_img - min_img));

% 4. Binarization after contrast enhancement (adjust thresholding if needed)
bw_img_eq = imbinarize(img_eq);
bw_img_adapthist = imbinarize(img_adapthist);
bw_img_contrast_stretched = imbinarize(contrast_stretched);

% 5. Morphological operations to remove horizontal lines
se_horizontal = strel('line', 15, 0);  % Horizontal structuring element

bw_img_eq_no_lines = imopen(bw_img_eq, se_horizontal);  % Remove horizontal lines
bw_img_adapthist_no_lines = imopen(bw_img_adapthist, se_horizontal);  % Remove horizontal lines
bw_img_contrast_stretched_no_lines = imopen(bw_img_contrast_stretched, se_horizontal);  % Remove horizontal lines

% Optional: Remove small objects (like residual noise) after line removal
bw_img_eq_no_lines = bwareaopen(bw_img_eq_no_lines, 50); % Remove small objects
bw_img_adapthist_no_lines = bwareaopen(bw_img_adapthist_no_lines, 50); % Remove small objects
bw_img_contrast_stretched_no_lines = bwareaopen(bw_img_contrast_stretched_no_lines, 50); % Remove small objects

% Display original image in a new window
figure;
imshow(img);
title('Original Image');

% Display histogram equalized image in a new window
figure;
imshow(img_eq);
title('Histogram Equalized');

% Display adaptive histogram equalization image in a new window
figure;
imshow(img_adapthist);
title('Adaptive Histogram Equalization');

% Display contrast stretched image in a new window
figure;
imshow(contrast_stretched);
title('Contrast Stretched');

% Display binary image from histogram equalized image in a new window
figure;
imshow(bw_img_eq);
title('Binary (Equalized)');

% Display binary image from adaptive histogram equalized image in a new window
figure;
imshow(bw_img_adapthist);
title('Binary (Adaptive Equalization)');

% Display binary image from contrast stretched image in a new window
figure;
imshow(bw_img_contrast_stretched);
title('Binary (Contrast Stretched)');

% Display binary image after line removal from histogram equalized image in a new window
figure;
imshow(bw_img_eq_no_lines);
title('No Lines (Equalized)');

% Display binary image after line removal from adaptive histogram equalized image in a new window
figure;
imshow(bw_img_adapthist_no_lines);
title('No Lines (Adaptive Equalization)');

% Display binary image after line removal from contrast stretched image in a new window
figure;
imshow(bw_img_contrast_stretched_no_lines);
title('No Lines (Contrast Stretched)');

% Save the best result (without lines) as needed
imwrite(bw_img_contrast_stretched_no_lines, 'processed_image_no_lines.jpg');
