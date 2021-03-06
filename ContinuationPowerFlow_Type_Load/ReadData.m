% 从指定路径读取案例的数据；
% 输入： busData.txt, generator.txt, branch.txt ；
% 返回： baseMVA, BusData, GeneratorData, BranchData ；

% busData.txt 格式：
% 1           2         3            4               5            6              7                  8         9              10                  11
% Bus_i      Type       P_load(MW)   Q_load(MVar)    G_parallel   B_parallel     V_amplitude(p.u.)  V_angle   V_base         V_amplitude_max     V_amplitude_min
% 节点编号    节点类型   有功负荷(MW)  无功负荷(MVar)  并联电导(MW)  并联电容(MVar)  电压幅值(标幺值)   电压角度   电压基准值(kV)  电压最大幅值(标幺值) 电压最小幅值(标幺值)
% 其中，节点类型：1-PQ; 2-PV;3-Balance;

% generator.txt 格式：
% 1           2             3              4                  5                  6                    7                 8           9               10                 
% Bus_i       P_gen(MW)     Q_gen(MVar)   Q_gen_max(MVar)     Q_gen_min(MVar)    V_gen                S_base            Statue      P_gen_max(MW)   P_gen_min(MW)     
% 节点编号    有功输出(MW)   无功输出(MVar)  最大无功输出(MVar)  最小无功输出(MVar) 电压幅值设定(标幺值)   发电机视在功率     发电机状态  最大有功输出(MW) 最小有功输出(MW)
% 其中，发电机状态：1-运行； 2-停运；

% 要求：busData.txt 中 PV 节点与平衡节点的电压幅值与 generator.txt 中的电压设定值一致；

% branch.txt 格式：
% 1       2      3          4           5                    6                       7                  8                    9             10           
% From    To     R(p.u.)    X(p.u.)     B(p.u.)              Ratio                   Angle              Statue               Imin          Imax
% 首节点  末节点  电阻(p.u.) 电抗(p.u.)  线路总充电电容(p.u.)  变压器变比(V_from:V_to)  移相变压器的移相角  线路或变压器运行状态   线路电流下限   线路电流上限
% 其中，变压器变比：0-线路；否则为变压器，非标准变比 K 为：首端/末端（K:1），阻抗放在节点末端；
% 这里的首端、末端仅指网络中的定义；
% 其中，线路或变压器运行状态：1-运行； 2-停运；
% 其中，线路总充电电容为 PI 模型时的单边电容（即已经除以 2 ）；
function [baseMVA, BusData,  BranchData, GeneratorData] = ReadData(busPath, generatorPath, branchPath)
    baseMVA = 100;
    BusData = load(busPath);                                               % 节点数据；
    GeneratorData = load(generatorPath);                                   % 发电机数据；
    BranchData = load(branchPath);                                         % 线路数据；
return 