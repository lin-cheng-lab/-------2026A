%TEST_PAPER4 快速测试Paper 4算法
%   跳过复杂的系统检查，直接测试核心功能

fprintf('\n=== Paper 4算法快速测试 ===\n');

% 添加路径
if exist('src', 'dir')
    addpath(genpath('src'));
    fprintf('✅ 源码路径已添加\n');
else
    fprintf('❌ 找不到src目录，请确保在正确的目录中\n');
    return;
end

% 测试Paper 4算法
try
    fprintf('创建Paper 4函数对象...\n');
    paper4 = OriginalPaper4Functions();
    fprintf('✅ Paper 4函数对象创建成功\n');
    
    fprintf('\n开始运行Paper 4问题1...\n');
    tic;
    result1 = paper4.question1();
    time1 = toc;
    
    fprintf('✅ Paper 4问题1运行成功\n');
    fprintf('   执行时间: %.3f 秒\n', time1);
    fprintf('   结果类型: %s\n', class(result1));
    
    if isnumeric(result1)
        fprintf('   结果维度: %s\n', mat2str(size(result1)));
        if length(result1) <= 20  % 只显示较小的结果
            fprintf('   结果值: %s\n', mat2str(result1, 4));
        else
            fprintf('   结果值: [%.4f, %.4f, ...] (共%d个元素)\n', result1(1), result1(2), length(result1));
        end
    end
    
    fprintf('\n开始运行Paper 4问题2...\n');
    tic;
    result2 = paper4.question2();
    time2 = toc;
    
    fprintf('✅ Paper 4问题2运行成功\n');
    fprintf('   执行时间: %.3f 秒\n', time2);
    fprintf('   结果类型: %s\n', class(result2));
    
    if isnumeric(result2)
        fprintf('   结果维度: %s\n', mat2str(size(result2)));
        if length(result2) <= 20
            fprintf('   结果值: %s\n', mat2str(result2, 4));
        else
            fprintf('   结果值: [%.4f, %.4f, ...] (共%d个元素)\n', result2(1), result2(2), length(result2));
        end
    end
    
    fprintf('\n🎉 Paper 4算法测试完全成功！\n');
    fprintf('总执行时间: %.3f 秒\n', time1 + time2);
    
catch ME
    fprintf('❌ Paper 4算法测试失败\n');
    fprintf('错误信息: %s\n', ME.message);
    fprintf('错误位置: %s (行 %d)\n', ME.stack(1).name, ME.stack(1).line);
    
    fprintf('\n可能的解决方案:\n');
    fprintf('1. 检查MATLAB版本是否 >= R2018b\n');
    fprintf('2. 确保有Optimization Toolbox\n');
    fprintf('3. 尝试运行: verify_system\n');
    fprintf('4. 检查文件完整性\n');
end

fprintf('\n--- 其他可用测试 ---\n');
fprintf('运行完整验证: verify_system\n');
fprintf('运行系统测试: TestSuite.runSimplifiedTests()\n');
fprintf('启动主程序: MooringSystemMain()\n');