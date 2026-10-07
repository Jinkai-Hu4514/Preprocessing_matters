# Pluggable preprocessing pipelines for heterogeneous WiFi CSI sensing: A comprehensive benchmark and analysis

Anonymous Author(s)

Anonymous Institution

Correspondence: [TBD]

## INTRODUCTION

WiFi access points provide more than communication connectivity. Changes in wireless propagation can reveal human activities, gestures, and identities without requiring wearable devices. Existing infrastructure therefore offers a practical source of sensing measurements for smart environments and human-computer interaction [3-6]. This development is also related to the wider interest in integrated sensing and communications [1,2]. In CSI-based sensing, human motion changes reflection, scattering, and diffraction paths, producing variations in channel amplitude and phase that learning models use for recognition [4,5,7,8].

Learning-based sensing has led to extensive study of model architectures, domain adaptation, and self-supervised learning [19,20]. SenseFi, for example, benchmarks deep models and learning schemes across representative WiFi sensing datasets [9]. These comparisons help researchers choose a feature extractor for a given input representation. The representation itself, however, is usually determined by a preprocessing pipeline before model training.

That pipeline is an important part of the sensing experiment. Raw or dataset-provided CSI can contain random noise, impulsive disturbances, synchronization errors, phase distortions, and differences in numerical scale. Denoising, outlier handling, phase calibration, normalization, and interpolation are widely used to address these effects. Each operation also changes the information available to the learning model. A filter can remove valid motion peaks together with noise; phase correction can alter relationships between subcarriers; and a numerical transformation can discard signed fluctuations. A pipeline that improves one sensing system is therefore not necessarily appropriate for another.

Most task-specific systems evaluate one fixed processing sequence. Changing a model under that sequence does not establish which preprocessing method is suitable, and comparing unrelated systems does not isolate the effect of an operator. A preprocessing benchmark needs to keep candidate choices open, identify the signal information required by each method, and control the downstream comparison. It should also explain pronounced failures from signal changes rather than report accuracy alone.

Three questions guide this study. How should representative preprocessing methods be organized and combined for systematic testing? How do their effects change across heterogeneous CSI datasets and learning models? When a component causes a large improvement or degradation, what signal changes explain the result and what conditions should guide its selection?

To address these questions, we develop the pluggable benchmark illustrated in Figure 1. Five modules expose alternative existing methods under defined execution rules. Stage I compares six representative presets across nineteen registered models on Widar, Gait, XRF55, and ElderAL. Stage II fixes a representative model for each dataset and enumerates the applicable component combinations. We then investigate three pronounced failure cases through matched comparisons, waveform statistics, and component ablations. The contribution is the systematic testing and analysis of preprocessing alternatives and their compositions.

The contributions of this study are summarized as follows.

- **A composable preprocessing benchmark.** Five operational roles cover seventeen method choices, with applicability determined by the retained CSI information. Existing algorithms can be substituted within a module while the surrounding comparison is controlled.
- **A two-stage test mechanism.** Broad model-preset screening is connected to an 800-condition fine-grained space. The design separates model-dependent behavior from component comparisons, and reports execution status alongside accuracy.
- **Mechanistic analysis of preprocessing failures.** Signal measurements and targeted ablations explain physical window mismatch, filter parameterization and sign handling, and relative phase distortion.
- **Data-aware preprocessing guidance.** The findings identify useful starting candidates and conditions that require closer inspection, providing a reusable evaluation setting for further methods and datasets.

:::figure 1 | Overview of the preprocessing benchmark. | 116
Reuse and redesign original Figure 2. Show the four datasets with signal-property tags, the five replaceable modules and candidate methods, Stage I model-preset screening, Stage II component combinations, and signal-level diagnosis. Show inherited readers and training utilities in a supporting box. The central visual should be method choice and composition. Include 456 designed / 358 successful Stage I conditions and 800 completed Stage II conditions.
:::

## CONCEPT OF PREPROCESSING IN WIFI CSI SENSING



### WiFi-sensing data: CSI

In an OFDM WiFi system, CSI describes the channel response of each subcarrier between a transmitter and receiver antenna pair. Commodity CSI tools expose these measurements for channel analysis and sensing [7,8]. For time index t, subcarrier k, and antenna link a, the complex observation is

:::equation
H(t,k,a) = A(t,k,a) exp(j phi(t,k,a)).                         (1)
:::

Here, A and phi denote amplitude and phase. Human motion perturbs the multipath channel and produces temporal changes in both quantities. Measured CSI also reflects hardware, synchronization, acquisition settings, and noise. Preprocessing aims to reduce unwanted variation while preserving motion-related structure.

This objective is more demanding than producing a smooth signal. Rapid transitions may be discriminative, relative phase may encode propagation changes, and signed real-valued features may carry statistical or temporal information. Method applicability and information preservation should therefore be examined before comparing recognition accuracy.

### Heterogeneous CSI data and representations

The inputs used for Widar and Gait retain complex CSI and allow both amplitude and phase to be examined. XRF55 and ElderAL are represented here by real-valued, amplitude-oriented inputs, so their fine-grained spaces omit phase calibration. This distinction describes the adopted input versions, rather than every possible release of these datasets. A common array shape alone does not imply identical physical information.

Temporal structure also differs. XRF55 contains regularly sampled sequences at 200 Hz, whereas the retained ElderAL frames are sparse and irregularly spaced. A fixed-frame neighborhood can represent a short, consistent interval in one dataset but a substantial and variable part of an activity in another. Frequency filters likewise require a correctly specified sampling rate. Table 1 summarizes these properties and their implications.

:::table 1

### CSI data transformation and preprocessing

Figure 2 illustrates the input dimensions and applicable operations. The benchmark organizes preprocessing into denoising, outlier handling, phase calibration, normalization, and subcarrier interpolation or reduction. The ordinary execution order follows these five roles. Algorithm choices are enumerated within the roles; arbitrary stage permutations are not evaluated. A documented complex-CSI branch postpones z-score amplitude normalization until after interpolation so that signed amplitude and calibrated phase can be emitted directly as separate channels. The actual execution branch is part of the configuration.

Existing sensing systems combine wavelet denoising, Butterworth filtering, Savitzky-Golay smoothing, PCA, and Hampel correction with learning models [11-14]. These methods rely on different assumptions about frequency structure, local trends, and abnormal values. Phase-processing studies similarly show that correction must account for the retained measurements and hardware-related errors [15,16]. Widar3.0 exploits receiving-antenna relationships to suppress common phase offsets [17]. Numerical scaling, as used in DeepFi [18], serves another role by controlling the model input scale.

The five evaluated families are described below. Table 2 gives their candidates and input requirements.

**Denoising and outlier handling.** The denoising module includes Wavelet, Butterworth, Savitzky-Golay, Band-pass, and Hampel. The methods span transform-based denoising, frequency filtering, local polynomial smoothing, and neighborhood-based replacement. Hampel is grouped under denoising in this implementation because it acts as a temporal correction stage. The separate outlier module compares IQR-based and z-score-based handling. Thus, the module taxonomy reflects the execution roles in this benchmark rather than mutually exclusive mathematical categories.

Both modules aim to suppress unwanted variation, but stronger suppression is not necessarily better for recognition. Human motion is nonstationary: rapid gestures, posture transitions, and short activity components may appear as peaks or abrupt changes. A filter or threshold that treats these changes as noise can remove class-discriminative information. The benchmark compares methods across identical downstream configurations and then inspects the signal changes associated with large accuracy differences.

**Phase calibration.** The phase module compares Linear, Polynomial, STC, and the implementation labeled Robust. These alternatives are evaluated only for Widar and Gait. Linear and polynomial methods estimate phase trends across subcarriers, while the Robust implementation also removes estimated temporal trends independently for individual subcarriers. This distinction is important because a correction applied equally to multiple subcarriers preserves their relative phase, whereas independent corrections can alter those relationships.

Method names are configuration labels rather than guarantees. In particular, a method labeled Robust is not assumed to preserve task-relevant phase structure. Its effectiveness is examined through recognition results and component-level diagnostics. For real-valued amplitude-only inputs, the phase module is explicitly inactive.

**Normalization and subcarrier interpolation.** The normalization module compares z-score standardization with min-max scaling. The former centers and scales an input relative to its mean and standard deviation; the latter maps it to a specified numerical range. Their effects depend on whether discriminative information is carried by relative fluctuations, numerical range, or differences in scale. The benchmark also separates z-score outlier handling from z-score normalization, because the two operations serve different purposes.

The interpolation or reduction module includes Linear, Cubic, Nearest, and anti-aliased Decimation. In the evaluated implementation these methods operate along the **subcarrier axis**. They compare alternative ways of constructing a fixed-size frequency representation, not alternative temporal interpolation schemes. Stage II uses a target of 15 subcarriers for Widar, Gait, and XRF55, and 64 for ElderAL. These targets are fixed within each dataset's fine-grained comparison. A complex interpolant or a larger processing cost does not by itself establish an advantage for sensing.

Seventeen counts candidate choices across operational roles, rather than seventeen newly proposed or necessarily distinct algorithms. PCA, BVP construction, antenna-ratio features, and learned restoration remain possible extensions; they are not counted as completed coverage of the evaluated grid.

:::table 2

:::figure 2 | CSI representation and preprocessing concept. | 110
Reuse the signal-transformation elements of original Figure 1. Show a time × subcarrier × antenna/link observation, with amplitude-plus-phase and amplitude-only branches. Illustrate which dimension and signal property each module changes. Mark interpolation along the subcarrier axis, distinguish temporal sequence-length handling, and show that signed normalized amplitude remains a real feature channel.
:::

### Insight: preprocessing changes what the model sees

The benchmark treats the preprocessing pipeline as a composition of modules. Given dataset D_d, pipeline P_p, and model M_m, a sample X_d is transformed into X_d,p = P_p(X_d), after which the model produces its prediction. The measured outcome therefore depends jointly on the dataset, pipeline, and learning model:

:::equation
E(d,p,m) = Evaluate(M_m(P_p(X_d)); split_d, training_d).      (2)
:::

This formulation makes the object of comparison explicit. Changing a pipeline changes the model input, while changing the model changes how that input is used. To examine preprocessing effects, the benchmark records the method chosen at each module, its parameters, the actual execution branch, and the resulting input representation. Split and training settings remain fixed within the relevant comparison.



This view has three consequences. An operator can fail when the sampling pattern or representation changes. The same processed representation can also suit different models unequally. Finally, accuracy alone cannot identify whether degradation originates from an operator, its interaction with another stage, or a violation of its assumptions. These observations motivate broad screening followed by controlled component tests.

## RESULTS



### A comprehensive preprocessing benchmark for WiFi sensing

Table 3 summarizes the evaluation design and execution coverage. Stage I combines six predefined pipelines with nineteen registered models on each of the four datasets. The presets are High Quality, Fast, Robust, Gesture Recognition, Activity Detection, and Localization. Their names indicate configuration bundles inherited from the implementation; they do not establish that a preset is best for the task named in its label. All six are evaluated across the dataset-specific tasks.

The nominal matrix contains 4 x 6 x 19 = 456 conditions. The result manifests contain 358 successful evaluations, 33 failed conditions, and 65 skipped conditions. Widar, Gait, and XRF55 each have 84 successful conditions out of 114; ElderAL has 106 out of 114. Accuracy comparisons use successful runs, while failed and skipped conditions retain distinct status labels. They are not assigned an accuracy of zero.

The registered model set spans feedforward, convolutional, recurrent, attention-based, state-space, graph-based, and other CSI-sensing architectures. The role of this broad screen is to reveal whether preset changes have similar effects across models and to identify a practical model for the detailed combination study. It does not imply that every architecture completed every preset condition.

Stage II fixes MLPModel for Widar and Gait, ResNet1D for XRF55, and CSITime for ElderAL. These models serve as representative probes for controlled component evaluation. The datasets need not share one architecture, because their input lengths, tasks, and signal characteristics differ. Within each dataset, however, the model and training setup remain unchanged across the fine-grained grid.

Let D, O, C_d, N, and I denote the denoising, outlier, phase, normalization, and interpolation/reduction choice sets. The dataset-specific space is

:::equation
P_d = D x O x C_d x N x I.                                  (3)
:::

For complex CSI, there are 5 x 2 x 4 x 2 x 4 = 320 configurations per dataset. For amplitude-only CSI, C_d contains only the inactive phase option, yielding 5 x 2 x 1 x 2 x 4 = 80 configurations. The complete Stage II space contains 800 dataset-pipeline conditions, all of which have successful results in the current summaries.

The two stages therefore serve different purposes. Stage I evaluates model-pipeline dependence with a limited set of representative bundles. Stage II evaluates the defined component grid using one model per dataset. The study does not evaluate all 800 conditions under all nineteen models and does not search arbitrary module-order permutations or every algorithm parameter.

:::table 3

### Benchmarking preprocessing presets and models

Figure 3 summarizes the first-stage test accuracies. Both preprocessing choice and model architecture affect recognition, and their effects are not independent. On the same dataset, models differ under an identical preset. When a model is fixed, changing the preset can also produce a large accuracy change. More importantly, the direction of that change can differ across models.

This behavior is particularly clear on ElderAL. CNN1D reaches 51.11% under High Quality and 83.33% under Gesture Recognition, a gain of 32.22 percentage points. ResNet2D similarly increases from 47.04% to 80.74%. AttentionGRU exhibits the opposite response: its accuracy decreases from 79.63% to 49.26%, a loss of 30.37 percentage points under the same preset change. Thus, a pipeline that benefits one architecture can harm another. The input representation produced by preprocessing must be considered together with the model that extracts its features.

Sensitivity also varies across models. CSITime reaches 91.48% under High Quality on ElderAL and remains relatively competitive under several other presets. Some other architectures show wider fluctuations. This variation describes sensitivity to the evaluated preset choices; it is not a measure of stability across independent training seeds.

No preset is consistently best across all successful model-dataset conditions. Reporting only the highest accuracy under one pipeline would conceal these dependencies. The first-stage screen therefore provides a reason to examine component choices in a controlled setting rather than treating a preset as a universally appropriate front end.

:::figure 3 | Stage I model-preset evaluation. | 112
Reuse original Figure 3 as four dataset panels. Rows are the nineteen registered models and columns are the six presets. Display failed and skipped conditions separately from accuracy, and retain missing cells as missing. Show successful / nominal counts of 84/114 for Widar, Gait, and XRF55 and 106/114 for ElderAL. Interpret the heatmaps as model-pipeline dependence at seed 42.
:::

### Evaluations of preprocessing operators

Figure 4 presents the fine-grained combination space. Stage II holds the model, split, training budget, and seed fixed within each dataset. Marginal means describe the balanced component grid; matched comparisons change one module while retaining the other choices.

**Denoising.** Stage II makes it possible to compare denoising alternatives while retaining identical choices for the other modules. On Widar, Savitzky-Golay obtains the highest mean accuracy, 69.12%, followed by Butterworth at 68.52%. The difference between these two candidates is small compared with the larger degradation associated with some other component choices. On ElderAL, Savitzky-Golay reaches 85.67%, while Hampel reaches 64.19%, a difference of 21.48 percentage points. The large gap persists across the sixteen matched downstream configurations.

XRF55 shows similar mean accuracies for Wavelet, Savitzky-Golay, Butterworth, and Hampel: 83.78%, 83.71%, 83.46%, and 82.72%, respectively. The default Band-pass configuration reaches only 40.09%. This contrast motivates a closer examination of the filter settings rather than a general claim that band-pass filtering is unsuitable for activity recognition.

The observations suggest different priorities. A local smoother that preserves dynamic trends is a reasonable candidate for Widar and ElderAL under the present settings. On XRF55, several alternatives perform similarly, while the default Band-pass implementation requires parameter and representation checks. The preferred method cannot be inferred from the generic name of the denoising algorithm.

**Phase calibration.** On Widar, Linear, STC, and Polynomial yield mean accuracies of 69.97%, 69.59%, and 69.37%. The three choices have similar performance in this grid, making Linear a reasonable simple starting point. Robust reaches 59.48%, which is 10.49 percentage points below Linear. On the complete Gait grid, Linear, Polynomial, STC, and Robust yield 92.82%, 90.70%, 92.89%, and 46.56%, respectively.

The poor Robust results occur across many otherwise identical configurations. They indicate a problem associated with this particular calibration implementation under the evaluated settings. They do not establish that all robust estimation methods are harmful. The component ablations below examine which operation changes the signal structure.

**Normalization.** Widar favors z-score normalization, with a mean accuracy of 69.45% compared with 64.76% for min-max, a difference of 4.69 percentage points. In matched comparisons, z-score performs better in 155 of 160 conditions. ElderAL shows the opposite preference: min-max reaches 81.69%, exceeding z-score at 77.36% by 4.33 percentage points. The mean difference on XRF55 is only about 0.28 percentage points.

These results illustrate that normalization is not merely a numerical convenience. Centering and scaling change the representation of deviations, while range scaling changes how amplitudes are distributed over a shared interval. The observed direction depends on the dataset and normalization scope. Distribution-based explanations provide useful hypotheses, but the benchmark does not independently establish that a particular distribution property is the sole cause of each accuracy difference.

**Outlier handling and subcarrier interpolation.** The difference between IQR and z-score outlier handling is small on Widar and XRF55. Z-score outlier handling improves mean accuracy by about 0.02 and 0.18 percentage points, respectively. On ElderAL, the mean improvement is larger, about 1.94 percentage points. These effects are smaller than the denoising failures examined above. IQR and z-score use different distribution summaries, so either choice should be evaluated when the input distribution or outlier pattern changes.

For subcarrier interpolation or reduction, the maximum difference between method-level means is about 0.47 percentage points on Widar and 0.67 on XRF55. Linear is consequently a reasonable simple reference in these settings. ElderAL is more sensitive: the spread of means is about 2.59 percentage points, and Decimation exceeds Linear by approximately 1.50 percentage points. The result concerns reduction or interpolation of the subcarrier dimension. The comparison therefore concerns frequency representation rather than temporal resampling.

:::figure 4 | Stage II fine-grained preprocessing benchmark. | 116
Reuse original Figure 4 and the combination heatmaps. Present the full 320-condition Widar and Gait grids and 80-condition XRF55 and ElderAL grids, with all module choices visible. Add matched component-difference panels if space permits. Rebuild Gait from its complementary 289- and 31-condition summaries. Configuration variation is not independent-seed uncertainty.
:::

### Mechanism analysis of preprocessing failures

Component rankings identify pronounced degradations but do not explain the information lost. We therefore examine three representative cases through waveform statistics, physical sampling scales, and targeted component controls. The diagnostic experiments have their own stated reference settings and are distinguished from grid-level averages.

#### Time-scale sensitivity of Hampel filtering

Figure 5 connects the ElderAL Hampel degradation with changes to the activity waveform and physical neighborhood span. The ElderAL grid shows a consistent Hampel degradation. Its mean accuracy of 64.19% is below Wavelet, Butterworth, Savitzky-Golay, and Band-pass at 81.64%, 83.94%, 85.67%, and 82.20%. With the remaining modules fixed, Hampel is the lowest-performing denoising method in all sixteen matched conditions. The corresponding gaps are 17.45, 19.75, 21.48, and 18.01 percentage points.

Waveform inspection shows that some peaks, valleys, and rapid transitions are replaced by local medians. Statistics over 162 stratified samples show that the default eleven-frame neighborhood replaces 17.33% of amplitude entries and alters at least one channel in 91.85% of frames. Summed absolute inter-frame variation decreases by 67.63%, dynamic peak intensity decreases by 69.44%, and the average waveform correlation is 0.766. These observations indicate broad changes to the activity waveform rather than correction of only a few isolated impulses.

The retained ElderAL frames are sparse and irregularly spaced. Among 2,015 samples with durations from 3 to 7 s, fewer valid frames are associated with larger inter-frame gaps, with Pearson and Spearman correlations of -0.556 and -0.842. A neighborhood containing a fixed number of frames therefore represents different physical durations in different sequences. When the neighborhood increases from three to eleven frames, its median physical span expands from 0.378 to 2.484 s. The ninetieth percentile of the eleven-frame span reaches 4.634 s, covering a substantial portion of an activity sample.

The window ablation is consistent with this mismatch. Accuracy is 90.74% when Hampel is disabled and 78.15%, 70.37%, 62.96%, and 68.52% for three-, five-, seven-, and eleven-frame neighborhoods. Reducing the eleven-frame window to three frames recovers 9.63 percentage points, but still leaves a 12.59-point gap to the no-Hampel reference. The non-monotonic trend also shows that window length alone does not explain all behavior. The local-outlier assumption itself can be inappropriate when valid activity transitions occupy a large part of the neighborhood.

XRF55 provides a contrasting example. At 200 Hz, a sample contains 1,000 frames with regular spacing. Hampel changes 2.23% of values and retains 93.84% of temporal variation and 98.67% of dynamic peak intensity. Accuracy is 83.18% with Hampel and 84.70% without it in the targeted comparison. The contrast supports a conditional interpretation: fixed-frame correction is much less disruptive when the window remains physically local. These targeted values and the grid-level means correspond to different experimental settings and should not be combined into one performance estimate.

:::figure 5 | Hampel filtering and physical window span. | 115
Combine original Figures 5-7. Include raw and filtered ElderAL waveforms with replacement locations; replacement, temporal-variation and peak statistics; no-filter versus 3/5/7/11-frame accuracy; and physical neighborhood spans versus retained-frame counts. Contrast the dense 200-Hz XRF55 example. Distinguish the 162-sample waveform subset, 2,015-sample timing subset, and targeted classifier ablation.
:::

#### Band-pass parameterization and signed semantics

Figure 6 summarizes the filter-parameter, signed-output, and activation diagnostics. The default Band-pass configuration on XRF55 performs poorly in all sixteen matched downstream conditions. Its mean of 40.09% is below the four alternatives by approximately 42.62-43.68 percentage points. This consistent pattern identifies the band-pass branch as a priority for diagnosis.

The implementation uses a sampling-rate parameter of 1,000 Hz with a designed passband of 0.5-50 Hz. For XRF55 sampled at 200 Hz, those digital filter coefficients correspond to an effective physical passband of approximately 0.1-10 Hz. In a targeted comparison, changing only the sampling-rate parameter from 1,000 to 200 Hz improves accuracy from 38.18% to 61.97%, a gain of 23.79 percentage points. This recovery supports sampling-rate mismatch as an important contributor, although it does not recover all performance lost relative to the other denoising alternatives.

A second issue appears in the composition of filter and outlier handling. Band-pass processing creates signed, zero-centered fluctuations, but a downstream absolute-value operation folds them into one polarity. Across 3,300 XRF55 samples, 49.759% of the filter outputs lie below zero. Retaining the sign improves accuracy from 62.58% to 64.70% in the sign-handling comparison. The values belong to a separate diagnostic condition and are not a continuation of the sampling-rate-only experiment. The pipeline should record both the filtering parameters and the semantics of its output.

ElderAL illustrates why apparently acceptable accuracy may conceal limited operator use. The band-pass implementation requires at least 28 frames. Of 2,404 valid ElderAL segments, 2,010 are returned unchanged because they are too short, a bypass rate of 83.61%. Its grid mean of 82.20% therefore includes many samples on which filtering was not executed. Compatibility and activation coverage are part of the method's behavior; accuracy alone cannot show whether the intended operator acted on the data.

:::figure 6 | Band-pass parameterization, sign retention, and activation. | 110
Reuse original Figure 8. Show the designed and effective physical passbands for 1,000 versus 200 Hz, the sampling-rate-only correction, the separate sign-retention control, and ElderAL filtered versus bypassed segments. Label 49.759% as the fraction of output entries below zero across 3,300 samples, and 2,010/2,404 as the bypassed-segment count.
:::

#### Phase-structure damage in robust calibration

Figure 7 compares calibration components and their effects on phase structure. The Robust implementation first unwraps phase over time, subtracts a common phase component across subcarriers for each antenna, and then estimates and removes a temporal slope independently for every subcarrier. The common correction leaves inter-subcarrier differences unchanged. Independent slopes, however, modify those differences. For subcarriers f and g on the same antenna, the corrected phase difference is

:::equation
Delta phi'_(f,g)(t) = Delta phi_(f,g)(t) - t(beta_f - beta_g). (4)
:::

When the estimated slopes differ, an additional relative rotation accumulates over time. Some estimated temporal trends may reflect human motion or phase-unwrapping behavior rather than removable hardware drift. Subtracting them independently can consequently alter the frequency-dimensional phase structure used for recognition.

The Gait component ablation supports this interpretation. With split, model, seed, and the other processing operations held fixed, accuracy is 95.83% without calibration and 95.87% with Linear. Independent temporal detrending reduces it to 70.68%; full Robust processing yields 67.32%. Replacing independent slopes with one shared slope per receiving antenna raises accuracy to 93.59%, a recovery of 26.27 percentage points relative to full Robust. The shared slope is the median of the estimated slopes across the thirty subcarriers for that antenna. This modification is a diagnostic control used to examine the existing implementation.

Signal measurements provide complementary evidence. Independent detrending increases mean adjacent-subcarrier phase differences from 0.812 to 1.439 rad on Widar and from 0.820 to 1.548 rad on Gait. Full Robust yields similar values, 1.444 and 1.552 rad. Additional relative rotation exceeding 90 degrees occurs in 42.47% and 49.36% of adjacent-subcarrier pairs. With a shared slope, the phase differences return to 0.812 and 0.820 rad and the proportion with rotations above 90 degrees is nearly zero.

These observations identify independent temporal-slope removal as a major source of degradation in the tested Robust branch. They explain why phase correction should be evaluated for preservation of relative structure, not only for removal of an estimated trend. The result is specific to the implementation and conditions examined here; it does not show that every phase-calibration method or robust estimator removes useful information.

:::figure 7 | Phase-calibration components and structure preservation. | 112
Combine original Figures 9 and 10. Panel A shows Gait no-calibration / Linear / independent detrending / full Robust / shared-slope accuracies. Panel B compares adjacent-subcarrier phase differences on Widar and Gait. Panel C shows the fraction with added relative rotation above 90 degrees. The shared slope is computed across subcarriers for each antenna; identify it as a diagnostic control.
:::

### Preprocessing recommendations

The benchmark supports conditional selection rather than one universal pipeline. Numerical applicability is a necessary first check, but it does not establish physical suitability. Temporal operators require a meaningful physical time scale, and phase or amplitude transformations should preserve the dimensions used by the sensing task. The largest observed failures arise when these assumptions are violated. Table 4 summarizes useful candidates and the checks required before reuse.

## DISCUSSION



### Summary of benchmarks and recommendations

The benchmark shows that preprocessing selection is conditional. Model-preset screening reveals different, sometimes opposite, responses to the same pipeline change. Fine-grained comparisons show that module effects are unequal: a poorly matched denoising or phase operation can dominate the performance change, while several outlier and interpolation alternatives differ only slightly. Mechanism analyses then connect large degradations with violations of method assumptions or loss of signal semantics.

The following recommendations summarize the observed settings.

- **Determine the available signal information first.** Use phase-calibration alternatives only when the input retains meaningful complex CSI. For amplitude-only inputs, omit the phase module. Preserve signed normalized amplitudes and signed filter outputs when they carry information used by the model.
- **Match temporal operations to physical time.** For dense, regularly sampled CSI, frequency filters and short neighborhood methods are reasonable candidates after parameter checks. For sparse, irregular sequences, inspect the duration spanned by a frame window and the locations replaced by an outlier filter. The ElderAL results favor Savitzky-Golay over the tested Hampel setting.
- **Treat phase structure as information to preserve.** Linear and STC are reasonable starting candidates for the complex-CSI settings studied here. Independent temporal detrending requires particular care because it can introduce relative phase rotation. A shared-correction control can help diagnose this failure.
- **Evaluate normalization for the dataset and model.** Z-score performs better on Widar, while min-max performs better on ElderAL. Neither preference supports a universal default. State the statistics-estimation scope and retain the sign of standardized real-valued features.
- **Prefer simple references when alternatives are similar.** Linear subcarrier interpolation is a useful reference for Widar and XRF55, where the method-level differences are small. Decimation is a competitive candidate for ElderAL in the evaluated reduction setting. These recommendations concern frequency representation, not temporal resampling.
- **Report when an operation is actually applied.** Record short-sequence bypasses, invalid inputs, failed runs, and skipped conditions. A method's apparent accuracy should be interpreted together with its activation coverage.

:::table 4

### Relationship to existing benchmarks

The benchmark complements work on models and input representation by examining preprocessing alternatives themselves. SenseFi provides a library and systematic evaluation of learning architectures and schemes [9]. Domain-adaptation, self-supervised, and measurement-dependent studies address other sources of recognition behavior [19-21]. Here, the experimental unit is a component substitution or a pipeline composition under a defined downstream setting.

The benchmark offers a reusable way to ask how existing preprocessing choices affect a sensing experiment. Its value comes from the combination of module coverage, method composition, broad model screening, controlled fine-grained comparisons, and signal-level explanation. Researchers can add a method within an existing role, retain the other processing choices, and compare the result against matched configurations. They can also evaluate whether a new dataset changes the applicability or effectiveness of a module.

This role differs from optimizing one pipeline for the highest accuracy on one task. A useful preprocessing benchmark should preserve both favorable and unfavorable results, document configurations that cannot be executed, and explain why a method fails when evidence is available. The present experiments provide examples of all three. They also show why a benchmark should compare alternative algorithms within a role rather than rely only on a fixed combination of default operators.

The evaluated breadth spans five modules, seventeen method choices across roles, four heterogeneous datasets, nineteen registered models, six preset bundles, and an 800-condition fine-grained space. Together, these dimensions support a systematic comparison of representative preprocessing alternatives and their compositions. The benchmark connects algorithm coverage with controlled testing and interpretable analysis, making it useful for evaluating existing methods and incorporating further alternatives.

### Limitations of the study

The main grid uses one training seed, 42. This controls initialization for the large combination study but does not quantify uncertainty across independent training runs. Configuration-level variation describes changes among pipelines, not random-seed stability. Small differences should therefore be treated as descriptive observations. Stronger claims about reproducibility or statistical significance require repeated seeds under matched conditions.

Stage I contains failed and skipped conditions, and Stage II uses one representative model per dataset. Component conclusions are consequently conditional on those probes. The design does not fully separate every dataset-model interaction, and an observed ranking may change under a different architecture. Probe selection considered accuracy and computational practicality, but a complete, uniform measurement of preprocessing latency, model FLOPs, memory, and training cost is not available in the main results. We therefore do not claim a measured Pareto-optimal selection.

The library covers selected representatives and fixed parameter settings. It does not exhaustively tune every algorithm, compare all processing orders, or include all feature-construction methods. The complex-CSI z-score branch has a documented representation-preserving order adjustment, which is fixed within the corresponding comparisons. Normalization scope also differs between dataset branches. These implementation choices are part of the evaluated pipelines and should be recorded when interpreting module effects.

The targeted ablations provide useful explanations within their controlled conditions, but their exact classification values cannot be substituted for grid-level averages. The absence of a phase module for an input is a property of the representation used here. Findings do not establish universal behavior across all hardware, dataset versions, subjects, or acquisition environments.

### Grand challenges and future directions

An important extension is to select preprocessing according to measurable data characteristics. Sampling regularity, physical window duration, sequence length, retained phase information, and signed-output semantics could guide the activation and parameterization of candidate methods. The present study supplies diagnostic examples for such an extension; it does not implement an automatic selector.

Broader evaluation should include additional hardware platforms, more dataset versions, and several controlled model probes for key component comparisons. Repeated-seed experiments are especially valuable for close rankings. A uniform cost measurement should distinguish preprocessing time from training time, caching, and input-size changes. Order-aware comparisons and further feature-construction alternatives can expand the library once the corresponding execution semantics and comparability conditions are defined.

### Concluding remarks

This work presents a pluggable benchmark for systematic evaluation of existing CSI preprocessing methods. Five modules organize the candidate choices, and a two-stage design connects model-preset screening with fine-grained component comparisons on four heterogeneous datasets. The resulting observations show that sensing performance depends on how data properties, preprocessing choices, and learning models fit together.

The main practical finding is that suppressing variation does not necessarily improve sensing. A fixed-frame outlier method can remove valid activity dynamics, a misparameterized filter can operate on the wrong physical frequency range, and independent phase correction can damage relative signal structure. By connecting these failures with controlled comparisons and signal diagnostics, the benchmark provides a basis for more informed preprocessing selection and clearer interpretation of WiFi-sensing experiments.

## EXPERIMENTAL PROCEDURES



### Resource availability

**Lead contact.** [TBD: confirmed corresponding author and email.]

**Materials availability.** This study uses existing CSI recordings and does not introduce new physical materials.

**Data and code availability.** [TBD: dataset access sources and adopted versions; public code URL and revision; split manifests; preprocessing configurations; result tables; and release license.] The experiments use existing Widar, Gait, XRF55, and ElderAL data. The implementation, summary results, and diagnostic artifacts are retained in the study workspace; this draft does not assert a completed public archival release.

### Method details of the preprocessing benchmark

A configuration specifies the method and parameters in every applicable role. Dataset adapters identify the retained signal semantics and activate the corresponding modules. The six preset bundles provide a manageable screen over the registered model library. The fine-grained grid then fixes one probe per dataset and enumerates five denoising, two outlier, four applicable phase, two normalization, and four interpolation choices. Phase is inactive for the adopted amplitude-only inputs.

The ordinary order is denoising, outlier handling, phase calibration, normalization, and interpolation. In the complex-CSI z-score branch, interpolation precedes normalization and direct real-channel emission. This fixed branch preserves signed standardized amplitude without reconstructing it as a complex magnitude. It is recorded as part of the pipeline, rather than treated as an arbitrary order search.

### Datasets

Table 5 summarizes the datasets and fixed settings. Widar is used for gesture recognition, with gesture type as the class label. Gait is used for gait-based identification, with user identity as the target. XRF55 is used for fine-grained activity recognition, with action identity as the target; the experiments use the first three users. ElderAL is used for activity classification, with action identity as the target. Acquisition location is used as a grouping variable for ElderAL, rather than being added to the prediction label.

Widar and Gait retain complex CSI, while the XRF55 and ElderAL inputs used here are real-valued and amplitude-oriented. The dataset-specific sequence lengths are 1,500 for Widar and Gait, 1,000 for XRF55, and 80 for ElderAL. Sequence-length handling is separate from subcarrier interpolation or reduction.

For Widar, the grouping variable combines position, orientation, and receiver identity. For Gait, it combines trajectory identity and receiver identity. ElderAL groups samples by acquisition location. Approximately 70% of groups are assigned to training, and the remaining groups are divided equally between validation and test, producing an approximate 70%/15%/15% ratio. Grouping prevents the chosen acquisition groups from being distributed across subsets; it does not by itself establish subject-independent evaluation.

XRF55 uses a fixed repetition split: repetitions 1-12 for training, 13-16 for validation, and 17-20 for testing. The same first-three-user subset is used across its configurations. All models and pipelines in a dataset share its split. The labels and splitting rules remain dataset-specific because task definitions and collection procedures differ.

:::table 5

### Input representation and safeguards

For calibrated phase phi and normalized amplitude A_tilde, complex-CSI input is delivered as real-valued amplitude and phase channels:

:::equation
X_AP = Concat(A_tilde, phi), with shape T x K x 2A.           (5)
:::

The first A channels contain amplitude features and the remaining A channels contain phase. Negative standardized amplitude retains its statistical meaning. Reconstructing A_tilde exp(j phi) would produce an additional pi phase rotation for a negative value, while an absolute-value transformation would discard its sign. Direct channel construction avoids both effects.

For the real-valued XRF55 branch, splitting precedes estimation of dataset-level statistics. Training mean mu_tr and standard deviation sigma_tr are then shared by all subsets:

:::equation
Z_s = (X_s - mu_tr) / (sigma_tr + epsilon),                  (6)
where s is train, validation, or test.
:::

Validation and test subsets do not estimate their own dataset-level parameters. Other branches use per-sample normalization where configured; they are identified by their actual scope. Signed XRF55 features are retained. Subcarrier interpolation uses frequency coordinates along axis 1 and has a Stage II target of 15 for Widar, Gait, and XRF55 and 64 for ElderAL. Temporal sequence-length handling is a separate operation.

### Model library and representative models

Stage I registers nineteen architectures: MLPModel, CNN1DModel, CNN2DModel, ResNet1D, ResNet2D, EfficientNetCSI, LSTMModel, BiLSTMModel, AttentionGRU, VisionTransformer, MambaCSI, THAT, CSITime, PACS, WiTransformer, GraphNeuralCSI, AllShot, ProtoNet, and FewSense. Registered coverage is distinguished from successful execution. Failed and skipped conditions remain visible in the result manifest.

Stage II uses MLPModel for Widar and Gait, ResNet1D for XRF55, and CSITime for ElderAL. The probes preserve the original study's model choices. Within a dataset, changing a component does not change the model, input-length setting, split, or training budget. Cross-dataset rankings remain conditional on their respective probes.

### Presets and operator parameters

Table 6 lists the preset bundles. The High Quality preset combines Butterworth, STC, and z-score normalization. Fast combines Savitzky-Golay, Linear calibration, and min-max. Robust combines Wavelet, Robust calibration, and z-score. Gesture Recognition combines Butterworth, STC, z-score, and Cubic interpolation. Activity Detection combines Savitzky-Golay, Polynomial calibration, and z-score. Localization combines Wavelet, Robust calibration, z-score, and Cubic interpolation. Phase operators are omitted when the input representation does not support them. Stages absent from a preset are inactive, which differs from the fully populated applicable Stage II grid.

:::table 6

### Implementation details

Classification uses cross-entropy loss and AdamW [22]. The batch size is 32, the initial learning rate is 3 x 10^-4, and weight decay is 1 x 10^-3. When validation loss does not improve for five consecutive epochs, the learning rate is multiplied by 0.1. The training budgets are 80, 60, 50, and 20 epochs for Widar, Gait, XRF55, and ElderAL, respectively. These budgets remain fixed across the preprocessing choices within each dataset. Test accuracy is the main metric reported by the supplied combination summaries.

The main study uses random seed 42. The computing server has two NVIDIA A100 80-GB PCIe GPUs. The software environment uses driver version 560.35.03 and PyTorch 2.6.0+cu124. Driver support for CUDA 12.6 and the PyTorch CUDA 12.4 build are different environment properties and are recorded separately.

The implementation reuses dataset readers, model interfaces, and training utilities from the existing SDP codebase [10]. These utilities are supporting infrastructure. The experimental object in this study is the library of alternative preprocessing operators and their compositions, together with the two-stage comparisons and mechanism analyses described above.

A configuration identifies each active module by method and parameters. Dataset adapters determine the retained signal semantics and applicable modules. The model interface receives the resulting real-valued feature channels. The grid scripts also reuse common preprocessing prefixes to avoid repeated loading and computation; each final configuration still receives its own model-training result. Caching should be recorded when interpreting run duration.

For extension, a new method should implement the appropriate module interface and state its input requirements, output semantics, and configurable parameters. Comparisons can then retain the split, probe model, and other module choices. Reproducibility records should include configuration identity, actual execution branch, split manifest, seed, training settings, software revision, and run status. These reporting fields support reuse but are not all established as a completed public archival release in this study.

### Baselines and criterion

The grid allows matched comparisons that change one module choice while retaining the other configuration choices. For a choice a versus reference b and a set Q of matched downstream configurations, the mean difference is

:::equation
Delta_(a,b) = mean over q in Q of [Acc(a,q) - Acc(b,q)].     (7)
:::

On each amplitude-only grid, two denoising alternatives have sixteen matched conditions. On a complete complex-CSI grid, two phase-calibration alternatives have eighty matched conditions, and two normalization alternatives have 160. Marginal means average over the remaining choices in the balanced grid. These averages describe the evaluated parameter combinations and model probe.

Signal diagnostics examine replacement coverage, summed absolute inter-frame variation, dynamic peaks, waveform correlation, the physical span of temporal windows, filter activation coverage, and adjacent-subcarrier phase relationships. The targeted Hampel, Band-pass, and Robust comparisons hold the settings described in their original analysis fixed. Their reference conditions are identified separately from the grid configurations.

## AUTHOR AND RESEARCH DECLARATIONS

**Author contributions.** [TBD: confirmed author identities and CRediT roles.]

**Funding and acknowledgments.** [TBD: confirmed funding and acknowledgments, or a statement of no external funding.]

**Declaration of interests.** [TBD: authors' confirmed conflict-of-interest statement.]

**Ethics.** The study analyzes existing datasets. [TBD: applicable original consent conditions and any required approval or exemption for reuse.] No new human-subject recruitment is reported.

**Writing assistance.** AI assistance was used for structural and language revision and document preparation. The rewrite adds no newly run sensing experiment. Authors should confirm the wording and disclosure for the selected venue.

## REFERENCES

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
