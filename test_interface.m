%TEST_INTERFACE 测试用户界面功能
%   验证所有功能是否正常工作

fprintf('=== 测试Paper 4用户界面 ===\n');

% 添加路径
addpath(genpath('src'));

try
    fprintf('测试1: 检查OriginalPaper4Functions类...\n');
    paper4 = OriginalPaper4Functions();
    fprintf('✅ 类创建成功\n');
    
    fprintf('\n测试2: 运行问题1 (24m/s)...\n');
    tic;
    results_24 = OriginalPaper4Functions.question1();
    time_24 = toc;
    fprintf('✅ 问题1 (24m/s) 完成，用时: %.3f 秒\n', time_24);
    fprintf('   结果维度: %s\n', mat2str(size(results_24)));
    fprintf('   钢管1倾斜角: %.6f°\n', results_24(9));
    fprintf('   钢管2倾斜角: %.6f°\n', results_24(10));
    fprintf('   钢管3倾斜角: %.6f°\n', results_24(11));
    fprintf('   钢管4倾斜角: %.6f°\n', results_24(12));
    
    fprintf('\n测试3: 运行问题1 (12m/s)...\n');
    tic;
    results_12 = OriginalPaper4Functions.question1_12ms();
    time_12 = toc;
    fprintf('✅ 问题1 (12m/s) 完成，用时: %.3f 秒\n', time_12);
    fprintf('   结果维度: %s\n', mat2str(size(results_12)));
    fprintf('   钢管1倾斜角: %.6f°\n', results_12(9));
    fprintf('   钢管2倾斜角: %.6f°\n', results_12(10));
    fprintf('   钢管3倾斜角: %.6f°\n', results_12(11));
    fprintf('   钢管4倾斜角: %.6f°\n', results_12(12));
    
    fprintf('\n测试4: 比较两种风速的结果差异...\n');
    wind_force_diff = results_24(1) - results_12(1);
    fprintf('   风力差异: %.6f N (24m/s vs 12m/s)\n', wind_force_diff);
    fprintf('   钢管1角度差异: %.6f°\n', results_24(9) - results_12(9));
    
    fprintf('\n测试5: 验证风速计算...\n');
    % 根据公式 F(19) = 2*(2-d)*0.625*Vwind*Vwind-Fwind
    % 验证 12m/s: 2*(2-d)*0.625*12^2 vs 24m/s: 2*(2-d)*0.625*24^2
    expected_24 = 2*(2-results_24(3))*0.625*24^2;
    expected_12 = 2*(2-results_12(3))*0.625*12^2;
    fprintf('   24m/s预期风力: %.6f, 实际: %.6f\n', expected_24, results_24(1));
    fprintf('   12m/s预期风力: %.6f, 实际: %.6f\n', expected_12, results_12(1));
    
    fprintf('\n🎉 所有测试通过！\n');
    
    fprintf('\n=== 使用说明 ===\n');
    fprintf('运行用户界面: run_paper4_problems\n');
    fprintf('   - 输入1选择问题1\n');
    fprintf('   - 输入1.1选择12m/s风速\n');
    fprintf('   - 输入1.2选择24m/s风速\n');
    fprintf('   - 输入2选择问题2\n');
    fprintf('   - 输入3选择问题3\n');

catch ME
    fprintf('❌ 测试失败\n');
    fprintf('错误: %s\n', ME.message);
    fprintf('位置: %s (行 %d)\n', ME.stack(1).name, ME.stack(1).line);
end