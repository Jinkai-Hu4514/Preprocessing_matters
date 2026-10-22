# 清理后的复现与恢复说明

工作目录：`E:\py_code\bupt_hjk\sdp_test\My_sdp_test`。

## 恢复已归档文件

备份根目录：`F:\temp\Preprocessing_matters`。`files/` 保留原相对目录结构；`_metadata/` 保存清单、校验记录和清理前的 `.gitignore`。完整模型推理、旧新权重比较、从 checkpoint 续训，以及部分实验的完成状态判定，需要先恢复相应权重。

在仓库根目录的 PowerShell 中恢复单个权重：

```powershell
& '.\cleanup_audit\2026-10-22\restore_archived_files.ps1' -RelativePath 'test1_gait/result/user_id_v2+fast+mlpmodel/best_checkpoint.pth'
```

恢复本次全部归档文件：

```powershell
& '.\cleanup_audit\2026-10-22\restore_archived_files.ps1' -All
```

恢复脚本先校验 SHA-256，再复制；不会覆盖内容不同的现有文件。`-All` 恢复归档文件，不撤销新增审计文件和 `.gitignore` 的更新。清理前的忽略配置保存在备份的 `_metadata/original.gitignore`，需要回滚时先比较再恢复。

## 从保留数据生成图片

以下是仓库现有绘图入口，需使用具备 NumPy、pandas、Matplotlib、SciPy、pypdf 等依赖的 Python 环境。脚本默认会写入其既有输出目录；最终投稿图中部分还经过手工拼接，脚本重绘不等于逐像素恢复最终版面。

```powershell
python paper_figures/generate_stage1_heatmap_marginals.py
python paper_figures/generate_stage2_pipeline_heatmaps.py
python ablation/plot_hampel_combined_abc.py
python ablation/plot_elderal_sampling_window_span_two_panel.py
python ablation/plot_elderal_hampel_ablation_six_panel.py
python ablation/plot_bandpass_accuracy_and_bypass.py
python ablation/robust_paper_figures/plot_fig_x_root_cause.py
python ablation/robust_paper_figures/plot_fig_y_signal_structure.py
```

清理验证会将测试成图重定向到仓库外的本次 Codex 工作目录，避免覆盖论文图。实测结果见 `figure_smoke_checks.json`。

## 实验重跑前需要核对

- 原始数据目录 `sdp_dataset/` 保留，未搬移、改写或删除；本次未对原始样本做全量读取或重新计算哈希。
- 核心包、四数据集读取器、所有现有实验入口、配置、许可证、统计表和机制证据均保留。
- Widar/Gait 的旧 Stage I 各 114 行，新版各 90 行，数值不同，两代数据均保留。`stage1_old_new_comparison.csv` 记录逐组合差异。
- Gait Stage II 原来的 289 行和补充 31 行均保留；`gait_stage2_320_merged.csv` 是带来源路径的新增联合校验表，未替换原始表。编号 1–320 完整且无重复；仅凭汇总表不能证明 seed、源码版本完全相同。
- `SDP/test_gait/full_test_gait_new.py` 的默认模型与论文 MLP 数据不一致；`SDP/test_xrf55/full_test_xrf55.py` 的默认模型与论文 ResNet1D 数据不一致。未找到可证明对应历史实验版本的完整配置前，不把这两个默认入口宣称为精确重放命令，也不擅自修改模型来掩盖差异。
- `paper_figures/figure_manifest.json` 是历史图包清单，原样保留；本次另外提供 `figure_to_source_map.csv`，区分已验证输入、内容对应和待确认的最终拼接关系。
- 部分 Hampel 绘图脚本从原始 PDF 图中提取曲线或混淆矩阵，因此这些 PDF 是必需输入，已保留。
- 本次不执行重新训练，不变更 Git 历史，不发布、提交或推送远程仓库。
