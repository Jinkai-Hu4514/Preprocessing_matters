# Pluggable Preprocessing Pipelines for Heterogeneous WiFi CSI Sensing Datasets: Systematic Evaluation and Analysis

Anonymous Author(s)

Rewritten manuscript | English full text and Chinese section-by-section notes | 6 October 2026

:::note
This reading draft follows the organization of SenseFi. All figures and tables are deliberately reserved as labeled placeholders. Existing experimental findings are retained; the Chinese notes after the references explain the rearrangement, necessary corrections, and remaining information to supply before submission.
:::

## Graphical abstract

:::placeholder GA | Graphical abstract | 105
Draw a left-to-right overview: heterogeneous CSI from Widar, Gait, XRF55, and ElderAL; a library of five preprocessing modules and their alternative methods; Stage I, six presets across nineteen registered models; Stage II, 320 combinations for each complex-CSI dataset and 80 for each amplitude-only dataset; signal diagnostics and conditional selection guidelines. Show an amplitude-plus-phase branch and an amplitude-only branch. Highlight algorithm comparison and composition as the central object. Do not use a protocol-standardization or canonical-tensor wall as the visual center.
:::

## Highlights

- Five pluggable preprocessing modules organize representative existing CSI-processing methods.
- A two-stage benchmark connects model-pipeline screening with controlled component comparisons.
- Matched configurations and signal diagnostics explain dataset-dependent gains and failures.
- Conditional recommendations relate preprocessing choices to CSI semantics and sampling conditions.

## The bigger picture

WiFi sensing systems usually contain several preprocessing operations before a learning model receives its input. These operations decide which channel variations remain available for recognition. A benchmark that compares only models under one fixed input pipeline cannot show whether the pipeline itself is appropriate, or whether a reported gain depends on a particular combination of processing methods. This work provides a systematic experimental setting for studying those choices. It organizes representative methods into replaceable modules, evaluates their combinations on heterogeneous datasets, and connects recognition results with changes in the underlying signals. The resulting observations help researchers select preprocessing methods, explain unexpected failures, and compare sensing systems with a clearer account of how their inputs were constructed.

## Summary

Preprocessing is widely used in WiFi sensing, but its methods are often adopted as fixed implementation choices. Their effects depend on the signal information retained by a dataset, the assumptions of each operation, and the learning model that receives the processed input. In this work, we present a pluggable preprocessing benchmark for heterogeneous WiFi channel state information (CSI). The benchmark covers five modules: denoising, outlier handling, phase calibration, normalization, and subcarrier interpolation or reduction. Alternative methods within each module can be combined under explicitly defined execution rules. A two-stage evaluation first screens six representative presets across nineteen registered models on four datasets, and then fixes a representative model for each dataset to examine 320 combinations for complex CSI and 80 combinations for amplitude-only CSI. The results show that a preprocessing change can improve one model while degrading another, and that no pipeline is consistently best across the evaluated settings. Component comparisons and targeted analyses identify three important sources of degradation: fixed-frame Hampel windows on sparse, irregular sequences; band-pass settings that do not match the sampling rate; and independent temporal phase detrending that distorts inter-subcarrier relationships. Together, the benchmark and its analyses provide evidence for selecting existing preprocessing methods according to data characteristics rather than adopting a single default pipeline.

Keywords: WiFi sensing; channel state information; preprocessing benchmark; pluggable modules; algorithm composition; mechanism analysis.

## Introduction

WiFi sensing uses changes in wireless propagation to infer human activities, gestures, and identities without requiring wearable devices. Existing communication infrastructure therefore offers a practical source of sensing measurements for smart environments and human-computer interaction [3-6]. The broader development of integrated sensing and communications also motivates closer examination of how communication measurements are used for sensing [1,2]. In CSI-based systems, human motion changes reflection, scattering, and diffraction paths, producing variations in the amplitude and phase of the measured channel [4,5,7,8]. Learning models use these variations to construct discriminative features.

The input to a learning model, however, is rarely the acquired CSI itself. Raw measurements may include random noise, impulsive fluctuations, synchronization errors, hardware-dependent phase distortions, and differences in numerical scale. Researchers commonly apply several preprocessing operations before training. A denoising method may smooth a temporal waveform; an outlier method may replace abrupt values; phase calibration may remove estimated phase trends; and normalization and interpolation may change the scale and dimensionality of the input. Each operation changes the information available to the model. As illustrated in Figure 1, different pipelines can produce different representations of the same observation and, consequently, different sensing outcomes.

:::placeholder Figure 1 | Preprocessing and model dependence of sensing outcomes | 105
Reuse the original Figure 1. Retain raw CSI, several alternative preprocessing pipelines, processed waveforms, and different recognition outcomes under controlled or different models. Update labels to emphasize information retention and removal. This is the motivation figure, not a diagram of a new data protocol.
:::

Much of the WiFi-sensing literature evaluates a task-specific system with a fixed preprocessing pipeline. Model benchmarks such as SenseFi provide a systematic comparison of learning architectures and learning schemes [9]. These studies help explain how models behave for given data representations, but leave a different practical question: which preprocessing methods should be used to construct those representations? A strong result obtained with one model and one pipeline does not establish that the pipeline is suitable for other models or datasets. Conversely, a poor result may reflect a mismatch in the input processing rather than a limitation of the model.

Studying preprocessing requires more than replacing one filter in a finished sensing system. The available signal representation determines whether an operation has a physical interpretation. For example, phase calibration can be evaluated when complex CSI is retained, but cannot be meaningfully applied to an amplitude-only input. Methods also interact through the representations that they produce. A filter that generates signed fluctuations can be undermined by a later absolute-value operation, while a normalization method can change the meaning of amplitude if its output is reconstructed as complex CSI. Therefore, method choice, composition, and representation handling should be made explicit experimental variables.

Three questions guide this study. First, how does a preprocessing configuration affect different learning models across heterogeneous sensing datasets? Second, when the model and training setting are fixed, which component choices are beneficial or harmful, and how consistently do those effects appear across the other processing choices? Third, what signal changes explain the observed results, and what conditions should guide preprocessing selection?

To address these questions, we organize representative existing methods into five pluggable modules and evaluate them using a two-stage strategy. Stage I compares six predefined pipelines across nineteen registered architectures on Widar, Gait, XRF55, and ElderAL. Stage II fixes a representative model for each dataset and enumerates the applicable preprocessing combinations. The design combines broad model-pipeline screening with detailed component comparisons, without requiring the entire fine-grained grid to be trained on every model. Targeted ablations and signal measurements then explain the most pronounced failure cases.

The contributions of this work are summarized as follows.

- **A composable preprocessing benchmark.** We organize denoising, outlier handling, phase calibration, normalization, and subcarrier interpolation or reduction into replaceable modules. The evaluated library contains seventeen method choices across these five roles, with applicability determined by the retained CSI information. The contribution is the systematic organization and evaluation of representative existing methods.
- **A two-stage evaluation of breadth and component detail.** We construct 456 model-preset conditions in Stage I and 800 dataset-pipeline conditions in Stage II. The first stage exposes model-dependent preprocessing behavior; the second controls the model to isolate component substitutions within the defined combination space. Run status is reported separately from accuracy.
- **Mechanistic explanations of preprocessing failures.** Matched comparisons, waveform statistics, and component ablations connect performance degradation with physical time-window mismatch, filter parameterization and sign handling, and inter-subcarrier phase-structure distortion.
- **Evidence-based selection guidance.** We summarize when particular module choices are reasonable candidates, when their differences are small, and when an operation should be omitted or checked more carefully. These observations support reuse of the benchmark for evaluating additional methods and datasets.

### Concept of CSI preprocessing

#### CSI representation and operator applicability

For a complex CSI observation, the channel response at time index t, subcarrier k, and antenna link a can be expressed as

:::equation
H(t,k,a) = A(t,k,a) exp(j phi(t,k,a)).                         (1)
:::

Here, A and phi denote amplitude and phase. The temporal dimension records channel dynamics; the subcarrier dimension records the channel response at different frequency positions; and the antenna-link dimension provides distinct propagation observations [4,5,7]. Preprocessing should be interpreted with respect to these dimensions rather than applied solely because an array has a compatible shape.

The inputs used for Widar and Gait retain complex CSI. These datasets therefore permit evaluation of phase-calibration alternatives as well as amplitude processing. The XRF55 and ElderAL inputs used in this study are real-valued and amplitude-oriented. Their preprocessing spaces omit phase calibration. This distinction describes the particular inputs used in our experiments; it does not assert that every release or collection of either dataset lacks phase information.

Two implications follow. A unified tensor interface does not guarantee identical physical semantics, and a method that is valid for one representation may be inapplicable to another. The benchmark consequently identifies representation type before activating operators. It also preserves signed real-valued outputs when their signs carry statistical or temporal information.

#### Representative preprocessing methods

Existing systems use wavelet denoising, Butterworth filtering, Savitzky-Golay smoothing, PCA, and Hampel correction to reduce fluctuations and outliers [11-14]. For example, Wi-Gym combines Hampel correction with PCA to exploit correlations among subcarriers [11]. Wavelet-based activity recognition and gesture-recognition systems illustrate other combinations of signal processing and learning [12-14]. These methods rely on different assumptions: a frequency filter requires a meaningful sampling rate, a local polynomial smoother assumes that local variations can be approximated by a polynomial, and a neighborhood-based outlier method assumes that unusual values can be distinguished from valid dynamics.

Phase processing addresses estimated phase errors but can also alter sensing information. Existing studies use linear or polynomial correction and other phase-processing strategies [15,16]. Widar3.0 uses relationships between receiving antennas to suppress common phase offsets and constructs motion-related features [17]. Such operations require appropriate complex measurements and acquisition conditions. Normalization, as illustrated in DeepFi [18], addresses numerical scale; interpolation or reduction changes the subcarrier representation. These roles differ from temporal denoising and should be compared separately.

The library in this work covers representative alternatives within five operational roles. PCA, BVP construction, antenna-ratio features, and every possible preprocessing algorithm are not included in the evaluated Cartesian grid. They remain useful extensions, but are not counted as completed benchmark coverage.

#### Position within WiFi-sensing benchmarks

SenseFi compares learning models and learning strategies across sensing datasets and platforms [9]. Other studies investigate domain adaptation, self-supervised learning, and measurement-dependent recognition behavior [19-21]. These directions make clear that input construction and evaluation conditions affect the interpretation of sensing results. Our study concentrates on the preprocessing operators themselves: their alternatives, compositions, applicability, and observed effects under controlled downstream models.

:::placeholder Table 1 | Scope of representative sensing studies and this benchmark | 75
Reorganize original Table I. Suggested columns: work; principal experimental object; input representation; alternative preprocessing methods compared; combination evaluation; model setting; signal-level explanation. Keep SenseFi, Widar3.0, and this work. A short row for a representation protocol may be retained if needed, but do not make repeated claims that prior work has no ablations. Describe the evaluated scope precisely. Mark this work as two-stage coverage, not a full dataset-by-all-models-by-all-pipelines factorial experiment.
:::

## Results

### Modules: A pluggable library of CSI preprocessing methods

The benchmark treats the preprocessing pipeline as a composition of modules. Given dataset D_d, pipeline P_p, and model M_m, a sample X_d is transformed into X_d,p = P_p(X_d), after which the model produces its prediction. The measured outcome therefore depends jointly on the dataset, pipeline, and learning model:

:::equation
E(d,p,m) = Evaluate(M_m(P_p(X_d)); split_d, training_d).      (2)
:::

This formulation makes the object of comparison explicit. Changing a pipeline changes the model input, while changing the model changes how that input is used. To examine preprocessing effects, the benchmark records the method chosen at each module, its parameters, the actual execution branch, and the resulting input representation. Split and training settings remain fixed within the relevant comparison.

:::placeholder Figure 2 | Benchmark architecture and two-stage evaluation | 115
Reuse the upper structure of original Figure 2 and original Table II. Place a five-module library in the center, with alternative methods under each module. Connect it to Stage I model-preset screening and Stage II controlled combination evaluation. Show the complex-CSI and amplitude-only branches and the representation-preserving z-score branch. Move inherited readers and training utilities to a small supporting box. The final output should be component effects, failure mechanisms, and conditional recommendations.
:::

#### Denoising and outlier handling

The denoising module includes Wavelet, Butterworth, Savitzky-Golay, Band-pass, and Hampel. The methods span transform-based denoising, frequency filtering, local polynomial smoothing, and neighborhood-based replacement. Hampel is grouped under denoising in this implementation because it acts as a temporal correction stage. The separate outlier module compares IQR-based and z-score-based handling. Thus, the module taxonomy reflects the execution roles in this benchmark rather than mutually exclusive mathematical categories.

Both modules aim to suppress unwanted variation, but stronger suppression is not necessarily better for recognition. Human motion is nonstationary: rapid gestures, posture transitions, and short activity components may appear as peaks or abrupt changes. A filter or threshold that treats these changes as noise can remove class-discriminative information. The benchmark compares methods across identical downstream configurations and then inspects the signal changes associated with large accuracy differences.

#### Phase calibration

The phase module compares Linear, Polynomial, STC, and the implementation labeled Robust. These alternatives are evaluated only for Widar and Gait. Linear and polynomial methods estimate phase trends across subcarriers, while the Robust implementation also removes estimated temporal trends independently for individual subcarriers. This distinction is important because a correction applied equally to multiple subcarriers preserves their relative phase, whereas independent corrections can alter those relationships.

Method names are configuration labels rather than guarantees. In particular, a method labeled Robust is not assumed to preserve task-relevant phase structure. Its effectiveness is examined through recognition results and component-level diagnostics. For real-valued amplitude-only inputs, the phase module is explicitly inactive.

#### Normalization and subcarrier interpolation or reduction

The normalization module compares z-score standardization with min-max scaling. The former centers and scales an input relative to its mean and standard deviation; the latter maps it to a specified numerical range. Their effects depend on whether discriminative information is carried by relative fluctuations, numerical range, or differences in scale. The benchmark also separates z-score outlier handling from z-score normalization, because the two operations serve different purposes.

The interpolation or reduction module includes Linear, Cubic, Nearest, and anti-aliased Decimation. In the evaluated implementation these methods operate along the **subcarrier axis**. They compare alternative ways of constructing a fixed-size frequency representation, not alternative temporal interpolation schemes. Stage II uses a target of 15 subcarriers for Widar, Gait, and XRF55, and 64 for ElderAL. These targets are fixed within each dataset's fine-grained comparison. A complex interpolant or a larger processing cost does not by itself establish an advantage for sensing.

:::placeholder Table 2 | Evaluated module inventory and applicability | 95
List all five modules, their alternatives, number of choices, required input semantics, processing axis, principal parameters, and output type. Counts are 5 denoising choices, 2 outlier choices, 4 phase choices, 2 normalization choices, and 4 interpolation/reduction choices. Explain that seventeen counts method choices across roles, not seventeen newly proposed or necessarily distinct algorithms. Mark phase calibration as not applicable for the amplitude-only inputs. Give temporal windows in frames and physical units where available, and state the subcarrier targets.
:::

### Scenarios: A two-stage preprocessing benchmark

#### Stage I: Model-preset screening

Stage I combines six predefined pipelines with nineteen registered models on each of the four datasets. The presets are High Quality, Fast, Robust, Gesture Recognition, Activity Detection, and Localization. Their names indicate configuration bundles inherited from the implementation; they do not establish that a preset is best for the task named in its label. All six are evaluated across the dataset-specific tasks.

The nominal matrix contains 4 x 6 x 19 = 456 conditions. The current result tables contain 358 successful evaluations, 33 failed conditions, and 65 skipped conditions. Widar, Gait, and XRF55 each have 84 successful conditions out of 114; ElderAL has 106 out of 114. Accuracy comparisons use successful runs, while failed and skipped conditions retain distinct status labels. They are not assigned an accuracy of zero.

The registered model set spans feedforward, convolutional, recurrent, attention-based, state-space, graph-based, and other CSI-sensing architectures. The role of this broad screen is to reveal whether preset changes have similar effects across models and to identify a practical model for the detailed combination study. It does not imply that every architecture completed every preset condition.

#### Stage II: Controlled component combinations

Stage II fixes MLPModel for Widar and Gait, ResNet1D for XRF55, and CSITime for ElderAL. These models are the representative probes used in the original study. The datasets need not share one architecture, because their input lengths, tasks, and signal characteristics differ. Within each dataset, however, the model and training setup remain unchanged across the fine-grained grid.

Let D, O, C_d, N, and I denote the denoising, outlier, phase, normalization, and interpolation/reduction choice sets. The dataset-specific space is

:::equation
P_d = D x O x C_d x N x I.                                  (3)
:::

For complex CSI, there are 5 x 2 x 4 x 2 x 4 = 320 configurations per dataset. For amplitude-only CSI, C_d contains only the inactive phase option, yielding 5 x 2 x 1 x 2 x 4 = 80 configurations. The complete Stage II space contains 800 dataset-pipeline conditions, all of which have successful results in the current summaries.

The two stages therefore serve different purposes. Stage I evaluates model-pipeline dependence with a limited set of representative bundles. Stage II evaluates the defined component grid using one model per dataset. The study does not evaluate all 800 conditions under all nineteen models and does not search arbitrary module-order permutations or every algorithm parameter.

:::placeholder Table 3 | Two-stage design, model probes, and run coverage | 95
Split original Table II into a clear design table. Give Stage I nominal/successful/failed/skipped counts by dataset; Stage II candidate dimensions, representative model, and completed combinations. Show 456 nominal and 358 successful Stage I conditions, plus 800 successful Stage II conditions. List the six presets separately in Experimental Procedures. Do not describe 1,256 designed conditions as 1,256 successful experiments; the main tables currently provide 1,158 successful condition results before targeted ablations.
:::

### Benchmarking preprocessing in WiFi sensing

#### Overall model-preset behavior

Figure 3 summarizes the first-stage test accuracies. Both preprocessing choice and model architecture affect recognition, and their effects are not independent. On the same dataset, models differ under an identical preset. When a model is fixed, changing the preset can also produce a large accuracy change. More importantly, the direction of that change can differ across models.

This behavior is particularly clear on ElderAL. CNN1D reaches 51.11% under High Quality and 83.33% under Gesture Recognition, a gain of 32.22 percentage points. ResNet2D similarly increases from 47.04% to 80.74%. AttentionGRU exhibits the opposite response: its accuracy decreases from 79.63% to 49.26%, a loss of 30.37 percentage points under the same preset change. Thus, a pipeline that benefits one architecture can harm another. The input representation produced by preprocessing must be considered together with the model that extracts its features.

Sensitivity also varies across models. CSITime reaches 91.48% under High Quality on ElderAL and remains relatively competitive under several other presets. Some other architectures show wider fluctuations. This variation describes sensitivity to the evaluated preset choices; it is not a measure of stability across independent training seeds.

No preset is consistently best across all successful model-dataset conditions. Reporting only the highest accuracy under one pipeline would conceal these dependencies. The first-stage screen therefore provides a reason to examine component choices in a controlled setting rather than treating a preset as a universally appropriate front end.

:::placeholder Figure 3 | Stage I model-by-preset accuracy and execution status | 105
Reuse original Figure 3 as four heatmaps. Rows: nineteen registered models; columns: six presets. Use a separate visual code for failed and skipped conditions and state successful/nominal counts in each panel. Keep missing accuracy cells visibly missing. The caption should state that results use seed 42 and that the figure describes preset sensitivity, not multi-seed uncertainty.
:::

#### Denoising preferences depend on the dataset

Stage II makes it possible to compare denoising alternatives while retaining identical choices for the other modules. On Widar, Savitzky-Golay obtains the highest mean accuracy, 69.12%, followed by Butterworth at 68.52%. The difference between these two candidates is small compared with the larger degradation associated with some other component choices. On ElderAL, Savitzky-Golay reaches 85.67%, while Hampel reaches 64.19%, a difference of 21.48 percentage points. The large gap persists across the sixteen matched downstream configurations.

XRF55 shows similar mean accuracies for Wavelet, Savitzky-Golay, Butterworth, and Hampel: 83.78%, 83.71%, 83.46%, and 82.72%, respectively. The default Band-pass configuration reaches only 40.09%. This contrast motivates a closer examination of the filter settings rather than a general claim that band-pass filtering is unsuitable for activity recognition.

The observations suggest different priorities. A local smoother that preserves dynamic trends is a reasonable candidate for Widar and ElderAL under the present settings. On XRF55, several alternatives perform similarly, while the default Band-pass implementation requires parameter and representation checks. The preferred method cannot be inferred from the generic name of the denoising algorithm.

#### Phase calibration requires preservation of relative structure

On Widar, Linear, STC, and Polynomial yield mean accuracies of 69.97%, 69.59%, and 69.37%. The three choices have similar performance in this grid, making Linear a reasonable simple starting point. Robust reaches 59.48%, which is 10.49 percentage points below Linear. On the complete Gait grid, Linear, Polynomial, STC, and Robust yield 92.82%, 90.70%, 92.89%, and 46.56%, respectively.

The poor Robust results occur across many otherwise identical configurations. They indicate a problem associated with this particular calibration implementation under the evaluated settings. They do not establish that all robust estimation methods are harmful. The component ablations below examine which operation changes the signal structure.

#### Normalization can have opposite effects across datasets

Widar favors z-score normalization, with a mean accuracy of 69.45% compared with 64.76% for min-max, a difference of 4.69 percentage points. In matched comparisons, z-score performs better in 155 of 160 conditions. ElderAL shows the opposite preference: min-max reaches 81.69%, exceeding z-score at 77.36% by 4.33 percentage points. The mean difference on XRF55 is only about 0.28 percentage points.

These results illustrate that normalization is not merely a numerical convenience. Centering and scaling change the representation of deviations, while range scaling changes how amplitudes are distributed over a shared interval. The observed direction depends on the dataset and normalization scope. Distribution-based explanations provide useful hypotheses, but the benchmark does not independently establish that a particular distribution property is the sole cause of each accuracy difference.

#### Outlier and interpolation choices often have smaller effects

The difference between IQR and z-score outlier handling is small on Widar and XRF55. Z-score outlier handling improves mean accuracy by about 0.02 and 0.18 percentage points, respectively. On ElderAL, the mean improvement is larger, about 1.94 percentage points. These effects are smaller than the denoising failures examined above. IQR and z-score use different distribution summaries, so either choice should be evaluated when the input distribution or outlier pattern changes.

For subcarrier interpolation or reduction, the maximum difference between method-level means is about 0.47 percentage points on Widar and 0.67 on XRF55. Linear is consequently a reasonable simple reference in these settings. ElderAL is more sensitive: the spread of means is about 2.59 percentage points, and Decimation exceeds Linear by approximately 1.50 percentage points. The result concerns reduction or interpolation of the subcarrier dimension. It should not be explained as evidence that a temporal interpolation scheme is better for sparse frames.

:::placeholder Figure 4 | Stage II combination landscape and matched component effects | 115
Reuse original Figure 4 or the existing combination heatmaps. Prefer two panels: distributions of all successful configurations for each dataset, and matched accuracy differences for selected component substitutions. Include all 320 Gait conditions by merging the two complementary current result files. Each dot represents a pipeline condition at seed 42. Configuration-level variation or bootstrap intervals must not be labeled as independent-seed uncertainty or statistical significance.
:::

### Analysis: Why preprocessing can remove useful information

#### Hampel filtering and the physical span of a frame window

The ElderAL grid shows a consistent Hampel degradation. Its mean accuracy of 64.19% is below Wavelet, Butterworth, Savitzky-Golay, and Band-pass at 81.64%, 83.94%, 85.67%, and 82.20%. With the remaining modules fixed, Hampel is the lowest-performing denoising method in all sixteen matched conditions. The corresponding gaps are 17.45, 19.75, 21.48, and 18.01 percentage points.

Waveform inspection shows that some peaks, valleys, and rapid transitions are replaced by local medians. Statistics over 162 stratified samples show that the default eleven-frame neighborhood replaces 17.33% of amplitude entries and alters at least one channel in 91.85% of frames. Summed absolute inter-frame variation decreases by 67.63%, dynamic peak intensity decreases by 69.44%, and the average waveform correlation is 0.766. These observations indicate broad changes to the activity waveform rather than correction of only a few isolated impulses.

The retained ElderAL frames are sparse and irregularly spaced. Among 2,015 samples with durations from 3 to 7 s, fewer valid frames are associated with larger inter-frame gaps, with Pearson and Spearman correlations of -0.556 and -0.842. A neighborhood containing a fixed number of frames therefore represents different physical durations in different sequences. When the neighborhood increases from three to eleven frames, its median physical span expands from 0.378 to 2.484 s. The ninetieth percentile of the eleven-frame span reaches 4.634 s, covering a substantial portion of an activity sample.

The window ablation is consistent with this mismatch. Accuracy is 90.74% when Hampel is disabled and 78.15%, 70.37%, 62.96%, and 68.52% for three-, five-, seven-, and eleven-frame neighborhoods. Reducing the eleven-frame window to three frames recovers 9.63 percentage points, but still leaves a 12.59-point gap to the no-Hampel reference. The non-monotonic trend also shows that window length alone does not explain all behavior. The local-outlier assumption itself can be inappropriate when valid activity transitions occupy a large part of the neighborhood.

XRF55 provides a contrasting example. At 200 Hz, a sample contains 1,000 frames with regular spacing. Hampel changes 2.23% of values and retains 93.84% of temporal variation and 98.67% of dynamic peak intensity. Accuracy is 83.18% with Hampel and 84.70% without it in the targeted comparison. The contrast supports a conditional interpretation: fixed-frame correction is much less disruptive when the window remains physically local. These targeted values and the grid-level means correspond to different experimental settings and should not be combined into one performance estimate.

:::placeholder Figure 5 | Hampel waveform and sampling-scale analysis | 120
Combine original Figures 5-7. Panel A: raw and filtered ElderAL waveforms with replacement locations. Panel B: replacement ratio, temporal variation retention, peak retention, and waveform correlation for ElderAL and XRF55. Panel C: retained-frame count versus time gap and physical window spans. Panel D: no-filter and window-size accuracy comparison. Give sample counts 162 and 2,015, and distinguish signal diagnostics from the targeted classification ablation.
:::

#### Band-pass parameterization, sign handling, and bypass behavior

The default Band-pass configuration on XRF55 performs poorly in all sixteen matched downstream conditions. Its mean of 40.09% is below the four alternatives by approximately 42.62-43.68 percentage points. This consistent pattern identifies the band-pass branch as a priority for diagnosis.

The implementation uses a sampling-rate parameter of 1,000 Hz with a designed passband of 0.5-50 Hz. For XRF55 sampled at 200 Hz, those digital filter coefficients correspond to an effective physical passband of approximately 0.1-10 Hz. In a targeted comparison, changing only the sampling-rate parameter from 1,000 to 200 Hz improves accuracy from 38.18% to 61.97%, a gain of 23.79 percentage points. This recovery supports sampling-rate mismatch as an important contributor, although it does not recover all performance lost relative to the other denoising alternatives.

A second issue appears in the composition of filter and outlier handling. Band-pass processing creates signed, zero-centered fluctuations, but a downstream absolute-value operation folds them into one polarity. Across 3,300 XRF55 samples, 49.759% of the filter outputs lie below zero. Retaining the sign improves accuracy from 62.58% to 64.70% in the sign-handling comparison. The values belong to a separate diagnostic condition and are not a continuation of the sampling-rate-only experiment. The pipeline should record both the filtering parameters and the semantics of its output.

ElderAL illustrates why apparently acceptable accuracy may conceal limited operator use. The band-pass implementation requires at least 28 frames. Of 2,404 valid ElderAL segments, 2,010 are returned unchanged because they are too short, a bypass rate of 83.61%. Its grid mean of 82.20% therefore includes many samples on which filtering was not executed. Compatibility and activation coverage are part of the method's behavior; accuracy alone cannot show whether the intended operator acted on the data.

:::placeholder Figure 6 | Band-pass failure diagnosis | 110
Reuse original Figure 8 with three explicit panels: designed versus effective physical passband; sampling-rate correction and the separate sign-retention comparison; ElderAL executed/bypassed segment counts. State 1,000 versus 200 Hz, 49.759% negative outputs, and 2,010 of 2,404 bypassed segments. Do not imply that the targeted accuracy points share identical settings unless the corresponding logs confirm that they do.
:::

#### Independent phase detrending and inter-subcarrier distortion

The Robust implementation first unwraps phase over time, subtracts a common phase component across subcarriers for each antenna, and then estimates and removes a temporal slope independently for every subcarrier. The common correction leaves inter-subcarrier differences unchanged. Independent slopes, however, modify those differences. For subcarriers f and g on the same antenna, the corrected phase difference is

:::equation
Delta phi'_(f,g)(t) = Delta phi_(f,g)(t) - t(beta_f - beta_g). (4)
:::

When the estimated slopes differ, an additional relative rotation accumulates over time. Some estimated temporal trends may reflect human motion or phase-unwrapping behavior rather than removable hardware drift. Subtracting them independently can consequently alter the frequency-dimensional phase structure used for recognition.

The Gait component ablation supports this interpretation. With split, model, seed, and the other processing operations held fixed, accuracy is 95.83% without calibration and 95.87% with Linear. Independent temporal detrending reduces it to 70.68%; full Robust processing yields 67.32%. Replacing independent slopes with one shared slope per receiving antenna raises accuracy to 93.59%, a recovery of 26.27 percentage points relative to full Robust. The shared slope is the median of the estimated slopes across the thirty subcarriers for that antenna. This modification is a diagnostic control used to examine the existing implementation.

Signal measurements provide complementary evidence. Independent detrending increases mean adjacent-subcarrier phase differences from 0.812 to 1.439 rad on Widar and from 0.820 to 1.548 rad on Gait. Full Robust yields similar values, 1.444 and 1.552 rad. Additional relative rotation exceeding 90 degrees occurs in 42.47% and 49.36% of adjacent-subcarrier pairs. With a shared slope, the phase differences return to 0.812 and 0.820 rad and the proportion with rotations above 90 degrees is nearly zero.

These observations identify independent temporal-slope removal as a major source of degradation in the tested Robust branch. They explain why phase correction should be evaluated for preservation of relative structure, not only for removal of an estimated trend. The result is specific to the implementation and conditions examined here; it does not show that every phase-calibration method or robust estimator removes useful information.

:::placeholder Figure 7 | Phase-calibration ablation and structure preservation | 115
Combine original Figures 9 and 10. Panel A: Gait no-calibration, Linear, independent detrending, full Robust, and shared-slope accuracies. Panel B: adjacent-subcarrier phase-difference statistics on Widar and Gait. Panel C: proportions with added relative rotations above 90 degrees. Include the algebraic explanation of a common versus independent correction. Label the shared-slope branch as a mechanism-control variant, not a newly benchmarked algorithm family.
:::

## Discussion

### Summary of benchmarks and recommendations

The benchmark shows that preprocessing selection is conditional. Model-preset screening reveals different, sometimes opposite, responses to the same pipeline change. Fine-grained comparisons show that module effects are unequal: a poorly matched denoising or phase operation can dominate the performance change, while several outlier and interpolation alternatives differ only slightly. Mechanism analyses then connect large degradations with violations of method assumptions or loss of signal semantics.

The following recommendations summarize the observed settings.

- **Determine the available signal information first.** Use phase-calibration alternatives only when the input retains meaningful complex CSI. For amplitude-only inputs, omit the phase module. Preserve signed normalized amplitudes and signed filter outputs when they carry information used by the model.
- **Match temporal operations to physical time.** For dense, regularly sampled CSI, frequency filters and short neighborhood methods are reasonable candidates after parameter checks. For sparse, irregular sequences, inspect the duration spanned by a frame window and the locations replaced by an outlier filter. The ElderAL results favor Savitzky-Golay over the tested Hampel setting.
- **Treat phase structure as information to preserve.** Linear and STC are reasonable starting candidates for the complex-CSI settings studied here. Independent temporal detrending requires particular care because it can introduce relative phase rotation. A shared-correction control can help diagnose this failure.
- **Evaluate normalization for the dataset and model.** Z-score performs better on Widar, while min-max performs better on ElderAL. Neither preference supports a universal default. State the statistics-estimation scope and retain the sign of standardized real-valued features.
- **Prefer simple references when alternatives are similar.** Linear subcarrier interpolation is a useful reference for Widar and XRF55, where the method-level differences are small. Decimation is a competitive candidate for ElderAL in the evaluated reduction setting. These recommendations concern frequency representation, not temporal resampling.
- **Report when an operation is actually applied.** Record short-sequence bypasses, invalid inputs, failed runs, and skipped conditions. A method's apparent accuracy should be interpreted together with its activation coverage.

:::placeholder Table 4 | Conditional preprocessing selection guide | 100
Create a concise decision table with columns: observed data condition; candidate module/method; evidence in this study; checks before reuse; scope of recommendation. Include complex versus amplitude-only CSI, regular versus irregular sampling, signed intermediate outputs, normalization preferences, and small interpolation differences. Each row should name an observed setting instead of claiming a universally optimal algorithm.
:::

### Benchmark value for the community

The benchmark offers a reusable way to ask how existing preprocessing choices affect a sensing experiment. Its value comes from the combination of module coverage, method composition, broad model screening, controlled fine-grained comparisons, and signal-level explanation. Researchers can add a method within an existing role, retain the other processing choices, and compare the result against matched configurations. They can also evaluate whether a new dataset changes the applicability or effectiveness of a module.

This role differs from optimizing one pipeline for the highest accuracy on one task. A useful preprocessing benchmark should preserve both favorable and unfavorable results, document configurations that cannot be executed, and explain why a method fails when evidence is available. The present experiments provide examples of all three. They also show why a benchmark should compare alternative algorithms within a role rather than rely only on a fixed combination of default operators.

The evaluated breadth spans five modules, seventeen method choices across roles, four heterogeneous datasets, nineteen registered models, six preset bundles, and an 800-condition fine-grained space. Together, these dimensions support a systematic comparison of representative preprocessing alternatives and their compositions. The benchmark connects algorithm coverage with controlled testing and interpretable analysis, making it useful for evaluating existing methods and incorporating further alternatives.

### Limitations of the study

The main grid uses one training seed, 42. This controls initialization for the large combination study but does not quantify uncertainty across independent training runs. Configuration-level variation describes changes among pipelines, not random-seed stability. Small differences should therefore be treated as descriptive observations. Stronger claims about reproducibility or statistical significance require repeated seeds under matched conditions.

Stage I contains failed and skipped conditions, and Stage II uses one representative model per dataset. Component conclusions are consequently conditional on those probes. The design does not fully separate every dataset-model interaction, and an observed ranking may change under a different architecture. The original study considered accuracy and computational practicality when choosing probes, but a complete, uniform measurement of preprocessing latency, model FLOPs, memory, and training cost is not available in the supplied main results. We therefore do not claim a measured Pareto-optimal selection.

The library covers selected representatives and fixed parameter settings. It does not exhaustively tune every algorithm, compare all processing orders, or include all feature-construction methods. The complex-CSI z-score branch has a documented representation-preserving order adjustment, which is fixed within the corresponding comparisons. Normalization scope also differs between dataset branches. These implementation choices are part of the evaluated pipelines and should be recorded when interpreting module effects.

The targeted ablations provide useful explanations within their controlled conditions, but their exact classification values cannot be substituted for grid-level averages. The absence of a phase module for an input is a property of the representation used here. Findings do not establish universal behavior across all hardware, dataset versions, subjects, or acquisition environments.

### Challenges and future directions

An important extension is to select preprocessing according to measurable data characteristics. Sampling regularity, physical window duration, sequence length, retained phase information, and signed-output semantics could guide the activation and parameterization of candidate methods. The present study supplies diagnostic examples for such an extension; it does not implement an automatic selector.

Broader evaluation should include additional hardware platforms, more dataset versions, and several controlled model probes for key component comparisons. Repeated-seed experiments are especially valuable for close rankings. A uniform cost measurement should distinguish preprocessing time from training time, caching, and input-size changes. Order-aware comparisons and further feature-construction alternatives can expand the library once the corresponding execution semantics and comparability conditions are defined.

### Concluding remarks

This work presents a pluggable benchmark for systematic evaluation of existing CSI preprocessing methods. Five modules organize the candidate choices, and a two-stage design connects model-preset screening with fine-grained component comparisons on four heterogeneous datasets. The resulting observations show that sensing performance depends on how data properties, preprocessing choices, and learning models fit together.

The main practical finding is that suppressing variation does not necessarily improve sensing. A fixed-frame outlier method can remove valid activity dynamics, a misparameterized filter can operate on the wrong physical frequency range, and independent phase correction can damage relative signal structure. By connecting these failures with controlled comparisons and signal diagnostics, the benchmark provides a basis for more informed preprocessing selection and clearer interpretation of WiFi-sensing experiments.

## Experimental procedures

### Resource availability

#### Lead contact

Author names, affiliations, and the corresponding contact are not specified in the supplied anonymous manuscript. Insert the confirmed author information before submission.

#### Materials, data, and code availability

The experiments use existing Widar, Gait, XRF55, and ElderAL data. The supplied workspace contains preprocessing implementations, experiment scripts, summary tables, and diagnostic artifacts. The final release should identify the exact dataset versions and access sources, code revision, split manifests, module parameters, and result files. A public repository URL, archival identifier, and release license have not been provided, so no completed public release is claimed in this draft. Access and redistribution should follow the original dataset terms.

### Datasets and task definitions

Widar is used for gesture recognition, with gesture type as the class label. Gait is used for gait-based identification, with user identity as the target. XRF55 is used for fine-grained activity recognition, with action identity as the target; the experiments use the first three users. ElderAL is used for activity classification, with action identity as the target. Acquisition location is used as a grouping variable for ElderAL, rather than being added to the prediction label.

Widar and Gait retain complex CSI, while the XRF55 and ElderAL inputs used here are real-valued and amplitude-oriented. The dataset-specific sequence lengths are 1,500 for Widar and Gait, 1,000 for XRF55, and 80 for ElderAL. Sequence-length handling is separate from subcarrier interpolation or reduction.

:::placeholder Table 5 | Datasets, inputs, tasks, and training configuration | 90
Reuse original Table III. Include dataset/version, task, class-label definition, retained signal information, split unit, split ratio, input length, subcarrier target for Stage II, epochs, and seed. Add verified sample/class counts and hardware metadata from the exact adopted subsets when available. Do not copy the joint activity-location task from the SDP paper; this manuscript uses ElderAL activity labels with location-based grouping.
:::

### Data partitioning and training

For Widar, the grouping variable combines position, orientation, and receiver identity. For Gait, it combines trajectory identity and receiver identity. ElderAL groups samples by acquisition location. Approximately 70% of groups are assigned to training, and the remaining groups are divided equally between validation and test, producing an approximate 70%/15%/15% ratio. Grouping prevents the chosen acquisition groups from being distributed across subsets; it does not by itself establish subject-independent evaluation.

XRF55 uses a fixed repetition split: repetitions 1-12 for training, 13-16 for validation, and 17-20 for testing. The same first-three-user subset is used across its configurations. All models and pipelines in a dataset share its split. The labels and splitting rules remain dataset-specific because task definitions and collection procedures differ.

Classification uses cross-entropy loss and AdamW [22]. The batch size is 32, the initial learning rate is 3 x 10^-4, and weight decay is 1 x 10^-3. When validation loss does not improve for five consecutive epochs, the learning rate is multiplied by 0.1. The training budgets are 80, 60, 50, and 20 epochs for Widar, Gait, XRF55, and ElderAL, respectively. These budgets remain fixed across the preprocessing choices within each dataset. Test accuracy is the main metric reported by the supplied combination summaries.

The main study uses random seed 42. The computing server has two NVIDIA A100 80-GB PCIe GPUs. The original environment reports driver version 560.35.03 and PyTorch 2.6.0+cu124. Driver support for CUDA 12.6 and the PyTorch CUDA 12.4 build are different environment properties and should be listed separately.

### Presets, parameters, and execution semantics

The High Quality preset combines Butterworth, STC, and z-score normalization. Fast combines Savitzky-Golay, Linear calibration, and min-max. Robust combines Wavelet, Robust calibration, and z-score. Gesture Recognition combines Butterworth, STC, z-score, and Cubic interpolation. Activity Detection combines Savitzky-Golay, Polynomial calibration, and z-score. Localization combines Wavelet, Robust calibration, z-score, and Cubic interpolation. Phase operators are omitted when the input representation does not support them. Stages absent from a preset are inactive, which differs from the fully populated applicable Stage II grid.

:::placeholder Table 6 | Six preset bundles and fine-grained method parameters | 110
Separate the preset half of original Table II from the Stage II inventory. State exact parameters and inactive stages. Current preset parameters include High Quality Butterworth order 5/cutoff 0.3; Fast Savitzky-Golay window 7/order 3; Gesture Recognition Butterworth order 4/cutoff 0.25 with target K=30; Activity Detection Savitzky-Golay window 11/order 3 and polynomial degree 2; Localization target K=64. Stage II uses its own parameters, including polynomial degree 3, Savitzky-Golay window 7/order 3, and dataset-specific Hampel windows. Distinguish preset settings from targeted diagnostic ablations.
:::

The ordinary implementation order is denoising, outlier handling, phase calibration, normalization, and subcarrier interpolation or reduction. Arbitrary module-order permutations are not evaluated. For complex CSI with z-score amplitude normalization, a representation-preserving branch applies denoising, outlier handling, calibration, and interpolation while the signal remains complex, then standardizes amplitude and directly emits amplitude and phase channels. Thus, the actual order of normalization and interpolation differs between the z-score and min-max branches. This branch is documented explicitly rather than hidden behind the logical module ordering.

For normalized amplitude A_tilde and calibrated phase phi, model input is constructed as

:::equation
X_AP = Concat(A_tilde, phi), with shape T x K x 2A.           (5)
:::

The first A channels store amplitude features and the next A channels store phase. Negative standardized amplitude values are retained as real features. Reconstructing A_tilde exp(j phi) would turn a negative amplitude into an additional pi phase rotation, and taking an absolute value would discard its sign. Direct real-channel construction avoids these transformations.

For the real-valued XRF55 branch, splitting precedes estimation of dataset-level normalization statistics. The training-set mean mu_tr and standard deviation sigma_tr are applied to training, validation, and test inputs:

:::equation
Z_s = (X_s - mu_tr) / (sigma_tr + epsilon),                  (6)
where s is train, validation, or test.
:::

Validation and test subsets do not fit their own dataset-level statistics. For branches using per-sample normalization, the scope should be stated as per-sample rather than described as training-set normalization. Signed XRF55 outputs are not subjected to an unconditional absolute-value operation. The band-pass diagnostic separately examines an absolute-value transformation within downstream outlier handling.

### Component comparisons and signal measurements

The grid allows matched comparisons that change one module choice while retaining the other configuration choices. For a choice a versus reference b and a set Q of matched downstream configurations, the mean difference is

:::equation
Delta_(a,b) = mean over q in Q of [Acc(a,q) - Acc(b,q)].     (7)
:::

On each amplitude-only grid, two denoising alternatives have sixteen matched conditions. On a complete complex-CSI grid, two phase-calibration alternatives have eighty matched conditions, and two normalization alternatives have 160. Marginal means average over the remaining choices in the balanced grid. These averages describe the evaluated parameter combinations and model probe.

Signal diagnostics examine replacement coverage, summed absolute inter-frame variation, dynamic peaks, waveform correlation, the physical span of temporal windows, filter activation coverage, and adjacent-subcarrier phase relationships. The targeted Hampel, Band-pass, and Robust comparisons hold the settings described in their original analysis fixed. Their reference conditions are identified separately from the grid configurations.

:::placeholder Table 7 | Definitions and provenance of diagnostic measurements | 95
Give a formula or exact implementation definition for replacement ratio, affected-frame fraction, temporal-variation retention, dynamic-peak intensity, waveform correlation, physical window span, adjacent-subcarrier phase difference, and added relative rotation. State sample counts, selected channels, aggregation scope, and corresponding result files. Reuse the existing analysis definitions; do not invent an unreported peak estimator or claim that all diagnostic subsets are identical.
:::

### Benchmark implementation and extension

The implementation reuses dataset readers, model interfaces, and training utilities from the existing SDP codebase [10]. These utilities are supporting infrastructure. The experimental object in this study is the library of alternative preprocessing operators and their compositions, together with the two-stage comparisons and mechanism analyses described above.

A configuration identifies each active module by method and parameters. Dataset adapters determine the retained signal semantics and applicable modules. The model interface receives the resulting real-valued feature channels. The grid scripts also reuse common preprocessing prefixes to avoid repeated loading and computation; each final configuration still receives its own model-training result. Caching should be recorded when interpreting run duration.

For extension, a new method should implement the appropriate module interface and state its input requirements, output semantics, and configurable parameters. Comparisons can then retain the split, probe model, and other module choices. Reproducibility records should include configuration identity, actual execution branch, split manifest, seed, training settings, software revision, and run status. These reporting fields support reuse but are not all established as a completed public archival release by this draft.

## Author and research declarations

**Author contributions.** Insert confirmed CRediT roles and author identities. The anonymous source does not establish the allocation of contributions.

**Funding and acknowledgments.** Insert confirmed funding sources and acknowledgments, or a confirmed statement of no external funding. No funding information is inferred from the comparison papers.

**Declaration of interests.** Insert the authors' confirmed conflict-of-interest statement.

**Ethics.** This draft reports analysis of existing datasets. State the adopted datasets' consent and ethics conditions and any required approval or exemption for the reuse. The supplied manuscript does not document a new human-subject recruitment study or an institutional approval number.

**Writing assistance.** This rewrite used AI assistance for structural reorganization, language revision, and document preparation. It introduced no newly run sensing experiment. Authors should verify the text and report assistance according to the selected venue's requirements.

## References

[1] F. Liu, Y. Cui, C. Masouros, J. Xu, T. X. Han, Y. C. Eldar, and S. Buzzi, "Integrated Sensing and Communications: Toward Dual-Functional Wireless Networks for 6G and Beyond," IEEE Journal on Selected Areas in Communications, vol. 40, no. 6, pp. 1728-1767, 2022. DOI: 10.1109/JSAC.2022.3156632.

[2] Z. Wei et al., "Integrated Sensing and Communication Signals Toward 5G-A and 6G: A Survey," IEEE Internet of Things Journal, vol. 10, no. 13, pp. 11068-11092, 2023. DOI: 10.1109/JIOT.2023.3235618.

[3] J. Liu, H. Liu, Y. Chen, Y. Wang, and C. Wang, "Wireless Sensing for Human Activity: A Survey," IEEE Communications Surveys & Tutorials, vol. 22, no. 3, pp. 1629-1645, 2020. DOI: 10.1109/COMST.2019.2934489.

[4] Y. Ma, G. Zhou, and S. Wang, "WiFi Sensing with Channel State Information: A Survey," ACM Computing Surveys, vol. 52, no. 3, article 46, 2019. DOI: 10.1145/3310194.

[5] S. Yousefi, H. Narui, S. Dayal, S. Ermon, and S. Valaee, "A Survey on Behavior Recognition Using WiFi Channel State Information," IEEE Communications Magazine, vol. 55, no. 10, pp. 98-104, 2017. DOI: 10.1109/MCOM.2017.1700082.

[6] F. Li, M. Valero, H. Shahriar, R. A. Khan, and S. I. Ahamed, "Wi-COVID: A COVID-19 Symptom Detection and Patient Monitoring Framework Using WiFi," Smart Health, vol. 19, article 100147, 2021. DOI: 10.1016/j.smhl.2020.100147.

[7] D. Halperin, W. Hu, A. Sheth, and D. Wetherall, "Tool Release: Gathering 802.11n Traces with Channel State Information," ACM SIGCOMM Computer Communication Review, vol. 41, no. 1, p. 53, 2011. DOI: 10.1145/1925861.1925870.

[8] W. Wang, A. X. Liu, M. Shahzad, K. Ling, and S. Lu, "Understanding and Modeling of WiFi Signal Based Human Activity Recognition," Proceedings of ACM MobiCom, pp. 65-76, 2015. DOI: 10.1145/2789168.2790093.

[9] J. Yang, X. Chen, H. Zou, C. X. Lu, D. Wang, S. Sun, and L. Xie, "SenseFi: A Library and Benchmark on Deep-Learning-Empowered WiFi Human Sensing," Patterns, vol. 4, no. 3, article 100703, 2023. DOI: 10.1016/j.patter.2023.100703.

[10] D. Zhang, J. Huang, Y. Cui, X. Cao, T. X. Han, X. Jing, and C. Masouros, "SDP: A Unified Protocol and Benchmarking Framework for Reproducible Wi-Fi Sensing," IEEE Transactions on Mobile Computing, accepted author version, 2026. DOI: 10.1109/TMC.2026.3723025.

[11] L. Zhang et al., "Wi-Gym: Gymnastics Activity Assessment Using Commodity Wi-Fi," IEEE Internet of Things Journal, vol. 9, no. 23, pp. 24051-24064, 2022. DOI: 10.1109/JIOT.2022.3188916.

[12] I. A. Showmik, T. F. Sanam, and H. Imtiaz, "Human Activity Recognition from Wi-Fi CSI Data Using Principal Component-Based Wavelet CNN," Digital Signal Processing, vol. 138, article 104056, 2023. DOI: 10.1016/j.dsp.2023.104056.

[13] N. Damodaran, E. Haruni, M. Kokhkharova, and J. Schafer, "Device Free Human Activity and Fall Recognition Using WiFi Channel State Information (CSI)," CCF Transactions on Pervasive Computing and Interaction, vol. 2, pp. 1-17, 2020. DOI: 10.1007/s42486-020-00027-1.

[14] H. Yang et al., "Recognition for Human Gestures Based on Convolutional Neural Network Using the Off-the-Shelf Wi-Fi Routers," Wireless Communications and Mobile Computing, article 7821241, 2021. DOI: 10.1155/2021/7821241.

[15] G. Diaz, I. Sobron, I. Eizmendi, I. Landa, J. Coyote, and M. Velez, "Channel Phase Processing in Wireless Networks for Human Activity Recognition," Internet of Things, vol. 24, article 100960, 2023. DOI: 10.1016/j.iot.2023.100960.

[16] Q. Wang, Q. Yao, Y. Li, Y. Zhang, and C. Xu, "PLAP: CSI-Based Passive Localization with Amplitude and Phase Information Using CNN and BGRU," Mobile Information Systems, article 1684490, 2023. DOI: 10.1155/2023/1684490.

[17] Y. Zhang, Y. Zheng, K. Qian, G. Zhang, Y. Liu, C. Wu, and Z. Yang, "Widar3.0: Zero-Effort Cross-Domain Gesture Recognition With Wi-Fi," IEEE Transactions on Pattern Analysis and Machine Intelligence, vol. 44, no. 11, pp. 8671-8688, 2022. DOI: 10.1109/TPAMI.2021.3105387.

[18] X. Wang, L. Gao, S. Mao, and S. Pandey, "DeepFi: Deep Learning for Indoor Fingerprinting Using Channel State Information," Proceedings of IEEE WCNC, pp. 1666-1671, 2015. DOI: 10.1109/WCNC.2015.7127718.

[19] Z. Zhou, F. Wang, and W. Gong, "i-Sample: Augment Domain Adversarial Adaptation Models for WiFi-Based HAR," ACM Transactions on Sensor Networks, vol. 20, no. 2, article 38, 2024. DOI: 10.1145/3616494.

[20] K. Xu, J. Wang, H. Zhu, and D. Zheng, "Evaluating Self-Supervised Learning for WiFi CSI-Based Human Activity Recognition," ACM Transactions on Sensor Networks, vol. 21, no. 2, article 21, 2025. DOI: 10.1145/3715130.

[21] X. Li, X. Cai, Y. Hei, and R. Yuan, "NLOS Identification and Mitigation Based on Channel State Information for Indoor WiFi Localisation," IET Communications, vol. 11, no. 4, pp. 531-537, 2017. DOI: 10.1049/iet-com.2016.0562.

[22] I. Loshchilov and F. Hutter, "Decoupled Weight Decay Regularization," Proceedings of ICLR, 2019. https://arxiv.org/abs/1711.05101.

---

# 中文改写说明：每一部分怎么写、复用什么、放什么图表

## A. 本次改写的主线和使用方式

这份文件前半部分是完整英文改写稿，后半部分是逐节写作说明。英文稿保留原题、四个数据集、原有任务与划分、六个 preset、十九个注册模型、五类模块、两阶段设计，以及三个机制分析案例。主要修改发生在章节位置、贡献表达、因果解释的边界和少数必须核对的技术语义。没有为改写新跑实验，也没有把补充设想写成完成的研究。

新的中心问题是：**既有预处理算法如何被组织、组合和系统评测；哪些模块选择在什么条件下适合；哪些失败能够被解释。** “统一数据协议”只在实现依赖处简短交代。复现是让组件比较可信的条件，不再作为整篇文章最主要的新颖性。这样，贡献来自实验对象和分析深度，而不是不断重复“统一框架”或反复对比 SDP。

SenseFi 的结构和语言风格在这里分别落实。结构上采用 Graphical abstract、Highlights、The bigger picture、Summary、Introduction、Concept、Results、Discussion、Experimental procedures、声明及参考文献。语言上采用“问题与研究对象先行、覆盖范围具体、观察先于解释、解释通向建议”的顺序；用 we organize / evaluate / observe / analyze / recommend 这样的动词，并限制推荐的适用范围。借用的是写作组织和论述节奏，没有直接搬用 SenseFi 的研究结果、句子或作者声明。

## B. SenseFi 模板与本稿的对应关系

**前置材料。** SenseFi 用图文摘要、Highlights 和 The bigger picture 提前交代资源与用途。本稿对应展示五类模块、两阶段机制、四个数据集、失效解释和选择建议。若最终投 IEEE 双栏会议，可把 Highlights 和 The bigger picture 合并进摘要或引言；当前保留它们是为了按你要求完整提供 SenseFi 式模板。

**Introduction / Concept。** SenseFi 先提出深度学习与数据平台的问题，再说明 CSI、数据处理及信号维度。本稿先提出预处理选择问题，再解释复数与实数输入、模块适用性和处理轴。原稿 I、II、III-B 中的内容在此重排。

**Results: Models / Scenarios / Benchmarking / Analysis。** SenseFi 的 Models 换成本稿的 Modules；其 Learning schemes 换成两阶段评测场景；其深度模型基准换成预处理基准；其模型分析换成三个预处理机制分析。这个替换保留了 SenseFi 从资源介绍到实验观察再到深入解释的完整逻辑。

**Discussion。** SenseFi 先总结建议，再讲挑战、未来方向和结语。本稿把原稿 IV-C 中散落的选择建议移到这一部分，并把 V 的未来工作压缩后放到同一位置。增加明确的局限小节，避免单 seed 或单代表模型的结果被写成普遍结论。

**Experimental procedures。** SenseFi 把具体实现放在结果之后。本稿相应将原 III 的接口、执行规则、公式和原 IV-A、IV-B 的划分、训练、幅相表示处理移到文末。正文仍保留理解结果所需的关键数量和语义，避免读者先看大量工程细节才看到贡献。

## C. 逐节写作与原稿复用地图

### C1. Graphical abstract / Highlights / The bigger picture

**怎么写。** 用一张图和四条短句回答“研究对象、评测方式、发现、用途”。大图景用一个段落说明为什么社区需要比较预处理选择：输入由多个运算共同构造，模型比较不能替代组件比较。不要从 6G 宏观愿景开始，也不要把协议名称写成图中心。

**复用来源。** 原摘要、I 的问题段和四条贡献；原 Figure 1、Figure 2 的素材可以重新组合。此处属于把已有内容变成 SenseFi 式前置介绍，几乎无需新增实验信息。

**图表。** GA 占位已给出完整画法。重点是五类可替换模块和两个测试阶段。原图中的 Legacy SDP 可缩成支持性代码工具，或只在正文实现处注明。

### C2. Summary

**怎么写。** 第一、二句说明预处理常被固定、效果依赖数据与模型。接着交代五类模块及算法可组合性，再交代十九模型和六 preset 的广度评测与 320/80 的细粒度评测。最后用一至两句给出主要观察和三个机制案例，收束到选择既有算法的价值。

**复用来源。** 原摘要基本可按“研究缺口—资源与设计—发现—用途”排列。保留原来“没有通用最优管线”的结论，删去反复出现的 built upon SDP 和支撑统一协议演进的中心表述。

**语言重点。** 用代表性覆盖、组合比较、mechanistic analysis。不要写 proposed novel denoising algorithms，不要把新算法作为贡献。摘要也不需要反复解释与 SDP 的关系。

### C3. Introduction

**怎么写。** 第一段简短介绍 WiFi 感知和 CSI。第二段说明预处理改变了模型可见的信息，接原 Figure 1。第三、四段讨论现有模型比较无法回答组件选择及表示语义问题。第五段明确三个研究问题。第六段介绍两阶段方法，最后列四条贡献。

**复用来源。** 原 I 的大多数论点和 II-B 末尾关于数据、管线、模型共同作用的段落。6G 背景压缩到一句；保留原论述而减少不必要的宏观铺垫。原贡献 1 改写为模块组织与可组合评测，原贡献 2 改写为两阶段覆盖，原贡献 3 保留机制解释，原贡献 4 保留有条件的建议。

**图表。** Figure 1 复用原动机图，需修改标签。这里的“同样输入经不同管线产生不同结果”直接导向研究问题，比“异构数据需要统一格式”更能突出本文。

### C4. Concept of CSI preprocessing

**怎么写。** 分三小节：输入语义与适用性；典型处理方法及其假设；基准中的研究位置。公式保留 H=A exp(j phi)，不需要建立全新的硬件误差理论。说明时间轴、子载波轴、天线轴，强调操作针对哪个轴、改变什么。

**复用来源。** 原 II-A 和 III-B。Wavelet、Butterworth、Savitzky-Golay、Hampel、相位、归一化等原文可以直接重组；保留 Wi-Gym、Widar3.0、DeepFi 等已有文献。PCA 只作为背景，不放进已评测计数。

**必须明确。** XRF55 和 ElderAL 是本研究采用的幅度输入，不等于宣布其所有版本永远无相位；插值比较是子载波轴。原 Table I 可变成 Table 1，避免把本稿写成所有模型和全部管线的三维完全析因试验。

### C5. Results / Modules

**怎么写。** 仿照 SenseFi 的模型库介绍，把预处理库作为正文结果中的第一块。先写 E(d,p,m) 的研究对象，再按去噪与异常值、相位、归一化与子载波插值三个小节介绍。每一类只交代“任务、代表方法、条件、潜在信息损失”，不要在这里铺开所有标准算法的教科书推导。

**复用来源。** 原 III-A、III-B，配合原 II-A 中已有算法背景。新增的整理是把这些内容作为 module library 统一介绍。Hampel 放在 denoising 是实现角色；它本质也涉及异常值，所以不要把五类写成严格互斥的数学分类。

**图表。** Figure 2 显示模块和两阶段；Table 2 显示方法名称、参数、输入语义和处理轴。这张方法清单表能最直接体现“覆盖了什么”。“17”是五类角色内的可选项之和，不是十七项新方法。

### C6. Results / Scenarios

**怎么写。** Stage I 回答模型对 preset 是否敏感，Stage II 回答固定模型时组件怎么选。分别写规模、控制变量、选用模型、限制，再用一段解释两阶段互补。保留 5×2×4×2×4 与 5×2×1×2×4 的公式即可。

**复用来源。** 原 III-C、III-D 和 Table II，几乎全部保留。具体模型仍为 Widar/Gait 的 MLPModel、XRF55 的 ResNet1D、ElderAL 的 CSITime。没有更换模型，也没有添加新训练。

**图表。** Table 3 单独展示设计与覆盖。Stage I 456 为名义条件，其中 358 成功、33 失败、65 跳过；Stage II 当前两份 Gait 文件合并后有 800 成功条件。将 1,256 称为设计条件，1,158 称为成功主结果条件，其他机制消融另外统计，避免把规模混为一谈。

### C7. Benchmarking / Overall model-preset behavior

**怎么写。** 第一段先给观察：相同 preset 改动在不同模型上方向不一致。第二段保留 ElderAL 的 CNN1D、ResNet2D 和 AttentionGRU 数字作为具体证据。第三段说明模型敏感度的差异，最后转到固定代表模型的组件比较。

**复用来源。** 原 IV-C1 基本整体移动。51.11→83.33、47.04→80.74、79.63→49.26 等数值保留。将 stability 改成 preset sensitivity 或 consistency across tested presets，避免把配置变化称作跨 seed 稳定性。

**图表。** Figure 3 复用原热力图。失败和跳过不要填零；图注要说明 nineteen 是注册集合，并注明成功覆盖，而不是假装所有十九种模型全都完成。

### C8. Benchmarking / Component comparisons

**怎么写。** 按去噪、相位、归一化、异常值和插值的结果分开讨论。每段先给均值或匹配差异，再说明它给选择提供什么信息。突出“模块影响大小不均等”和“归一化方向跨数据集相反”。不要只列每个数据集的一条最佳管线。

**复用来源。** 原 IV-C2 中的数值与分析大部分保留。Widar z-score 优势 4.69 pp、ElderAL min-max 优势 4.33 pp、XRF55 默认带通的大幅下降都可直接保留。Gait 相位均值按完整 320 条当前汇总更新为 92.82、90.70、92.89、46.56。

**图表。** Figure 4 用组合全景加匹配组件差异。插值的 0.47、0.67、2.59 pp 是子载波处理效应；不再解释为“时间序列连续所以线性时间插值更合适”。主要条件推荐统一移到 Discussion，结果部分减少重复。

### C9. Analysis / Hampel

**怎么写。** 以“固定帧数不等于固定物理时间”作为小节中心。先说明所有匹配条件都差，再用替换比例和动态损失说明发生了什么，再用采样间隔、窗口跨度及消融说明为什么，最后用 XRF55 对照限定结论。

**复用来源。** 原 IV-D1 和 Figures 5-7 几乎完整保留。162 个诊断样本、2,015 个时长样本、17.33%、91.85%、67.63%、69.44%、0.766、窗口 ablation 和 XRF55 对照都有具体内容支撑。这里已是本文非常有辨识度的贡献，不需要新增算法包装。

**图表。** Figure 5 合并替换位置、动态统计、采样尺度和窗口消融。篇幅紧张时将混淆矩阵放补充材料，主图保留解释链即可。图注要分清不同诊断样本集。

### C10. Analysis / Band-pass

**怎么写。** 分“参数错配—组合中的符号损失—操作未实际执行”三层。先以匹配结果定位带通，再解释 1,000/200 Hz 如何改变物理通带，再解释 abs 的影响，最后用 ElderAL 83.61% bypass 展示单看准确率的局限。

**复用来源。** 原 IV-D2 全部关键结论保留。38.18→61.97 与 62.58→64.70 是不同诊断对比，不能连写成同一条顺序修复曲线。采样率修复改善很大，但没有恢复全部差距，所以改写为重要贡献因素，避免写成已经完全解释了失效。

**图表。** Figure 6 复用原 Figure 8。可加设计通带与实际通带的小示意，但不要虚构新频谱实验。注明 2,010/2,404 未执行条件。

### C11. Analysis / Phase structure

**怎么写。** 以“独立时间去趋势改变子载波间相位关系”为核心。先交代操作步骤，再写 Delta phi 公式，然后给 Gait 组件消融，最后给 Widar/Gait 的信号诊断。共享斜率用来定位机制，而不是包装成新算法主贡献。

**复用来源。** 原 IV-D3、Figures 9-10、原式 (19)。95.83、95.87、70.68、67.32、93.59 及相位统计均保留。区分 shared correction across subcarriers 与 SDP 论文讨论的 across antennas；两者的索引和保留关系不同，不能简单说成同一个实验。

**图表。** Figure 7 合并性能消融和相位结构诊断。解释对象明确为本实现中的 Robust 分支，不写所有 robust calibration 都无效。

### C12. Discussion / Recommendations and community value

**怎么写。** 仿 SenseFi 先把经验总结成有条件的短建议，再说明社区可怎样使用模块和匹配比较。每条建议包含适用数据、候选方法、证据及检查条件。价值在于能验证既有方法、保留失败结果、解释何时失效，以及方便增加新模块。

**复用来源。** 原 IV-C2 后半的选型段、原 V 的主要结论。将强泛化改成在 evaluated settings 中推荐。Savgol、Linear/STC、Widar z-score、ElderAL min-max、线性频率插值与 Decimation 都能利用原结果表达。

**图表。** Table 4 是本稿建议新增的总结表，但只整理现有证据，无需新实验。不要把“更简单”直接写成“已测更快”；尚无统一 latency 测量。

### C13. Discussion / Limitations, future work, conclusion

**怎么写。** 局限明确单 seed、Stage I 不完整、Stage II 单代表模型、参数与顺序范围、归一化分支差异，以及诊断条件与主网格区别。未来工作围绕这些局限：数据条件驱动参数、关键比较多 seed、多模型 probe、统一开销测量和更多模块。结语用一段总结基准，一段总结信息保留的实践意义。

**复用来源。** 原 V 的结论和未来工作。保留“根据数据条件选择”的方向，但不写已实现自动或自适应选择器。没有新增在线感知、域迁移或住宅部署实验。

### C14. Experimental procedures

**怎么写。** 按 SenseFi 的文末实验细节顺序安排资源可用性、数据与任务、划分训练、preset 参数、真实执行分支、幅相输入、匹配效应与诊断、实现扩展。这里允许保留较多原技术细节，但所有细节都要解释它如何保障组件比较的公平性。

**复用来源。** 原 III 的接口与公式，原 IV-A、IV-B，原 Table III、Table II 的参数部分。SDP 的来源归属放在实现小节一句说明，避免让整篇文章一直以基于 SDP 来介绍自己。

**图表。** Table 5 复用数据设置，Table 6 拆出 preset 和参数，Table 7 汇总诊断定义。归一化的统计 scope、实际模块次序和插值轴必须可核对，不能仅靠统一接口推断。

### C15. Declarations and references

**怎么写。** 保留作者匿名状态；资金、CRediT、利益冲突、伦理和公开代码位置等没有提供的信息明确留待填写。SenseFi 的作者、资助、数据发布和人类受试者声明不能移植到本稿。

**复用来源。** 原 22 条参考文献保留编号，便于最小迁移。SDP 作者表补上所给 PDF 中的 Christos Masouros；AdamW 使用真实 ICLR/arXiv 来源。不编造作者、基金号、伦理号或已经完成的开源发布。

## D. 与 SDP 的贡献区分：写法上的实际落点

**研究对象不同。** SDP 所给版本集中讨论协议定义、元数据驱动频率投影、Canonical CSI Tensor、合规与表示取舍。本稿研究每个预处理角色中的多个候选方法，以及它们在相同模型条件下的效果、相互衔接和失效条件。两篇可共享读数器或训练工具，但共享工具不等于共享核心研究问题。

**证据链不同。** 本稿的主证据是六 preset 与模型的依赖、完整组件网格的匹配比较，以及 Hampel/Band-pass/phase 三个机制案例。本文不搬用 SDP 的 K=30 最优取舍、PCA/Uniform 投影比较、跨 seed CKA/MMD 或住宅流推理作为自己的结果。

**贡献措辞不同。** 将 “a unified protocol for reproducible sensing” 作为全文中心，容易与 SDP 重叠。可改成 “a systematic benchmark of representative preprocessing methods and their compositions”。将 “standardized physical-layer sanitization” 改成 “replaceable preprocessing alternatives with explicit input requirements”。将 “the proposed protocol improves stability” 改成 “the benchmark reveals when component substitutions help or damage recognition”。

**新颖性来自系统比较与解释。** 不是新的去噪或校准算法，也不是把固定清洗流程重新命名。五类模块的算法集合、组合空间、两阶段机制、失败诊断、条件指南共同形成贡献。代码接口只是让这套研究可执行、可扩展的实现手段。

## E. “最大、最丰富、系统覆盖”应怎样写

当前证据支持写出明确覆盖：四数据集、五模块、十七个角色内方法选项、十九注册模型、六 preset、456 个 Stage I 设计条件和 800 个 Stage II 条件。这比反复说 comprehensive 更有说服力。英文推荐句是：

:::quote
The benchmark systematically covers representative preprocessing methods across five modules and evaluates their compositions through model-preset screening and controlled component comparisons.
:::

更强调规模时，可以接：

:::quote
Its evaluated scope includes four heterogeneous datasets, nineteen registered models, six preset bundles, and an 800-condition fine-grained preprocessing space.
:::

不建议当前直接写 the largest / the most comprehensive / the first。有限检索及这三篇论文不能证明全领域排名；数据集规模大、模型数多和预处理方法覆盖广也是不同维度。网上检索还发现 CSI-Bench 等较新的基准，说明比较范围不能只停在 SenseFi。可在投稿前补一张限定“预处理算法替换与组合评测”维度的文献覆盖表，再决定是否有证据使用 one of the most extensive。在当前完整稿中使用 broad/systematic coverage 和具体数字已能突出你的工作，没有削弱系统性。

## F. 最小修改之外必须保留的校正与证据边界

**第一阶段覆盖。** 当前长表含 456 条记录，其中 358 条 ok、33 条 failed、65 条 skipped。模型集合是 19，但三个数据集各只有 84/114 成功条件，ElderAL 为 106/114。图注和规模描述已按此处理。

**Gait 完整结果。** 当前 gait_320_pipeline_optimized_mlpmodel_summary.csv 有 289 条，gpu1_290_320 的补表有 31 条；combo_id 合并后为互不重复的 320 条 ok。旧图包清单仍写 253/320，旧 Robust 主结果表写 317/320，均不是当前完整覆盖。Gait 相位均值因此小幅更新，其他主要数字尽量沿用原文。绘图时必须从当前两表重建，不要直接沿用旧派生文件。

**插值轴。** 代码 interpolation.py 在 axis=1 子载波维处理，Stage II target_K 是 Widar/Gait/XRF55 的 15 和 ElderAL 的 64。原文把部分结果解释成连续时间插值或时间降采样，已修正为频率表征比较。这是必要的语义修正，不是增加实验。

**模块顺序。** 普通分支为 D→O→C→N→I；复数 z-score 分支为 D→O→C→I→z-score，并直接输出幅度和相位的实数通道。两种分支是确定的实现规则，但不能仍宣称所有配置严格使用完全相同的实际顺序。跨归一化比较反映该实现分支整体效果。

**统计与解释。** 主网格单 seed；不写多 seed 显著性，不用配置间区间代表训练不确定性。小差距保留数值但降低推荐强度。Gait 的相位消融值与主网格 Robust 均值来自不同控制条件，不能混成一个实验。Band-pass 参数修正与保留符号的对比也分开写。

**原稿文件完整性。** 原 PDF 由三种页树计数均识别为 14 页，并且已逐页提取与渲染检查；读取预检发现一个 xref 覆盖警告，因此其自动页锚状态为 UNAVAILABLE，不能冒充 PASS。复用地图采用原章节与图号定位，避免将未通过预检的页锚当作严格来源凭证。SenseFi 与 SDP 的读取预检为 PASS。

## G. 图表占位总清单

GA：异构输入—五类方法库—两阶段评测—机制解释—选择指南，重画总览。

Figure 1：复用原 Figure 1 的预处理与模型共同决定结果的动机图。

Figure 2：复用并调整原 Figure 2 和 Table II，突出方法库与两阶段。

Figure 3：复用原 Figure 3 的四数据集模型×preset 热图，补失败/跳过编码。

Figure 4：复用组合图或已有图脚本，展示四数据集配置全景与匹配组件效应；Gait 更新至完整 320 条。

Figure 5：合并原 Figures 5-7，解释 Hampel 的替换、信号损失、物理窗跨度及消融。

Figure 6：复用原 Figure 8，解释带通参数、符号和未执行比例。

Figure 7：合并原 Figures 9-10，展示相位组件消融与子载波关系损伤。

Table 1：原 Table I 的研究对象/方法覆盖比较，避免三维完全析因的错误表述。

Table 2：五类模块方法、参数、输入条件、输出和处理轴；主要来自原 III-B。

Table 3：两阶段的设计与运行覆盖，拆分原 Table II。

Table 4：现有结果整理成条件选择指南，无需新增实验。

Table 5：原 Table III 数据集、任务、分组、训练设置，并补版本与子集说明。

Table 6：原 Table II 的六 preset 和具体参数；区分主网格与机制消融参数。

Table 7：现有机制统计指标的严格定义与样本来源；需要从对应脚本补齐细节。

## H. 投稿前的信息补全顺序

先完成图表替换和结果来源统一，核对每幅图的配置与样本集。随后补确切数据版本、各划分样本数、归一化 scope、checkpoint 选择规则、诊断指标定义和异常条件。作者及公开资源信息按真实情况填写。若希望加强近似排名或泛化结论，再针对关键组件补多 seed 或另一代表模型；这些是可选的证据扩展，不是当前改写稿已经完成的工作。

当前英文正文已经完整写出各部分，包括结果解释、讨论和实验方法。图表框中的文字是明确的制作说明，作者声明里的待填项来自原稿未提供的信息。后续把真实图表和元数据放入相应位置，即可继续做目标期刊/会议格式压缩。

## I. 三篇材料的阅读与外部来源记录

主要内容来源为用户给出的 conference_101719.pdf。结构参考为 SenseFi（Patterns 4, 100703, DOI: 10.1016/j.patter.2023.100703）。研究区分依据是用户给出的 SDP 已接收作者稿（DOI: 10.1109/TMC.2026.3723025）；没有用其早期 arXiv 摘要中的强稳定性表述替代所给版本。

参考文献尽量保留原 22 条。公开标题/DOI 检索用于核对文献身份，不等于重新全文审查全部被引论文。没有依据有限检索宣布“全领域第一或最大”。结构与覆盖核对可参看 SenseFi 作者机构记录：https://www.research.ed.ac.uk/en/publications/sensefi-a-library-and-benchmark-on-deep-learning-empowered-wifi-h/ 。新增基准检查例为 CSI-Bench：https://arxiv.org/abs/2505.21866 及其 NeurIPS 2025 论文，本文正文没有把该文实验作为自己的证据。

局部数值复核使用工作区中的 Stage I 456 条状态长表，以及 Widar 320、Gait 289+31、XRF55 80、ElderAL 80 的原始结果汇总。该复核仅重新汇总既有实验，没有改动原始数据、训练代码或原论文文件。
