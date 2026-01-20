% Generate_Robustness_Energy.m - 能量异构度鲁棒性数据生成
clear; clc;

% --- 核心修复：强力路径定位 ---
[current_dir, ~, ~] = fileparts(mfilename('fullpath'));
cd(current_dir);
root_path = current_dir;
while ~exist(fullfile(root_path, 'Network_Layer'), 'dir') && length(root_path) > 5
    root_path = fileparts(root_path);
end
addpath(genpath(root_path));
rehash path;

% --- 环境载入 ---
Config_Params; 

hetero_steps = [0.1, 0.3, 0.5, 0.7, 0.9];
algorithms = {'LEACH', 'QELAR', 'QL'};
results_matrix = zeros(length(algorithms), length(hetero_steps));

% --- 批量仿真 ---
for h = 1:length(hetero_steps)
    global Hetero_Factor;
    Hetero_Factor = hetero_steps(h);
    fprintf('\n--- 测试异构因子: %.1f ---\n', Hetero_Factor);
    
    for a = 1:length(algorithms)
        algo = algorithms{a};
        fprintf('运行 %s... ', algo);
        results_matrix(a, h) = Evaluate_Protocol_Performance(algo, 10); 
        fprintf('FND=%d\n', results_matrix(a, h));
    end
end

% --- 自动创建并保存 ---
if ~exist('Results', 'dir'), mkdir('Results'); end
save(fullfile(root_path, 'Results', 'Robustness_Energy_Summary.mat'), 'results_matrix', 'hetero_steps', 'algorithms');
fprintf('\n数据已保存至 Results 文件夹。\n');