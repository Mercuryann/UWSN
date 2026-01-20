function fnd = Evaluate_Protocol_Performance(mode, packet_load)
    % Evaluate_Protocol_Performance - 评估不同协议在指定负载下的网络寿命 (FND)
    % 输入: 
    %   mode: 协议名称 ('LEACH', 'QELAR', 'QL')
    %   packet_load: 每节点每轮产生的数据包数量
    % 输出:
    %   fnd: 网络首节点死亡轮数 (First Node Dead)

    % 1. 环境初始化
    Config_Params; 
    global Packets_Per_Node;
    Packets_Per_Node = packet_load; % 动态注入当前测试负载

    % 2. 网络初始化
    [Nodes, Sink] = Initialize_Network(N, Area_Size, Initial_Energy, Sink_Pos);
    
    % 初始化算法特有的状态变量
    Q_Table_Cluster = zeros(18, 2); 
    Q_Table_Routing = zeros(N, N + 1); 
    fnd = Max_Rounds; 
    first_dead_found = false;

    % 3. 仿真主循环
    for r = 1:Max_Rounds
        % 动态 epsilon 衰减 (确保 Q 学习的收敛性)
        current_epsilon = max(0.05, epsilon * (0.98^r));

        % --- 分算法执行传输逻辑 ---
        if strcmp(mode, 'LEACH')
            % 传统 LEACH 逻辑
            [CHs, Mems] = Run_LEACH_Election(Nodes, r);
            if ~isempty(CHs)
                for p = 1:Packets_Per_Node
                    for i = 1:length(Mems)
                        if ~isempty(Mems(i).CH_id)
                            [Nodes, ~] = Update_Energy(Nodes, Mems(i).id, Mems(i).CH_id, Packet_Length);
                        end
                    end
                    for j = 1:length(CHs)
                        [Nodes, ~] = Update_Energy(Nodes, CHs(j).id, 0, Packet_Length);
                    end
                end
            end

        elseif strcmp(mode, 'QELAR')
            % 基础 Q-Learning 路由 (无分簇)
            for p = 1:Packets_Per_Node
                for i = 1:N
                    if ~strcmp(Nodes(i).role, 'Dead')
                        [Nodes, Q_Table_Routing] = Route_To_Sink_QELAR(Nodes(i).id, Nodes, Sink, Q_Table_Routing, current_epsilon);
                    end
                end
            end

        elseif strcmp(mode, 'QL')
            % 本文优化的分簇强化学习算法
            [CHs, Mems] = Run_Cluster_Election(Nodes, Q_Table_Cluster, current_epsilon);
            if ~isempty(CHs)
                for p = 1:Packets_Per_Node
                    for i = 1:length(Mems)
                        if ~isempty(Mems(i).CH_id)
                            [Nodes, ~] = Update_Energy(Nodes, Mems(i).id, Mems(i).CH_id, Packet_Length);
                        end
                    end
                    for j = 1:length(CHs)
                        [Nodes, Q_Table_Routing] = Route_To_Sink(CHs(j).id, Nodes, Sink, Q_Table_Routing, current_epsilon);
                    end
                end
            end
        end

        % 4. 统计与 FND 监测 (优化运行效率)
        Nodes = Update_Idle_Energy(Nodes, T_round);
        alive_count = sum(~strcmp({Nodes.role}, 'Dead'));
        
        if ~first_dead_found && alive_count < N
            fnd = r;
            first_dead_found = true;
            break; % 仅需获取 FND，检测到后立即停止当前仿真
        end
        
        if alive_count < (N * 0.5), break; end
    end
end