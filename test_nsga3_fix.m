%TEST_NSGA3_FIX 测试NSGA-III算法修复
%   验证维度错误是否已修复

fprintf('=== 测试NSGA-III算法修复 ===\n');

% 添加路径
addpath(genpath('src'));

try
    fprintf('1. 创建AdvancedOptimizationSolver对象...\n');
    solver = AdvancedOptimizationSolver();
    fprintf('✅ 对象创建成功\n');
    
    fprintf('\n2. 测试小规模NSGA-III算法...\n');
    pop_size = 10;
    max_gen = 5;
    
    fprintf('   种群大小: %d, 最大代数: %d\n', pop_size, max_gen);
    
    tic;
    results = solver.runNSGA3(pop_size, max_gen);
    elapsed_time = toc;
    
    fprintf('✅ NSGA-III算法运行成功！\n');
    fprintf('   执行时间: %.3f 秒\n', elapsed_time);
    fprintf('   收敛代数: %d\n', results.converged_generation);
    fprintf('   Pareto解数量: %d\n', results.pareto_solutions_count);
    fprintf('   超体积指标: %.6f\n', results.hypervolume);
    
    if results.pareto_solutions_count > 0
        fprintf('\n--- Pareto最优解示例 ---\n');
        fprintf('解\t吃水深度\t倾角\t\t游动半径\t约束违反\n');
        for i = 1:min(3, results.pareto_solutions_count)
            sol = results.pareto_solutions(i, :);
            fprintf('%d\t%.4f\t\t%.4f\t\t%.4f\t\t%.4f\n', i, sol(1), sol(2), sol(3), sol(4));
        end
    end
    
    fprintf('\n🎉 NSGA-III算法修复成功！\n');
    fprintf('   维度错误已解决，算法可以正常运行。\n');
    
    fprintf('\n=== 现在可以运行完整版本 ===\n');
    fprintf('在主程序中选择选项7，使用推荐参数：\n');
    fprintf('• 种群大小: 50-200\n');
    fprintf('• 最大代数: 50-200\n');

catch ME
    fprintf('❌ 测试失败\n');
    fprintf('错误信息: %s\n', ME.message);
    if ~isempty(ME.stack)
        fprintf('错误位置: %s (行 %d)\n', ME.stack(1).name, ME.stack(1).line);
    end
    
    fprintf('\n如果仍有错误，请检查：\n');
    fprintf('1. MATLAB版本是否 >= R2018b\n');
    fprintf('2. 是否有足够内存运行多目标优化\n');
    fprintf('3. Optimization Toolbox是否可用\n');
end