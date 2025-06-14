% Close all open figure windows before running the script
close all;

% Step 1: Define the file path
% imageFile = 'asd.jpg';  % Path to the image file
imageFile = 'a.png';  % Path to the image file

% Step 2: Check if the image exists
if exist(imageFile, 'file') == 2  % '2' means it is a file
    % If the image exists, load and display it
    img = imread(imageFile);      % Load the image
    figure, imshow(img);          % Display the image
    title('Loaded Image from File');
    
    %% Preprocessing
    % Convert the image to grayscale
    gray_img = rgb2gray(img);
    figure, imshow(gray_img);
    title('Grayscale Image');
    pause(1);  % Pause to visualize the image for 1 second
    
    % Apply Gaussian filter to remove noise
    denoised_img = imgaussfilt(gray_img, 2);  % The second argument is the filter size
    denoised_img = gray_img;
    figure, imshow(denoised_img);
    title('Denoised Image');
    pause(1);  % Pause to visualize the image for 1 second
    
    % Binarize the image using Otsu's thresholding
    bin_img = imbinarize(denoised_img);
    figure, imshow(bin_img);
    title('Binarized Image');
    pause(1);  % Pause to visualize the image for 1 second
    
    % Invert the binary image if needed (white background, black text)
    bin_img = ~bin_img;
    figure, imshow(bin_img);
    title('Inverted Binary Image');
    pause(1);  % Pause to visualize the image for 1 second
    
    % Apply dilation to make the handwriting more solid
    se = strel('disk', 1);  % Create a structural element for dilation
    processed_img = imdilate(bin_img, se);
    figure, imshow(processed_img);
    title('Morphologically Processed Image');
    pause(1);  % Pause to visualize the image for 1 second

    % Apply erosion to the processed image
    eroded_img = imerode(processed_img, se);    
%     eroded_img = imerode(eroded_img, se);
%     eroded_img = imerode(eroded_img, se);

    figure, imshow(eroded_img);
    title('Eroded Image');
    pause(1);  % Pause to visualize the image for 1 second
    
    %% Step 3: Segmentation
    
    % Step 3.1: Line Segmentation
    [L, num] = bwlabel(processed_img);  % Label connected components (lines)
    stats = regionprops(L, 'BoundingBox');  % Get bounding boxes for lines
    
    if num == 0
        disp('No lines detected.');
        return;
    end
    
    % Step 4: Feature Extraction for Each Line
    all_features = [];  % To store features of all characters
    for i = 1:num
        % Crop the image to extract each line
        line_img = imcrop(processed_img, stats(i).BoundingBox);
        
        % Label connected components in the line (individual characters)
        [L_char, num_char] = bwlabel(line_img);
        
        % Get bounding boxes for each character
        char_stats = regionprops(L_char, 'BoundingBox');
        
        % Step 4: Call the feature extraction function
        if num_char > 0
            features = extractCharacterFeatures(line_img, num_char, char_stats);
            % Append the features of this line to the overall feature set
            all_features = [all_features; features];
        else
            disp(['No characters detected in line ', num2str(i)]);
        end
    end
    
    % Display the number of features extracted for all characters
    disp(['Total number of features extracted: ', num2str(size(all_features, 2))]);
    
    % Display the full feature matrix (this might be large if there are many features)
    disp('Extracted features:');
    disp(all_features);
    
    % Display the size of the feature matrix
    disp(['Size of the feature matrix: ', num2str(size(all_features))]);

    close all;
    
else
    % If the image is not found, display an error message
    disp('Image not found!');
end
