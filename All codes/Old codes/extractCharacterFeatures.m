function features = extractCharacterFeatures(line_img, num_char, char_stats)
features = [];  % Initialize an empty matrix to store features

for j = 1:num_char
    % Crop each character from the line
    char_img = imcrop(line_img, char_stats(j).BoundingBox);
    
    % Check if the character image has sufficient size for resizing
    if size(char_img, 1) > 5 && size(char_img, 2)> 5
        % Resize the character image to a fixed size (e.g., 28x28 pixels)
        char_img_resized = imresize(char_img, [28 28]);
        
        %% Feature 1: Raw Pixel Intensities
        pixel_features = char_img_resized(:)';  % Convert to row vector
        
        %% Feature 2: HOG Features
        % Extract HOG features and visualize for the first character
        [hog_features, visualization] = extractHOGFeatures(char_img_resized, 'CellSize', [4 4]);
        
        % Plot the HOG features for the first character in the first line
        if j == 1
            figure;
            imshow(char_img_resized); title('Resized Character Image');
            figure;
            plot(visualization); title('HOG Visualization');
            pause(1);  % Pause to visualize
        end
        
        %% Combine the features
        combined_features = [pixel_features, hog_features];
        
        % Append to features matrix
        features = [features; combined_features];
    else
        disp(['Character too small to process, skipping character ', num2str(j)]);
    end
end
end
