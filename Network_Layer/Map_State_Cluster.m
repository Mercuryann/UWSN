function state_idx = Map_State_Cluster(energy, dist_to_sink, density, init_energy, max_dist, max_density)
    % 1. 能量等级 (3级): 高(>50%), 中(20%-50%), 低(<20%)
    e_ratio = energy / init_energy;
    if e_ratio > 0.5
        e_lvl = 1;
    elseif e_ratio > 0.2
        e_lvl = 2;
    else
        e_lvl = 3;
    end

    % 2. 距离等级 (3级): 近, 中, 远 (相对于Sink)
    d_ratio = dist_to_sink / max_dist;
    if d_ratio < 0.3
        d_lvl = 1;
    elseif d_ratio < 0.7
        d_lvl = 2;
    else
        d_lvl = 3;
    end

    % 3. 密度等级 (2级): 稀疏, 稠密 (基于通信半径内的邻居数)
    if density > (max_density / 2)
        dens_lvl = 1;
    else
        dens_lvl = 2;
    end

    % 计算线性索引 (1-18)
    state_idx = (e_lvl - 1) * 6 + (d_lvl - 1) * 2 + dens_lvl;
end