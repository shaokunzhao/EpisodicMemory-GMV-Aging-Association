%--------------------------------------
% This code is designed to restrict the results for each sliding window 
% based on the mask obtained in section 2.3.
%--------------------------------------

clc;
clear;

root = 'REPLACE_WITH_YOUR_ROOT_PATH'; % Replace with the actual root path
mask = 'REPLACE_WITH_YOUR_MASK_PATH'; % Replace with the actual mask path

t_map = '*_T.nii'; 

subs = dir(fullfile(root, 'Slide_win_Residual_Norm'));
subs = subs(3:end);

for i = 1:numel(subs)
    subs_slide = dir(fullfile(root, 'Slide_win_Residual_Norm', 'Slide_win*'));
    
    for s = 1:numel(subs_slide)
        subs_sec = dir(fullfile(root, 'Slide_win_Residual_Norm', subs_slide(s).name));
        subs_sec = subs_sec(3:end);
        
        for j = 1:numel(subs_sec)
            subs_thi = dir(fullfile(root, 'Slide_win_Residual_Norm', subs_slide(s).name, subs_sec(j).name));
            subs_thi = subs_thi(3:end);

            for k = 1:numel(subs_thi)
                disp([subs_slide(s).name, '--', subs_sec(j).name, '--', subs_thi(k).name, ' is processing!'])
                
                file_result = dir(fullfile(root, 'Slide_win_Residual_Norm', subs_slide(s).name, subs_sec(j).name, subs_thi(k).name, t_map));
                file_result = file_result.name;

                Nii_mask = spm_vol(mask);
                Vol_mask = spm_read_vols(Nii_mask);

                Nii_result = spm_vol(fullfile(root, 'Slide_win_Residual_Norm', subs_slide(s).name, subs_sec(j).name, subs_thi(k).name, file_result));
                Vol_result = spm_read_vols(Nii_result);

                Volresult = Vol_mask .* Vol_result;

                output_file = fullfile(root, 'Slide_win_Residual_Norm', subs_slide(s).name, subs_sec(j).name, subs_thi(k).name, [file_result(1:end-4), '_mask.nii']);
                Nii_mask.fname = output_file;
                Nii_mask.dt = [64, 0];
                spm_write_vol(Nii_mask, Volresult);
            end
        end
    end
end

disp('Done');
