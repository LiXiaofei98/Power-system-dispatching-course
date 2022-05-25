%% h ΪԤ��������
function [VoltageNextHat, AngleNextHat, lambdaNextHat] = CPFEstimate(busNumber, BusDataCPF, Voltage, Angle, TangentVector, lambda, h)
   t = 1;
   VoltageNextHat = Voltage;
   AngleNextHat = Angle;
   for x = 1:1:busNumber
       if BusDataCPF(x, 2) == 1                                            	% PQ �ڵ㣬���� ��ѹ��ֵ Ԥ��ֵ����ѹ��� Ԥ��ֵ��
           AngleNextHat(x) = Angle(x) + h * TangentVector(t);         
           t = t + 1;
           VoltageNextHat(x) = Voltage(x) + h * TangentVector(t);     
           t = t + 1;
       else
           if BusDataCPF(x, 2) == 2                                         % PV �ڵ㣬���� ��ѹ��� Ԥ��ֵ��
               AngleNextHat(x) = Angle(x) + h * TangentVector(t);     
               t = t + 1;
           end
       end
   end
   lambdaNextHat = lambda + h * TangentVector(end);
return