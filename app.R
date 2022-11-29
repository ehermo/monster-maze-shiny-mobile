#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#
source("game/monster-maze-all.R")
library(shiny)

# Define UI for application 
ui<- fluidPage(
    fluidRow(
        column(12,
              # https://groups.google.com/g/shiny-discuss/c/8GmXV-UfTm4?pli=1
               verbatimTextOutput("banner"),
              align="center"
              )
        ),
    fluidRow(
      column(2,
             #"Side Panel",
             fluidRow(
               column(12,
                      "Level",
                      verbatimTextOutput("level"),
                      tags$head(tags$style(HTML("
                            #level {
                              font-size: 30px;
                            }
                            "))),
                      style ="font-size:50px;")),
             fluidRow(
               column(12,
                      "Legend",
                      verbatimTextOutput("legend"),
                      tags$head(tags$style(HTML("
                            #legend {
                              font-size: 30px;
                            }
                            "))),
                      style ="font-size:50px;")),
             fluidRow(
               column(12,
                      "Actions",
                      verbatimTextOutput("actions"),
                      tags$head(tags$style(HTML("
                            #actions {
                              font-size: 30px;
                            }
                            "))),
                      style ="font-size:50px;")
             )
      ),
      
      column(width = 10,
             fluidRow(
               column (12,
             "Player's View",
             verbatimTextOutput("players_view"),
             align="center",
             tags$head(tags$style(HTML("
                            #players_view {
                              font-size: 50px;
                            }
                            "))),
             style ="font-size:50px;")),
              fluidRow(
                column(12,
                  column(width = 4,
                      actionButton("left","Left",  icon = icon("arrow-left", lib="glyphicon")), align="right"),
                  column(width = 4,
                      actionButton("forward","Forward",  icon = icon("arrow-up", lib="glyphicon")),  align="center"),
                  column(width = 4,
                      actionButton("right","Right", icon = icon("arrow-right", lib="glyphicon")), align="left"))
      ),
      fluidRow(
        column(12,
        "Console",
        verbatimTextOutput("console"),
      ))

)))
    

build_players_view <- function(maze,
                         player_position,
                         ghost_positions,
                         zombie_positions, 
                         player_direction, 
                         forward_vision, 
                         rear_vision) {
  
  maze_view <- what_player_can_see(maze = maze,
                                   player_position = player_position, 
                                   ghost_positions = ghost_positions, 
                                   zombie_positions = zombie_positions,
                                   direction = player_direction,
                                   forward_vision = forward_vision,
                                   rear_vision  = rear_vision)
  view = get_graphics(maze_view,graph_map)
  
  map_height <- nrow(view)
  pane2_height <- map_height + 1
  pane2 <- matrix("", nrow = pane2_height, ncol = 1 )
  colnames(pane2) <- c("Map")
  map_idx <- 1
  for (line in apply(view, 1, paste, collapse = "")) {
    pane2[map_idx,"Map"] <- paste0("",line,"")
    map_idx <- map_idx + 1
  }
  return(paste(pane2,collapse="\n"))
}


server <- function(input, output) {

  game_info <- reactiveValues(
    lives = 6,
    level_id = "level1"
  )
  
  #level_info
    maze = reactive(game_level_map$get(game_info$level_id)$maze)
    forward_vision <- reactive(game_level_map$get(game_info$level_id)$forward_vision)
    rear_vision = reactive(game_level_map$get(game_info$level_id)$rear_vision)
    num_ghosts =  reactive(game_level_map$get(game_info$level_id)$num_ghosts)
    num_zombies =  reactive(game_level_map$get(game_info$level_id)$num_zombies)
    ghost_speed =  reactive(game_level_map$get(game_info$level_id)$ghost_speed)
    zombie_speed =  reactive(game_level_map$get(game_info$level_id)$zombie_speed)
    radius_to_exit =  reactive(game_level_map$get(game_info$level_id)$radius_to_exit)
  
  
 #turn_info 
   player_direction = reactiveVal(NULL)
   player_position = reactiveVal(NULL)
   ghost_positions = reactiveVal(NULL)
   zombie_positions = reactiveVal(NULL)
   
   ghost_moves =reactiveVal(0)
   player_moves_since_last_ghost_move = reactiveVal(0)
   zombie_moves = reactiveVal(0)
   player_moves_since_last_zombie_move = reactiveVal(0)
   player_moves = reactiveVal(0)
   
  
  console <- reactiveValues(data=NULL)

  observeEvent(TRUE, ignoreNULL = FALSE, ignoreInit = FALSE, once = TRUE, {
    print("null observeEvent")
    initial = shuffle(maze=maze(), 
                        num_ghosts=num_ghosts(), 
                        num_zombies = num_zombies(), 
                        radius_to_exit = radius_to_exit())
    player_direction(initial$player_direction)
    player_position(initial$player_position)
    ghost_positions(initial$ghost_positions)
    zombie_positions(initial$zombie_positions)
  })
  
  
  level <- reactive(paste(c(game_level_map$get(game_info$level_id)$name, forward_vision(), player_direction()),collpase="\n"))
  

   players_view <- reactive(build_players_view(maze = maze(),
                                         player_position = player_position(),
                                         ghost_positions = ghost_positions(),
                                         zombie_positions = zombie_positions(),
                                         player_direction = player_direction(),
                                         forward_vision =  forward_vision(),
                                         rear_vision = rear_vision()))
  
   

  observeEvent(input$left, {
    console$data <- "left"
    console$data <- paste0(console$data , turn(player_direction(),"LEFT"))
    player_direction(turn(player_direction(),"LEFT"))
    player_moves_since_last_ghost_move(player_moves_since_last_ghost_move() + 1)
    player_moves_since_last_zombie_move(player_moves_since_last_zombie_move() + 1)
    player_moves(player_moves() + 1)
  })
  
  observeEvent(input$right, {
    console$data <- "right"
    console$data <- paste0(console$data , turn(player_direction(),"RIGHT"))
    player_direction(turn(player_direction(),"RIGHT"))
    player_moves_since_last_ghost_move(player_moves_since_last_ghost_move() + 1)
    player_moves_since_last_zombie_move(player_moves_since_last_zombie_move() + 1)
    player_moves(player_moves() + 1)
  })
  
  observeEvent(input$forward, {
    console$data <- "forward"
    
    next_position <- get_position_forward(player_position(), player_direction())
    # Wall player collision detection
    if(can_move_to(maze(),next_position)) {
      player_position(next_position)
      player_moves_since_last_ghost_move(player_moves_since_last_ghost_move() + 1)
      player_moves_since_last_zombie_move(player_moves_since_last_zombie_move() + 1)
      player_moves(player_moves() + 1)
      if(is_exit(maze(),player_position())) {
        
        console$data <- sprintf("You have escaped in %d moves\n", ghost_moves() * ghost_speed() + player_moves_since_last_ghost_move())
      }
    }
    else {
      console$data <- "You are a muggle, you cannot walk through the walls!!\n"
    
    }
  })

  output$banner = renderText({ title()})
  output$legend = renderText({legend()})
  output$actions = renderText({actions()})
  output$level = renderText({level()})
  output$players_view = renderText({players_view()})
  output$console = renderText({console$data})

}

# Run the application 
shinyApp(ui = ui, server = server)
