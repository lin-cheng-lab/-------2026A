classdef ParameterValidator < handle
    %PARAMETERVALIDATOR 系泊系统设计参数验证工具
    %   确保所有输入参数符合物理约束和工程规范
    %   基于Paper 4技术规范和海洋工程标准
    
    properties (Constant, Access = private)
        % 物理常数
        GRAVITY = 9.8;              % 重力加速度 (m/s^2)
        SEAWATER_DENSITY = 1025;    % 海水密度 (kg/m^3)
        AIR_DENSITY = 1.225;        % 空气密度 (kg/m^3)
        
        % 系统组件规格 (基于Paper 4)
        BUOY_DIAMETER = 2;          % 浮标直径 (m)
        BUOY_HEIGHT = 2;            % 浮标高度 (m)
        BUOY_MASS = 1000;           % 浮标质量 (kg)
        ANCHOR_MASS = 600;          % 锚质量 (kg)
        PIPE_LENGTH = 1;            % 钢管长度 (m)
        PIPE_DIAMETER = 0.05;       % 钢管直径 (m)
        PIPE_MASS = 10;             % 钢管质量 (kg)
        CYLINDER_LENGTH = 1;        % 钢桶长度 (m)
        CYLINDER_DIAMETER = 0.3;    % 钢桶直径 (m)
        CYLINDER_MASS = 100;        % 钢桶质量 (kg)
        
        % 锚链规格表 (Paper 4附表)
        CHAIN_SPECS = [
            78,  3.2;   % Type I
            105, 7;     % Type II  
            120, 12.5;  % Type III
            150, 19.5;  % Type IV
            180, 28.12  % Type V
        ];
        
        % 约束限制 (Paper 4规范)
        MAX_ANCHOR_ANGLE = 16;      % 锚链与海床最大夹角 (度)
        MAX_CYLINDER_ANGLE = 5;     % 钢桶最大倾斜角 (度)
        MAX_DRAFT_RATIO = 0.9;      % 最大吃水比例 (浮标高度的90%)
    end
    
    properties (Access = private)
        validation_history  % 验证历史记录
        warning_count      % 警告计数
        error_count       % 错误计数
    end
    
    methods (Access = public)
        function obj = ParameterValidator()
            %构造函数
            obj.validation_history = {};
            obj.warning_count = 0;
            obj.error_count = 0;
        end
        
        function [is_valid, validation_result] = validateDesignParameters(obj, params)
            %验证设计参数
            %   输入: params - 设计参数结构体
            %   输出: is_valid - 是否有效, validation_result - 详细验证结果
            
            validation_result = struct();
            validation_result.timestamp = datetime('now');
            validation_result.errors = {};
            validation_result.warnings = {};
            validation_result.info = {};
            
            fprintf('\n=== 设计参数验证 ===\n');
            
            % 验证重物球参数
            if isfield(params, 'ball_mass')
                obj.validateBallMass(params.ball_mass, validation_result);
            end
            
            % 验证锚链参数
            if isfield(params, 'chain_length') && isfield(params, 'chain_type')
                obj.validateChainParameters(params.chain_length, params.chain_type, validation_result);
            end
            
            % 验证环境参数
            if isfield(params, 'wind_speed')
                obj.validateWindSpeed(params.wind_speed, validation_result);
            end
            
            if isfield(params, 'water_depth')
                obj.validateWaterDepth(params.water_depth, validation_result);
            end
            
            if isfield(params, 'current_speed')
                obj.validateCurrentSpeed(params.current_speed, validation_result);
            end
            
            % 验证系统组合约束
            obj.validateSystemConstraints(params, validation_result);
            
            % 统计验证结果
            n_errors = length(validation_result.errors);
            n_warnings = length(validation_result.warnings);
            n_info = length(validation_result.info);
            
            is_valid = (n_errors == 0);
            
            obj.error_count = obj.error_count + n_errors;
            obj.warning_count = obj.warning_count + n_warnings;
            
            % 显示验证结果摘要
            fprintf('\n--- 验证结果摘要 ---\n');
            fprintf('✓ 信息: %d 条\n', n_info);
            if n_warnings > 0
                fprintf('⚠ 警告: %d 条\n', n_warnings);
            end
            if n_errors > 0
                fprintf('✗ 错误: %d 条\n', n_errors);
            end
            
            if is_valid
                fprintf('✅ 参数验证通过\n');
            else
                fprintf('❌ 参数验证失败，请修正错误后重试\n');
            end
            
            % 显示详细验证信息
            obj.displayValidationDetails(validation_result);
            
            % 保存验证历史
            obj.validation_history{end+1} = validation_result;
        end
        
        function [is_feasible, feasibility_result] = checkDesignFeasibility(obj, design_vector)
            %检查设计方案可行性
            %   快速检查设计向量是否在可行域内
            
            feasibility_result = struct();
            feasibility_result.timestamp = datetime('now');
            feasibility_result.constraints_satisfied = [];
            feasibility_result.constraint_violations = [];
            
            % 解析设计向量
            if length(design_vector) >= 3
                ball_mass = design_vector(1);
                chain_length = design_vector(2);
                chain_type = round(design_vector(3));
                
                constraints_check = [];
                
                % 检查边界约束
                constraints_check(1) = (ball_mass >= 500 && ball_mass <= 8000);
                constraints_check(2) = (chain_length >= 15 && chain_length <= 30);
                constraints_check(3) = (chain_type >= 1 && chain_type <= 5);
                
                % 检查物理约束
                if length(design_vector) >= 5
                    wind_speed = design_vector(4);
                    water_depth = design_vector(5);
                    
                    constraints_check(4) = (wind_speed >= 5 && wind_speed <= 50);
                    constraints_check(5) = (water_depth >= 10 && water_depth <= 30);
                    
                    % 检查锚链长度与水深关系
                    constraints_check(6) = (chain_length >= water_depth * 1.2);
                    constraints_check(7) = (chain_length <= water_depth * 2.0);
                end
                
                feasibility_result.constraints_satisfied = find(constraints_check);
                feasibility_result.constraint_violations = find(~constraints_check);
                
                is_feasible = all(constraints_check);
            else
                is_feasible = false;
                feasibility_result.constraint_violations = 1:length(design_vector);
            end
            
            feasibility_result.is_feasible = is_feasible;
        end
        
        function bounds = getParameterBounds(obj, parameter_name)
            %获取参数边界
            switch lower(parameter_name)
                case 'ball_mass'
                    bounds = [500, 8000]; % kg
                case 'chain_length'
                    bounds = [15, 30]; % m
                case 'chain_type'
                    bounds = [1, 5]; % integer
                case 'wind_speed'
                    bounds = [5, 50]; % m/s
                case 'water_depth'
                    bounds = [10, 30]; % m
                case 'current_speed'
                    bounds = [0, 3]; % m/s
                case 'draft_depth'
                    bounds = [0.5, obj.BUOY_HEIGHT * obj.MAX_DRAFT_RATIO]; % m
                case 'tilt_angle'
                    bounds = [0, obj.MAX_CYLINDER_ANGLE]; % degrees
                case 'swimming_radius'
                    bounds = [5, 50]; % m
                otherwise
                    warning('未知参数: %s', parameter_name);
                    bounds = [-inf, inf];
            end
        end
        
        function recommendations = getDesignRecommendations(obj, params)
            %获取设计建议
            recommendations = {};
            
            if isfield(params, 'ball_mass')
                if params.ball_mass < 2000
                    recommendations{end+1} = '建议增加重物球质量以提高系统稳定性';
                elseif params.ball_mass > 5000
                    recommendations{end+1} = '重物球质量过大可能影响经济性，考虑优化';
                end
            end
            
            if isfield(params, 'chain_length') && isfield(params, 'water_depth')
                chain_to_depth_ratio = params.chain_length / params.water_depth;
                if chain_to_depth_ratio < 1.3
                    recommendations{end+1} = '锚链长度相对水深偏短，可能影响锚泊性能';
                elseif chain_to_depth_ratio > 1.8
                    recommendations{end+1} = '锚链长度相对水深偏长，考虑优化成本';
                end
            end
            
            if isfield(params, 'wind_speed')
                if params.wind_speed > 35
                    recommendations{end+1} = '极端风速条件，建议加强系统设计安全系数';
                end
            end
            
            if isempty(recommendations)
                recommendations{1} = '设计参数合理，无特殊建议';
            end
        end
        
        function displayValidationSummary(obj)
            %显示验证统计摘要
            fprintf('\n=== 参数验证统计摘要 ===\n');
            fprintf('总验证次数: %d\n', length(obj.validation_history));
            fprintf('累计错误: %d\n', obj.error_count);
            fprintf('累计警告: %d\n', obj.warning_count);
            
            if obj.error_count == 0 && obj.warning_count == 0
                fprintf('✅ 所有验证均通过\n');
            elseif obj.error_count == 0
                fprintf('⚠ 有警告但无致命错误\n');
            else
                fprintf('❌ 存在需要修正的错误\n');
            end
        end
        
        function resetValidationHistory(obj)
            %重置验证历史
            obj.validation_history = {};
            obj.warning_count = 0;
            obj.error_count = 0;
            fprintf('验证历史已重置\n');
        end
    end
    
    methods (Access = private)
        function validateBallMass(obj, ball_mass, result)
            %验证重物球质量
            param_name = '重物球质量';
            
            % 基本范围检查
            if ball_mass < 100
                result.errors{end+1} = sprintf('%s过小 (%.1f kg)，最小建议值: 500 kg', param_name, ball_mass);
            elseif ball_mass < 500
                result.warnings{end+1} = sprintf('%s偏小 (%.1f kg)，可能影响稳定性', param_name, ball_mass);
            end
            
            if ball_mass > 10000
                result.errors{end+1} = sprintf('%s过大 (%.1f kg)，最大建议值: 8000 kg', param_name, ball_mass);
            elseif ball_mass > 8000
                result.warnings{end+1} = sprintf('%s偏大 (%.1f kg)，可能影响经济性', param_name, ball_mass);
            end
            
            % 工程合理性检查
            if ball_mass > obj.BUOY_MASS * 8
                result.warnings{end+1} = sprintf('%s是浮标质量的%.1f倍，检查系统平衡', param_name, ball_mass/obj.BUOY_MASS);
            end
            
            if ball_mass >= 500 && ball_mass <= 8000
                result.info{end+1} = sprintf('%s: %.1f kg ✓', param_name, ball_mass);
            end
        end
        
        function validateChainParameters(obj, chain_length, chain_type, result)
            %验证锚链参数
            
            % 验证锚链类型
            if chain_type < 1 || chain_type > 5 || floor(chain_type) ~= chain_type
                result.errors{end+1} = sprintf('锚链型号无效 (%d)，必须是1-5的整数', chain_type);
                return;
            end
            
            % 验证锚链长度
            if chain_length < 10
                result.errors{end+1} = sprintf('锚链长度过短 (%.2f m)，最小建议值: 15 m', chain_length);
            elseif chain_length < 15
                result.warnings{end+1} = sprintf('锚链长度偏短 (%.2f m)，可能影响锚泊效果', chain_length);
            end
            
            if chain_length > 35
                result.errors{end+1} = sprintf('锚链长度过长 (%.2f m)，最大建议值: 30 m', chain_length);
            elseif chain_length > 30
                result.warnings{end+1} = sprintf('锚链长度偏长 (%.2f m)，考虑成本优化', chain_length);
            end
            
            % 锚链规格信息
            if chain_type >= 1 && chain_type <= 5
                chain_mass_per_m = obj.CHAIN_SPECS(chain_type, 2);
                total_chain_mass = chain_length * chain_mass_per_m;
                
                result.info{end+1} = sprintf('锚链: %d型，长度%.2f m，总质量%.1f kg ✓', ...
                                            chain_type, chain_length, total_chain_mass);
                
                % 检查锚链质量合理性
                if total_chain_mass > obj.BUOY_MASS * 0.5
                    result.warnings{end+1} = sprintf('锚链质量(%.1f kg)较大，占浮标质量%.1f%%', ...
                                                    total_chain_mass, total_chain_mass/obj.BUOY_MASS*100);
                end
            end
        end
        
        function validateWindSpeed(obj, wind_speed, result)
            %验证风速参数
            param_name = '风速';
            
            if wind_speed < 0
                result.errors{end+1} = sprintf('%s不能为负值 (%.1f m/s)', param_name, wind_speed);
            elseif wind_speed < 5
                result.warnings{end+1} = sprintf('%s较小 (%.1f m/s)，实际海况可能更恶劣', param_name, wind_speed);
            end
            
            if wind_speed > 60
                result.errors{end+1} = sprintf('%s过大 (%.1f m/s)，超出系统设计范围', param_name, wind_speed);
            elseif wind_speed > 50
                result.warnings{end+1} = sprintf('%s很大 (%.1f m/s)，属于极端海况', param_name, wind_speed);
            elseif wind_speed > 35
                result.warnings{end+1} = sprintf('%s较大 (%.1f m/s)，注意安全系数', param_name, wind_speed);
            end
            
            % 风级分类信息
            if wind_speed >= 5 && wind_speed <= 50
                wind_scale = obj.getWindScale(wind_speed);
                result.info{end+1} = sprintf('%s: %.1f m/s (%s) ✓', param_name, wind_speed, wind_scale);
            end
        end
        
        function validateWaterDepth(obj, water_depth, result)
            %验证水深参数
            param_name = '水深';
            
            if water_depth <= 0
                result.errors{end+1} = sprintf('%s必须为正值 (%.2f m)', param_name, water_depth);
            elseif water_depth < 10
                result.warnings{end+1} = sprintf('%s较浅 (%.2f m)，可能影响锚泊效果', param_name, water_depth);
            end
            
            if water_depth > 50
                result.errors{end+1} = sprintf('%s过深 (%.2f m)，超出近海范围', param_name, water_depth);
            elseif water_depth > 30
                result.warnings{end+1} = sprintf('%s较深 (%.2f m)，增加系统复杂性', param_name, water_depth);
            end
            
            if water_depth >= 10 && water_depth <= 30
                result.info{end+1} = sprintf('%s: %.2f m ✓', param_name, water_depth);
            end
        end
        
        function validateCurrentSpeed(obj, current_speed, result)
            %验证流速参数
            param_name = '流速';
            
            if current_speed < 0
                result.errors{end+1} = sprintf('%s不能为负值 (%.2f m/s)', param_name, current_speed);
            end
            
            if current_speed > 5
                result.errors{end+1} = sprintf('%s过大 (%.2f m/s)，超出一般海流范围', param_name, current_speed);
            elseif current_speed > 2
                result.warnings{end+1} = sprintf('%s较大 (%.2f m/s)，属于强海流', param_name, current_speed);
            end
            
            if current_speed >= 0 && current_speed <= 2
                result.info{end+1} = sprintf('%s: %.2f m/s ✓', param_name, current_speed);
            end
        end
        
        function validateSystemConstraints(obj, params, result)
            %验证系统组合约束
            
            % 锚链长度与水深关系
            if isfield(params, 'chain_length') && isfield(params, 'water_depth')
                ratio = params.chain_length / params.water_depth;
                if ratio < 1.2
                    result.warnings{end+1} = sprintf('锚链长度/水深比(%.2f)偏小，建议≥1.3', ratio);
                elseif ratio > 2.0
                    result.warnings{end+1} = sprintf('锚链长度/水深比(%.2f)偏大，可考虑优化', ratio);
                else
                    result.info{end+1} = sprintf('锚链长度/水深比: %.2f ✓', ratio);
                end
            end
            
            % 重物球与环境载荷匹配
            if isfield(params, 'ball_mass') && isfield(params, 'wind_speed')
                wind_force_approx = 0.625 * pi * (obj.BUOY_DIAMETER/2)^2 * params.wind_speed^2;
                ball_weight = params.ball_mass * obj.GRAVITY;
                
                if ball_weight < wind_force_approx * 0.5
                    result.warnings{end+1} = '重物球质量可能不足以平衡风载荷';
                elseif ball_weight > wind_force_approx * 10
                    result.warnings{end+1} = '重物球质量相对风载荷偏大，考虑优化';
                else
                    result.info{end+1} = '重物球质量与风载荷匹配合理 ✓';
                end
            end
        end
        
        function wind_scale = getWindScale(obj, wind_speed)
            %获取风级描述
            if wind_speed < 6
                wind_scale = '微风';
            elseif wind_speed < 12
                wind_scale = '轻风';
            elseif wind_speed < 20
                wind_scale = '中风';
            elseif wind_speed < 29
                wind_scale = '强风';
            elseif wind_speed < 39
                wind_scale = '大风';
            elseif wind_speed < 50
                wind_scale = '烈风';
            else
                wind_scale = '暴风';
            end
        end
        
        function displayValidationDetails(obj, result)
            %显示详细验证信息
            if ~isempty(result.info)
                fprintf('\n📋 验证信息:\n');
                for i = 1:length(result.info)
                    fprintf('   %s\n', result.info{i});
                end
            end
            
            if ~isempty(result.warnings)
                fprintf('\n⚠️  警告信息:\n');
                for i = 1:length(result.warnings)
                    fprintf('   %s\n', result.warnings{i});
                end
            end
            
            if ~isempty(result.errors)
                fprintf('\n❌ 错误信息:\n');
                for i = 1:length(result.errors)
                    fprintf('   %s\n', result.errors{i});
                end
            end
        end
    end
end