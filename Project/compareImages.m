function [percent_overlap, mask_a_col, mask_b_col, overlap_mask_col] = compareImages(image_sound_a, image_sound_b, sensitivity, phase_offset, freq_offset)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here


%% 
% load in specmap
axis off
load specmap;

%image sound a must be the original audio
image_sound_a = image_sound_a;
image_sound_b = image_sound_b;



percentage_mask = (100- sensitivity) %finetune 
if percentage_mask < 100
    percentage_mask = percentage_mask + 1;
end


rows_mask = ceil(length(specmap)*(percentage_mask/100));
%obtain image masks 
mask_a = image_sound_a(:,:,1) >= specmap(rows_mask,1) & image_sound_a(:,:,2)...
    >= specmap(rows_mask,2) & image_sound_a(:,:,3) >= specmap(rows_mask,3);

mask_b = image_sound_b(:,:,1) >= specmap(rows_mask,1) & image_sound_b(:,:,2)...
    >= specmap(rows_mask,2) & image_sound_b(:,:,3) >= specmap(rows_mask,3);

pixels_per_unit_x = ceil(size(image_sound_a,2)/7.5); %based on x ticks
pixels_per_unit_y = ceil(size(image_sound_a,1)/9); %based on y ticks 

freq_per_unit_y = 200;

freq_per_pixel = pixels_per_unit_y/freq_per_unit_y;

%% Create mask
phase_offset_secs = phase_offset;
frequency_offset = freq_offset;

phase_offset_pixels = ceil(phase_offset_secs * pixels_per_unit_x);

freq_offset_pixels = ceil(frequency_offset * freq_per_pixel);
overlap_mask = (mask_a == mask_b) & (mask_a == 1);

% create matrix to store mask for offset values
overlay_mask = logical(zeros(size(mask_a,1),size(mask_a,2))); %#ok<LOGL>

for(i = 1:size(mask_a,1)) % i = y j = x
    for(j = 1:size(mask_a,2))
        %check for phase difference
        if (j < size(mask_a,2) - phase_offset_pixels)
            if any(mask_a(i,j) == mask_b(i,j:j+phase_offset_pixels)) & mask_a(i,j) == 1
                if(ne(overlap_mask(i,j),1))
                 overlay_mask(i,j) = true;
                end
            end
            
            
            if any(mask_a(i,j) == mask_b(i,j:j-phase_offset_pixels)) & mask_a(i,j) == 1 ...
                    & (j-phase_offset_pixels >= 0)
                if(ne(overlap_mask(i,j),1))
                 overlay_mask(i,j) = true;
                end
            end                 
        end
        
        %check pitch
        if (i < size(mask_a,1) - freq_offset_pixels)
            if any(mask_a(i,j) == mask_b(i:i+freq_offset_pixels,j)) & mask_a(i,j) == 1
                if(ne(overlap_mask(i,j),1))
                 overlay_mask(i,j) = true;
                end
            end
            
            
            if any(mask_a(i,j) == mask_b(i:i-freq_offset_pixels,j)) & mask_a(i,j) == 1 ...
                    & (i-freq_offset_pixels >= 0)
                if(ne(overlap_mask(i,j),1))
                 overlay_mask(i,j) = true;
                end
            end
        end
        
        
    end
        
end

overlap_mask = overlap_mask + overlay_mask;

%%pick whatever pretty colours you want
mask_a_col = cat(3,mask_a * (255/255), mask_a * (51/255), mask_a * (0/255)); %red
mask_b_col = cat(3,mask_b * (51/255), mask_b *  (204/255)   , mask_b * (51/255));%green 
overlap_mask_col = cat(3,overlap_mask * (10/255), overlap_mask *(154/255), overlap_mask * (250/255)); %blue

% percent_overlap = sum(overlap_mask(:)) / ((sum(mask_a(:)))+1);

percent_overlap = sum(overlap_mask(:)) / ((sum(mask_a(:))));
% 
% figure;
% imshow(mask_a_col);
% figure;
% imshow(mask_b_col);
% figure;
% imshow(overlap_mask_col);
% figure;

end

