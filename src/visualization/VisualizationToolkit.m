classdef VisualizationToolkit < handle
    %VISUALIZATIONTOOLKIT 系泊系统设计可视化工具包
    %   提供全面的数据可视化和图表生成功能
    %   支持2D/3D绘图、动态图表、交互式可视化
    
    properties (Access = private)
        figure_handles   % 图表句柄存储
        chart_counter   % 图表计数器
        default_colors  % 默认颜色方案
        save_directory  % 图表保存目录
    end
    
    methods (Access = public)
        function obj = VisualizationToolkit()
            %构造函数
            obj.figure_handles = containers.Map();
            obj.chart_counter = 0;
            obj.default_colors = obj.setupDefaultColors();
            obj.save_directory = fullfile(pwd, 'charts');
            
            % 确保保存目录存在
            if ~exist(obj.save_directory, 'dir')
                mkdir(obj.save_directory);
            end
            
            fprintf('可视化工具包初始化完成\n');
        end
        
        %% 系统几何可视化
        function fig_handle = plotSystemGeometry(obj, results, varargin)
            %绘制系泊系统几何形状
            %   显示锚链形状、浮标位置、钢桶钢管配置
            
            p = inputParser;
            addParameter(p, 'ShowLabels', true, @islogical);
            addParameter(p, 'ShowDimensions', true, @islogical);
            addParameter(p, 'ViewAngle', [45, 30], @isnumeric);
            addParameter(p, 'SaveFigure', false, @islogical);
            parse(p, varargin{:});
            
            fig_handle = figure('Name', '系泊系统几何布置', 'Position', [100, 100, 1200, 900]);
            obj.chart_counter = obj.chart_counter + 1;
            obj.figure_handles(sprintf('geometry_%d', obj.chart_counter)) = fig_handle;
            
            % 创建子图布局
            subplot(2, 3, [1, 2, 4, 5]); % 主视图
            obj.plot3DSystemGeometry(results, p.Results);
            
            subplot(2, 3, 3); % 侧视图
            obj.plotSideViewGeometry(results);
            
            subplot(2, 3, 6); % 俯视图
            obj.plotTopViewGeometry(results);
            
            % 添加整体标题和说明
            sgtitle('系泊系统几何布置图', 'FontSize', 16, 'FontWeight', 'bold');
            
            if p.Results.SaveFigure
                obj.saveFigure(fig_handle, 'system_geometry');
            end
        end
        
        function fig_handle = plotChainShape(obj, chain_data, varargin)
            %绘制锚链形状 (悬链线)
            
            p = inputParser;
            addParameter(p, 'ShowSeabed', true, @islogical);
            addParameter(p, 'ShowForces', false, @islogical);
            addParameter(p, 'AnimateChain', false, @islogical);
            parse(p, varargin{:});
            
            fig_handle = figure('Name', '锚链形状分析', 'Position', [200, 150, 1000, 700]);
            obj.chart_counter = obj.chart_counter + 1;
            obj.figure_handles(sprintf('chain_%d', obj.chart_counter)) = fig_handle;
            
            if p.Results.AnimateChain
                obj.animateChainDeformation(chain_data);
            else
                obj.plotStaticChainShape(chain_data, p.Results);
            end
            
            if p.Results.SaveFigure
                obj.saveFigure(fig_handle, 'chain_shape');
            end
        end
        
        %% 性能分析可视化
        function fig_handle = plotPerformanceComparison(obj, results_array, algorithm_names, varargin)
            %绘制算法性能对比图表
            
            p = inputParser;
            addParameter(p, 'Metrics', {'execution_time', 'convergence', 'robustness'}, @iscell);
            addParameter(p, 'ChartType', 'bar', @ischar); % 'bar', 'radar', 'scatter'
            addParameter(p, 'ShowStatistics', true, @islogical);
            parse(p, varargin{:});
            
            fig_handle = figure('Name', '算法性能对比分析', 'Position', [150, 100, 1400, 1000]);
            obj.chart_counter = obj.chart_counter + 1;
            obj.figure_handles(sprintf('performance_%d', obj.chart_counter)) = fig_handle;
            
            switch lower(p.Results.ChartType)
                case 'bar'
                    obj.plotPerformanceBarChart(results_array, algorithm_names, p.Results.Metrics);
                case 'radar'
                    obj.plotPerformanceRadarChart(results_array, algorithm_names, p.Results.Metrics);
                case 'scatter'
                    obj.plotPerformanceScatterChart(results_array, algorithm_names);
            end
            
            if p.Results.SaveFigure
                obj.saveFigure(fig_handle, 'performance_comparison');
            end
        end
        
        function fig_handle = plotOptimizationHistory(obj, history_data, varargin)
            %绘制优化历史曲线
            
            p = inputParser;
            addParameter(p, 'ShowConfidenceInterval', true, @islogical);
            addParameter(p, 'LogScale', false, @islogical);
            addParameter(p, 'HighlightBest', true, @islogical);
            parse(p, varargin{:});
            
            fig_handle = figure('Name', '优化收敛历史', 'Position', [250, 200, 1200, 800]);
            obj.chart_counter = obj.chart_counter + 1;
            obj.figure_handles(sprintf('optimization_%d', obj.chart_counter)) = fig_handle;
            
            obj.plotConvergenceTrajectory(history_data, p.Results);
            
            if p.Results.SaveFigure
                obj.saveFigure(fig_handle, 'optimization_history');
            end
        end
        
        %% 多目标优化可视化
        function fig_handle = plotParetoFront(obj, pareto_solutions, varargin)
            %绘制Pareto前沿
            
            p = inputParser;
            addParameter(p, 'ObjectiveNames', {'目标1', '目标2', '目标3'}, @iscell);
            addParameter(p, 'ShowDominatedSolutions', true, @islogical);
            addParameter(p, 'ColorByRank', true, @islogical);
            parse(p, varargin{:});
            
            fig_handle = figure('Name', 'Pareto前沿分析', 'Position', [300, 250, 1300, 900]);
            obj.chart_counter = obj.chart_counter + 1;
            obj.figure_handles(sprintf('pareto_%d', obj.chart_counter)) = fig_handle;
            
            if size(pareto_solutions, 2) == 2
                obj.plot2DParetoFront(pareto_solutions, p.Results);
            elseif size(pareto_solutions, 2) == 3
                obj.plot3DParetoFront(pareto_solutions, p.Results);
            else
                obj.plotParallelCoordinates(pareto_solutions, p.Results);
            end
            
            if p.Results.SaveFigure
                obj.saveFigure(fig_handle, 'pareto_front');
            end
        end
        
        %% 敏感性分析可视化
        function fig_handle = plotSensitivityAnalysis(obj, sensitivity_data, varargin)
            %绘制参数敏感性分析图
            
            p = inputParser;
            addParameter(p, 'AnalysisType', 'heatmap', @ischar); % 'heatmap', 'tornado', 'spider'
            addParameter(p, 'ShowInteractions', true, @islogical);
            addParameter(p, 'NormalizeValues', true, @islogical);
            parse(p, varargin{:});
            
            fig_handle = figure('Name', '参数敏感性分析', 'Position', [350, 300, 1200, 800]);
            obj.chart_counter = obj.chart_counter + 1;
            obj.figure_handles(sprintf('sensitivity_%d', obj.chart_counter)) = fig_handle;
            
            switch lower(p.Results.AnalysisType)
                case 'heatmap'
                    obj.plotSensitivityHeatmap(sensitivity_data, p.Results);
                case 'tornado'
                    obj.plotTornadoDiagram(sensitivity_data, p.Results);
                case 'spider'
                    obj.plotSpiderDiagram(sensitivity_data, p.Results);
            end
            
            if p.Results.SaveFigure
                obj.saveFigure(fig_handle, 'sensitivity_analysis');
            end
        end
        
        %% 鲁棒性分析可视化
        function fig_handle = plotRobustnessAnalysis(obj, robustness_data, varargin)
            %绘制鲁棒性分析图表
            
            p = inputParser;
            addParameter(p, 'ShowDistributions', true, @islogical);
            addParameter(p, 'ConfidenceLevel', 0.95, @isnumeric);
            addParameter(p, 'ShowOutliers', true, @islogical);
            parse(p, varargin{:});
            
            fig_handle = figure('Name', '鲁棒性分析', 'Position', [400, 350, 1400, 1000]);
            obj.chart_counter = obj.chart_counter + 1;
            obj.figure_handles(sprintf('robustness_%d', obj.chart_counter)) = fig_handle;
            
            obj.plotRobustnessDistributions(robustness_data, p.Results);
            
            if p.Results.SaveFigure
                obj.saveFigure(fig_handle, 'robustness_analysis');
            end
        end
        
        %% 参数空间探索可视化
        function fig_handle = plotParameterSpace(obj, parameter_data, objective_data, varargin)
            %绘制参数空间和目标函数分布
            
            p = inputParser;
            addParameter(p, 'PlotType', 'surface', @ischar); % 'surface', 'contour', 'scatter'
            addParameter(p, 'ShowOptimumPath', true, @islogical);
            addParameter(p, 'InterpolationMethod', 'cubic', @ischar);
            parse(p, varargin{:});
            
            fig_handle = figure('Name', '参数空间探索', 'Position', [450, 400, 1300, 900]);
            obj.chart_counter = obj.chart_counter + 1;
            obj.figure_handles(sprintf('parameter_space_%d', obj.chart_counter)) = fig_handle;
            
            obj.plotParameterSpaceVisualization(parameter_data, objective_data, p.Results);
            
            if p.Results.SaveFigure
                obj.saveFigure(fig_handle, 'parameter_space');
            end
        end
        
        %% 时间序列分析可视化
        function fig_handle = plotTimeSeriesAnalysis(obj, time_data, varargin)
            %绘制时间序列分析图表
            
            p = inputParser;
            addParameter(p, 'ShowTrends', true, @islogical);
            addParameter(p, 'ShowSeasonality', false, @islogical);
            addParameter(p, 'ForecastSteps', 0, @isnumeric);
            parse(p, varargin{:});
            
            fig_handle = figure('Name', '时间序列分析', 'Position', [500, 450, 1200, 700]);
            obj.chart_counter = obj.chart_counter + 1;
            obj.figure_handles(sprintf('timeseries_%d', obj.chart_counter)) = fig_handle;
            
            obj.plotTimeSeriesData(time_data, p.Results);
            
            if p.Results.SaveFigure
                obj.saveFigure(fig_handle, 'timeseries_analysis');
            end
        end
        
        %% 交互式可视化
        function createInteractiveDashboard(obj, data_collection)
            %创建交互式仪表板
            
            dashboard_fig = figure('Name', '系泊系统设计交互式仪表板', ...
                                 'Position', [50, 50, 1600, 1200], ...
                                 'MenuBar', 'none', ...
                                 'ToolBar', 'figure');
            
            obj.setupDashboardLayout(dashboard_fig, data_collection);
            obj.addInteractiveControls(dashboard_fig);
            
            obj.figure_handles('interactive_dashboard') = dashboard_fig;
        end
        
        %% 报告生成可视化
        function report_figures = generateReportFigures(obj, analysis_results, varargin)
            %生成技术报告所需的所有图表
            
            p = inputParser;
            addParameter(p, 'ReportType', 'comprehensive', @ischar);
            addParameter(p, 'FigureQuality', 'high', @ischar);
            addParameter(p, 'AutoSave', true, @islogical);
            parse(p, varargin{:});
            
            report_figures = {};
            
            fprintf('生成报告图表中...\n');
            
            % 系统几何图
            if isfield(analysis_results, 'geometry')
                fprintf('  生成系统几何图...\n');
                fig1 = obj.plotSystemGeometry(analysis_results.geometry, 'SaveFigure', p.Results.AutoSave);
                report_figures{end+1} = fig1;
            end
            
            % 性能对比图
            if isfield(analysis_results, 'performance_comparison')
                fprintf('  生成性能对比图...\n');
                fig2 = obj.plotPerformanceComparison(analysis_results.performance_comparison.results, ...
                                                   analysis_results.performance_comparison.algorithms, ...
                                                   'SaveFigure', p.Results.AutoSave);
                report_figures{end+1} = fig2;
            end
            
            % Pareto前沿图
            if isfield(analysis_results, 'pareto_solutions')
                fprintf('  生成Pareto前沿图...\n');
                fig3 = obj.plotParetoFront(analysis_results.pareto_solutions, 'SaveFigure', p.Results.AutoSave);
                report_figures{end+1} = fig3;
            end
            
            % 敏感性分析图
            if isfield(analysis_results, 'sensitivity_analysis')
                fprintf('  生成敏感性分析图...\n');
                fig4 = obj.plotSensitivityAnalysis(analysis_results.sensitivity_analysis, 'SaveFigure', p.Results.AutoSave);
                report_figures{end+1} = fig4;
            end
            
            % 鲁棒性分析图
            if isfield(analysis_results, 'robustness_analysis')
                fprintf('  生成鲁棒性分析图...\n');
                fig5 = obj.plotRobustnessAnalysis(analysis_results.robustness_analysis, 'SaveFigure', p.Results.AutoSave);
                report_figures{end+1} = fig5;
            end
            
            fprintf('报告图表生成完成，共%d个图表\n', length(report_figures));
        end
        
        %% 工具方法
        function closeAllFigures(obj)
            %关闭所有生成的图表
            handles = values(obj.figure_handles);
            for i = 1:length(handles)
                if ishandle(handles{i})
                    close(handles{i});
                end
            end
            obj.figure_handles = containers.Map();
            obj.chart_counter = 0;
            fprintf('所有图表已关闭\n');
        end
        
        function exportAllFigures(obj, format, varargin)
            %批量导出所有图表
            
            p = inputParser;
            addParameter(p, 'Resolution', 300, @isnumeric);
            addParameter(p, 'Directory', obj.save_directory, @ischar);
            parse(p, varargin{:});
            
            if isempty(obj.figure_handles)
                fprintf('没有可导出的图表\n');
                return;
            end
            
            export_dir = p.Results.Directory;
            if ~exist(export_dir, 'dir')
                mkdir(export_dir);
            end
            
            fprintf('正在导出图表到: %s\n', export_dir);
            
            figure_names = keys(obj.figure_handles);
            handles = values(obj.figure_handles);
            
            for i = 1:length(handles)
                if ishandle(handles{i})
                    filename = fullfile(export_dir, sprintf('%s.%s', figure_names{i}, format));
                    
                    switch lower(format)
                        case {'png', 'jpg', 'jpeg', 'tiff', 'bmp'}
                            print(handles{i}, filename, sprintf('-d%s', format), ...
                                  sprintf('-r%d', p.Results.Resolution));
                        case {'eps', 'pdf'}
                            print(handles{i}, filename, sprintf('-d%s', format));
                        case 'svg'
                            print(handles{i}, filename, '-dsvg');
                        case 'fig'
                            savefig(handles{i}, filename);
                        otherwise
                            warning('不支持的格式: %s', format);
                    end
                    
                    fprintf('  已导出: %s\n', filename);
                end
            end
            
            fprintf('图表导出完成\n');
        end
        
        function listActiveFigures(obj)
            %列出所有活动图表
            if isempty(obj.figure_handles)
                fprintf('当前没有活动图表\n');
            else
                fprintf('当前活动图表:\n');
                figure_names = keys(obj.figure_handles);
                for i = 1:length(figure_names)
                    fprintf('  %d. %s\n', i, figure_names{i});
                end
            end
        end
    end
    
    methods (Access = private)
        function colors = setupDefaultColors(obj)
            %设置默认颜色方案
            colors = struct();
            colors.primary = [0, 0.4470, 0.7410];      % 蓝色
            colors.secondary = [0.8500, 0.3250, 0.0980]; % 橙色
            colors.accent1 = [0.9290, 0.6940, 0.1250];   % 黄色
            colors.accent2 = [0.4940, 0.1840, 0.5560];   % 紫色
            colors.accent3 = [0.4660, 0.6740, 0.1880];   % 绿色
            colors.neutral = [0.6350, 0.0780, 0.1840];   % 红色
            colors.grid = [0.8, 0.8, 0.8];              % 浅灰色
            colors.text = [0.2, 0.2, 0.2];              % 深灰色
        end
        
        function plot3DSystemGeometry(obj, results, options)
            %绘制3D系统几何
            % 这里是简化实现，实际需要根据具体的系统几何数据进行绘制
            
            % 示例：绘制基本的系统轮廓
            hold on;
            
            % 绘制海面
            [X, Y] = meshgrid(-30:5:30, -30:5:30);
            Z = zeros(size(X));
            surf(X, Y, Z, 'FaceColor', [0.3, 0.6, 1.0], 'FaceAlpha', 0.3);
            
            % 绘制锚链 (简化的悬链线)
            x_chain = 0:0.5:20;
            y_chain = zeros(size(x_chain));
            z_chain = -15 + 5 * cosh(x_chain/10) - 5;
            plot3(x_chain, y_chain, z_chain, 'k-', 'LineWidth', 3);
            
            % 绘制浮标
            [xs, ys, zs] = sphere(20);
            surf(xs + 0, ys + 0, zs - 0.5, 'FaceColor', [1, 0.5, 0], 'EdgeColor', 'none');
            
            % 设置视角和标签
            xlabel('水平距离 (m)');
            ylabel('横向距离 (m)');
            zlabel('垂直高度 (m)');
            title('系泊系统3D几何布置');
            
            view(options.ViewAngle);
            axis equal;
            grid on;
            
            if options.ShowLabels
                text(0, 0, 1, '浮标', 'FontSize', 12);
                text(20, 0, -15, '锚点', 'FontSize', 12);
            end
            
            hold off;
        end
        
        function plotSideViewGeometry(obj, results)
            %绘制侧视图
            hold on;
            
            % 示例侧视图
            x = [0, 10, 20];
            z = [0, -5, -15];
            plot(x, z, 'b-o', 'LineWidth', 2, 'MarkerSize', 8);
            
            xlabel('水平距离 (m)');
            ylabel('深度 (m)');
            title('侧视图');
            grid on;
            axis equal;
            
            hold off;
        end
        
        function plotTopViewGeometry(obj, results)
            %绘制俯视图
            hold on;
            
            % 示例俯视图
            theta = 0:0.1:2*pi;
            r = 15;
            x_circle = r * cos(theta);
            y_circle = r * sin(theta);
            plot(x_circle, y_circle, 'r--', 'LineWidth', 1.5);
            
            plot(0, 0, 'bo', 'MarkerSize', 10, 'MarkerFaceColor', 'b');
            
            xlabel('东西方向 (m)');
            ylabel('南北方向 (m)');
            title('俯视图 (游动区域)');
            grid on;
            axis equal;
            
            hold off;
        end
        
        function plotStaticChainShape(obj, chain_data, options)
            %绘制静态锚链形状
            hold on;
            
            % 模拟锚链数据
            x = 0:0.5:25;
            y = -18 + 5 * cosh(x/15) - 5;
            
            plot(x, y, 'b-', 'LineWidth', 3);
            
            if options.ShowSeabed
                fill([0, max(x), max(x), 0], [-20, -20, -18, -18], ...
                     [0.8, 0.6, 0.4], 'EdgeColor', 'none', 'FaceAlpha', 0.7);
                text(max(x)/2, -19, '海床', 'FontSize', 12, 'HorizontalAlignment', 'center');
            end
            
            % 添加水面线
            line([0, max(x)], [0, 0], 'Color', [0.3, 0.6, 1.0], 'LineWidth', 2, 'LineStyle', '--');
            text(max(x)/2, 1, '海面', 'FontSize', 12, 'HorizontalAlignment', 'center');
            
            xlabel('水平距离 (m)');
            ylabel('垂直高度 (m)');
            title('锚链形状 (悬链线)');
            grid on;
            
            hold off;
        end
        
        function plotPerformanceBarChart(obj, results_array, algorithm_names, metrics)
            %绘制性能柱状图
            n_algorithms = length(algorithm_names);
            n_metrics = length(metrics);
            
            % 模拟性能数据
            performance_matrix = rand(n_algorithms, n_metrics) * 100;
            
            subplot(2, 2, [1, 2]);
            bar(performance_matrix);
            set(gca, 'XTickLabel', algorithm_names);
            ylabel('性能值');
            title('算法性能对比');
            legend(metrics, 'Location', 'best');
            grid on;
            
            % 添加详细的子图
            for i = 1:min(3, n_metrics)
                subplot(2, 2, i + 2);
                bar(performance_matrix(:, i));
                set(gca, 'XTickLabel', algorithm_names);
                ylabel('数值');
                title(sprintf('%s 对比', metrics{i}));
                grid on;
            end
        end
        
        function plotParameterSpaceVisualization(obj, parameter_data, objective_data, options)
            %绘制参数空间可视化
            
            if size(parameter_data, 2) >= 2
                subplot(2, 2, [1, 2]);
                scatter3(parameter_data(:, 1), parameter_data(:, 2), objective_data, ...
                        50, objective_data, 'filled');
                xlabel('参数1');
                ylabel('参数2');
                zlabel('目标函数值');
                title('参数空间 - 目标函数分布');
                colorbar;
                
                subplot(2, 2, 3);
                scatter(parameter_data(:, 1), objective_data, 'filled');
                xlabel('参数1');
                ylabel('目标函数值');
                title('参数1影响');
                grid on;
                
                subplot(2, 2, 4);
                scatter(parameter_data(:, 2), objective_data, 'filled');
                xlabel('参数2');
                ylabel('目标函数值');
                title('参数2影响');
                grid on;
            end
        end
        
        function plotRobustnessDistributions(obj, robustness_data, options)
            %绘制鲁棒性分布图
            
            % 模拟数据
            n_scenarios = 1000;
            performance_data = randn(n_scenarios, 3) * 0.1 + repmat([1.5, 4.0, 15.0], n_scenarios, 1);
            
            subplot(2, 3, [1, 2]);
            scatter3(performance_data(:, 1), performance_data(:, 2), performance_data(:, 3), ...
                    20, 'filled', 'alpha', 0.6);
            xlabel('吃水深度 (m)');
            ylabel('倾斜角 (°)');
            zlabel('游动半径 (m)');
            title('性能分布 (蒙特卡洛)');
            
            objective_names = {'吃水深度', '倾斜角', '游动半径'};
            for i = 1:3
                subplot(2, 3, i + 3);
                histogram(performance_data(:, i), 30);
                xlabel(sprintf('%s', objective_names{i}));
                ylabel('频次');
                title(sprintf('%s 分布', objective_names{i}));
                grid on;
                
                % 添加统计线
                mean_val = mean(performance_data(:, i));
                std_val = std(performance_data(:, i));
                xline(mean_val, 'r--', 'LineWidth', 2);
                xline(mean_val + std_val, 'r:', 'LineWidth', 1.5);
                xline(mean_val - std_val, 'r:', 'LineWidth', 1.5);
            end
        end
        
        function saveFigure(obj, fig_handle, base_filename)
            %保存图表
            timestamp = datestr(now, 'yyyymmdd_HHMMSS');
            filename = fullfile(obj.save_directory, sprintf('%s_%s', base_filename, timestamp));
            
            % 保存多种格式
            savefig(fig_handle, [filename, '.fig']);
            print(fig_handle, [filename, '.png'], '-dpng', '-r300');
            print(fig_handle, [filename, '.eps'], '-depsc');
            
            fprintf('图表已保存: %s\n', filename);
        end
        
        function setupDashboardLayout(obj, dashboard_fig, data_collection)
            %设置仪表板布局
            % 这里是仪表板的基本布局设置
            % 实际实现需要更复杂的UI组件
            
            % 创建基本的面板结构
            uicontrol('Parent', dashboard_fig, 'Style', 'text', ...
                     'String', '系泊系统设计交互式仪表板', ...
                     'Position', [50, 1150, 1500, 40], ...
                     'FontSize', 16, 'FontWeight', 'bold');
        end
        
        function addInteractiveControls(obj, dashboard_fig)
            %添加交互式控件
            
            % 参数调节滑块
            uicontrol('Parent', dashboard_fig, 'Style', 'text', ...
                     'String', '重物球质量 (kg):', ...
                     'Position', [50, 1100, 150, 25]);
            
            uicontrol('Parent', dashboard_fig, 'Style', 'slider', ...
                     'Min', 500, 'Max', 8000, 'Value', 3000, ...
                     'Position', [200, 1100, 300, 25], ...
                     'Callback', @obj.updateVisualization);
            
            % 更多控件...
        end
        
        function updateVisualization(obj, src, event)
            %更新可视化回调函数
            % 当参数改变时更新图表
            fprintf('参数已更新，重新计算中...\n');
        end
    end
end