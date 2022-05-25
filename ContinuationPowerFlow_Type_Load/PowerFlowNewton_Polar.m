% ���ü�������ʽ��ţ��-����ѷ��������
% Matlab �����Ǻ������õ��ǣ������ƣ�
% �޸ľ����Ԫ���±�󣬸ó�����Ըı�Ϊ��C/C# �ȣ�
% ���������󡢸��������� ��������ĸ��д��һ�����ͱ��� ��������ĸСд���궨�� ����ȫ��д��

function [BusPower, ResultBus, ResultBranch, S_slack, Ploss, Qloss, counter] = ...
    PowerFlowNewton_Polar(baseMVA, Y, G, B, Y0, busNumber, lineNumber, PQ, PV, BusData, BranchData, GeneratorData)   
    global EPS;                                                                % ȫ�ֱ��������������ж�������
    global PI;                                                                 % ȫ�ֱ�����Բ���ʣ�
    global PFITERATIONMAX;                                                     % ȫ�ֱ�����������������
    global BASEMVA;                                                            % ȫ�ֱ�������׼���ʣ�
    
    %% ��ȡ��ѹ��ʼֵ�� Voltage, delta��
    Voltage = BusData(:, 7);                                                   % ���нڵ�ĵ�ѹ��ֵ�����������ã���
    Angle = BusData(:, 8) .* PI / 180;                                         % ���нڵ�ĵ�ѹ��ǻ���ֵ�����������ã���

    %% ���������
    [bus, Gen, ~] = intersect(GeneratorData(:, 1), PV);                        % �ҳ� ������ı�ţ�
    BusPower = zeros(busNumber, 1);
    BusPower(bus) = GeneratorData(Gen, 2) / BASEMVA;

    counter = 1;                                                               % ѭ��������
    for r = 1:1:PFITERATIONMAX
        [DeltaPQ] = PFMismatch(busNumber, G, B, Voltage, Angle, BusPower, BusData, PQ);
                                                                               % ���� ���ʲ�ƽ���� ������
        [convergence] = PFJudgeConvergence(EPS, DeltaPQ);                      % �ж��Ƿ���������������

        if convergence == 1                                                    % �����������ֹ������
            counter = r - 1;
            break;
        else                                                                   % ���δ����������������            
            [Jacobi] = ...
                PFJacobian(busNumber, PQ, G, B, BusData, Voltage, Angle);      % ���� Jacobi ����
            DeltaV = -inv(Jacobi) * DeltaPQ;                                   % ��ƽ��ڵ��⣬���нڵ��ѹ��ƫ��������������ʹ�ã���
            [Voltage, Angle] = ...
                PFRenewV(busNumber, BusData, Voltage, Angle, DeltaV);          % ���½ڵ��ѹ��
        end 
    end
    [ResultBus, ResultBranch, S_slack, Ploss, Qloss] = ...
        PFResults(busNumber, lineNumber, BusData, BranchData, Y, G, B, Y0, Voltage, Angle, baseMVA);
return