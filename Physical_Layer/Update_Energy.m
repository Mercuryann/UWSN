function [Nodes, is_success] = Update_Energy(Nodes, sender_id, receiver_id, L)
    global E_elec R_rate P_amp P_rx
    is_success = true;
    if isempty(receiver_id) || isempty(sender_id)
            is_success = false;
            return;
        end
    % 1. 定位发送者索引
    s_idx = find([Nodes.id] == sender_id);
    
    % 2. 处理接收者（判断是否为 Sink）
    if receiver_id == 0
        % 如果接收方是 Sink，认为其永远存活且能量无限
        is_sink = true;
        r_dead = false;
    else
        is_sink = false;
        r_idx = find([Nodes.id] == receiver_id);
        % 如果找不到接收节点或接收节点已死亡
        if isempty(r_idx) || strcmp(Nodes(r_idx).role, 'Dead')
            r_dead = true;
        else
            r_dead = false;
        end
    end

    % 3. 存活检查
    if isempty(s_idx) || strcmp(Nodes(s_idx).role, 'Dead') || r_dead
        is_success = false;
        return;
    end

    % 4. 计算距离 d
    if is_sink
        % 获取全局 Sink 位置参数
        global Sink_Pos
        target_pos = Sink_Pos;
    else
        target_pos = [Nodes(r_idx).x, Nodes(r_idx).y, Nodes(r_idx).z];
    end
    
    d = sqrt((Nodes(s_idx).x - target_pos(1))^2 + ...
             (Nodes(s_idx).y - target_pos(2))^2 + ...
             (Nodes(s_idx).z - target_pos(3))^2);

    % 5. 计算能耗
    % 发送能耗: Etx = L * Eelec + Pamp * d^2 * (L / Rrate)
    E_tx = L * E_elec + (P_amp * d^2) * (L / R_rate);
    Nodes(s_idx).energy = Nodes(s_idx).energy - E_tx;

    % 6. 如果不是 Sink，扣除接收能耗
    if ~is_sink
        E_rx = L * E_elec;
        Nodes(r_idx).energy = Nodes(r_idx).energy - E_rx;
        
        if Nodes(r_idx).energy <= 0
            Nodes(r_idx).energy = 0;
            Nodes(r_idx).role = 'Dead';
        end
    end

    % 7. 发送方死亡检查
    if Nodes(s_idx).energy <= 0
        Nodes(s_idx).energy = 0;
        Nodes(s_idx).role = 'Dead';
    end
end