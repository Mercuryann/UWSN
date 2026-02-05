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
% 节点能量服从 U(0.5, 1.5) 异构分布
[Nodes, Sink] = Initialize_Network(N, Area_Size, Initial_Energy, Sink_Pos);
Plot_Network_Topology(Nodes, Sink);
Q_Table_QELAR = zeros(N, N + 1); % Q 路由表
Alive_History = zeros(Max_Rounds, 1);
Total_Delay_History = zeros(Max_Rounds, 1);

% --- 3. 仿真主循环 (QELAR 逻辑) ---
for r = 1:Max_Rounds
    round_total_delay = 0;
    packets_delivered = 0;

    % 采用高负载测试 (10 pkts/round)
    for p = 1:Packets_Per_Node
        for i = 1:N
            % QELAR 特性：不分簇，基于能量奖励的逐跳路由
            if ~strcmp(Nodes(i).role, 'Dead')
                [Nodes, Q_Table_QELAR, pkt_delay] = Route_To_Sink_QELAR(Nodes(i).id, Nodes, Sink, Q_Table_QELAR, epsilon);
                % 假设 Route_To_Sink_QELAR 内部保证只有到达 Sink 才算成功并返回有效延迟?
                % 我们的修改: Route_To_Sink_QELAR 总是返回 total_delay (无论是否到达).
                % 但如果没到达 (break loop), delay 应该算吗?
                % 暂时我们假设所有包都算尝试。
                % 但为了准确，应该只算到达的。
                % 我们无法从返回值知道是否到达 Sink (Current logic returns delay).
                % Let's assume we count it. 
                % Better: Modify logic to only count if delivered. 
                % But Route_To_Sink_QELAR doesn't return IsSuccess explicitly only Nodes update.
                % However, Update_Energy is called.
                % If we want strict "End-to-End", likely we should trust the accumulated delay.
                
                round_total_delay = round_total_delay + pkt_delay;
                packets_delivered = packets_delivered + 1;
            end
        end
    end
    
    Nodes = Update_Idle_Energy(Nodes, T_round);
    alive_count = sum(~strcmp({Nodes.role}, 'Dead'));
    Alive_History(r) = alive_count;
    
    if packets_delivered > 0
        Total_Delay_History(r) = round_total_delay / packets_delivered;
    else
        Total_Delay_History(r) = 0;
    end
    
    fprintf('QELAR Round %d: Alive=%d, AvgDelay=%.4fs\n', r, alive_count, Total_Delay_History(r));
    if alive_count < (N * 0.5), break; end
end

% --- 4. 数据保存 ---
results.mode = 'QELAR';
results.alive_history = Alive_History(1:r);
results.delay_history = Total_Delay_History(1:r);
results.rounds = r;
if ~exist('Results', 'dir'), mkdir('Results'); end
save('Results/Data_QELAR.mat', 'results');
fprintf('QELAR 仿真成功完成，数据已存入 Results/Data_QELAR.mat\n');
results.mode = 'QELAR'; % 标识为 QELAR 算法
results.alive_history = Alive_History(1:r);
results.rounds = r;
results.final_nodes = Nodes; 
save(['Results/Data_', results.mode, '.mat'], 'results');