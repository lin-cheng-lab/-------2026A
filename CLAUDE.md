# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a repository for the 2026A National Mathematical Contest in Modeling (CUMCM) focusing on **Mooring System Design** for marine observation networks. The project involves designing optimal mooring systems for transmission nodes consisting of buoy systems, mooring systems, and underwater acoustic communication systems.

## Repository Structure

- `题目原题/2026A 国赛原题.md` - Contains the complete problem statement in Chinese
- `往年获奖论文/` - Collection of award-winning papers from 2016 National Contest Problem A for reference
- `此处插入图片1：传输节点示意图.md` - Contains diagram reference for transmission node structure
- `README.md` - Basic project title

## Problem Domain

The core problem involves optimizing a marine mooring system with the following components:
- **Buoy System**: Cylindrical buoy (2m diameter, 2m height, 1000kg mass)
- **Mooring System**: Steel pipes (4 sections, 1m each), steel cylinder, heavy balls, anchor chains, and anchor (600kg)
- **Communication System**: Underwater acoustic equipment in sealed steel cylinder (1m length, 30cm diameter, 100kg total mass)

Key constraints:
- Anchor chain angle with seabed must not exceed 16°
- Steel cylinder tilt angle must not exceed 5° for optimal equipment performance
- System must handle wind speeds up to 36 m/s and water currents up to 1.5 m/s
- Water depth varies between 16m-20m

## Physics Models Used

The problem involves several engineering physics calculations:
- **Wind Load**: F = 0.625 × S × v² (N), where S = projected area (m²), v = wind speed (m/s)
- **Water Current Force**: F = 374 × S × v² (N), where S = projected area (m²), v = current speed (m/s)
- **Chain Types**: 5 different anchor chain specifications (I-V) with varying lengths and masses
- **Buoyancy and stability analysis** for the complete system

## Mathematical Modeling Approach

This is a multi-objective optimization problem requiring:
1. **Force analysis** of the entire mooring system under various environmental conditions
2. **Geometric modeling** of chain shapes and component positions
3. **Constraint optimization** to minimize buoy draft depth, swimming area, and cylinder tilt angle
4. **Sensitivity analysis** across different water depths, wind speeds, and current velocities

## Development Notes

- This appears to be a research/academic project focused on mathematical modeling rather than software development
- No traditional build, test, or lint commands are applicable
- The repository contains reference materials and problem specifications
- Future work would likely involve implementing numerical models using tools like MATLAB, Python (NumPy/SciPy), or specialized marine engineering software