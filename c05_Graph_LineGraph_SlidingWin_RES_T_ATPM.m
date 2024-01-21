%-------------------------------------------------
% Statistical analysis and plotting of the average 
% t-values correlated with age within sliding
% windows of the AT and PM systems
%-------------------------------------------------

clc;
clear;
close all;

%% Set data table
root = 'YOUR_ROOT_PATH';

%% Set chart names
xname = 'Age';
yname = 't';
titlePrefix = '';

region = [1,2]; % AT, PM
region_name = {'AT system','PM system'};
cognition = {'N1N5', 'ROdelay'};

subs = dir(root);
subs = subs(3:end);

for m = 1:numel(subs)
    if isfolder(fullfile(root,subs(m).name)) == 1
        for re = 1:numel(cognition)
            subs_sec = dir(fullfile(root,subs(m).name, cognition{re},'*_ATPM.xlsx'));
            
            for n = 1:numel(subs_sec)
                xls = subs_sec(n).name;
                disp(xls);
                file = fullfile(root,subs(m).name, cognition{re}, xls);
                [~,~,raw] = xlsread(file); % Modify sheet number

                h = figure;
                set(h,'units','normalized','position',[0.1 0.1 0.5 0.7]); % Set the size of the plotting window
                set(h,'color','w'); % Set the background of the plotting window to white

                posi = 1; 
                X = cell2mat(raw(2:end,3));
                Y = {};
                
                for i = 1:numel(region) % ROI APTM
                    Y_temp = cell2mat(raw(2:end,region(i)+5));
                    
                    if isempty(Y_temp)
                        continue
                    else
                        [r,p] = corr(X, Y_temp, 'type', 'Pearson'); % Pearson correlation 
                        r = roundn(r, -3);
                        p = roundn(p, -4);

                        Y{posi,1} = cell2mat(raw(2:end,region(i)+5))';
                        legend{1, posi} = cell2mat(raw(1,region(i)+5));
                        posi = posi + 1;
                        disp([subs(m).name,titlePrefix,' with ',cell2mat(raw(1,region(i)+5)),', r = ', num2str(r),', p = ', num2str(p)])
                    end
                    clear Y_temp;                    
                end
                
                X = X';

                try 
                    %% Plotting
                    g(1,1) = gramm('x',X,'y',Y,'color',legend);                    
                    g(1,1).geom_point(); % Scatter plot
                    g(1,1).stat_glm(); % Plot the line and confidence interval based on the scatter plot
                    g(1,1).axe_property('LineWidth',5);
                    g(1,1).stat_glm('geom','line'); % Plot the line based on the scatter plot

                    g.set_line_options('base_size',6);
                    g.set_names('x',xname,'y',yname,'color','Group'); % Set titles for each part
                    g.set_text_options('base_size',25,'label_scaling',1.1,'font','calibri'); % Set font size, base font size is set to 16, and the font size of axis titles is set to 1.2 times the base font size
                    g.draw(); % Start drawing after setting the above properties

                    output = fullfile(root, ['FigCorrAll_',subs(m).name,titlePrefix,'_',xls(1:numel(xls)-5),'.tif']);
                    saveas(gcf,output);
                    close(gcf);
                catch
                    close(gcf);
                    continue
                end

                clear X;
                clear Y;                
                clear legend;         
            end
        end
    end
end

disp('===================This Script Has Done======================');
