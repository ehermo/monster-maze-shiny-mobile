library(glue)
library(logger)

test_that("is-next-to", {
  
  position_1 <- new_position(row=2, col=2)
  position_2 <- new_position(row=7, col=7)
  max_distance <- 5
  actual_distance <- calc_distance(position_1, position_2)
  log_info(glue("Actual distance: {actual_distance} "))
  result <- is_next_to(position_1, position_2, max_distance)
  expect_equal(result, FALSE)
})

test_that("is-next-to", {
  
  position_1 <- new_position(row=2, col=2)
  position_2 <- new_position(row=7, col=7)
  max_distance <- 10
  actual_distance <- calc_distance(position_1, position_2)
  log_info(glue("Actual distance: {actual_distance} "))
  result <- is_next_to(position_1, position_2, max_distance)
  expect_equal(result, TRUE)
})