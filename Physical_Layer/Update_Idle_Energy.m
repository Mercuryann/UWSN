function Nodes = Update_Idle_Energy(Nodes, T_round)
    % 输入: Nodes-节点结构体, T_round-一轮仿真的时长(s)
    
    global P_idle
    
    for i = 1:length(Nodes)
        if ~strcmp(Nodes(i).role, 'Dead')
            % 扣除空闲功耗: E_idle = P_idle * T
            Nodes(i).energy = Nodes(i).energy - P_idle * T_round;
            
            % 检查是否因此死亡
            if Nodes(i).energy <= 0
                Nodes(i).energy = 0;
                Nodes(i).role = 'Dead';
            end
        end
    end
end