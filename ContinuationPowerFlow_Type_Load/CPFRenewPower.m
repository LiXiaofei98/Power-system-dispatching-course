%% 根据指定的负荷增长方式 以及 lambda 的值，更新节点 i 对应的发电机、负荷的有功功率、无功功率；
%% 这里选择全网负荷等比例增长；
%% BusDataPrimary 格式：
% 1           2         3            4               5            6              7                  8         9              10                  11
% Bus_i      Type       P_load(MW)   Q_load(MVar)    G_parallel   B_parallel     V_amplitude(p.u.)  V_angle   V_base         V_amplitude_max     V_amplitude_min
% 节点编号    节点类型   有功负荷(MW)  无功负荷(MVar)  并联电导(MW)  并联电容(MVar)  电压幅值(标幺值)   电压角度   电压基准值(kV)  电压最大幅值(标幺值) 电压最小幅值(标幺值)
% 其中，节点类型：1-PQ; 2-PV;3-Balance;

%% GeneratorDataPrimary 格式：
% 1           2             3              4                  5                  6                    7                 8           9               10                 
% Bus_i       P_gen(MW)     Q_gen(MVar)   Q_gen_max(MVar)     Q_gen_min(MVar)    V_gen                S_base            Statue      P_gen_max(MW)   P_gen_min(MW)     
% 节点编号    有功输出(MW)   无功输出(MVar)  最大无功输出(MVar)  最小无功输出(MVar) 电压幅值设定(标幺值)   发电机视在功率     发电机状态  最大有功输出(MW) 最小有功输出(MW)
% 其中，发电机状态：1-运行； 2-停运；
function [BusDataCPF, BranchDataCPF, GeneratorDataCPF] = ...
    CPFRenewPower(busNumber, lambda, KG, KL, PV, BusDataPrimary, BranchDataPrimary, GeneratorDataPrimary)
    % 1. 初始化 母线数据 线路数据 发电机数据；
    BusDataCPF = BusDataPrimary;
    BranchDataCPF = BranchDataPrimary;
    GeneratorDataCPF = GeneratorDataPrimary;
    
    % 2. 根据 lambda 及 KL 的值，修正每个母线的有功负荷、无功负荷；
    for x = 1:1:busNumber
        BusDataCPF(x, 3) = (1 + lambda * KL(x)) * BusDataPrimary(x, 3);     % 负荷有功功率增长；
        BusDataCPF(x, 4) = (1 + lambda * KL(x)) * BusDataPrimary(x, 4);     % 负荷无功功率增长；
    end
    
    % 2. 根据 lambda 及 KG 的值，修正每台发电机的有功输出；
    % GenBus ：发电机母线在网络中的 节点编号；
    [GenBus, ~, ~] = intersect(GeneratorDataPrimary(:, 1), PV);             % 找出 发电机的编号；

    for x = 1:1:length(GeneratorDataCPF(:, 1))
        for y = 1:1:length(GenBus)
            if GeneratorDataCPF(x, 1) == GenBus(y)
                GeneratorDataCPF(x, 2) = ...
                    (1 + lambda * KG(GenBus(y))) * GeneratorDataCPF(x, 2);	% 发电机输出有功功率增长；
            end
        end
    end
return