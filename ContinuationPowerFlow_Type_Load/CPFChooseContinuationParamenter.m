%% 选择切向量中电压幅值变化量最大值；
%% 返回值：切向量中，除 lambda 变化量之外，绝对值最大的元素的下标值；
function [continuation] = CPFChooseContinuationParamenter(busNumber, BusDataCPF, TangentVector)
%     t = 1;
%     Temp = TangentVector;
%     for x = 1:1:busNumber
%         if BusDataCPF(x, 2) == 1                                           	% PQ 节点，包含 电压幅值 切向量、电压相角 切向量；
%             Temp(t) = TangentVector(t);         
%             t = t + 1;
%             Temp(t) = TangentVector(t);     
%             t = t + 1;
%         else
%             if BusDataCPF(x, 2) == 2                                       	% PV 节点，包含 电压相角 切向量；
%                 Temp(t) = TangentVector(t);     
%                 t = t + 1;
%             end
%         end
%     end
%     Temp = abs(Temp);                                                       % 取绝对值；
%     [~, continuation] = max(Temp);

%     Temp = TangentVector;
%     Temp(end) = [];
%     Temp = abs(Temp);
%     [~, continuation] = max(Temp);
    
   t = 1;
   Temp = TangentVector;
   for x = 1:1:busNumber
       if BusDataCPF(x, 2) == 1
           Temp(t) = Temp(t) * 0;         t = t + 1;                        % PQ 节点的 电压相角 变化量，排序时不计入；
           Temp(t) = Temp(t) * 1;         t = t + 1;                        % PQ 节点的 电压幅值 变化量，取绝对值，排序时需要用到；
       else
           if BusDataCPF(x, 2) == 2
               Temp(t) = Temp(t) * 0;     t = t + 1;                        % PV 节点的 电压相角 变化量，排序时不计入；
           end
       end
   end
   Temp = abs(Temp);
   Temp(end) = [];
   [~, continuation] = max(Temp);
return 