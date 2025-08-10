%% 附件9：问题2中，系泊系统参数求解的Matlab程序（原文完整版）
% 基于Paper 4附录的原始代码，保持100%一致性

function problem2_original()
    %% 问题2：优化求解器
    fprintf('=== 问题2优化求解器 ===\n');
    fprintf('开始扫描重物球质量范围 1700-5000 kg...\n');
    solve_question2();
    fprintf('问题2优化求解完成\n\n');
end

%% 附件9：问题2中，系泊系统参数求解的Matlab程序
function solve_question2()
    global Mball R
    G=[];beta=[];alph1=[];d=[];R=[];
    for Mball1=1700:10:5000
        Mball=Mball1*0.869426751592357;
        [x,fval,exitflag,r,Unuse]=fun_problem2();
        if (Unuse==0&x(2)>0.279)|x(3)>1.5|x(13)>0.087%只选取阿发1小于16°，浮标深度小于1.5米，β小于5度的解
            continue
        elseif Unuse==0%代表没有落在地面的锚链
            alph1=[alph1;x(2)];G=[G;Mball1];beta=[beta;x(13)];d=[d;x(3)];R=[R;r];
        else%代表有落在地面的锚链
            alph1=[alph1;0];G=[G;Mball1];beta=[beta;x(13)];d=[d;x(3)];R=[R;r];
        end
    end
    G,beta=beta/pi*180,alph1=alph1/pi*180,d,R
    figure(1)
    plot(G,beta)
    title('β随重物球质量变化图')
    xlabel('重物球质量/kg')
    ylabel('β/°')
    grid on
    figure(2)
    plot(G,R)
    title('区域半径随重物球质量变化图')
    xlabel('重物球质量/kg')
    ylabel('半径/m')
    grid on
    figure(3)
    plot(G,d)
    title('吃水深度随重物球质量变化图')
    xlabel('重物球质量/kg')
    ylabel('深度/m')
    grid on
    figure(4)
    plot(G,alph1)
    title('α1随重物球质量变化图')
    xlabel('重物球质量/kg')
    ylabel('α1/°')
    set(gca,'ytick',[0:16])
    grid on
    figure(5)
    k=[0.1,0.8,0.1];%吃水深度：β：区域半径=0.1：0.8:0.1
    y=d/max(d)*k(1)+beta/max(beta)*k(2)+R/max(R)*k(3);
    plot(G,y)
    title('优化目标随重物球质量变化图')
    xlabel('重物球质量/kg')
    ylabel('目标值')
    grid on
    [a,place]=min(y);
    fprintf('Optimal solution:\n');
    fprintf('Mass: %.1f kg, Beta: %.3f°, Alpha1: %.3f°, Depth: %.3f m, Radius: %.3f m\n', ...
            G(place), beta(place), alph1(place), d(place), R(place));
    
    % 保存结果
    save('problem2_results.mat', 'G', 'beta', 'alph1', 'd', 'R', 'y');
    fprintf('问题2结果已保存到 problem2_results.mat\n');
end

function [x,fval,exitflag,R,Unuse]=fun_problem2()
    global R Mball
    options=optimset('MaxFunEvals',1e4,'MaxIter',1e4);
    format long
    x0=[1372.4,0.18,0.78,14496.80,14592.35,14687.92,14783.49,14879.07,0.09,0.09,0.09,0.09,0.09,0.09,0.09,0.09,0.09,0.09,17.75]';
    [x,fval,exitflag]=fsolve(@fangcheng2_problem2,x0,options);
    Unuse=0;%代表没有落在地面的锚链
    if x(2)<0
        x0=[1372.4,6,0.78,14496.80,14592.35,14687.92,14783.49,14879.07,0.09,0.09,0.09,0.09,0.09,0.09,0.09,0.09,0.09,0.09,17.75]';
        [x,fval,exitflag]=fsolve(@fangcheng1_problem2,x0,options);
        Unuse=1;%代表有落在地面的锚链
    end
end

function F=fangcheng1_problem2(x)
    global R Mball
    Fwind=x(1);%风力
    unuse=x(2);
    alph1=0;%弧度<0.2793
    d=x(3);%吃水深度 0.5
    F1=x(4);F2=x(5);F3=x(6);F4=x(7);F5=x(8);theta1=x(9);theta2=x(10);theta3=x(11);theta4=x(12);
    beta=x(13);gama1=x(14);gama2=x(15);gama3=x(16);gama4=x(17);gama5=x(18);
    x1=x(19);%锚链末端横坐标
    %%
    Vwind=36;%风速
    H=18;%水深
    p=1025;%海水密度
    sigma=7;
    g=9.8;%重力加速度
    % Mball=1200;%重物球质量
    maolian=22.05;%锚链长度
    maolian=maolian-x(2);%减去沉在海底的长度
    floatage_bucket=0.15*0.15*pi*p;%钢桶浮力
    floatage_pipe=0.025*0.025*pi*p;%钢管浮力
    F=ones(19,1);
    %%
    y=@(t)(Fwind/sigma/g*cosh(sigma*g*t/Fwind+asinh(tan(alph1)))-Fwind/sigma/g*cosh(asinh(tan(alph1))));
    Dy=@(t)(sqrt(1+(sinh(sigma*g*t/Fwind+asinh(tan(alph1)))).^2));
    R=sin(beta)+sin(theta1)+sin(theta2)+sin(theta3)+sin(theta4)+x1+unuse;
    F(1)=quad(Dy,0,x1)-maolian;%锚链长度
    alph2=atan(sinh(sigma*g*x1/Fwind+asinh(tan(alph1))));
    y1=y(x1);
    %钢桶
    F(2)=F1*sin(gama1-beta)+Fwind/cos(alph2)*sin(pi/2-alph2-beta)-Mball*g*sin(beta);%力矩平衡
    F(3)=F1*cos(gama1)+floatage_bucket-100*g-Mball*g-Fwind*tan(alph2);%竖直受力平衡
    F(4)=F1*sin(gama1)-Fwind;%水平受力平衡
    %4个钢管力矩平衡
    F(5)=F1*sin(gama1-theta1)-F2*sin(theta1-gama2);
    F(6)=F2*sin(gama2-theta2)-F3*sin(theta2-gama3);
    F(7)=F3*sin(gama3-theta3)-F4*sin(theta3-gama4);
    F(8)=F4*sin(gama4-theta4)-F5*sin(theta4-gama5);
    %4个钢管水平受力平衡
    F(9)=F2*sin(gama2)-Fwind;
    F(10)=F3*sin(gama3)-Fwind;
    F(11)=F4*sin(gama4)-Fwind;
    F(12)=F5*sin(gama5)-Fwind;
    %4个钢管竖直受力平衡
    F(13)=F1*cos(gama1)+10*g-F2*cos(gama2)-floatage_pipe;
    F(14)=F2*cos(gama2)+10*g-F3*cos(gama3)-floatage_pipe;
    F(15)=F3*cos(gama3)+10*g-F4*cos(gama4)-floatage_pipe;
    F(16)=F4*cos(gama4)+10*g-F5*cos(gama5)-floatage_pipe;
    F(17)=F5*cos(gama5)+1000*g-pi*d*p*g;%浮标竖直受力
    F(18)=y1+cos(beta)+cos(theta1)+cos(theta2)+cos(theta3)+cos(theta4)+d-H;%水深
    F(19)=2*(2-d)*0.625*Vwind*Vwind-Fwind;%风力
end

function F=fangcheng2_problem2(x)
    global R Mball
    Fwind=x(1);%风力
    alph1=x(2);%弧度<0.2793
    d=x(3);%吃水深度 0.5
    F1=x(4);F2=x(5);F3=x(6);F4=x(7);F5=x(8);theta1=x(9);theta2=x(10);theta3=x(11);theta4=x(12);
    beta=x(13);gama1=x(14);gama2=x(15);gama3=x(16);gama4=x(17);gama5=x(18);
    x1=x(19);%锚链末端横坐标
    %%
    Vwind=36;%风速
    H=18;%水深
    p=1025;%海水密度
    sigma=7;
    g=9.8;%重力加速度
    % Mball=1200;%重物球质量
    floatage_bucket=0.15*0.15*pi*p;%钢桶浮力
    floatage_pipe=0.025*0.025*pi*p;%钢管浮力
    F=ones(19,1);
    %%
    y=@(t)(Fwind/sigma/g*cosh(sigma*g*t/Fwind+asinh(tan(alph1)))-Fwind/sigma/g*cosh(asinh(tan(alph1))));
    Dy=@(t)(sqrt(1+(sinh(sigma*g*t/Fwind+asinh(tan(alph1)))).^2));
    R=x1+sin(beta)+sin(theta1)+sin(theta2)+sin(theta3)+sin(theta4);
    F(1)=quad(Dy,0,x1)-22.05;%锚链长度
    alph2=atan(sinh(sigma*g*x1/Fwind+asinh(tan(alph1))));
    y1=y(x1);
    %钢桶
    F(2)=F1*sin(gama1-beta)+Fwind/cos(alph2)*sin(pi/2-alph2-beta)-Mball*g*sin(beta);%力矩平衡
    F(3)=F1*cos(gama1)+floatage_bucket-100*g-Mball*g-Fwind*tan(alph2);%竖直受力平衡
    F(4)=F1*sin(gama1)-Fwind;%水平受力平衡
    %4个钢管力矩平衡
    F(5)=F1*sin(gama1-theta1)-F2*sin(theta1-gama2);
    F(6)=F2*sin(gama2-theta2)-F3*sin(theta2-gama3);
    F(7)=F3*sin(gama3-theta3)-F4*sin(theta3-gama4);
    F(8)=F4*sin(gama4-theta4)-F5*sin(theta4-gama5);
    %4个钢管水平受力平衡
    F(9)=F2*sin(gama2)-Fwind;
    F(10)=F3*sin(gama3)-Fwind;
    F(11)=F4*sin(gama4)-Fwind;
    F(12)=F5*sin(gama5)-Fwind;
    %4个钢管竖直受力平衡
    F(13)=F1*cos(gama1)+10*g-F2*cos(gama2)-floatage_pipe;
    F(14)=F2*cos(gama2)+10*g-F3*cos(gama3)-floatage_pipe;
    F(15)=F3*cos(gama3)+10*g-F4*cos(gama4)-floatage_pipe;
    F(16)=F4*cos(gama4)+10*g-F5*cos(gama5)-floatage_pipe;
    F(17)=F5*cos(gama5)+1000*g-pi*d*p*g;%浮标竖直受力
    F(18)=y1+cos(beta)+cos(theta1)+cos(theta2)+cos(theta3)+cos(theta4)+d-H;%水深
    F(19)=2*(2-d)*0.625*Vwind*Vwind-Fwind;%风力
end