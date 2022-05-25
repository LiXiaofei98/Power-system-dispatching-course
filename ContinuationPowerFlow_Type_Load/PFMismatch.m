%% ���� ���ʲ�ƽ���� ��ѹ��ƽ��������P����Q ��
%% ���룺 busNumber, generatorNumber, G, B, Voltage, delta, busData, generatorData, baseMVA ��
%% ���أ� DeltaPQ ��ƽ������
%% ����Ĭ�� PQ �ڵ㶼�Ǵ����ɽڵ㣬��û�з�������� PQ �ڵ��ϣ���
%% ���� PV �ڵ��� PQ �ڵ�ת��ʱ������ PQ �ڵ���װ�з����ʱ����Ҫ�� PQ �ڵ�Ĺ��ʽ������������ļ�Ҫ�����޸ģ���
function [DeltaPQ] = PFMismatch(busNumber, G, B, Voltage, angle, BusPower, BusData, PQ)
   
   global BASEMVA;                                                          % ȫ�ֱ�������׼���ʣ�

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