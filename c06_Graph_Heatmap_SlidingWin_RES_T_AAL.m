%-------------------------------------------------
% Drawing a heatmap illustrating the 
% correlation between average t-values
% of 90 ROIs based on AAL atlas and age
%-------------------------------------------------

clc;
clear;
close all;

%% Settings
root = 'YOUR_ROOT_PATH';
outputdir = 'YOUR_OUTPUT_PATH';
thre = 0.05;

% AAL 90 ROI names
ROIname = {'PreCG.L', 'PreCG.R', 'SFGdor.L', 'SFGdor.R', 'ORBsup.L', 'ORBsup.R', 'MFG.L', 'MFG.R', 'ORBmid.L', 'ORBmid.R', 'IFGoperc.L', 'IFGoperc.R', 'IFGtriang.L', 'IFGtriang.R', 'ORBinf.L', 'ORBinf.R', 'ROL.L', 'ROL.R', 'SMA.L', 'SMA.R', 'OLF.L', 'OLF.R', 'SFGmed.L', 'SFGmed.R', 'ORBsupmed.L', 'ORBsupmed.R', 'REC.L', 'REC.R', 'INS.L', 'INS.R', 'ACG.L', 'ACG.R', 'DCG.L', 'DCG.R', 'PCG.L', 'PCG.R', 'HIP.L', 'HIP.R', 'PHG.L', 'PHG.R', 'AMYG.L', 'AMYG.R', 'CAL.L', 'CAL.R', 'CUN.L', 'CUN.R', 'LING.L', 'LING.R', 'SOG.L', 'SOG.R', 'MOG.L', 'MOG.R', 'IOG.L', 'IOG.R', 'FFG.L', 'FFG.R', 'PoCG.L', 'PoCG.R', 'SPG.L', 'SPG.R', 'IPL.L', 'IPL.R', 'SMG.L', 'SMG.R', 'ANG.L', 'ANG.R', 'PCUN.L', 'PCUN.R', 'PCL.L', 'PCL.R', 'CAU.L', 'CAU.R', 'PUT.L', 'PUT.R', 'PAL.L', 'PAL.R', 'THA.L', 'THA.R', 'HES.L', 'HES.R', 'STG.L', 'STG.R', 'TPOsup.L', 'TPOsup.R', 'MTG.L', 'MTG.R', 'TPOmid.L', 'TPOmid.R', 'ITG.L', 'ITG.R'};
region = {[1:28,31:34],[35:36,57:70],43:54,[37:42,55:56,79:90],[29:30,71:78]}; % F,P,O,T,sub
region_name = {'Frontal','Parietal','Occipital','Temporal','Subcortical'};
titleName = ''; % Center circle title
File_name = {'N1N5', 'ROdelay'};
overlay = [0.2 0.3 0.4];

subs = dir(root);
subs = subs(3:end);

for f = 1:numel(File_name)
    for o = 1:numel(overlay)
        Data = {};
        varNameCol = {};
        for m = 1:numel(subs)
            if isfolder(fullfile(root,subs(m).name)) == 1
                subs_sec = dir(fullfile(root,subs(m).name, File_name{f},[File_name{f},'*', num2str(overlay(o)),'_Gender*.xlsx']));            
                for n = 1:numel(subs_sec)
                    xls = subs_sec(n).name;
                    disp(['===================',xls, '====================']);
                    file = fullfile(root,subs(m).name, File_name{f}, xls);
                    [~,~,raw] = xlsread(file); % Modify sheet number

                   % Calculate p-values and convert to FDRp
                    X = cell2mat(raw(2:end,3));
                    for i = 1:90 % ROI number (AAL90)
                        Y_temp = cell2mat(raw(2:end,i+5));
                        if sum(Y_temp) == 0
                            p_list(i,1) = nan;
                            continue
                        else
                            [r,p] = corr(X, Y_temp, 'type', 'Pearson'); % Pearson correlation 
                            p_list(i,1) = p;                        
                        end
                        clear Y_temp;                    
                    end

                    % FDR correction
                    table_p_tem = p_list;
                    ind_val = 1:numel(table_p_tem);
                    table_p_tem = sortrows([table_p_tem,ind_val'],1,'descend');
                    FDRp = mafdr(table_p_tem(:,1),'BHFDR', true);
                    FDRp = sortrows([FDRp,table_p_tem(:,2)],2,'ascend');
                    FDRp_list = FDRp(:,1); 

                    % Calculate results after correction
                    X = cell2mat(raw(2:end,3));
                    Y = [];                
                    for re = 1:numel(region)
                        disp(['-----------------', region_name{re},'-----------------']);                                
                        sig_num = 1;
                        for i = region{re} % ROI number (AAL90)
                            Y_temp = cell2mat(raw(2:end,i+5));
                            [r,~] = corr(X, Y_temp, 'type', 'Pearson'); % Pearson correlation 
                            r = roundn(r, -2);
                            p = FDRp_list(i,1); 

                            if p < thre && p ~= 0 
                                Data{re}(n, sig_num) = r;
                                varNameCol{re}{1, sig_num} = ROIname{i};
                                sig_num = sig_num + 1;
                                if p < .001
                                    disp([cell2mat(raw(1,i+5)),', r = ', num2str(r),', FDRp < .001 ']);
                                else
                                    disp([cell2mat(raw(1,i+5)),', r = ', num2str(r),', FDRp = ', num2str(roundn(p, -3))]);
                                end
                            else                            
                                Data{re}(n, sig_num) = 0;
                                varNameCol{re}{1, sig_num} = ROIname{i};
                                sig_num = sig_num + 1;                        
                                continue
                            end
                            clear legend;
                        end
                    end
                end        
            end    
        end

        % Delete all 0 columns
        for s = 1:numel(Data)
            zero_num = 0;
            for nan_ind = 1:numel(Data{s}(1,:))
                if sum(Data{s}(:,nan_ind-zero_num)) == 0
                    Data{s}(:, nan_ind-zero_num)=[];
                    varNameCol{s}(:, nan_ind-zero_num)=[];
                    zero_num = zero_num + 1;
                else
                    continue
                end
            end
        end



        %% Graph 
        x=linspace(CLim(1),CLim(2),size(CMap,1))';
        y1=CMap(:,1);y2=CMap(:,2);y3=CMap(:,3);
        colorFunc=@(X)[interp1(x,y1,X,'pchip'),interp1(x,y2,X,'pchip'),interp1(x,y3,X,'pchip')];
        tS=linspace(0,1,50);
        for k=1:length(Data)
            theta3=theta1+(theta2-theta1).*(k*txtRatio+sum(ringRatio2(1:(k-1))));
            tData=Data{k};
            for i=1:size(Data{k},1)
                for j=1:size(Data{k},2)
                    tT=theta3+[j-1,j].*ringRatio1.*(theta2-theta1);
                    tTd=tT(2)-tT(1);
                    tT=[tT(1)+tTd/30,tT(2)-tTd/30];
                    tR=R2+(R1-R2).*[i-1,i]./size(Data{k},1);
                    tRd=tR(2)-tR(1);
                    tR=[tR(1)+tRd/30,tR(2)-tRd/30];
                    tT=[tT(1)+(tT(2)-tT(1)).*tS,tT(2)+(tT(1)-tT(2)).*tS];
                    tR=[tR(1).*ones(1,50),tR(2).*ones(1,50)];
                    if tData(i,j)>thresholdValue(2)||tData(i,j)<thresholdValue(1)
                        fill(ax,tR.*cos(tT),tR.*sin(tT),colorFunc(tData(i,j)),'EdgeColor',[0,0,0],'LineWidth',1.2,'EdgeAlpha',.8)
                    else
                        fill(ax,tR.*cos(tT),tR.*sin(tT),colorFunc(tData(i,j)),'EdgeColor',[1,1,1],'LineWidth',1.2)
                    end
                end
            end
        end


        for k=1:length(Data)
            tT=theta1+(theta2-theta1).*((k-.5)*txtRatio+sum(ringRatio2(1:(k-1))));
            for i=1:size(Data{k},1)
                tR=R2+(R1-R2).*[i-1,i]./size(Data{k},1);
                tR=mean(tR);
                tVarNameRow=varNameRow{k};
                if tT<0&&tT>-pi
                    text(ax,tR.*cos(tT),tR.*sin(tT),tVarNameRow{i},'FontSize',14,...
                        'Color',[0,0,0],'HorizontalAlignment','center','Rotation',tT./pi.*180+90, 'FontName','calibri')
                else
                    text(ax,tR.*cos(tT),tR.*sin(tT),tVarNameRow{i},'FontSize',14,...
                        'Color',[0,0,0],'HorizontalAlignment','center','Rotation',tT./pi.*180-90, 'FontName','calibri')
                end
            end
        end

        for k=1:length(Data)
            theta3=theta1+(theta2-theta1).*(k*txtRatio+sum(ringRatio2(1:(k-1))));
            tR=(R2*3+R3*2)/5;
            tVarNameCol=varNameCol{k};
            for j=1:size(Data{k},2)
                tT=theta3+[j-1,j].*ringRatio1.*(theta2-theta1);
                tT=mean(tT);
                if tT<0&&tT>-pi
                    text(ax,tR.*cos(tT),tR.*sin(tT),tVarNameCol{j},'Rotation',tT./pi.*180+120,...
                        'Color',[0,0,0],'HorizontalAlignment','center','FontSize',10, 'FontName','calibri')
                else
                    text(ax,tR.*cos(tT),tR.*sin(tT),tVarNameCol{j},'Rotation',tT./pi.*180-60,...
                        'Color',[0,0,0],'HorizontalAlignment','center','FontSize',10, 'FontName','calibri')
                end
            end
        end

        tS=linspace(0,1,100);
        for k=1:length(Data)
            theta3=theta1+(theta2-theta1).*((k-1)*txtRatio+sum(ringRatio2(1:(k-1))));
            theta4=theta1+(theta2-theta1).*(k*txtRatio+sum(ringRatio2(1:k)));
            tT=[theta3,theta4];
            tT=[tT(1)-2*pi/40/length(Data),tT(2)];
            tR=[R3,R4];
            ttT=mean(tT);ttR=mean(tR);
            tT=[tT(1)+(tT(2)-tT(1)).*tS,tT(2)+(tT(1)-tT(2)).*tS];
            tR=[tR(1).*ones(1,100),tR(2).*ones(1,100)];
            fill(ax,tR.*cos(tT),tR.*sin(tT),[1,1,1],'EdgeColor',[.3,.3,.3],'LineWidth',1.2,'EdgeAlpha',.8)
            if ttT<0&&ttT>-pi
                text(ax,ttR.*cos(ttT),ttR.*sin(ttT),className{k},'Rotation',ttT./pi.*180+90,...
                    'Color',[0,0,0],'HorizontalAlignment','center','FontSize',14, 'FontName','calibri')
            else
                text(ax,ttR.*cos(ttT),ttR.*sin(ttT),className{k},'Rotation',ttT./pi.*180-90,...
                    'Color',[0,0,0],'HorizontalAlignment','center','FontSize',14, 'FontName','calibri')
            end
        end

        colormap(colorFunc(linspace(-1,1,256)'))
        caxis(CLim)
        cb=colorbar();
        cb.Location="southoutside";
        cb.LineWidth=1;
        cb.TickDirection='out';
        cb.TickLength=.005;
        cb.FontSize=11;
        cb.Label.String={'Correlation';'coefficient r'};
        cb.Label.Position=[-.9,3.5,0];
        cb.Label.FontSize=13;


        output = fullfile(outputdir, [File_name{f}, '_', num2str(overlay(o)), '_Gender.tiff']);
        saveas(gcf,output);
        close(gcf);
    end
end

disp('Done')