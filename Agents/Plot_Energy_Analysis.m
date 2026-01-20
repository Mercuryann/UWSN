% Plot_Energy_Analysis.m - 任务八：能量均衡性深度分析
clear; clc;

% 1. 定义提供的专业配色 (RGB 归一化)
color_blue  = [79, 129, 189] / 255;  % #4F81BD (LEACH)
color_red   = [192, 80, 77] / 255;   % #C0504D (QELAR)
color_green = [155, 187, 89] / 255;  % #9BBB59 (Proposed)

files = {'Results/Data_LEACH.mat', 'Results/Data_QELAR.mat', 'Results/Data_QL.mat'};
labels = {'LEACH', 'QELAR', '本文优化算法'};
colors = {color_blue, color_red, color_green};

figure('Color', 'w', 'Position', [100, 100, 1000, 500]);

% --- 子图 1: 节点剩余能量 vs. 深度 (Z轴) ---
subplot(1, 2, 1); hold on;
std_devs = [];

for i = 1:length(files)
    if exist(files{i}, 'file')
        load(files{i});
        nodes = results.final_nodes;
        
        % 提取所有节点的深度和剩余能量
        depths = [nodes.z];
        energies = [nodes.energy];
        
        % 计算能量标准差 (均衡性指标)
        std_devs(i) = std(energies);
        
        % 绘制散点图
        scatter(depths, energies, 30, colors{i}, 'filled', ...
            'MarkerFaceAlpha', 0.6, 'DisplayName', labels{i});
    end
end

xlabel('节点深度 (Depth / m)', 'FontSize', 11);
ylabel('剩余能量 (Remaining Energy / J)', 'FontSize', 11);
title('节点能量与深度分布关系图', 'FontSize', 12, 'FontWeight', 'bold');
grid on; legend('Location', 'northeast');

% --- 子图 2: 能量均衡性对比 (标准差) ---
subplot(1, 2, 2);
b = bar(std_devs, 'FaceColor', 'flat');
b.CData(1,:) = color_blue;
b.CData(2,:) = color_red;
b.CData(3,:) = color_green;

set(gca, 'XTickLabel', labels, 'FontSize', 10);
ylabel('能量标准差 (Energy Std Dev)', 'FontSize', 11);
title('全网能耗均衡性对比', 'FontSize', 12, 'FontWeight', 'bold');
grid on;

% 添加数值标签
for j = 1:length(std_devs)
    text(j, std_devs(j), sprintf('%.4f', std_devs(j)), ...
        'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'FontWeight', 'bold');
end

saveas(gcf, 'Results/Task8_Energy_Analysis.png');