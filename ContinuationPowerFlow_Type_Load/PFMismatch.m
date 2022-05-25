%% 计算 功率不平衡量 电压不平衡量：ΔP、ΔQ ；
%% 输入： busNumber, generatorNumber, G, B, Voltage, delta, busData, generatorData, baseMVA ；
%% 返回： DeltaPQ 不平衡量；
%% 这里默认 PQ 节点都是纯负荷节点，即没有发电机挂在 PQ 节点上！！
%% 遇到 PV 节点向 PQ 节点转移时，或者 PQ 节点上装有发电机时，需要对 PQ 节点的功率进行修正，此文件要进行修改！！
function [DeltaPQ] = PFMismatch(busNumber, G, B, Voltage, angle, BusPower, BusData, PQ)
   
   global BASEMVA;                                                          % 全局变量，基准功率；

   t = 1;
   DeltaPQ = zeros(1, busNumber + length(PQ) - 1);
   for x = 1:1:busNumber
       if BusData(x, 2) == 1
           tempP = 0;   tempQ = 0;
           for y = 1:1:busNumber
               deltaij = angle(x) - angle(y);
               tempP = tempP + Voltage(y) * (G(x, y) * cos(deltaij) + B(x, y) * sin(deltaij));
               tempQ = tempQ + Voltage(y) * (G(x, y) * sin(deltaij) - B(x, y) * cos(deltaij));
           end
           tempP = tempP * Voltage(x);
           tempQ = tempQ * Voltage(x);
           DeltaPQ(t) = 0 - BusData(x, 3) / BASEMVA - tempP;	 t = t + 1;
           DeltaPQ(t) = 0 - BusData(x, 4) / BASEMVA - tempQ; 	 t = t + 1;
       else
           if BusData(x, 2) == 2
               tempP = 0;
               for y = 1:1:busNumber
                   deltaij = angle(x) - angle(y);
                   tempP = tempP + Voltage(y) * (G(x, y) * cos(deltaij) + B(x, y) * sin(deltaij));
               end
               tempP = tempP * Voltage(x);
               DeltaPQ(t) = BusPower(x) - BusData(x, 3) / BASEMVA - tempP;      t = t + 1;
           end
       end
   end
   DeltaPQ = DeltaPQ';
   
return 