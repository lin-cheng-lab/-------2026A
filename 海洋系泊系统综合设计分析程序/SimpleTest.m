function SimpleTest()
%% 海洋系泊系统程序简化测试

fprintf('开始基础功能测试...\\n');

%% 测试1：基本参数设置
try
    v = 12; % 风速
    H = 18; % 水深
    q = 2;  % 锚链类型
    fprintf('✅ 参数设置正常\\n');
catch ME
    fprintf('❌ 参数设置失败: %s\\n', ME.message);
    return;
end

%% 测试2：核心函数存在性检查
core_functions = {'ExtremalOptimizationCore', 'MechanicalAnalysisCore', ...
                  'VirtualWorkCore', 'MultiObjectiveCore', 'LeastSquaresSearchCore'};

for i = 1:length(core_functions)
    func_name = core_functions{i};
    if exist(func_name, 'file') == 2
        fprintf('✅ 函数存在: %s\\n', func_name);
    else
        fprintf('❌ 函数缺失: %s\\n', func_name);
    end
end

%% 测试3：尝试调用第一个核心函数
try
    fprintf('\\n测试 ExtremalOptimizationCore...\\n');
    results = ExtremalOptimizationCore(12, 18);
    if isstruct(results)
        fprintf('✅ ExtremalOptimizationCore 调用成功\\n');
        fields = fieldnames(results);
        fprintf('   返回字段: %s\\n', strjoin(fields, ', '));
    else
        fprintf('⚠️  返回结果不是结构体\\n');
    end
catch ME
    fprintf('❌ ExtremalOptimizationCore 调用失败: %s\\n', ME.message);
end

%% 测试4：检查绘图函数
plot_functions = {'PlotResults1', 'PlotResults2', 'PlotResults3', ...
                  'PlotResults4', 'PlotResults5'};

fprintf('\\n检查绘图函数...\\n');
for i = 1:length(plot_functions)
    func_name = plot_functions{i};
    if exist(func_name, 'file') == 2
        fprintf('✅ 绘图函数存在: %s\\n', func_name);
    else
        fprintf('❌ 绘图函数缺失: %s\\n', func_name);
    end
end

fprintf('\\n基础测试完成！\\n');
end
