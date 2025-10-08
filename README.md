# Adaptive HARQ Scheduling for 5G IoT in Non-Terrestrial Networks (NTN)

This repository contains the implementation of an **AI/ML-powered HARQ scheduling framework** for 5G IoT services in Non-Terrestrial Networks (NTNs).  
Our approach dynamically predicts and adapts HARQ timing parameters (Downlink Data-to-ACK (DD2A) and Uplink Grant-to-Data (UG2D) delays), thereby reducing idle waiting times, improving throughput, and boosting spectral efficiency for resource-constrained IoT devices in satellite communication environments.

---

## 🚀 Motivation

Hybrid Automatic Repeat Request (HARQ) is critical for reliable data delivery in wireless systems. However, in NTN scenarios (e.g., satellite links), large round-trip times (RTTs) significantly degrade HARQ performance, leading to:
- Long idle gaps  
- Reduced spectral efficiency  
- Higher latency and jitter  
- Inefficient utilization of IoT device power/resources  

Conventional solutions (like disabling HARQ or using multi-process HARQ) are not always suitable for IoT due to added complexity or excessive delays.  
This project proposes an **adaptive ML-based HARQ scheduler** that addresses these inefficiencies.

---

## 🎯 Objectives

- Dynamically predict **n_DD2A** (Downlink Data-to-ACK) and **n_UG2D** (Uplink Grant-to-Data) delays.  
- Optimize HARQ parameters (**N_TBPHC**, **n_repetitions**) for maximum throughput.  
- Minimize idle waiting times while keeping IoT device complexity and power usage low.  
- Benchmark performance against fixed-delay HARQ schemes.

---

## 📊 Approach & Methodology

1. **Dataset Generation**  
   - Synthetic dataset (`ntn_harq_dataset.csv`) generated using MATLAB 5G Toolbox.  
   - Features: RTT, SNR, path loss, modulation order, repetitions, etc.  
   - Targets: optimal `n_DD2A`, `n_UG2D`, `N_TBPHC`, and `n_repetitions`.

2. **ML Model Development**  
   - Random Forest regressors built in Python (scikit-learn).  
   - Model 1 → Predicts delays (`n_DD2A`, `n_UG2D`).  
   - Model 2 → Predicts scheduling parameters (`N_TBPHC`, `n_repetitions`) to maximize throughput.

3. **Integration with HARQ Simulator**  
   - MATLAB/Python simulator models UE ↔ Satellite ↔ gNB communication.  
   - ML-predicted values replace fixed HARQ delays in scheduling logic.  
   - Performance compared with legacy HARQ.

4. **Evaluation Metrics**  
   - Throughput  
   - Spectral Efficiency  
   - Subframe Utilization Factor (SUF)  
   - Latency & Jitter  
   - Device Energy Consumption  



