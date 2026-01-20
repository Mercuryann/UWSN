function Q_Table_Cluster = Update_Q_Cluster(Nodes, Q_Table_Cluster)
    global learning_rate gamma_discount Initial_Energy Area_Size
    
    % 遍历所有存活节点进行学习
    for i = 1:length(Nodes)
        if strcmp(Nodes(i).role, 'Dead'), continue; end
        
        % 获取当前状态（用于计算奖励 R）
        dist_to_sink = sqrt((Nodes(i).x - 250)^2 + (Nodes(i).y - 250)^2 + (Nodes(i).z - 500)^2);
        % 简化的密度计算
        density = length(Nodes(i).neighbors);
        
        % 获取状态索引
        s_idx = Map_State_Cluster(Nodes(i).energy, dist_to_sink, density, Initial_Energy, Area_Size, 20);
        
        % 根据角色判定动作：1-CH, 2-Member
        if strcmp(Nodes(i).role, 'CH'), action = 1; else, action = 2; end
        
        % 计算分簇奖励 R_cluster [cite: 72]
        % 奖励高能量、高密度且靠近中心位置的节点成为簇头
        R = 0.5 * (Nodes(i).energy / Initial_Energy) + 0.3 * (density / 10) - 0.2 * (dist_to_sink / Area_Size);
        
        % 能量保护机制：若能量极低且竞选簇头，给予重罚 [cite: 73]
        if Nodes(i).energy < (0.2 * Initial_Energy) && action == 1
            R = -100;
        end
        
        % 标准 Q-learning 更新公式 [cite: 109]
        max_future_q = max(Q_Table_Cluster(s_idx, :));
        Q_Table_Cluster(s_idx, action) = (1 - learning_rate) * Q_Table_Cluster(s_idx, action) + ...
                                         learning_rate * (R + gamma_discount * max_future_q);
    end
end