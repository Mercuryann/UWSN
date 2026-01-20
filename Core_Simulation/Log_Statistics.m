function Log_Statistics(r, Nodes)
    % 统计存活节点、总能量等数据
    stats.round = r;
    stats.alive = sum(~strcmp({Nodes.role}, 'Dead'));
    stats.total_energy = sum([Nodes.energy]);
    
    % 将数据追加保存到 Results 文件夹下的 .mat 文件中
    if r == 1
        history = stats;
    else
        load('Results/Simulation_History.mat', 'history');
        history(r) = stats;
    end
    save('Results/Simulation_History.mat', 'history');
end