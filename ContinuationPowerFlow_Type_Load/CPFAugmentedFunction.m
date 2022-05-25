function [M] = CPFAugmentedFunction(busNumber, dimEk, continuation, BusDataCPF, AngleNextHat, Angle, VoltageNextHat, Voltage)
    t = 1;
    V_Delta_lambda = zeros(dimEk - 1, 1);
    V_Delta_lambdaNextHat = zeros(dimEk - 1, 1);
    for x = 1:1:busNumber
        if BusDataCPF(x, 2) == 1     
            % PQ 节点，包含 电压幅值 预估值与当前计算值、电压相角 预估值与当前计算值；
            V_Delta_lambda(t) = Angle(x);
            V_Delta_lambdaNextHat(t) = AngleNextHat(x);         
            t = t + 1;
            V_Delta_lambda(t) = Voltage(x);
            V_Delta_lambdaNextHat(t) = VoltageNextHat(x);       
            t = t + 1;
        else
            if BusDataCPF(x, 2) == 2  
                % PV 节点，包含 电压相角 预估值与当前计算值；
                V_Delta_lambda(t) = Angle(x);
                V_Delta_lambdaNextHat(t) = AngleNextHat(x);     
                t = t + 1;    
            end
        end
    end
%     V_Delta_lambda(end) = lambda;
%     V_Delta_lambdaNextHat(end) = lambdaNextHat;
    M = -V_Delta_lambdaNextHat(continuation) + V_Delta_lambda(continuation);
return