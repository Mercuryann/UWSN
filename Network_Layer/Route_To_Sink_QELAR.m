function [Nodes, Q_Table] = Route_To_Sink_QELAR(source_id, Nodes, Sink, Q_Table, epsilon)
    % Route_To_Sink_QELAR - QELAR 复现逻辑
    
    current_id = source_id;
    max_hops = 20; 
    hop_count = 0;
    global Packet_Length Comm_Range E_init
    
    while current_id ~= 0 && hop_count < max_hops
        hop_count = hop_count + 1;
        curr_idx = find([Nodes.id] == current_id);
        
        % 1. 发现邻居 (在通信范围内且存活)
        dists = arrayfun(@(n) sqrt((Nodes(curr_idx).x-n.x)^2 + (Nodes(curr_idx).y-n.y)^2 + (Nodes(curr_idx).z-n.z)^2), Nodes);
        neighbor_indices = find(dists > 0 & dists <= Comm_Range & ~strcmp({Nodes.role}, 'Dead'));
        
        if isempty(neighbor_indices)
            next_id = 0; % 尝试直连 Sink
        else
            % epsilon-greedy 策略
            if rand() < epsilon
                target_idx = neighbor_indices(randi(length(neighbor_indices)));
                next_id = Nodes(target_idx).id;
            else
                % Q 表寻优：注意 Q_Table 索引偏移 (+1 处理 Sink ID=0)
                q_vals = Q_Table(current_id, [Nodes(neighbor_indices).id] + 1);
                [~, max_idx] = max(q_vals);
                next_id = Nodes(neighbor_indices(max_idx)).id;
            end
        end
        
        % 2. QELAR 奖励函数：仅基于能量分布
        if next_id == 0
            reward = 1.0; 
        else
            next_idx = find([Nodes.id] == next_id);
            reward = Nodes(next_idx).energy / E_init; % 纯能量奖励
        end
        
        % 3. 物理层执行：更新能量消耗
        [Nodes, success] = Update_Energy(Nodes, current_id, next_id, Packet_Length);
        
        if success
            % Q-Learning 更新公式
            lr = 0.1; df = 0.9;
            old_q = Q_Table(current_id, next_id + 1);
            max_future_q = max(Q_Table(max(1, next_id), :));
            Q_Table(current_id, next_id + 1) = old_q + lr * (reward + df * max_future_q - old_q);
            current_id = next_id;
        else
            break; 
        end
    end
end