function R_total = Calculate_Routing_Reward(Nodes, curr_id, next_id, Sink)
    % 载入全局参数
    global alpha_val beta_val gamma_val E_init SNR_ref
    global E_elec P_amp R_rate Packet_Length Comm_Range
    
    % 1. 剩余能量奖励 (R_E) - 保持原有高阶倾向
    E_ratio = Nodes(next_id).energy / E_init;
    R_E = E_ratio^4; 
    
    % 2. 进度奖励 (R_D) - 指向 Sink 的倾向性
    dist_curr_sink = sqrt((Nodes(curr_id).x-Sink.x)^2 + (Nodes(curr_id).y-Sink.y)^2 + (Nodes(curr_id).z-Sink.z)^2);
    
    if next_id == 0 % 如果下一跳是 Sink
        dist_next_sink = 0;
        d_link = dist_curr_sink;
    else
        dist_next_sink = sqrt((Nodes(next_id).x-Sink.x)^2 + (Nodes(next_id).y-Sink.y)^2 + (Nodes(next_id).z-Sink.z)^2);
        d_link = sqrt((Nodes(curr_id).x-Nodes(next_id).x)^2 + (Nodes(curr_id).y-Nodes(next_id).y)^2 + (Nodes(curr_id).z-Nodes(next_id).z)^2);
    end
    
    R_D = (dist_curr_sink - dist_next_sink) / dist_curr_sink;
    
    % 如果进度为负（往回走），给予重罚
    if R_D <= 0, R_total = -100; return; end

    % 3. 核心修改：非线性距离惩罚 (R_cost)
    % 计算本次传输真实能耗
    E_tx_cost = Packet_Length * E_elec + (P_amp * d_link^2) * (Packet_Length / R_rate);
    
    % 引入距离归一化惩罚系数
    % 当 d_link 接近 Comm_Range 时，该项会因为 4 次方而迅速增大
    norm_dist = d_link / Comm_Range;
    if norm_dist > 1.0
        R_cost = -1000; % 物理不可达，给予毁灭性惩罚
    else
        % 使用 -20 倍的 4 次方惩罚，使长距离跳跃的代价远超短距离
        R_cost = -20 * (norm_dist^4) - 10 * (E_tx_cost / E_init);
    end

    % 4. 链路质量奖励 (R_L) - 保持原有逻辑
    TL = Channel_Urick(d_link, 25);
    SNR_link = 150 - TL - 50; 
    R_L = SNR_link / SNR_ref;
    
    % 5. 动态权重调整
    % 当剩余能量减少时，极大化 alpha 以保护能量
    dynamic_alpha = min(0.95, alpha_val + (0.6 * (1 - E_ratio)));
    dynamic_beta = max(0.05, 1 - dynamic_alpha - gamma_val);
    
    % 6. 总奖励合成
    % 调高 R_D 的基础收益，但会被 R_cost 在长距离下对冲
    R_total = dynamic_alpha * R_E + (5 * dynamic_beta * R_D) + gamma_val * R_L + R_cost;
end