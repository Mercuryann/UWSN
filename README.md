# 水下无线传感器网络 (UWSN) 节能路由协议仿真平台

本项目旨在仿真和评估水下无线传感器网络（UWSN）中的不同路由协议性能，重点实现了本文提出的节能分簇强化学习协议 (EC-QL)，并将其与经典的 LEACH 协议及 QELAR 协议进行了全面对比。

---

## 1. 项目代码架构 (Code Architecture)

项目采用模块化设计，主要包含以下核心目录：

### 1.1 `Core_Simulation/` (核心仿真层)
包含系统的主入口脚本和顶层调度逻辑。
*   **`Config_Params.m`**: 全局参数配置文件（如节点数量、区域大小、能量模型参数等）。
*   **`Main_QL.m`**: **EC-QL (本文算法)** 的主仿真程序。包含分簇选举和 Q-Learning 路由的主循环。
*   **`Main_LEACH.m`**: LEACH 协议的主仿真程序（基准对比）。
*   **`Main_QELAR.m`**: QELAR 协议的主仿真程序（基准对比）。
*   **`Generate_Robustness_*.m`**: 用于生成鲁棒性分析数据的专用脚本（针对不同负载、区域大小、能量异构度进行批量测试）。
*   **`Evaluate_Protocol_Performance.m`**: 协议性能评估的通用封装函数。

### 1.2 `Network_Layer/` (网络层算法)
实现了具体的路由算法逻辑、状态更新和奖励计算。
*   **`Run_Cluster_Election.m`**: EC-QL 的分簇选举逻辑（基于 Q-Learning 状态）。
*   **`Route_To_Sink.m`**: EC-QL 的骨干路由逻辑（簇头至 Sink 的多跳路径规划）。
*   **`Calculate_Routing_Reward.m`**: 计算强化学习奖励函数的核心代码（考虑能耗、距离、剩余能量等）。
*   **`Run_LEACH_Election.m`**: LEACH 协议的轮换簇头选举逻辑。
*   **`Route_To_Sink_QELAR.m`**: QELAR 协议的 Q-value 更新与路由选择逻辑。
*   **`Initialize_Network.m`**: 网络节点初始化（位置、能量分布）。

### 1.3 `Agents/` (绘图与可视化代理)
专门用于读取仿真数据并生成高质量学术图表。
*   **`Plot_Comparison.m`**: 绘制核心性能指标对比图（存活节点数、网络剩余能量）。
*   **`Plot_Delay_Analysis.m`**: 绘制端到端延迟分析对比图。
*   **`Plot_Energy_Analysis.m`**: 绘制能耗分布与均衡性分析图。
*   **`Plot_Robustness_Analysis.m`**: 绘制鲁棒性分析系列图表（负载、规模、异构度影响）。
*   **`Plot_Routing_Paths.m`**: **3D 路由可视化**，高亮显示 EC-QL 的多跳路径和中继节点。

### 1.4 `Results/` (结果输出)
存放所有仿真生成的 `.mat` 数据文件和最终的 `.png` 图像文件。

---

##  2. 仿真结果图表说明

运行 `Agents/` 目录下的绘图脚本后，将生成以下关键结果图：

### 2.1 核心性能对比
*   **`Analysis_Alive_Nodes.png`**: 展示网络存活节点数量随轮数的变化。EC-QL 应显示出比 LEACH 和 QELAR 更晚出现首个死亡节点（FND），证明其延长了网络寿命。
*   **`Analysis_Total_Energy.png`**: 展示网络总剩余能量随时间的消耗曲线，反映算法的整体能效。

### 2.2 延迟分析
*   **`Final_Delay_Comparison.png`**: 对比三种协议的端到端传输延迟。
    *   **高延迟组**: QELAR 通常延迟较高（因其寻找路径机制）。
    *   **低延迟组**: EC-QL 与 LEACH 对比，验证 EC-QL 在保证节能的同时是否维持了可接受的低延迟。

### 2.3 鲁棒性分析 (Robustness)
*   **`Task9_Robustness_Final_Plot.png`** (业务负载): 展示当数据包负载增加时，网络寿命（FND）的变化趋势。验证算法在高负载下的稳定性。
*   **`Analysis_Robustness_Area.png`** (网络规模): 展示网络区域从 300m 扩展到 800m 时，算法性能的衰减情况。EC-QL 应在大规模网络中保持优势。
*   **`Analysis_Robustness_Energy.png`** (能量异构): 展示在初始能量分布不均匀（异构因子增加）的情况下，算法的适应能力。

### 2.4 路由可视化
*   **`Final_Highlighted_Routing.png`**: 3D 空间中的路由路径快照。
    *   **绿色线条**: 数据传输路径。
    *   **橙色节点**: 被选中的 **中继节点 (Relays)**。
    *   **红色五角星**: Sink 节点（水面汇聚站）。
    *   此图直观展示了 EC-QL 如何智能选择中继点进行多跳传输。

---

## 3. 使用说明 (Usage)

### 第一步：运行仿真生成数据
在 MATLAB 中依次运行以下脚本（约需几分钟）：
```matlab
% 1. 运行核心仿真 (生成 Data_*.mat)
Core_Simulation/Main_LEACH
Core_Simulation/Main_QELAR
Core_Simulation/Main_QL          % 对应 EC-QL 算法

% 2. 运行鲁棒性批量测试 (生成 Robustness_*.mat)
Core_Simulation/Generate_Robustness_Data    % 负载测试
Core_Simulation/Generate_Robustness_Area    % 规模测试
Core_Simulation/Generate_Robustness_Energy  % 异构测试
```

### 第二步：生成结果图表
在仿真完成后，运行绘图脚本（位于 `Agents/` 目录下）：
```matlab
% 生成核心对比图
Agents/Plot_Comparison
Agents/Plot_Energy_Analysis
Agents/Plot_Delay_Analysis

% 生成鲁棒性分析图
Agents/Plot_Robustness_Analysis

% 生成 3D 路由可视化图
Agents/Plot_Routing_Paths
```

所有生成的图像将自动保存在项目根目录的 **`Results/`** 文件夹中。
