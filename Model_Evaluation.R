#########
#  title: "AI Classifier Performance Evaluation"
#subtitle: "Confusion Matrix Analysis — Marine Biodiversity Monitoring"
#author: "L. Ribas-Deulofeu — Nord University"
#########

# Setup & Data Loading
# Install missing packages automatically
pkgs <- c("tidyverse", "readxl", "pheatmap", "knitr", "kableExtra",
          "scales", "RColorBrewer", "gridExtra", "ggrepel")
install_if_missing <- pkgs[!pkgs %in% installed.packages()[, "Package"]]
if (length(install_if_missing)) install.packages(install_if_missing)

library(tidyverse)
library(readxl)
library(pheatmap)
library(knitr)
library(kableExtra)
library(scales)
library(RColorBrewer)
library(ggrepel)

# ---------------------------------------------------------
# EDIT THESE PATHS to match your file locations
# IMPORTANT: copy paste the path of the input datasets to match their exact location on your machine
# ---------------------------------------------------------
cm_path<- "/Users/laurianeribasdeulofeu/Library/CloudStorage/Dropbox-Personal/05-Classes/METIS 2026/E-class/Active Learning/Model evaluation/confusion_matrix_full_0.csv"
classsize_path<- "/Users/laurianeribasdeulofeu/Library/CloudStorage/Dropbox-Personal/05-Classes/METIS 2026/E-class/Active Learning/Model evaluation/Confusion_matrix_classsize.csv"

# ---------------------------------------------------------

# Load confusion matrix — first column is class names
cm_raw <- read.csv(cm_path)
class_names <- cm_raw[[1]]
cm_mat <- as.matrix(cm_raw[, -1])
rownames(cm_mat) <- class_names
colnames(cm_mat) <- class_names

# Load class sizes — expects columns: Class, n_annotations
cs_raw <- read.csv(classsize_path)
colnames(cs_raw) <- c("Class", "n_annotations")

######

# Training Set Composition
n_classes <- nrow(cs_raw)
n_total   <- sum(cs_raw$n_annotations)

# Summary banner
cat(sprintf("Total classes : %d\n", n_classes))
cat(sprintf("Total annotations : %s\n", format(n_total, big.mark = ",")))
cat(sprintf("Mean per class : %.0f\n", mean(cs_raw$n_annotations)))
cat(sprintf("Min per class  : %d (%s)\n",
    min(cs_raw$n_annotations),
    cs_raw$Class[which.min(cs_raw$n_annotations)]))
cat(sprintf("Max per class  : %d (%s)\n",
    max(cs_raw$n_annotations),
    cs_raw$Class[which.max(cs_raw$n_annotations)]))

cs_raw %>%
  arrange(desc(n_annotations)) %>%
  mutate(
    Proportion = paste0(round(n_annotations / n_total * 100, 1), "%"),
    n_annotations = format(n_annotations, big.mark = ",")
  ) %>%
  rename(`Class` = Class,
         `N annotations` = n_annotations,
         `% of total` = Proportion) %>%
  kbl(caption = "Training set composition per class") %>%
  kable_styling(bootstrap_options = c("striped", "hover", "condensed"),
                full_width = FALSE) %>%
  scroll_box(height = "400px")

cs_raw %>%
  arrange(n_annotations) %>%
  mutate(Class = factor(Class, levels = Class)) %>%
  ggplot(aes(x = Class, y = n_annotations,
             fill = n_annotations)) +
  geom_col(width = 0.75) +
  geom_text(aes(label = format(n_annotations, big.mark = ",")),
            hjust = -0.1, size = 3, color = "grey30") +
  scale_fill_gradient(low = "#B5D4F4", high = "#185FA5",
                      guide = "none") +
  scale_y_continuous(expand = expansion(mult = c(0, .15)),
                     labels = comma) +
  coord_flip() +
  labs(title = "Training set — annotations per class",
       x = NULL, y = "Number of annotations") +
  theme_minimal(base_size = 12) +
  theme(panel.grid.major.y = element_blank(),
        plot.title = element_text(face = "bold", size = 13))

# Confusion Matrix Heatmap
# Row-normalise so each cell = recall proportion for that class
cm_norm <- cm_mat / rowSums(cm_mat)
cm_norm[is.nan(cm_norm)] <- 0

# Color palette: white → navy
pal <- colorRampPalette(c("#FFFFFF", "#B5D4F4", "#185FA5", "#042C53"))(100)

pheatmap(
  cm_norm,
  color             = pal,
  cluster_rows      = FALSE,
  cluster_cols      = FALSE,
  display_numbers   = TRUE,
  number_format     = "%.2f",
  number_color      = "grey20",
  fontsize_number   = 7,
  fontsize_row      = 9,
  fontsize_col      = 9,
  angle_col         = 45,
  main              = "Confusion matrix — row-normalised (recall per class)",
  legend_breaks     = seq(0, 1, 0.2),
  legend_labels     = paste0(seq(0, 100, 20), "%"),
  border_color      = "white"
)

# Performance Metrics
# Per-class: TP (true positive), FP (false positive), FN (false negative)
TP <- diag(cm_mat)
FP <- colSums(cm_mat) - TP
FN <- rowSums(cm_mat) - TP
TN <- sum(cm_mat) - TP - FP - FN

precision <- ifelse((TP + FP) == 0, NA, TP / (TP + FP))
recall    <- ifelse((TP + FN) == 0, NA, TP / (TP + FN))
f1        <- ifelse(is.na(precision) | is.na(recall) |
                    (precision + recall) == 0,
                    NA,
                    2 * precision * recall / (precision + recall))
class_acc <- ifelse((TP + FP + FN + TN) == 0, NA,
                    (TP + TN) / (TP + FP + FN + TN))

overall_acc <- sum(TP) / sum(cm_mat)

metrics_df <- tibble(
  Class       = rownames(cm_mat),
  TP          = TP,
  FP          = FP,
  FN          = FN,
  Precision   = round(precision, 3),
  Recall      = round(recall, 3),
  F1          = round(f1, 3),
  Class_Acc   = round(class_acc, 3)
) %>%
  left_join(cs_raw, by = "Class") %>%
  arrange(desc(F1))

metrics_df #call result table

## Overall accuracy
cat(sprintf("Overall accuracy: %.2f%%\n", overall_acc * 100))

## Per-class metrics table
# Metrics table with color coded F1 score between high (>75%), moderate (<75% and >50%) and low (<50%)
metrics_df %>%
  select(Class, n_annotations, Precision, Recall, F1, Class_Acc) %>%
  rename(
    `N train`        = n_annotations,
    `F1 score`       = F1,
    `Class accuracy` = Class_Acc
  ) %>%
  kbl(caption = sprintf(
    "Per-class metrics — Overall accuracy: %.2f%%", overall_acc * 100)) %>%
  kable_styling(bootstrap_options = c("striped", "hover", "condensed"),
                full_width = FALSE) %>%
  column_spec(5, bold = TRUE,
              color = case_when(
                is.na(metrics_df$F1)        ~ "grey60",
                metrics_df$F1 >= 0.75       ~ "#0F6E56",
                metrics_df$F1 >= 0.50       ~ "#BA7517",
                TRUE                        ~ "#A32D2D"
              )) %>%
  scroll_box(height = "500px")

## F1 score — ranked plot
metrics_df %>%
  filter(!is.na(F1)) %>%
  arrange(F1) %>%
  mutate(Class = factor(Class, levels = Class),
         tier = case_when(
           F1 >= 0.75 ~ "Good (≥0.75)",
           F1 >= 0.50 ~ "Moderate (0.50–0.75)",
           TRUE       ~ "Poor (<0.50)"
         ),
         tier = factor(tier, levels = c("Good (≥0.75)",
                                        "Moderate (0.50–0.75)",
                                        "Poor (<0.50)"))) %>%
  ggplot(aes(x = Class, y = F1, fill = tier)) +
  geom_col(width = 0.75) +
  geom_hline(yintercept = c(0.5, 0.75),
             linetype = "dashed", color = "grey50", linewidth = 0.5) +
  scale_fill_manual(values = c(
    "Good (≥0.75)"        = "#1D9E75",
    "Moderate (0.50–0.75)"= "#BA7517",
    "Poor (<0.50)"        = "#A32D2D"
  )) +
  scale_y_continuous(limits = c(0, 1), labels = percent) +
  coord_flip() +
  labs(title = "F1 score per class — ranked",
       x = NULL, y = "F1 score", fill = "Performance tier") +
  theme_minimal(base_size = 12) +
  theme(panel.grid.major.y = element_blank(),
        legend.position = "bottom",
        plot.title = element_text(face = "bold", size = 13))

## Precision vs. Recall scatter
metrics_df %>%
  filter(!is.na(Precision), !is.na(Recall)) %>%
  ggplot(aes(x = Recall, y = Precision,
             size = n_annotations, color = F1,
             label = Class)) +
  geom_point(alpha = 0.75) +
  ggrepel::geom_text_repel(size = 2.8, max.overlaps = 20,
                            color = "grey30") +
  scale_color_gradient(low = "#F09595", high = "#1D9E75",
                       name = "F1 score") +
  scale_size_continuous(name = "N training annotations",
                        range = c(2, 10)) +
  scale_x_continuous(limits = c(0, 1), labels = percent) +
  scale_y_continuous(limits = c(0, 1), labels = percent) +
  geom_abline(slope = 1, intercept = 0,
              linetype = "dashed", color = "grey60") +
  labs(title = "Precision vs. Recall per class",
       subtitle = "Point size = training set size · Color = F1 score",
       x = "Recall", y = "Precision") +
  theme_minimal(base_size = 12) +
  theme(plot.title = element_text(face = "bold", size = 13))

# Summary & Interpretation
n_good <- sum(metrics_df$F1 >= 0.75, na.rm = TRUE)
n_mod  <- sum(metrics_df$F1 >= 0.50 & metrics_df$F1 < 0.75, na.rm = TRUE)
n_poor <- sum(metrics_df$F1 < 0.50, na.rm = TRUE)

worst <- metrics_df %>% filter(!is.na(F1)) %>% slice_min(F1, n = 3)
best  <- metrics_df %>% filter(!is.na(F1)) %>% slice_max(F1, n = 3)

cat(sprintf("Overall accuracy     : %.2f%%\n", overall_acc * 100))
cat(sprintf("Classes assessed     : %d\n", n_classes))
cat(sprintf("Good F1 (>=0.75)     : %d classes\n", n_good))
cat(sprintf("Moderate F1 (0.5-0.75): %d classes\n", n_mod))
cat(sprintf("Poor F1 (<0.50)      : %d classes\n\n", n_poor))
cat("Top 3 best performing classes:\n")
print(select(best, Class, F1, Recall, Precision, n_annotations))
cat("\nTop 3 worst performing classes:\n")
print(select(worst, Class, F1, Recall, Precision, n_annotations))

