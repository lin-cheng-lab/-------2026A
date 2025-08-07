function DebugTool()
%% MATLAB代码调试和诊断工具
% 用于系统性检查海洋系泊系统程序中的错误
% 作者：Claude Code
% 版本：v1.0

fprintf('==========================================================\n');
fprintf('        MATLAB代码调试和诊断工具 v1.0\n');
fprintf('==========================================================\n\n');

% 检查主程序文件
main_file = 'MooringSystemDesign.m';
if ~exist(main_file, 'file')
    fprintf('❌ 错误：找不到主程序文件 %s\n', main_file);
    return;
else
    fprintf('✅ 主程序文件存在: %s\n', main_file);
end

fprintf('\n开始系统性错误检查...\n\n');

%% 1. 语法检查
fprintf('【1】语法检查\n');
fprintf('----------------------------------------------------------\n');
try
    % 尝试解析主函数
    fprintf('检查主函数语法...\n');
    mlint_result = mlint(main_file, '-string');
    if isempty(mlint_result)
        fprintf('✅ 语法检查通过\n');
    else
        fprintf('⚠️  发现语法问题:\n');
        for i = 1:length(mlint_result)
            fprintf('   第%d行: %s - %s\n', mlint_result(i).line, ...
                   mlint_result(i).id, mlint_result(i).message);
        end
    end
catch ME
    fprintf('❌ 语法检查失败: %s\n', ME.message);
end

%% 2. 函数定义检查
fprintf('\n【2】函数定义检查\n');
fprintf('----------------------------------------------------------\n');
try
    % 读取文件内容
    fid = fopen(main_file, 'r');
    if fid == -1
        fprintf('❌ 无法读取主程序文件\n');
        return;
    end
    
    file_content = textscan(fid, '%s', 'Delimiter', '\n', 'WhiteSpace', '');
    file_lines = file_content{1};
    fclose(fid);
    
    % 查找所有函数定义
    function_defs = {};
    function_lines = [];
    
    for i = 1:length(file_lines)
        line = strtrim(file_lines{i});
        if ~isempty(line) && length(line) >= 8 && strcmp(line(1:8), 'function')
            % 提取函数名
            tokens = regexp(line, 'function\s+(?:\[.*?\]\s*=\s*)?(\w+)\s*\(', 'tokens');
            if ~isempty(tokens)
                func_name = tokens{1}{1};
                function_defs{end+1} = func_name;
                function_lines(end+1) = i;
                fprintf('✅ 找到函数定义: %s (第%d行)\n', func_name, i);
            else
                fprintf('⚠️  函数定义格式异常: 第%d行\n', i);
            end
        end
    end
    
    fprintf('总计找到 %d 个函数定义\n', length(function_defs));
    
    %% 3. 函数调用检查
    fprintf('\n【3】函数调用检查\n');
    fprintf('----------------------------------------------------------\n');
    
    % 检查关键函数调用
    critical_functions = {'ExtremalOptimizationCore', 'MechanicalAnalysisCore', ...
                         'VirtualWorkCore', 'MultiObjectiveCore', 'LeastSquaresSearchCore'};
    
    for i = 1:length(critical_functions)
        func_name = critical_functions{i};
        found_def = false;
        found_calls = [];
        
        % 检查是否有定义
        for j = 1:length(function_defs)
            if strcmp(function_defs{j}, func_name)
                found_def = true;
                fprintf('✅ 函数定义存在: %s\n', func_name);
                break;
            end
        end
        
        if ~found_def
            fprintf('❌ 缺少函数定义: %s\n', func_name);
        end
        
        % 查找函数调用
        for k = 1:length(file_lines)
            line = file_lines{k};
            if contains(line, [func_name '(']) && ~contains(line, ['function ' func_name])
                found_calls(end+1) = k;
            end
        end
        
        if ~isempty(found_calls)
            fprintf('   调用位置: 第%s行\n', mat2str(found_calls));
        else
            fprintf('   未找到函数调用\n');
        end
    end
    
    %% 4. 常见错误模式检查
    fprintf('\n【4】常见错误模式检查\n');
    fprintf('----------------------------------------------------------\n');
    
    error_count = 0;
    
    % 检查常见错误
    for i = 1:length(file_lines)
        line = strtrim(file_lines{i});
        
        % 检查end语句匹配
        if strcmp(line, 'end')
            % 简单检查，这里可以扩展
        end
        
        % 检查未闭合的字符串
        quote_count = length(strfind(line, ''''));
        if mod(quote_count, 2) ~= 0 && ~contains(line, '%')
            fprintf('⚠️  可能的未闭合字符串: 第%d行\n', i);
            error_count = error_count + 1;
        end
        
        % 检查未闭合的括号
        if ~isempty(line) && ~startsWith(line, '%')
            open_paren = length(strfind(line, '('));
            close_paren = length(strfind(line, ')'));
            open_bracket = length(strfind(line, '['));
            close_bracket = length(strfind(line, ']'));
            
            if open_paren ~= close_paren
                fprintf('⚠️  括号不匹配: 第%d行\n', i);
                error_count = error_count + 1;
            end
            
            if open_bracket ~= close_bracket
                fprintf('⚠️  方括号不匹配: 第%d行\n', i);
                error_count = error_count + 1;
            end
        end
    end
    
    if error_count == 0
        fprintf('✅ 未发现常见错误模式\n');
    else
        fprintf('发现 %d 个潜在错误\n', error_count);
    end
    
catch ME
    fprintf('❌ 函数检查失败: %s\n', ME.message);
end

%% 5. 生成测试脚本
fprintf('\n【5】生成简化测试脚本\n');
fprintf('----------------------------------------------------------\n');

try
    CreateSimpleTest();
    fprintf('✅ 已生成 SimpleTest.m 用于逐步测试\n');
catch ME
    fprintf('❌ 生成测试脚本失败: %s\n', ME.message);
end

%% 6. 错误解决建议
fprintf('\n【6】错误解决建议\n');
fprintf('----------------------------------------------------------\n');
fprintf('1. 先运行 SimpleTest.m 进行基础功能测试\n');
fprintf('2. 如果有语法错误，先修复语法问题\n');
fprintf('3. 确保所有Core函数都有正确的输入输出定义\n');
fprintf('4. 检查函数调用的参数数量和类型\n');
fprintf('5. 使用 try-catch 包围可能出错的代码段\n');
fprintf('6. 在MATLAB命令行中逐行测试出错的函数\n\n');

fprintf('调试完成！请按照建议逐步解决问题。\n');
end

function CreateSimpleTest()
%% 创建简化的测试脚本
test_content = {
    'function SimpleTest()',
    '%% 海洋系泊系统程序简化测试',
    '',
    'fprintf(''开始基础功能测试...\\n'');',
    '',
    '%% 测试1：基本参数设置',
    'try',
    '    v = 12; % 风速',
    '    H = 18; % 水深',
    '    q = 2;  % 锚链类型',
    '    fprintf(''✅ 参数设置正常\\n'');',
    'catch ME',
    '    fprintf(''❌ 参数设置失败: %s\\n'', ME.message);',
    '    return;',
    'end',
    '',
    '%% 测试2：核心函数存在性检查',
    'core_functions = {''ExtremalOptimizationCore'', ''MechanicalAnalysisCore'', ...',
    '                  ''VirtualWorkCore'', ''MultiObjectiveCore'', ''LeastSquaresSearchCore''};',
    '',
    'for i = 1:length(core_functions)',
    '    func_name = core_functions{i};',
    '    if exist(func_name, ''file'') == 2',
    '        fprintf(''✅ 函数存在: %s\\n'', func_name);',
    '    else',
    '        fprintf(''❌ 函数缺失: %s\\n'', func_name);',
    '    end',
    'end',
    '',
    '%% 测试3：尝试调用第一个核心函数',
    'try',
    '    fprintf(''\\n测试 ExtremalOptimizationCore...\\n'');',
    '    results = ExtremalOptimizationCore(12, 18);',
    '    if isstruct(results)',
    '        fprintf(''✅ ExtremalOptimizationCore 调用成功\\n'');',
    '        fields = fieldnames(results);',
    '        fprintf(''   返回字段: %s\\n'', strjoin(fields, '', ''));',
    '    else',
    '        fprintf(''⚠️  返回结果不是结构体\\n'');',
    '    end',
    'catch ME',
    '    fprintf(''❌ ExtremalOptimizationCore 调用失败: %s\\n'', ME.message);',
    'end',
    '',
    '%% 测试4：检查绘图函数',
    'plot_functions = {''PlotResults1'', ''PlotResults2'', ''PlotResults3'', ...',
    '                  ''PlotResults4'', ''PlotResults5''};',
    '',
    'fprintf(''\\n检查绘图函数...\\n'');',
    'for i = 1:length(plot_functions)',
    '    func_name = plot_functions{i};',
    '    if exist(func_name, ''file'') == 2',
    '        fprintf(''✅ 绘图函数存在: %s\\n'', func_name);',
    '    else',
    '        fprintf(''❌ 绘图函数缺失: %s\\n'', func_name);',
    '    end',
    'end',
    '',
    'fprintf(''\\n基础测试完成！\\n'');',
    'end'
};

% 写入文件
fid = fopen('SimpleTest.m', 'w');
if fid == -1
    error('无法创建测试文件');
end

for i = 1:length(test_content)
    fprintf(fid, '%s\n', test_content{i});
end

fclose(fid);
end