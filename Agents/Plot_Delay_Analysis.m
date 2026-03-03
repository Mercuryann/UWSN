clear; clc;

% 1. 定义数据文件路径
leach_file = 'Results/Data_LEACH.mat';
qelar_file = 'Results/Data_QELAR.mat';
ql_file    = 'Results/Data_QL.mat';

% 创建画布 (增加高度以容纳两个子图)
figure('Color', 'w', 'Position', [100, 100, 900, 800]);

% --- 数据加载与预处理 ---
% 格式: {路径, 颜色, 线型, 标签, 线宽, 分组(1=High, 2=Low)}
configs = {
    qelar_file, '#c0504d', '-', 'QELAR',                   2.0, 1;
    leach_file, '#4f81bd', '--', 'LEACH',                  2.0, 2;
    ql_file,    '#9bbb59', '-', 'EC-QL',                   2.5, 2
};

max_rounds = 0;
data_store = cell(size(configs, 1), 2); % 存储 {rounds, delay_smooth}

for i = 1:size(configs, 1)
    file_path = configs{i, 1};
    if exist(file_path, 'file')
        data_struct = load(file_path);
        if isfield(data_struct, 'results'), res = data_struct.results; else, res = data_struct; end
        
        if isfield(res, 'delay_history')
            rounds = 1:length(res.delay_history);
            delay_data = res.delay_history;
            delay_smooth = smooth(delay_data, 50); 
            
            data_store{i, 1} = rounds;
            data_store{i, 2} = delay_smooth;
            max_rounds = max(max_rounds, max(rounds));
        end
    end
end

% --- 子图 1: 高延迟组 (QELAR) ---
subplot(2, 1, 1);
hold on;
plotted_any = false;
for i = 1:size(configs, 1)
    if configs{i, 6} == 1 && ~isempty(data_store{i, 1}) % Group 1
        plot(data_store{i, 1}, data_store{i, 2}, ...
            'Color', configs{i, 2}, 'LineStyle', configs{i, 3}, ...
            'LineWidth', configs{i, 5}, 'DisplayName', configs{i, 4});
        plotted_any = true;
    end
end
title('高延迟协议对比 (High Latency)', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('延迟 (s)', 'FontSize', 11);
grid on;
set(gca, 'GridLineStyle', ':', 'GridAlpha', 0.5, 'LineWidth', 1.1);
if plotted_any, legend('Location', 'best'); end
if max_rounds > 0, xlim([0, max_rounds]); end
% 适当调整 Y轴让曲线居中
% ylim auto is usually fine, but QELAR is ~3.

% --- 子图 2: 低延迟组 (LEACH vs QL) ---
subplot(2, 1, 2);
hold on;
plotted_any = false;
for i = 1:size(configs, 1)
    if configs{i, 6} == 2 && ~isempty(data_store{i, 1}) % Group 2
        plot(data_store{i, 1}, data_store{i, 2}, ...
            'Color', configs{i, 2}, 'LineStyle', configs{i, 3}, ...
            'LineWidth', configs{i, 5}, 'DisplayName', configs{i, 4});
        plotted_any = true;
    end
end
title('低延迟协议对比 (Low Latency)', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('延迟 (s)', 'FontSize', 11);
xlabel('仿真轮数 (Round)', 'FontSize', 12, 'FontWeight', 'bold');
grid on;
set(gca, 'GridLineStyle', ':', 'GridAlpha', 0.5, 'LineWidth', 1.1);
if plotted_any, legend('Location', 'best'); end
if max_rounds > 0, xlim([0, max_rounds]); end

% 为整个图形添加总标题
sgtitle('网络传输延迟分层对比分析', 'FontSize', 14, 'FontWeight', 'bold');

% 4. 保存
if ~exist('Results', 'dir'), mkdir('Results'); end
save_path = 'Results/Final_Delay_Comparison.png';
saveas(gcf, save_path);
fprintf('延迟对比子图已保存至: %s\n', save_path);
