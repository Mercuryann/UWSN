clear; clc;

% 1. 定义数据文件路径
leach_file = 'Results/Data_LEACH.mat';
qelar_file = 'Results/Data_QELAR.mat';
ql_file    = 'Results/Data_QL.mat';

% 创建画布
figure('Color', 'w', 'Position', [100, 100, 900, 700]);
hold on;

% 2. 配置文件矩阵 (增加了第 6 列：文字垂直偏移；第 7 列：水平对齐方式)
% 格式: {路径, 颜色, 线型, 标签, 线宽, Y偏移, 水平对齐}
configs = {
    leach_file, '#4f81bd', '--', 'LEACH',                  2.5,  3, 'right';
    qelar_file, '#c0504d', '--', 'QELAR',                  2.5,  3, 'left';
    ql_file,    '#9bbb59', '--', 'Q-Learning Clustering',  2.5,  3, 'center'
};

for i = 1:size(configs, 1)
    file_path = configs{i, 1};
    
    if exist(file_path, 'file')
        data_struct = load(file_path);
        if isfield(data_struct, 'results'), res = data_struct.results; else, res = data_struct; end
        
        % 绘制生存曲线
        rounds = 1:res.rounds;
        plot(rounds, res.alive_history, ...
            'Color', configs{i, 2}, 'LineStyle', configs{i, 3}, ...
            'LineWidth', configs{i, 5}, 'DisplayName', configs{i, 4});
        
        % --- 自动标注 FND ---
        fnd_idx = find(res.alive_history < 100, 1, 'first');
        if ~isempty(fnd_idx)
            % 绘制 FND 标记点
            plot(fnd_idx, res.alive_history(fnd_idx), 'ko', ...
                'MarkerFaceColor', configs{i, 2}, 'MarkerSize', 6, 'HandleVisibility', 'off'); 
            
            % 优化后的文字标注
            % 使用 configs 中定义的偏移和对齐方式，防止重叠
            text(fnd_idx, res.alive_history(fnd_idx) + configs{i, 6}, ...
                sprintf('FND: %d', fnd_idx), ...
                'Color', configs{i, 2}, ...
                'FontSize', 20, ...
                'FontWeight', 'bold', ...
                'HorizontalAlignment', configs{i, 7});
        end
        fprintf('成功绘制: %s, FND: %d\n', configs{i, 4}, fnd_idx);
    else
        warning('文件未找到: %s', file_path);
    end
end

% 3. 图表美化
xlabel('仿真轮数 (Round)', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('存活节点数 (Number of Alive Nodes)', 'FontSize', 12, 'FontWeight', 'bold');
title('无线传感器网络节点存活曲线对比', 'FontSize', 14);

legend('Location', 'southwest', 'FontSize', 11);
grid on;
set(gca, 'GridLineStyle', ':', 'GridAlpha', 0.5, 'LineWidth', 1.1);

% 关键修改：抬高 Y 轴上限到 110，防止顶部标签被遮挡或挡住线条
ylim([40, 110]); 
xlim([0, max(rounds)*1.1]); % 适当增加 X 轴右侧空间

% 4. 保存
if ~exist('Results', 'dir'), mkdir('Results'); end
save_path = 'Results/Final_Comparison_Task7.png';
saveas(gcf, save_path);
fprintf('图片已保存至: %s\n', save_path);