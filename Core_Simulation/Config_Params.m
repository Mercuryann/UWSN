% Config_Params.m

global N Area_Size Initial_Energy Sink_Pos Comm_Range
global E_elec R_rate P_amp P_rx P_idle Packet_Length
global alpha_val beta_val gamma_val SNR_ref
global learning_rate gamma_discount epsilon
global Max_Rounds T_round E_init

% --- 拓扑参数 ---
N = 100;                
Area_Size = 500;        
Initial_Energy = 1.0;   % 建议设定在 0.5J - 2.0J 之间以便于观察
E_init = Initial_Energy;
Sink_Pos = [250, 250, 500]; 
Comm_Range = 325;       

% --- 方案 B：优化能耗比例 ---
E_elec = 50e-9;         
R_rate = 10000;         
P_amp  = 10e-12;        
P_rx   = 15e-3;         
P_idle = 1e-3;          % 调低空闲功耗 (从 10mW 降至 1mW)
Packet_Length = 2048;   % 增加包长 (从 1024 增至 2048 bits) 以增强通信能耗占比

% --- Q-learning 与 路由参数 ---
alpha_val = 0.4;        
beta_val  = 0.4;        
gamma_val = 0.2;        
SNR_ref = 20;           
learning_rate = 0.1;    
gamma_discount = 0.9;   
epsilon = 0.2;          

% --- 循环控制 ---
Max_Rounds = 2000;      
T_round = 3;            % 缩短每轮时长以进一步减小空闲功耗的影响
% --- 负载测试参数 ---
global Packets_Per_Node
Packets_Per_Node = 10;  % 每个成员节点在每一轮产生的数据包数量
% --- LEACH 协议参数 ---
global P_leach
P_leach = 0.05;  % 期望的簇头比例（通常为 5%）