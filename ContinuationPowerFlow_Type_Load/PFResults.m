function [Result_Bus, Result_Branch, S_slack, Ploss, Qloss] = PFResults(busNumber, lineNumber, BusData, BranchData, Y, G, B, Y0, Voltage, angle, baseMVA)
    % 节点计算结果：
    % 1        2       3           4             5               6               7                          8
    % 节点编号 节点类型 节点电压幅值 节点电压相角度 节点注入有功功率 节点注入无功功率 节点输出有功功率（负荷有功） 节点输出无功功率（负荷无功）
    Result_Bus = zeros(busNumber, 8);                                                                           
    
    % 支路计算结果：
    % 1          2         3              4              5              6              7             8
    % 支路首节点 支路末节点 首端有功功率Pij 首端无功功率Qij 末端有功功率Pji 末端无功功率Qji 有功功率损耗PL 无功功率损耗QL
    Result_Branch = zeros(lineNumber, 8);
    PI = 3.141592653;                                                      % 圆周率；
    
    E = Voltage .* cos(angle);
    F = Voltage .* sin(angle);
    
    U = E + 1i * F;                                                        % 所有节点电压的复数值；
    V_magnitude = E .* E + F .* F;                                         % 所有节点电压的幅值（输出结论及计算功率使用）；
    V_magnitude = sqrt(V_magnitude);
    V_angle = atan(F ./E) * 180 / PI;                                      % 所有节点电压的相角（输出结论及计算功率使用）；
    
    %% 求取母线节点信息；
    Result_Bus(:, 1) = BusData(:, 1);                                      % 节点编号；
    Result_Bus(:, 2) = BusData(:, 2);                                      % 节点类型；
    Result_Bus(:, 3) = V_magnitude(:, 1);                                  % 节点电压幅值；
    Result_Bus(:, 4) = V_angle(:, 1);                                      % 节点电压相角；
    Result_Bus(:, 7) = BusData(:, 3);                                      % 节点输出有功功率（负荷有功）；
    Result_Bus(:, 8) = BusData(:, 4);                                      % 节点输出无功功率（负荷无功）；
    
    [sNumber, ~] = find(BusData(:, 2) == 3);
    Isum = conj(Y(sNumber, :)) * conj(U(:, 1));
    S = U(sNumber, 1) * Isum;
    Result_Bus(sNumber, 5) = real(S) * baseMVA + BusData(sNumber, 3);      % 平衡节点注入有功功率；
    Result_Bus(sNumber, 6) = imag(S) * baseMVA + BusData(sNumber, 4);      % 平衡节点注入无功功率；
    S_slack = S * baseMVA;

    TempA = G * E - B * F;
    TempB = G * F + B * E;
    Result_Bus(:, 5) = (E .* TempA + F .* TempB) * baseMVA + BusData(:, 3);% 节点注入有功功率；
    Result_Bus(:, 6) = (F .* TempA - E .* TempB) * baseMVA + BusData(:, 4);% 节点注入无功功率；
    %% 求取支路信息
    Result_Branch(:, 1) = BranchData(:, 1);                                % 线路首节点；
    Result_Branch(:, 2) = BranchData(:, 2);                                % 线路末节点；
    Ploss = 0.0;
    Qloss = 0.0;

    CONJY0 = conj(Y0);
    CONJY = conj(Y);
    CONJU = conj(U);
    for m = 1:1:lineNumber
        x = Result_Branch(m, 1);
        y = Result_Branch(m, 2);
        cy0 = CONJY0(x, y);
        cy = CONJY(x, y);
        dU = CONJU(x) - CONJU(y);
        head = CONJU(x) * cy0 - dU * cy;
        tail = CONJU(y) * cy0 + dU * cy;
        Sf = U(x) * head * baseMVA;
        St = U(y) * tail * baseMVA;
        
        Result_Branch(m, 3) = real(Sf);
        Result_Branch(m, 4) = imag(Sf);
        Result_Branch(m, 5) = real(St);
        Result_Branch(m, 6) = imag(St);
        
       %% 计算线损：警告，变压器受端电压要除以非标准变比 K 
        if BranchData(m, 8) == 1                                           % 该线路处于运行状态；
            if BranchData(m, 6) == 0                                       % Ratio = 0 ，求普通线路的导纳；
                Z = BranchData(m, 3) + 1i *  BranchData(m, 4);
                I = (U(x, 1) - U(y, 1)) / Z;
            else                                                           % Ratio = K ，求变压器支路的导纳；
                K = BranchData(m, 6);
                Z = BranchData(m, 3) + 1i *  BranchData(m, 4);             % 计算网损时，变压器阻抗不需要变换；
                I = (U(x, 1) / K - U(y, 1)) / Z;                           % 变压器受端电压要除以非标准变比 K ；
            end
        end
       
        Result_Branch(m, 7) = I * conj(I) * real(Z) * baseMVA;
        Result_Branch(m, 8) = I * conj(I) * imag(Z) * baseMVA;
    end
    Ploss = Ploss + sum(Result_Branch(:, 7));
    Qloss = Qloss + sum(Result_Branch(:, 8));
return