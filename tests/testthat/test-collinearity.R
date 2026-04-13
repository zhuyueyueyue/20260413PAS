test_that("check_collinearity_df detects high correlation and vif", {
  set.seed(42)
  x1 <- rnorm(100)
  x2 <- x1 * 0.95 + rnorm(100, sd = 0.05)
  x3 <- rnorm(100)
  dat <- data.frame(x1 = x1, x2 = x2, x3 = x3)

  res <- check_collinearity_df(dat, corr_threshold = 0.8)

  expect_true(is.list(res))
  expect_true(all(c("vif", "cor_matrix", "high_correlation_pairs") %in% names(res)))
  expect_true(any(res$high_correlation_pairs$var1 == "x1" | res$high_correlation_pairs$var2 == "x1"))
  expect_true(any(res$vif$indicator == "x1"))
})


test_that("check_collinearity_df errors for too few usable columns", {
  dat <- data.frame(a = rep(1, 10), b = rep(2, 10))
  expect_error(check_collinearity_df(dat), "Not enough valid numeric indicators")
})
