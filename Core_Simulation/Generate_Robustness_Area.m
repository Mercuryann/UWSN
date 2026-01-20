% Generate_Robustness_Area.m - 区域规模鲁棒性数据生成
clear; clc;

% --- 核心修复：强力路径定位 ---
% 获取当前脚本所在的文件夹
[current_dir, ~, ~] = fileparts(mfilename('fullpath'));
cd(current_dir); % 切换到脚本目录
% 尝试向上寻找包含 Network_Layer 的根目录
root_path = current_dir;
while ~exist(fullfile(root_path, 'Network_Layer'), 'dir') && length(root_path) > 5
    root_path = fileparts(root_path);
end
% 添加根目录及其所有子目录
addpath(genpath(root_path));
rehash path; % 强制刷新 MATLAB 路径缓存

% --- 环境载入 ---
Config_Params; 

area_steps = [300, 400, 500, 600, 700, 800];
algorithms = {'LEACH', 'QELAR', 'QL'};
results_matrix = zeros(length(algorithms), length(area_steps));

% --- 批量仿真 ---
for s = 1:length(area_steps)
    global Area_Size;
    Area_Size = area_steps(s);
    fprintf('\n--- 测试区域规模: %d x %d ---\n', Area_Size, Area_Size);
    
    for a = 1:length(algorithms)
        algo = algorithms{a};
        fprintf('运行 %s... ', algo);
        % 调用已封装的评估函数
        results_matrix(a, s) = Evaluate_Protocol_Performance(algo, 10); 
        fprintf('FND=%d\n', results_matrix(a, s));
    end
end

% --- 自动创建并保存 ---
if ~exist('Results', 'dir'), mkdir('Results'); end
save(fullfile(root_path, 'Results', 'Robustness_Area_Summary.mat'), 'results_matrix', 'area_steps', 'algorithms');
fprintf('\n数据已保存至 Results 文件夹。\n');