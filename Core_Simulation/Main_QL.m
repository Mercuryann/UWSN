% Main_QL.m - 增加 Epsilon 衰减逻辑
clear; clc; close all;
addpath(genpath(pwd)); 
Config_Params; 

[Nodes, Sink] = Initialize_Network(N, Area_Size, Initial_Energy, Sink_Pos);
Plot_Network_Topology(Nodes, Sink);
Q_Table_Cluster = zeros(18, 2); 
Q_Table_Routing = zeros(N, N); 
Alive_History = zeros(Max_Rounds, 1);

% --- 设定 Epsilon 衰减参数 ---
initial_epsilon = 0.5;  % 初始探索率调高，前期疯狂学习
min_epsilon = 0.05;     % 最小探索率，保留一点点探索性
decay_rate = 0.98;      % 每轮衰减系数

Total_Delay_History = zeros(Max_Rounds, 1);

for r = 1:Max_Rounds
    % 计算当前轮次的 epsilon
    current_epsilon = max(min_epsilon, initial_epsilon * (decay_rate^r));
    
    % --- 阶段1：分簇 (使用 current_epsilon) ---
    [Cluster_Heads, Members] = Run_Cluster_Election(Nodes, Q_Table_Cluster, current_epsilon);
    
    % --- 阶段2：高负载数据传输与多跳路由 ---
    round_total_delay = 0;
    packets_delivered = 0;

    if ~isempty(Cluster_Heads)
        for p = 1:Packets_Per_Node
            % 1. 成员向簇头发送数据
            for i = 1:length(Members)
                if ~isempty(Members(i).CH_id) % 确保关联了簇头
                    [Nodes, ~] = Update_Energy(Nodes, Members(i).id, Members(i).CH_id, Packet_Length);
                    % 简单添加成员到CH的延迟 (假设1500m/s)
                    % 需获取距离，由于代码结构限制，暂忽略成员延迟或近似处理
                    % 为精确起见，可在 Update_Energy 后计算，但为保持代码简洁，
                    % 我们假设成员非常接近其簇头，主要延迟在主干路由。
                    % 或者我们应计算它？成员坐标 Members(i).x ...
                    % 暂时只统计骨干路由延迟作为主要指标。
                end
            end
            
            % 2. 簇头多跳路由至 Sink (使用优化后的奖励函数)
            for j = 1:length(Cluster_Heads)
                if ~strcmp(Cluster_Heads(j).role, 'Dead')
                    curr_hop = Cluster_Heads(j).id;
                    accum_delay = 0;
                    hop_count = 0;
                    max_hops = 20; % 防止死循环
                    
                    while curr_hop ~= 0 && hop_count < max_hops
                        [Nodes, Q_Table_Routing, next_hop, hop_delay] = Route_To_Sink(curr_hop, Nodes, Sink, Q_Table_Routing, current_epsilon);
                        
                        if next_hop == -1
                            % 路由失败/丢包
                             break;
                        end
                        
                        accum_delay = accum_delay + hop_delay;
                        curr_hop = next_hop;
                        hop_count = hop_count + 1;
                        
                        if curr_hop == 0 % Arrived at Sink
                            round_total_delay = round_total_delay + accum_delay;
                            packets_delivered = packets_delivered + 1;
                        end
                    end
                end
            end
        end
    else
        fprintf('QL Round %d: 本轮 Q 表未选出簇头，跳过传输。\n', r);
    end
    
    % --- 阶段3：更新与统计 ---
    Q_Table_Cluster = Update_Q_Cluster(Nodes, Q_Table_Cluster);
    Nodes = Update_Idle_Energy(Nodes, T_round);
    
    alive_count = sum(~strcmp({Nodes.role}, 'Dead'));
    Alive_History(r) = alive_count;
    
    if packets_delivered > 0
        Total_Delay_History(r) = round_total_delay / packets_delivered;
    else
        Total_Delay_History(r) = 0;
    end
    
    fprintf('EC-QL Round %d (eps=%.3f): Alive=%d, AvgDelay=%.4fs\n', r, current_epsilon, alive_count, Total_Delay_History(r));
    
    if alive_count < (N * 0.5), break; end
end

% 保存数据
results.mode = 'QL';
results.alive_history = Alive_History(1:r);
results.delay_history = Total_Delay_History(1:r);
results.rounds = r;
save('Results/Data_QL.mat', 'results');
results.mode = 'QL'; % 标识为 EC-QL (Energy-efficient Clustered Q-Learning) 算法
results.alive_history = Alive_History(1:r);
results.rounds = r;
results.final_nodes = Nodes; 
save(['Results/Data_', results.mode, '.mat'], 'results');