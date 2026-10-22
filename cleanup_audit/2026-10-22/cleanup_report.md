# 文件夹清理报告

日期：2026-10-22（Asia/Shanghai）。操作目录：`E:\py_code\bupt_hjk\sdp_test\My_sdp_test`。

本次按用户指定顺序完成：先复制到 `F:\temp\Preprocessing_matters`，全部校验通过后，再逐文件删除原位置。未修改投稿材料目录；没有远程发布、Git 提交、暂存或历史重写。

## 实际结果

- 已归档并删除 **4,773 个文件**，合计 **10,231,692,607 字节 / 10.232 GB / 9.529 GiB**。这是工作目录中删除文件的逻辑大小，包含重复副本；不代表 Git 历史大小的减少。
- 清理了 1,591 个由这些文件删除后形成的空目录；仅删除确认为空的目录，没有通配符式递归删除结果树。
- 其中 Git 已追踪文件删除 4,689 个；其余为本地缓存等未追踪文件。Git 工作区保留可审查的删除记录，尚未提交。
- 原扫描范围内保留 644 个文件；除明确更新的 `.gitignore` 外，643 个保留文件的 SHA-256 与清理前一致。
- 100 个待核验项目继续保留，详见 `review_required_retained.csv`。

| 删除项目 | 文件数 |
| --- | ---: |
| best_checkpoint.pth | 1,518 |
| loss_curve.png | 1,491 |
| train_process.txt | 1,560 |
| preset_process.txt | 12 |
| error.txt | 12 |
| 缓存、字节码、个人编辑器配置 | 165 |
| 清单明确列出的过程文稿、写作工具、DOCX 和 QA 文件 | 14 |
| SHA-256 相同的 ElderAL 汇总表副本 | 1 |

`test1_elderAL/result/preset_tests/` 的 327 个文件与 `SDP/test_elderAL/result/preset_tests/` 对应文件逐一哈希相同。旧目录已归档删除；主目录的统计表保留，主目录内权重、曲线和日志也按全仓统一规则另行归档。没有把两个归档副本的相同内容误认为统计数据丢失。

## 备份和恢复

- `F:\temp\Preprocessing_matters\files`：原相对目录结构下的完整文件内容。
- `F:\temp\Preprocessing_matters\_metadata`：本报告、清单、校验记录、恢复脚本，以及清理前的 `original.gitignore`。
- 每个文件复制后校验 SHA-256；全部备份完成后才进入删除阶段；每次删除前再次计算原文件和备份文件 SHA-256，与清理前清单比对。
- 恢复入口：`restore_archived_files.ps1`。支持按清单相对路径恢复或 `-All`，遇到同路径但内容不同的文件会停止，不覆盖。
- 详细恢复及绘图命令见 `reproduction_commands.md`。旧权重评估、完整重新推理、续训，以及部分实验的完成状态检查需要先恢复对应权重。

## 保护范围

`sdp_dataset/`、可能存在的 `data/` 与 `temp_sdp_data/`、Git 元数据、核心 `src/wsdp/`、实验入口、读取器、模型、配置、许可证、测试、非重复统计 CSV/JSON、全部 `training_history.csv`、逐样本机制证据、源图与绘图脚本均未纳入删除。

扫描并哈希了 5,417 个项目文件。原始数据内部、Git 历史、工具运行时、`.codex_tmp/`、`tmp/` 等保护树未做全量内容扫描或哈希，具体边界见 `protected_roots.csv`。这些目录不是“已经审计清空”的对象；其中可能包含数据、运行依赖或独有论文源文件，保持不动。

## 投稿图表核对

用户指定稿件目录：`C:\Users\21669\Desktop\论文\SDP\投稿材料`。其中 12 个文件的哈希已记录，并在清理后确认未改变。

- 稿件内含 Figure 1–8；目录没有单独的 `Figure4.pdf`，但稿件第 7 个 PDF 页面内嵌了该图。本次未创建、替换或移动投稿文件。
- `Graphical_Abstract.pdf` 与仓库 `output/pdf/异构CSI预处理基准与关键发现_高清矢量.pdf` 的 SHA-256 完全一致，该仓库文件保留。
- Figure 5/6 的脚本会从原始 PDF 分图读取曲线路径或混淆矩阵。相关 PDF 属于绘图输入，均保留；Figure 6 的拼接结构已视觉核对。
- Figure 8 等包含后期组合；不能仅凭文件名或“旧图”字样清理。全部相关图形版本、源图、绘图代码保留。
- `figure_to_source_map.csv` 记录 15 条结果/图表/代码对应关系，明确区分输入已核验、内容对应、完全相同和待确认的最终拼接关系。未伪造精确版本追溯。

## 数据和代码验证

- Stage I：四个主表各 114 行、19 个模型、6 个预设，组合键无重复；失败和跳过记录原样保留。
- Stage II：Widar 320、Gait 320、XRF55 80、ElderAL 80，配置编号完整且无重复。Gait 原表 289+31 行保留，另生成带来源路径的联合表。
- Widar/Gait 新版 Stage I 各 90 行。84 个可比较数值对中，Widar 有 84 个不同、Gait 有 83 个不同；因此两代结果均保留。
- 对 186 个保留的 Python 文件做了语法解析；对 166 个保留 CSV/JSON 文件确认内容哈希不变。
- 文件完整性、删除范围、投稿文件、Git 变更范围及 `.gitignore` 保护检查：**通过**。
- 现有绘图入口在清理后的目录上重绘：**8/8 通过**。测试输出重定向到仓库外的 Codex 工作目录，未覆盖正式图。

| 绘图检查 | 结果 |
| --- | --- |
| stage1 | 通过 |
| stage2 | 通过 |
| hampel_waveforms | 通过 |
| hampel_confusion | 通过 |
| hampel_timing | 通过 |
| bandpass | 通过 |
| phase_accuracy | 通过 |
| phase_structure | 通过 |

## 保留的已知问题与范围限制

1. Gait Stage II 默认脚本模型为 resnet2d，论文使用 MLPModel；XRF55 默认脚本模型为 csitime，论文使用 ResNet1D。没有为迎合论文改写现有脚本；相关历史代码、表格与配置完整保留。
2. Gait 合并表的编号和模型列一致，但汇总表不能单独证明两批运行的 seed 与源码版本一致。
3. `paper_figures/figure_manifest.json` 是历史图包清单；保留原件并另建本次对应表，没有冒称已经完成全部投稿图版本认证。
4. 可用 Python 环境没有 PyTorch，未运行 WSDP/PyTorch 导入、GPU 训练、原始数据全量读取或模型重新评估。绘图与文件完整性验证不等于实验数值重新训练验证。
5. `.gitignore` 新增仅针对 checkpoint、过程日志、逐次 loss PNG、IDE 配置及指定预览文件；未全局忽略 CSV、JSON、PDF 或全部 PNG。
6. 本次是本地归档清理，没有移动核心目录、修复历史实验参数、创建 PR、发布 release 或清除 Git 大对象历史。现有 Git 历史仍占用空间。

## 交付索引

`inventory.csv`：清理前文件、大小、哈希、Git 跟踪状态、类别、引用和动作。

`deletion_manifest.csv` / `backup_verified.csv` / `hash_manifest.csv`：实际删除、备份校验和哈希记录。

`retained_manifest.csv` / `review_required_retained.csv` / `protected_roots.csv`：保留及扫描边界。

`run_manifest.csv` / `failure_manifest.csv`：从归档日志提取的运行信息、失败/跳过证据；未记录的参数明确视为未知，完整日志仍在 F 盘。

`result_validation.json` / `stage1_old_new_comparison.csv` / `gait_stage2_320_merged.csv`：结果完整性及差异核对。

`submission_files.csv` / `figure_to_source_map.csv` / `figure_smoke_checks.json` / `file_verification.json`：投稿材料、图表来源及验证记录。
