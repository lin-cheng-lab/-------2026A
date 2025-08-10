%QUICK_TEST 快速功能测试
%   最简单的测试，验证核心组件是否工作

fprintf('=== 快速功能测试 ===\n');

% 添加路径
addpath(genpath('src'));

try
    % 测试TestSuite
    fprintf('运行简化测试套件...\n');
    TestSuite.runSimplifiedTests();
    
catch ME
    fprintf('简化测试失败: %s\n', ME.message);
    
    % 备选方案：手动测试核心功能
    fprintf('\n运行手动测试...\n');
    
    test_count = 0;
    pass_count = 0;
    
    % 测试1: Paper 4函数
    test_count = test_count + 1;
    try
        paper4 = OriginalPaper4Functions();
        fprintf('✅ Paper 4函数对象创建成功\n');
        pass_count = pass_count + 1;
    catch
        fprintf('❌ Paper 4函数对象创建失败\n');
    end
    
    % 测试2: 参数验证器
    test_count = test_count + 1;
    try
        validator = ParameterValidator();
        fprintf('✅ 参数验证器创建成功\n');
        pass_count = pass_count + 1;
    catch
        fprintf('❌ 参数验证器创建失败\n');
    end
    
    % 测试3: 可视化工具
    test_count = test_count + 1;
    try
        viz = VisualizationToolkit();
        fprintf('✅ 可视化工具创建成功\n');
        pass_count = pass_count + 1;
    catch
        fprintf('❌ 可视化工具创建失败\n');
    end
    
    fprintf('\n手动测试结果: %d/%d 通过\n', pass_count, test_count);
end

fprintf('\n=== 使用建议 ===\n');
fprintf('• 测试Paper 4算法: test_paper4\n');
fprintf('• 验证系统状态: verify_system\n');
fprintf('• 启动主程序: MooringSystemMain()\n');