% Plot_Physical_Model.m - 水声信道物理特性分析绘图
clear; clc;
addpath(genpath('../Physical_Layer')); % 确保能调用物理层公式

% 1. 设置分析范围
f_range = 1:0.1:100;   % 1kHz 到 100kHz
d_range = 10:10:1000;  % 10m 到 1000m

% 2. 创建画布
fig = figure('Name', 'Physical Layer Analysis', 'Color', 'w', 'Position', [100, 100, 800, 600]);

% 3. 绘制频率 vs 吸收系数 (Thorp)
subplot(2,1,1);
alphas = arrayfun(@Calc_Thorp_Alpha, f_range);
plot(f_range, alphas, 'r-', 'LineWidth', 2);
grid on;
xlabel('频率 (kHz)', 'FontSize', 12); 
ylabel('吸收系数 \alpha (dB/km)', 'FontSize', 12);
title('频率与吸收系数关系 (Thorp 模型)', 'FontSize', 14, 'FontWeight', 'bold');

% 4. 绘制距离 vs 传输损耗 (不同频率对比)
subplot(2,1,2);
frequencies = [10, 20, 50]; 
hold on;
for f = frequencies
    tls = arrayfun(@(d) Channel_Urick(d, f), d_range);
    plot(d_range, tls, 'LineWidth', 1.5, 'DisplayName', [num2str(f), ' kHz']);
end
grid on; 
legend('Location', 'best');
xlabel('距离 (m)', 'FontSize', 12); 
ylabel('传输损耗 TL (dB)', 'FontSize', 12);
title('距离与传输损耗关系 (Urick 模型)', 'FontSize', 14, 'FontWeight', 'bold');

% 5. 自动保存结果到 Results 文件夹
if ~exist('../Results', 'dir'), mkdir('../Results'); end
saveas(fig, '../Results/Channel_Model_Curves.png');

fprintf('物理层特性分析图已生成并保存至 ../Results/Channel_Model_Curves.png\n');