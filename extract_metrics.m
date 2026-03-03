% extract_metrics.m — 临时脚本，仅读取 Results/ 中的数据，不修改任何项目文件。
% 使用方法：在 MATLAB 中将工作目录切换到项目根目录，然后运行 extract_metrics

files  = {'Results/Data_LEACH.mat', 'Results/Data_QELAR.mat', 'Results/Data_QL.mat'};
labels = {'LEACH', 'QELAR', 'EC-QL'};
n = numel(files);

FND              = zeros(1, n);
mean_delay       = zeros(1, n);
energy_std       = zeros(1, n);
total_energy_end = zeros(1, n);

for i = 1:n
    d   = load(files{i});
    res = d.results;

    % --- FND：存活节点数首次低于 100 的轮次 ---
    ah      = double(res.alive_history(:));
    idx_fnd = find(ah < 100, 1, 'first');
    if isempty(idx_fnd), idx_fnd = numel(ah); end
    FND(i)  = idx_fnd;

    % --- 端到端平均延迟（只统计有数据的轮次）---
    dh = double(res.delay_history(:));
    mean_delay(i) = mean(dh(dh > 0));

    % --- 最终节点剩余能量标准差 & 总剩余能量 ---
    nodes = res.final_nodes;
    E     = arrayfun(@(nd) nd.energy, nodes);
    energy_std(i)       = std(E);
    total_energy_end(i) = sum(E);
end

% ========= 打印汇总表 =========
fprintf('\n%s\n', repmat('=', 1, 60));
fprintf('  核心指标汇总\n');
fprintf('%s\n', repmat('=', 1, 60));
fprintf('%-10s  %6s  %14s  %14s  %14s\n', ...
    'Protocol', 'FND', 'AvgDelay(s)', 'EnergyStd(J)', 'TotalEnergy(J)');
fprintf('%s\n', repmat('-', 1, 60));
for i = 1:n
    fprintf('%-10s  %6d  %14.4f  %14.4f  %14.4f\n', ...
        labels{i}, FND(i), mean_delay(i), energy_std(i), total_energy_end(i));
end

% ========= EC-QL 相对提升 =========
fprintf('\n%s\n', repmat('=', 1, 60));
fprintf('  EC-QL 相对提升（正值=EC-QL 更优）\n');
fprintf('%s\n', repmat('=', 1, 60));
for i = 1:2
    fnd_imp    = (FND(3)              - FND(i))              / FND(i)              * 100;
    delay_imp  = (mean_delay(i)       - mean_delay(3))       / mean_delay(i)       * 100;
    std_imp    = (energy_std(i)       - energy_std(3))       / energy_std(i)       * 100;
    energy_imp = (total_energy_end(3) - total_energy_end(i)) / total_energy_end(i) * 100;

    fprintf('\nEC-QL vs %s:\n', labels{i});
    fprintf('  FND 延长           : %+.1f%%\n', fnd_imp);
    fprintf('  平均延迟 降低      : %+.1f%%\n', delay_imp);
    fprintf('  能耗标准差 降低    : %+.1f%%\n', std_imp);
    fprintf('  最终总剩余能量 提升: %+.1f%%\n', energy_imp);
end
fprintf('\n');
