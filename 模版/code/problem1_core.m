%% 问题1核心代码 - 刚体力学模型求解
% 基于Paper 4的方法实现系泊系统参数求解

function results = problem1_solver(wind_speed)
    % 输入：wind_speed - 风速(m/s)，可选12, 24, 36
    % 输出：results - 包含所有状态参数的结构体
    
    %% 初始化参数
    x0 = [1372.4, 6, 0.78, 14496.80, 14592.35, 14687.92, 14783.49, ...
          14879.07, 0.09, 0.09, 0.09, 0.09, 0.09, 0.09, 0.09, ...
          0.09, 0.09, 0.09, 17.75]';
    
    options = optimset('MaxFunEvals', 1e4, 'MaxIter', 1e4, ...
                      'Display', 'iter-detailed');
    
    %% 求解非线性方程组
    [x, fval, exitflag] = fsolve(@(x)equations_system(x, wind_speed), ...
                                 x0, options);
    
    %% 结果处理
    results.wind_force = x(1);           % 风力(N)
    results.ground_length = x(2);        % 锚链沉底长度(m)
    results.draft = x(3);                % 吃水深度(m)
    results.tensions = x(4:8);           % 各连接点张力(N)
    results.pipe_angles = x(9:12)*180/pi;  % 钢管倾角(度)
    results.bucket_angle = x(13)*180/pi;   % 钢桶倾角(度)
    results.force_angles = x(14:18)*180/pi; % 力方向角(度)
    results.anchor_x = x(19);            % 锚链末端横坐标(m)
    results.radius = x(19) + x(2);       % 游动半径(m)
    results.exitflag = exitflag;         % 求解状态
    
    %% 绘制锚链形状
    plot_chain_shape(x, wind_speed);
end

function F = equations_system(x, Vwind)
    %% 提取未知量
    Fwind = x(1);     % 风力
    unuse = x(2);     % 沉底长度
    d = x(3);         % 吃水深度
    F1 = x(4); F2 = x(5); F3 = x(6); F4 = x(7); F5 = x(8);
    theta1 = x(9); theta2 = x(10); theta3 = x(11); theta4 = x(12);
    beta = x(13);
    gama1 = x(14); gama2 = x(15); gama3 = x(16); 
    gama4 = x(17); gama5 = x(18);
    x1 = x(19);       % 锚链末端横坐标
    
    %% 物理参数
    H = 18;           % 水深(m)
    rho = 1025;       % 海水密度(kg/m³)
    g = 9.8;          % 重力加速度(m/s²)
    sigma = 7;        % 锚链单位质量(kg/m)
    
    % 根据风速确定重物球质量
    if Vwind == 36 && unuse > 0
        Mball = 4090 * 0.869426751592357;  % 36m/s沉底
    elseif Vwind == 36
        Mball = 2010 * 0.869426751592357;  % 36m/s悬浮
    else
        Mball = 1200 * 0.869426751592357;  % 12或24m/s
    end
    
    maolian = 22.05 - unuse;  % 有效锚链长度
    floatage_bucket = 0.15^2 * pi * rho;  % 钢桶浮力
    floatage_pipe = 0.025^2 * pi * rho;   % 钢管浮力
    
    %% 悬链线方程
    alph1 = 0;  % 锚链底角（沉底时为0）
    y = @(t)(Fwind/sigma/g * cosh(sigma*g*t/Fwind + ...
            asinh(tan(alph1))) - ...
            Fwind/sigma/g * cosh(asinh(tan(alph1))));
    Dy = @(t)sqrt(1 + (sinh(sigma*g*t/Fwind + ...
                      asinh(tan(alph1)))).^2);
    
    %% 20个平衡方程
    F = ones(19, 1);
    
    % 锚链长度约束
    F(1) = quad(Dy, 0, x1) - maolian;
    
    % 锚链顶端切线角
    alph2 = atan(sinh(sigma*g*x1/Fwind + asinh(tan(alph1))));
    y1 = y(x1);
    
    % 钢桶平衡方程（3个）
    F(2) = F1*sin(gama1-beta) + Fwind/cos(alph2)*sin(pi/2-alph2-beta) ...
           - Mball*g*sin(beta);  % 力矩平衡
    F(3) = F1*cos(gama1) + floatage_bucket - 100*g - Mball*g ...
           - Fwind*tan(alph2);   % 竖直平衡
    F(4) = F1*sin(gama1) - Fwind;  % 水平平衡
    
    % 钢管力矩平衡（4个）
    F(5) = F1*sin(gama1-theta1) - F2*sin(theta1-gama2);
    F(6) = F2*sin(gama2-theta2) - F3*sin(theta2-gama3);
    F(7) = F3*sin(gama3-theta3) - F4*sin(theta3-gama4);
    F(8) = F4*sin(gama4-theta4) - F5*sin(theta4-gama5);
    
    % 钢管水平平衡（4个）
    F(9) = F2*sin(gama2) - Fwind;
    F(10) = F3*sin(gama3) - Fwind;
    F(11) = F4*sin(gama4) - Fwind;
    F(12) = F5*sin(gama5) - Fwind;
    
    % 钢管竖直平衡（4个）
    F(13) = F1*cos(gama1) + 10*g - F2*cos(gama2) - floatage_pipe;
    F(14) = F2*cos(gama2) + 10*g - F3*cos(gama3) - floatage_pipe;
    F(15) = F3*cos(gama3) + 10*g - F4*cos(gama4) - floatage_pipe;
    F(16) = F4*cos(gama4) + 10*g - F5*cos(gama5) - floatage_pipe;
    
    % 浮标平衡
    F(17) = F5*cos(gama5) + 1000*g - pi*d*rho*g;
    
    % 几何约束（水深）
    F(18) = y1 + cos(beta) + cos(theta1) + cos(theta2) + ...
            cos(theta3) + cos(theta4) + d - H;
    
    % 风力公式
    F(19) = 2*(2-d)*0.625*Vwind^2 - Fwind;
end

function plot_chain_shape(x, Vwind)
    % 绘制锚链形状
    Fwind = x(1);
    unuse = x(2);
    x1 = x(19);
    sigma = 7;
    g = 9.8;
    alph1 = 0;
    
    y = @(t)(Fwind/sigma/g * cosh(sigma*g*t/Fwind + ...
            asinh(tan(alph1))) - ...
            Fwind/sigma/g * cosh(asinh(tan(alph1))));
    
    xx = 0:0.001:x1;
    yy = y(xx);
    xx = [0:0.001:unuse, xx+unuse+0.001];
    u = length(0:0.001:unuse);
    yy = [zeros(1,u), yy];
    
    figure;
    plot(xx, yy, 'LineWidth', 3);
    grid on;
    xlabel('锚链投影长度 (m)');
    ylabel('距离海底高度 (m)');
    title(sprintf('锚链形状 (风速 %d m/s)', Vwind));
end