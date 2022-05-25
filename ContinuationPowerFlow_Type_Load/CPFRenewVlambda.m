%% 更新各母线电压；
%% 输入： busNumber, slack, Voltage, angle, DeltaV ；
%% 返回： Voltage, angle；
function [Voltage, Angle, lambda] = CPFRenewVlambda(busNumber, BusDataCPF, Voltage, Angle, lambda, d_V_A_lambda)
   t = 1;
   for x = 1:1:busNumber
       if BusDataCPF(x, 2) == 1
           Angle(x) = Angle(x) + d_V_A_lambda(t);                      t = t + 1;
           Voltage(x) = Voltage(x) + d_V_A_lambda(t);                  t = t + 1;
       else
           if BusDataCPF(x, 2) == 2
               Angle(x) = Angle(x) + d_V_A_lambda(t);                  t = t + 1;
           end
       end
   end
   lambda = lambda + d_V_A_lambda(end);
return