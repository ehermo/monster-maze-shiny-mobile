library(glue)
library(logger)

test_that("get_random_free_position", {
  
  maze0_data <-            c(0,0,0,0,0,0,0,0,0,0,0,0)
  maze0_data <- c(maze0_data,0,0,0,0,0,0,1,0,0,0,0,0)
  maze0_data <- c(maze0_data,0,0,0,0,0,0,0,0,0,0,0,0)
  maze0 = matrix(maze0_data,nrow=3,ncol=12,byrow=TRUE);
  result <- get_random_free_position(maze0,list())
  expect_equal(result, new_position(row=2,col=7))
})

test_that("get_random_free_position", {
  
  maze0_data <-            c(0,0,0,0,0,0,0,0,0,0,0,0)
  maze0_data <- c(maze0_data,0,0,0,0,0,0,1,1,0,0,0,0)
  maze0_data <- c(maze0_data,0,0,0,0,0,0,0,0,0,0,0,0)
  maze0 = matrix(maze0_data,nrow=3,ncol=12,byrow=TRUE);
  result <- get_random_free_position(maze0,list())
  expect(any(result %in% c(new_position(row=2,col=7),new_position(row=2,col=8))), glue('error'))
})

test_that("get_random_free_position", {
  
  maze0_data <-            c(0,0,0,0,0,0,0,0,0,0,0,0)
  maze0_data <- c(maze0_data,0,0,0,0,0,0,0,0,0,0,0,0)
  maze0_data <- c(maze0_data,0,0,0,0,0,0,0,0,0,0,0,0)
  maze0 = matrix(maze0_data,nrow=3,ncol=12,byrow=TRUE);
  result <- get_random_free_position(maze0,list())
  log_info("Result positon: {result}")
  expect_equal(result,new_position(row=NULL, col=NULL))
})

