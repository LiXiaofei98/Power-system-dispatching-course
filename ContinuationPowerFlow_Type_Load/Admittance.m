% �õ����ɾ��� Y = G + j*B ��
% ���� TCSC �����Ӱ�죻
% TCSC ��n * 5 ����ÿһ�У�[TCSC��־, TCSC����λ��, ������r, 0, 0]��
% ���룺 baseMVA, BusData, BranchData, GeneratorData ��     % TCSC
% ���أ� Y, G, B, Yfrom, Yto, busNumber, lineNumber, generatorNumber ��
function[Y, G, B, Y0, busNumber, lineNumber, generatorNumber] = Admittance(baseMVA, BusData, BranchData, GeneratorData)
    PI = 3.141592653;
    busNumber = size(BusData, 1);                                          % �ڵ�������
    lineNumber = size(BranchData, 1);                                      % ��·������
    generatorNumber = size(GeneratorData, 1);                              % �����������
    Y = zeros(busNumber, busNumber);                                       % ���嵼�ɾ���
    Y0 = zeros(busNumber, busNumber);                                              % ��·/��ѹ����֧·�Եص��ɣ�ע���Խ�ԪΪ 0 ��
%% �Լ���д    
    % ��ȡ���ɾ���ķǶԽ�Ԫ��
    % ������ʹ��ͬ�����ڵ�֮��׷����֧·��Ҳ����ֱ����ԭ�ļ�����ӣ�������Ҫ��������
    for m = 1:1:lineNumber
        if BranchData(m, 8) == 1                                           % ����·��������״̬��
            if BranchData(m, 6) == 0                                       % Ratio = 0 ������ͨ��·�ĵ��ɣ�
                temp = -1./(BranchData(m, 3) + 1i *  BranchData(m, 4));
                Y(BranchData(m, 1), BranchData(m, 2)) = Y(BranchData(m, 1), BranchData(m, 2)) + temp;
                Y(BranchData(m, 2), BranchData(m, 1)) = Y(BranchData(m, 2), BranchData(m, 1)) + temp;
                
                Y0(BranchData(m, 1), BranchData(m, 2)) =  1i *  BranchData(m, 5); % ��· ij ���׶˶Եص��� yi0��
                Y0(BranchData(m, 2), BranchData(m, 1)) =  1i *  BranchData(m, 5); % ��· ij ��ĩ�˶Եص��� yj0��
            else                                                           % Ratio = K �����ѹ��֧·�ĵ��ɣ�
                K = BranchData(m, 6);
                temp = -1./(BranchData(m, 3) + 1i *  BranchData(m, 4))/K;
                Y(BranchData(m, 1), BranchData(m, 2)) = Y(BranchData(m, 1), BranchData(m, 2)) + temp;
                Y(BranchData(m, 2), BranchData(m, 1)) = Y(BranchData(m, 2), BranchData(m, 1)) + temp;
                
                Y0(BranchData(m, 1), BranchData(m, 2)) = (1 - K) / (K * K) * 1 ./ (BranchData(m, 3) + 1i * BranchData(m, 4)); % ��ѹ��֧· ij ���׶˶Եص��� yi0��
                Y0(BranchData(m, 2), BranchData(m, 1)) = (K - 1) / (K) * 1 ./ (BranchData(m, 3) + 1i * BranchData(m, 4));     % ��ѹ��֧· ij ��ĩ�˶Եص��� yj0��
            end
        end
    end
    
    % ��ȡ���ɾ���ĶԽ�Ԫ��
    for m = 1:1:lineNumber
       if BranchData(m, 8) == 1                                            % ����·��������״̬��
           if BranchData(m, 6) == 0                                        % Ratio = 0 ������ͨ��·�����˵���Ե��ɣ�
               % ����ͨ��·�׶˵㣻
               Y(BranchData(m, 1), BranchData(m, 1)) = Y(BranchData(m, 1), BranchData(m, 1)) + ...
                                                       1./(BranchData(m, 3) + 1i *  BranchData(m, 4)) + ...
                                                       1i *  BranchData(m, 5);
                                                                           % ������·��������ݣ�
               
                % ����ͨ��·ĩ�˵㣻
               Y(BranchData(m, 2), BranchData(m, 2)) = Y(BranchData(m, 2), BranchData(m, 2)) + ...
                                                       1./(BranchData(m, 3) + 1i *  BranchData(m, 4)) + ...
                                                       1i *  BranchData(m, 5);
                                                                           % ������·��������ݣ�
           else                                                            % Ratio = K �����ѹ��֧·�����˵���Ե��ɣ�
               K = BranchData(m, 6); 
               % ���Ǳ�ѹ��֧·���׶˶Եص��ɣ�
               Y(BranchData(m, 1), BranchData(m, 1)) = Y(BranchData(m, 1), BranchData(m, 1)) + ...
                                                       1./(BranchData(m, 3) + 1i * BranchData(m, 4)) / K + ...
                                                       (1 - K) / (K * K) * 1 ./ (BranchData(m, 3) + 1i * BranchData(m, 4));
               % ���Ǳ�ѹ��֧·��ĩ�˶Եص��ɣ�
               Y(BranchData(m, 2), BranchData(m, 2)) = Y(BranchData(m, 2), BranchData(m, 2)) + ...
                                                       1./(BranchData(m, 3) + 1i *  BranchData(m, 4)) / K + ...
                                                       (K - 1) / (K) * 1 ./ (BranchData(m, 3) + 1i * BranchData(m, 4));
           end
       end
    end
    
    % ���Ƕ˵㲢��������ݣ�
    for m = 1:1:busNumber
        y_Toground = (BusData(m, 5) + 1i * BusData(m, 6)) ./ baseMVA;
        Y(m, m) = Y(m, m) + y_Toground;                                                                    
    end

%    %% �ο�������ϵͳ���������������������õ��� Yfrom, Yto ���ڼ��㹦��������
%     Ys = 1 ./ (BranchData(:, 3) + 1i * BranchData(:, 4));
%     Bc = 1 .* BranchData(:, 5);
%     % ��Ϊ TCSC �Ľ��룬Ys Ӧ�����仯��
%     
%     tap = ones(lineNumber, 1);
%     m = find(BranchData(:, 6));
%     tap(m) = BranchData(m, 6);
%     tap = tap .* exp(1i * PI / 180 * BranchData(:, 7));
%     
%     Ytt = Ys + 1i * Bc;
%     Yff = Ytt ./ (tap .* conj(tap));
%     Yft = - Ys ./ conj(tap);
%     Ytf = - Ys ./ tap;
%     
%     fromNod = BranchData(:, 1);
%     toNod = BranchData(:, 2);
%     
%     i = [1:lineNumber; 1:lineNumber]';
%     Yfrom = sparse(i, [fromNod; toNod], [Yff; Yft], lineNumber, busNumber);
%     Yto = sparse(i, [fromNod; toNod], [Ytf; Ytt], lineNumber, busNumber);

   %% ���� TCSC ���޸� Y ����Ķ�ӦԪ�أ�
   
   
   %% ���ص��ɾ���Y = G + j * B ��
    Y = round(Y, 4);%����4λС��ȡ��
    G = real(Y);
    B = imag(Y);
return 