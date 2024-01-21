%-------------------------------------------------
% Perform sliding window analysis for the 2 sex groups
% Establish the relationship between EM and GMV within each window using simple regression
%-------------------------------------------------

clc;
clear;

% Path configurations
root = 'REPLACE_WITH_YOUR_ROOT_PATH';
xlsxroot = 'REPLACE_WITH_YOUR_XLSX_ROOT_PATH';
xlsxfile = {'Table.xlsx'};
outputdir = 'REPLACE_WITH_YOUR_OUTPUT_DIR_PATH';

% Slide window settings
win_width = [90];
win_gap = [0.2 0.3 0.4];

% Data choices
data_folder = {'T1_VolumeMap_QC_Age_Edu_TIV_RES_Norm'};
outputfolder = {'01_Volume'};
mask = {'REPLACE_WITH_YOUR_MASK_PATH'};

for xls = 1:numel(xlsxfile)
    [~, ~, sheet] = xlsread(fullfile(xlsxroot, xlsxfile{xls}));
    gen = sheet{2, 3};
    
    for w_wid = win_width
        for w_gap = win_gap
            cir_max = ceil((numel(sheet(2:end, 1)) - w_wid) / (w_wid * w_gap));
            disp(['+++++++++++++++++++++gender: ', num2str(gen), ' window_width = ', num2str(w_wid), ' overlap = ', num2str(1 - w_gap), ' is processing +++++++++++++++++++++'])
            
            for cir_num = 1:cir_max
                col = 1;
                wid_start = 2 + (cir_num - 1) * (w_wid * w_gap);
                
                for i = wid_start:wid_start + w_wid - 1              
                    ID(col, 1) = sheet(i, 1);                    
                    N1N5(col, 1) = sheet(i, 8);
                    ROdelay(col, 1) = sheet(i, 9);                         
                    col = col + 1;
                    
                    if i > numel(sheet(:, 1))
                        break;
                    end
                end
                
                disp(['WINDOW: ', num2str(min(cell2mat(Age))), '_', num2str(max(cell2mat(Age))), ' added']);

                % Generate computable matrices            
                ComputeTable_N1N5 = [ID, N1N5];
                ComputeTable_ROdelay = [ID, ROdelay];                

                VariableTable = {ComputeTable_N1N5, ComputeTable_ROdelay};
                outputcog = {'N1N5',  'ROdelay'};

                for j = 1:numel(VariableTable)
                    VariableTableTem = VariableTable{j};

                    % Exclude all NaN subjects
                    y = 1;
                    VariableTableOmitNaN = {};

                    for z = 1:numel(VariableTableTem(:, 1))
                        if VariableTableTem{z, 2} == 'NaN'
                            continue
                        else
                            VariableTableOmitNaN(y, :) = VariableTableTem(z, :);
                            y = y + 1;
                        end
                    end

                    for m = 1:numel(data_folder)
                        subject = {};
                        tmpIndex = 1;

                        for k = 1:numel(VariableTableOmitNaN(:, 1))
                            file = dir(fullfile(root, data_folder{m}, strcat('*', VariableTableOmitNaN{k, 1}, '*')));
                            subject{tmpIndex} = strcat(fullfile(root, data_folder{m}, file.name), ',1');  % NII file
                            tmpIndex = tmpIndex + 1; 
                        end

                        subject = subject';
                        matdir = fullfile(outputdir, outputfolder{m}, outputcog{j}, 'Slide_win_Residual_Norm', ['Slide_win_', num2str(w_wid), '_', num2str(w_gap)], ['Gender_', num2str(gen)], [num2str(min(cell2mat(Age))), '_', num2str(max(cell2mat(Age))), '_M_', num2str(mean(cell2mat(Age)))]);
                        mkdir(matdir);

                        spm_jobman('initcfg');
                        matlabbatch{1}.spm.stats.factorial_design.dir = cellstr(matdir);
                        matlabbatch{1}.spm.stats.factorial_design.des.mreg.scans = cellstr(subject);
                        matlabbatch{1}.spm.stats.factorial_design.des.mreg.mcov(1).c = cell2mat(VariableTableOmitNaN(:, 2));
                        matlabbatch{1}.spm.stats.factorial_design.des.mreg.mcov(1).cname = outputcog{j};
                        matlabbatch{1}.spm.stats.factorial_design.des.mreg.mcov(1).iCC = 1;
                        matlabbatch{1}.spm.stats.factorial_design.des.mreg.incint = 1;
                        matlabbatch{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
                        matlabbatch{1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
                        matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
                        matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
                        matlabbatch{1}.spm.stats.factorial_design.masking.em = mask;
                        matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
                        matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
                        matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;
                        matlabbatch{2}.spm.stats.fmri_est.spmmat = cellstr(fullfile(matdir, 'SPM.mat'));
                        matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
                        matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;

                        spm('defaults', 'pet');
                        spm_jobman('run', matlabbatch);
                        clear matlabbatch;                    
                    end
                end
                
                clear matlabbatch;
                clear ID;                
                clear N1N5;
                clear ROdelay;
            end 
        end
    end
end

disp('===This script is done!===');
