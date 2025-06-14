% Step 2: Check the Histogram Spread Dynamically
figure, imhist(gray_img);
title('Histogram of Grayscale Image');

% Calculate histogram spread
min_intensity = min(gray_img(:));
max_intensity = max(gray_img(:));
spread = max_intensity - min_intensity;


% Calculate a dynamic threshold based on the intensity range or standard deviation
intensity_std = std(double(gray_img(:)));  % Standard deviation of intensity
dynamic_threshold = 0.2 * spread;  % Use 20% of the spread as the threshold
disp(['Calculated Dynamic Threshold: ', num2str(dynamic_threshold)]);

if spread < dynamic_threshold
    disp('Poor contrast detected. Applying histogram equalization.');
    enhanced_img = histeq(gray_img);  % Perform histogram equalization
    figure, imshow(enhanced_img);
    title('Histogram Equalized Image');
else
    disp('Sufficient contrast detected. Skipping histogram equalization.');
    enhanced_img = gray_img;  % Use the original grayscale image
end
