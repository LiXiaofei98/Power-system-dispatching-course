%% ѡ���������е�ѹ��ֵ�仯�����ֵ��
%% ����ֵ���������У��� lambda �仯��֮�⣬����ֵ����Ԫ�ص��±�ֵ��
function [continuation] = CPFChooseContinuationParamenter(busNumber, BusDataCPF, TangentVector)
%     t = 1;
%     Temp = TangentVector;
%     for x = 1:1:busNumber
%         if BusDataCPF(x, 2) == 1                                           	% PQ �ڵ㣬���� ��ѹ��ֵ ����������ѹ��� ��������
%             Temp(t) = TangentVector(t);         
%             t = t + 1;
%             Temp(t) = TangentVector(t);     
%             t = t + 1;
%         else
%             if BusDataCPF(x, 2) == 2                                       	% PV �ڵ㣬���� ��ѹ��� ��������
%                 Temp(t) = TangentVector(t);     
%                 t = t + 1;
%             end
%         end
%     end
%     Temp = abs(Temp);                                                       % ȡ����ֵ��
%     [~, continuation] = max(Temp);

%     Temp = TangentVector;
%     Temp(end) = [];
%     Temp = abs(Temp);
%     [~, continuation] = max(Temp);
    
   t = 1;
   Temp = TangentVector;
   for x = 1:1:busNumber
       if BusDataCPF(x, 2) == 1
           Temp(t) = Temp(t) * 0;         t = t + 1;                        % PQ �ڵ�� ��ѹ��� �仯��������ʱ�����룻
           Temp(t) = Temp(t) * 1;         t = t + 1;                        % PQ �ڵ�� ��ѹ��ֵ �仯����ȡ����ֵ������ʱ��Ҫ�õ���
       else
           if BusDataCPF(x, 2) == 2
               Temp(t) = Temp(t) * 0;     t = t + 1;                        % PV �ڵ�� ��ѹ��� �仯��������ʱ�����룻
           end
       end
   end
   Temp = abs(Temp);
   Temp(end) = [];
   [~, continuation] = max(Temp);
return 