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
library("keys")

# Define UI for application 
ui<- fluidPage(
  useKeys(),
  keysInput("keys",c("up","left","right")),
    fluidRow(
        column(12,
              # https://groups.google.com/g/shiny-discuss/c/8GmXV-UfTm4?pli=1
               verbatimTextOutput("banner"),
              align="center",
              tags$head(tags$style(HTML("
                            #banner {
                              font-size: 7px;
                              background-color: black;
                              color:green;
                            }
                            "))),
              style ="font-size:10px;")),
    fluidRow(
      column(4,
             #"Side Panel",
             fluidRow(
               column(12,
                      "Level & Lives",
                      verbatimTextOutput("level"),
                      tags$head(tags$style(HTML("
                            #level {
                              font-size: 40px;
                              background-color: black;
                              color:green;
                            }
                            "))),
                      style ="font-size:20px;")),
             fluidRow(
               column(12,
                      "Legend",
                      verbatimTextOutput("legend"),
                      tags$head(tags$style(HTML("
                            #legend {
                              font-size: 20px;
                              background-color: black;
                              color:green;
                            }
                            "))),
                      style ="font-size:20px;")),
             fluidRow(
               column(12,
                      "Keys",
                      verbatimTextOutput("keys"),
                      tags$head(tags$style(HTML("
                            #keys {
                              font-size: 20px;
                              background-color: black;
                              color:green;
                            }
                            "))),
                      style ="font-size:20px;")
             )
      ),
      
      column(width = 8,
             fluidRow(
               column (12,
             "Player's View",
             htmlOutput("players_view"),
             align="center",
             tags$head(tags$style(HTML("
                            #players_view {
                              font-size: 15px;
                              background-color: white;
                              color:black;
                            }
                            "))),
             style ="font-size:20px;")),
      fluidRow(
        column(12,
        "Console",
        verbatimTextOutput("console"),
        tags$head(tags$style(HTML("
                            #cosole {
                              font-size: 15px;
                            }"))),
        style ="font-size:20px;"
      ))

)),
style="background-color: black;color:green;"
)
    
#
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
    pane2[map_idx,"Map"] <- paste0('<p style="margin-top: -0.6em;padding-top:0;">',line,'</p>')
    map_idx <- map_idx + 1
  }
  return(paste(pane2,collapse=""))
}


server <- function(input, output) {

  #game_info
  game_info <- reactiveValues(
    lives = 6,
    level_key = "level1",
    level_id = 1,
    scene = ""
  )
  #level_info
  maze = reactive(game_level_map$get(game_info$level_key)$maze)
  forward_vision <- reactive(game_level_map$get(game_info$level_key)$forward_vision)
  rear_vision = reactive(game_level_map$get(game_info$level_key)$rear_vision)
  num_ghosts =  reactive(game_level_map$get(game_info$level_key)$num_ghosts)
  num_zombies =  reactive(game_level_map$get(game_info$level_key)$num_zombies)
  ghost_speed =  reactive(game_level_map$get(game_info$level_key)$ghost_speed)
  zombie_speed =  reactive(game_level_map$get(game_info$level_key)$zombie_speed)
  radius_to_exit =  reactive(game_level_map$get(game_info$level_key)$radius_to_exit)
  #turn_info 
  player_direction = reactiveVal(NULL)
  player_position = reactiveVal(NULL)
  ghost_positions = reactiveVal(NULL)
  zombie_positions = reactiveVal(NULL)
  #counters 
  ghost_moves =reactiveVal(0)
  player_moves_since_last_ghost_move = reactiveVal(0)
  zombie_moves = reactiveVal(0)
  player_moves_since_last_zombie_move = reactiveVal(0)
  player_moves = reactiveVal(0)
  
  #console 
  console <- reactiveValues(data=NULL)
  console$data <- "
39 years have passed since the unsettling events in that creepy sort of place known as 'Ghost Maze'.
The yells and shouts haven’t ceased ever since. 
But it has only been recently when villagers have started to claim that something new has now nested and dwells inside those walls.
"
  #banner
  banner = reactiveVal(title())

  # set the initial values 
  observeEvent(TRUE, ignoreNULL = FALSE, ignoreInit = FALSE, once = TRUE, {
  initial = shuffle(maze=maze(), 
                        num_ghosts=num_ghosts(), 
                        num_zombies = num_zombies(), 
                        radius_to_exit = radius_to_exit())

    game_info$scene = "intro"
    player_direction(initial$player_direction)
    player_position(initial$player_position)
    ghost_positions(initial$ghost_positions)
    zombie_positions(initial$zombie_positions)
  })
  
  #reactive expression to determine the level and lives based on level_key and lives
  level <- reactive(paste(c(
                            paste0(c(game_level_map$get(game_info$level_key)$name,"/",game_level_map$size()),sep="",collapse=""),
                            paste0(rep("🧡",game_info$lives),collapse="")
                          )
                          ,collapse="\n",sep=""))
  
  move_monsters <- reactive({
    #ghosts move according to ghost speed
    if (player_moves_since_last_ghost_move() == ghost_speed()) {
      occupied_positions <- append(zombie_positions(), get_positions_nearby(maze = maze(),this_position = player_position(), radius = 1))
      ghost_positions(get_random_free_positions(maze = maze(), num = num_ghosts(), occupied_positions = occupied_positions))
      ghost_moves(ghost_moves() +  1)
      player_moves_since_last_ghost_move(0)
    }
    #zombies move according to zombie speed
    if (player_moves_since_last_zombie_move() == zombie_speed()) {
      zombie_positions(move_zombies(maze=maze(),zombie_positions = zombie_positions(), ghost_positions = ghost_positions(), player_position = player_position()))
      zombie_moves(zombie_moves() +  1)
      player_moves_since_last_zombie_move(0)
    }
    
   #monster_collision <- check_collision_monster_player(player_position = player_position(),
  #                                                      ghost_positions = ghost_positions(),
  #                                                      zombie_positions = zombie_positions())
    
    
    #check_collision_monster_player <- function(player_position, ghost_positions, zombie_positions) {
      monster_collision <- NONE
      if (is_player_next_to_any_ghost(player_position(), ghost_positions())) {
        monster_collision <- GHOST
        game_info$scene <- "ghost"
        console$data <- "Boo boooo! Shuffled away!"
      }
      else if (is_player_caught_by_any_zombie(player_position(), zombie_positions())) {
        monster_collision <- ZOMBIE
        game_info$scene <- "zombie"
        console$data <- "Tasty brains! Shuffled away!"
      }
    #  return(collision)
  #  }

    if ( monster_collision != NONE) {
      after_shuffle <- shuffle(maze=maze(), num_ghosts= num_ghosts(), num_zombies = num_zombies(), radius_to_exit = radius_to_exit())
      player_position(after_shuffle$player_position)
      player_direction(after_shuffle$player_direction)
      ghost_positions(after_shuffle$ghost_positions)
      zombie_positions(after_shuffle$zombie_positions)

      if(monster_collision == ZOMBIE) {
        game_info$lives <- game_info$lives - 1
      }
      
      if (game_info$lives == 0) {
       game_info$scene ="end"
      }
    }
  })

   players_view <- reactive({
                              scene_to_play <- isolate(game_info$scene)
                              if (scene_to_play != "") {
                                scene <- scene_map$get(scene_to_play)
                                sound <- scene$sound
                                beep(sound$beep)
                                duration = sound$duration
                                if(scene$invalidate) {
                                  if(duration != 0 ) {
                                    invalidateLater(duration* 1000)
                                  }
                                  isolate(game_info$scene <-"")
                                }
                               pre(HTML(scene$ascii),style="background-color:white;color:black;")
                              }
                              else {
                                div(HTML(build_players_view(maze = maze(),
                                         player_position = player_position(),
                                         ghost_positions = ghost_positions(),
                                         zombie_positions = zombie_positions(),
                                         player_direction = player_direction(),
                                         forward_vision =  forward_vision(),
                                         rear_vision = rear_vision())),style="font-size:55px; margin-top:0.5em")
                              }
                              
     })
  
   
  # Observe user input keys
  observeEvent(input$keys, {
    
     if (input$keys == "left") {
       console$data <- "Turning left"
       player_direction(turn(player_direction(),"LEFT"))
       player_moves_since_last_ghost_move(player_moves_since_last_ghost_move() + 1)
       player_moves_since_last_zombie_move(player_moves_since_last_zombie_move() + 1)
       player_moves(player_moves() + 1)
       move_monsters()
     }
    else if (input$keys == "right"){
      console$data <- "Turning right"
      player_direction(turn(player_direction(),"RIGHT"))
      player_moves_since_last_ghost_move(player_moves_since_last_ghost_move() + 1)
      player_moves_since_last_zombie_move(player_moves_since_last_zombie_move() + 1)
      player_moves(player_moves() + 1)
      move_monsters()
    }
    else if (input$keys == "up") {
      console$data <- "Walking forward"
      
      next_position <- get_position_forward(player_position(), player_direction())
      # Wall player collision detection
      if(can_move_to(maze(),next_position)) {
        player_position(next_position)
        player_moves_since_last_ghost_move(player_moves_since_last_ghost_move() + 1)
        player_moves_since_last_zombie_move(player_moves_since_last_zombie_move() + 1)
        player_moves(player_moves() + 1)
        if(is_exit(maze(),player_position())) {
          
          console$data <- sprintf("You have escaped in %d moves\n", ghost_moves() * ghost_speed() + player_moves_since_last_ghost_move())
          
          game_info$level_id <- game_info$level_id + 1
          if(game_info$level_id <= game_level_map$size()) {
            next_level<-game_level_map$keys()[[game_info$level_id]]
            game_info$level_key <- next_level
            game_info$scene = "new_level"
            initial = shuffle(maze=maze(), 
                              num_ghosts=num_ghosts(), 
                              num_zombies = num_zombies(), 
                              radius_to_exit = radius_to_exit())
            player_direction(initial$player_direction)
            player_position(initial$player_position)
            ghost_positions(initial$ghost_positions)
            zombie_positions(initial$zombie_positions)
            ghost_moves(0)
            player_moves_since_last_ghost_move(0)
            zombie_moves(0)
            player_moves_since_last_zombie_move(0)
            player_moves(0)
          }
          else {
            game_info$scene = "you_won"
          }
          
        }
        else {
          move_monsters()
        }
      }
      else {
        console$data <- "You are a muggle, you cannot walk through the walls!!\n"
        
      }
    }
      
   })

  output$banner = renderText({banner()})
  output$legend = renderText({legend()})
  output$keys = renderText({actions()})
  output$level = renderText({level()})
  output$players_view = renderUI({players_view()})
  output$console = renderText({console$data})
}

# Run the application 
shinyApp(ui = ui, server = server)
