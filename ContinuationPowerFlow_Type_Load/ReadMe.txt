% busData.txt ��ʽ��
% 1           2         3            4               5            6              7                  8         9              10                  11
% Bus_i      Type       P_load(MW)   Q_load(MVar)    G_parallel   B_parallel     V_amplitude(p.u.)  V_angle   V_base         V_amplitude_max     V_amplitude_min
% �ڵ���    �ڵ�����   �й�����(MW)  �޹�����(MVar)  �����絼(MW)  ��������(MVar)  ��ѹ��ֵ(����ֵ)   ��ѹ�Ƕ�   ��ѹ��׼ֵ(kV)  ��ѹ����ֵ(����ֵ) ��ѹ��С��ֵ(����ֵ)
% ���У��ڵ����ͣ�1-PQ; 2-PV;3-Balance;
% ���У�Ҫ�� PQ �ڵ���ǰ�� PV �ڵ��ں�

% generator.txt ��ʽ��
% 1           2             3              4                  5                  6                     7                 8           9               10                 
% Bus_i       P_gen(MW)     Q_gen(MVar)   Q_gen_max(MVar)    Q_gen_min(MVar)     V_gen                 S_base  V_angle   Statue      P_gen_max(MW)   P_gen_min(MW)     
% �ڵ���    �й����(MW)   �޹����(MVar)  ����޹����(MVar)  ��С�޹����(MVar)  ��ѹ��ֵ�趨(����ֵ)   ��������ڹ���     �����״̬  ����й����(MW) ��С�й����(MW)
% ���У������״̬��1-���У� 2-ͣ�ˣ�

% Ҫ��busData.txt �� PV �ڵ���ƽ��ڵ�ĵ�ѹ��ֵ�� generator.txt �еĵ�ѹ�趨ֵһ�£�

% branch.txt ��ʽ��
% 1       2      3          4           5                    6                       7                  8                       
% From    To     R(p.u.)    X(p.u.)     B(p.u.)              Ratio                   Angle              Statue
% �׽ڵ�  ĩ�ڵ�  ����(p.u.) �翹(p.u.)  ��·�ܳ�����(p.u.)  ��ѹ�����(V_from:V_to)  �����ѹ���������  ��·���ѹ������״̬
% ���У���ѹ����ȣ�0-��·������Ϊ��ѹ�����Ǳ�׼��� K Ϊ���׶�/ĩ�ˣ��迹���ڽڵ�ĩ�ˣ�
% ������׶ˡ�ĩ�˽�ָ�����еĶ��壻
% ���У���·���ѹ������״̬��1-���У� 2-ͣ�ˣ�
% ���У���·�ܳ�����Ϊ PI ģ��ʱ�ĵ��ߵ��ݣ�

��Ҫ˵�����ǣ�������û�б�дPV�ڵ���PQ�ڵ��ת�����룬��Ϊ�Ҳ���ʵ�ʹ���������ι����޹��������Ƶ�T^T
��� IEEE 14��IEEE 30��IEEE 39�� IEEE 57��IEEE 118 �ļ����������� matpower ����ϵġ�