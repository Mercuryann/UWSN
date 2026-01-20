function action = Select_Role_QL(q_table, state_idx, epsilon)
    % 动作空间: 1-竞选簇头, 2-成为成员
    if rand() < epsilon
        action = randi([1, 2]); % 探索
    else
        [~, action] = max(q_table(state_idx, :)); % 利用
    end
end