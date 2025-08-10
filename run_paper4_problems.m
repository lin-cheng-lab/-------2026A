function run_paper4_problems()
    %RUN_PAPER4_PROBLEMS 运行Paper 4原始问题的简单界面
    %   用户可以输入1、2、3来运行对应的问题
    
    fprintf('\n=== Paper 4 原始算法运行界面 ===\n');
    fprintf('请选择要运行的问题：\n');
    fprintf('1 - 问题1：基本系泊系统设计 (24m/s风速)\n');
    fprintf('1.1 - 问题1：12m/s风速情况\n'); 
    fprintf('1.2 - 问题1：24m/s风速情况\n');
    fprintf('2 - 问题2：重物球质量优化分析\n');
    fprintf('3 - 问题3：水流同向情况分析\n');
    fprintf('输入数字选择问题，或输入0退出：');
    
    while true
        choice = input('');
        
        if choice == 0
            fprintf('退出程序。\n');
            break;
        elseif choice == 1
            run_question1_with_options();
        elseif choice == 1.1
            run_question1_12ms();
        elseif choice == 1.2
            run_question1_24ms();
        elseif choice == 2
            run_question2();
        elseif choice == 3
            run_question3();
        else
            fprintf('无效选择。请输入1、1.1、1.2、2、3或0：');
            continue;
        end
        
        fprintf('\n继续选择问题，或输入0退出：');
    end
end

function run_question1_with_options()
    %运行问题1，让用户选择风速
    fprintf('\n=== 问题1：系泊系统设计 ===\n');
    fprintf('选择风速条件：\n');
    fprintf('1 - 12 m/s 风速\n');
    fprintf('2 - 24 m/s 风速\n');
    wind_choice = input('请选择 (1 或 2)：');
    
    if wind_choice == 1
        run_question1_12ms();
    elseif wind_choice == 2  
        run_question1_24ms();
    else
        fprintf('无效选择，运行默认24m/s风速\n');
        run_question1_24ms();
    end
end

function run_question1_12ms()
    %运行12m/s风速的问题1
    fprintf('\n=== 运行问题1：12m/s风速 ===\n');
    
    try
        % 修改原始函数以支持12m/s风速
        results = OriginalPaper4Functions.question1_12ms();
        display_question1_results(results, 12);
    catch ME
        fprintf('错误：%s\n', ME.message);
        fprintf('尝试运行标准问题1...\n');
        run_question1_standard();
    end
end

function run_question1_24ms()
    %运行24m/s风速的问题1
    fprintf('\n=== 运行问题1：24m/s风速 ===\n');
    
    try
        results = OriginalPaper4Functions.question1();
        display_question1_results(results, 24);
    catch ME
        fprintf('错误：%s\n', ME.message);
        fprintf('尝试运行标准问题1...\n');
        run_question1_standard();
    end
end

function run_question1_standard()
    %运行标准问题1（后备方案）
    fprintf('\n正在运行Paper 4问题1...\n');
    
    try
        paper4 = OriginalPaper4Functions();
        tic;
        paper4.question1();
        elapsed_time = toc;
        fprintf('\n计算完成，用时: %.3f 秒\n', elapsed_time);
    catch ME
        fprintf('运行失败: %s\n', ME.message);
    end
end

function display_question1_results(results, wind_speed)
    %显示问题1的详细结果
    if nargin < 1 || isempty(results)
        fprintf('未获得有效结果\n');
        return;
    end
    
    fprintf('\n=== 问题1计算结果 (风速: %d m/s) ===\n', wind_speed);
    fprintf('%-20s: %12.6f N\n', '风力 Fwind', results(1));
    fprintf('%-20s: %12.6f m\n', '未用锚链 unuse', results(2)); 
    fprintf('%-20s: %12.6f m\n', '吃水深度 d', results(3));
    fprintf('%-20s: %12.6f N\n', '张力 F1', results(4));
    fprintf('%-20s: %12.6f N\n', '张力 F2', results(5));
    fprintf('%-20s: %12.6f N\n', '张力 F3', results(6));
    fprintf('%-20s: %12.6f N\n', '张力 F4', results(7));
    fprintf('%-20s: %12.6f N\n', '张力 F5', results(8));
    
    fprintf('\n--- 钢管倾斜角度 ---\n');
    fprintf('%-20s: %12.6f°\n', '钢管1倾斜角 θ1', results(9));
    fprintf('%-20s: %12.6f°\n', '钢管2倾斜角 θ2', results(10));
    fprintf('%-20s: %12.6f°\n', '钢管3倾斜角 θ3', results(11));
    fprintf('%-20s: %12.6f°\n', '钢管4倾斜角 θ4', results(12));
    
    fprintf('\n--- 其他角度参数 ---\n');
    fprintf('%-20s: %12.6f°\n', '钢桶倾斜角 β', results(13));
    fprintf('%-20s: %12.6f°\n', '角度 γ1', results(14));
    fprintf('%-20s: %12.6f°\n', '角度 γ2', results(15));
    fprintf('%-20s: %12.6f°\n', '角度 γ3', results(16));
    fprintf('%-20s: %12.6f°\n', '角度 γ4', results(17));
    fprintf('%-20s: %12.6f°\n', '角度 γ5', results(18));
    
    fprintf('\n--- 位置参数 ---\n');
    fprintf('%-20s: %12.6f m\n', '锚链末端坐标 x1', results(19));
    
    % 计算系泊半径
    mooring_radius = results(2) + results(19) + sin(results(13)*pi/180) + ...
                    sin(results(9)*pi/180) + sin(results(10)*pi/180) + ...
                    sin(results(11)*pi/180) + sin(results(12)*pi/180);
    fprintf('%-20s: %12.6f m\n', '系泊半径', mooring_radius);
end

function run_question2()
    %运行问题2
    fprintf('\n=== 运行问题2：重物球质量优化分析 ===\n');
    fprintf('这将需要较长计算时间...\n');
    
    try
        tic;
        OriginalPaper4Functions.question2();
        elapsed_time = toc;
        fprintf('\n问题2计算完成，用时: %.3f 秒\n', elapsed_time);
    catch ME
        fprintf('问题2运行失败: %s\n', ME.message);
    end
end

function run_question3()
    %运行问题3
    fprintf('\n=== 运行问题3：水流同向情况分析 ===\n');
    fprintf('这将需要很长计算时间...\n');
    
    try
        tic;
        OriginalPaper4Functions.question3_junyunshuili();
        elapsed_time = toc;
        fprintf('\n问题3计算完成，用时: %.3f 秒\n', elapsed_time);
    catch ME
        fprintf('问题3运行失败: %s\n', ME.message);
    end
end