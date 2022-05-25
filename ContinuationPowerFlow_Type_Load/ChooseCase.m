% ��������İ������ţ����ظð��������������ļ�·����
% ���룺 caseNumber ��
% ���أ� busPath, generatorPath, branchPath ��
function [busPath, generatorPath, branchPath] = ChooseCase(caseNumber)
    switch(caseNumber)
                
        case 14 % ������Դ�� matpower ��
                busPath = 'IEEE_14_Matpower\Bus.txt';
                generatorPath = 'IEEE_14_Matpower\Gen.txt';
                branchPath = 'IEEE_14_Matpower\Branch.txt';
                
        case 30 % ������Դ�� matpower ��
                busPath = 'IEEE_30_Matpower\Bus.txt';
                generatorPath = 'IEEE_30_Matpower\Gen.txt';
                branchPath = 'IEEE_30_Matpower\Branch.txt';
                
        case 39 % ������Դ�� matpower ��
                busPath = 'NewEngland_39_Matpower\Bus.txt';
                generatorPath = 'NewEngland_39_Matpower\Gen.txt';
                branchPath = 'NewEngland_39_Matpower\Branch.txt';
                
        case 57 % ������Դ�� matpower ��
                busPath = 'IEEE_57_Matpower\Bus.txt';
                generatorPath = 'IEEE_57_Matpower\Gen.txt';
                branchPath = 'IEEE_57_Matpower\Branch.txt';
        
        case 118 % ������Դ�� matpower ��
                busPath = 'IEEE_118_Matpower\Bus.txt';
                generatorPath = 'IEEE_118_Matpower\Gen.txt';
                branchPath = 'IEEE_118_Matpower\Branch.txt';  
                
        % case X % ����ʽ����µİ����ļ�·����
        
        otherwise
                fprintf('���ݴ���\n' );
    end
return