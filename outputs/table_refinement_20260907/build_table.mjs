import fs from "node:fs/promises";
import { FileBlob, SpreadsheetFile, Workbook } from "@oai/artifact-tool";

const outputDir = "E:/py_code/bupt_hjk/sdp_test/My_sdp_test/outputs/table_refinement_20260907";
const fontFamily = "Arial";

const colors = {
  ink: "#203040",
  muted: "#617184",
  line: "#CBD6E2",
  lineStrong: "#8FA6BE",
  stage1: "#244A73",
  stage1Header: "#4774A3",
  stage1Soft: "#F3F7FB",
  stage1Alt: "#F8FAFD",
  stage2: "#356B70",
  stage2Header: "#568589",
  stage2Soft: "#F1F7F6",
  stage2Alt: "#F8FBFA",
  white: "#FFFFFF",
  result1: "#DCE9F5",
  result2: "#DCEDEB",
};

const workbook = Workbook.create();
const sheet = workbook.worksheets.add("Evaluation Design");
sheet.showGridLines = false;
sheet.tabColor = colors.stage1;

// Page title and stage bands.
sheet.mergeCells("A2:K2");
sheet.getRange("A2").values = [["CSI Preprocessing Evaluation Design"]];
sheet.getRange("A3:K3").format.fill = "#BCCCDD";
sheet.mergeCells("A4:G4");
sheet.mergeCells("H4:K4");
sheet.getRange("A4").values = [["Stage I: Preset–Model Screening"]];
sheet.getRange("H4").values = [["Stage II: Fine-Grained Preprocessing Evaluation"]];

// Column headers.
sheet.getRange("A5:K5").values = [[
  "Preset",
  "Denoising",
  "Phase\nCalibration",
  "Normalization",
  "Interpolation",
  "Models",
  "Evaluation\nScale",
  "Preprocessing\nStage",
  "Candidate Methods",
  "Representative\nModels",
  "Evaluation\nScale",
]];

// Stage I uses two worksheet rows per preset for comfortable spacing.
const stage1 = [
  [6, "High Quality", "Butterworth", "STC", "Z-score", "—"],
  [8, "Fast", "Savitzky–Golay", "Linear", "Min–max", "—"],
  [10, "Robust", "Wavelet", "Robust", "Z-score", "—"],
  [12, "Gesture Recognition", "Butterworth", "STC", "Z-score", "Cubic"],
  [14, "Activity Detection", "Savitzky–Golay", "Polynomial", "Z-score", "—"],
  [16, "Localization", "Wavelet", "Robust", "Z-score", "Cubic"],
];

for (const [row, preset, denoising, phase, normalization, interpolation] of stage1) {
  for (const col of ["A", "B", "C", "D", "E"]) sheet.mergeCells(`${col}${row}:${col}${row + 1}`);
  sheet.getRange(`A${row}:E${row}`).values = [[preset, denoising, phase, normalization, interpolation]];
}

sheet.mergeCells("F6:F17");
sheet.getRange("F6").values = [[
  "All available models (n = 19)\n\n" +
  "MLPModel, CNN1DModel, CNN2DModel\n" +
  "ResNet1D, ResNet2D, EfficientNetCSI\n" +
  "LSTMModel, BiLSTMModel, AttentionGRU\n" +
  "VisionTransformer, MambaCSI, THAT\n" +
  "CSITime, PACS, WiTransformer\n" +
  "GraphNeuralCSI, AllShot, ProtoNet\n" +
  "FewSense"
]];

sheet.mergeCells("G6:G11");
sheet.getRange("G6").values = [["4 datasets\n× 6 presets\n× 19 models"]];
sheet.mergeCells("G12:G17");
sheet.getRange("G12").formulas = [["=4*6*19"]];
sheet.getRange("G12:G17").format.numberFormat = '0" experiments"';

// Stage II uses row spans proportional to the five preprocessing stages.
const stage2 = [
  [6, 7, "Denoising", "Wavelet, Butterworth,\nSavitzky–Golay, Band-pass, Hampel"],
  [8, 9, "Outlier Handling", "IQR, Z-score"],
  [10, 12, "Phase Calibration", "Linear, Polynomial, STC, Robust"],
  [13, 14, "Normalization", "Z-score, Min–max"],
  [15, 17, "Interpolation", "Linear, Cubic, Nearest, Decimation"],
];

for (const [start, end, stage, methods] of stage2) {
  sheet.mergeCells(`H${start}:H${end}`);
  sheet.mergeCells(`I${start}:I${end}`);
  sheet.getRange(`H${start}`).values = [[stage]];
  sheet.getRange(`I${start}`).values = [[methods]];
}

sheet.mergeCells("J6:J17");
sheet.getRange("J6").values = [[
  "Widar = MLPModel\n" +
  "Gait = MLPModel\n" +
  "XRF55 = ResNet1D\n" +
  "ElderAL = CSITime"
]];

sheet.mergeCells("K6:K7");
sheet.getRange("K6").values = [["Complex CSI\nWidar, Gait\n5 × 2 × 4 × 2 × 4"]];
sheet.mergeCells("K8:K9");
sheet.getRange("K8").formulas = [["=5*2*4*2*4"]];
sheet.getRange("K8:K9").format.numberFormat = '0" per dataset"';

sheet.mergeCells("K10:K14");
sheet.getRange("K10").values = [["Real-valued amplitude\nXRF55, ElderAL\nPhase calibration excluded\n5 × 2 × 2 × 4"]];
sheet.mergeCells("K15:K17");
sheet.getRange("K15").formulas = [["=5*2*2*4"]];
sheet.getRange("K15:K17").format.numberFormat = '0" per dataset"';

// Workbook-wide typography and alignment.
sheet.getRange("A2:K17").format.font = { name: fontFamily, size: 10, color: colors.ink };
sheet.getRange("A2:K17").format.verticalAlignment = "center";
sheet.getRange("A2:K17").format.wrapText = true;

sheet.getRange("A2:K2").format.font = { name: fontFamily, size: 16, bold: true, color: colors.stage1 };
sheet.getRange("A2:K2").format.horizontalAlignment = "left";

sheet.getRange("A4:G4").format = {
  fill: colors.stage1,
  font: { name: fontFamily, size: 12, bold: true, color: colors.white },
  horizontalAlignment: "center",
  verticalAlignment: "center",
};
sheet.getRange("H4:K4").format = {
  fill: colors.stage2,
  font: { name: fontFamily, size: 12, bold: true, color: colors.white },
  horizontalAlignment: "center",
  verticalAlignment: "center",
};

sheet.getRange("A5:G5").format = {
  fill: colors.stage1Header,
  font: { name: fontFamily, size: 10, bold: true, color: colors.white },
  horizontalAlignment: "center",
  verticalAlignment: "center",
  wrapText: true,
  borders: {
    insideVertical: { style: "thin", color: "#DDE8F3" },
    bottom: { style: "medium", color: colors.stage1 },
  },
};
sheet.getRange("H5:K5").format = {
  fill: colors.stage2Header,
  font: { name: fontFamily, size: 10, bold: true, color: colors.white },
  horizontalAlignment: "center",
  verticalAlignment: "center",
  wrapText: true,
  borders: {
    insideVertical: { style: "thin", color: "#E3EFEE" },
    bottom: { style: "medium", color: colors.stage2 },
  },
};

sheet.getRange("A6:E17").format.horizontalAlignment = "center";
sheet.getRange("F6:F17").format.horizontalAlignment = "left";
sheet.getRange("F6:F17").format.font = { name: fontFamily, size: 9, color: colors.ink };
sheet.getRange("G6:G17").format.horizontalAlignment = "center";
sheet.getRange("H6:H17").format.horizontalAlignment = "left";
sheet.getRange("H6:H17").format.font = { name: fontFamily, size: 10, bold: true, color: colors.stage2 };
sheet.getRange("I6:I17").format.horizontalAlignment = "left";
sheet.getRange("J6:J17").format.horizontalAlignment = "left";
sheet.getRange("J6:J17").format.font = { name: fontFamily, size: 9, color: colors.ink };
sheet.getRange("K6:K17").format.horizontalAlignment = "center";

for (const [row] of stage1) {
  sheet.getRange(`A${row}:A${row + 1}`).format.font = { name: fontFamily, size: 10, bold: true, color: colors.stage1 };
}

// Subtle section and alternating-row fills.
sheet.getRange("F6:G17").format.fill = colors.stage1Soft;
sheet.getRange("J6:K17").format.fill = colors.stage2Soft;
for (const row of [6, 10, 14]) sheet.getRange(`A${row}:E${row + 1}`).format.fill = colors.stage1Alt;
for (const [start, end] of [[6, 7], [10, 12], [15, 17]]) sheet.getRange(`H${start}:I${end}`).format.fill = colors.stage2Alt;

sheet.getRange("G12:G17").format.fill = colors.result1;
sheet.getRange("G12:G17").format.font = { name: fontFamily, size: 15, bold: true, color: colors.stage1 };
sheet.getRange("K8:K9").format.fill = colors.result2;
sheet.getRange("K8:K9").format.font = { name: fontFamily, size: 13, bold: true, color: colors.stage2 };
sheet.getRange("K15:K17").format.fill = colors.result2;
sheet.getRange("K15:K17").format.font = { name: fontFamily, size: 13, bold: true, color: colors.stage2 };
sheet.getRange("K6:K7").format.font = { name: fontFamily, size: 9, bold: true, color: colors.ink };
sheet.getRange("K10:K14").format.font = { name: fontFamily, size: 9, bold: true, color: colors.ink };

// Light structure: outside frame, column separators, and meaningful row breaks only.
sheet.getRange("A4:K17").format.borders = {
  top: { style: "medium", color: colors.lineStrong },
  bottom: { style: "medium", color: colors.lineStrong },
  left: { style: "medium", color: colors.lineStrong },
  right: { style: "medium", color: colors.lineStrong },
};
sheet.getRange("A6:G17").format.borders = {
  insideVertical: { style: "thin", color: colors.line },
  left: { style: "medium", color: colors.lineStrong },
  right: { style: "medium", color: colors.stage1 },
};
sheet.getRange("H6:K17").format.borders = {
  insideVertical: { style: "thin", color: colors.line },
  left: { style: "medium", color: colors.stage2 },
  right: { style: "medium", color: colors.lineStrong },
};

for (const row of [7, 9, 11, 13, 15, 17]) {
  sheet.getRange(`A${row}:G${row}`).format.borders = { bottom: { style: "thin", color: colors.line } };
}
for (const row of [7, 9, 12, 14, 17]) {
  sheet.getRange(`H${row}:J${row}`).format.borders = { bottom: { style: "thin", color: colors.line } };
}
sheet.getRange("K9").format.borders = { bottom: { style: "thin", color: colors.lineStrong } };
sheet.getRange("G4:G17").format.borders = { right: { style: "medium", color: colors.stage1 } };
sheet.getRange("H4:H17").format.borders = { left: { style: "medium", color: colors.stage2 } };

// Dimensions tuned for a single-screen, landscape table.
const widths = {
  A: 19, B: 18, C: 18, D: 18, E: 17, F: 34, G: 23,
  H: 23, I: 37, J: 27, K: 27,
};
for (const [col, width] of Object.entries(widths)) sheet.getRange(`${col}1:${col}18`).format.columnWidth = width;
sheet.getRange("A1:K1").format.rowHeight = 10;
sheet.getRange("A2:K2").format.rowHeight = 30;
sheet.getRange("A3:K3").format.rowHeight = 2;
sheet.getRange("A4:K4").format.rowHeight = 32;
sheet.getRange("A5:K5").format.rowHeight = 44;
for (let row = 6; row <= 17; row += 1) sheet.getRange(`A${row}:K${row}`).format.rowHeight = 22;
sheet.getRange("A18:K18").format.rowHeight = 8;

// Final calculation, inspection, rendering, and export.
workbook.recalculate();

const check = await workbook.inspect({
  kind: "table",
  range: "'Evaluation Design'!A2:K17",
  include: "values,formulas",
  tableMaxRows: 20,
  tableMaxCols: 12,
  maxChars: 12000,
});
console.log("TABLE_CHECK");
console.log(check.ndjson);

const errors = await workbook.inspect({
  kind: "match",
  searchTerm: "#REF!|#DIV/0!|#VALUE!|#NAME\\?|#N/A|#NUM!|#NULL!|#SPILL!|#CALC!",
  options: { useRegex: true, maxResults: 100 },
  summary: "final formula error scan",
});
console.log("ERROR_SCAN");
console.log(errors.ndjson);

await fs.mkdir(outputDir, { recursive: true });
const xlsx = await SpreadsheetFile.exportXlsx(workbook);
await xlsx.save(`${outputDir}/preprocessing_evaluation_polished.xlsx`);

// Re-open the exported workbook so the delivered XLSX—not only the in-memory model—is verified.
const exportedFile = await FileBlob.load(`${outputDir}/preprocessing_evaluation_polished.xlsx`);
const exportedWorkbook = await SpreadsheetFile.importXlsx(exportedFile);
const exportedCheck = await exportedWorkbook.inspect({
  kind: "table",
  range: "'Evaluation Design'!A2:K17",
  include: "values,formulas",
  tableMaxRows: 20,
  tableMaxCols: 12,
  maxChars: 12000,
});
console.log("EXPORTED_TABLE_CHECK");
console.log(exportedCheck.ndjson);

const preview = await exportedWorkbook.render({
  sheetName: "Evaluation Design",
  range: "A1:K18",
  scale: 1.5,
  format: "png",
});
await fs.writeFile(`${outputDir}/preprocessing_evaluation_preview.png`, new Uint8Array(await preview.arrayBuffer()));

console.log("OUTPUT_XLSX", `${outputDir}/preprocessing_evaluation_polished.xlsx`);
console.log("OUTPUT_PREVIEW", `${outputDir}/preprocessing_evaluation_preview.png`);
