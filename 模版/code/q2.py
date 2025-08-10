%产生邻接矩阵
clear;
clc;
load bssj;
i3=zeros(3958,3958);
for i1=1:520
    for i2=2:87
        for i4=2:90
            a1=data((find(data(:,1)==i1)+2),i4);
            a2=data(find(data(:,1)==i1)+2,i2);
            if a1~=0 & (i4-i2)==0  %a1不为空值时，把i3矩阵赋值
                i3(a2,a1)=0;
            elseif a1~=0  & (i4-i2)==1
                i3(a2,a1)=3;
            elseif a1~=0 & (i4-i2)>1
                 i3(a2,a1)=inf;
            elseif a1==0 
                break
            end
            a3=data((find(data(:,1)==i1)+3),i4);
            a4=data(find(data(:,1)==i1)+3,i2);
            if a3~=0 & (i4-i2)==0  %a1不为空值时，把i3矩阵赋值
                i3(a3,a4)=0;
            elseif a3~=0  & (i4-i2)==1
                i3(a3,a4)=3;
            elseif a3~=0 & (i4-i2)>1
                 i3(a3,a4)=inf;
            elseif a3==0 
                break
            end
        end
    end
end
for j1=1:3958
    for j2=1:3958
        if j1~=j2 & i3(j1,j2)~=3
            i3(j1,j2)=inf;
        elseif j1==j2 
            i3(j1,j2)=0;
        end
    end
end
 
附件二
%遗传算法流程实现
%yic.m
clear;
clc;
M=30;
num=3957;
popm1=zeros(M,num);            %生成初始群体1
for k1=1:M
    popm1(k1,:)=randperm(num);    %随机产生一个由自然数1到num 组成的全排列
end
popm2=zeros(M,num);            %生成初始群体2
for k2=1:M
    popm2(k2,:)=randperm(num);    %随机产生一个由自然数1到num 组成的全排列
end
a1=3395;
a2=1828;
a3=[];
a4=[];
for k3=1:30
a3(k3)=abs(find(popm1(k3,:)==a1)-find(popm1(k3,:)==a2));%群体1中，不同个体a1和a2的站点差
a4(k3)=abs(find(popm2(k3,:)==a1)-find(popm2(k3,:)==a2));%群体2中，不同个体a1和a2的站点差
end
a5=3.*a3+3956*3;%种群1的不同个体适应度
a6=3.*a4+3956*3;%种群1的不同个体适应度
a7=[];
a8=[];
a7=(a5./sum(a5)).*1000;%种群1的不同个体选择概率
a8=(a6./sum(a6)).*1000;%种群2的不同个体选择概率
a11=0;
a12=[];
for k4=1:30
    a11=a11+a7(k4);%种群1累加区间
    a12(k4)=a11;
end
a13=0;
a14=[];
for k5=1:30
    a13=a13+a8(k5);%种群2累加区间
    a14(k5)=a13;
end
a15=unifrnd(1,1000,1,30);%种群1产生30个1-1000的均匀分布的随机数
a16=unifrnd(1,1000,1,30);%种群2产生30个1-1000的均匀分布的随机数

a17=[];%种群1
for k6=1:30
if a15(k6)<=a12(1)
   a17(k6)=1;
elseif a12(1)<(a15(k6)) &(a15(k6))<=a12(2)
   a17(k6)=2;
elseif a12(2)<(a15(k6)) & (a15(k6))<=a12(3)
    a17(k6)=3;
elseif a12(3)<(a15(k6)) & (a15(k6))<=a12(4)
    a17(k6)=4;
elseif a12(4)<(a15(k6)) & (a15(k6))<=a12(5)
    a17(k6)=5;
elseif a12(5)<(a15(k6)) & (a15(k6))<=a12(6)
    a17(k6)=6;
elseif a12(6)<(a15(k6)) & (a15(k6))<=a12(7)
    a17(k6)=7;
elseif a12(7)<(a15(k6)) & (a15(k6))<=a12(8)
    a17(k6)=8;
elseif a12(8)<(a15(k6)) & (a15(k6))<=a12(9)
    a17(k6)=9;
elseif a12(9)<(a15(k6)) & (a15(k6))<=a12(10)
    a17(k6)=10;
elseif a12(10)<(a15(k6)) & (a15(k6))<=a12(11)
    a17(k6)=11;
elseif a12(11)<(a15(k6)) & (a15(k6))<=a12(12)
    a17(k6)=12;    
elseif a12(12)<(a15(k6)) & (a15(k6))<=a12(13)
    a17(k6)=13;
elseif a12(13)<(a15(k6)) & (a15(k6))<=a12(14)
    a17(k6)=14;
elseif a12(14)<(a15(k6)) & (a15(k6))<=a12(15)
    a17(k6)=15;
elseif a12(15)<(a15(k6)) & (a15(k6))<=a12(16)
    a17(k6)=16;
elseif a12(16)<(a15(k6)) & (a15(k6))<=a12(17)
    a17(k6)=17;
elseif a12(17)<(a15(k6)) & (a15(k6))<=a12(18)
    a17(k6)=18;
elseif a12(18)<(a15(k6)) & (a15(k6))<=a12(19)
    a17(k6)=19;
elseif a12(19)<(a15(k6)) & (a15(k6))<=a12(20)
    a17(k6)=20;
elseif a12(20)<(a15(k6)) & (a15(k6))<=a12(21)
    a17(k6)=21;
elseif a12(21)<(a15(k6)) & (a15(k6))<=a12(22)
    a17(k6)=22;
elseif a12(22)<(a15(k6)) & (a15(k6))<=a12(23)
    a17(k6)=23;
elseif a12(23)<(a15(k6)) & (a15(k6))<=a12(24)
    a17(k6)=24;
elseif a12(24)<(a15(k6)) & (a15(k6))<=a12(25)
    a17(k6)=25;
elseif a12(25)<(a15(k6)) & (a15(k6))<=a12(26)
    a17(k6)=26;
elseif a12(26)<(a15(k6)) & (a15(k6))<=a12(27)
    a17(k6)=27;
elseif a12(27)<(a15(k6)) & (a15(k6))<=a12(28)
    a17(k6)=28;
elseif a12(28)<(a15(k6)) & (a15(k6))<=a12(29)
    a17(k6)=29;
elseif a12(29)<(a15(k6)) & (a15(k6))<=a12(30)
    a17(k6)=30;
end
end

a18=[];%种群2
for k7=1:30
if a16(k7)<=a14(1)
   a18(k7)=1;
elseif a14(1)<(a16(k7)) &(a16(k7))<=a14(2)
   a18(k7)=2;
elseif a14(2)<(a16(k7)) & (a16(k7))<=a14(3)
    a18(k7)=3;
elseif a14(3)<(a16(k7)) & (a16(k7))<=a14(4)
    a18(k7)=4;
elseif a14(4)<(a16(k7)) & (a16(k7))<=a14(5)
    a18(k7)=5;
elseif a14(5)<(a16(k7)) & (a16(k7))<=a14(6)
    a18(k7)=6;
elseif a14(6)<(a16(k7)) & (a16(k7))<=a14(7)
    a18(k7)=7;
elseif a14(7)<(a16(k7)) & (a16(k7))<=a14(8)
    a18(k7)=8;
elseif a14(8)<(a16(k7)) & (a16(k7))<=a14(9)
    a18(k7)=9;
elseif a14(9)<(a16(k7)) & (a16(k7))<=a14(10)
    a18(k7)=10;
elseif a14(10)<(a16(k7)) & (a16(k7))<=a14(11)
    a18(k7)=11;
elseif a14(11)<(a16(k7)) & (a16(k7))<=a14(12)
    a18(k7)=12;    
elseif a14(12)<(a16(k7)) & (a16(k7))<=a14(13)
    a18(k7)=13;
elseif a14(13)<(a16(k7)) & (a16(k7))<=a14(14)
    a18(k7)=14;
elseif a14(14)<(a16(k7)) & (a16(k7))<=a14(15)
    a18(k7)=15;
elseif a14(15)<(a16(k7)) & (a16(k7))<=a14(16)
    a18(k7)=16;
elseif a14(16)<(a16(k7)) & (a16(k7))<=a14(17)
    a18(k7)=17;
elseif a14(17)<(a16(k7)) & (a16(k7))<=a14(18)
    a18(k7)=18;
elseif a14(18)<(a16(k7)) & (a16(k7))<=a14(19)
    a18(k7)=19;
elseif a14(19)<(a16(k7)) & (a16(k7))<=a14(20)
    a18(k7)=20;
elseif a14(20)<(a16(k7)) & (a16(k7))<=a14(21)
    a18(k7)=21;
elseif a14(21)<(a16(k7)) & (a16(k7))<=a14(22)
    a18(k7)=22;
elseif a14(22)<(a16(k7)) & (a16(k7))<=a14(23)
    a18(k7)=23;
elseif a14(23)<(a16(k7)) & (a16(k7))<=a14(24)
    a18(k7)=24;
elseif a14(24)<(a16(k7)) & (a16(k7))<=a14(25)
    a18(k7)=25;
elseif a14(25)<(a16(k7)) & (a16(k7))<=a14(26)
    a18(k7)=26;
elseif a14(26)<(a16(k7)) & (a16(k7))<=a14(27)
    a18(k7)=27;
elseif a14(27)<(a16(k7)) & (a16(k7))<=a14(28)
    a18(k7)=28;
elseif a14(28)<(a16(k7)) & (a16(k7))<=a14(29)
    a18(k7)=29;
elseif a14(29)<(a16(k7)) & (a16(k7))<=a14(30)
    a18(k7)=30;
end
end
a19=[,];
a20=[,];
for k9=1:30
    a19(k9,:)=popm1(a17(k9),:);
    a20(k9,:)=popm2(a18(k9),:);
end  

a22=[,];a23=[,];
for r1=1:2:30
a=a19(r1,:);
b=a19(r1+1,:);
p1=min(fix(unifrnd(1,3957,1,2)));
p2=max(fix(unifrnd(1,3957,1,2)));
 a1=[b(p1:p2),a];
 b1=[a(p1:p2),b];
 for j=p2-p1+2:3957+p2-p1+1
     for i=1:p2-p1+1
         if(a1(j)==a1(i))
             a1(j)=nan;
         end
         if(b1(j)==b1(i))
              b1(j)=nan;
         end
     end
 end
 if r1==1
a22(r1,:)=a1(~isnan(a1));
a22(r1+1,:)=b1(~isnan(b1));
 elseif r1~=1
     a23(r1-2,:)=a1(~isnan(a1));
     a23(r1-1,:)=b1(~isnan(b1));
 end
end
a2=[a22;a23];

b22=[,];,b23=[,];
for r2=1:2:30
a=a20(r2,:);
b=a20(r2+1,:);
p1=min(fix(unifrnd(1,3957,1,2)));
p2=max(fix(unifrnd(1,3957,1,2)));
 a1=[b(p1:p2),a];
 b1=[a(p1:p2),b];
 for j=p2-p1+2:3957+p2-p1+1
     for i=1:p2-p1+1
         if(a1(j)==a1(i))
             a1(j)=nan;
         end
         if(b1(j)==b1(i))
              b1(j)=nan;
         end
     end
 end
 if r2==1
b22(r2,:)=a1(~isnan(a1));
b22(r2+1,:)=b1(~isnan(b1));
 elseif r2~=1
     b23(r2-2,:)=a1(~isnan(a1));
     b23(r2-1,:)=b1(~isnan(b1));
 end
end
b2=[b22;b23];

w1=[,];
w2=[,];
for q=1:15

z1=fix(unifrnd(1,3957,1,1));
z2=fix(unifrnd(1,3957,1,1));

z3=a2(q,z1);z5=a2(q,z1+1);
z4=b2(q,z2);z6=a2(q,z1+1);

w1(q,:)=[a2(q,1:z1-1),z5,z3,a2(q,(z1+2):3957)];
w2(q,:)=[b2(q,1:z1-1),z6,z4,b2(q,(z1+2):3957)];
end

w3=[,];
w4=[,];
for q=16:30
z1=fix(unifrnd(1,3957,1,2));
z2=fix(unifrnd(1,3957,1,2));
z11=max(z1);
z12=min(z1);
z21=max(z2);
z22=min(z2);

z3=a2(q,z12);z5=a2(q,z11);
z4=b2(q,z22);z6=a2(q,z21);

w3(q-15,:)=[a2(q,1:z12-1),z5,a2(q,z12+1:z11-1),z3,a2(q,(z11+1):3957)];
w4(q-15,:)=[b2(q,1:z22-1),z6,b2(q,z22+1:z21-1),z4,b2(q,(z21+1):3957)];
end
w5=[w1;w3];
w6=[w2;w4];

%jiaoc.m
a22=[,];a23=[,];
for r1=1:2:30
a=a19(r1,:);
b=a19(r1+1,:);
p1=min(fix(unifrnd(1,3957,1,2)));
p2=max(fix(unifrnd(1,3957,1,2)));
 a1=[b(p1:p2),a];
 b1=[a(p1:p2),b];
 for j=p2-p1+2:3957+p2-p1+1
     for i=1:p2-p1+1
         if(a1(j)==a1(i))
             a1(j)=nan;
         end
         if(b1(j)==b1(i))
              b1(j)=nan;
         end
     end
 end
 if r1==1
a22(r1,:)=a1(~isnan(a1));
a22(r1+1,:)=b1(~isnan(b1));
 elseif r1~=1
     a23(r1-2,:)=a1(~isnan(a1));
     a23(r1-1,:)=b1(~isnan(b1));
 end
end
a2=[a22;a23];

b22=[,];,b23=[,];
for r2=1:2:30
a=a20(r2,:);
b=a20(r2+1,:);
p1=min(fix(unifrnd(1,3957,1,2)));
p2=max(fix(unifrnd(1,3957,1,2)));
 a1=[b(p1:p2),a];
 b1=[a(p1:p2),b];
 for j=p2-p1+2:3957+p2-p1+1
     for i=1:p2-p1+1
         if(a1(j)==a1(i))
             a1(j)=nan;
         end
         if(b1(j)==b1(i))
              b1(j)=nan;
         end
     end
 end
 if r2==1
b22(r2,:)=a1(~isnan(a1));
b22(r2+1,:)=b1(~isnan(b1));
 elseif r2~=1
     b23(r2-2,:)=a1(~isnan(a1));
     b23(r2-1,:)=b1(~isnan(b1));
 end
end
b2=[b22;b23];
%biany.m
w1=[,];
w2=[,];
for q=1:15

z1=fix(unifrnd(1,3957,1,1));
z2=fix(unifrnd(1,3957,1,1));

z3=a2(q,z1);z5=a2(q,z1+1);
z4=b2(q,z2);z6=a2(q,z1+1);

w1(q,:)=[a2(q,1:z1-1),z5,z3,a2(q,(z1+2):3957)];
w2(q,:)=[b2(q,1:z1-1),z6,z4,b2(q,(z1+2):3957)];
end

w3=[,];
w4=[,];
for q=16:30
z1=fix(unifrnd(1,3957,1,2));
z2=fix(unifrnd(1,3957,1,2));
z11=max(z1);
z12=min(z1);
z21=max(z2);
z22=min(z2);

z3=a2(q,z12);z5=a2(q,z11);
z4=b2(q,z22);z6=a2(q,z21);

w3(q-15,:)=[a2(q,1:z12-1),z5,a2(q,z12+1:z11-1),z3,a2(q,(z11+1):3957)];
w4(q-15,:)=[b2(q,1:z22-1),z6,b2(q,z22+1:z21-1),z4,b2(q,(z21+1):3957)];
end
w5=[w1;w3];
w6=[w2;w4];