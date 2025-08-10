%TEST_STABLE_NSGA3 测试稳定版NSGA-III算法
%   验证新的简化稳定实现是否正常工作

fprintf('=== 测试稳定版NSGA-III算法 ===\n');

% 添加路径
addpath(genpath('src'));

try
    fprintf('1. 创建AdvancedOptimizationSolver对象...\n');
    solver = AdvancedOptimizationSolver();
    fprintf('✅ 对象创建成功\n');
    
    fprintf('\n2. 测试稳定版NSGA-III算法（小规模）...\n');
    pop_size = 20;
    max_gen = 10;
    
    fprintf('   种群大小: %d, 最大代数: %d\n', pop_size, max_gen);
    
    tic;
    results = solver.runNSGA3(pop_size, max_gen);
    elapsed_time = toc;
    
    fprintf('✅ NSGA-III算法运行成功！\n');
    fprintf('   执行时间: %.3f 秒\n', elapsed_time);
    
    % 显示结果详情
    fprintf('\n=== 算法结果 ===\n');
    fprintf('收敛代数: %d\n', results.converged_generation);
    fprintf('Pareto解数量: %d\n', results.pareto_solutions_count);
    fprintf('超体积指标: %.6f\n', results.hypervolume);
    
    if isfield(results, 'best_solution')
        fprintf('\n最佳解参数:\n');
        fprintf('  重物球质量: %.1f kg\n', results.best_solution(1));
        fprintf('  锚链长度: %.2f m\n', results.best_solution(2)); 
        fprintf('  锚链型号: %d\n', round(results.best_solution(3)));
        fprintf('  综合目标值: %.4f\n', results.best_objective);
    end
    
    if results.pareto_solutions_count > 0
        fprintf('\nPareto最优解:\n');
        fprintf('吃水深度\t倾角\t游动半径\t约束违反\n');
        for i = 1:min(3, size(results.pareto_solutions, 1))
            sol = results.pareto_solutions(i, :);
            fprintf('%.3f\t\t%.3f\t%.3f\t\t%.4f\n', sol(1), sol(2), sol(3), sol(4));
        end
    end
    
    fprintf('\n🎉 稳定版NSGA-III算法测试成功！\n');
    fprintf('   所有维度错误已解决，算法稳定运行。\n');
    
    fprintf('\n=== 现在可以运行标准版本 ===\n');
    fprintf('在主程序中选择选项7，推荐参数：\n');
    fprintf('• 种群大小: 50-100 （较大规模需要更多时间）\n');
    fprintf('• 最大代数: 50-100 （较大代数获得更好收敛）\n');

catch ME
    fprintf('❌ 测试失败\n');
    fprintf('错误信息: %s\n', ME.message);
    if ~isempty(ME.stack)
        fprintf('错误位置: %s (行 %d)\n', ME.stack(1).name, ME.stack(1).line);
        fprintf('函数: %s\n', ME.stack(1).file);
    end
    
    fprintf('\n调试信息:\n');
    fprintf('MATLAB版本: %s\n', version('-release'));
    fprintf('当前目录: %s\n', pwd);
end