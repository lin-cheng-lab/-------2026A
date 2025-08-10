function MinimalTest()
%% 最小化测试程序 - 逐步验证核心功能
% 用于在MATLAB中逐步测试海洋系泊系统程序
% 作者：Claude Code
% 版本：v1.0

fprintf('==========================================================\n');
fprintf('            最小化功能测试程序 v1.0\n');
fprintf('==========================================================\n\n');

% 测试基本MATLAB功能
fprintf('【步骤1】测试基本MATLAB功能\n');
fprintf('----------------------------------------------------------\n');
try
    test_array = [1, 2, 3];
    test_result = sum(test_array);
    fprintf('✅ 基本数组操作正常: sum([1,2,3]) = %g\n', test_result);
    
    test_struct.field1 = 'test';
    test_struct.field2 = 123;
    fprintf('✅ 结构体操作正常\n');
    
    if isfield(test_struct, 'field1')
        fprintf('✅ isfield函数正常\n');
    end
    
catch ME
    fprintf('❌ 基本MATLAB功能测试失败: %s\n', ME.message);
    return;
end

% 测试主程序文件存在
fprintf('\n【步骤2】检查主程序文件\n');
fprintf('----------------------------------------------------------\n');
main_file = 'MooringSystemDesign.m';
if exist(main_file, 'file') == 2
    fprintf('✅ 主程序文件存在: %s\n', main_file);
else
    fprintf('❌ 主程序文件不存在: %s\n', main_file);
    return;
end

% 测试函数路径
fprintf('\n【步骤3】测试函数可访问性\n');
fprintf('----------------------------------------------------------\n');
core_functions = {
    'ExtremalOptimizationCore',
    'MechanicalAnalysisCore', 
    'VirtualWorkCore',
    'MultiObjectiveCore',
    'LeastSquaresSearchCore'
};

available_functions = {};
for i = 1:length(core_functions)
    func_name = core_functions{i};
    try
        func_handle = str2func(func_name);
        if isa(func_handle, 'function_handle')
            fprintf('✅ 函数可访问: %s\n', func_name);
            available_functions{end+1} = func_name;
        else
            fprintf('⚠️  函数状态未知: %s\n', func_name);
        end
    catch
        fprintf('❌ 函数不可访问: %s\n', func_name);
    end
end

% 测试第一个可用函数
fprintf('\n【步骤4】测试核心函数调用\n');
fprintf('----------------------------------------------------------\n');

if ~isempty(available_functions)
    test_func = available_functions{1};
    fprintf('正在测试函数: %s\n', test_func);
    
    try
        % 使用安全的参数测试
        switch test_func
            case 'ExtremalOptimizationCore'
                fprintf('调用 %s(12, 18)...\n', test_func);
                result = feval(test_func, 12, 18);
                
            case 'MechanicalAnalysisCore'
                fprintf('调用 %s(12, 18, 2)...\n', test_func);
                result = feval(test_func, 12, 18, 2);
                
            case 'VirtualWorkCore'
                fprintf('调用 %s(12, 18, 10, 20)...\n', test_func);
                result = feval(test_func, 12, 18, 10, 20);
                
            case 'MultiObjectiveCore'
                fprintf('调用 %s(12, 18, [0.4, 0.3, 0.3])...\n', test_func);
                result = feval(test_func, 12, 18, [0.4, 0.3, 0.3]);
                
            case 'LeastSquaresSearchCore'
                fprintf('调用 %s(12, 18, 0, 0)...\n', test_func);
                result = feval(test_func, 12, 18, 0, 0);
                
            otherwise
                fprintf('未知函数类型，跳过测试\n');
                result = [];
        end
        
        if ~isempty(result)
            if isstruct(result)
                fprintf('✅ 函数调用成功，返回结构体\n');
                fields = fieldnames(result);
                fprintf('   结构体字段 (%d个): %s\n', length(fields), strjoin(fields, ', '));
                
                % 检查关键字段
                key_fields = {'success', 'tilt_angle', 'chain_angle', 'swing_radius'};
                for j = 1:length(key_fields)
                    if isfield(result, key_fields{j})
                        fprintf('   ✅ 包含字段: %s\n', key_fields{j});
                    else
                        fprintf('   ⚠️  缺少字段: %s\n', key_fields{j});
                    end
                end
                
            else
                fprintf('⚠️  函数返回值不是结构体: %s\n', class(result));
            end
        else
            fprintf('⚠️  函数返回空值\n');
        end
        
    catch ME
        fprintf('❌ 函数调用失败: %s\n', ME.message);
        fprintf('   错误位置: %s\n', ME.stack(1).name);
        if length(ME.stack) > 1
            fprintf('   错误行号: %d\n', ME.stack(1).line);
        end
    end
else
    fprintf('❌ 没有可用的核心函数进行测试\n');
end

% 测试绘图函数
fprintf('\n【步骤5】检查绘图函数\n');
fprintf('----------------------------------------------------------\n');
plot_functions = {'PlotResults1', 'PlotResults2', 'PlotResults3', 'PlotResults4', 'PlotResults5'};

for i = 1:length(plot_functions)
    func_name = plot_functions{i};
    if exist(func_name, 'file') == 2
        fprintf('✅ 绘图函数存在: %s\n', func_name);
    else
        fprintf('❌ 绘图函数缺失: %s\n', func_name);
    end
end

% 提供诊断建议
fprintf('\n【步骤6】诊断建议\n');
fprintf('----------------------------------------------------------\n');
fprintf('基于以上测试结果，建议：\n\n');

if length(available_functions) == length(core_functions)
    fprintf('✅ 所有核心函数都可访问，程序结构完整\n');
    fprintf('   建议：可以尝试运行完整的主程序\n');
elseif length(available_functions) > 0
    fprintf('⚠️  部分核心函数可访问 (%d/%d)\n', length(available_functions), length(core_functions));
    fprintf('   建议：先修复缺失的函数，然后重新测试\n');
else
    fprintf('❌ 核心函数都不可访问\n');
    fprintf('   建议：检查函数定义的语法错误\n');
end

fprintf('\n下一步操作建议：\n');
fprintf('1. 如果有语法错误，运行 QuickFix 进行自动修复\n');
fprintf('2. 运行 DebugTool 进行详细诊断\n');
fprintf('3. 在MATLAB命令行中手动测试出错的函数\n');
fprintf('4. 检查函数的输入参数是否正确\n\n');

fprintf('测试完成！\n');
end