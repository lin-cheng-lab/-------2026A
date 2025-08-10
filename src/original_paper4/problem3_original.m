%% 附件10&11：问题3中，系泊系统参数求解的Matlab程序（原文完整版）
% 基于Paper 4附录的原始代码，保持100%一致性

function problem3_original()
    %% 问题3：多场景优化求解器
    fprintf('=== 问题3多场景优化求解器 ===\n');
    fprintf('开始多参数扫描优化...\n');
    solve_question3_junyunshuili();
    fprintf('\n问题3优化求解完成\n\n');
    
    %% 问题3：分析程序
    fprintf('=== 问题3分析程序 ===\n');
    fprintf('输入海深进行分析（建议值：16-20）\n');
    solve_question3_fenxi_junyunshuili();
    fprintf('问题3分析完成\n\n');
end

%% 附件10：问题3中，各点水速相同、水流与风同向时，锚链长度、型号、重物球质量的Matlab求解程序
function solve_question3_junyunshuili() %水力与风力同向
    clc
    clear
    tic
    global Mball sigma maolian H G BETA ALPH1 D RR A R
    SIGMA=[3.2,7,12.5,19.5,28.12];
    G=[];BETA=[];ALPH1=[];D=[];RR=[];A=[];XX=[];THETA=[];
    H=20;
    for xinghao=5:5
        sigma=SIGMA(xinghao);
        for maolian=21.1:0.1:22
            for Mball=4000:1:4002
                [x,fval,exitflag,r,Unuse]=fun3();
                if (Unuse==0&x(2)>0.279)|x(3)>1.8|x(3)<0|x(13)>0.087|exitflag<1|(Unuse==1&x(2)<0)%只选取阿发1小于16°，浮标深度小于1.5米，β小于5度的解
                    continue
                elseif Unuse==0%代表没有落在地面的锚链
                    ALPH1=[ALPH1;x(2)];G=[G;Mball];BETA=[BETA;x(13)];D=[D;x(3)];RR=[RR;r];A=[A;sigma,maolian,Mball];XX=[XX,[Unuse;x]];THETA=[THETA,x(12:15)];
                else%代表有落在地面的锚链
                    ALPH1=[ALPH1;0];G=[G;Mball];BETA=[BETA;x(13)];D=[D;x(3)];RR=[RR;r];A=[A;sigma,maolian,Mball];XX=[XX,[Unuse;x]];THETA=[THETA,x(12:15)];
                end
            end
        end
    end
    G,BETA=BETA/pi*180,ALPH1=ALPH1/pi*180,D,RR,A,XX%sigma,maolian,Mball
    k=[0.1,0.8,0.1];%吃水深度：β：区域半径=0.1：0.8:0.1
    y=D/1.5*k(1)+BETA/5*k(2)+RR/30*k(3);
    [aim,place]=min(y);
    fprintf('Optimal solution for Problem 3:\n');
    fprintf('Depth: %.3f m, Beta: %.3f°, Radius: %.3f m\n', D(place), BETA(place), RR(place));
    fprintf('Parameters: sigma=%.2f, length=%.1f, mass=%.1f\n', A(place,1), A(place,2), A(place,3));
    sigma_cu=A(place,1);
    maolian_cu=A(place,2);
    Mball_cu=A(place,3);
    aim_cu=aim;
    THETA=THETA;
    
    % 保存结果
    save('problem3_results.mat', 'G', 'BETA', 'ALPH1', 'D', 'RR', 'A', 'XX', 'THETA', ...
         'sigma_cu', 'maolian_cu', 'Mball_cu', 'aim_cu');
    fprintf('问题3结果已保存到 problem3_results.mat\n');
    toc
end

function [x,fval,exitflag,R,Unuse]=fun3()
    global R
    format long
    x0=[1372.4,0.18,0.78,14496.80,14592.35,14687.92,14783.49,14879.07,0.09,0.09,0.09,0.09,0.09,0.09,0.09,0.09,0.09,0.09,17.75]';
    [x,fval,exitflag]=fsolve(@fangcheng2_3,x0);
    Unuse=0;%代表没有落在地面的锚链
    if x(2)<0
        x0=[1372.4,6,0.78,14496.80,14592.35,14687.92,14783.49,14879.07,0.09,0.09,0.09,0.09,0.09,0.09,0.09,0.09,0.09,0.09,17.75]';
        [x,fval,exitflag]=fsolve(@fangcheng1_3,x0);
        Unuse=1;%代表有落在地面的锚链
    end
end

function F=fangcheng1_3(x)
    global R Mball sigma maolian H
    Fwind=x(1);%风力
    unuse=x(2);
    alph1=0;%弧度<0.2793
    d=x(3);%吃水深度 0.5
    F1=x(4);F2=x(5);F3=x(6);F4=x(7);F5=x(8);theta1=x(9);theta2=x(10);theta3=x(11);theta4=x(12);
    beta=x(13);gama1=x(14);gama2=x(15);gama3=x(16);gama4=x(17);gama5=x(18);
    x1=x(19);%锚链末端横坐标
    %%
    Vwind=36;%风速
    p=1025;%海水密度
    g=9.8;%重力加速度
    floatage_bucket=0.15*0.15*pi*p;%钢桶浮力
    floatage_pipe=0.025*0.025*pi*p;%钢管浮力
    F=ones(19,1);
    %%
    y=@(t)((Fwind+42.075*4+252.45+2*d*374*1.5*1.5)/sigma/g*cosh(sigma*g*t/(Fwind+42.075*4+252.45+2*d*374*1.5*1.5)+asinh(tan(alph1)))-(Fwind+42.075*4+252.45+2*d*374*1.5*1.5)/sigma/g*cosh(asinh(tan(alph1))));
    Dy=@(t)(sqrt(1+(sinh(sigma*g*t/(Fwind+42.075*4+252.45+2*d*374*1.5*1.5)+asinh(tan(alph1)))).^2));
    R=sin(beta)+sin(theta1)+sin(theta2)+sin(theta3)+sin(theta4)+x1+unuse;
    F(1)=quad(Dy,0,x1)-(maolian-x(2));%锚链长度
    alph2=atan(sinh(sigma*g*x1/(Fwind+42.075*4+252.45+2*d*374*1.5*1.5)+asinh(tan(alph1))));
    y1=y(x1);
    %钢桶
    F(2)=F1*sin(gama1-beta)+(Fwind+42.075*4+2*d*374*1.5*1.5)/cos(alph2)*sin(pi/2-alph2-beta)-Mball*g*sin(beta);%力矩平衡
    F(3)=F1*cos(gama1)+floatage_bucket-100*g-Mball*g-(Fwind+42.075*4+252.45+2*d*374*1.5*1.5)*tan(alph2);%竖直受力平衡
    F(4)=F1*sin(gama1)-(Fwind+42.075*4+2*d*374*1.5*1.5);%水平受力平衡
    %4个钢管力矩平衡
    F(5)=F1*sin(gama1-theta1)-F2*sin(theta1-gama2);
    F(6)=F2*sin(gama2-theta2)-F3*sin(theta2-gama3);
    F(7)=F3*sin(gama3-theta3)-F4*sin(theta3-gama4);
    F(8)=F4*sin(gama4-theta4)-F5*sin(theta4-gama5);
    %4个钢管水平受力平衡
    F(9)=F2*sin(gama2)-(Fwind+42.075*3+2*d*374*1.5*1.5);
    F(10)=F3*sin(gama3)-(Fwind+42.075*2+2*d*374*1.5*1.5);
    F(11)=F4*sin(gama4)-(Fwind+42.075*1+2*d*374*1.5*1.5);
    F(12)=F5*sin(gama5)-(Fwind+2*d*374*1.5*1.5);
    %4个钢管竖直受力平衡
    F(13)=F1*cos(gama1)+10*g-F2*cos(gama2)-floatage_pipe;
    F(14)=F2*cos(gama2)+10*g-F3*cos(gama3)-floatage_pipe;
    F(15)=F3*cos(gama3)+10*g-F4*cos(gama4)-floatage_pipe;
    F(16)=F4*cos(gama4)+10*g-F5*cos(gama5)-floatage_pipe;
    F(17)=F5*cos(gama5)+1000*g-pi*d*p*g;%浮标竖直受力
    F(18)=y1+cos(beta)+cos(theta1)+cos(theta2)+cos(theta3)+cos(theta4)+d-H;%水深
    F(19)=2*(2-d)*0.625*Vwind*Vwind-Fwind;%风力
end

function F=fangcheng2_3(x)
    global R Mball sigma maolian H
    Fwind=x(1);%风力
    alph1=x(2);%弧度<0.2793
    d=x(3);%吃水深度 0.5
    F1=x(4);F2=x(5);F3=x(6);F4=x(7);F5=x(8);theta1=x(9);theta2=x(10);theta3=x(11);theta4=x(12);
    beta=x(13);gama1=x(14);gama2=x(15);gama3=x(16);gama4=x(17);gama5=x(18);
    x1=x(19);%锚链末端横坐标
    %%
    Vwind=36;%风速
    p=1025;%海水密度
    g=9.8;%重力加速度
    floatage_bucket=0.15*0.15*pi*p;%钢桶浮力
    floatage_pipe=0.025*0.025*pi*p;%钢管浮力
    F=ones(19,1);
    f=2*d*374*1.5*1.5;
    %%
    y=@(t)((Fwind+42.075*4+252.45+f)/sigma/g*cosh(sigma*g*t/(Fwind+42.075*4+252.45+f)+asinh(tan(alph1)))-(Fwind+42.075*4+252.45+f)/sigma/g*cosh(asinh(tan(alph1))));
    Dy=@(t)(sqrt(1+(sinh(sigma*g*t/(Fwind+42.075*4+252.45+f)+asinh(tan(alph1)))).^2));
    R=x1+sin(beta)+sin(theta1)+sin(theta2)+sin(theta3)+sin(theta4);
    F(1)=quad(Dy,0,x1)-maolian;%锚链长度
    alph2=atan(sinh(sigma*g*x1/(Fwind+42.075*4+252.45+f)+asinh(tan(alph1))));
    y1=y(x1);
    %钢桶
    F(2)=F1*sin(gama1-beta)+(Fwind+42.075*4+f)/cos(alph2)*sin(pi/2-alph2-beta)-Mball*g*sin(beta);%力矩平衡
    F(3)=F1*cos(gama1)+floatage_bucket-100*g-Mball*g-(Fwind+42.075*4+252.45+f)*tan(alph2);%竖直受力平衡
    F(4)=F1*sin(gama1)-(Fwind+42.075*4+f);%水平受力平衡
    %4个钢管力矩平衡
    F(5)=F1*sin(gama1-theta1)-F2*sin(theta1-gama2);
    F(6)=F2*sin(gama2-theta2)-F3*sin(theta2-gama3);
    F(7)=F3*sin(gama3-theta3)-F4*sin(theta3-gama4);
    F(8)=F4*sin(gama4-theta4)-F5*sin(theta4-gama5);
    %4个钢管水平受力平衡
    F(9)=F2*sin(gama2)-(Fwind+42.075*3+f);
    F(10)=F3*sin(gama3)-(Fwind+42.075*2+f);
    F(11)=F4*sin(gama4)-(Fwind+42.075*1+f);
    F(12)=F5*sin(gama5)-(Fwind+1683);
    %4个钢管竖直受力平衡
    F(13)=F1*cos(gama1)+10*g-F2*cos(gama2)-floatage_pipe;
    F(14)=F2*cos(gama2)+10*g-F3*cos(gama3)-floatage_pipe;
    F(15)=F3*cos(gama3)+10*g-F4*cos(gama4)-floatage_pipe;
    F(16)=F4*cos(gama4)+10*g-F5*cos(gama5)-floatage_pipe;
    F(17)=F5*cos(gama5)+1000*g-pi*d*p*g;%浮标竖直受力
    F(18)=y1+cos(beta)+cos(theta1)+cos(theta2)+cos(theta3)+cos(theta4)+d-H;%水深
    F(19)=2*(2-d)*0.625*Vwind*Vwind-Fwind;%风力
end

%% 附件11：问题3中，各点水速相同、水流与风同向时，钢桶和钢管的倾斜角度、锚链形状的Matlab求解程序
function solve_question3_fenxi_junyunshuili()
    global Mball H maolian sigma R
    Mball=4030;H=input('输入海深H：');maolian=20.9;sigma=28.12;
    [x,fval,exitflag,r,Unuse]=fun3_analysis();
    if Unuse==0%代表没有落在地面的锚链
        alph1=x(2);beta=x(13);d=x(3);R=r;
    else%代表有落在地面的锚链
        alph1=0;beta=x(13);d=x(3);R=r;
    end
    beta=beta/pi*180;alph1=alph1/pi*180;
    fprintf('Analysis results:\n');
    fprintf('Beta: %.3f°, Alpha1: %.3f°, Depth: %.3f m, Radius: %.3f m\n', beta, alph1, d, R);
    fprintf('Angles: ');
    disp(x(9:13)/pi*180);
end

function [x,fval,exitflag,R,Unuse]=fun3_analysis()
    global R Mball
    format long
    x0=[1372.4,0.18,0.78,14496.80,14592.35,14687.92,14783.49,14879.07,0.09,0.09,0.09,0.09,0.09,0.09,0.09,0.09,0.09,0.09,17.75]';
    [x,fval,exitflag]=fsolve(@fangcheng2_3_analysis,x0);
    Unuse=0;%代表没有落在地面的锚链
    if x(2)<0
        x0=[1372.4,6,0.78,14496.80,14592.35,14687.92,14783.49,14879.07,0.09,0.09,0.09,0.09,0.09,0.09,0.09,0.09,0.09,0.09,17.75]';
        [x,fval,exitflag]=fsolve(@fangcheng1_3_analysis,x0);
        Unuse=1;%代表有落在地面的锚链
    end
end

function F=fangcheng1_3_analysis(x)
    global R Mball sigma maolian H
    Fwind=x(1);%风力
    unuse=x(2);
    alph1=0;%弧度<0.2793
    d=x(3);%吃水深度 0.5
    F1=x(4);F2=x(5);F3=x(6);F4=x(7);F5=x(8);theta1=x(9);theta2=x(10);theta3=x(11);theta4=x(12);
    beta=x(13);gama1=x(14);gama2=x(15);gama3=x(16);gama4=x(17);gama5=x(18);
    x1=x(19);%锚链末端横坐标
    %%
    Vwind=36;%风速
    p=1025;%海水密度
    g=9.8;%重力加速度
    floatage_bucket=0.15*0.15*pi*p;%钢桶浮力
    floatage_pipe=0.025*0.025*pi*p;%钢管浮力
    F=ones(19,1);
    %%
    y=@(t)((Fwind+42.075*4+252.45+2*d*374*1.5*1.5)/sigma/g*cosh(sigma*g*t/(Fwind+42.075*4+252.45+2*d*374*1.5*1.5)+asinh(tan(alph1)))-(Fwind+42.075*4+252.45+2*d*374*1.5*1.5)/sigma/g*cosh(asinh(tan(alph1))));
    Dy=@(t)(sqrt(1+(sinh(sigma*g*t/(Fwind+42.075*4+252.45+2*d*374*1.5*1.5)+asinh(tan(alph1)))).^2));
    R=sin(beta)+sin(theta1)+sin(theta2)+sin(theta3)+sin(theta4)+x1+unuse;
    F(1)=quad(Dy,0,x1)-(maolian-x(2));%锚链长度
    alph2=atan(sinh(sigma*g*x1/(Fwind+42.075*4+252.45+2*d*374*1.5*1.5)+asinh(tan(alph1))));
    y1=y(x1);
    xx=0:0.001:x1;
    yy=y(xx);
    xx=[0:0.001:unuse,xx+unuse+0.001];xx=(xx-xx(1))*0.89;
    u=length(0:0.001:unuse);
    yy=[zeros(1,u),yy];
    plot(xx,yy,'LineWidth',3,'markersize',8)
    % set(gca,'xtick',[0:x1+unuse+1],'ytick',[0:yy(end)+1])
    title('锚链形状')
    xlabel('锚链投影长度/m')
    ylabel('距离海底高度/m')
    grid on
    %钢桶
    F(2)=F1*sin(gama1-beta)+(Fwind+42.075*4+2*d*374*1.5*1.5)/cos(alph2)*sin(pi/2-alph2-beta)-Mball*g*sin(beta);%力矩平衡
    F(3)=F1*cos(gama1)+floatage_bucket-100*g-Mball*g-(Fwind+42.075*4+252.45+2*d*374*1.5*1.5)*tan(alph2);%竖直受力平衡
    F(4)=F1*sin(gama1)-(Fwind+42.075*4+2*d*374*1.5*1.5);%水平受力平衡
    %4个钢管力矩平衡
    F(5)=F1*sin(gama1-theta1)-F2*sin(theta1-gama2);
    F(6)=F2*sin(gama2-theta2)-F3*sin(theta2-gama3);
    F(7)=F3*sin(gama3-theta3)-F4*sin(theta3-gama4);
    F(8)=F4*sin(gama4-theta4)-F5*sin(theta4-gama5);
    %4个钢管水平受力平衡
    F(9)=F2*sin(gama2)-(Fwind+42.075*3+2*d*374*1.5*1.5);
    F(10)=F3*sin(gama3)-(Fwind+42.075*2+2*d*374*1.5*1.5);
    F(11)=F4*sin(gama4)-(Fwind+42.075*1+2*d*374*1.5*1.5);
    F(12)=F5*sin(gama5)-(Fwind+2*d*374*1.5*1.5);
    %4个钢管竖直受力平衡
    F(13)=F1*cos(gama1)+10*g-F2*cos(gama2)-floatage_pipe;
    F(14)=F2*cos(gama2)+10*g-F3*cos(gama3)-floatage_pipe;
    F(15)=F3*cos(gama3)+10*g-F4*cos(gama4)-floatage_pipe;
    F(16)=F4*cos(gama4)+10*g-F5*cos(gama5)-floatage_pipe;
    F(17)=F5*cos(gama5)+1000*g-pi*d*p*g;%浮标竖直受力
    F(18)=y1+cos(beta)+cos(theta1)+cos(theta2)+cos(theta3)+cos(theta4)+d-H;%水深
    F(19)=2*(2-d)*0.625*Vwind*Vwind-Fwind;%风力
end

function F=fangcheng2_3_analysis(x)
    global R Mball sigma maolian H
    Fwind=x(1);%风力
    alph1=x(2);%弧度<0.2793
    d=x(3);%吃水深度 0.5
    F1=x(4);F2=x(5);F3=x(6);F4=x(7);F5=x(8);theta1=x(9);theta2=x(10);theta3=x(11);theta4=x(12);
    beta=x(13);gama1=x(14);gama2=x(15);gama3=x(16);gama4=x(17);gama5=x(18);
    x1=x(19);%锚链末端横坐标
    %%
    Vwind=36;%风速
    p=1025;%海水密度
    g=9.8;%重力加速度
    floatage_bucket=0.15*0.15*pi*p;%钢桶浮力
    floatage_pipe=0.025*0.025*pi*p;%钢管浮力
    F=ones(19,1);
    f=2*d*374*1.5*1.5;
    %%
    y=@(t)((Fwind+42.075*4+252.45+f)/sigma/g*cosh(sigma*g*t/(Fwind+42.075*4+252.45+f)+asinh(tan(alph1)))-(Fwind+42.075*4+252.45+f)/sigma/g*cosh(asinh(tan(alph1))));
    Dy=@(t)(sqrt(1+(sinh(sigma*g*t/(Fwind+42.075*4+252.45+f)+asinh(tan(alph1)))).^2));
    R=x1+sin(beta)+sin(theta1)+sin(theta2)+sin(theta3)+sin(theta4);
    F(1)=quad(Dy,0,x1)-maolian;%锚链长度
    alph2=atan(sinh(sigma*g*x1/(Fwind+42.075*4+252.45+f)+asinh(tan(alph1))));
    y1=y(x1);
    xx=0:0.001:x1;
    yy=y(xx);
    plot(xx,yy,'LineWidth',3,'markersize',8)
    % set(gca,'xtick',[0:x1+1],'ytick',[0:yy(end)+1])
    title('锚链形状')
    xlabel('锚链投影长度/m')
    ylabel('距离海底高度/m')
    grid on
    %钢桶
    F(2)=F1*sin(gama1-beta)+(Fwind+42.075*4+f)/cos(alph2)*sin(pi/2-alph2-beta)-Mball*g*sin(beta);%力矩平衡
    F(3)=F1*cos(gama1)+floatage_bucket-100*g-Mball*g-(Fwind+42.075*4+252.45+f)*tan(alph2);%竖直受力平衡
    F(4)=F1*sin(gama1)-(Fwind+42.075*4+f);%水平受力平衡
    %4个钢管力矩平衡
    F(5)=F1*sin(gama1-theta1)-F2*sin(theta1-gama2);
    F(6)=F2*sin(gama2-theta2)-F3*sin(theta2-gama3);
    F(7)=F3*sin(gama3-theta3)-F4*sin(theta3-gama4);
    F(8)=F4*sin(gama4-theta4)-F5*sin(theta4-gama5);
    %4个钢管水平受力平衡
    F(9)=F2*sin(gama2)-(Fwind+42.075*3+f);
    F(10)=F3*sin(gama3)-(Fwind+42.075*2+f);
    F(11)=F4*sin(gama4)-(Fwind+42.075*1+f);
    F(12)=F5*sin(gama5)-(Fwind+f);
    %4个钢管竖直受力平衡
    F(13)=F1*cos(gama1)+10*g-F2*cos(gama2)-floatage_pipe;
    F(14)=F2*cos(gama2)+10*g-F3*cos(gama3)-floatage_pipe;
    F(15)=F3*cos(gama3)+10*g-F4*cos(gama4)-floatage_pipe;
    F(16)=F4*cos(gama4)+10*g-F5*cos(gama5)-floatage_pipe;
    F(17)=F5*cos(gama5)+1000*g-pi*d*p*g;%浮标竖直受力
    F(18)=y1+cos(beta)+cos(theta1)+cos(theta2)+cos(theta3)+cos(theta4)+d-H;%水深
    F(19)=2*(2-d)*0.625*Vwind*Vwind-Fwind;%风力
end