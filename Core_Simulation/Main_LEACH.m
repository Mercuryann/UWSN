% Main_LEACH.m - 传统 LEACH 协议独立仿真脚本
clear; clc; close all;

% 1. 环境准备
addpath(genpath(pwd)); 
Config_Params; 

% 2. 网络初始化
% 确保 Initial_Energy 和异构性与 QL 保持一致
% 2. 网络初始化
% 确保 Initial_Energy 和异构性与 QL 保持一致
[Nodes, Sink] = Initialize_Network(N, Area_Size, Initial_Energy, Sink_Pos);
Plot_Network_Topology(Nodes, Sink);
Alive_History = zeros(Max_Rounds, 1);
Total_Delay_History = zeros(Max_Rounds, 1);

% 3. 仿真主循环
for r = 1:Max_Rounds
    % --- 阶段1：分簇选举 ---
    % 调用任务七中编写的随机阈值选举函数
    [Cluster_Heads, Members] = Run_LEACH_Election(Nodes, r);
    
    % --- 阶段2：高负载数据传输 ---
    round_total_delay = 0;
    packets_delivered = 0;
    v_sound = 1500;

    for p = 1:Packets_Per_Node
        % 1. 成员向簇头发送数据
        for i = 1:length(Members)
            if ~strcmp(Members(i).role, 'Dead')
                [Nodes, ~] = Update_Energy(Nodes, Members(i).id, Members(i).CH_id, Packet_Length);
            end
        end
        
        % 2. 簇头向 Sink 发送数据 (LEACH 标准逻辑：单跳直连)
        for j = 1:length(Cluster_Heads)
            if ~strcmp(Cluster_Heads(j).role, 'Dead')
                % 簇头直接与 Sink (ID为0) 通信，不经过多跳路由
                [Nodes, ~] = Update_Energy(Nodes, Cluster_Heads(j).id, 0, Packet_Length);
                
                % 计算单跳直连延迟
                ch_idx = find([Nodes.id] == Cluster_Heads(j).id);
                d_sink = sqrt((Nodes(ch_idx).x - Sink.x)^2 + (Nodes(ch_idx).y - Sink.y)^2 + (Nodes(ch_idx).z - Sink.z)^2);
                delay = d_sink / v_sound;
                
                round_total_delay = round_total_delay + delay;
                packets_delivered = packets_delivered + 1;
            end
        end
    end
    
    % --- 阶段3：能量统计 ---
    % 扣除每轮固定空闲功耗
    Nodes = Update_Idle_Energy(Nodes, T_round);
    
    alive_count = sum(~strcmp({Nodes.role}, 'Dead'));
    Alive_History(r) = alive_count;
    
    if packets_delivered > 0
        Total_Delay_History(r) = round_total_delay / packets_delivered;
    else
        Total_Delay_History(r) = 0;
    end
    
    fprintf('LEACH Round %d: Alive=%d, AvgDelay=%.4fs\n', r, alive_count, Total_Delay_History(r));
    
    % 终止条件 (50% 节点死亡)
    if alive_count < (N * 0.5), break; end
end

% 4. 数据保存
results.mode = 'LEACH';
results.alive_history = Alive_History(1:r);
results.delay_history = Total_Delay_History(1:r);
results.rounds = r;
save('Results/Data_LEACH.mat', 'results');
results.mode = 'LEACH'; % 标识为 LEACH 算法
results.alive_history = Alive_History(1:r);
results.rounds = r;
results.final_nodes = Nodes; 
save(['Results/Data_', results.mode, '.mat'], 'results');