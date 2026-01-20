function [CHs, Members] = Run_Cluster_Election(Nodes, Q_Table_Cluster, epsilon)
    % Run_Cluster_Election - Q-Learning 分簇选举函数
    
    CHs = [];
    Members = [];
    is_ch = false(1, length(Nodes)); 
    
    % 1. 智能体决策：节点根据 Q 表决定自己是 CH 还是 Member
    for i = 1:length(Nodes)
        if strcmp(Nodes(i).role, 'Dead'), continue; end
        
        % 获取当前节点的能量状态索引 (假设已根据能量百分比离散化)
        state = ceil((Nodes(i).energy / 1.5) * 17) + 1; % 1.5J 是最大可能能量
        state = max(1, min(18, state));
        
        % epsilon-greedy 策略
        if rand() < epsilon
            action = randi([1, 2]); % 1: CH, 2: Member
        else
            [~, action] = max(Q_Table_Cluster(state, :));
        end
        
        if action == 1
            Nodes(i).role = 'CH';
            is_ch(i) = true;
        else
            Nodes(i).role = 'Member';
            Nodes(i).CH_id = []; % 预设字段
        end
    end
    
    % 提取初步集合
    CHs = Nodes(is_ch);
    temp_members = Nodes(~is_ch & ~strcmp({Nodes.role}, 'Dead'));
    
    % 2. 关联逻辑：成员节点寻找最近的簇头
    if ~isempty(CHs)
        for i = 1:length(temp_members)
            dists = arrayfun(@(ch) sqrt((temp_members(i).x-ch.x)^2 + ...
                                        (temp_members(i).y-ch.y)^2 + ...
                                        (temp_members(i).z-ch.z)^2), CHs);
            [~, min_idx] = min(dists);
            temp_members(i).CH_id = CHs(min_idx).id;
        end
        Members = temp_members;
    else
        % 特殊处理：如果没有节点愿意当 CH，则所有存活节点设为 Member，且 CH_id 为空
        Members = temp_members;
        if ~isempty(Members)
            [Members.CH_id] = deal([]); 
        end
    end
end