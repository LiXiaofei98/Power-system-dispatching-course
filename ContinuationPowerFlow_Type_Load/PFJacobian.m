% 计算雅可比矩阵 Jacobi ；
% 输入： busNumber, slack, G, B, E, F, BusData ；
% 返回： Jacobi ；
function [Jacobi] = PFJacobian(busNumber, PQ, G, B, BusData, Voltage, Angle)
    line = 1;
    sizeofJacobi = busNumber + length(PQ) - 1;
    Jacobi = zeros(sizeofJacobi, sizeofJacobi);
    
    for x = 1:1:busNumber
        if BusData(x, 2) == 1                                              % PQ 节点，包括 PQ-PQ 节点与 PQ-PV 节点；
           %% PQ 节点，P 对 delta 、 P 对 U 的偏导；
            column = 1;
            for y = 1:1:busNumber                                          
                if BusData(y, 2) == 1                                      % PQ 节点的 H, N 项；
                    if x == y                                              % PQ-PQ 节点的 Hii , Nii 项
                        tempPd = 0;
                        for m = 1:1:(x - 1)
                            tempPd = tempPd + Voltage(m) * (G(x, m) * sin(Angle(x) - Angle(m)) - B(x, m) * cos(Angle(x) - Angle(m)));
                        end
                        for m = (x + 1):1:busNumber
                            tempPd = tempPd + Voltage(m) * (G(x, m) * sin(Angle(x) - Angle(m)) - B(x, m) * cos(Angle(x) - Angle(m)));
                        end
                        Jacobi(line, column) = Voltage(x) * tempPd;        
                        column = column + 1;                               % PQ-PQ 节点的 Hii 项；
                        
                        tempPU = 0;
                        for m = 1:1:(x - 1)
                            tempPU = tempPU + Voltage(m) * (G(x, m) * cos(Angle(x) - Angle(m)) + B(x, m) * sin(Angle(x) - Angle(m)));
                        end
                        for m = (x + 1):1:busNumber
                            tempPU = tempPU + Voltage(m) * (G(x, m) * cos(Angle(x) - Angle(m)) + B(x, m) * sin(Angle(x) - Angle(m)));
                        end
                        Jacobi(line, column) = -tempPU - 2 * Voltage(x) * G(x, x);
                        column = column + 1;                               % PQ-PQ 节点的 Nii 项；
                        
                    else                                                   % PQ-PQ 节点的 Hij, Nij 项；
                        Jacobi(line, column) = -Voltage(x) * Voltage(y) * (G(x, y) * sin(Angle(x) - Angle(y)) - B(x, y) * cos(Angle(x) - Angle(y)));
                        column = column + 1;                               % PQ-PQ 节点的 Hij 项；
                        Jacobi(line, column) = -Voltage(x) * (G(x, y) * cos(Angle(x) - Angle(y)) + B(x, y) * sin(Angle(x) - Angle(y)));
                        column = column + 1;                               % PQ-PQ 节点的 Nij 项；
                    end
                else                                            
                    if BusData(y, 2) == 2                                  % PQ-PV 节点仅有 Hij 项； 
                        Jacobi(line, column) = -Voltage(x) * Voltage(y) * (G(x, y) * sin(Angle(x) - Angle(y)) - B(x, y) * cos(Angle(x) - Angle(y)));
                        column = column + 1;                               % PQ-PV 节点的 Hij 项；
                    end
                end
            end
            line = line + 1;
            
           %% PQ 节点，Q 对 delta 、 Q 对 U 的偏导；
            column = 1;
            for y = 1:1:busNumber                                          
                if BusData(y, 2) == 1                                      % PQ 节点的 J, L 项；
                    if x == y                                              % PQ-PQ 节点的 Jii , Lii 项
                        tempQd = 0;
                        for m = 1:1:(x - 1)
                            tempQd = tempQd + Voltage(m) * (G(x, m) * cos(Angle(x) - Angle(m)) + B(x, m) * sin(Angle(x) - Angle(m)));
                        end
                        for m = (x + 1):1:busNumber
                            tempQd = tempQd + Voltage(m) * (G(x, m) * cos(Angle(x) - Angle(m)) + B(x, m) * sin(Angle(x) - Angle(m)));
                        end
                        Jacobi(line, column) = -Voltage(x) * tempQd;       % PQ-PQ 节点的 Jii 项；
                        column = column + 1;
                        
                        tempQU = 0;
                        for m = 1:1:(x - 1)
                            tempQU = tempQU + Voltage(m) * (G(x, m) * sin(Angle(x) - Angle(m)) - B(x, m) * cos(Angle(x) - Angle(m)));
                        end
                        for m = (x + 1):1:busNumber
                            tempQU = tempQU + Voltage(m) * (G(x, m) * sin(Angle(x) - Angle(m)) - B(x, m) * cos(Angle(x) - Angle(m)));
                        end
                        Jacobi(line, column) = -tempQU + 2 * Voltage(x) * B(x, x);
                                                                           % PQ-PQ 节点的 Lii 项；
                        column = column + 1;
                    else                                                   % PQ-PQ 节点的 Jij, Lij 项；
                        Jacobi(line, column) = Voltage(x) * Voltage(y) * (G(x, y) * cos(Angle(x) - Angle(y)) + B(x, y) * sin(Angle(x) - Angle(y)));
                        column = column + 1;                               % PQ-PQ 节点的 Jij 项；
                        Jacobi(line, column) = -Voltage(x) * (G(x, y) * sin(Angle(x) - Angle(y)) - B(x, y) * cos(Angle(x) - Angle(y)));
                        column = column + 1;                               % PQ-PQ 节点的 Lij 项；
                    end
                else
                    if BusData(y, 2) == 2                                  % PQ-PV 节点仅有 Jij 项；
                        Jacobi(line, column) = Voltage(x) * Voltage(y) * (G(x, y) * cos(Angle(x) - Angle(y)) + B(x, y) * sin(Angle(x) - Angle(y)));
                        column = column + 1;                               % PQ-PV 节点的 Jij 项；
                    end
                end 
            end
            line = line + 1;
            
        else                                                               
            if BusData(x, 2) == 2                                          % PV 节点，包括 PV-PQ 节点与 PV-PV 节点；
              %% PV 节点，P 对 delta 、 P 对 U 的偏导；
                column = 1;
                for y = 1:1:busNumber   
                    if BusData(y, 2) == 1                                  % PV 节点的 Hij, Nij 项；
                        Jacobi(line, column) = -Voltage(x) * Voltage(y) * (G(x, y) * sin(Angle(x) - Angle(y)) - B(x, y) * cos(Angle(x) - Angle(y)));
                        column = column + 1;                               % PV-PQ 节点的 Hij 项；
                        Jacobi(line, column) = -Voltage(x) * (G(x, y) * cos(Angle(x) - Angle(y)) + B(x, y) * sin(Angle(x) - Angle(y)));
                        column = column + 1;                               % PV-PQ 节点的 Nij 项；
                    else                                                   
                        if BusData(y, 2) == 2                              % PV 节点的 H 项；
                            if x == y                                      % PV-PV 节点的 Hii 项；
                                tempPd = 0;
                                for m = 1:1:(x - 1)
                                    tempPd = tempPd + Voltage(m) * (G(x, m) * sin(Angle(x) - Angle(m)) - B(x, m) * cos(Angle(x) - Angle(m)));
                                end
                                for m = (x + 1):1:busNumber
                                    tempPd = tempPd + Voltage(m) * (G(x, m) * sin(Angle(x) - Angle(m)) - B(x, m) * cos(Angle(x) - Angle(m)));
                                end
                                Jacobi(line, column) = Voltage(x) * tempPd;        
                                column = column + 1;                       % PV-PV 节点的 Hii 项；
                            else                                           % PV-PV 节点的 Hij 项；
                                Jacobi(line, column) = -Voltage(x) * Voltage(y) * (G(x, y) * sin(Angle(x) - Angle(y)) - B(x, y) * cos(Angle(x) - Angle(y)));
                                column = column + 1;                       % PV-PV 节点的 Hij 项；
                            end
                        end
                    end
                end
                line = line + 1;
            end
        end
    end                                            
return