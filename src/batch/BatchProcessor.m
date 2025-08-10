classdef BatchProcessor < handle
    %BATCHPROCESSOR 批量处理工具
    %   支持大规模参数扫描、多算法批量对比、自动作业调度
    %   集成Paper 4原始算法与先进优化方法的批量执行
    
    properties (Access = private)
        job_queue           % 作业队列
        completed_jobs      % 已完成作业
        failed_jobs         % 失败作业
        worker_pool         % 工作进程池
        batch_results       % 批处理结果
        progress_tracker    % 进度跟踪器
        log_manager         % 日志管理器
        resource_monitor    % 资源监控器
    end
    
    properties (Constant, Access = private)
        % 批处理模式
        BATCH_MODES = {
            'parameter_sweep',      % 参数扫描
            'algorithm_comparison', % 算法对比
            'monte_carlo',         % 蒙特卡洛分析
            'sensitivity_analysis', % 敏感性分析
            'robustness_test',     % 鲁棒性测试
            'scalability_test',    % 可扩展性测试
            'benchmark_suite'      % 基准测试套件
        };
        
        % 作业状态
        JOB_STATUS = {'pending', 'running', 'completed', 'failed', 'cancelled'};
        
        % 优先级级别
        PRIORITY_LEVELS = {'low', 'normal', 'high', 'urgent'};
    end
    
    methods (Access = public)
        function obj = BatchProcessor()
            %构造函数
            obj.job_queue = containers.Map('KeyType', 'char', 'ValueType', 'any');
            obj.completed_jobs = containers.Map('KeyType', 'char', 'ValueType', 'any');
            obj.failed_jobs = containers.Map('KeyType', 'char', 'ValueType', 'any');
            obj.batch_results = containers.Map('KeyType', 'char', 'ValueType', 'any');
            obj.progress_tracker = obj.initializeProgressTracker();
            obj.log_manager = obj.initializeLogManager();
            obj.resource_monitor = obj.initializeResourceMonitor();
            
            fprintf('批量处理工具初始化完成\n');
        end
        
        %% 核心批处理功能
        function batch_id = createParameterSweepBatch(obj, parameter_ranges, algorithms, varargin)
            %创建参数扫描批处理任务
            %   输入: parameter_ranges - 参数范围定义
            %         algorithms - 算法列表
            %   输出: batch_id - 批处理ID
            
            p = inputParser;
            addParameter(p, 'BatchName', 'parameter_sweep', @ischar);
            addParameter(p, 'Priority', 'normal', @ischar);
            addParameter(p, 'MaxWorkers', 4, @isnumeric);
            addParameter(p, 'SaveResults', true, @islogical);
            addParameter(p, 'GenerateReport', true, @islogical);
            parse(p, varargin{:});
            
            fprintf('\n=== 创建参数扫描批处理任务 ===\n');
            fprintf('批处理名称: %s\n', p.Results.BatchName);
            fprintf('算法数量: %d\n', length(algorithms));
            
            % 生成批处理ID
            batch_id = sprintf('%s_%s', p.Results.BatchName, datestr(now, 'yyyymmdd_HHMMSS'));
            
            % 生成参数组合
            parameter_combinations = obj.generateParameterCombinations(parameter_ranges);
            n_combinations = size(parameter_combinations, 1);
            
            fprintf('参数组合数: %d\n', n_combinations);
            fprintf('总作业数: %d\n', n_combinations * length(algorithms));
            
            % 创建作业列表
            jobs = obj.createParameterSweepJobs(parameter_combinations, algorithms, batch_id);
            
            % 添加到作业队列
            for i = 1:length(jobs)
                job_id = jobs{i}.job_id;
                obj.job_queue(job_id) = jobs{i};
            end
            
            % 创建批处理记录
            batch_record = struct();
            batch_record.batch_id = batch_id;
            batch_record.batch_type = 'parameter_sweep';
            batch_record.creation_time = datetime('now');
            batch_record.parameter_ranges = parameter_ranges;
            batch_record.algorithms = algorithms;
            batch_record.total_jobs = length(jobs);
            batch_record.completed_jobs = 0;
            batch_record.failed_jobs = 0;
            batch_record.status = 'created';
            batch_record.settings = p.Results;
            
            obj.batch_results(batch_id) = batch_record;
            
            fprintf('参数扫描批处理任务已创建，ID: %s\n', batch_id);
        end
        
        function batch_id = createAlgorithmComparisonBatch(obj, problem_instances, algorithms, varargin)
            %创建算法对比批处理任务
            
            p = inputParser;
            addParameter(p, 'BatchName', 'algorithm_comparison', @ischar);
            addParameter(p, 'Priority', 'normal', @ischar);
            addParameter(p, 'RunsPerAlgorithm', 30, @isnumeric);
            addParameter(p, 'TimeLimit', 300, @isnumeric); % 每个作业5分钟限制
            parse(p, varargin{:});
            
            fprintf('\n=== 创建算法对比批处理任务 ===\n');
            fprintf('问题实例数: %d\n', length(problem_instances));
            fprintf('算法数量: %d\n', length(algorithms));
            fprintf('每算法运行次数: %d\n', p.Results.RunsPerAlgorithm);
            
            % 生成批处理ID
            batch_id = sprintf('%s_%s', p.Results.BatchName, datestr(now, 'yyyymmdd_HHMMSS'));
            
            % 创建对比作业
            jobs = obj.createAlgorithmComparisonJobs(problem_instances, algorithms, p.Results, batch_id);
            
            % 添加到作业队列
            for i = 1:length(jobs)
                job_id = jobs{i}.job_id;
                obj.job_queue(job_id) = jobs{i};
            end
            
            % 创建批处理记录
            batch_record = struct();
            batch_record.batch_id = batch_id;
            batch_record.batch_type = 'algorithm_comparison';
            batch_record.creation_time = datetime('now');
            batch_record.problem_instances = problem_instances;
            batch_record.algorithms = algorithms;
            batch_record.total_jobs = length(jobs);
            batch_record.completed_jobs = 0;
            batch_record.failed_jobs = 0;
            batch_record.status = 'created';
            batch_record.settings = p.Results;
            
            obj.batch_results(batch_id) = batch_record;
            
            fprintf('算法对比批处理任务已创建，ID: %s\n', batch_id);
        end
        
        function batch_id = createMonteCarloAnalysisBatch(obj, base_parameters, uncertainty_spec, n_samples, varargin)
            %创建蒙特卡洛分析批处理任务
            
            p = inputParser;
            addParameter(p, 'BatchName', 'monte_carlo_analysis', @ischar);
            addParameter(p, 'Algorithm', 'Paper4_Original', @ischar);
            addParameter(p, 'ConfidenceLevel', 0.95, @isnumeric);
            addParameter(p, 'SamplingMethod', 'latin_hypercube', @ischar);
            parse(p, varargin{:});
            
            fprintf('\n=== 创建蒙特卡洛分析批处理任务 ===\n');
            fprintf('样本数量: %d\n', n_samples);
            fprintf('采样方法: %s\n', p.Results.SamplingMethod);
            fprintf('算法: %s\n', p.Results.Algorithm);
            
            % 生成批处理ID
            batch_id = sprintf('%s_%s', p.Results.BatchName, datestr(now, 'yyyymmdd_HHMMSS'));
            
            % 生成不确定参数样本
            parameter_samples = obj.generateUncertaintysamples(base_parameters, uncertainty_spec, n_samples, p.Results.SamplingMethod);
            
            % 创建蒙特卡洛作业
            jobs = obj.createMonteCarloJobs(parameter_samples, p.Results.Algorithm, batch_id);
            
            % 添加到作业队列
            for i = 1:length(jobs)
                job_id = jobs{i}.job_id;
                obj.job_queue(job_id) = jobs{i};
            end
            
            % 创建批处理记录
            batch_record = struct();
            batch_record.batch_id = batch_id;
            batch_record.batch_type = 'monte_carlo';
            batch_record.creation_time = datetime('now');
            batch_record.base_parameters = base_parameters;
            batch_record.uncertainty_spec = uncertainty_spec;
            batch_record.n_samples = n_samples;
            batch_record.algorithm = p.Results.Algorithm;
            batch_record.total_jobs = length(jobs);
            batch_record.completed_jobs = 0;
            batch_record.failed_jobs = 0;
            batch_record.status = 'created';
            batch_record.settings = p.Results;
            
            obj.batch_results(batch_id) = batch_record;
            
            fprintf('蒙特卡洛分析批处理任务已创建，ID: %s\n', batch_id);
        end
        
        function batch_id = createBenchmarkSuiteBatch(obj, benchmark_problems, algorithms, varargin)
            %创建基准测试套件批处理任务
            
            p = inputParser;
            addParameter(p, 'BatchName', 'benchmark_suite', @ischar);
            addParameter(p, 'TestRounds', 10, @isnumeric);
            addParameter(p, 'TimeLimit', 600, @isnumeric);
            addParameter(p, 'GenerateReport', true, @islogical);
            parse(p, varargin{:});
            
            fprintf('\n=== 创建基准测试套件批处理任务 ===\n');
            fprintf('基准问题数: %d\n', length(benchmark_problems));
            fprintf('算法数量: %d\n', length(algorithms));
            fprintf('测试轮次: %d\n', p.Results.TestRounds);
            
            % 生成批处理ID
            batch_id = sprintf('%s_%s', p.Results.BatchName, datestr(now, 'yyyymmdd_HHMMSS'));
            
            % 创建基准测试作业
            jobs = obj.createBenchmarkJobs(benchmark_problems, algorithms, p.Results, batch_id);
            
            % 添加到作业队列
            for i = 1:length(jobs)
                job_id = jobs{i}.job_id;
                obj.job_queue(job_id) = jobs{i};
            end
            
            % 创建批处理记录
            batch_record = struct();
            batch_record.batch_id = batch_id;
            batch_record.batch_type = 'benchmark_suite';
            batch_record.creation_time = datetime('now');
            batch_record.benchmark_problems = benchmark_problems;
            batch_record.algorithms = algorithms;
            batch_record.total_jobs = length(jobs);
            batch_record.completed_jobs = 0;
            batch_record.failed_jobs = 0;
            batch_record.status = 'created';
            batch_record.settings = p.Results;
            
            obj.batch_results(batch_id) = batch_record;
            
            fprintf('基准测试套件批处理任务已创建，ID: %s\n', batch_id);
        end
        
        %% 作业执行和管理
        function executeBatch(obj, batch_id, varargin)
            %执行批处理任务
            
            p = inputParser;
            addParameter(p, 'MaxWorkers', 4, @isnumeric);
            addParameter(p, 'ShowProgress', true, @islogical);
            addParameter(p, 'SaveIntermediateResults', true, @islogical);
            parse(p, varargin{:});
            
            fprintf('\n=== 开始执行批处理任务 ===\n');
            fprintf('批处理ID: %s\n', batch_id);
            
            if ~obj.batch_results.isKey(batch_id)
                error('批处理任务不存在: %s', batch_id);
            end
            
            batch_record = obj.batch_results(batch_id);
            batch_record.status = 'running';
            batch_record.start_time = datetime('now');
            obj.batch_results(batch_id) = batch_record;
            
            % 获取该批次的所有作业
            batch_jobs = obj.getBatchJobs(batch_id);
            total_jobs = length(batch_jobs);
            
            fprintf('作业总数: %d\n', total_jobs);
            fprintf('最大工作进程数: %d\n', p.Results.MaxWorkers);
            
            % 初始化进度跟踪
            obj.initializeBatchProgress(batch_id, total_jobs);
            
            % 执行作业
            completed_count = 0;
            failed_count = 0;
            
            % 简单的顺序执行 (在实际应用中可以使用并行计算工具箱)
            for i = 1:total_jobs
                job = batch_jobs{i};
                
                if p.Results.ShowProgress
                    fprintf('执行作业 %d/%d: %s\n', i, total_jobs, job.job_id);
                end
                
                try
                    % 执行单个作业
                    job_result = obj.executeJob(job);
                    
                    % 保存结果
                    job.result = job_result;
                    job.status = 'completed';
                    job.completion_time = datetime('now');
                    
                    obj.completed_jobs(job.job_id) = job;
                    completed_count = completed_count + 1;
                    
                    if p.Results.SaveIntermediateResults
                        obj.saveIntermediateResult(batch_id, job);
                    end
                    
                catch ME
                    % 处理作业失败
                    job.status = 'failed';
                    job.error_message = ME.message;
                    job.failure_time = datetime('now');
                    
                    obj.failed_jobs(job.job_id) = job;
                    failed_count = failed_count + 1;
                    
                    fprintf('作业失败: %s - %s\n', job.job_id, ME.message);
                end
                
                % 更新进度
                obj.updateBatchProgress(batch_id, i, total_jobs);
            end
            
            % 更新批处理状态
            batch_record = obj.batch_results(batch_id);
            batch_record.status = 'completed';
            batch_record.end_time = datetime('now');
            batch_record.completed_jobs = completed_count;
            batch_record.failed_jobs = failed_count;
            batch_record.success_rate = completed_count / total_jobs;
            obj.batch_results(batch_id) = batch_record;
            
            fprintf('\n批处理任务执行完成\n');
            fprintf('成功作业: %d/%d (%.1f%%)\n', completed_count, total_jobs, (completed_count/total_jobs)*100);
            fprintf('失败作业: %d/%d (%.1f%%)\n', failed_count, total_jobs, (failed_count/total_jobs)*100);
            
            % 生成批处理报告
            if batch_record.settings.GenerateReport
                obj.generateBatchReport(batch_id);
            end
        end
        
        function pauseBatch(obj, batch_id)
            %暂停批处理任务
            
            if obj.batch_results.isKey(batch_id)
                batch_record = obj.batch_results(batch_id);
                batch_record.status = 'paused';
                batch_record.pause_time = datetime('now');
                obj.batch_results(batch_id) = batch_record;
                
                fprintf('批处理任务已暂停: %s\n', batch_id);
            else
                fprintf('批处理任务不存在: %s\n', batch_id);
            end
        end
        
        function resumeBatch(obj, batch_id)
            %恢复批处理任务
            
            if obj.batch_results.isKey(batch_id)
                batch_record = obj.batch_results(batch_id);
                batch_record.status = 'running';
                batch_record.resume_time = datetime('now');
                obj.batch_results(batch_id) = batch_record;
                
                fprintf('批处理任务已恢复: %s\n', batch_id);
            else
                fprintf('批处理任务不存在: %s\n', batch_id);
            end
        end
        
        function cancelBatch(obj, batch_id)
            %取消批处理任务
            
            if obj.batch_results.isKey(batch_id)
                batch_record = obj.batch_results(batch_id);
                batch_record.status = 'cancelled';
                batch_record.cancel_time = datetime('now');
                obj.batch_results(batch_id) = batch_record;
                
                % 取消所有待处理的作业
                batch_jobs = obj.getBatchJobs(batch_id);
                for i = 1:length(batch_jobs)
                    job = batch_jobs{i};
                    if strcmp(job.status, 'pending')
                        job.status = 'cancelled';
                        obj.job_queue(job.job_id) = job;
                    end
                end
                
                fprintf('批处理任务已取消: %s\n', batch_id);
            else
                fprintf('批处理任务不存在: %s\n', batch_id);
            end
        end
        
        %% 结果分析和报告
        function results = analyzeBatchResults(obj, batch_id, varargin)
            %分析批处理结果
            
            p = inputParser;
            addParameter(p, 'AnalysisType', 'comprehensive', @ischar);
            addParameter(p, 'GenerateVisualization', true, @islogical);
            addParameter(p, 'StatisticalTests', true, @islogical);
            parse(p, varargin{:});
            
            fprintf('\n=== 分析批处理结果 ===\n');
            fprintf('批处理ID: %s\n', batch_id);
            
            if ~obj.batch_results.isKey(batch_id)
                error('批处理任务不存在: %s', batch_id);
            end
            
            batch_record = obj.batch_results(batch_id);
            
            % 收集所有完成的作业结果
            completed_jobs = obj.getCompletedBatchJobs(batch_id);
            
            if isempty(completed_jobs)
                fprintf('没有已完成的作业可供分析\n');
                results = struct();
                return;
            end
            
            results = struct();
            results.batch_id = batch_id;
            results.batch_type = batch_record.batch_type;
            results.analysis_time = datetime('now');
            results.total_completed_jobs = length(completed_jobs);
            
            % 根据批处理类型进行专门分析
            switch batch_record.batch_type
                case 'parameter_sweep'
                    results.parameter_analysis = obj.analyzeParameterSweepResults(completed_jobs, batch_record);
                case 'algorithm_comparison'
                    results.comparison_analysis = obj.analyzeAlgorithmComparisonResults(completed_jobs, batch_record);
                case 'monte_carlo'
                    results.monte_carlo_analysis = obj.analyzeMonteCarloResults(completed_jobs, batch_record);
                case 'benchmark_suite'
                    results.benchmark_analysis = obj.analyzeBenchmarkResults(completed_jobs, batch_record);
                otherwise
                    results.general_analysis = obj.analyzeGeneralResults(completed_jobs);
            end
            
            % 统计分析
            if p.Results.StatisticalTests
                results.statistical_analysis = obj.performBatchStatisticalAnalysis(completed_jobs, batch_record);
            end
            
            % 可视化
            if p.Results.GenerateVisualization
                results.visualizations = obj.generateBatchVisualizations(results);
            end
            
            fprintf('批处理结果分析完成\n');
        end
        
        function report_file = generateBatchReport(obj, batch_id, varargin)
            %生成批处理报告
            
            p = inputParser;
            addParameter(p, 'ReportFormat', 'detailed', @ischar); % 'summary', 'detailed', 'technical'
            addParameter(p, 'IncludeVisualizations', true, @islogical);
            addParameter(p, 'SaveDirectory', pwd, @ischar);
            parse(p, varargin{:});
            
            fprintf('\n=== 生成批处理报告 ===\n');
            fprintf('批处理ID: %s\n', batch_id);
            
            if ~obj.batch_results.isKey(batch_id)
                error('批处理任务不存在: %s', batch_id);
            end
            
            % 分析结果
            analysis_results = obj.analyzeBatchResults(batch_id, 'GenerateVisualization', p.Results.IncludeVisualizations);
            
            % 生成报告
            timestamp = datestr(now, 'yyyymmdd_HHMMSS');
            report_filename = sprintf('batch_report_%s_%s.txt', batch_id, timestamp);
            report_file = fullfile(p.Results.SaveDirectory, report_filename);
            
            try
                fid = fopen(report_file, 'w');
                
                % 写入报告头部
                obj.writeBatchReportHeader(fid, batch_id, analysis_results);
                
                % 写入执行摘要
                obj.writeBatchExecutionSummary(fid, batch_id);
                
                % 写入详细分析结果
                obj.writeBatchAnalysisResults(fid, analysis_results, p.Results.ReportFormat);
                
                % 写入结论和建议
                obj.writeBatchConclusions(fid, analysis_results);
                
                fclose(fid);
                
                fprintf('批处理报告已生成: %s\n', report_file);
                
            catch ME
                if exist('fid', 'var') && fid ~= -1
                    fclose(fid);
                end
                error('生成报告失败: %s', ME.message);
            end
        end
        
        %% 查询和管理功能
        function listBatches(obj, varargin)
            %列出所有批处理任务
            
            p = inputParser;
            addParameter(p, 'Status', 'all', @ischar); % 'all', 'running', 'completed', 'failed'
            addParameter(p, 'SortBy', 'creation_time', @ischar);
            parse(p, varargin{:});
            
            fprintf('\n=== 批处理任务列表 ===\n');
            
            if obj.batch_results.Count == 0
                fprintf('当前没有批处理任务\n');
                return;
            end
            
            batch_ids = keys(obj.batch_results);
            batch_data = values(obj.batch_results);
            
            % 过滤和排序
            filtered_batches = {};
            for i = 1:length(batch_data)
                batch = batch_data{i};
                if strcmp(p.Results.Status, 'all') || strcmp(batch.status, p.Results.Status)
                    filtered_batches{end+1} = batch;
                end
            end
            
            if isempty(filtered_batches)
                fprintf('没有符合条件的批处理任务\n');
                return;
            end
            
            % 显示批处理任务信息
            for i = 1:length(filtered_batches)
                batch = filtered_batches{i};
                
                fprintf('%d. ID: %s\n', i, batch.batch_id);
                fprintf('   类型: %s\n', batch.batch_type);
                fprintf('   状态: %s\n', batch.status);
                fprintf('   创建时间: %s\n', datestr(batch.creation_time));
                fprintf('   总作业数: %d\n', batch.total_jobs);
                fprintf('   已完成: %d\n', batch.completed_jobs);
                fprintf('   失败: %d\n', batch.failed_jobs);
                
                if isfield(batch, 'success_rate')
                    fprintf('   成功率: %.1f%%\n', batch.success_rate * 100);
                end
                
                fprintf('\n');
            end
        end
        
        function status = getBatchStatus(obj, batch_id)
            %获取批处理任务状态
            
            if obj.batch_results.isKey(batch_id)
                batch_record = obj.batch_results(batch_id);
                
                status = struct();
                status.batch_id = batch_id;
                status.status = batch_record.status;
                status.total_jobs = batch_record.total_jobs;
                status.completed_jobs = batch_record.completed_jobs;
                status.failed_jobs = batch_record.failed_jobs;
                
                if isfield(batch_record, 'success_rate')
                    status.success_rate = batch_record.success_rate;
                end
                
                % 计算进度
                if batch_record.total_jobs > 0
                    status.progress_percent = (batch_record.completed_jobs + batch_record.failed_jobs) / batch_record.total_jobs * 100;
                else
                    status.progress_percent = 0;
                end
                
                fprintf('\n批处理任务状态: %s\n', batch_id);
                fprintf('状态: %s\n', status.status);
                fprintf('进度: %.1f%% (%d/%d)\n', status.progress_percent, ...
                        batch_record.completed_jobs + batch_record.failed_jobs, batch_record.total_jobs);
                fprintf('成功: %d, 失败: %d\n', batch_record.completed_jobs, batch_record.failed_jobs);
            else
                status = [];
                fprintf('批处理任务不存在: %s\n', batch_id);
            end
        end
        
        function deleteBatch(obj, batch_id)
            %删除批处理任务
            
            if obj.batch_results.isKey(batch_id)
                % 删除相关作业
                batch_jobs = obj.getBatchJobs(batch_id);
                for i = 1:length(batch_jobs)
                    job_id = batch_jobs{i}.job_id;
                    if obj.job_queue.isKey(job_id)
                        obj.job_queue.remove(job_id);
                    end
                    if obj.completed_jobs.isKey(job_id)
                        obj.completed_jobs.remove(job_id);
                    end
                    if obj.failed_jobs.isKey(job_id)
                        obj.failed_jobs.remove(job_id);
                    end
                end
                
                % 删除批处理记录
                obj.batch_results.remove(batch_id);
                
                fprintf('批处理任务已删除: %s\n', batch_id);
            else
                fprintf('批处理任务不存在: %s\n', batch_id);
            end
        end
        
        function clearAllBatches(obj)
            %清空所有批处理任务
            
            obj.job_queue = containers.Map('KeyType', 'char', 'ValueType', 'any');
            obj.completed_jobs = containers.Map('KeyType', 'char', 'ValueType', 'any');
            obj.failed_jobs = containers.Map('KeyType', 'char', 'ValueType', 'any');
            obj.batch_results = containers.Map('KeyType', 'char', 'ValueType', 'any');
            
            fprintf('所有批处理任务已清空\n');
        end
        
        function exportBatchResults(obj, batch_id, export_format, varargin)
            %导出批处理结果
            
            p = inputParser;
            addParameter(p, 'ExportDirectory', pwd, @ischar);
            addParameter(p, 'IncludeRawData', true, @islogical);
            addParameter(p, 'CompressResults', false, @islogical);
            parse(p, varargin{:});
            
            fprintf('\n=== 导出批处理结果 ===\n');
            fprintf('批处理ID: %s\n', batch_id);
            fprintf('导出格式: %s\n', export_format);
            
            if ~obj.batch_results.isKey(batch_id)
                error('批处理任务不存在: %s', batch_id);
            end
            
            % 分析结果
            analysis_results = obj.analyzeBatchResults(batch_id);
            
            timestamp = datestr(now, 'yyyymmdd_HHMMSS');
            
            switch lower(export_format)
                case 'matlab'
                    filename = fullfile(p.Results.ExportDirectory, sprintf('batch_results_%s_%s.mat', batch_id, timestamp));
                    save(filename, 'analysis_results');
                    fprintf('结果已导出到: %s\n', filename);
                    
                case 'excel'
                    fprintf('Excel导出功能需要进一步实现\n');
                    
                case 'csv'
                    obj.exportBatchResultsCSV(analysis_results, batch_id, p.Results.ExportDirectory, timestamp);
                    
                case 'json'
                    filename = fullfile(p.Results.ExportDirectory, sprintf('batch_results_%s_%s.json', batch_id, timestamp));
                    json_str = jsonencode(analysis_results);
                    fid = fopen(filename, 'w');
                    fprintf(fid, '%s', json_str);
                    fclose(fid);
                    fprintf('结果已导出到: %s\n', filename);
                    
                otherwise
                    warning('不支持的导出格式: %s', export_format);
            end
        end
        
        function statistics = getProcessorStatistics(obj)
            %获取处理器统计信息
            
            statistics = struct();
            statistics.total_batches = obj.batch_results.Count;
            statistics.total_jobs_queued = obj.job_queue.Count;
            statistics.total_jobs_completed = obj.completed_jobs.Count;
            statistics.total_jobs_failed = obj.failed_jobs.Count;
            
            % 计算批处理状态统计
            batch_data = values(obj.batch_results);
            status_counts = containers.Map();
            
            for i = 1:length(batch_data)
                batch = batch_data{i};
                status = batch.status;
                
                if status_counts.isKey(status)
                    status_counts(status) = status_counts(status) + 1;
                else
                    status_counts(status) = 1;
                end
            end
            
            statistics.batch_status_counts = status_counts;
            
            if statistics.total_jobs_completed + statistics.total_jobs_failed > 0
                statistics.overall_success_rate = statistics.total_jobs_completed / ...
                    (statistics.total_jobs_completed + statistics.total_jobs_failed);
            else
                statistics.overall_success_rate = 0;
            end
            
            fprintf('\n=== 批处理器统计信息 ===\n');
            fprintf('总批处理任务: %d\n', statistics.total_batches);
            fprintf('队列中作业: %d\n', statistics.total_jobs_queued);
            fprintf('已完成作业: %d\n', statistics.total_jobs_completed);
            fprintf('失败作业: %d\n', statistics.total_jobs_failed);
            fprintf('总体成功率: %.1f%%\n', statistics.overall_success_rate * 100);
        end
    end
    
    methods (Access = private)
        %% 初始化方法
        function progress_tracker = initializeProgressTracker(obj)
            %初始化进度跟踪器
            
            progress_tracker = struct();
            progress_tracker.active_batches = containers.Map();
            progress_tracker.update_interval = 10; % 每10个作业更新一次
        end
        
        function log_manager = initializeLogManager(obj)
            %初始化日志管理器
            
            log_manager = struct();
            log_manager.log_file = fullfile(pwd, 'logs', sprintf('batch_processor_%s.log', datestr(now, 'yyyymmdd')));
            log_manager.log_level = 'info';
            
            % 确保日志目录存在
            log_dir = fileparts(log_manager.log_file);
            if ~exist(log_dir, 'dir')
                mkdir(log_dir);
            end
        end
        
        function resource_monitor = initializeResourceMonitor(obj)
            %初始化资源监控器
            
            resource_monitor = struct();
            resource_monitor.memory_threshold = 0.8; % 80%内存使用阈值
            resource_monitor.cpu_threshold = 0.9;    % 90%CPU使用阈值
            resource_monitor.monitor_interval = 30;  % 30秒监控间隔
        end
        
        %% 作业创建方法
        function parameter_combinations = generateParameterCombinations(obj, parameter_ranges)
            %生成参数组合
            
            parameter_names = fieldnames(parameter_ranges);
            n_params = length(parameter_names);
            
            % 为每个参数生成取值
            param_values = cell(n_params, 1);
            for i = 1:n_params
                param_name = parameter_names{i};
                param_range = parameter_ranges.(param_name);
                
                if isstruct(param_range)
                    % 结构体定义：{min, max, step} 或 {values}
                    if isfield(param_range, 'min') && isfield(param_range, 'max') && isfield(param_range, 'step')
                        param_values{i} = param_range.min:param_range.step:param_range.max;
                    elseif isfield(param_range, 'values')
                        param_values{i} = param_range.values;
                    else
                        error('参数范围定义错误: %s', param_name);
                    end
                elseif isnumeric(param_range) && length(param_range) == 3
                    % 数值数组定义：[min, max, step]
                    param_values{i} = param_range(1):param_range(3):param_range(2);
                else
                    % 直接值数组
                    param_values{i} = param_range;
                end
            end
            
            % 生成所有组合
            if n_params == 1
                combinations = param_values{1}';
                parameter_combinations = array2table(combinations, 'VariableNames', parameter_names);
            else
                [grids{1:n_params}] = ndgrid(param_values{:});
                combinations = zeros(numel(grids{1}), n_params);
                
                for i = 1:n_params
                    combinations(:, i) = grids{i}(:);
                end
                
                parameter_combinations = array2table(combinations, 'VariableNames', parameter_names);
            end
        end
        
        function jobs = createParameterSweepJobs(obj, parameter_combinations, algorithms, batch_id)
            %创建参数扫描作业
            
            n_combinations = height(parameter_combinations);
            n_algorithms = length(algorithms);
            jobs = cell(n_combinations * n_algorithms, 1);
            
            job_index = 1;
            
            for i = 1:n_combinations
                param_combo = parameter_combinations(i, :);
                
                for j = 1:n_algorithms
                    algorithm = algorithms{j};
                    
                    job = struct();
                    job.job_id = sprintf('%s_job_%d_%d', batch_id, i, j);
                    job.batch_id = batch_id;
                    job.job_type = 'parameter_sweep';
                    job.parameters = param_combo;
                    job.algorithm = algorithm;
                    job.status = 'pending';
                    job.creation_time = datetime('now');
                    job.priority = 'normal';
                    
                    jobs{job_index} = job;
                    job_index = job_index + 1;
                end
            end
        end
        
        function jobs = createAlgorithmComparisonJobs(obj, problem_instances, algorithms, settings, batch_id)
            %创建算法对比作业
            
            jobs = {};
            job_index = 1;
            
            for i = 1:length(problem_instances)
                problem = problem_instances{i};
                
                for j = 1:length(algorithms)
                    algorithm = algorithms{j};
                    
                    for run = 1:settings.RunsPerAlgorithm
                        job = struct();
                        job.job_id = sprintf('%s_job_%d_%d_%d', batch_id, i, j, run);
                        job.batch_id = batch_id;
                        job.job_type = 'algorithm_comparison';
                        job.problem_instance = problem;
                        job.algorithm = algorithm;
                        job.run_number = run;
                        job.status = 'pending';
                        job.creation_time = datetime('now');
                        job.priority = 'normal';
                        job.time_limit = settings.TimeLimit;
                        
                        jobs{job_index} = job;
                        job_index = job_index + 1;
                    end
                end
            end
        end
        
        function jobs = createMonteCarloJobs(obj, parameter_samples, algorithm, batch_id)
            %创建蒙特卡洛作业
            
            n_samples = height(parameter_samples);
            jobs = cell(n_samples, 1);
            
            for i = 1:n_samples
                sample = parameter_samples(i, :);
                
                job = struct();
                job.job_id = sprintf('%s_job_%d', batch_id, i);
                job.batch_id = batch_id;
                job.job_type = 'monte_carlo';
                job.parameter_sample = sample;
                job.algorithm = algorithm;
                job.sample_number = i;
                job.status = 'pending';
                job.creation_time = datetime('now');
                job.priority = 'normal';
                
                jobs{i} = job;
            end
        end
        
        function jobs = createBenchmarkJobs(obj, benchmark_problems, algorithms, settings, batch_id)
            %创建基准测试作业
            
            jobs = {};
            job_index = 1;
            
            for i = 1:length(benchmark_problems)
                problem = benchmark_problems{i};
                
                for j = 1:length(algorithms)
                    algorithm = algorithms{j};
                    
                    for round = 1:settings.TestRounds
                        job = struct();
                        job.job_id = sprintf('%s_job_%d_%d_%d', batch_id, i, j, round);
                        job.batch_id = batch_id;
                        job.job_type = 'benchmark';
                        job.benchmark_problem = problem;
                        job.algorithm = algorithm;
                        job.test_round = round;
                        job.status = 'pending';
                        job.creation_time = datetime('now');
                        job.priority = 'normal';
                        job.time_limit = settings.TimeLimit;
                        
                        jobs{job_index} = job;
                        job_index = job_index + 1;
                    end
                end
            end
        end
        
        function parameter_samples = generateUncertaintysamples(obj, base_parameters, uncertainty_spec, n_samples, sampling_method)
            %生成不确定性参数样本
            
            param_names = fieldnames(base_parameters);
            n_params = length(param_names);
            
            % 根据采样方法生成样本
            switch lower(sampling_method)
                case 'monte_carlo'
                    samples = randn(n_samples, n_params);
                    
                case 'latin_hypercube'
                    % 简化的拉丁超立方采样
                    samples = zeros(n_samples, n_params);
                    for i = 1:n_params
                        perm = randperm(n_samples);
                        samples(:, i) = (perm - 0.5) / n_samples;
                    end
                    
                    % 转换为正态分布
                    samples = norminv(samples);
                    
                otherwise
                    % 默认蒙特卡洛
                    samples = randn(n_samples, n_params);
            end
            
            % 应用不确定性规范
            parameter_samples = table();
            
            for i = 1:n_params
                param_name = param_names{i};
                base_value = base_parameters.(param_name);
                
                if isfield(uncertainty_spec, param_name)
                    uncertainty = uncertainty_spec.(param_name);
                    
                    if isstruct(uncertainty)
                        % 结构体定义：{type, parameters}
                        switch lower(uncertainty.type)
                            case 'normal'
                                std_dev = uncertainty.std;
                                param_values = base_value + samples(:, i) * std_dev;
                            case 'uniform'
                                range = uncertainty.range;
                                param_values = base_value + (samples(:, i) - 0.5) * range;
                            case 'relative'
                                rel_std = uncertainty.relative_std;
                                param_values = base_value * (1 + samples(:, i) * rel_std);
                            otherwise
                                param_values = repmat(base_value, n_samples, 1);
                        end
                    else
                        % 简单的相对标准差
                        param_values = base_value * (1 + samples(:, i) * uncertainty);
                    end
                else
                    % 没有不确定性，使用基准值
                    param_values = repmat(base_value, n_samples, 1);
                end
                
                parameter_samples.(param_name) = param_values;
            end
        end
        
        %% 作业执行方法
        function job_result = executeJob(obj, job)
            %执行单个作业
            
            job_result = struct();
            job_result.job_id = job.job_id;
            job_result.start_time = datetime('now');
            
            try
                switch job.job_type
                    case 'parameter_sweep'
                        result = obj.executeParameterSweepJob(job);
                    case 'algorithm_comparison'
                        result = obj.executeAlgorithmComparisonJob(job);
                    case 'monte_carlo'
                        result = obj.executeMonteCarloJob(job);
                    case 'benchmark'
                        result = obj.executeBenchmarkJob(job);
                    otherwise
                        result = obj.executeGenericJob(job);
                end
                
                job_result.result = result;
                job_result.status = 'success';
                
            catch ME
                job_result.status = 'failed';
                job_result.error_message = ME.message;
                job_result.error_stack = ME.stack;
            end
            
            job_result.end_time = datetime('now');
            job_result.execution_time = seconds(job_result.end_time - job_result.start_time);
        end
        
        function result = executeParameterSweepJob(obj, job)
            %执行参数扫描作业
            
            % 模拟参数扫描计算
            params = job.parameters;
            algorithm = job.algorithm;
            
            % 这里应该调用实际的算法
            % 为了演示，我们使用模拟结果
            result = struct();
            result.parameters = params;
            result.algorithm = algorithm;
            result.objective_value = rand() * 100;
            result.execution_time = rand() * 60;
            result.convergence_iterations = randi([10, 500]);
            result.memory_usage = rand() * 1000;
            result.success = true;
        end
        
        function result = executeAlgorithmComparisonJob(obj, job)
            %执行算法对比作业
            
            problem = job.problem_instance;
            algorithm = job.algorithm;
            
            result = struct();
            result.problem = problem;
            result.algorithm = algorithm;
            result.run_number = job.run_number;
            
            % 模拟不同算法的性能
            if contains(lower(algorithm), 'paper4')
                result.objective_value = 80 + randn() * 10;
                result.execution_time = 60 + randn() * 15;
            elseif contains(lower(algorithm), 'nsga')
                result.objective_value = 85 + randn() * 12;
                result.execution_time = 90 + randn() * 20;
            elseif contains(lower(algorithm), 'bayes')
                result.objective_value = 88 + randn() * 8;
                result.execution_time = 45 + randn() * 10;
            else
                result.objective_value = 70 + randn() * 15;
                result.execution_time = 50 + randn() * 20;
            end
            
            result.convergence_iterations = randi([20, 300]);
            result.success = true;
        end
        
        function result = executeMonteCarloJob(obj, job)
            %执行蒙特卡洛作业
            
            sample = job.parameter_sample;
            algorithm = job.algorithm;
            
            result = struct();
            result.parameter_sample = sample;
            result.sample_number = job.sample_number;
            result.algorithm = algorithm;
            
            % 模拟蒙特卡洛样本计算
            result.objective_value = 75 + randn() * 15;
            result.execution_time = 30 + rand() * 20;
            result.constraint_violations = max(0, randn() * 2);
            result.success = true;
        end
        
        function result = executeBenchmarkJob(obj, job)
            %执行基准测试作业
            
            problem = job.benchmark_problem;
            algorithm = job.algorithm;
            
            result = struct();
            result.benchmark_problem = problem;
            result.algorithm = algorithm;
            result.test_round = job.test_round;
            
            % 模拟基准测试结果
            result.objective_value = 60 + rand() * 40;
            result.execution_time = 20 + rand() * 40;
            result.memory_usage = 200 + rand() * 800;
            result.convergence_iterations = randi([5, 200]);
            result.success = rand() > 0.1; % 90%成功率
        end
        
        function result = executeGenericJob(obj, job)
            %执行通用作业
            
            result = struct();
            result.job_type = job.job_type;
            result.objective_value = rand() * 100;
            result.execution_time = rand() * 60;
            result.success = true;
        end
        
        %% 工具方法
        function batch_jobs = getBatchJobs(obj, batch_id)
            %获取指定批次的所有作业
            
            batch_jobs = {};
            
            % 从队列中获取
            job_ids = keys(obj.job_queue);
            for i = 1:length(job_ids)
                job = obj.job_queue(job_ids{i});
                if strcmp(job.batch_id, batch_id)
                    batch_jobs{end+1} = job;
                end
            end
            
            % 从已完成作业中获取
            completed_job_ids = keys(obj.completed_jobs);
            for i = 1:length(completed_job_ids)
                job = obj.completed_jobs(completed_job_ids{i});
                if strcmp(job.batch_id, batch_id)
                    batch_jobs{end+1} = job;
                end
            end
            
            % 从失败作业中获取
            failed_job_ids = keys(obj.failed_jobs);
            for i = 1:length(failed_job_ids)
                job = obj.failed_jobs(failed_job_ids{i});
                if strcmp(job.batch_id, batch_id)
                    batch_jobs{end+1} = job;
                end
            end
        end
        
        function completed_jobs = getCompletedBatchJobs(obj, batch_id)
            %获取指定批次的已完成作业
            
            completed_jobs = {};
            completed_job_ids = keys(obj.completed_jobs);
            
            for i = 1:length(completed_job_ids)
                job = obj.completed_jobs(completed_job_ids{i});
                if strcmp(job.batch_id, batch_id)
                    completed_jobs{end+1} = job;
                end
            end
        end
        
        function initializeBatchProgress(obj, batch_id, total_jobs)
            %初始化批次进度跟踪
            
            progress = struct();
            progress.batch_id = batch_id;
            progress.total_jobs = total_jobs;
            progress.completed_jobs = 0;
            progress.start_time = datetime('now');
            progress.last_update_time = datetime('now');
            
            obj.progress_tracker.active_batches(batch_id) = progress;
        end
        
        function updateBatchProgress(obj, batch_id, completed_count, total_jobs)
            %更新批次进度
            
            if obj.progress_tracker.active_batches.isKey(batch_id)
                progress = obj.progress_tracker.active_batches(batch_id);
                progress.completed_jobs = completed_count;
                progress.last_update_time = datetime('now');
                progress.progress_percent = completed_count / total_jobs * 100;
                
                obj.progress_tracker.active_batches(batch_id) = progress;
                
                % 定期显示进度
                if mod(completed_count, obj.progress_tracker.update_interval) == 0 || completed_count == total_jobs
                    fprintf('批次 %s: %.1f%% (%d/%d)\n', batch_id, progress.progress_percent, completed_count, total_jobs);
                end
            end
        end
        
        function saveIntermediateResult(obj, batch_id, job)
            %保存中间结果
            
            % 创建中间结果目录
            results_dir = fullfile(pwd, 'batch_results', batch_id);
            if ~exist(results_dir, 'dir')
                mkdir(results_dir);
            end
            
            % 保存作业结果
            result_file = fullfile(results_dir, sprintf('%s.mat', job.job_id));
            job_data = job;
            save(result_file, 'job_data');
        end
        
        %% 分析方法实现
        function parameter_analysis = analyzeParameterSweepResults(obj, completed_jobs, batch_record)
            %分析参数扫描结果
            
            parameter_analysis = struct();
            parameter_analysis.total_jobs = length(completed_jobs);
            
            % 提取所有结果
            objective_values = zeros(length(completed_jobs), 1);
            execution_times = zeros(length(completed_jobs), 1);
            parameter_data = [];
            
            for i = 1:length(completed_jobs)
                job = completed_jobs{i};
                if isfield(job, 'result') && job.result.success
                    objective_values(i) = job.result.objective_value;
                    execution_times(i) = job.result.execution_time;
                    
                    if isempty(parameter_data)
                        parameter_data = table2array(job.parameters);
                    else
                        parameter_data = [parameter_data; table2array(job.parameters)];
                    end
                end
            end
            
            parameter_analysis.best_objective = min(objective_values);
            parameter_analysis.worst_objective = max(objective_values);
            parameter_analysis.mean_objective = mean(objective_values);
            parameter_analysis.std_objective = std(objective_values);
            
            parameter_analysis.mean_execution_time = mean(execution_times);
            parameter_analysis.total_execution_time = sum(execution_times);
            
            % 找到最优参数组合
            [~, best_idx] = min(objective_values);
            if ~isempty(parameter_data)
                parameter_analysis.best_parameters = parameter_data(best_idx, :);
            end
            
            parameter_analysis.objective_values = objective_values;
            parameter_analysis.execution_times = execution_times;
            parameter_analysis.parameter_data = parameter_data;
        end
        
        function comparison_analysis = analyzeAlgorithmComparisonResults(obj, completed_jobs, batch_record)
            %分析算法对比结果
            
            comparison_analysis = struct();
            
            % 按算法分组结果
            algorithm_results = containers.Map();
            
            for i = 1:length(completed_jobs)
                job = completed_jobs{i};
                if isfield(job, 'result') && job.result.success
                    algorithm = job.algorithm;
                    
                    if algorithm_results.isKey(algorithm)
                        results = algorithm_results(algorithm);
                    else
                        results = [];
                    end
                    
                    results = [results; job.result.objective_value, job.result.execution_time];
                    algorithm_results(algorithm) = results;
                end
            end
            
            % 计算每个算法的统计量
            algorithms = keys(algorithm_results);
            algorithm_stats = struct();
            
            for i = 1:length(algorithms)
                alg = algorithms{i};
                results = algorithm_results(alg);
                
                stats = struct();
                stats.mean_objective = mean(results(:, 1));
                stats.std_objective = std(results(:, 1));
                stats.best_objective = min(results(:, 1));
                stats.worst_objective = max(results(:, 1));
                stats.mean_time = mean(results(:, 2));
                stats.std_time = std(results(:, 2));
                stats.total_runs = size(results, 1);
                
                algorithm_stats.(alg) = stats;
            end
            
            comparison_analysis.algorithms = algorithms;
            comparison_analysis.algorithm_results = algorithm_results;
            comparison_analysis.algorithm_stats = algorithm_stats;
            
            % 算法排名
            mean_objectives = zeros(length(algorithms), 1);
            for i = 1:length(algorithms)
                mean_objectives(i) = algorithm_stats.(algorithms{i}).mean_objective;
            end
            
            [~, ranking_idx] = sort(mean_objectives);
            comparison_analysis.algorithm_ranking = algorithms(ranking_idx);
        end
        
        function monte_carlo_analysis = analyzeMonteCarloResults(obj, completed_jobs, batch_record)
            %分析蒙特卡洛结果
            
            monte_carlo_analysis = struct();
            monte_carlo_analysis.total_samples = length(completed_jobs);
            
            % 提取所有样本结果
            sample_results = zeros(length(completed_jobs), 1);
            constraint_violations = zeros(length(completed_jobs), 1);
            
            successful_samples = 0;
            
            for i = 1:length(completed_jobs)
                job = completed_jobs{i};
                if isfield(job, 'result') && job.result.success
                    sample_results(i) = job.result.objective_value;
                    constraint_violations(i) = job.result.constraint_violations;
                    successful_samples = successful_samples + 1;
                end
            end
            
            % 统计分析
            monte_carlo_analysis.mean_objective = mean(sample_results);
            monte_carlo_analysis.std_objective = std(sample_results);
            monte_carlo_analysis.min_objective = min(sample_results);
            monte_carlo_analysis.max_objective = max(sample_results);
            
            % 置信区间 (假设95%置信度)
            alpha = 0.05;
            t_critical = 1.96; % 近似值，实际应使用t分布
            margin_error = t_critical * monte_carlo_analysis.std_objective / sqrt(successful_samples);
            
            monte_carlo_analysis.confidence_interval = [
                monte_carlo_analysis.mean_objective - margin_error,
                monte_carlo_analysis.mean_objective + margin_error
            ];
            
            % 约束违反分析
            monte_carlo_analysis.mean_constraint_violation = mean(constraint_violations);
            monte_carlo_analysis.feasibility_rate = sum(constraint_violations == 0) / length(completed_jobs);
            
            monte_carlo_analysis.sample_results = sample_results;
            monte_carlo_analysis.constraint_violations = constraint_violations;
            monte_carlo_analysis.successful_samples = successful_samples;
        end
        
        function benchmark_analysis = analyzeBenchmarkResults(obj, completed_jobs, batch_record)
            %分析基准测试结果
            
            benchmark_analysis = struct();
            
            % 按问题和算法分组
            problem_algorithm_results = containers.Map();
            
            for i = 1:length(completed_jobs)
                job = completed_jobs{i};
                if isfield(job, 'result') && job.result.success
                    problem = job.benchmark_problem.name;
                    algorithm = job.algorithm;
                    key = sprintf('%s_%s', problem, algorithm);
                    
                    if problem_algorithm_results.isKey(key)
                        results = problem_algorithm_results(key);
                    else
                        results = [];
                    end
                    
                    results = [results; job.result.objective_value, job.result.execution_time, job.result.memory_usage];
                    problem_algorithm_results(key) = results;
                end
            end
            
            benchmark_analysis.problem_algorithm_results = problem_algorithm_results;
            
            % 生成性能汇总
            keys_list = keys(problem_algorithm_results);
            performance_summary = struct();
            
            for i = 1:length(keys_list)
                key = keys_list{i};
                results = problem_algorithm_results(key);
                
                summary = struct();
                summary.mean_objective = mean(results(:, 1));
                summary.std_objective = std(results(:, 1));
                summary.mean_time = mean(results(:, 2));
                summary.std_time = std(results(:, 2));
                summary.mean_memory = mean(results(:, 3));
                summary.success_rate = size(results, 1) / batch_record.settings.TestRounds;
                
                performance_summary.(key) = summary;
            end
            
            benchmark_analysis.performance_summary = performance_summary;
        end
        
        function general_analysis = analyzeGeneralResults(obj, completed_jobs)
            %分析通用结果
            
            general_analysis = struct();
            general_analysis.total_completed = length(completed_jobs);
            
            objective_values = [];
            execution_times = [];
            
            for i = 1:length(completed_jobs)
                job = completed_jobs{i};
                if isfield(job, 'result') && isfield(job.result, 'objective_value')
                    objective_values = [objective_values; job.result.objective_value];
                    if isfield(job.result, 'execution_time')
                        execution_times = [execution_times; job.result.execution_time];
                    end
                end
            end
            
            if ~isempty(objective_values)
                general_analysis.mean_objective = mean(objective_values);
                general_analysis.std_objective = std(objective_values);
                general_analysis.best_objective = min(objective_values);
                general_analysis.worst_objective = max(objective_values);
            end
            
            if ~isempty(execution_times)
                general_analysis.mean_execution_time = mean(execution_times);
                general_analysis.total_execution_time = sum(execution_times);
            end
        end
        
        function statistical_analysis = performBatchStatisticalAnalysis(obj, completed_jobs, batch_record)
            %执行批处理统计分析
            
            statistical_analysis = struct();
            statistical_analysis.analysis_type = 'basic';
            
            % 基本统计检验
            if strcmp(batch_record.batch_type, 'algorithm_comparison')
                % 算法对比的方差分析
                statistical_analysis = obj.performAlgorithmComparisonStatistics(completed_jobs);
            elseif strcmp(batch_record.batch_type, 'monte_carlo')
                % 蒙特卡洛分析的分布检验
                statistical_analysis = obj.performMonteCarloStatistics(completed_jobs);
            else
                statistical_analysis.message = '该批处理类型暂不支持统计分析';
            end
        end
        
        function statistics = performAlgorithmComparisonStatistics(obj, completed_jobs)
            %执行算法对比统计分析
            
            statistics = struct();
            
            % 提取算法性能数据
            algorithm_data = containers.Map();
            
            for i = 1:length(completed_jobs)
                job = completed_jobs{i};
                if isfield(job, 'result') && job.result.success
                    algorithm = job.algorithm;
                    
                    if algorithm_data.isKey(algorithm)
                        data = algorithm_data(algorithm);
                    else
                        data = [];
                    end
                    
                    data = [data; job.result.objective_value];
                    algorithm_data(algorithm) = data;
                end
            end
            
            algorithms = keys(algorithm_data);
            
            if length(algorithms) >= 2
                % 执行方差分析
                try
                    data_matrix = [];
                    group_labels = [];
                    
                    for i = 1:length(algorithms)
                        alg_data = algorithm_data(algorithms{i});
                        data_matrix = [data_matrix; alg_data];
                        group_labels = [group_labels; repmat({algorithms{i}}, length(alg_data), 1)];
                    end
                    
                    [p_value, anova_table] = anova1(data_matrix, group_labels, 'off');
                    
                    statistics.anova_p_value = p_value;
                    statistics.anova_significant = p_value < 0.05;
                    statistics.anova_table = anova_table;
                    
                catch
                    statistics.anova_p_value = NaN;
                    statistics.anova_significant = false;
                    statistics.error = '方差分析失败';
                end
            else
                statistics.message = '算法数量不足，无法进行统计分析';
            end
        end
        
        function statistics = performMonteCarloStatistics(obj, completed_jobs)
            %执行蒙特卡洛统计分析
            
            statistics = struct();
            
            % 提取样本数据
            sample_data = [];
            
            for i = 1:length(completed_jobs)
                job = completed_jobs{i};
                if isfield(job, 'result') && job.result.success
                    sample_data = [sample_data; job.result.objective_value];
                end
            end
            
            if length(sample_data) >= 30
                % 正态性检验 (Kolmogorov-Smirnov)
                try
                    [h, p] = kstest((sample_data - mean(sample_data)) / std(sample_data));
                    statistics.normality_test_h = h;
                    statistics.normality_test_p = p;
                    statistics.is_normal = h == 0;
                catch
                    statistics.normality_test_h = NaN;
                    statistics.normality_test_p = NaN;
                    statistics.is_normal = false;
                end
                
                % 描述性统计
                statistics.sample_size = length(sample_data);
                statistics.sample_mean = mean(sample_data);
                statistics.sample_std = std(sample_data);
                statistics.sample_skewness = skewness(sample_data);
                statistics.sample_kurtosis = kurtosis(sample_data);
                
            else
                statistics.message = '样本数量不足，无法进行可靠的统计分析';
            end
        end
        
        function visualizations = generateBatchVisualizations(obj, analysis_results)
            %生成批处理可视化
            
            visualizations = struct();
            
            try
                % 根据批处理类型生成不同的可视化
                switch analysis_results.batch_type
                    case 'parameter_sweep'
                        if isfield(analysis_results, 'parameter_analysis')
                            visualizations.parameter_plots = obj.createParameterSweepPlots(analysis_results.parameter_analysis);
                        end
                        
                    case 'algorithm_comparison'
                        if isfield(analysis_results, 'comparison_analysis')
                            visualizations.comparison_plots = obj.createAlgorithmComparisonPlots(analysis_results.comparison_analysis);
                        end
                        
                    case 'monte_carlo'
                        if isfield(analysis_results, 'monte_carlo_analysis')
                            visualizations.monte_carlo_plots = obj.createMonteCarloPlots(analysis_results.monte_carlo_analysis);
                        end
                        
                    case 'benchmark_suite'
                        if isfield(analysis_results, 'benchmark_analysis')
                            visualizations.benchmark_plots = obj.createBenchmarkPlots(analysis_results.benchmark_analysis);
                        end
                end
                
            catch ME
                visualizations.error = ME.message;
                fprintf('生成可视化时出错: %s\n', ME.message);
            end
        end
        
        function plots = createParameterSweepPlots(obj, parameter_analysis)
            %创建参数扫描图表
            
            plots = struct();
            
            % 目标函数分布直方图
            fig1 = figure('Name', '目标函数分布', 'Position', [100, 100, 800, 600]);
            histogram(parameter_analysis.objective_values, 30);
            xlabel('目标函数值');
            ylabel('频次');
            title('参数扫描目标函数分布');
            grid on;
            
            plots.objective_distribution = fig1;
            
            % 执行时间 vs 目标函数值散点图
            fig2 = figure('Name', '执行时间 vs 目标函数', 'Position', [200, 150, 800, 600]);
            scatter(parameter_analysis.execution_times, parameter_analysis.objective_values);
            xlabel('执行时间 (秒)');
            ylabel('目标函数值');
            title('执行时间 vs 目标函数值');
            grid on;
            
            plots.time_vs_objective = fig2;
        end
        
        function plots = createAlgorithmComparisonPlots(obj, comparison_analysis)
            %创建算法对比图表
            
            plots = struct();
            
            algorithms = comparison_analysis.algorithms;
            n_algorithms = length(algorithms);
            
            % 算法性能箱线图
            fig1 = figure('Name', '算法性能对比', 'Position', [100, 100, 1000, 600]);
            
            data_for_boxplot = [];
            group_labels = [];
            
            for i = 1:n_algorithms
                alg = algorithms{i};
                results = comparison_analysis.algorithm_results(alg);
                data_for_boxplot = [data_for_boxplot; results(:, 1)];
                group_labels = [group_labels; repmat({alg}, size(results, 1), 1)];
            end
            
            boxplot(data_for_boxplot, group_labels);
            ylabel('目标函数值');
            title('算法性能对比 (箱线图)');
            grid on;
            
            plots.performance_boxplot = fig1;
            
            % 算法平均性能柱状图
            fig2 = figure('Name', '算法平均性能', 'Position', [200, 150, 800, 600]);
            
            mean_objectives = zeros(n_algorithms, 1);
            std_objectives = zeros(n_algorithms, 1);
            
            for i = 1:n_algorithms
                alg = algorithms{i};
                stats = comparison_analysis.algorithm_stats.(alg);
                mean_objectives(i) = stats.mean_objective;
                std_objectives(i) = stats.std_objective;
            end
            
            bar(mean_objectives);
            hold on;
            errorbar(1:n_algorithms, mean_objectives, std_objectives, 'k.', 'LineWidth', 1.5);
            hold off;
            
            set(gca, 'XTickLabel', algorithms);
            ylabel('平均目标函数值');
            title('算法平均性能对比');
            grid on;
            
            plots.average_performance_bar = fig2;
        end
        
        function plots = createMonteCarloPlots(obj, monte_carlo_analysis)
            %创建蒙特卡洛分析图表
            
            plots = struct();
            
            % 样本结果分布直方图
            fig1 = figure('Name', '蒙特卡洛样本分布', 'Position', [100, 100, 800, 600]);
            histogram(monte_carlo_analysis.sample_results, 30);
            xlabel('目标函数值');
            ylabel('频次');
            title(sprintf('蒙特卡洛分析样本分布 (n=%d)', monte_carlo_analysis.successful_samples));
            
            % 添加统计信息
            hold on;
            xline(monte_carlo_analysis.mean_objective, 'r-', 'LineWidth', 2, 'Label', '均值');
            xline(monte_carlo_analysis.confidence_interval(1), 'b--', 'LineWidth', 1.5);
            xline(monte_carlo_analysis.confidence_interval(2), 'b--', 'LineWidth', 1.5, 'Label', '95% 置信区间');
            hold off;
            
            legend('Location', 'best');
            grid on;
            
            plots.sample_distribution = fig1;
            
            % Q-Q图检验正态性
            fig2 = figure('Name', '正态性检验 Q-Q图', 'Position', [200, 150, 600, 600]);
            qqplot(monte_carlo_analysis.sample_results);
            title('正态性检验 Q-Q 图');
            grid on;
            
            plots.normality_qq = fig2;
        end
        
        function plots = createBenchmarkPlots(obj, benchmark_analysis)
            %创建基准测试图表
            
            plots = struct();
            
            % 这里需要更复杂的实现来处理基准测试结果
            % 简化版本
            fig1 = figure('Name', '基准测试结果', 'Position', [100, 100, 1000, 600]);
            text(0.5, 0.5, '基准测试可视化功能需要进一步实现', ...
                'HorizontalAlignment', 'center', 'FontSize', 14);
            title('基准测试结果汇总');
            
            plots.benchmark_summary = fig1;
        end
        
        %% 报告生成方法
        function writeBatchReportHeader(obj, fid, batch_id, analysis_results)
            %写入报告头部
            
            fprintf(fid, '系泊系统批处理分析报告\n');
            fprintf(fid, '========================\n\n');
            fprintf(fid, '批处理ID: %s\n', batch_id);
            fprintf(fid, '批处理类型: %s\n', analysis_results.batch_type);
            fprintf(fid, '分析时间: %s\n', datestr(analysis_results.analysis_time));
            fprintf(fid, '总完成作业数: %d\n\n', analysis_results.total_completed_jobs);
        end
        
        function writeBatchExecutionSummary(obj, fid, batch_id)
            %写入执行摘要
            
            batch_record = obj.batch_results(batch_id);
            
            fprintf(fid, '执行摘要\n');
            fprintf(fid, '--------\n');
            fprintf(fid, '创建时间: %s\n', datestr(batch_record.creation_time));
            
            if isfield(batch_record, 'start_time')
                fprintf(fid, '开始时间: %s\n', datestr(batch_record.start_time));
            end
            
            if isfield(batch_record, 'end_time')
                fprintf(fid, '结束时间: %s\n', datestr(batch_record.end_time));
                
                if isfield(batch_record, 'start_time')
                    duration = batch_record.end_time - batch_record.start_time;
                    fprintf(fid, '执行时长: %s\n', char(duration));
                end
            end
            
            fprintf(fid, '总作业数: %d\n', batch_record.total_jobs);
            fprintf(fid, '成功作业: %d\n', batch_record.completed_jobs);
            fprintf(fid, '失败作业: %d\n', batch_record.failed_jobs);
            
            if isfield(batch_record, 'success_rate')
                fprintf(fid, '成功率: %.1f%%\n', batch_record.success_rate * 100);
            end
            
            fprintf(fid, '\n');
        end
        
        function writeBatchAnalysisResults(obj, fid, analysis_results, report_format)
            %写入分析结果
            
            fprintf(fid, '分析结果\n');
            fprintf(fid, '--------\n');
            
            % 根据批处理类型写入不同的分析结果
            switch analysis_results.batch_type
                case 'parameter_sweep'
                    if isfield(analysis_results, 'parameter_analysis')
                        obj.writeParameterSweepAnalysis(fid, analysis_results.parameter_analysis, report_format);
                    end
                    
                case 'algorithm_comparison'
                    if isfield(analysis_results, 'comparison_analysis')
                        obj.writeAlgorithmComparisonAnalysis(fid, analysis_results.comparison_analysis, report_format);
                    end
                    
                case 'monte_carlo'
                    if isfield(analysis_results, 'monte_carlo_analysis')
                        obj.writeMonteCarloAnalysis(fid, analysis_results.monte_carlo_analysis, report_format);
                    end
                    
                case 'benchmark_suite'
                    if isfield(analysis_results, 'benchmark_analysis')
                        obj.writeBenchmarkAnalysis(fid, analysis_results.benchmark_analysis, report_format);
                    end
            end
            
            fprintf(fid, '\n');
        end
        
        function writeParameterSweepAnalysis(obj, fid, parameter_analysis, report_format)
            %写入参数扫描分析
            
            fprintf(fid, '参数扫描分析:\n');
            fprintf(fid, '  最优目标值: %.6f\n', parameter_analysis.best_objective);
            fprintf(fid, '  最差目标值: %.6f\n', parameter_analysis.worst_objective);
            fprintf(fid, '  平均目标值: %.6f ± %.6f\n', parameter_analysis.mean_objective, parameter_analysis.std_objective);
            fprintf(fid, '  平均执行时间: %.2f 秒\n', parameter_analysis.mean_execution_time);
            fprintf(fid, '  总执行时间: %.2f 秒\n', parameter_analysis.total_execution_time);
            
            if isfield(parameter_analysis, 'best_parameters')
                fprintf(fid, '  最优参数组合: [');
                fprintf(fid, '%.4f ', parameter_analysis.best_parameters);
                fprintf(fid, ']\n');
            end
        end
        
        function writeAlgorithmComparisonAnalysis(obj, fid, comparison_analysis, report_format)
            %写入算法对比分析
            
            fprintf(fid, '算法对比分析:\n');
            algorithms = comparison_analysis.algorithms;
            
            fprintf(fid, '  算法排名 (按平均目标值):\n');
            for i = 1:length(comparison_analysis.algorithm_ranking)
                alg = comparison_analysis.algorithm_ranking{i};
                stats = comparison_analysis.algorithm_stats.(alg);
                fprintf(fid, '    %d. %s: %.6f ± %.6f (运行次数: %d)\n', ...
                    i, alg, stats.mean_objective, stats.std_objective, stats.total_runs);
            end
        end
        
        function writeMonteCarloAnalysis(obj, fid, monte_carlo_analysis, report_format)
            %写入蒙特卡洛分析
            
            fprintf(fid, '蒙特卡洛分析:\n');
            fprintf(fid, '  总样本数: %d\n', monte_carlo_analysis.total_samples);
            fprintf(fid, '  成功样本数: %d\n', monte_carlo_analysis.successful_samples);
            fprintf(fid, '  平均目标值: %.6f ± %.6f\n', monte_carlo_analysis.mean_objective, monte_carlo_analysis.std_objective);
            fprintf(fid, '  目标值范围: [%.6f, %.6f]\n', monte_carlo_analysis.min_objective, monte_carlo_analysis.max_objective);
            fprintf(fid, '  95%% 置信区间: [%.6f, %.6f]\n', monte_carlo_analysis.confidence_interval(1), monte_carlo_analysis.confidence_interval(2));
            fprintf(fid, '  约束可行率: %.1f%%\n', monte_carlo_analysis.feasibility_rate * 100);
        end
        
        function writeBenchmarkAnalysis(obj, fid, benchmark_analysis, report_format)
            %写入基准测试分析
            
            fprintf(fid, '基准测试分析:\n');
            fprintf(fid, '  基准测试分析功能需要进一步实现\n');
        end
        
        function writeBatchConclusions(obj, fid, analysis_results)
            %写入结论和建议
            
            fprintf(fid, '结论和建议\n');
            fprintf(fid, '----------\n');
            
            % 根据批处理类型生成不同的结论
            switch analysis_results.batch_type
                case 'parameter_sweep'
                    fprintf(fid, '• 通过参数扫描找到了最优参数组合\n');
                    fprintf(fid, '• 建议进一步在最优区域进行精细搜索\n');
                    
                case 'algorithm_comparison'
                    if isfield(analysis_results, 'comparison_analysis')
                        best_alg = analysis_results.comparison_analysis.algorithm_ranking{1};
                        fprintf(fid, '• 算法 %s 在本次对比中表现最佳\n', best_alg);
                        fprintf(fid, '• 建议在实际应用中优先考虑该算法\n');
                    end
                    
                case 'monte_carlo'
                    if isfield(analysis_results, 'monte_carlo_analysis')
                        mca = analysis_results.monte_carlo_analysis;
                        if mca.feasibility_rate > 0.9
                            fprintf(fid, '• 设计在不确定性条件下具有很高的可行性\n');
                        elseif mca.feasibility_rate > 0.7
                            fprintf(fid, '• 设计在不确定性条件下具有较好的可行性\n');
                        else
                            fprintf(fid, '• 需要改进设计以提高在不确定性条件下的可行性\n');
                        end
                    end
                    
                case 'benchmark_suite'
                    fprintf(fid, '• 基准测试为算法性能提供了客观评估\n');
                    fprintf(fid, '• 建议定期运行基准测试以监控算法性能\n');
            end
            
            fprintf(fid, '• 所有结果已保存，可用于后续分析\n');
            fprintf(fid, '• 建议结合实际工程需求选择最适合的方法\n');
        end
        
        function exportBatchResultsCSV(obj, analysis_results, batch_id, export_dir, timestamp)
            %导出批处理结果为CSV格式
            
            fprintf('CSV导出功能需要进一步实现\n');
        end
    end
end