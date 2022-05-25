function [Result_Bus, Result_Branch, S_slack, Ploss, Qloss] = PFResults(busNumber, lineNumber, BusData, BranchData, Y, G, B, Y0, Voltage, angle, baseMVA)
    % �ڵ��������
    % 1        2       3           4             5               6               7                          8
    % �ڵ��� �ڵ����� �ڵ��ѹ��ֵ �ڵ��ѹ��Ƕ� �ڵ�ע���й����� �ڵ�ע���޹����� �ڵ�����й����ʣ������й��� �ڵ�����޹����ʣ������޹���
    Result_Bus = zeros(busNumber, 8);                                                                           
    
    % ֧·��������
    % 1          2         3              4              5              6              7             8
    % ֧·�׽ڵ� ֧·ĩ�ڵ� �׶��й�����Pij �׶��޹�����Qij ĩ���й�����Pji ĩ���޹�����Qji �й��������PL �޹��������QL
    Result_Branch = zeros(lineNumber, 8);
    PI = 3.141592653;                                                      % Բ���ʣ�
    
    E = Voltage .* cos(angle);
    F = Voltage .* sin(angle);
    
    U = E + 1i * F;                                                        % ���нڵ��ѹ�ĸ���ֵ��
    V_magnitude = E .* E + F .* F;                                         % ���нڵ��ѹ�ķ�ֵ��������ۼ����㹦��ʹ�ã���
    V_magnitude = sqrt(V_magnitude);
    V_angle = atan(F ./E) * 180 / PI;                                      % ���нڵ��ѹ����ǣ�������ۼ����㹦��ʹ�ã���
    
    %% ��ȡĸ�߽ڵ���Ϣ��
    Result_Bus(:, 1) = BusData(:, 1);                                      % �ڵ��ţ�
    Result_Bus(:, 2) = BusData(:, 2);                                      % �ڵ����ͣ�
    Result_Bus(:, 3) = V_magnitude(:, 1);                                  % �ڵ��ѹ��ֵ��
    Result_Bus(:, 4) = V_angle(:, 1);                                      % �ڵ��ѹ��ǣ�
    Result_Bus(:, 7) = BusData(:, 3);                                      % �ڵ�����й����ʣ������й�����
    Result_Bus(:, 8) = BusData(:, 4);                                      % �ڵ�����޹����ʣ������޹�����
    
    [sNumber, ~] = find(BusData(:, 2) == 3);
    Isum = conj(Y(sNumber, :)) * conj(U(:, 1));
    S = U(sNumber, 1) * Isum;
    Result_Bus(sNumber, 5) = real(S) * baseMVA + BusData(sNumber, 3);      % ƽ��ڵ�ע���й����ʣ�
    Result_Bus(sNumber, 6) = imag(S) * baseMVA + BusData(sNumber, 4);      % ƽ��ڵ�ע���޹����ʣ�
    S_slack = S * baseMVA;

    TempA = G * E - B * F;
    TempB = G * F + B * E;
    Result_Bus(:, 5) = (E .* TempA + F .* TempB) * baseMVA + BusData(:, 3);% �ڵ�ע���й����ʣ�
    Result_Bus(:, 6) = (F .* TempA - E .* TempB) * baseMVA + BusData(:, 4);% �ڵ�ע���޹����ʣ�
    %% ��ȡ֧·��Ϣ
    Result_Branch(:, 1) = BranchData(:, 1);                                % ��·�׽ڵ㣻
    Result_Branch(:, 2) = BranchData(:, 2);                                % ��·ĩ�ڵ㣻
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
        
       %% �������𣺾��棬��ѹ���ܶ˵�ѹҪ���ԷǱ�׼��� K 
        if BranchData(m, 8) == 1                                           % ����·��������״̬��
            if BranchData(m, 6) == 0                                       % Ratio = 0 ������ͨ��·�ĵ��ɣ�
                Z = BranchData(m, 3) + 1i *  BranchData(m, 4);
                I = (U(x, 1) - U(y, 1)) / Z;
            else                                                           % Ratio = K �����ѹ��֧·�ĵ��ɣ�
                K = BranchData(m, 6);
                Z = BranchData(m, 3) + 1i *  BranchData(m, 4);             % ��������ʱ����ѹ���迹����Ҫ�任��
                I = (U(x, 1) / K - U(y, 1)) / Z;                           % ��ѹ���ܶ˵�ѹҪ���ԷǱ�׼��� K ��
            end
        end
       
        Result_Branch(m, 7) = I * conj(I) * real(Z) * baseMVA;
        Result_Branch(m, 8) = I * conj(I) * imag(Z) * baseMVA;
    end
    Ploss = Ploss + sum(Result_Branch(:, 7));
    Qloss = Qloss + sum(Result_Branch(:, 8));
return