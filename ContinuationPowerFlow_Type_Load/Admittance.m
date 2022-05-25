% 得到导纳矩阵 Y = G + j*B ；
% 考虑 TCSC 接入的影响；
% TCSC ：n * 5 矩阵，每一行：[TCSC标志, TCSC接入位置, 补偿度r, 0, 0]；
% 输入： baseMVA, BusData, BranchData, GeneratorData ；     % TCSC
% 返回： Y, G, B, Yfrom, Yto, busNumber, lineNumber, generatorNumber ；
function[Y, G, B, Y0, busNumber, lineNumber, generatorNumber] = Admittance(baseMVA, BusData, BranchData, GeneratorData)
    PI = 3.141592653;
    busNumber = size(BusData, 1);                                          % 节点数量；
    lineNumber = size(BranchData, 1);                                      % 线路数量；
    generatorNumber = size(GeneratorData, 1);                              % 发电机数量；
    Y = zeros(busNumber, busNumber);                                       % 定义导纳矩阵；
    Y0 = zeros(busNumber, busNumber);                                              % 线路/变压器的支路对地导纳，注：对角元为 0 ；
%% 自己编写    
    % 求取导纳矩阵的非对角元；
    % 这样即使相同两个节点之间追加了支路，也可以直接在原文件中添加，而不需要修正程序；
    for m = 1:1:lineNumber
        if BranchData(m, 8) == 1                                           % 该线路处于运行状态；
            if BranchData(m, 6) == 0                                       % Ratio = 0 ，求普通线路的导纳；
                temp = -1./(BranchData(m, 3) + 1i *  BranchData(m, 4));
                Y(BranchData(m, 1), BranchData(m, 2)) = Y(BranchData(m, 1), BranchData(m, 2)) + temp;
                Y(BranchData(m, 2), BranchData(m, 1)) = Y(BranchData(m, 2), BranchData(m, 1)) + temp;
                
                Y0(BranchData(m, 1), BranchData(m, 2)) =  1i *  BranchData(m, 5); % 线路 ij 的首端对地导纳 yi0；
                Y0(BranchData(m, 2), BranchData(m, 1)) =  1i *  BranchData(m, 5); % 线路 ij 的末端对地导纳 yj0；
            else                                                           % Ratio = K ，求变压器支路的导纳；
                K = BranchData(m, 6);
                temp = -1./(BranchData(m, 3) + 1i *  BranchData(m, 4))/K;
                Y(BranchData(m, 1), BranchData(m, 2)) = Y(BranchData(m, 1), BranchData(m, 2)) + temp;
                Y(BranchData(m, 2), BranchData(m, 1)) = Y(BranchData(m, 2), BranchData(m, 1)) + temp;
                
                Y0(BranchData(m, 1), BranchData(m, 2)) = (1 - K) / (K * K) * 1 ./ (BranchData(m, 3) + 1i * BranchData(m, 4)); % 变压器支路 ij 的首端对地导纳 yi0；
                Y0(BranchData(m, 2), BranchData(m, 1)) = (K - 1) / (K) * 1 ./ (BranchData(m, 3) + 1i * BranchData(m, 4));     % 变压器支路 ij 的末端对地导纳 yj0；
            end
        end
    end
    
    % 求取导纳矩阵的对角元；
    for m = 1:1:lineNumber
       if BranchData(m, 8) == 1                                            % 该线路处于运行状态；
           if BranchData(m, 6) == 0                                        % Ratio = 0 ，求普通线路的两端点的自导纳；
               % 对普通线路首端点；
               Y(BranchData(m, 1), BranchData(m, 1)) = Y(BranchData(m, 1), BranchData(m, 1)) + ...
                                                       1./(BranchData(m, 3) + 1i *  BranchData(m, 4)) + ...
                                                       1i *  BranchData(m, 5);
                                                                           % 考虑线路自身充电电容；
               
                % 对普通线路末端点；
               Y(BranchData(m, 2), BranchData(m, 2)) = Y(BranchData(m, 2), BranchData(m, 2)) + ...
                                                       1./(BranchData(m, 3) + 1i *  BranchData(m, 4)) + ...
                                                       1i *  BranchData(m, 5);
                                                                           % 考虑线路自身充电电容；
           else                                                            % Ratio = K ，求变压器支路的两端点的自导纳；
               K = BranchData(m, 6); 
               % 考虑变压器支路的首端对地导纳；
               Y(BranchData(m, 1), BranchData(m, 1)) = Y(BranchData(m, 1), BranchData(m, 1)) + ...
                                                       1./(BranchData(m, 3) + 1i * BranchData(m, 4)) / K + ...
                                                       (1 - K) / (K * K) * 1 ./ (BranchData(m, 3) + 1i * BranchData(m, 4));
               % 考虑变压器支路的末端对地导纳；
               Y(BranchData(m, 2), BranchData(m, 2)) = Y(BranchData(m, 2), BranchData(m, 2)) + ...
                                                       1./(BranchData(m, 3) + 1i *  BranchData(m, 4)) / K + ...
                                                       (K - 1) / (K) * 1 ./ (BranchData(m, 3) + 1i * BranchData(m, 4));
           end
       end
    end
    
    % 考虑端点并联电阻电容；
    for m = 1:1:busNumber
        y_Toground = (BusData(m, 5) + 1i * BusData(m, 6)) ./ baseMVA;
        Y(m, m) = Y(m, m) + y_Toground;                                                                    
    end

%    %% 参考《电力系统计算机辅助分析》，这里得到的 Yfrom, Yto 用于计算功率流动；
%     Ys = 1 ./ (BranchData(:, 3) + 1i * BranchData(:, 4));
%     Bc = 1 .* BranchData(:, 5);
%     % 因为 TCSC 的接入，Ys 应发生变化；
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

   %% 增加 TCSC 后修改 Y 矩阵的对应元素；
   
   
   %% 返回导纳矩阵，Y = G + j * B ；
    Y = round(Y, 4);%保留4位小数取整
    G = real(Y);
    B = imag(Y);
return 