import matplotlib.pyplot as plt
import matplotlib.patches as patches
import numpy as np

# 创建图形和坐标轴
fig, ax = plt.subplots(1, 1, figsize=(10, 8))

# 设置坐标轴
ax.set_xlim(-3, 3)
ax.set_ylim(-1, 4)
ax.set_aspect('equal')
ax.grid(True, alpha=0.3, linestyle='--')

# 钢桶参数
beta = 15  # 钢桶倾角（度）
beta_rad = np.radians(beta)
L = 2  # 钢桶长度
W = 0.6  # 钢桶宽度

# 钢桶中心位置
center_x = 0
center_y = 2

# 绘制钢桶（倾斜的矩形）
from matplotlib.transforms import Affine2D

# 创建矩形
rect = patches.Rectangle((-W/2, -L/2), W, L, 
                         linewidth=2, edgecolor='black', 
                         facecolor='lightgray', alpha=0.7)

# 应用旋转和平移
t = Affine2D().rotate(beta_rad).translate(center_x, center_y) + ax.transData
rect.set_transform(t)
ax.add_patch(rect)

# 绘制重物球（在钢桶底部）
ball_x = center_x - L/2 * np.sin(beta_rad)
ball_y = center_y - L/2 * np.cos(beta_rad)
circle = plt.Circle((ball_x, ball_y), 0.2, color='darkgray', zorder=10)
ax.add_patch(circle)

# 绘制坐标轴
ax.arrow(-2.5, 0, 4.5, 0, head_width=0.1, head_length=0.1, fc='black', ec='black')
ax.arrow(0, -0.5, 0, 4, head_width=0.1, head_length=0.1, fc='black', ec='black')
ax.text(2.2, -0.3, 'x', fontsize=12, fontweight='bold')
ax.text(0.2, 3.8, 'y', fontsize=12, fontweight='bold')

# 绘制参考线
ax.axvline(x=center_x, color='gray', linestyle='--', alpha=0.5)
ax.axhline(y=center_y, color='gray', linestyle='--', alpha=0.5)

# 钢桶顶部和底部位置
top_x = center_x + L/2 * np.sin(beta_rad)
top_y = center_y + L/2 * np.cos(beta_rad)
bottom_x = center_x - L/2 * np.sin(beta_rad)
bottom_y = center_y - L/2 * np.cos(beta_rad)

# 绘制力矢量
# 1. 钢桶重力 G_bucket
ax.arrow(center_x, center_y, 0, -0.6, head_width=0.1, head_length=0.08, 
         fc='blue', ec='blue', linewidth=2)
ax.text(center_x + 0.3, center_y - 0.3, r'$G_{bucket}$', fontsize=11, color='blue')

# 2. 重物球重力 G_ball
ax.arrow(ball_x, ball_y, 0, -0.8, head_width=0.1, head_length=0.08, 
         fc='red', ec='red', linewidth=2)
ax.text(ball_x + 0.3, ball_y - 0.4, r'$G_{ball}$', fontsize=11, color='red')

# 3. 浮力 F_bucket
ax.arrow(center_x, center_y, 0, 0.6, head_width=0.1, head_length=0.08, 
         fc='cyan', ec='cyan', linewidth=2)
ax.text(center_x + 0.3, center_y + 0.3, r'$F_{bucket}$', fontsize=11, color='cyan')

# 4. 顶部拉力 F_1
gamma_1 = 20  # 拉力方向角
F1_x = 0.8 * np.sin(np.radians(gamma_1))
F1_y = 0.8 * np.cos(np.radians(gamma_1))
ax.arrow(top_x, top_y, F1_x, F1_y, head_width=0.1, head_length=0.08, 
         fc='green', ec='green', linewidth=2)
ax.text(top_x + F1_x + 0.2, top_y + F1_y, r'$F_1$', fontsize=11, color='green')

# 5. 锚链张力 T_chain
alpha_2 = 30  # 锚链切线角
T_x = -0.9 * np.cos(np.radians(alpha_2))
T_y = -0.9 * np.sin(np.radians(alpha_2))
ax.arrow(bottom_x, bottom_y, T_x, T_y, head_width=0.1, head_length=0.08, 
         fc='purple', ec='purple', linewidth=2)
ax.text(bottom_x + T_x - 0.3, bottom_y + T_y, r'$T_{chain}$', fontsize=11, color='purple')

# 标注角度
# β角
arc_beta = patches.Arc((center_x, center_y), 0.8, 0.8, angle=0, 
                       theta1=90-beta, theta2=90, color='black', linewidth=1.5)
ax.add_patch(arc_beta)
ax.text(center_x + 0.5, center_y + 0.4, r'$\beta$', fontsize=12, fontweight='bold')

# γ_1角
arc_gamma = patches.Arc((top_x, top_y), 0.6, 0.6, angle=0, 
                        theta1=70, theta2=90, color='green', linewidth=1.5)
ax.add_patch(arc_gamma)
ax.text(top_x + 0.4, top_y + 0.3, r'$\gamma_1$', fontsize=11, color='green')

# α_2角
arc_alpha = patches.Arc((bottom_x, bottom_y), 0.6, 0.6, angle=0, 
                        theta1=180, theta2=210, color='purple', linewidth=1.5)
ax.add_patch(arc_alpha)
ax.text(bottom_x - 0.5, bottom_y - 0.2, r'$\alpha_2$', fontsize=11, color='purple')

# 绘制力臂（虚线）
# 重物球力臂
ax.plot([top_x, ball_x], [top_y, ball_y], 'k--', alpha=0.5, linewidth=1)
perp_x = top_x - (top_y - ball_y) * np.sin(beta_rad)
perp_y = ball_y
ax.plot([top_x, perp_x], [top_y, perp_y], 'r--', alpha=0.7, linewidth=1.5)
ax.text((top_x + perp_x)/2 - 0.3, (top_y + perp_y)/2, r'$L\sin\beta$', 
        fontsize=10, color='red', rotation=-beta)

# 标注转轴
ax.plot(top_x, top_y, 'ko', markersize=8, markerfacecolor='white', 
        markeredgewidth=2, zorder=15)
ax.text(top_x + 0.2, top_y + 0.2, '转轴', fontsize=10, fontweight='bold')

# 添加力矩方向（弧形箭头）
from matplotlib.patches import FancyArrowPatch
from matplotlib.patches import Arc

# 顺时针力矩（重物球）
arc1 = patches.FancyArrowPatch((top_x - 0.3, top_y - 0.2),
                               (top_x - 0.2, top_y - 0.3),
                               connectionstyle="arc3,rad=0.3",
                               arrowstyle='->', mutation_scale=20,
                               color='red', linewidth=2)
ax.add_patch(arc1)

# 逆时针力矩（锚链）
arc2 = patches.FancyArrowPatch((top_x + 0.2, top_y - 0.3),
                               (top_x + 0.3, top_y - 0.2),
                               connectionstyle="arc3,rad=-0.3",
                               arrowstyle='->', mutation_scale=20,
                               color='purple', linewidth=2)
ax.add_patch(arc2)

# 添加标题和标签
ax.set_title('钢桶受力与力矩分析图', fontsize=14, fontweight='bold', pad=20)
ax.set_xlabel('x轴', fontsize=12)
ax.set_ylabel('y轴', fontsize=12)

# 添加图例
legend_elements = [
    plt.Line2D([0], [0], color='blue', linewidth=2, label='钢桶重力'),
    plt.Line2D([0], [0], color='red', linewidth=2, label='重物球重力'),
    plt.Line2D([0], [0], color='cyan', linewidth=2, label='浮力'),
    plt.Line2D([0], [0], color='green', linewidth=2, label='顶部拉力'),
    plt.Line2D([0], [0], color='purple', linewidth=2, label='锚链张力')
]
ax.legend(handles=legend_elements, loc='upper right', fontsize=10)

# 移除坐标刻度
ax.set_xticks([])
ax.set_yticks([])

# 保存图片
plt.tight_layout()
plt.savefig('/Users/lincheng/MooringSystemDesign/模版/figures/钢桶受力分析.png', 
            dpi=300, bbox_inches='tight', facecolor='white')
plt.show()

print("钢桶受力与力矩分析图已保存！")