% 根据输入的案例代号，返回该案例的网络数据文件路径；
% 输入： caseNumber ；
% 返回： busPath, generatorPath, branchPath ；
function [busPath, generatorPath, branchPath] = ChooseCase(caseNumber)
    switch(caseNumber)
                
        case 14 % 数据来源： matpower ；
                busPath = 'IEEE_14_Matpower\Bus.txt';
                generatorPath = 'IEEE_14_Matpower\Gen.txt';
                branchPath = 'IEEE_14_Matpower\Branch.txt';
                
        case 30 % 数据来源： matpower ；
                busPath = 'IEEE_30_Matpower\Bus.txt';
                generatorPath = 'IEEE_30_Matpower\Gen.txt';
                branchPath = 'IEEE_30_Matpower\Branch.txt';
                
        case 39 % 数据来源： matpower ；
                busPath = 'NewEngland_39_Matpower\Bus.txt';
                generatorPath = 'NewEngland_39_Matpower\Gen.txt';
                branchPath = 'NewEngland_39_Matpower\Branch.txt';
                
        case 57 % 数据来源： matpower ；
                busPath = 'IEEE_57_Matpower\Bus.txt';
                generatorPath = 'IEEE_57_Matpower\Gen.txt';
                branchPath = 'IEEE_57_Matpower\Branch.txt';
        
        case 118 % 数据来源： matpower ；
                busPath = 'IEEE_118_Matpower\Bus.txt';
                generatorPath = 'IEEE_118_Matpower\Gen.txt';
                branchPath = 'IEEE_118_Matpower\Branch.txt';  
                
        % case X % 按格式添加新的案例文件路径；
        
        otherwise
                fprintf('数据错误！\n' );
    end
return