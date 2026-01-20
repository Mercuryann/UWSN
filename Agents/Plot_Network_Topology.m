function Plot_Network_Topology(Nodes, Sink)
    % Plot_Network_Topology - 专门用于网络拓扑的可视化与保存
    
    % 1. 获取 Results 文件夹路径
    [func_path, ~, ~] = fileparts(mfilename('fullpath'));
    root_path = fullfile(func_path, '..'); 
    results_dir = fullfile(root_path, 'Results');
    if ~exist(results_dir, 'dir'), mkdir(results_dir); end

    % 2. 绘制三维拓扑
    figure('Name', 'Initial Topology', 'Color', 'w', 'Position', [200, 200, 700, 600]);
    
    % 绘制普通传感器节点 (蓝色)
    plot3([Nodes.x], [Nodes.y], [Nodes.z], 'bo', 'MarkerFaceColor', [0.3, 0.6, 1], 'MarkerSize', 5);
    hold on;
    % 绘制 Sink 节点 (红色五角星)
    plot3(Sink.x, Sink.y, Sink.z, 'rp', 'MarkerSize', 15, 'MarkerFaceColor', 'r');
    
    title('UWSN 三维网络初始拓扑分布', 'FontSize', 12);
    xlabel('X (m)'); ylabel('Y (m)'); zlabel('Depth (m)');
    grid on; view(3); 
    
    % 3. 保存图片
    save_path = fullfile(results_dir, 'Initial_Topology.png');
    saveas(gcf, save_path);
    fprintf('拓扑图已生成并保存至: %s\n', save_path);
end