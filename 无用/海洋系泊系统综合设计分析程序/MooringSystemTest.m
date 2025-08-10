function MooringSystemTest()
%% 海洋系泊系统综合设计分析程序 - 测试版本
% 自动运行问题1的分析，无需用户交互

fprintf('==========================================================\n');
fprintf('      海洋系泊系统综合设计分析程序 - 测试运行\n');
fprintf('      Marine Mooring System Design Tool - Test Mode\n');
fprintf('==========================================================\n');
fprintf('  自动运行问题1：风速12m/s & 24m/s下的系统分析\n');
fprintf('==========================================================\n\n');

try
    % 自动运行问题1
    fprintf('正在运行问题1分析...\n');
    Problem1_WindSpeedAnalysis();
    fprintf('\n问题1分析完成！\n');
    
    fprintf('\n正在运行问题2分析...\n');
    Problem2_ParameterOptimization();
    fprintf('\n问题2分析完成！\n');
    
catch ME
    fprintf('程序运行出错: %s\n', ME.message);
    fprintf('错误位置: %s\n', ME.stack(1).name);
    fprintf('错误行号: %d\n', ME.stack(1).line);
    fprintf('请检查程序依赖或联系开发者\n');
    
    % 显示更详细的错误信息
    fprintf('\n=== 详细错误信息 ===\n');
    disp(ME);
end

fprintf('\n测试运行结束。\n');
end