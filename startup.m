%STARTUP 系泊系统设计工具启动脚本
%   这个脚本用于启动系泊系统设计工具
%   避免函数与脚本命名冲突问题

fprintf('=== 系泊系统设计工具启动脚本 ===\n');
fprintf('正在启动系统...\n');

try
    % 调用主程序
    MooringSystemMain();
    
catch ME
    fprintf('\n启动失败: %s\n', ME.message);
    fprintf('请尝试以下解决方案:\n');
    fprintf('1. 确保当前工作目录为: %s\n', pwd);
    fprintf('2. 检查MATLAB版本 >= R2018b\n');
    fprintf('3. 运行简化测试: TestSuite.runSimplifiedTests()\n');
    fprintf('4. 手动添加路径: addpath(genpath(''src''))\n');
end