function [Nodes, Q_Table_Routing] = Route_To_Sink(curr_node_id, Nodes, Sink, Q_Table_Routing, epsilon)
    global Packet_Length learning_rate gamma_discount
    global Comm_Range % 确保全局变量已载入

    curr_idx = find([Nodes.id] == curr_node_id);
    candidates = [];
    dist_to_sink_curr = sqrt((Nodes(curr_idx).x - Sink.x)^2 + (Nodes(curr_idx).y - Sink.y)^2 + (Nodes(curr_idx).z - Sink.z)^2);

    % 1. 筛选候选者：必须在 Comm_Range 内且更接近 Sink
    for i = 1:length(Nodes)
        if strcmp(Nodes(i).role, 'CH') && Nodes(i).id ~= curr_node_id
            dist_ij = sqrt((Nodes(curr_idx).x - Nodes(i).x)^2 + ...
                           (Nodes(curr_idx).y - Nodes(i).y)^2 + ...
                           (Nodes(curr_idx).z - Nodes(i).z)^2);
            dist_to_sink_next = sqrt((Nodes(i).x - Sink.x)^2 + (Nodes(i).y - Sink.y)^2 + (Nodes(i).z - Sink.z)^2);
            
            if dist_ij <= Comm_Range && dist_to_sink_next < dist_to_sink_curr
                candidates = [candidates, Nodes(i).id];
            end
        end
    end

   
    if isempty(candidates)
       
        if dist_to_sink_curr <= Comm_Range
            [Nodes, success] = Update_Energy(Nodes, curr_node_id, Sink.id, Packet_Length);
            
            return;
        else
    
            return; 
        end
    end

    % 3. Epsilon-greedy 选择下一跳 
    if rand() < epsilon
        next_hop_id = candidates(randi(length(candidates)));
    else
        [~, max_idx] = max(Q_Table_Routing(curr_node_id, candidates));
        next_hop_id = candidates(max_idx);
    end

    % 4. 传输并更新 Q 表
    [Nodes, success] = Update_Energy(Nodes, curr_node_id, next_hop_id, Packet_Length);
    if success
        
        reward = Calculate_Routing_Reward(Nodes, curr_node_id, next_hop_id, Sink);
        max_future_q = max(Q_Table_Routing(next_hop_id, :));
        Q_Table_Routing(curr_node_id, next_hop_id) = (1 - learning_rate) * Q_Table_Routing(curr_node_id, next_hop_id) + ...
            learning_rate * (reward + gamma_discount * max_future_q);
    else
        Q_Table_Routing(curr_node_id, next_hop_id) = -100;
    end
end