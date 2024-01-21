%--------------------------------------
% This code is designed to restrict the results for each sliding window 
% based on the mask obtained in section 2.3.
%--------------------------------------

clc;
clear;

root = 'REPLACE_WITH_YOUR_ROOT_PATH'; % Uncomment and replace with the actual root path
mask_dir = 'REPLACE_WITH_YOUR_MASK_DIR'; % Uncomment and replace with the actual mask directory
gender_mask = {'REPLACE_WITH_GENDER0_MASK','REPLACE_WITH_GENDER1_MASK'}; % Uncomment and replace with the actual gender masks

t_map = '*_T.nii';
subs = dir(fullfile(root, 'Slide_win_Residual_Norm'));
subs = subs(3:end);

for i = 1:numel(subs)
    subs_sec = dir(fullfile(root, 'Slide_win_Residual_Norm', subs(i).name));
    subs_sec = subs_sec(3:end);
    
    for j = 1:numel(subs_sec)
        subs_thi = dir(fullfile(root, 'Slide_win_Residual_Norm', subs(i).name, subs_sec(j).name));
        subs_thi = subs_thi(3:end);

        if str2num(subs_sec(j).name(end)) == 0
            file_mask = gender_mask{1};
        elseif str2num(subs_sec(j).name(end)) == 1
            file_mask = gender_mask{2};
        end
            
        for k = 1:numel(subs_thi)
            disp([subs(i).name, '--', subs_sec(j).name, '--', subs_thi(k).name, ' is processing!'])
            file_result = dir(fullfile(root, 'Slide_win_Residual_Norm', subs(i).name, subs_sec(j).name, subs_thi(k).name, t_map));
            file_result = file_result.name;

            Nii_mask = spm_vol(fullfile(mask_dir, subs_sec(j).name, file_mask));
            Vol_mask = spm_read_vols(Nii_mask);

            Nii_result = spm_vol(fullfile(root, 'Slide_win_Residual_Norm', subs(i).name, subs_sec(j).name, subs_thi(k).name, file_result));
            Vol_result = spm_read_vols(Nii_result);

            Volresult = Vol_mask .* Vol_result;

            output_file = fullfile(root, 'Slide_win_Residual_Norm', subs(i).name, subs_sec(j).name, subs_thi(k).name, [file_result(1:end-4), '_mask.nii']);
            Nii_mask.fname = output_file;
            Nii_mask.dt = [64, 0];
            spm_write_vol(Nii_mask, Volresult);
        end
    end
end

disp('Done');