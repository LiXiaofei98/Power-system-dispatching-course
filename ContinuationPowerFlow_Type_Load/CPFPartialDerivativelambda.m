%% 根据指定的负荷增长方式，确定扩展潮流方程对 lambda 的偏导数；
%% 这里选择全网负荷等比例增长；
%% 输入参数，常规潮流计算， 母线结果；
    % 1        2       3           4             5               6               7                          8
    % 节点编号 节点类型 节点电压幅值 节点电压相角度 节点注入有功功率 节点注入无功功率 节点输出有功功率（负荷有功） 节点输出无功功率（负荷无功）
%% 扩展潮流方程对 lambda 的偏导数；
%% 这里默认 PQ 节点都是纯负荷节点，即没有发电机挂在 PQ 节点上！！
%% 遇到 PV 节点向 PQ 节点转移时，此文件要进行修改 KG 向量！！
function [CPFPDlambda] = CPFPartialDerivativelambda(busNumber, PFResultBus, PQ, KL, KG)
    global BASEMVA;                                                         % 全局变量，基准功率；

    t = 1;
    CPFPDlambda = zeros((busNumber + length(PQ) - 1), 1);
    
    for x = 1:1:busNumber
        if PFResultBus(x, 2) == 1
            PG0i = PFResultBus(x, 5);
            KGi = KG(x);
            PL0i = PFResultBus(x, 7);
            QL0i = PFResultBus(x, 8);
            KLi = KL(x);
            
            CPFPDlambda(t) = (PG0i * KGi - PL0i * KLi) / BASEMVA;           % PQ 节点， P 对 lambda 求偏导；
            t = t + 1;
            CPFPDlambda(t) = (0 - QL0i * KLi) / BASEMVA;                    % PQ 节点， Q 对 lambda 求偏导；
            t = t + 1;
        else
            if PFResultBus(x, 2) == 2
                PG0i = PFResultBus(x, 5);
                KGi = KG(x);
                PL0i = PFResultBus(x, 7);
                KLi = KL(x);
                
                CPFPDlambda(t) = (PG0i * KGi - PL0i * KLi) / BASEMVA;       % PV 节点， P 对 lambda 求偏导；
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