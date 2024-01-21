%-------------------------------------------------
% Setting Thresholds for Sliding Window Results
%-------------------------------------------------

clc;
clear;

% Set statistic result of NII file
root = 'REPLACE_WITH_YOUR_ROOT_PATH';
tmapname = 'spmT_0001.nii';
betaname = tmapname;
p = 0.01;  % p threshold

subs = dir(root);
subs = subs(3:end);

for m = 1:numel(subs)
    subs_s = dir(fullfile(root, subs(m).name, 'Slide_win_Residual_Norm', 'Slide_win*'));
    
    for i = 1:numel(subs_s)
        subs_sec = dir(fullfile(root, subs(m).name, 'Slide_win_Residual_Norm', subs_s(i).name));
        subs_sec = subs_sec(3:end);
        
        for j = 1:numel(subs_sec)
            subs_thi = dir(fullfile(root, subs(m).name, 'Slide_win_Residual_Norm', subs_s(i).name, subs_sec(j).name));
            subs_thi = subs_thi(3:end);
            
            for k = 1:numel(subs_thi)
                disp([subs(m).name, '--', subs_s(i).name, '--', subs_sec(j).name, '--', subs_thi(k).name, ' is processing!'])
                
                file = fullfile(root, subs(m).name, 'Slide_win_Residual_Norm', subs_s(i).name, subs_sec(j).name, subs_thi(k).name, tmapname);
                tmpNii = spm_vol(file);
                tmpVol = spm_read_vols(tmpNii);

                df = str2double(tmpNii.descrip(isstrprop(tmpNii.descrip, 'digit'))(1:end-2));
                
                % P = 1 - tcdf(T, df) % Given T and df, calculate p
                % Tthre = tinv(1 - p, df); % Given p and df, find critical T 
                Tthre = 0;  % Only discard results less than 0

                %% Positive result
                tmpResVol_posi = tmpVol;
                x = find(tmpVol < Tthre);
                tmpResVol_posi(x) = 0;   
                vmax_p = max(max(max(tmpResVol_posi)));
                
                if vmax_p ~= 0
                    tmpNii_beta = spm_vol(fullfile(root, subs(m).name, 'Slide_win_Residual_Norm', subs_s(i).name, subs_sec(j).name, subs_thi(k).name, betaname));
                    tmpVol_beta = spm_read_vols(tmpNii_beta);
                    
                    tmpResVol_posi(tmpResVol_posi ~= 0) = 1;
                    tmpResVol = tmpResVol_posi .* tmpVol_beta;
                    
                    vmax_p = max(max(max(tmpResVol)));
                    vmin_p = min(min(min(tmpResVol)));
                    
                    tmpNii_beta.fname = fullfile(root, subs(m).name, 'Slide_win_Residual_Norm', subs_s(i).name, subs_sec(j).name, subs_thi(k).name, ['result_posi_cs0_p', num2str(p), 'uncorr_T', num2str(Tthre), '_df', num2str(df), '_T', num2str(vmin_p), '_', num2str(vmax_p), '_T_nothre.nii']);
                    tmpNii_beta.dt = [64, 0];
                    spm_write_vol(tmpNii_beta, tmpResVol);
                else
                    continue
                end
            end
        end
    end
end

disp('Done');
