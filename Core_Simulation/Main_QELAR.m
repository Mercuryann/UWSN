% Main_QELAR.m - 任务七：QELAR 协议复现
clear; clc; close all;

% --- 1. 自动寻找项目根目录并添加路径 ---
% 获取当前脚本的绝对路径
[script_dir, ~, ~] = fileparts(mfilename('fullpath'));
% 向上递归寻找包含 'Network_Layer' 的根目录
root_path = script_dir;
while ~exist(fullfile(root_path, 'Network_Layer'), 'dir') && length(root_path) > 3
    root_path = fileparts(root_path);
end

if exist(fullfile(root_path, 'Network_Layer'), 'dir')
    addpath(genpath(root_path));
    cd(root_path); % 强制切换 MATLAB 工作目录到根目录
    rehash path;
else
    error('无法定位项目根目录，请确保项目文件夹结构完整。');
end

% --- 2. 环境与网络初始化 ---
Config_Params; 
% 节点能量服从 U(0.5, 1.5) 异构分布
[Nodes, Sink] = Initialize_Network(N, Area_Size, Initial_Energy, Sink_Pos);
Plot_Network_Topology(Nodes, Sink);
Q_Table_QELAR = zeros(N, N + 1); % Q 路由表
Alive_History = zeros(Max_Rounds, 1);

% --- 3. 仿真主循环 (QELAR 逻辑) ---
for r = 1:Max_Rounds
    % 采用高负载测试 (10 pkts/round)
    for p = 1:Packets_Per_Node
        for i = 1:N
            % QELAR 特性：不分簇，基于能量奖励的逐跳路由
            if ~strcmp(Nodes(i).role, 'Dead')
                [Nodes, Q_Table_QELAR] = Route_To_Sink_QELAR(Nodes(i).id, Nodes, Sink, Q_Table_QELAR, epsilon);
            end
        end
    end
    
    Nodes = Update_Idle_Energy(Nodes, T_round);
    alive_count = sum(~strcmp({Nodes.role}, 'Dead'));
    Alive_History(r) = alive_count;
    
    fprintf('QELAR Round %d: Alive Nodes = %d\n', r, alive_count);
    if alive_count < (N * 0.5), break; end
end

% --- 4. 数据保存 ---
results.mode = 'QELAR';
results.alive_history = Alive_History(1:r);
results.rounds = r;
if ~exist('Results', 'dir'), mkdir('Results'); end
save('Results/Data_QELAR.mat', 'results');
fprintf('QELAR 仿真成功完成，数据已存入 Results/Data_QELAR.mat\n');
results.mode = 'QELAR'; % 标识为 QELAR 算法
results.alive_history = Alive_History(1:r);
results.rounds = r;
results.final_nodes = Nodes; 
save(['Results/Data_', results.mode, '.mat'], 'results');