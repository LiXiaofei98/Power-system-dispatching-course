% Continuous Power Flow 计算程序；
% CPF 类型：负荷型；

%% 固定参数；
clc;    clear;
global EPS; EPS = 0.00000001;                                               % 全局变量，常规潮流计算的迭代收敛判断条件；
global PI;  PI = 3.141592653;                                               % 全局变量，圆周率；
global PFITERATIONMAX;   PFITERATIONMAX = 50;                               % 全局变量，常规潮流计算最大迭代次数；
global CPFITERATIONMAX1;   CPFITERATIONMAX1 = 10;                           % 全局变量，CPF 计算最大迭代次数；

%% 算例选择，数据读取；
global caseNumber;  caseNumber = 14;                                        % 选择参数：算例编号；
global busMonitor;  busMonitor = 14;                                        % 观测点参数：电压监测点母线编号；

[busPath, generatorPath, branchPath] = ChooseCase(caseNumber);              % 获取算例文件路径；
[baseMVA, BusDataPrimary, BranchDataPrimary, GeneratorDataPrimary] = ...
    ReadData(busPath, generatorPath, branchPath);                           % 读取初始数据；
global BASEMVA;  BASEMVA = baseMVA;                                         % 基准功率；

BusData = BusDataPrimary;                                                   % 潮流计算中的母线数据；
BranchData = BranchDataPrimary;                                             % 潮流计算中的支路数据；
GeneratorData = GeneratorDataPrimary;                                       % 潮流计算中的发电机数据；

BusDataCPF = BusDataPrimary;                                                % CPF 计算中的母线数据；
BranchDataCPF = BranchDataPrimary;                                          % CPF 计算中的支路数据；
GeneratorDataCPF = GeneratorDataPrimary;                                    % CPF 计算中的发电机数据；

%% 进行潮流计算，获取初始解；                                                    
[Y, G, B, Y0, busNumber, lineNumber, generatorNumber] = ...
    Admittance(baseMVA, BusData, BranchData, GeneratorData);                % 求取网络的导纳矩阵；

[slack, ~] = find(BusData(:, 2) == 3);                                      % 平衡节点的编号；
[PQ, ~] = find(BusData(:, 2) == 1);                                         % 找出 PQ 节点编号，数量为 m ；
[PV, ~] = find(BusData(:, 2) == 2);                                         % 找出 PV 节点编号，数量为 n - m - 1 ；
[bus, Gen, ~] = intersect(GeneratorData(:, 1), PV);                         % 找出 发电机 的编号；

[BusPower, PFResultBus, PFResultBranch, ~, PFPloss, PFQloss, ~] = ...
    PowerFlowNewton_Polar(baseMVA, Y, G, B, Y0, busNumber, lineNumber, ...
                          PQ, PV, BusData, BranchData, GeneratorData);      % 常规潮流计算；

BusDataCPF(:, 7) = PFResultBus(:, 3);                                       % 更新各母线在初始状态下的 电压幅值；
BusDataCPF(:, 8) = PFResultBus(:, 4) * PI / 180;                            % 更新各母线在初始状态下的 电压相角，弧度值；

%% PV 曲线追踪参数定义；
disp('常规潮流计算结束，CPF 计算开始...');
LambdaMonitor = [];   VoltageMonitor = [];                                  % PV 曲线， lambda 向量 与 VoltageMonitor 幅值向量；
LambdaPredictor = zeros(1, 2); VoltagePredictor = zeros(1, 2);              % 预测切线， lambdaPredictor 向量 与 VoltagePredictor 幅值向量：第 1 个数为 当前值，第 2 个数为 预测值；

%% 参数选择：设定负荷增长方式；
lambda = 0;                                                                 % 负荷增长水平；
KL = ones(busNumber, 1);                                                    % 节点负荷增长率，这里设置为 1 ；
KG = ones(length(BusPower), 1);                                             % 发电机输出有功功率增长率，这里设置为 1 ；
[CPFPDlambda] = CPFPartialDerivativelambda(busNumber, PFResultBus, PQ, KL, KG);%得到P对lambda导数
dimEk = length(CPFPDlambda) + 1;

LambdaMonitor = [LambdaMonitor; lambda];
VoltageMonitor = [VoltageMonitor; BusDataCPF(busMonitor, 7)];               % 常规潮流的解为 PV 曲线的起点；

%% CPF 计算；
fprintf('连续潮流计算开始，观测母线为：bus %d\n', busMonitor);
tic;


%% 1. 第 1 阶段， PV 曲线较为平坦，以 lambda 作为切向量；
h = 0.2;                                                                    % 步长；
for TIME = 1:1:CPFITERATIONMAX1
    Voltage = BusDataCPF(:, 7);                                             % 电压幅值 初始值；
    Angle = BusDataCPF(:, 8);                                               % 电压相角 初始值；
                                                                            
    % 1.1 计算切向量；
    Ek = zeros(1, dimEk);   Ek(end) = 1;                                    % Jacobi 矩阵的补充行向量，选择 lambda 作连续参数时，最后一项对应于 lambda ，值为 1 ；
    X = zeros(dimEk, 1);   X(end) = 1;                                      % 局部参数化，选择 lambda 作连续参数时，最后一项对应于 lambda ，值为 1 ；
    [J0] = PFJacobian(busNumber, PQ, G, B, BusDataCPF, Voltage, Angle);     % 生成常规潮流的 Jacobi 矩阵；
    Jaug = [J0, CPFPDlambda; Ek];                                           % 增广 Jacobi 矩阵；
    TangentVector = (Jaug) \ X;                                             % 获得 切向量；
    
    % 1.2 确定下一轮计算时的连续参数下标编号；
    [continuationNext] = CPFChooseContinuationParamenter(busNumber, BusDataCPF, TangentVector);

    % 1.3 预测；
    [VoltageNextHat, AngleNextHat, lambdaNextHat] = ...                     % 预测步骤，获得 电压幅值 、 电压相角 、 lambda 的预测值；
        CPFEstimate(busNumber, BusDataCPF, Voltage, Angle, TangentVector, lambda, h);

    LambdaPredictor(1) = lambda;        VoltagePredictor(1) = Voltage(busMonitor);       
    LambdaPredictor(2) = lambdaNextHat; VoltagePredictor(2) = VoltageNextHat(busMonitor);%举例用
    
    % 作图：作出预测步骤的对应切线；
    plot(LambdaPredictor, VoltagePredictor, 'bx--', 'LineWidth', 0.5);    hold on;            

    % 1.4 校正，牛顿-拉夫逊 法；
    Voltage = VoltageNextHat;                                               % 校正步骤，所有节点的 电压幅值 初始值；
    Angle = AngleNextHat;                                                   % 校正步骤，所有节点的 电压相角 初始值；
    lambda = lambdaNextHat;                                                 % 校正步骤，lambda 初始值；

    for r = 1:1:PFITERATIONMAX
        [BusDataCPF, BranchDataCPF, GeneratorDataCPF] = ...                 % 根据 lambda 修正功率数据；
        CPFRenewPower(busNumber, lambda, KG, KL, PV, BusDataPrimary, BranchDataPrimary, GeneratorDataPrimary);

        [busCPF, GenCPF, ~] = intersect(GeneratorDataCPF(:, 1), PV);        % 找出发电机的编号；
        BusPowerCPF = zeros(busNumber, 1);
        BusPowerCPF(busCPF) = GeneratorDataCPF(GenCPF, 2) / BASEMVA;
    
        [DeltaPQ] = PFMismatch(busNumber, G, B, Voltage, Angle, BusPowerCPF, BusDataCPF, PQ);
                                                                            % 生成常规潮流的 功率不平衡量 向量；
        M = -lambdaNextHat + lambda;                                        % 生成 增广方程 不平衡值；
        d_PQlambda = [DeltaPQ; M];                                         	% 增广不平衡向量；
    
        [convergence] = PFJudgeConvergence(EPS, d_PQlambda);                % 判断是否满足收敛条件；
        if convergence == 1                                                 % 结果收敛，终止迭代；
            break;
        else                                                                % 结果未收敛，继续迭代；      
        [J0] = PFJacobian(busNumber, PQ, G, B, BusDataCPF, Voltage, Angle); % 常规潮流的 Jacobi 矩阵；
        Ek = zeros(1, dimEk);   Ek(end) = 1;                                % Jacobi 矩阵的补充行向量，选择 lambda 作连续参数时，最后一项对应于 lambda ，值为 1 ；
        Jaug = [J0, CPFPDlambda; Ek];                                       % 增广 Jacobi 矩阵；
        d_V_A_lambda = -inv(Jaug) * d_PQlambda;                             % 电压幅值 、 电压相角 、 lambda 的偏差量；
        [Voltage, Angle, lambda] = ...                                      % 按照偏差量，更新 电压幅值 、 电压相角 、 lambda ；
            CPFRenewVlambda(busNumber, BusDataCPF, Voltage, Angle, lambda, d_V_A_lambda);
        end 
    end

    BusDataCPF(:, 7) = Voltage;                                             % 根据计算出的校正值，更新 电压幅值；
    BusDataCPF(:, 8) = Angle;                                               % 根据计算出的校正值，更新 电压相角；
    LambdaMonitor = [LambdaMonitor; lambda];   
    VoltageMonitor = [VoltageMonitor; BusDataCPF(busMonitor, 7)];           % PV 曲线， lambda 向量 与 VoltageMonitor 幅值向量的校正值；

end
fprintf('PV 曲线第 1 阶段计算完毕...\n');
        
%% 第 2 阶段，临近鼻点附近，选择 电压幅值变化量 最大的参数作为连续参数；
h = 0.01;
FLAG = 1;
for TIME = 1:1:50
    Voltage = BusDataCPF(:, 7);                                             % 电压幅值 初始值；
    Angle = BusDataCPF(:, 8);                                               % 电压相角 初始值；
    continuation = continuationNext;

    % 2.1 计算切向量；
    Ek = zeros(1, dimEk);   Ek(continuation) = 1;                           % Jacobi 矩阵的补充行向量，选择 xk 作连续参数时，第 k 项对应值为 1 ；
    X = zeros(dimEk, 1);   X(end) = -1;                                     % 局部参数化，选择 xk 作连续参数时，最后一项对应于 xk ，值为 -1 ，因为电压幅值一直在降低；
    [J0] = PFJacobian(busNumber, PQ, G, B, BusDataCPF, Voltage, Angle);     % 生成常规潮流的 Jacobi 矩阵；
    Jaug = [J0, CPFPDlambda; Ek];                                           % 增广 Jacobi 矩阵；
    TangentVector = (Jaug) \ X;                                             % 获得 切向量；

    if TangentVector(end) < 0 && FLAG == 1                                  % 提示 PV 曲线越过鼻点；
        fprintf('dlambda = %f\t， PV 曲线已经越过鼻点...\n', TangentVector(end));
        FLAG = 0;
    end
    
    % 2.2 确定下一轮计算时的连续参数下标编号；
    [continuationNext] = CPFChooseContinuationParamenter(busNumber, BusDataCPF, TangentVector);

    % 2.3 预测；
    [VoltageNextHat, AngleNextHat, lambdaNextHat] = ...                     % 预测步骤，获得 电压幅值 、 电压相角 、 lambda 的预测值；
        CPFEstimate(busNumber, BusDataCPF, Voltage, Angle, TangentVector, lambda, h);

    LambdaPredictor(1) = lambda;        VoltagePredictor(1) = Voltage(busMonitor);       
    LambdaPredictor(2) = lambdaNextHat; VoltagePredictor(2) = VoltageNextHat(busMonitor);
    
    % 作图：作出预测步骤的对应切线；
    plot(LambdaPredictor, VoltagePredictor, 'bSquare --', 'LineWidth', 0.5);    hold on;            

    % 2.4 校正，牛顿-拉夫逊 法；
    Voltage = VoltageNextHat;                                               % 校正步骤，所有节点的 电压幅值 初始值；
    Angle = AngleNextHat;                                                   % 校正步骤，所有节点的 电压相角 初始值；
    lambda = lambdaNextHat;                                                 % 校正步骤，lambda 初始值；

    for r = 1:1:PFITERATIONMAX
        [BusDataCPF, BranchDataCPF, GeneratorDataCPF] = ...                 % 根据 lambda 修正功率数据；
        CPFRenewPower(busNumber, lambda, KG, KL, PV, BusDataPrimary, BranchDataPrimary, GeneratorDataPrimary);

        [busCPF, GenCPF, ~] = intersect(GeneratorDataCPF(:, 1), PV);        % 找出发电机的编号；
        BusPowerCPF = zeros(busNumber, 1);
        BusPowerCPF(busCPF) = GeneratorDataCPF(GenCPF, 2) / BASEMVA;
    
        [DeltaPQ] = PFMismatch(busNumber, G, B, Voltage, Angle, BusPowerCPF, BusDataCPF, PQ);
                                                                            % 生成常规潮流的 功率不平衡量 向量；
        [M] = CPFAugmentedFunction(busNumber, dimEk, continuation, BusDataCPF, ...
            AngleNextHat, Angle, VoltageNextHat, Voltage);                  % 生成 增广方程 不平衡值；
        d_PQlambda = [DeltaPQ; M];                                          % 增广不平衡向量；
    
        [convergence] = PFJudgeConvergence(EPS, d_PQlambda);                % 判断是否满足收敛条件；
        if convergence == 1                                                 % 结果收敛，终止迭代；
            break;
        else                                                                % 结果未收敛，继续迭代；      
        [J0] = PFJacobian(busNumber, PQ, G, B, BusDataCPF, Voltage, Angle); % 常规潮流的 Jacobi 矩阵；
        Ek = zeros(1, dimEk);   Ek(continuation) = 1;                       % Jacobi 矩阵的补充行向量，选择 xk 作连续参数时，第 k 项对应值为 1 ；
        Jaug = [J0, CPFPDlambda; Ek];                                       % 增广 Jacobi 矩阵；
        d_V_A_lambda = -inv(Jaug) * d_PQlambda;                             % 电压幅值 、 电压相角 、 lambda 的偏差量；
        [Voltage, Angle, lambda] = ...                                      % 按照偏差量，更新 电压幅值 、 电压相角 、 lambda ；
            CPFRenewVlambda(busNumber, BusDataCPF, Voltage, Angle, lambda, d_V_A_lambda);
        end 
    end

    BusDataCPF(:, 7) = Voltage;                                             % 根据计算出的校正值，更新 电压幅值；
    BusDataCPF(:, 8) = Angle;                                               % 根据计算出的校正值，更新 电压相角；
    LambdaMonitor = [LambdaMonitor; lambda];   
    VoltageMonitor = [VoltageMonitor; BusDataCPF(busMonitor, 7)];           % PV 曲线， lambda 向量 与 VoltageMonitor 幅值向量的校正值；

end
fprintf('PV 曲线第 2 阶段计算完毕...\n');
time = toc;
%% 信息输出与作图；
[lambdaMax, k] = max(LambdaMonitor);
CriticalX = [LambdaMonitor(k); LambdaMonitor(k)];
CriticalY = [0; VoltageMonitor(k)];

fprintf('CPF 计算完毕，耗时 %f s...\n', time);
fprintf('鼻点处的 lambda = %f\n', lambdaMax);

plot(LambdaMonitor, VoltageMonitor, 'ro-', 'LineWidth', 1);      hold on; 
plot(CriticalX, CriticalY, 'k--', 'LineWidth', 1);               hold on;       

Legend = zeros(3, 1); 
Legend(1) = plot(NaN, NaN, 'bx--', 'LineWidth', 1); 
Legend(2) = plot(NaN, NaN, 'bSquare --', 'LineWidth', 1); 
Legend(3) = plot(NaN, NaN, 'ro-', 'LineWidth', 1); 
legend(Legend, 'Predictor Stage 1','Predictor Stage 2','PV Curve'); 

grid on;    xlabel('PQload');    ylabel('Voltage');   
% xlim([0, 3.5]);      
% ylim([0, 1.1]);
title(['System Name:', num2str(caseNumber), ', Bus Number:', num2str(busMonitor)]);
