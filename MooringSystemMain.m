function MooringSystemMain()
    %MOORINGSYSTEMMAIN 系泊系统设计工具主程序
    %   完整的系泊系统设计、分析、优化集成平台
    %   基于Paper 4刚体力学方法 + 创新算法扩展
    %
    %   使用方法：
    %     MooringSystemMain()  - 启动交互式界面
    %
    %   作者：基于2016年数学建模竞赛A题Paper 4
    %   版本：v2.0 - 集成原始算法与先进优化方法
    %   日期：2025

    % 添加所有必要的路径
    addPaths();
    
    % 显示欢迎信息
    displayWelcomeBanner();
    
    % 检查系统环境
    checkSystemEnvironment();
    
    % 启动主程序
    try
        designer = MooringSystemInteractiveDesigner();
    catch ME
        fprintf('\n错误：无法启动系泊系统设计工具\n');
        fprintf('错误信息：%s\n', ME.message);
        fprintf('请检查MATLAB版本和工具箱依赖\n');
        
        % 显示故障排除信息
        displayTroubleshootingInfo();
    end
end

function addPaths()
    %添加必要的搜索路径
    fprintf('正在配置搜索路径...\n');
    
    % 获取主目录
    main_dir = fileparts(mfilename('fullpath'));
    
    % 添加核心路径
    addpath(genpath(fullfile(main_dir, 'src')));
    
    % 创建必要的目录结构
    createDirectoryStructure(main_dir);
    
    fprintf('路径配置完成。\n');
end

function createDirectoryStructure(main_dir)
    %创建必要的目录结构
    dirs_to_create = {
        'data',
        'results', 
        'reports',
        'charts',
        'exports',
        'temp',
        'logs'
    };
    
    for i = 1:length(dirs_to_create)
        dir_path = fullfile(main_dir, dirs_to_create{i});
        if ~exist(dir_path, 'dir')
            mkdir(dir_path);
        end
    end
end

function displayWelcomeBanner()
    %显示欢迎横幅
    fprintf('\n');
    fprintf('================================================================\n');
    fprintf('              系泊系统交互式设计优化平台 v2.0                    \n');
    fprintf('================================================================\n');
    fprintf('                                                                \n');
    fprintf('  基于Paper 4刚体力学方法的完整实现 + 创新算法扩展               \n');
    fprintf('                                                                \n');
    fprintf('  【核心功能】                                                  \n');
    fprintf('  ✓ Paper 4原始算法完整实现 (100%%代码一致性)                  \n');
    fprintf('  ✓ NSGA-III多目标进化优化                                      \n');
    fprintf('  ✓ 贝叶斯优化智能参数调优                                      \n');
    fprintf('  ✓ 分布式鲁棒优化设计                                          \n');
    fprintf('  ✓ 机器学习代理模型加速                                        \n');
    fprintf('  ✓ 全方位性能分析与对比                                        \n');
    fprintf('  ✓ 交互式参数探索界面                                          \n');
    fprintf('                                                                \n');
    fprintf('  【技术特色】                                                  \n');
    fprintf('  • 保持原始论文代码100%%不变                                   \n');
    fprintf('  • 集成最新优化算法                                            \n');
    fprintf('  • 多目标优化与鲁棒设计                                        \n');
    fprintf('  • 智能代理模型与加速计算                                      \n');
    fprintf('  • 全面的可视化分析工具                                        \n');
    fprintf('                                                                \n');
    fprintf('================================================================\n');
    fprintf('\n');
end

function checkSystemEnvironment()
    %检查系统环境
    fprintf('正在检查系统环境...\n');
    
    % 检查MATLAB版本
    matlab_version = version('-release');
    fprintf('  MATLAB版本: %s\n', matlab_version);
    
    % 检查必要工具箱
    required_toolboxes = {
        'Optimization Toolbox',
        'Statistics and Machine Learning Toolbox',
        'Global Optimization Toolbox'
    };
    
    missing_toolboxes = {};
    
    for i = 1:length(required_toolboxes)
        toolbox_name = required_toolboxes{i};
        if checkToolboxAvailability(toolbox_name)
            fprintf('  ✓ %s: 可用\n', toolbox_name);
        else
            fprintf('  ✗ %s: 不可用 (部分功能可能受限)\n', toolbox_name);
            missing_toolboxes{end+1} = toolbox_name;
        end
    end
    
    % 检查内存
    try
        [~, system_view] = memory;
        available_memory = system_view.PhysicalMemory.Available / 1e9;
        fprintf('  可用内存: %.1f GB\n', available_memory);
        
        if available_memory < 2
            fprintf('  ⚠ 警告: 可用内存较少，大规模计算可能受限\n');
        end
    catch
        fprintf('  内存信息: 无法获取（部分平台不支持）\n');
    end
    
    % 显示建议
    if ~isempty(missing_toolboxes)
        fprintf('\n  建议安装以下工具箱以获得完整功能:\n');
        for i = 1:length(missing_toolboxes)
            fprintf('    - %s\n', missing_toolboxes{i});
        end
    end
    
    fprintf('环境检查完成。\n\n');
end

function has_toolbox = checkToolboxAvailability(toolbox_name)
    %检查工具箱可用性
    try
        has_toolbox = license('test', getToolboxCode(toolbox_name));
    catch
        has_toolbox = false;
    end
end

function toolbox_code = getToolboxCode(toolbox_name)
    %获取工具箱许可证代码
    switch toolbox_name
        case 'Optimization Toolbox'
            toolbox_code = 'optimization_toolbox';
        case 'Statistics and Machine Learning Toolbox'
            toolbox_code = 'statistics_toolbox';
        case 'Global Optimization Toolbox'
            toolbox_code = 'GADS_toolbox';
        otherwise
            toolbox_code = '';
    end
end

function displayTroubleshootingInfo()
    %显示故障排除信息
    fprintf('\n=== 故障排除信息 ===\n');
    fprintf('1. 确保MATLAB版本 >= R2018b\n');
    fprintf('2. 检查文件路径中是否包含中文字符\n');
    fprintf('3. 确保有足够的磁盘空间 (建议 >= 1GB)\n');
    fprintf('4. 重新启动MATLAB并清除工作空间\n');
    fprintf('5. 检查网络连接（如需下载依赖）\n');
    fprintf('\n如问题持续，请联系技术支持。\n');
end

function quickStart()
    %快速启动脚本
    if ~exist('OCTAVE_VERSION', 'builtin')
        % MATLAB环境
        fprintf('正在启动系泊系统设计工具...\n');
        MooringSystemMain();
    else
        % Octave环境 (有限支持)
        fprintf('检测到Octave环境，部分功能可能不可用。\n');
        fprintf('建议使用MATLAB以获得完整体验。\n');
    end
end