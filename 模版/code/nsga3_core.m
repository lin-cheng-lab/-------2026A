%% NSGA-III多目标优化核心代码
% 用于问题2的系泊系统多目标优化

function [pareto_solutions, pareto_objectives] = nsga3_optimization()
    %% 算法参数设置
    params.pop_size = 100;          % 种群大小
    params.max_gen = 200;           % 最大代数
    params.n_obj = 3;               % 目标数量
    params.n_var = 3;               % 决策变量数量
    params.pc = 0.9;                % 交叉概率
    params.pm = 0.1;                % 变异概率
    params.eta_c = 20;              % 交叉分布指数
    params.eta_m = 20;              % 变异分布指数
    
    % 变量边界 [重物球质量(kg), 锚链长度(m), 锚链型号]
    params.lb = [1700, 16, 1];      % 下界
    params.ub = [5000, 25, 5];      % 上界
    
    % 生成参考点
    params.ref_points = generate_reference_points(params.n_obj, 12);
    
    %% 初始化种群
    pop = initialize_population(params);
    objs = evaluate_objectives(pop, params);
    cons = evaluate_constraints(pop, params);
    
    %% 主循环
    fprintf('开始NSGA-III优化...\n');
    for gen = 1:params.max_gen
        % 生成子代
        offspring = generate_offspring(pop, params);
        off_objs = evaluate_objectives(offspring, params);
        off_cons = evaluate_constraints(offspring, params);
        
        % 合并父代和子代
        combined_pop = [pop; offspring];
        combined_objs = [objs; off_objs];
        combined_cons = [cons; off_cons];
        
        % 环境选择
        [pop, objs, cons] = environmental_selection(combined_pop, ...
                                combined_objs, combined_cons, params);
        
        % 显示进度
        if mod(gen, 20) == 0
            fprintf('  第 %d/%d 代\n', gen, params.max_gen);
        end
    end
    
    %% 提取Pareto最优解
    feasible_idx = all(cons <= 0, 2);
    pareto_solutions = pop(feasible_idx, :);
    pareto_objectives = objs(feasible_idx, :);
    
    fprintf('优化完成！获得 %d 个Pareto最优解\n', ...
            size(pareto_solutions, 1));
end

function objs = evaluate_objectives(pop, params)
    % 评价目标函数
    n = size(pop, 1);
    objs = zeros(n, params.n_obj);
    
    for i = 1:n
        % 调用问题1的求解器计算系统状态
        state = solve_mooring_system(pop(i, :));
        
        % 三个目标：最小化吃水深度、钢桶倾角、游动半径
        objs(i, 1) = state.draft;           % 吃水深度(m)
        objs(i, 2) = state.bucket_angle;    % 钢桶倾角(度)
        objs(i, 3) = state.radius;          % 游动半径(m)
    end
end

function cons = evaluate_constraints(pop, params)
    % 评价约束违反度
    n = size(pop, 1);
    cons = zeros(n, 3);
    
    for i = 1:n
        state = solve_mooring_system(pop(i, :));
        
        % 约束条件
        cons(i, 1) = state.anchor_angle - 16;   % 锚链底角 <= 16°
        cons(i, 2) = state.bucket_angle - 5;    % 钢桶倾角 <= 5°
        cons(i, 3) = state.draft - 1.5;         % 吃水深度 <= 1.5m
    end
end

function offspring = generate_offspring(pop, params)
    % 生成子代（SBX交叉 + 多项式变异）
    n = size(pop, 1);
    offspring = zeros(n, params.n_var);
    
    % 随机配对
    perm = randperm(n);
    
    for i = 1:2:n
        p1 = pop(perm(i), :);
        p2 = pop(perm(i+1), :);
        
        % SBX交叉
        if rand < params.pc
            [c1, c2] = sbx_crossover(p1, p2, params);
        else
            c1 = p1;
            c2 = p2;
        end
        
        % 多项式变异
        c1 = polynomial_mutation(c1, params);
        c2 = polynomial_mutation(c2, params);
        
        offspring(i, :) = c1;
        offspring(i+1, :) = c2;
    end
end

function [c1, c2] = sbx_crossover(p1, p2, params)
    % 模拟二进制交叉(SBX)
    n = length(p1);
    c1 = zeros(1, n);
    c2 = zeros(1, n);
    
    for i = 1:n
        if rand <= 0.5
            if abs(p1(i) - p2(i)) > 1e-6
                if p1(i) < p2(i)
                    y1 = p1(i);
                    y2 = p2(i);
                else
                    y1 = p2(i);
                    y2 = p1(i);
                end
                
                yl = params.lb(i);
                yu = params.ub(i);
                
                beta = 1 + (2*(y1-yl)/(y2-y1));
                alpha = 2 - beta^(-(params.eta_c+1));
                
                u = rand;
                if u <= 1/alpha
                    betaq = (u*alpha)^(1/(params.eta_c+1));
                else
                    betaq = (1/(2-u*alpha))^(1/(params.eta_c+1));
                end
                
                c1(i) = 0.5*((y1+y2) - betaq*(y2-y1));
                c2(i) = 0.5*((y1+y2) + betaq*(y2-y1));
            else
                c1(i) = p1(i);
                c2(i) = p2(i);
            end
        else
            c1(i) = p1(i);
            c2(i) = p2(i);
        end
        
        % 边界处理
        c1(i) = max(params.lb(i), min(params.ub(i), c1(i)));
        c2(i) = max(params.lb(i), min(params.ub(i), c2(i)));
    end
end

function c = polynomial_mutation(p, params)
    % 多项式变异
    c = p;
    n = length(p);
    
    for i = 1:n
        if rand < params.pm
            yl = params.lb(i);
            yu = params.ub(i);
            
            delta1 = (p(i) - yl)/(yu - yl);
            delta2 = (yu - p(i))/(yu - yl);
            
            u = rand;
            if u <= 0.5
                xy = 1 - delta1;
                val = 2*u + (1-2*u)*(xy^(params.eta_m+1));
                deltaq = val^(1/(params.eta_m+1)) - 1;
            else
                xy = 1 - delta2;
                val = 2*(1-u) + 2*(u-0.5)*(xy^(params.eta_m+1));
                deltaq = 1 - val^(1/(params.eta_m+1));
            end
            
            c(i) = p(i) + deltaq*(yu - yl);
            c(i) = max(yl, min(yu, c(i)));
        end
    end
end

function ref_points = generate_reference_points(n_obj, n_div)
    % 生成均匀分布的参考点（Das and Dennis方法）
    ref_points = [];
    
    if n_obj == 3
        for i = 0:n_div
            for j = 0:(n_div-i)
                k = n_div - i - j;
                ref_points = [ref_points; i j k]/n_div;
            end
        end
    end
end

function [next_pop, next_objs, next_cons] = environmental_selection(...
         combined_pop, combined_objs, combined_cons, params)
    % 基于参考点的环境选择
    N = params.pop_size;
    
    % 非支配排序
    fronts = non_dominated_sorting(combined_objs, combined_cons);
    
    % 选择到最后一个前沿
    next_pop = [];
    next_objs = [];
    next_cons = [];
    
    for f = 1:length(fronts)
        if size(next_pop, 1) + length(fronts{f}) <= N
            next_pop = [next_pop; combined_pop(fronts{f}, :)];
            next_objs = [next_objs; combined_objs(fronts{f}, :)];
            next_cons = [next_cons; combined_cons(fronts{f}, :)];
        else
            % 基于参考点的选择
            remaining = N - size(next_pop, 1);
            selected = reference_point_selection(combined_objs(fronts{f}, :), ...
                                                params.ref_points, remaining);
            next_pop = [next_pop; combined_pop(fronts{f}(selected), :)];
            next_objs = [next_objs; combined_objs(fronts{f}(selected), :)];
            next_cons = [next_cons; combined_cons(fronts{f}(selected), :)];
            break;
        end
    end
end

function state = solve_mooring_system(vars)
    % 调用问题1的求解器（简化版）
    % 实际实现中应调用完整的problem1_solver
    
    state.draft = 1.5 + 0.2*rand;          % 示例值
    state.bucket_angle = 3 + 2*rand;       % 示例值
    state.radius = 10 + 10*rand;           % 示例值
    state.anchor_angle = 5 + 10*rand;      % 示例值
end