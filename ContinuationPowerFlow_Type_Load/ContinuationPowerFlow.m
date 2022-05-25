% Continuous Power Flow �������
% CPF ���ͣ������ͣ�

%% �̶�������
clc;    clear;
global EPS; EPS = 0.00000001;                                               % ȫ�ֱ��������泱������ĵ��������ж�������
global PI;  PI = 3.141592653;                                               % ȫ�ֱ�����Բ���ʣ�
global PFITERATIONMAX;   PFITERATIONMAX = 50;                               % ȫ�ֱ��������泱������������������
global CPFITERATIONMAX1;   CPFITERATIONMAX1 = 10;                           % ȫ�ֱ�����CPF ����������������

%% ����ѡ�����ݶ�ȡ��
global caseNumber;  caseNumber = 14;                                        % ѡ�������������ţ�
global busMonitor;  busMonitor = 14;                                        % �۲���������ѹ����ĸ�߱�ţ�

[busPath, generatorPath, branchPath] = ChooseCase(caseNumber);              % ��ȡ�����ļ�·����
[baseMVA, BusDataPrimary, BranchDataPrimary, GeneratorDataPrimary] = ...
    ReadData(busPath, generatorPath, branchPath);                           % ��ȡ��ʼ���ݣ�
global BASEMVA;  BASEMVA = baseMVA;                                         % ��׼���ʣ�

BusData = BusDataPrimary;                                                   % ���������е�ĸ�����ݣ�
BranchData = BranchDataPrimary;                                             % ���������е�֧·���ݣ�
GeneratorData = GeneratorDataPrimary;                                       % ���������еķ�������ݣ�

BusDataCPF = BusDataPrimary;                                                % CPF �����е�ĸ�����ݣ�
BranchDataCPF = BranchDataPrimary;                                          % CPF �����е�֧·���ݣ�
GeneratorDataCPF = GeneratorDataPrimary;                                    % CPF �����еķ�������ݣ�

%% ���г������㣬��ȡ��ʼ�⣻                                                    
[Y, G, B, Y0, busNumber, lineNumber, generatorNumber] = ...
    Admittance(baseMVA, BusData, BranchData, GeneratorData);                % ��ȡ����ĵ��ɾ���

[slack, ~] = find(BusData(:, 2) == 3);                                      % ƽ��ڵ�ı�ţ�
[PQ, ~] = find(BusData(:, 2) == 1);                                         % �ҳ� PQ �ڵ��ţ�����Ϊ m ��
[PV, ~] = find(BusData(:, 2) == 2);                                         % �ҳ� PV �ڵ��ţ�����Ϊ n - m - 1 ��
[bus, Gen, ~] = intersect(GeneratorData(:, 1), PV);                         % �ҳ� ����� �ı�ţ�

[BusPower, PFResultBus, PFResultBranch, ~, PFPloss, PFQloss, ~] = ...
    PowerFlowNewton_Polar(baseMVA, Y, G, B, Y0, busNumber, lineNumber, ...
                          PQ, PV, BusData, BranchData, GeneratorData);      % ���泱�����㣻

BusDataCPF(:, 7) = PFResultBus(:, 3);                                       % ���¸�ĸ���ڳ�ʼ״̬�µ� ��ѹ��ֵ��
BusDataCPF(:, 8) = PFResultBus(:, 4) * PI / 180;                            % ���¸�ĸ���ڳ�ʼ״̬�µ� ��ѹ��ǣ�����ֵ��

%% PV ����׷�ٲ������壻
disp('���泱�����������CPF ���㿪ʼ...');
LambdaMonitor = [];   VoltageMonitor = [];                                  % PV ���ߣ� lambda ���� �� VoltageMonitor ��ֵ������
LambdaPredictor = zeros(1, 2); VoltagePredictor = zeros(1, 2);              % Ԥ�����ߣ� lambdaPredictor ���� �� VoltagePredictor ��ֵ�������� 1 ����Ϊ ��ǰֵ���� 2 ����Ϊ Ԥ��ֵ��

%% ����ѡ���趨����������ʽ��
lambda = 0;                                                                 % ��������ˮƽ��
KL = ones(busNumber, 1);                                                    % �ڵ㸺�������ʣ���������Ϊ 1 ��
KG = ones(length(BusPower), 1);                                             % ���������й����������ʣ���������Ϊ 1 ��
[CPFPDlambda] = CPFPartialDerivativelambda(busNumber, PFResultBus, PQ, KL, KG);%�õ�P��lambda����
dimEk = length(CPFPDlambda) + 1;

LambdaMonitor = [LambdaMonitor; lambda];
VoltageMonitor = [VoltageMonitor; BusDataCPF(busMonitor, 7)];               % ���泱���Ľ�Ϊ PV ���ߵ���㣻

%% CPF ���㣻
fprintf('�����������㿪ʼ���۲�ĸ��Ϊ��bus %d\n', busMonitor);
tic;


%% 1. �� 1 �׶Σ� PV ���߽�Ϊƽ̹���� lambda ��Ϊ��������
h = 0.2;                                                                    % ������
for TIME = 1:1:CPFITERATIONMAX1
    Voltage = BusDataCPF(:, 7);                                             % ��ѹ��ֵ ��ʼֵ��
    Angle = BusDataCPF(:, 8);                                               % ��ѹ��� ��ʼֵ��
                                                                            
    % 1.1 ������������
    Ek = zeros(1, dimEk);   Ek(end) = 1;                                    % Jacobi ����Ĳ�����������ѡ�� lambda ����������ʱ�����һ���Ӧ�� lambda ��ֵΪ 1 ��
    X = zeros(dimEk, 1);   X(end) = 1;                                      % �ֲ���������ѡ�� lambda ����������ʱ�����һ���Ӧ�� lambda ��ֵΪ 1 ��
    [J0] = PFJacobian(busNumber, PQ, G, B, BusDataCPF, Voltage, Angle);     % ���ɳ��泱���� Jacobi ����
    Jaug = [J0, CPFPDlambda; Ek];                                           % ���� Jacobi ����
    TangentVector = (Jaug) \ X;                                             % ��� ��������
    
    % 1.2 ȷ����һ�ּ���ʱ�����������±��ţ�
    [continuationNext] = CPFChooseContinuationParamenter(busNumber, BusDataCPF, TangentVector);

    % 1.3 Ԥ�⣻
    [VoltageNextHat, AngleNextHat, lambdaNextHat] = ...                     % Ԥ�ⲽ�裬��� ��ѹ��ֵ �� ��ѹ��� �� lambda ��Ԥ��ֵ��
        CPFEstimate(busNumber, BusDataCPF, Voltage, Angle, TangentVector, lambda, h);

    LambdaPredictor(1) = lambda;        VoltagePredictor(1) = Voltage(busMonitor);       
    LambdaPredictor(2) = lambdaNextHat; VoltagePredictor(2) = VoltageNextHat(busMonitor);%������
    
    % ��ͼ������Ԥ�ⲽ��Ķ�Ӧ���ߣ�
    plot(LambdaPredictor, VoltagePredictor, 'bx--', 'LineWidth', 0.5);    hold on;            

    % 1.4 У����ţ��-����ѷ ����
    Voltage = VoltageNextHat;                                               % У�����裬���нڵ�� ��ѹ��ֵ ��ʼֵ��
    Angle = AngleNextHat;                                                   % У�����裬���нڵ�� ��ѹ��� ��ʼֵ��
    lambda = lambdaNextHat;                                                 % У�����裬lambda ��ʼֵ��

    for r = 1:1:PFITERATIONMAX
        [BusDataCPF, BranchDataCPF, GeneratorDataCPF] = ...                 % ���� lambda �����������ݣ�
        CPFRenewPower(busNumber, lambda, KG, KL, PV, BusDataPrimary, BranchDataPrimary, GeneratorDataPrimary);

        [busCPF, GenCPF, ~] = intersect(GeneratorDataCPF(:, 1), PV);        % �ҳ�������ı�ţ�
        BusPowerCPF = zeros(busNumber, 1);
        BusPowerCPF(busCPF) = GeneratorDataCPF(GenCPF, 2) / BASEMVA;
    
        [DeltaPQ] = PFMismatch(busNumber, G, B, Voltage, Angle, BusPowerCPF, BusDataCPF, PQ);
                                                                            % ���ɳ��泱���� ���ʲ�ƽ���� ������
        M = -lambdaNextHat + lambda;                                        % ���� ���㷽�� ��ƽ��ֵ��
        d_PQlambda = [DeltaPQ; M];                                         	% ���㲻ƽ��������
    
        [convergence] = PFJudgeConvergence(EPS, d_PQlambda);                % �ж��Ƿ���������������
        if convergence == 1                                                 % �����������ֹ������
            break;
        else                                                                % ���δ����������������      
        [J0] = PFJacobian(busNumber, PQ, G, B, BusDataCPF, Voltage, Angle); % ���泱���� Jacobi ����
        Ek = zeros(1, dimEk);   Ek(end) = 1;                                % Jacobi ����Ĳ�����������ѡ�� lambda ����������ʱ�����һ���Ӧ�� lambda ��ֵΪ 1 ��
        Jaug = [J0, CPFPDlambda; Ek];                                       % ���� Jacobi ����
        d_V_A_lambda = -inv(Jaug) * d_PQlambda;                             % ��ѹ��ֵ �� ��ѹ��� �� lambda ��ƫ������
        [Voltage, Angle, lambda] = ...                                      % ����ƫ���������� ��ѹ��ֵ �� ��ѹ��� �� lambda ��
            CPFRenewVlambda(busNumber, BusDataCPF, Voltage, Angle, lambda, d_V_A_lambda);
        end 
    end

    BusDataCPF(:, 7) = Voltage;                                             % ���ݼ������У��ֵ������ ��ѹ��ֵ��
    BusDataCPF(:, 8) = Angle;                                               % ���ݼ������У��ֵ������ ��ѹ��ǣ�
    LambdaMonitor = [LambdaMonitor; lambda];   
    VoltageMonitor = [VoltageMonitor; BusDataCPF(busMonitor, 7)];           % PV ���ߣ� lambda ���� �� VoltageMonitor ��ֵ������У��ֵ��

end
fprintf('PV ���ߵ� 1 �׶μ������...\n');
        
%% �� 2 �׶Σ��ٽ��ǵ㸽����ѡ�� ��ѹ��ֵ�仯�� ���Ĳ�����Ϊ����������
h = 0.01;
FLAG = 1;
for TIME = 1:1:50
    Voltage = BusDataCPF(:, 7);                                             % ��ѹ��ֵ ��ʼֵ��
    Angle = BusDataCPF(:, 8);                                               % ��ѹ��� ��ʼֵ��
    continuation = continuationNext;

    % 2.1 ������������
    Ek = zeros(1, dimEk);   Ek(continuation) = 1;                           % Jacobi ����Ĳ�����������ѡ�� xk ����������ʱ���� k ���ӦֵΪ 1 ��
    X = zeros(dimEk, 1);   X(end) = -1;                                     % �ֲ���������ѡ�� xk ����������ʱ�����һ���Ӧ�� xk ��ֵΪ -1 ����Ϊ��ѹ��ֵһֱ�ڽ��ͣ�
    [J0] = PFJacobian(busNumber, PQ, G, B, BusDataCPF, Voltage, Angle);     % ���ɳ��泱���� Jacobi ����
    Jaug = [J0, CPFPDlambda; Ek];                                           % ���� Jacobi ����
    TangentVector = (Jaug) \ X;                                             % ��� ��������

    if TangentVector(end) < 0 && FLAG == 1                                  % ��ʾ PV ����Խ���ǵ㣻
        fprintf('dlambda = %f\t�� PV �����Ѿ�Խ���ǵ�...\n', TangentVector(end));
        FLAG = 0;
    end
    
    % 2.2 ȷ����һ�ּ���ʱ�����������±��ţ�
    [continuationNext] = CPFChooseContinuationParamenter(busNumber, BusDataCPF, TangentVector);

    % 2.3 Ԥ�⣻
    [VoltageNextHat, AngleNextHat, lambdaNextHat] = ...                     % Ԥ�ⲽ�裬��� ��ѹ��ֵ �� ��ѹ��� �� lambda ��Ԥ��ֵ��
        CPFEstimate(busNumber, BusDataCPF, Voltage, Angle, TangentVector, lambda, h);

    LambdaPredictor(1) = lambda;        VoltagePredictor(1) = Voltage(busMonitor);       
    LambdaPredictor(2) = lambdaNextHat; VoltagePredictor(2) = VoltageNextHat(busMonitor);
    
    % ��ͼ������Ԥ�ⲽ��Ķ�Ӧ���ߣ�
    plot(LambdaPredictor, VoltagePredictor, 'bSquare --', 'LineWidth', 0.5);    hold on;            

    % 2.4 У����ţ��-����ѷ ����
    Voltage = VoltageNextHat;                                               % У�����裬���нڵ�� ��ѹ��ֵ ��ʼֵ��
    Angle = AngleNextHat;                                                   % У�����裬���нڵ�� ��ѹ��� ��ʼֵ��
    lambda = lambdaNextHat;                                                 % У�����裬lambda ��ʼֵ��

    for r = 1:1:PFITERATIONMAX
        [BusDataCPF, BranchDataCPF, GeneratorDataCPF] = ...                 % ���� lambda �����������ݣ�
        CPFRenewPower(busNumber, lambda, KG, KL, PV, BusDataPrimary, BranchDataPrimary, GeneratorDataPrimary);

        [busCPF, GenCPF, ~] = intersect(GeneratorDataCPF(:, 1), PV);        % �ҳ�������ı�ţ�
        BusPowerCPF = zeros(busNumber, 1);
        BusPowerCPF(busCPF) = GeneratorDataCPF(GenCPF, 2) / BASEMVA;
    
        [DeltaPQ] = PFMismatch(busNumber, G, B, Voltage, Angle, BusPowerCPF, BusDataCPF, PQ);
                                                                            % ���ɳ��泱���� ���ʲ�ƽ���� ������
        [M] = CPFAugmentedFunction(busNumber, dimEk, continuation, BusDataCPF, ...
            AngleNextHat, Angle, VoltageNextHat, Voltage);                  % ���� ���㷽�� ��ƽ��ֵ��
        d_PQlambda = [DeltaPQ; M];                                          % ���㲻ƽ��������
    
        [convergence] = PFJudgeConvergence(EPS, d_PQlambda);                % �ж��Ƿ���������������
        if convergence == 1                                                 % �����������ֹ������
            break;
        else                                                                % ���δ����������������      
        [J0] = PFJacobian(busNumber, PQ, G, B, BusDataCPF, Voltage, Angle); % ���泱���� Jacobi ����
        Ek = zeros(1, dimEk);   Ek(continuation) = 1;                       % Jacobi ����Ĳ�����������ѡ�� xk ����������ʱ���� k ���ӦֵΪ 1 ��
        Jaug = [J0, CPFPDlambda; Ek];                                       % ���� Jacobi ����
        d_V_A_lambda = -inv(Jaug) * d_PQlambda;                             % ��ѹ��ֵ �� ��ѹ��� �� lambda ��ƫ������
        [Voltage, Angle, lambda] = ...                                      % ����ƫ���������� ��ѹ��ֵ �� ��ѹ��� �� lambda ��
            CPFRenewVlambda(busNumber, BusDataCPF, Voltage, Angle, lambda, d_V_A_lambda);
        end 
    end

    BusDataCPF(:, 7) = Voltage;                                             % ���ݼ������У��ֵ������ ��ѹ��ֵ��
    BusDataCPF(:, 8) = Angle;                                               % ���ݼ������У��ֵ������ ��ѹ��ǣ�
    LambdaMonitor = [LambdaMonitor; lambda];   
    VoltageMonitor = [VoltageMonitor; BusDataCPF(busMonitor, 7)];           % PV ���ߣ� lambda ���� �� VoltageMonitor ��ֵ������У��ֵ��

end
fprintf('PV ���ߵ� 2 �׶μ������...\n');
time = toc;
%% ��Ϣ�������ͼ��
[lambdaMax, k] = max(LambdaMonitor);
CriticalX = [LambdaMonitor(k); LambdaMonitor(k)];
CriticalY = [0; VoltageMonitor(k)];

fprintf('CPF ������ϣ���ʱ %f s...\n', time);
fprintf('�ǵ㴦�� lambda = %f\n', lambdaMax);

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
