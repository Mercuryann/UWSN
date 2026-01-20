%% Standalone_MultiHop_Plot_Final.m - 终极可视化版（高亮中继点 + 自定义配色）
clear; clc; close all;

%% 1. 参数与拓扑设置
N = 350;                % 高密度以确保连通性
Area_Size = 800;        
Comm_Range = 320;       % 严格通信半径
Sink_Pos = [400, 400, 0]; 
Initial_Energy = 1.0;

% Q-Learning 参数
alpha_learning = 0.2;
gamma_discount = 0.9;
episodes = 3000;        % 深度训练

Nodes = struct('x', cell(1,N), 'y', cell(1,N), 'z', cell(1,N), 'energy', cell(1,N));
for i = 1:N
    Nodes(i).x = rand() * Area_Size;
    Nodes(i).y = rand() * Area_Size;
    Nodes(i).z = rand() * Area_Size;
    Nodes(i).energy = Initial_Energy * (0.6 + 0.8*rand()); 
end

%% 2. 深度 Q-Learning 训练
Q_Table = zeros(N, N + 1); 
fprintf('正在进行深度强化训练 (%d 轮)... \n', episodes);

for ep = 1:episodes
    curr_id = randi(N);
    for step = 1:18 
        candidates = [];
        dist_curr_sink = sqrt((Nodes(curr_id).x-Sink_Pos(1))^2 + (Nodes(curr_id).y-Sink_Pos(2))^2 + (Nodes(curr_id).z-Sink_Pos(3))^2);
        
        if dist_curr_sink <= Comm_Range, candidates = [0]; end
        for j = 1:N
            d_ij = sqrt((Nodes(curr_id).x-Nodes(j).x)^2 + (Nodes(curr_id).y-Nodes(j).y)^2 + (Nodes(curr_id).z-Nodes(j).z)^2);
            dist_j_sink = sqrt((Nodes(j).x-Sink_Pos(1))^2 + (Nodes(j).y-Sink_Pos(2))^2 + (Nodes(j).z-Sink_Pos(3))^2);
            if d_ij <= Comm_Range && dist_j_sink < dist_curr_sink
                candidates = [candidates, j];
            end
        end
        
        if isempty(candidates), break; end
        if rand() < 0.15, next_id = candidates(randi(length(candidates)));
        else, [~, idx] = max(Q_Table(curr_id, candidates + 1)); next_id = candidates(idx); end
        
        target_pos = Sink_Pos; if next_id ~= 0, target_pos = [Nodes(next_id).x, Nodes(next_id).y, Nodes(next_id).z]; end
        d_hop = sqrt((Nodes(curr_id).x-target_pos(1))^2 + (Nodes(curr_id).y-target_pos(2))^2 + (Nodes(curr_id).z-target_pos(3))^2);
        dist_next_sink = sqrt((target_pos(1)-Sink_Pos(1))^2 + (target_pos(2)-Sink_Pos(2))^2 + (target_pos(3)-Sink_Pos(3))^2);
        
        % 奖励函数
        reward = ((dist_curr_sink - dist_next_sink) / Area_Size) * 15 - 20 * (d_hop / Comm_Range)^4; 
        
        if next_id == 0
            Q_Table(curr_id, 1) = (1-alpha_learning)*Q_Table(curr_id, 1) + alpha_learning * (reward + gamma_discount * 100);
            break; 
        else
            future_q = max(Q_Table(next_id, :));
            Q_Table(curr_id, next_id + 1) = (1-alpha_learning)*Q_Table(curr_id, next_id + 1) + alpha_learning * (reward + gamma_discount * future_q);
            curr_id = next_id;
        end
    end
end

%% 3. 可视化绘图 (高亮中继点版)
figure('Color', 'w', 'Position', [50, 50, 1100, 850]);
hold on; grid on; view(3);

% --- 定义专业配色 ---
c_red_custom = [192, 80, 77] / 255;   % 你指定的自定义红色 (用于 Sink)
my_green = [155, 187, 89] / 255;      % 路径线颜色
relay_color = [255, 140, 0] / 255;    % 新增：中继节点颜色 (亮橙色)

% 绘制基础背景节点
plot3([Nodes.x], [Nodes.y], [Nodes.z], '.', 'Color', [0.85 0.85 0.85], 'MarkerSize', 5);

% --- 修改 1：使用自定义红色绘制 Sink ---
plot3(Sink_Pos(1), Sink_Pos(2), Sink_Pos(3), 'p', 'MarkerSize', 22, ...
      'MarkerEdgeColor', c_red_custom, 'MarkerFaceColor', c_red_custom);

% 选取源节点
[~, sort_idx] = sort([Nodes.z], 'descend');
source_nodes = sort_idx(round(linspace(1, N*0.4, 15))); 

Relay_Handles = []; % 用于存储中继点的句柄以便图例显示

for k = 1:length(source_nodes)
    curr_id = source_nodes(k);
    path_x = Nodes(curr_id).x; path_y = Nodes(curr_id).y; path_z = Nodes(curr_id).z;
    
    % 高亮起始点
    plot3(path_x, path_y, path_z, 'o', 'MarkerSize', 6, ...
          'MarkerEdgeColor', my_green, 'MarkerFaceColor', 'w');
    
    for h = 1:15
        [q_val, next_idx_raw] = max(Q_Table(curr_id, :));
        next_id = next_idx_raw - 1;
        
        % 鲁棒性保底逻辑
        if q_val <= 0 
            best_d = inf; best_n = -1;
            for n = 0:N
                if n == curr_id, continue; end
                if n == 0, pos_n = Sink_Pos; else, pos_n = [Nodes(n).x, Nodes(n).y, Nodes(n).z]; end
                d_check = sqrt((Nodes(curr_id).x-pos_n(1))^2 + (Nodes(curr_id).y-pos_n(2))^2 + (Nodes(curr_id).z-pos_n(3))^2);
                if d_check <= Comm_Range
                    dist_to_sink_n = sqrt((pos_n(1)-Sink_Pos(1))^2 + (pos_n(2)-Sink_Pos(2))^2 + (pos_n(3)-Sink_Pos(3))^2);
                    if dist_to_sink_n < best_d, best_d = dist_to_sink_n; best_n = n; end
                end
            end
            if best_n == -1, break; else, next_id = best_n; end
        end
        
        if next_id == 0, tx = Sink_Pos(1); ty = Sink_Pos(2); tz = Sink_Pos(3);
        else, tx = Nodes(next_id).x; ty = Nodes(next_id).y; tz = Nodes(next_id).z; end
        
        % --- 修改 2：高亮显示路径上的中继节点 ---
        if next_id ~= 0
            h_relay = plot3(tx, ty, tz, 'o', 'MarkerSize', 8, ...
                  'MarkerEdgeColor', relay_color, 'MarkerFaceColor', relay_color);
            if isempty(Relay_Handles), Relay_Handles = h_relay; end % 只收集一个句柄用于图例
        end
        
        % 绘制路径线
        line([path_x(end), tx], [path_y(end), ty], [path_z(end), tz], 'Color', my_green, 'LineWidth', 2.2);
        
        if next_id == 0, break; end
        curr_id = next_id;
        path_x(end+1) = tx; path_y(end+1) = ty; path_z(end+1) = tz;
    end
end

title(['UWSN Intelligence Multi-hop Routing with Relays Highlighted (Area: 800m)']);
xlabel('X (m)'); ylabel('Y (m)'); zlabel('Depth (m)');
% 更新图例以包含中继节点
legend([Relay_Handles], {'Relay Sensor Node'}, 'Location', 'northeastoutside');

% 自动保存
if ~exist('Results', 'dir'), mkdir('Results'); end
saveas(gcf, 'Results/Final_Highlighted_Routing.png');
fprintf('可视化完成！图像已保存至 Results/Final_Highlighted_Routing.png\n');