#' Check multicollinearity for a data frame
#'
#' Calculates pairwise correlations and VIF (variance inflation factor)
#' for selected numeric indicators.
#'
#' @param data A data.frame containing indicators.
#' @param vars Optional character vector of column names to include.
#'   Default `NULL` means all numeric columns.
#' @param corr_threshold Numeric, absolute correlation threshold used to flag
#'   high-correlation pairs. Default `0.8`.
#'
#' @return A list with:
#' \describe{
#'   \item{meta}{Basic info about selected indicators and row count.}
#'   \item{vif}{A data.frame with indicator, VIF and tolerance.}
#'   \item{cor_matrix}{Correlation matrix.}
#'   \item{high_correlation_pairs}{Pairs with absolute correlation above threshold.}
#' }
#' @export
check_collinearity_df <- function(data, vars = NULL, corr_threshold = 0.8) {
  stopifnot(is.data.frame(data))
  stopifnot(is.numeric(corr_threshold), length(corr_threshold) == 1)

  if (is.null(vars)) {
    numeric_cols <- vapply(data, is.numeric, logical(1))
    vars <- names(data)[numeric_cols]
  }

  if (length(vars) < 2) {
    stop("At least 2 numeric indicators are required.")
  }

  missing_vars <- setdiff(vars, names(data))
  if (length(missing_vars) > 0) {
    stop(sprintf("Variables not found: %s", paste(missing_vars, collapse = ", ")))
  }

  x <- data[vars]
  non_numeric <- names(x)[!vapply(x, is.numeric, logical(1))]
  if (length(non_numeric) > 0) {
    stop(sprintf("Non-numeric indicators included: %s", paste(non_numeric, collapse = ", ")))
  }

  # remove all-NA or near-constant columns
  keep <- vapply(
    x,
    function(col) {
      col <- col[!is.na(col)]
      length(col) > 1 && stats::var(col) > 0
    },
    logical(1)
  )
  x <- x[keep]

  if (ncol(x) < 2) {
    stop("Not enough valid numeric indicators after filtering constants/NA-only columns.")
  }

  cor_mat <- stats::cor(x, use = "pairwise.complete.obs")

  # high-correlation pairs
  idx <- which(abs(cor_mat) >= corr_threshold & upper.tri(cor_mat), arr.ind = TRUE)
  high_pairs <- if (nrow(idx) == 0) {
    data.frame(var1 = character(0), var2 = character(0), correlation = numeric(0))
  } else {
    data.frame(
      var1 = colnames(cor_mat)[idx[, "row"]],
      var2 = colnames(cor_mat)[idx[, "col"]],
      correlation = cor_mat[idx],
      row.names = NULL
    )
  }

  # VIF calculation via regressing each variable on all others
  calc_vif <- function(target, frame) {
    others <- setdiff(names(frame), target)
    if (length(others) == 0) {
      return(NA_real_)
    }

    fit <- stats::lm(stats::as.formula(sprintf("%s ~ %s", target, paste(others, collapse = " + "))), data = frame)
    r2 <- summary(fit)$r.squared

    if (is.na(r2)) {
      return(NA_real_)
    }
    if (r2 >= 0.999999) {
      return(Inf)
    }
    1 / (1 - r2)
  }

  vif_values <- vapply(names(x), calc_vif, numeric(1), frame = x)
  vif_df <- data.frame(
    indicator = names(vif_values),
    vif = unname(vif_values),
    tolerance = ifelse(is.finite(vif_values), 1 / vif_values, 0),
    row.names = NULL
  )

  list(
    meta = list(
      n_rows = nrow(data),
      indicators = names(x),
      corr_threshold = corr_threshold
    ),
    vif = vif_df,
    cor_matrix = cor_mat,
    high_correlation_pairs = high_pairs
  )
}

#' Check multicollinearity from an Excel file
#'
#' Reads an Excel sheet and runs [check_collinearity_df()].
#'
#' @param path Excel file path.
#' @param sheet Sheet name or index. Default `1`.
#' @param vars Optional character vector of column names to include.
#' @param corr_threshold Numeric threshold for absolute correlation flagging.
#'
#' @return Same structure as [check_collinearity_df()].
#' @export
check_collinearity_excel <- function(path, sheet = 1, vars = NULL, corr_threshold = 0.8) {
  stopifnot(is.character(path), length(path) == 1)
  if (!file.exists(path)) {
    stop(sprintf("Excel file not found: %s", path))
  }

  data <- readxl::read_excel(path = path, sheet = sheet)
  data <- as.data.frame(data)

  check_collinearity_df(data = data, vars = vars, corr_threshold = corr_threshold)
}
