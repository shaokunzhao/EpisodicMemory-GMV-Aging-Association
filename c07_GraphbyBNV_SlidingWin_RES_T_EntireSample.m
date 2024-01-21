%-----------------------------------------------------------------------
% Graph by BrainNet Viewer
%-----------------------------------------------------------------------

clc;
clear;

root = 'YOUR_ROOT_PATH';
config = 'YOUR_CONFIG_PATH';

file = dir(root);
file = file(3:end);

for n = 1:numel(file)
    if isfolder(fullfile(root,file(n).name)) == 1       
        file_sec = dir(fullfile(root,file(n).name,'Slide_win_Residual_Norm','Slide_win_180*'));
        
        for m = 1:numel(file_sec)
            if isfolder(fullfile(root,file(n).name,'Slide_win_Residual_Norm',file_sec(m).name)) == 1
                file_thi = dir(fullfile(root,file(n).name,'Slide_win_Residual_Norm',file_sec(m).name));
                file_thi = file_thi(3:end);
                
                for l = 1:numel(file_thi)
                    file_for = dir(fullfile(root,file(n).name,'Slide_win_Residual_Norm', file_sec(m).name, file_thi(l).name));
                    file_for = file_for(3:end);
                    
                    for h = 1:numel(file_for)
                        im = dir(fullfile(root,file(n).name,'Slide_win_Residual_Norm', file_sec(m).name, file_thi(l).name,file_for(h).name,'result_*_T_mask.nii'));
                        
                        if numel(im) > 0                            
                            disp([file(n).name,'Slide_win_Residual_Norm','-', file_sec(m).name,'-', file_thi(l).name,file_for(h).name, ' is processing']);                             
                            
                            for x = 1:numel(im)                               
                                f = fullfile(root,file(n).name,'Slide_win_Residual_Norm', file_sec(m).name, file_thi(l).name,file_for(h).name,im(x).name); 
                                fname = fullfile(root,file(n).name,'Slide_win_Residual_Norm', file_sec(m).name, file_thi(l).name,file_for(h).name,[file_for(h).name, '_mask_BNV.png']);
                                BrainNet_MapCfg('BrainMesh_ICBM152_smoothed.nv',f,config, fname);  
                                close all;
                            end
                        end
                    end
                end
            end
        end
    else
        continue
    end
end

disp('=========================Done==========================');
