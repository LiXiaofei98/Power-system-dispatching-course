% �����ſɱȾ��� Jacobi ��
% ���룺 busNumber, slack, G, B, E, F, BusData ��
% ���أ� Jacobi ��
function [Jacobi] = PFJacobian(busNumber, PQ, G, B, BusData, Voltage, Angle)
    line = 1;
    sizeofJacobi = busNumber + length(PQ) - 1;
    Jacobi = zeros(sizeofJacobi, sizeofJacobi);
    
    for x = 1:1:busNumber
        if BusData(x, 2) == 1                                              % PQ �ڵ㣬���� PQ-PQ �ڵ��� PQ-PV �ڵ㣻
           %% PQ �ڵ㣬P �� delta �� P �� U ��ƫ����
            column = 1;
            for y = 1:1:busNumber                                          
                if BusData(y, 2) == 1                                      % PQ �ڵ�� H, N �
                    if x == y                                              % PQ-PQ �ڵ�� Hii , Nii ��
                        tempPd = 0;
                        for m = 1:1:(x - 1)
                            tempPd = tempPd + Voltage(m) * (G(x, m) * sin(Angle(x) - Angle(m)) - B(x, m) * cos(Angle(x) - Angle(m)));
                        end
                        for m = (x + 1):1:busNumber
                            tempPd = tempPd + Voltage(m) * (G(x, m) * sin(Angle(x) - Angle(m)) - B(x, m) * cos(Angle(x) - Angle(m)));
                        end
                        Jacobi(line, column) = Voltage(x) * tempPd;        
                        column = column + 1;                               % PQ-PQ �ڵ�� Hii �
                        
                        tempPU = 0;
                        for m = 1:1:(x - 1)
                            tempPU = tempPU + Voltage(m) * (G(x, m) * cos(Angle(x) - Angle(m)) + B(x, m) * sin(Angle(x) - Angle(m)));
                        end
                        for m = (x + 1):1:busNumber
                            tempPU = tempPU + Voltage(m) * (G(x, m) * cos(Angle(x) - Angle(m)) + B(x, m) * sin(Angle(x) - Angle(m)));
                        end
                        Jacobi(line, column) = -tempPU - 2 * Voltage(x) * G(x, x);
                        column = column + 1;                               % PQ-PQ �ڵ�� Nii �
                        
                    else                                                   % PQ-PQ �ڵ�� Hij, Nij �
                        Jacobi(line, column) = -Voltage(x) * Voltage(y) * (G(x, y) * sin(Angle(x) - Angle(y)) - B(x, y) * cos(Angle(x) - Angle(y)));
                        column = column + 1;                               % PQ-PQ �ڵ�� Hij �
                        Jacobi(line, column) = -Voltage(x) * (G(x, y) * cos(Angle(x) - Angle(y)) + B(x, y) * sin(Angle(x) - Angle(y)));
                        column = column + 1;                               % PQ-PQ �ڵ�� Nij �
                    end
                else                                            
                    if BusData(y, 2) == 2                                  % PQ-PV �ڵ���� Hij � 
                        Jacobi(line, column) = -Voltage(x) * Voltage(y) * (G(x, y) * sin(Angle(x) - Angle(y)) - B(x, y) * cos(Angle(x) - Angle(y)));
                        column = column + 1;                               % PQ-PV �ڵ�� Hij �
                    end
                end
            end
            line = line + 1;
            
           %% PQ �ڵ㣬Q �� delta �� Q �� U ��ƫ����
            column = 1;
            for y = 1:1:busNumber                                          
                if BusData(y, 2) == 1                                      % PQ �ڵ�� J, L �
                    if x == y                                              % PQ-PQ �ڵ�� Jii , Lii ��
                        tempQd = 0;
                        for m = 1:1:(x - 1)
                            tempQd = tempQd + Voltage(m) * (G(x, m) * cos(Angle(x) - Angle(m)) + B(x, m) * sin(Angle(x) - Angle(m)));
                        end
                        for m = (x + 1):1:busNumber
                            tempQd = tempQd + Voltage(m) * (G(x, m) * cos(Angle(x) - Angle(m)) + B(x, m) * sin(Angle(x) - Angle(m)));
                        end
                        Jacobi(line, column) = -Voltage(x) * tempQd;       % PQ-PQ �ڵ�� Jii �
                        column = column + 1;
                        
                        tempQU = 0;
                        for m = 1:1:(x - 1)
                            tempQU = tempQU + Voltage(m) * (G(x, m) * sin(Angle(x) - Angle(m)) - B(x, m) * cos(Angle(x) - Angle(m)));
                        end
                        for m = (x + 1):1:busNumber
                            tempQU = tempQU + Voltage(m) * (G(x, m) * sin(Angle(x) - Angle(m)) - B(x, m) * cos(Angle(x) - Angle(m)));
                        end
                        Jacobi(line, column) = -tempQU + 2 * Voltage(x) * B(x, x);
                                                                           % PQ-PQ �ڵ�� Lii �
                        column = column + 1;
                    else                                                   % PQ-PQ �ڵ�� Jij, Lij �
                        Jacobi(line, column) = Voltage(x) * Voltage(y) * (G(x, y) * cos(Angle(x) - Angle(y)) + B(x, y) * sin(Angle(x) - Angle(y)));
                        column = column + 1;                               % PQ-PQ �ڵ�� Jij �
                        Jacobi(line, column) = -Voltage(x) * (G(x, y) * sin(Angle(x) - Angle(y)) - B(x, y) * cos(Angle(x) - Angle(y)));
                        column = column + 1;                               % PQ-PQ �ڵ�� Lij �
                    end
                else
                    if BusData(y, 2) == 2                                  % PQ-PV �ڵ���� Jij �
                        Jacobi(line, column) = Voltage(x) * Voltage(y) * (G(x, y) * cos(Angle(x) - Angle(y)) + B(x, y) * sin(Angle(x) - Angle(y)));
                        column = column + 1;                               % PQ-PV �ڵ�� Jij �
                    end
                end 
            end
            line = line + 1;
            
        else                                                               
            if BusData(x, 2) == 2                                          % PV �ڵ㣬���� PV-PQ �ڵ��� PV-PV �ڵ㣻
              %% PV �ڵ㣬P �� delta �� P �� U ��ƫ����
                column = 1;
                for y = 1:1:busNumber   
                    if BusData(y, 2) == 1                                  % PV �ڵ�� Hij, Nij �
                        Jacobi(line, column) = -Voltage(x) * Voltage(y) * (G(x, y) * sin(Angle(x) - Angle(y)) - B(x, y) * cos(Angle(x) - Angle(y)));
                        column = column + 1;                               % PV-PQ �ڵ�� Hij �
                        Jacobi(line, column) = -Voltage(x) * (G(x, y) * cos(Angle(x) - Angle(y)) + B(x, y) * sin(Angle(x) - Angle(y)));
                        column = column + 1;                               % PV-PQ �ڵ�� Nij �
                    else                                                   
                        if BusData(y, 2) == 2                              % PV �ڵ�� H �
                            if x == y                                      % PV-PV �ڵ�� Hii �
                                tempPd = 0;
                                for m = 1:1:(x - 1)
                                    tempPd = tempPd + Voltage(m) * (G(x, m) * sin(Angle(x) - Angle(m)) - B(x, m) * cos(Angle(x) - Angle(m)));
                                end
                                for m = (x + 1):1:busNumber
                                    tempPd = tempPd + Voltage(m) * (G(x, m) * sin(Angle(x) - Angle(m)) - B(x, m) * cos(Angle(x) - Angle(m)));
                                end
                                Jacobi(line, column) = Voltage(x) * tempPd;        
                                column = column + 1;                       % PV-PV �ڵ�� Hii �
                            else                                           % PV-PV �ڵ�� Hij �
                                Jacobi(line, column) = -Voltage(x) * Voltage(y) * (G(x, y) * sin(Angle(x) - Angle(y)) - B(x, y) * cos(Angle(x) - Angle(y)));
                                column = column + 1;                       % PV-PV �ڵ�� Hij �
                            end
                        end
                    end
                end
                line = line + 1;
            end
        end
    end                                            
return