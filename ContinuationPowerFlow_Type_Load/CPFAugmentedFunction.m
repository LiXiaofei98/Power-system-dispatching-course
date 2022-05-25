function [M] = CPFAugmentedFunction(busNumber, dimEk, continuation, BusDataCPF, AngleNextHat, Angle, VoltageNextHat, Voltage)
    t = 1;
    V_Delta_lambda = zeros(dimEk - 1, 1);
    V_Delta_lambdaNextHat = zeros(dimEk - 1, 1);
    for x = 1:1:busNumber
        if BusDataCPF(x, 2) == 1     
            % PQ �ڵ㣬���� ��ѹ��ֵ Ԥ��ֵ�뵱ǰ����ֵ����ѹ��� Ԥ��ֵ�뵱ǰ����ֵ��
            V_Delta_lambda(t) = Angle(x);
            V_Delta_lambdaNextHat(t) = AngleNextHat(x);         
            t = t + 1;
            V_Delta_lambda(t) = Voltage(x);
            V_Delta_lambdaNextHat(t) = VoltageNextHat(x);       
            t = t + 1;
        else
            if BusDataCPF(x, 2) == 2  
                % PV �ڵ㣬���� ��ѹ��� Ԥ��ֵ�뵱ǰ����ֵ��
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