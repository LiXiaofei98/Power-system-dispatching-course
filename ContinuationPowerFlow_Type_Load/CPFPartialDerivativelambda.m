%% ����ָ���ĸ���������ʽ��ȷ����չ�������̶� lambda ��ƫ������
%% ����ѡ��ȫ�����ɵȱ���������
%% ������������泱�����㣬 ĸ�߽����
    % 1        2       3           4             5               6               7                          8
    % �ڵ��� �ڵ����� �ڵ��ѹ��ֵ �ڵ��ѹ��Ƕ� �ڵ�ע���й����� �ڵ�ע���޹����� �ڵ�����й����ʣ������й��� �ڵ�����޹����ʣ������޹���
%% ��չ�������̶� lambda ��ƫ������
%% ����Ĭ�� PQ �ڵ㶼�Ǵ����ɽڵ㣬��û�з�������� PQ �ڵ��ϣ���
%% ���� PV �ڵ��� PQ �ڵ�ת��ʱ�����ļ�Ҫ�����޸� KG ��������
function [CPFPDlambda] = CPFPartialDerivativelambda(busNumber, PFResultBus, PQ, KL, KG)
    global BASEMVA;                                                         % ȫ�ֱ�������׼���ʣ�

    t = 1;
    CPFPDlambda = zeros((busNumber + length(PQ) - 1), 1);
    
    for x = 1:1:busNumber
        if PFResultBus(x, 2) == 1
            PG0i = PFResultBus(x, 5);
            KGi = KG(x);
            PL0i = PFResultBus(x, 7);
            QL0i = PFResultBus(x, 8);
            KLi = KL(x);
            
            CPFPDlambda(t) = (PG0i * KGi - PL0i * KLi) / BASEMVA;           % PQ �ڵ㣬 P �� lambda ��ƫ����
            t = t + 1;
            CPFPDlambda(t) = (0 - QL0i * KLi) / BASEMVA;                    % PQ �ڵ㣬 Q �� lambda ��ƫ����
            t = t + 1;
        else
            if PFResultBus(x, 2) == 2
                PG0i = PFResultBus(x, 5);
                KGi = KG(x);
                PL0i = PFResultBus(x, 7);
                KLi = KL(x);
                
                CPFPDlambda(t) = (PG0i * KGi - PL0i * KLi) / BASEMVA;       % PV �ڵ㣬 P �� lambda ��ƫ����
                t = t + 1;
            end
        end
    end
    
%     DeltaPQ = zeros(1, busNumber + length(PQ) - 1);
%     for x = 1:1:busNumber
%        if BusData(x, 2) == 1
%            tempP = 0;   tempQ = 0;
%            for y = 1:1:busNumber
%                deltaij = angle(x) - angle(y);
%                tempP = tempP + Voltage(y) * (G(x, y) * cos(deltaij) + B(x, y) * sin(deltaij));
%                tempQ = tempQ + Voltage(y) * (G(x, y) * sin(deltaij) - B(x, y) * cos(deltaij));
%            end
%            tempP = tempP * Voltage(x);
%            tempQ = tempQ * Voltage(x);
%            CPFPDlambda(t) = 0 - BusData(x, 3) / BASEMVA - tempP;	 t = t + 1;
%            CPFPDlambda(t) = 0 - BusData(x, 4) / BASEMVA - tempQ; 	 t = t + 1;
%        else
%            if BusData(x, 2) == 2
%                tempP = 0;
%                for y = 1:1:busNumber
%                    deltaij = angle(x) - angle(y);
%                    tempP = tempP + Voltage(y) * (G(x, y) * cos(deltaij) + B(x, y) * sin(deltaij));
%                end
%                tempP = tempP * Voltage(x);
%                DeltaPQ(t) = BusPower(x) - BusData(x, 3) / baseMVA - tempP;      t = t + 1;
%            end
%        end
%    end
return 