# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a repository for the 2026A National Mathematical Contest in Modeling (CUMCM) focusing on **Mooring System Design** for marine observation networks. The project involves designing optimal mooring systems for transmission nodes consisting of buoy systems, mooring systems, and underwater acoustic communication systems.

This is primarily a **mathematical research project** rather than a software development project, focused on theoretical analysis and paper-based competition preparation.

## Repository Structure

- `题目原题/` - Complete problem statement and original contest materials
  - `2026A 国赛原题.md` - Main problem description with all constraints and parameters
  - `CUMCM2016-problem-A-Chinese-version.*` - Original contest documentation
- `往年获奖论文/` - Reference collection of 5 award-winning papers from 2016 National Contest Problem A
- `往年论文分析/` - Comprehensive analysis framework for studying reference papers
  - `横向对比分析报告.md` - Cross-paper comparative analysis template
  - Individual paper analysis directories with detailed breakdowns
- `题目解析/` - Deep technical analysis of the problem domain
  - `2016年数学建模A题深度解析.md` - Comprehensive engineering and mathematical analysis
- `此处插入图片1：传输节点示意图.md` - System architecture diagrams

## Problem Domain & Technical Specifications

**Core Engineering Problem**: Multi-objective optimization of marine mooring system design

**System Components**:
- **Buoy System**: Cylindrical buoy (2m diameter, 2m height, 1000kg mass)
- **Mooring System**: Steel pipes (4×1m sections), steel cylinder, heavy balls, anchor chains, anchor (600kg)
- **Communication System**: Underwater acoustic equipment (1m×30cm cylinder, 100kg total)

**Critical Constraints**:
- Anchor chain angle with seabed ≤ 16°
- Steel cylinder tilt angle ≤ 5° for optimal equipment performance
- Wind resistance up to 36 m/s, water currents up to 1.5 m/s
- Variable water depth: 16m-20m

**Load Calculation Formulas**:
- Wind Load: F = 0.625 × S × v² (N)
- Water Current Force: F = 374 × S × v² (N)
- S = projected area (m²), v = velocity (m/s)

## Mathematical Modeling Framework

**Problem Classification**: Multi-objective constrained optimization with:
1. **Static Force Analysis**: Balance equations for entire system under environmental loads
2. **Geometric Modeling**: Catenary curve equations for chain shape analysis  
3. **Constraint Optimization**: Minimize buoy draft depth, swimming area, and cylinder tilt
4. **Multi-scenario Analysis**: Robustness across varying environmental conditions

**Core Mathematical Components**:
- Catenary differential equations: `d²z/dx² = (w/T₀) × √(1 + (dz/dx)²)³`
- Static equilibrium: `∑F = 0, ∑M = 0`
- Constraint inequalities: angle and stability limits
- Multi-objective optimization with conflicting objectives

**Three Problem Complexity Levels**:
1. **Problem 1**: Static analysis with fixed parameters (basic force balance)
2. **Problem 2**: Constrained optimization (adjust heavy ball mass)
3. **Problem 3**: Multi-scenario robustness design (variable depth/wind/current)

## Analysis Methodology

The repository contains a structured **comparative analysis framework** for evaluating solution approaches:

**Evaluation Dimensions**:
- Modeling methods and theoretical foundations
- Solution techniques and computational efficiency  
- Result quality and engineering validation
- Technical writing and presentation quality
- Innovation and methodological contributions

**Reference Paper Analysis**: 5 award-winning papers analyzed across:
- Force analysis approaches vs. extremal methods vs. multi-objective optimization
- Numerical solution techniques and algorithm selection
- Model validation and sensitivity analysis approaches
- Technical presentation and result visualization

## Development Workflow

Since this is an academic modeling project:

**No Traditional Development Commands**: No build, test, or lint processes apply

**Research Workflow**:
1. Study problem specifications in `题目原题/`
2. Analyze reference approaches in `往年论文分析/`
3. Review technical analysis in `题目解析/`  
4. Develop mathematical models (typically in MATLAB, Python, or specialized software)
5. Generate academic paper following contest formatting requirements

**Key Reference Files for Model Development**:
- `题目解析/2016年数学建模A题深度解析.md` - Technical implementation guidance
- `往年论文分析/横向对比分析报告.md` - Solution approach comparisons
- Chain specifications and load formulas in problem statement

## Future Implementation Notes

Mathematical models would typically be implemented using:
- **MATLAB**: For differential equation solving and optimization
- **Python**: NumPy/SciPy for numerical analysis, matplotlib for visualization
- **Specialized Marine Engineering Software**: For advanced catenary analysis
- **Optimization Libraries**: For multi-objective constraint optimization

The focus should be on theoretical rigor, mathematical correctness, and engineering practicality rather than software development best practices.