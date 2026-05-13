# 毕业设计 Demo Cheatsheet — EC-QL 水下传感器网络

> **前置准备**：打开 MATLAB，`cd` 到项目根目录 `UWSN/`，运行 `addpath(genpath(pwd))`

---

## 一、水声信道物理模型（论文第 2 章）

### 1.1 【原理】Thorp 吸收系数 — 公式 (2-2)

- **代码位置**：`Physical_Layer/Calc_Thorp_Alpha.m`（全文仅 10 行）
- **话术**：
> "这是 Thorp 经验公式的直接实现。公式由四项物理机制叠加：硼酸弛豫吸收、硫酸镁弛豫吸收、纯水粘滞吸收和低频残余项。代码第 7-9 行完全对应论文公式 (2-2)。在 f=25kHz 时，α≈3.52 dB/km。"

### 1.2 【原理】Urick 传输损耗模型 — 公式 (2-1)

- **代码位置**：`Physical_Layer/Channel_Urick.m`（全文 19 行）
- **话术**：
> "Urick 模型将路径损耗分为几何扩散（k·10lgd）和介质吸收（α·d×10⁻³）两项。扩散系数 k=1.5 取球面与柱面扩散的折中值，适用于深海混合场景。代码第 18 行是完整公式实现。"

### 1.3 【图像+指标】水声信道特性分析图 — 论文图 2-1

- **运行命令**：
```matlab
run('Agents/Plot_Physical_Model.m')
```
- **生成图像**：`Results/水声信道特性分析图.png`
- **话术**：
> "上子图是吸收系数随频率变化曲线，50kHz 以上进入快速增长区。下子图对比了 10/20/50kHz 三频率下传输损耗随距离变化，1000m 处 50kHz 比 10kHz 高约 15dB，说明频段选择至关重要。本文选用 25kHz 兼顾通信距离与带宽。"

### 1.4 【原理】节点能耗模型 — 公式 (2-3)(2-4)(2-5)

- **代码位置**：`Physical_Layer/Update_Energy.m`
- **关键行**：第 83 行（发送能耗 E_tx = L·E_elec + E_tx_loss）、第 89 行（接收能耗 E_rx = L·E_elec）
- **话术**：
> "能耗模型分三部分：发送含电路能耗和功放能耗（与传输损耗挂钩），接收仅含固定电路能耗，空闲监听由 `Update_Idle_Energy.m` 处理。代码还集成了真实声速计算和地形遮挡检测。"

### 1.5 【原理】仿真平台四层架构 — 论文图 2-2 / 表 2-2

- **代码位置**：`Core_Simulation/Config_Params.m`（全部参数配置）
- **话术**：
> "平台代码按四层目录组织：Physical_Layer（信道/能耗）、Network_Layer（协议/路由）、Core_Simulation（主循环/配置）、Agents（绘图/分析）。表 2-2 中所有参数均在 Config_Params.m 中集中管理，如 N=100 节点、区域 500m³、初始能量 1.0J、通信半径 325m、学习率 α=0.1、折扣因子 γ=0.9。"

---

## 二、EC-QL 算法设计与实现（论文第 3 章）

### 2.1 【原理】LEACH 对比协议 — 公式 (3-1)

- **代码位置**：`Network_Layer/Run_LEACH_Election.m` 第 9-10 行
- **话术**：
> "LEACH 的簇头选举阈值 T(n) 在代码第 10 行实现。p=0.05 为目标簇头比例，r 为当前轮次。核心局限在于：选举不感知能量、簇头至 Sink 单跳直连导致远距离高能耗。"

### 2.2 【原理】QELAR 对比协议 — 公式 (3-2)

- **代码位置**：`Network_Layer/Calculate_QELAR_Reward.m`（全文仅 6 行）
- **话术**：
> "QELAR 奖励函数极其简单：R = E_next/E_0，仅依赖下一跳剩余能量比率。这导致策略倾向于绕路至高能量节点，FND 仅为 1 轮、延迟高达约 2.93s。"

### 2.3 【原理】EC-QL 两层解耦架构 — §3.2.2

- **分簇层代码**：`Network_Layer/Run_Cluster_Election.m`
- **路由层代码**：`Network_Layer/Route_To_Sink.m`
- **话术**：
> "EC-QL 采用两层解耦架构。分簇层（Run_Cluster_Election.m）让每个节点根据 Q 表自主决策担任簇头还是成员；路由层（Route_To_Sink.m）在簇头骨干网络上学习多跳最优路径。两层共享 ε-greedy 探索策略，初始 ε=0.5，每轮衰减 0.98 直至 0.05。"

### 2.4 【原理】分簇层状态空间 — 公式 (3-6)

- **代码位置**：`Network_Layer/Map_State_Cluster.m`
- **话术**：
> "状态空间由三个维度组合：能量等级（3 级）× 距离等级（3 级）× 密度等级（2 级）= 18 个离散状态。代码第 3-27 行实现了三维度的分级映射，第 30 行计算线性索引。"

### 2.5 【图像】网络初始拓扑 — 论文图 3-1

- **运行命令**（需先运行仿真生成拓扑）：
```matlab
Config_Params;
[Nodes, Sink] = Initialize_Network(N, Area_Size, Initial_Energy, Sink_Pos);
Plot_Network_Topology(Nodes, Sink);
```
- **生成图像**：`Results/网络初始拓扑（节点随机部署）.png`
- **话术**：
> "100 个传感器节点在 500×500×500m³ 三维空间中随机均匀部署，Sink 位于 (250,250,500)。随机分布保证了仿真对真实水下部署的代表性。"

### 2.6 【图像】典型轮次路由拓扑 — 论文图 3-2

- **运行命令**：
```matlab
run('Agents/Plot_Routing_Paths.m')
```
- **生成图像**：`Results/典型轮次EC-QL路由拓扑图（簇头分布与多跳路径）.png`
- **话术**：
> "经过 3000 轮深度 Q-learning 训练后，EC-QL 形成分布均匀的簇头骨干网络，路由路径呈多跳折线形式，有效规避了单跳长距离传输的高功放能耗。橙色点为中继节点，绿色线为学习到的最优路径。"

### 2.7 【原理】五维多目标奖励函数 — 公式 (3-8)~(3-12)

- **代码位置**：`Network_Layer/Calculate_Routing_Reward.m`
- **对应关系**：
  | 论文公式 | 代码行 | 说明 |
  |---------|-------|------|
  | R_E = (E_next/E_0)⁴ | 第 8 行 | 四次方非线性能量奖励 |
  | R_D（进度奖励） | 第 21 行 | 负进度则第 24 行返回 -100 |
  | R_L（链路质量） | 第 61-62 行 | 基于 TL 计算 SNR |
  | R_Delay | 第 67-70 行 | 使用真实声速 C_eff |
  | R_cost = -(d/R_comm)⁴ | 第 57 行 | 非线性距离惩罚 |
- **动态权重**：第 74 行，`dynamic_alpha = min(0.95, alpha + 0.6*(1-E_ratio))`
- **话术**：
> "五维奖励函数是本文核心创新。第 8 行的四次方设计使低能量区惩罚急剧增大；第 24 行强制前向性避免回环；第 57 行的四次方距离惩罚抑制长跳；第 67-70 行将真实声速纳入延迟计算。第 74 行的动态权重机制在节点能量下降时自动调高能量权重优先保电。最终第 84-88 行加权合成总奖励。"

### 2.8 【原理】Q-learning 更新公式 — 公式 (3-5)

- **路由层 Q 表更新**：`Network_Layer/Route_To_Sink.m` 第 73-74 行
- **分簇层 Q 表更新**：`Network_Layer/Update_Q_Cluster.m` 第 30-31 行
- **话术**：
> "两层均使用标准 Bellman 方程更新 Q 值。Route_To_Sink.m 第 73 行：Q(s,a) ← (1-α)·Q(s,a) + α·[R + γ·max Q(s',a')]。学习率 α=0.1，折扣因子 γ=0.9。"

---

## 三、仿真实验与结果分析（论文第 4 章）

### 3.1 【图像+指标】存活节点曲线 — 论文图 4-1

- **运行命令**（先仿真，再绘图）：
```matlab
run('Core_Simulation/Main_ECQL.m')    % 生成 Data_QL.mat（约3-5分钟）
run('Core_Simulation/Main_LEACH.m')   % 生成 Data_LEACH.mat
run('Core_Simulation/Main_QELAR.m')   % 生成 Data_QELAR.mat
run('Agents/Plot_Alive_Curve_Ideal.m') % 绘制对比图
```
- **生成图像**：`Results/三协议存活节点数随轮次对比.png`
- **关键指标**：
  - 📌 **EC-QL FND = 117 轮，LEACH FND = 96 轮 → FND 提升 21.9%**
  - 📌 QELAR FND = 1 轮（第一轮即有节点死亡）
- **话术**：
> "图中绿色实线为 EC-QL，蓝色虚线为 LEACH，红色虚线为 QELAR。EC-QL 的首节点死亡时间 FND=117 轮，相对 LEACH 的 96 轮提升了 21.9%，达到预设的 15% 目标。QELAR 因单一能量奖励导致盲目绕路，FND 仅 1 轮。"

### 3.2 【图像+指标】端到端传输延迟 — 论文图 4-2

- **运行命令**：
```matlab
run('Agents/Plot_Delay_Analysis.m')
```
- **生成图像**：`Results/三协议端到端传输延迟对比.png`
- **关键指标**：
  - 📌 **EC-QL 平均延迟 ≈0.16s，LEACH ≈0.22s → 延迟降低 30.7%**
  - 📌 QELAR 延迟 ≈2.93s → EC-QL 相对降低 94.5%（远超 80% 目标）
- **话术**：
> "由于量级差异巨大，采用双子图分层显示。上图 QELAR 延迟约 2.93s，下图 EC-QL 约 0.16s、LEACH 约 0.22s。EC-QL 延迟降低得益于 R_Delay 奖励分量和多跳短距中继策略。"

### 3.3 【图像+指标】能耗均衡性 — 论文图 4-3

- **运行命令**：
```matlab
run('Agents/Plot_Energy_Analysis.m')
```
- **生成图像**：`Results/全网节点能耗均衡性对比.png`
- **关键指标**：
  - 📌 **EC-QL 能量标准差 0.1786J ≈ LEACH 0.1773J，远优于 QELAR 0.2254J**
  - 📌 仿真结束时 EC-QL 总剩余能量相对 LEACH **提升 12.7%**
- **话术**：
> "左图为节点剩余能量随深度的散点分布，右图为标准差柱状对比。EC-QL 在延长寿命的同时保持了与 LEACH 相当的能耗均衡性，说明其延寿优势来自整体能效提升而非极端均摊。"

### 3.4 【指标汇总】运行指标打印脚本

- **运行命令**：
```matlab
run('Print_Protocol_Metrics.m')
```
- **话术**：
> "这个脚本自动从仿真数据中提取并打印所有核心指标及 EC-QL 相对提升百分比，方便快速验证论文中声称的全部量化目标。"

### 3.5 【图像+指标】鲁棒性分析 — 论文图 4-4/4-5/4-6

#### 图 4-4：业务负载鲁棒性
```matlab
run('Core_Simulation/Generate_Robustness_Data.m')  % 生成数据（耗时较长）
run('Agents/Plot_Robustness_Analysis.m')            % 绘制三张图
```
- **生成图像**：`Results/不同业务负载下三协议网络寿命对比.png`
- **指标**：低负载(5pkt) EC-QL FND=145 vs LEACH=129；高负载(40pkt) EC-QL=70 vs LEACH=18，差距随负载增大显著扩大

#### 图 4-5：网络区域规模鲁棒性
```matlab
run('Core_Simulation/Generate_Robustness_Area.m')
```
- **生成图像**：`Results/不同网络区域规模下三协议网络寿命对比.png`
- **指标**：EC-QL 在 300~800m 范围内 FND 稳定约 220 轮，LEACH 在 140~165 间波动

#### 图 4-6：初始能量异构度鲁棒性
```matlab
run('Core_Simulation/Generate_Robustness_Energy.m')
```
- **生成图像**：`Results/初始能量分布不均对三协议网络寿命的影响.png`
- **指标**：δ=0.1 时 EC-QL FND=222 vs LEACH=162；δ=0.9 时两者趋同

- **话术**：
> "三类鲁棒性实验分别扫描业务负载、覆盖区域和能量异构度。EC-QL 在所有条件下均保持 FND 优势，尤其在负载增大和区域扩展时优势更显著。这得益于五维奖励函数中的非线性距离惩罚和多跳分摊机制。"

---

## 四、真实海洋环境验证（论文 §4.3）

### 4.1 【图像】真实海洋地形与节点部署 — 论文图 4-7

- **运行命令**：
```matlab
Config_Params;
[X, Y, Z_mesh, Nodes_terrain] = Load_Realistic_Bathymetry(100);
```
- **生成图像**：`Results/真实海洋地形与节点部署地图.png`
- **话术**：
> "本图基于 NOAA SRTM15+ 真实海底地形数据。红色为底栖节点（60%，贴合海床），黄色为悬浮节点（40%）。地形起伏通过 `interp2` 插值获得精确海床高度，用于后续 LOS 遮挡判断。"

### 4.2 【原理】真实环境物理模型集成

- **WOA23 温盐剖面**：`Physical_Layer/Get_WOA23_Profile.m`（温跃层+盐跃层经验拟合）
- **Mackenzie 声速公式**：`Physical_Layer/Mackenzie_SSP.m`（九项经验公式）
- **地形遮挡检测**：`Physical_Layer/Update_Energy.m` 第 62-76 行
- **话术**：
> "真实环境集成三个模块：Get_WOA23_Profile 提供南海典型温盐剖面（表面 28°C 指数衰减至深海 4°C）；Mackenzie_SSP 计算动态声速替代固定 1500m/s；Update_Energy 第 64-75 行检测信号中点是否被海底地形遮挡，若遮挡则 TL+30dB 模拟能量浪费。"

### 4.3 【图像+指标】真实环境鲁棒性 — 论文图 4-8/4-9/4-10

```matlab
run('Core_Simulation/Generate_Robustness_Data_Realistic.m')
run('Core_Simulation/Generate_Robustness_Area_Realistic.m')
run('Core_Simulation/Generate_Robustness_Energy_Realistic.m')
run('Agents/Plot_Robustness_Analysis_Realistic.m')
```
- **生成图像**：
  - `Results/真实海洋环境下不同业务负载对FND的影响.png`（图 4-8）
  - `Results/真实海洋环境下网络规模对三协议FND的影响.png`（图 4-9）
  - `Results/真实海洋环境下初始能量异构对三协议FND的影响.png`（图 4-10）
- **话术**：
> "真实环境下 EC-QL 的鲁棒性优势基本保持。值得注意的是，真实环境中 EC-QL 的 FND 不降反升（141 轮 vs 理想环境 117 轮），这可能与真实声速剖面形成的低耗声波导链路有关。"

### 4.4 【图像+指标】真实环境延迟对比 — 论文图 4-11

```matlab
run('Core_Simulation/Main_ECQL.m')   % 确保 Data_QL_Realistic.mat 已生成
run('Core_Simulation/Main_LEACH.m')
run('Core_Simulation/Main_QELAR.m')
run('Agents/Plot_Delay_Analysis_Realistic.m')
```
- **生成图像**：`Results/真实海洋声学模型下三协议端到端传输延迟对比.png`
- **指标**：EC-QL 在真实环境下平均延迟约 0.16s，与理想环境持平
- **话术**：
> "EC-QL 在真实环境延迟约 0.16s 与理想环境几乎持平，体现了 R_Delay 五维奖励对高延迟路径的持续约束能力。"

### 4.5 【图像+指标】真实环境能耗均衡性 — 论文图 4-12

```matlab
run('Agents/Plot_Energy_Analysis_Realistic.m')
```
- **生成图像**：`Results/真实海洋环境下全网节点能耗均衡性对比.png`
- **指标**：EC-QL 能量标准差 0.1503J，优于理想环境的 0.1786J
- **话术**：
> "真实环境下 EC-QL 的能耗均衡性反而更优，标准差从 0.1786 降至 0.1503。这说明真实地形的遮挡效应迫使算法选择更分散的路由路径，间接促进了负载均衡。"

### 4.6 【图像】EC-QL 理想 vs 真实环境横向对比 — 论文图 4-13

```matlab
run('Agents/Plot_ECQL_Ideal_vs_Realistic.m')
```
- **生成图像**：`Results/ECQL_理想与真实环境性能对比.png`
- **指标**：FND 理想 117 轮 → 真实 141 轮；延迟均为 0.16s
- **话术**：
> "横向对比柱状图直观展示：EC-QL 在真实海洋环境中 FND 不降反升，延迟保持不变，验证了算法在复杂物理约束下的泛化能力。"

---

## 五、Demo 时间管理建议

| 阶段 | 预计时间 | 备注 |
|------|---------|------|
| 第 2 章 物理模型 | 3 min | 展示代码 + 运行 1 张图 |
| 第 3 章 算法设计 | 5 min | 重点讲奖励函数代码 |
| 第 4 章 理想环境实验 | 5 min | 提前运行好数据，现场绘图 |
| 第 4 章 鲁棒性 | 3 min | 数据提前生成，现场绘图 |
| 第 4 章 真实环境 | 4 min | 地形图 + 对比图 |

> [!TIP]
> **耗时较长的数据生成脚本建议提前运行好**（Generate_Robustness_*.m 和 Main_*.m），demo 时只运行绘图脚本（Plot_*.m），每张图仅需几秒。

> [!IMPORTANT]
> **三大量化目标速记**：FND +21.9%（≥15%✅）、延迟 -30.7%（≥20%✅）、总剩余能量 +12.7%（≥10%✅）
