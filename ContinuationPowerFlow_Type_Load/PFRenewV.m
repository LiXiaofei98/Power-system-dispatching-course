%% ���¸�ĸ�ߵ�ѹ��
%% ���룺 busNumber, slack, Voltage, angle, DeltaV ��
%% ���أ� Voltage, angle��
function [Voltage, Angle] = PFRenewV(busNumber, BusData, Voltage, Angle, DeltaV)
   t = 1;
   for x = 1:1:busNumber
       if BusData(x, 2) == 1
           Angle(x) = Angle(x) + DeltaV(t);                      t = t + 1;
           Voltage(x) = Voltage(x) + DeltaV(t);                  t = t + 1;
       else
           if BusData(x, 2) == 2
               Angle(x) = Angle(x) + DeltaV(t);                  t = t + 1;
           end
       end
   end
return