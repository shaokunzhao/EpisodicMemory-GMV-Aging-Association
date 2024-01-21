%-------------------------------------------------
% Extracting average T-values based on AAL90 atlas for each sliding window
%-------------------------------------------------

clc;
clear;

root = 'REPLACE_WITH_YOUR_ROOT_PATH'; 
ROItitle = 'REPLACE_WITH_YOUR_ROITITLE_PATH'; 
mask = 'REPLACE_WITH_YOUR_MASK_PATH'; 
gen = {'Gender_0', 'Gender_1'};

subs = dir(root);
subs = subs(3:end);

for i = 1:numel(subs) 
    if isfolder(fullfile(root,subs(i).name))
        subs_sec = dir(fullfile(root,subs(i).name));
        subs_sec = subs_sec(3:end); 
        
        for k = 1:numel(subs_sec)
            if isfolder(fullfile(root, subs(i).name, subs_sec(k).name))
                for g = 1:numel(gen)
                    table = {'Filename', 'Gender', 'AGEmean', 'AGEmin', 'AGEmax'};
                    [~, ~, sheet] = xlsread(ROItitle);
                    title = sheet(3:92, 2);
                    table(1, 6:5+numel(title)) = title';
                    subs_s = dir(fullfile(fullfile(root,subs(i).name, subs_sec(k).name), [gen{g},'*.nii']));
                    
                    for j = 1:numel(subs_s)
                        disp([subs(i).name, '--', subs_sec(k).name, '--', subs_s(j).name, ' is processing!'])
                        file = fullfile(fullfile(root,subs(i).name, subs_sec(k).name), subs_s(j).name);
                        ResNii = spm_vol(file);
                        ResVol = spm_read_vols(ResNii);

                        a = strsplit(subs_s(j).name, '_');
                        table{j+1, 1} = subs_s(j).name;
                        table{j+1, 2} = a{2};
                        table{j+1, 3} = a{6};
                        table{j+1, 4} = a{3};
                        table{j+1, 5} = a{4};

                        Nii_mask = spm_vol(mask);
                        Vol_mask = spm_read_vols(Nii_mask);

                        for mask_order = 1:90 % aal90
                            Vol_mask_tmp = Vol_mask;
                            Vol_mask_tmp(Vol_mask_tmp~=mask_order) = 0;
                            Vol_mask_tmp(Vol_mask_tmp==mask_order) = 1;

                            ResVol_tem = ResVol .* Vol_mask_tmp;

                            table{j+1, mask_order+5} = mean(mean(mean(ResVol_tem)));
                            if isnan(table{j+1, mask_order+5})
                                table{j+1, mask_order+5} = 0;
                            end
                        end
                    end
                    
                    output = fullfile(root, subs(i).name, subs_sec(k).name, [subs_sec(k).name, '_', subs(i).name, '_', gen{g}, '.xlsx']);
                    xlswrite(output, table);
                    clear table;
                end
            end
        end
    end
end

disp('Done');
