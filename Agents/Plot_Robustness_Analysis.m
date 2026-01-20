% Plot_Robustness_Analysis.m - 仅读取数据并绘图
clear; clc;

% 1. 加载数据
data_file = 'Results/Robustness_Data_Summary.mat';
if ~exist(data_file, 'file')
    error('未找到汇总数据文件，请先运行 Generate_Robustness_Data.m');
end
load(data_file);

% 2. 定义你指定的专业配色
color_blue  = [79, 129, 189] / 255;  % #4F81BD (LEACH)
color_red   = [192, 80, 77] / 255;   % #C0504D (QELAR)
color_green = [155, 187, 89] / 255;  % #9BBB59 (本文优化 QL)

% 3. 绘图配置
figure('Color', 'w', 'Position', [100, 100, 850, 600]);
hold on;

% 绘制 LEACH
plot(load_steps, lifetimes_matrix(1,:), 's--', 'Color', color_blue, ...
    'LineWidth', 2, 'MarkerSize', 8, 'MarkerFaceColor', color_blue, 'DisplayName', 'LEACH (Baseline)');

% 绘制 QELAR
plot(load_steps, lifetimes_matrix(2,:), 'v--', 'Color', color_red, ...
    'LineWidth', 2, 'MarkerSize', 8, 'MarkerFaceColor', color_red, 'DisplayName', 'QELAR (Energy-only)');

% 绘制本文优化算法
plot(load_steps, lifetimes_matrix(3,:), 'o-', 'Color', color_green, ...
    'LineWidth', 2.5, 'MarkerSize', 10, 'MarkerFaceColor', color_green, 'DisplayName', '本文优化 Q-Learning');

% 4. 图表美化
xlabel('网络业务负载 (Packets / Node / Round)', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('网络寿命 (FND 轮数)', 'FontSize', 12, 'FontWeight', 'bold');
title('算法鲁棒性分析：不同负载压力对 FND 的影响', 'FontSize', 14);
grid on;
legend('Location', 'northeast', 'FontSize', 10);
set(gca, 'GridLineStyle', ':', 'GridAlpha', 0.5);

% 添加数值标注
for a = 1:size(lifetimes_matrix, 1)
    for l = 1:size(lifetimes_matrix, 2)
        text(load_steps(l), lifetimes_matrix(a, l), sprintf(' %d', lifetimes_matrix(a, l)), ...
            'FontSize', 8, 'VerticalAlignment', 'bottom');
    end
end

% 5. 保存图表
saveas(gcf, 'Results/Task9_Robustness_Final_Plot.png');
fprintf('鲁棒性对比图已更新并保存。\n');
% Plot_Robustness_Area.m - 区域规模鲁棒性独立绘图


% 1. 加载数据
data_file = 'Results/Robustness_Area_Summary.mat';
if ~exist(data_file, 'file'), error('请先运行 Generate_Robustness_Area.m'); end
load(data_file);

% 2. 定义专业配色 (RGB)
c_blue  = [79, 129, 189] / 255;  % LEACH
c_red   = [192, 80, 77] / 255;   % QELAR
c_green = [155, 187, 89] / 255;  % 本文算法

% 3. 绘图配置
figure('Color', 'w', 'Position', [100, 100, 700, 500]);
hold on;

% 绘制 LEACH
plot(area_steps, results_matrix(1,:), 's--', 'Color', c_blue, ...
    'LineWidth', 1.5, 'MarkerSize', 8, 'MarkerFaceColor', c_blue, 'DisplayName', 'LEACH (Baseline)');

% 绘制 QELAR
plot(area_steps, results_matrix(2,:), 'v--', 'Color', c_red, ...
    'LineWidth', 1.5, 'MarkerSize', 8, 'MarkerFaceColor', c_red, 'DisplayName', 'QELAR (Energy-only)');

% 绘制本文优化算法
plot(area_steps, results_matrix(3,:), 'o-', 'Color', c_green, ...
    'LineWidth', 2.5, 'MarkerSize', 10, 'MarkerFaceColor', c_green, 'DisplayName', '本文优化 Q-Learning');

% 4. 图表美化
xlabel('网络区域边长 (Area Side Length / m)', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('网络寿命 (FND / Rounds)', 'FontSize', 12, 'FontWeight', 'bold');
title('网络规模扩展性对比分析', 'FontSize', 14);
grid on; set(gca, 'GridLineStyle', ':', 'GridAlpha', 0.5);
legend('Location', 'northeast', 'FontSize', 10);

% 5. 保存结果
saveas(gcf, 'Results/Analysis_Robustness_Area.png');
fprintf('区域规模对比图已保存。\n');
% Plot_Robustness_Energy.m - 能量异构度鲁棒性独立绘图


% 1. 加载数据
data_file = 'Results/Robustness_Energy_Summary.mat';
if ~exist(data_file, 'file'), error('请先运行 Generate_Robustness_Energy.m'); end
load(data_file);

% 2. 配色设置
c_blue  = [79, 129, 189] / 255;
c_red   = [192, 80, 77] / 255;
c_green = [155, 187, 89] / 255;

% 3. 绘图配置
figure('Color', 'w', 'Position', [150, 150, 700, 500]);
hold on;

% 绘制 LEACH
plot(hetero_steps, results_matrix(1,:), 's--', 'Color', c_blue, ...
    'LineWidth', 1.5, 'MarkerSize', 8, 'MarkerFaceColor', c_blue, 'DisplayName', 'LEACH');

% 绘制 QELAR
plot(hetero_steps, results_matrix(2,:), 'v--', 'Color', c_red, ...
    'LineWidth', 1.5, 'MarkerSize', 8, 'MarkerFaceColor', c_red, 'DisplayName', 'QELAR');

% 绘制本文算法
plot(hetero_steps, results_matrix(3,:), 'o-', 'Color', c_green, ...
    'LineWidth', 2.5, 'MarkerSize', 10, 'MarkerFaceColor', c_green, 'DisplayName', '本文优化 Q-Learning');

% 4. 图表美化
xlabel('初始能量异构因子 (Heterogeneity Factor)', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('网络寿命 (FND / Rounds)', 'FontSize', 12, 'FontWeight', 'bold');
title('初始能量分布不均对网络寿命的影响', 'FontSize', 14);
grid on; set(gca, 'GridLineStyle', ':', 'GridAlpha', 0.5);
legend('Location', 'northeast', 'FontSize', 10);

% 5. 保存结果
saveas(gcf, 'Results/Analysis_Robustness_Energy.png');
fprintf('能量分布对比图已保存。\n');