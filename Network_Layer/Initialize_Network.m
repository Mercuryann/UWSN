function [Nodes, Sink] = Initialize_Network(N, Area_Size, Initial_Energy, Sink_Pos)
    % Initialize_Network
    global Hetero_Factor; % 默认可设为 0.5
    if isempty(Hetero_Factor), Hetero_Factor = 0.5; end

    Nodes = struct('id', {}, 'x', {}, 'y', {}, 'z', {}, ...
                   'energy', {}, 'role', {}, 'neighbors', {}, 'q_table_cluster', {});

    for i = 1:N
        Nodes(i).id = i;
        Nodes(i).x = rand() * Area_Size;
        Nodes(i).y = rand() * Area_Size;
        Nodes(i).z = rand() * Area_Size;
        
        % 动态异构公式: 当 Factor=0.1 为近乎均匀; Factor=0.9 为极度不均
        % 默认 Factor=0.5 时对应方案 A 的 U(0.5, 1.5)
        low_bound = 1.0 - Hetero_Factor;
        range = 2.0 * Hetero_Factor;
        Nodes(i).energy = Initial_Energy * (low_bound + range * rand());
        
        Nodes(i).role = 'Member';
        Nodes(i).neighbors = [];
        Nodes(i).q_table_cluster = zeros(18, 2); 
    end

    Sink.id = 0;
    Sink.x = Sink_Pos(1); Sink.y = Sink_Pos(2); Sink.z = Sink_Pos(3);
    Sink.energy = inf;
end