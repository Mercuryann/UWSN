% Generate_Robustness_Data.m - 修正版
clear; clc;

% 1. 环境路径处理
[root_path, ~, ~] = fileparts(mfilename('fullpath'));
addpath(genpath(root_path));
Config_Params; 

% 2. 定义参数
load_steps = [5, 10, 20, 30, 40]; 
algorithms = {'LEACH', 'QELAR', 'QL'};
lifetimes_matrix = zeros(length(algorithms), length(load_steps));

% 3. 仿真主循环
for l = 1:length(load_steps)
    current_load = load_steps(l);
    fprintf('\n--- 负载测试中: %d pkts/round ---\n', current_load);
    
    for a = 1:length(algorithms)
        algo = algorithms{a};
        fprintf('运行 %s... ', algo);
        
        % 调用评估函数 (已改名)
        fnd = Evaluate_Protocol_Performance(algo, current_load); 
        
        lifetimes_matrix(a, l) = fnd;
        fprintf('完成 (FND=%d)\n', fnd);
    end
end

% --- 修正部分：自动检查并创建 Results 文件夹 ---
if ~exist('Results', 'dir')
    mkdir('Results');
end

% 4. 保存汇总数据
save('Results/Robustness_Data_Summary.mat', 'lifetimes_matrix', 'load_steps', 'algorithms');
fprintf('\n数据已成功保存至 Results/Robustness_Data_Summary.mat\n');