%% h 为预估步长；
function [VoltageNextHat, AngleNextHat, lambdaNextHat] = CPFEstimate(busNumber, BusDataCPF, Voltage, Angle, TangentVector, lambda, h)
   t = 1;
   VoltageNextHat = Voltage;
   AngleNextHat = Angle;
   for x = 1:1:busNumber
       if BusDataCPF(x, 2) == 1                                            	% PQ 节点，包含 电压幅值 预估值、电压相角 预估值；
           AngleNextHat(x) = Angle(x) + h * TangentVector(t);         
           t = t + 1;
           VoltageNextHat(x) = Voltage(x) + h * TangentVector(t);     
           t = t + 1;
       else
           if BusDataCPF(x, 2) == 2                                         % PV 节点，包含 电压相角 预估值；
               AngleNextHat(x) = Angle(x) + h * TangentVector(t);     
               t = t + 1;
           end
       end
   end
   lambdaNextHat = lambda + h * TangentVector(end);
return