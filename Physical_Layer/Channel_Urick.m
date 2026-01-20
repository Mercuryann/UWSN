function TL = Channel_Urick(d, f)
% CHANNEL_URICK 计算水声传输损耗 
% 输入: d - 传输距离 (单位: m) 
%       f - 信号频率 (单位: kHz)

    % 1. 获取吸收系数 (dB/km)
    alpha = Calc_Thorp_Alpha(f); 
    
    % 2. 设置扩散系数 k
    % 手册建议设为 1.5 以模拟实际复杂环境 
    k = 1.5; 
    
    % 3. 额外损失项 A (根据手册公式 
    A = 0; 
    
    % 4. 计算 TL (dB) 
    % 注意: alpha 的单位是 dB/km，而 d 的单位是 m，故乘以 10^-3 进行单位统一 
    TL = k * 10 * log10(d) + alpha * d * 10^-3 + A;
end