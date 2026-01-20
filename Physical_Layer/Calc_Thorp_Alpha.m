function alpha = Calc_Thorp_Alpha(f)
% CALC_THORP_ALPHA 计算水声吸收系数 (Thorp公式)
% 输入: f - 信号频率 (单位: kHz) 
% 输出: alpha - 吸收系数 (单位: dB/km)
    f2 = f^2;
    % 根据 Thorp 经验公式进行计算 
    alpha = (0.11 * f2) / (1 + f2) + ...
            (44 * f2) / (4100 + f2) + ...
            2.75 * 10^-4 * f2 + 0.003;
end