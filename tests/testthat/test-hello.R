test_that("hello_pas returns expected greeting", {
  expect_equal(hello_pas(), "Hello, world!")
  expect_equal(hello_pas("R"), "Hello, R!")
})
