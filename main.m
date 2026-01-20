% main.m - 统一入口脚本
clear; clc; close all;

% 1. 自动添加所有规范目录到路径 
addpath('Core_Simulation');
addpath('Physical_Layer');
addpath('Network_Layer');
addpath('Agents');
addpath('Results');

% 2. 运行物理层特性分析图表生成
Plot_Physical_Model; 

fprintf('所有物理层特性图表已成功生成并保存。\n');