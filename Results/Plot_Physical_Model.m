function Plot_Physical_Model()
% PLOT_PHYSICAL_MODEL 生成并保存水声信道物理特性的分析图表

    % 1. 设置分析范围
    f_range = 1:0.1:100;   % 1kHz 到 100kHz
    d_range = 10:10:1000;  % 10m 到 1000m

    % 2. 创建画布
    fig = figure('Name', 'Physical Layer Analysis', 'Color', 'w');
    
    % 3. 绘制频率 vs 吸收系数 (Thorp)
    subplot(2,1,1);
    alphas = arrayfun(@Calc_Thorp_Alpha, f_range);
    plot(f_range, alphas, 'r-', 'LineWidth', 2);
    grid on;
    xlabel('Frequency (kHz)'); 
    ylabel('Absorption Coeff \alpha (dB/km)');
    title('Frequency vs. Thorp Absorption Coefficient');

    % 4. 绘制距离 vs 传输损耗 (不同频率对比)
    subplot(2,1,2);
    frequencies = [10, 20, 50]; 
    hold on;
    for f = frequencies
        tls = arrayfun(@(d) Channel_Urick(d, f), d_range);
        plot(d_range, tls, 'LineWidth', 1.5, 'DisplayName', [num2str(f), ' kHz']);
    end
    grid on; 
    legend('Location', 'northeast');
    xlabel('Distance (m)'); 
    ylabel('Transmission Loss TL (dB)');
    title('Distance vs. Transmission Loss (Urick Model)');

    % 5. 自动保存结果到 Results 文件夹
    if ~exist('Results', 'dir'), mkdir('Results'); end
    saveas(fig, 'Results/Channel_Model_Curves.png');
    
    fprintf('物理层特性分析图已生成并保存至 \\Results。\n');
end