function R_total = Calculate_QELAR_Reward(Nodes, next_id)
    global E_init
    % QELAR 核心逻辑：奖励仅与目标节点的剩余能量比例相关
    E_res_next = Nodes(next_id).energy;
    R_total = E_res_next / E_init; % 基于能量分布的简单奖励
end