% extract_metrics_2.m — 提取鲁棒性实验数据（只读，不修改项目文件）
% 在 MATLAB 中将工作目录切换到项目根目录后运行

fprintf('\n===== 负载鲁棒性（Robustness_Data_Summary.mat）=====\n');
d1 = load('Results/Robustness_Data_Summary.mat');
f1 = fieldnames(d1);
disp('Fields:'); disp(f1);
for i = 1:numel(f1)
    val = d1.(f1{i});
    if isnumeric(val)
        fprintf('  %s: ', f1{i}); disp(val);
    elseif isstruct(val)
        sf = fieldnames(val);
        for j = 1:numel(sf)
            v2 = val.(sf{j});
            if isnumeric(v2)
                fprintf('  %s.%s: ', f1{i}, sf{j}); disp(v2);
            end
        end
    end
end

fprintf('\n===== 规模鲁棒性（Robustness_Area_Summary.mat）=====\n');
d2 = load('Results/Robustness_Area_Summary.mat');
f2 = fieldnames(d2);
disp('Fields:'); disp(f2);
for i = 1:numel(f2)
    val = d2.(f2{i});
    if isnumeric(val)
        fprintf('  %s: ', f2{i}); disp(val);
    elseif isstruct(val)
        sf = fieldnames(val);
        for j = 1:numel(sf)
            v2 = val.(sf{j});
            if isnumeric(v2)
                fprintf('  %s.%s: ', f2{i}, sf{j}); disp(v2);
            end
        end
    end
end

fprintf('\n===== 能量异构鲁棒性（Robustness_Energy_Summary.mat）=====\n');
d3 = load('Results/Robustness_Energy_Summary.mat');
f3 = fieldnames(d3);
disp('Fields:'); disp(f3);
for i = 1:numel(f3)
    val = d3.(f3{i});
    if isnumeric(val)
        fprintf('  %s: ', f3{i}); disp(val);
    elseif isstruct(val)
        sf = fieldnames(val);
        for j = 1:numel(sf)
            v2 = val.(sf{j});
            if isnumeric(v2)
                fprintf('  %s.%s: ', f3{i}, sf{j}); disp(v2);
            end
        end
    end
end
