%% Use for testing and tweaking the program

%% Read in initial audio

[sound_a, Fs_a] = audioread('piano_scales.m4a');
[sound_b, Fs_b] = audioread('piano_scales2.m4a'); % what you're comparing to (i.e the right sound)


% set fixed length of matrices 
fixed_length = length(sound_b) / Fs_b;
% fixed_length = Fs_a * 1;


%only deal with mono sound 
if(length(size(sound_a)) > 1);
    sound_a = sound_a(:,1); % get just the first chanel of audio
end

if(length(size(sound_b)) >1);
    sound_b = sound_b(:,1); % get just the first chanel of audio
end
%fill up matrices to be fixed length
if((fixed_length*Fs_b - length(sound_a) > 0));
    sound_a = vertcat(sound_a, zeros((fixed_length*Fs_b - length(sound_a)),1));
end

if((fixed_length*Fs_a - length(sound_b) > 0));
    sound_b = vertcat(sound_b, zeros((fixed_length*Fs_a - length(sound_b)),1));
end

figure;
plotspectrogram(sound_a,Fs_a);
axis off;
ylim([200 2000]);
img = getframe(gca);
imwrite(img.cdata,'song1.png','png');
image_sound_a = img.cdata;


plotspectrogram(sound_b,Fs_b);
axis off;
ylim([200 2000]);
img = getframe(gca);
image_sound_b = img.cdata;




%% 
% load in specmap
axis off
load specmap;

%image sound a must be the original audio



percentage_mask = 15; %finetune 
if percentage_mask < 100
    percentage_mask = percentage_mask + 1;
end


rows_mask = ceil(length(specmap)*(percentage_mask/100));

mask_a = image_sound_a(:,:,1) >= specmap(rows_mask,1) & image_sound_a(:,:,2) >= specmap(rows_mask,2) ...
    & image_sound_a(:,:,3) >= specmap(rows_mask,3);

mask_b = image_sound_b(:,:,1) >= specmap(rows_mask,1) & image_sound_b(:,:,2) >= specmap(rows_mask,2) ...
    & image_sound_b(:,:,3) >= specmap(rows_mask,3);

pixels_per_unit_x = ceil(size(image_sound_a,2)/10);
pixels_per_unit_y = ceil(size(image_sound_a,1)/10);


%% Create mask
phase_offset_secs = 1; 
phase_offset_pixels = ceil(phase_offset_secs * pixels_per_unit_x);


overlap_mask = (mask_a == mask_b) & (mask_a == 1);

% create matrix to store mask for offset values
overlay_mask = logical(zeros(size(mask_a,1),size(mask_a,2)));

for(i = 1:size(mask_a,1)) % i = y j = x
    for(j = 1:size(mask_a,2))
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
        
        
%         if (i < size(mask_a,1) - phase_offset_pixels)
%             if any(mask_a(i,j) == mask_b(i:i+phase_offset_pixels,j)) & mask_a(i,j) == 1
%                 if(ne(overlap_mask(i,j),1))
%                  overlay_mask(i,j) = true;
%                 end
%             end
%             
%             
%             if any(mask_a(i,j) == mask_b(i:i-phase_offset_pixels,j)) & mask_a(i,j) == 1 ...
%                     & (j-phase_offset_pixels >= 0)
%                 if(ne(overlap_mask(i,j),1))
%                  overlay_mask(i,j) = true;
%                 end
%             end                        
%         end
        
        
        
    end
        
end

overlap_mask = overlap_mask + overlay_mask;

%%pick whatever pretty colours you want
mask_a_col = cat(3,mask_a * (255/255), mask_a * (51/255), mask_a * (0/255)); %red
mask_b_col = cat(3,mask_b * (51/255), mask_b *  (204/255)   , mask_b * (51/255));%green 
overlap_mask_col = cat(3,overlap_mask * (10/255), overlap_mask *(154/255), overlap_mask * (250/255)); %blue

percent_match_BtoA = sum(overlap_mask(:)) / ((sum(mask_a(:)))+1);

%% Display data 
% Display figures for visual confirmation of masking  
figure;
imshow(overlap_mask_col);
title('Overlap Mask');
figure;
imshow(mask_a_col);
title('Mask A');
figure;
imshow(mask_b_col);
title('Mask B');

figure;
imshowpair(mask_a_col,mask_b_col); % compare mask_a and mask_b with built in function
str = sprintf('Percentage accuracy: %2f ',percent_match_BtoA* 100);
title(str);

