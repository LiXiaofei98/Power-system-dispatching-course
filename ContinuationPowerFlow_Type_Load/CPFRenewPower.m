%% ����ָ���ĸ���������ʽ �Լ� lambda ��ֵ�����½ڵ� i ��Ӧ�ķ���������ɵ��й����ʡ��޹����ʣ�
%% ����ѡ��ȫ�����ɵȱ���������
%% BusDataPrimary ��ʽ��
% 1           2         3            4               5            6              7                  8         9              10                  11
% Bus_i      Type       P_load(MW)   Q_load(MVar)    G_parallel   B_parallel     V_amplitude(p.u.)  V_angle   V_base         V_amplitude_max     V_amplitude_min
% �ڵ���    �ڵ�����   �й�����(MW)  �޹�����(MVar)  �����絼(MW)  ��������(MVar)  ��ѹ��ֵ(����ֵ)   ��ѹ�Ƕ�   ��ѹ��׼ֵ(kV)  ��ѹ����ֵ(����ֵ) ��ѹ��С��ֵ(����ֵ)
% ���У��ڵ����ͣ�1-PQ; 2-PV;3-Balance;

%% GeneratorDataPrimary ��ʽ��
% 1           2             3              4                  5                  6                    7                 8           9               10                 
% Bus_i       P_gen(MW)     Q_gen(MVar)   Q_gen_max(MVar)     Q_gen_min(MVar)    V_gen                S_base            Statue      P_gen_max(MW)   P_gen_min(MW)     
% �ڵ���    �й����(MW)   �޹����(MVar)  ����޹����(MVar)  ��С�޹����(MVar) ��ѹ��ֵ�趨(����ֵ)   ��������ڹ���     �����״̬  ����й����(MW) ��С�й����(MW)
% ���У������״̬��1-���У� 2-ͣ�ˣ�
function [BusDataCPF, BranchDataCPF, GeneratorDataCPF] = ...
    CPFRenewPower(busNumber, lambda, KG, KL, PV, BusDataPrimary, BranchDataPrimary, GeneratorDataPrimary)
    % 1. ��ʼ�� ĸ������ ��·���� ��������ݣ�
    BusDataCPF = BusDataPrimary;
    BranchDataCPF = BranchDataPrimary;
    GeneratorDataCPF = GeneratorDataPrimary;
    
    % 2. ���� lambda �� KL ��ֵ������ÿ��ĸ�ߵ��й����ɡ��޹����ɣ�
    for x = 1:1:busNumber
        BusDataCPF(x, 3) = (1 + lambda * KL(x)) * BusDataPrimary(x, 3);     % �����й�����������
        BusDataCPF(x, 4) = (1 + lambda * KL(x)) * BusDataPrimary(x, 4);     % �����޹�����������
    end
    
    % 2. ���� lambda �� KG ��ֵ������ÿ̨��������й������
    % GenBus �������ĸ���������е� �ڵ��ţ�
    [GenBus, ~, ~] = intersect(GeneratorDataPrimary(:, 1), PV);             % �ҳ� ������ı�ţ�

    for x = 1:1:length(GeneratorDataCPF(:, 1))
        for y = 1:1:length(GenBus)
            if GeneratorDataCPF(x, 1) == GenBus(y)
                GeneratorDataCPF(x, 2) = ...
                    (1 + lambda * KG(GenBus(y))) * GeneratorDataCPF(x, 2);	% ���������й�����������
            end
        end
    end
return