function [CHs, Members] = Run_LEACH_Election(Nodes, r)
    global P_leach
    
    % 初始化输出
    CHs = [];
    Members = [];
    
    % 1. 阈值计算 T(n)
    cycle = round(1/P_leach);
    T_n = P_leach / (1 - P_leach * mod(r-1, cycle));
    
    % 2. 选举簇头
    is_ch = false(1, length(Nodes)); % 标记位
    for i = 1:length(Nodes)
        if strcmp(Nodes(i).role, 'Dead'), continue; end
        
        if rand() < T_n
            Nodes(i).role = 'CH';
            is_ch(i) = true;
        else
            Nodes(i).role = 'Member';
            Nodes(i).CH_id = []; % 预设字段，防止字段不存在
        end
    end
    
    % 提取簇头和成员
    CHs = Nodes(is_ch);
    temp_members = Nodes(~is_ch & ~strcmp({Nodes.role}, 'Dead'));
    
    % 3. 关联逻辑
    if ~isempty(CHs)
        for i = 1:length(temp_members)
            % 寻找最近的簇头
            dists = arrayfun(@(ch) sqrt((temp_members(i).x-ch.x)^2 + ...
                                        (temp_members(i).y-ch.y)^2 + ...
                                        (temp_members(i).z-ch.z)^2), CHs);
            [~, min_idx] = min(dists);
            
            % 直接给成员赋值其所属簇头ID
            temp_members(i).CH_id = CHs(min_idx).id;
        end
        Members = temp_members;
    else
        % 如果没有簇头，所有存活节点都是成员，且无 CH_id
        Members = temp_members;
        if ~isempty(Members)
            [Members.CH_id] = deal([]); 
        end
    end
end