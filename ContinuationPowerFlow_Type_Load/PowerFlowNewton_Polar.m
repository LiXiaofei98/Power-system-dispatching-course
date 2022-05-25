% 利用极坐标形式的牛顿-拉夫逊法求潮流；
% Matlab 的三角函数采用的是：弧度制；
% 修改矩阵的元素下标后，该程序可以改编为：C/C# 等；
% 向量、矩阵、复数、函数 名称首字母大写；一般类型变量 名称首字母小写；宏定义 名称全大写；

function [BusPower, ResultBus, ResultBranch, S_slack, Ploss, Qloss, counter] = ...
    PowerFlowNewton_Polar(baseMVA, Y, G, B, Y0, busNumber, lineNumber, PQ, PV, BusData, BranchData, GeneratorData)   
    global EPS;                                                                % 全局变量，迭代收敛判断条件；
    global PI;                                                                 % 全局变量，圆周率；
    global PFITERATIONMAX;                                                     % 全局变量，最大迭代次数；
    global BASEMVA;                                                            % 全局变量，基准功率；
    
    %% 求取电压初始值： Voltage, delta；
    Voltage = BusData(:, 7);                                                   % 所有节点的电压幅值（迭代计算用）；
    Angle = BusData(:, 8) .* PI / 180;                                         % 所有节点的电压相角弧度值（迭代计算用）；

    %% 进入迭代；
    [bus, Gen, ~] = intersect(GeneratorData(:, 1), PV);                        % 找出 发电机的编号；
    BusPower = zeros(busNumber, 1);
    BusPower(bus) = GeneratorData(Gen, 2) / BASEMVA;

    counter = 1;                                                               % 循环次数；
    for r = 1:1:PFITERATIONMAX
        [DeltaPQ] = PFMismatch(busNumber, G, B, Voltage, Angle, BusPower, BusData, PQ);
                                                                               % 生成 功率不平衡量 向量；
        [convergence] = PFJudgeConvergence(EPS, DeltaPQ);                      % 判断是否满足收敛条件；

        if convergence == 1                                                    % 结果收敛，终止迭代；
            counter = r - 1;
            break;
        else                                                                   % 结果未收敛，继续迭代；            
            [Jacobi] = ...
                PFJacobian(busNumber, PQ, G, B, BusData, Voltage, Angle);      % 生成 Jacobi 矩阵；
            DeltaV = -inv(Jacobi) * DeltaPQ;                                   % 除平衡节点外，所有节点电压的偏差量（迭代计算使用）；
            [Voltage, Angle] = ...
                PFRenewV(busNumber, BusData, Voltage, Angle, DeltaV);          % 更新节点电压；
        end 
    end
    [ResultBus, ResultBranch, S_slack, Ploss, Qloss] = ...
        PFResults(busNumber, lineNumber, BusData, BranchData, Y, G, B, Y0, Voltage, Angle, baseMVA);
return