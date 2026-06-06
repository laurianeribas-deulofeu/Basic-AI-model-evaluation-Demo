
<body>

<h1>Evaluating AI Model Performance in Marine Biodiversity Monitoring</h1>
<p class="subtitle">A practical demo in R — <em>AI Applications in Marine Science</em></p>
<p class="author">L. Ribas-Deulofeu — Nord University, Norway</p>

<span class="badge">R</span>
<span class="badge green">Teaching</span>
<span class="badge gray">CC BY 4.0</span>

<hr>

<h2>Overview</h2>
<p>This repository contains teaching materials for a hands-on demonstration on how to evaluate the performance of an AI-assisted image classification model applied to coral reef biodiversity monitoring.</p>
<p>The demo uses a real CoralNet source as a case study — a widely used platform for automated annotation of benthic survey images. Students will learn to load a confusion matrix, compute standard performance metrics, and produce publication-quality visualisations in R.</p>

<blockquote>This is not about building a model. It is about critically evaluating one — a core skill for responsible use of AI in marine science.</blockquote>

<hr>

<h2>The Data</h2>

<h3>CoralNet source</h3>
<table>
  <tr><th>Parameter</th><th>Value</th></tr>
  <tr><td>Platform</td><td><a href="https://coralnet.ucsd.edu">CoralNet</a></td></tr>
  <tr><td>Confirmed photos</td><td>5,597</td></tr>
  <tr><td>Annotation points per image</td><td>25 (expert-annotated)</td></tr>
  <tr><td>Total annotations</td><td>~139,925</td></tr>
  <tr><td>Original number of classes</td><td>333</td></tr>
  <tr><td>Classes in this demo</td><td>51 (subset for demonstration)</td></tr>
  <tr><td>Annotation in this demo</td><td>16,133 (subset)</td></tr>
</table>

<p>The confusion matrix used here is a <strong>51-class subset</strong> of the full 333-class source, selected to keep the demo tractable while covering a representative range of benthic categories — hard corals, soft corals, algae, substrate types, and other life forms.</p>

<h3>Files in this repository</h3>
<div class="file-tree">
├── README.md<br>
├── Model_Evaluation.Rmd &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; # R Markdown — main analysis script<br>
├── Model_Evaluation.html &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; # HTML — main analysis script<br>
├── Model_Evaluation.R &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; # R — main analysis script<br>
├── confusion_matrix_full_0.csv &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; # 51 × 51 confusion matrix (rows = true, cols = predicted)<br>
└── confusion_matrix_classsize.csv &nbsp; # Training set composition (class name + n annotations)
</div>

<hr>

<h2>What this demo covers</h2>
<p>Running the R Markdown will produce a self-contained HTML report including:</p>
<ul>
  <li><strong>Training set composition</strong> — number of annotations per class, class balance barplot</li>
  <li><strong>Confusion matrix heatmap</strong> — row-normalised, showing recall per class</li>
  <li><strong>Overall accuracy</strong></li>
  <li><strong>Per-class metrics</strong> — Precision, Recall, F1 score, Class accuracy</li>
  <li><strong>F1 ranked barplot</strong> — colour-coded by performance tier (good / moderate / poor)</li>
  <li><strong>Precision vs. Recall scatter</strong> — point size scaled to training set size</li>
</ul>

<hr>

<h2>Getting started</h2>

<h3>1. Clone or download this repository</h3>
<pre><code>git clone https://github.com/your-username/your-repo-name.git</code></pre>
<p>Or click <strong>Code → Download ZIP</strong> and unzip locally.</p>

<h3>2. Install R and RStudio</h3>
<ul>
  <li><a href="https://cran.r-project.org">Download R</a></li>
  <li><a href="https://posit.co/download/rstudio-desktop/">Download RStudio</a> (recommended)</li>
</ul>

<h3>3. Install required R packages</h3>
<p>Run this once in your R console before knitting:</p>
<pre><code>install.packages(c(
  "tidyverse", "readxl", "pheatmap",
  "knitr", "kableExtra", "scales",
  "RColorBrewer", "ggrepel", "rmarkdown"
))</code></pre>

<h3>4. Knit the R Markdown</h3>
<p>Open <code>Model_Evaluation.Rmd</code> in RStudio and click <strong>Knit</strong>, or run:</p>
<pre><code>rmarkdown::render("Model_Evaluation.Rmd", output_format = "html_document")</code></pre>
<p>This will generate <code>Model_Evaluation.html</code> in the same folder — open it in any browser.</p>

<hr>

<h2>Understanding the input files</h2>

<h3>confusion_matrix_full_0.csv</h3>
<p>A square matrix where:</p>
<ul>
  <li><strong>Rows</strong> = true (validated) class</li>
  <li><strong>Columns</strong> = predicted class</li>
  <li><strong>Diagonal</strong> = correct predictions (true positives)</li>
  <li><strong>Off-diagonal</strong> = errors (misclassifications)</li>
</ul>
<p>The first column contains class names. All other columns are integer counts.</p>

<h3>confusion_matrix_classsize.csv</h3>
<p>A two-column table:</p>
<table>
  <tr><th>Class</th><th>n_annotations</th></tr>
  <tr><td>Acropora_tabular</td><td>1842</td></tr>
  <tr><td>Porites_encrusting</td><td>976</td></tr>
  <tr><td>…</td><td>…</td></tr>
</table>
<p>This file records how many annotated images were used to train the model for each class — essential for interpreting model performance in the context of class imbalance.</p>

<hr>

<h2>Key concepts covered</h2>
<table>
  <tr><th>Concept</th><th>What it means in practice</th></tr>
  <tr><td><strong>Overall accuracy</strong></td><td>Proportion of all predictions that were correct — useful but misleading with imbalanced classes</td></tr>
  <tr><td><strong>Precision</strong></td><td>Of all times the model predicted a class, how often was it right</td></tr>
  <tr><td><strong>Recall</strong></td><td>Of all true instances of a class, how many did the model find</td></tr>
  <tr><td><strong>F1 score</strong></td><td>Harmonic mean of precision and recall — best single metric for imbalanced datasets</td></tr>
  <tr><td><strong>Class imbalance</strong></td><td>Rare classes with few training annotations tend to show poor recall — even when overall accuracy is high</td></tr>
  <tr><td><strong>Confusion matrix</strong></td><td>Reveals which classes are confused with which — makes silent failure visible</td></tr>
</table>

<hr>

<h2>Learning objectives</h2>
<p>By completing this demo, students will be able to:</p>
<ol>
  <li>Load and visualise a confusion matrix in R</li>
  <li>Calculate and interpret precision, recall, and F1 score per class</li>
  <li>Identify class imbalance and its consequences for model reliability</li>
  <li>Critically evaluate AI-assisted classification outputs</li>
  <li>Produce a reproducible performance evaluation report using R Markdown</li>
</ol>

<hr>

<h2>Citation</h2>
<p>If you use these materials in your teaching or research, please cite:</p>
<pre><code>Ribas-Deulofeu, L. (2026). Evaluating AI Model Performance in Marine Biodiversity Monitoring
— A practical demo in R. Teaching materials, Nord University, Norway.
GitHub: [https://github.com/your-username/your-repo-name](https://github.com/laurianeribas-deulofeu/Basic-AI-model-evaluation-Demo)</code></pre>

<hr>

<h2>License</h2>
<p>These materials are shared for educational use under <a href="https://creativecommons.org/licenses/by/4.0/">CC BY 4.0</a> — you are free to use, adapt, and redistribute with attribution.</p>


</body>
</html>
