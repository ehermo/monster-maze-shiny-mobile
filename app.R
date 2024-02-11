#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#
source("game/monster-maze-all.R")
#install.packages(c("howler","shinyjs"))
library(shiny)
library("howler")
library(shinyjs)

jsCode <- "
shinyjs.replay_walking = function(params) {
  $('#player').attr('src', 'char_walking.gif');
}

shinyjs.replay_turning_left = function(params) {
  $('#player').attr('src', 'char_walking.gif');
}

shinyjs.replay_turning_right = function(params) {
  $('#player').attr('src', 'char_walking.gif');
  
}
"

# Define UI for application 
ui<- fluidPage(
  useShinyjs(), 
  extendShinyjs(text = jsCode,functions = c("replay_walking","replay_turning_right","replay_turning_left")),
  includeCSS('www/CSS.css'),
  howler(
    elementId = "sound", 
    tracks = list("Track 1" = "sample_audio/smb_stage_clear.wav"),
    auto_continue = FALSE,
    auto_loop = FALSE,
    seek_ping_rate = 1000
  ),
    fluidRow(
        column(12,
              # https://groups.google.com/g/shiny-discuss/c/8GmXV-UfTm4?pli=1
              verbatimTextOutput("banner"),
              align="center",
              style ="font-size:10px;")),
    fluidRow(
      column(12,
            # "Level & Lives",
             verbatimTextOutput("level"),
             tags$head(tags$style(HTML("
              #level {
                font-size: 15px;
                background-color: black;
                color:green;
               }"))),
              style ="font-size:20px;")),

      fluidRow(
        column (12,
          # "Player's View",
          htmlOutput("players_view"),
          align="center",
          tags$head(tags$style(HTML("
            #players_view {
              font-size: 15px;
              background-color: white;
              color:black;
            }"))),
          style ="font-size:20px;")),
      fluidRow(
        column(6,
            tags$button(
              id = "forward",
              class = "btn action-button btn-info",
              label="right",
              type="button",
              tags$img(src = "char.gif",
                       height = "40px"),
              style="padding-right:0px;padding-left:0px; border-radius: 10px; height:100px; width:100%;"
            ),   
           class = "col-xs-6",
           style="padding-right:0;padding-left:0;"),
      column(3,
          tags$button(
            id = "left",
            class = "btn action-button btn-success",
            label="right",
            type="button",
            tags$img(src = "char_left.gif",
              height = "40px"),
            style="border-radius: 10px; height:100px; width:100%; "
          ),
      class = "col-xs-3",
      style="padding-right:0;padding-left:0;"),
      column(3,
        tags$button(
          id = "right",
          class = "btn action-button btn-warning",
          label="right",
          type="button",
          tags$img(src = "char_right.gif",
            height = "40px"),
            style="border-radius: 10px; height:100px; width:100%;"
          ),
          class = "col-xs-3",
        style="padding-right:0;padding-left:0;"),
      style ="padding-top:0.5em;margin-bottom:0.5em;"),
      fluidRow(
        column(12,
        #"Console",
        verbatimTextOutput("console"),
        tags$head(tags$style(HTML("
                            #console {
                              font-size: 15px;
                            }"))),
        style ="font-size:20px;padding-top:0.5em;"
      )),
  style="background-color: black;color:green;"
)
    
#
server <- function(input, output) {


  onclick("forward", {
    js$replay_walking()
  })
  onclick("left", {
    js$replay_turning_left()
    #js$delay_render(1000)
  })
  onclick("right", {
    js$replay_turning_right()
    #js$delay_render(1000)
  })
  #game_info
  game_info <- reactiveValues(
    lives = 6,
    coins = 0,
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
  num_coins_gold =  reactive(game_level_map$get(game_info$level_key)$num_coins_gold)
  ghost_speed =  reactive(game_level_map$get(game_info$level_key)$ghost_speed)
  zombie_speed =  reactive(game_level_map$get(game_info$level_key)$zombie_speed)
  radius_to_exit =  reactive(game_level_map$get(game_info$level_key)$radius_to_exit)
  #turn_info 
  player_direction = reactiveVal(NULL)
  player_position = reactiveVal(NULL)
  ghost_positions = reactiveVal(NULL)
  zombie_positions = reactiveVal(NULL)
  coin_gold_positions = reactiveVal(NULL)
  #counters 
  ghost_moves =reactiveVal(0)
  player_moves_since_last_ghost_move = reactiveVal(0)
  zombie_moves = reactiveVal(0)
  player_moves_since_last_zombie_move = reactiveVal(0)
  player_moves = reactiveVal(0)
  num_shuffles = reactiveVal(0)
  
  #timer
  autoInvalidate <- reactiveTimer(1000)
  startedTimer = reactiveVal(NULL)
  afterIntro = reactiveVal(NULL)
  
  #console 
  console <- reactiveValues(data=NULL)

  #banner
  banner = reactiveVal(title())

  # set the initial values 
  observeEvent(TRUE, ignoreNULL = FALSE, ignoreInit = FALSE, once = TRUE, {
      initial = shuffle(maze=maze(), 
                        num_ghosts=num_ghosts(), 
                        num_zombies = num_zombies(),
                        num_coins_gold = num_coins_gold(),
                        radius_to_exit = radius_to_exit(),
                        num_shuffles = num_shuffles())

      isolate(num_shuffles(num_shuffles()+1))
      game_info$scene = "intro"
      player_direction(initial$player_direction)
      player_position(initial$player_position)
      ghost_positions(initial$ghost_positions)
      zombie_positions(initial$zombie_positions)
      coin_gold_positions(initial$coin_gold_positions)
      startedTimer(FALSE)
      afterIntro(FALSE)
      console$data <- "39 years have passed since 
the unsettling events in that 
creepy sort of place known as
'Ghost Maze'.
The yells and shouts haven’t 
ceased ever since. But it has 
only been recently when villagers
have started to claim that
something new has now nested 
and dwells inside those walls.
"
  })
  
  #reactive expression to determine the level and lives based on level_key and lives
  level <- reactive(paste(c(
                            paste0(c("Level: ",game_level_map$get(game_info$level_key)$name,"/",game_level_map$size()),sep="",collapse=""),
                            paste0(c("Lives: ", rep("🧡",game_info$lives), " 🟡: ", game_info$coins),collapse="")
                          )
                          ,collapse="\n",sep=""))
  
  move_monsters <- reactive({
    #isolate(console$data <- "")
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
    monster_collision <- NONE
    if (is_player_next_to_any_ghost(player_position(), ghost_positions())) {
      monster_collision <- GHOST
      game_info$scene <- "ghost"
      isolate(console$data <- "Boo boooo! Shuffled away!")
    }
    else if (is_player_caught_by_any_zombie(player_position(), zombie_positions())) {
      monster_collision <- ZOMBIE
      game_info$scene <- "zombie"
      isolate(console$data <- "Tasty brains! Shuffled away!")
    }
    if ( monster_collision != NONE) {
      after_shuffle <- shuffle(maze=maze(), 
                               num_ghosts= num_ghosts(), 
                               num_zombies = num_zombies(),
                               num_coins_gold = num_coins_gold(),
                               radius_to_exit = radius_to_exit(),
                               num_shuffles = num_shuffles())
      isolate(num_shuffles(num_shuffles() + 1))
      player_position(after_shuffle$player_position)
      player_direction(after_shuffle$player_direction)
      ghost_positions(after_shuffle$ghost_positions)
      zombie_positions(after_shuffle$zombie_positions)
      coin_gold_positions(after_shuffle$coin_gold_positions)
      if(monster_collision == ZOMBIE) {
        game_info$lives <- game_info$lives - 1
      }
      if (game_info$lives == 0) {
       game_info$scene ="end"
       isolate(autoInvalidate <- NULL)
       isolate(startedTimer(FALSE))
      }
    }
  })
  
  #
  show_buttons <- function() {
    shinyjs::show("left")
    shinyjs::show("right")
    shinyjs::show("forward")
  }
  
  #
  hide_buttons <- function() {
    shinyjs::hide("left")
    shinyjs::hide("right")
    shinyjs::hide("forward")
  } 
  
  #
  disable_buttons <- function(){
    shinyjs::disable("left")
    shinyjs::disable("right")
    shinyjs::disable("forward")
  }
   
  #
  enable_buttons <- function() {
    shinyjs::enable("left")
    shinyjs::enable("right")
    shinyjs::enable("forward")
  }
  
  observe({
    # Invalidate and re-execute this reactive expression every time the
    # timer fires.
    autoInvalidate()
    if (startedTimer()) {
      isolate(player_moves_since_last_ghost_move(player_moves_since_last_ghost_move() + 1))
      isolate(player_moves_since_last_zombie_move(player_moves_since_last_zombie_move() + 1))
      isolate(move_monsters())
    }
  })
  
  #
  players_view <- reactive({
    isolate(scene_to_play <- game_info$scene)
    if (scene_to_play != "") {
      scene <- scene_map$get(scene_to_play)
      sound <- scene$sound
      wav_file = sound$wav
      isolate(game_info$scene <- "")
      if(wav_file != "") {
        shinyjs::runjs(paste0("var music = new Howl({src: ['",wav_file,"'],html5:true}); music.play();"))
      }
      duration <- sound$duration
      result <- div(pre(HTML(scene$ascii),style=scene$style),style="background-color:black;color:green;text-align=center;")
      if(scene$invalidate) {
        if(duration != 0 ) {
          invalidateLater(duration * 1000 + 500)
          if(scene_to_play == "intro") {
            isolate(afterIntro(TRUE))
            hide_buttons()
          }
        }
      }
      return(result)
    }
    else {
      show_buttons()
      enable_buttons()
      if(isolate(!startedTimer()) & afterIntro()){
        isolate(startedTimer(TRUE))
      }
      return(div(HTML(build_players_view(maze = maze(),
        player_position = player_position(),
        ghost_positions = ghost_positions(),
        zombie_positions = zombie_positions(),
        player_direction = player_direction(),
        coin_gold_positions = coin_gold_positions(),
        forward_vision =  forward_vision(),
        rear_vision = rear_vision())),style="font-size:30px; margin-top:0.5em; background-color:black;color:green;"))
   }
  })

  
  #
  observeEvent(input$left, {
    isolate(console$data <- "")
    disable_buttons()
    player_direction(turn(player_direction(),"LEFT"))
    #player_moves_since_last_ghost_move(player_moves_since_last_ghost_move() + 1)
    #player_moves_since_last_zombie_move(player_moves_since_last_zombie_move() + 1)
    player_moves(player_moves() + 1)
    move_monsters()
    if(isolate(console$data == "")) {
      isolate(console$data <- "Turning left")
    }
  })

  #
  observeEvent(input$right, {
    isolate(console$data <- "")
    disable_buttons()
    player_direction(turn(player_direction(),"RIGHT"))
    #player_moves_since_last_ghost_move(player_moves_since_last_ghost_move() + 1)
    #player_moves_since_last_zombie_move(player_moves_since_last_zombie_move() + 1)
    player_moves(player_moves() + 1)
    move_monsters()
    if(isolate(console$data == "")) {
      isolate(console$data <- "Turning right")
    }
  })

  

  #
  observeEvent(input$forward, {
    isolate(console$data <- "")
    disable_buttons()
    next_position <- get_position_forward(player_position(), player_direction())
    # Wall player collision detection
    if(can_move_to(maze(),next_position)) {
      player_position(next_position)
      #player_moves_since_last_ghost_move(player_moves_since_last_ghost_move() + 1)
      #player_moves_since_last_zombie_move(player_moves_since_last_zombie_move() + 1)
      player_moves(player_moves() + 1)
      if(has_coin(coin_gold_positions(), player_position())) {
        game_info$coins <-  game_info$coins + 1
        coin_gold_positions(remove_position_from_list(player_position(),coin_gold_positions()))
        shinyjs::runjs(paste0("var music = new Howl({src: ['",coin_sound,"'],html5:true}); music.play();"))
      }
      else if(is_exit(maze(),player_position())) {
        move_counter <- ghost_moves() * ghost_speed() + player_moves_since_last_ghost_move()
        game_info$level_id <- game_info$level_id + 1
        if(game_info$level_id <= game_level_map$size()) {
          next_level<-game_level_map$keys()[[game_info$level_id]]
          game_info$level_key <- next_level
          game_info$scene = "new_level"
          num_shuffles(0)
          initial = shuffle(maze=maze(), 
                            num_ghosts=num_ghosts(), 
                            num_zombies = num_zombies(),
                            num_coins_gold = num_coins_gold(),
                            radius_to_exit = radius_to_exit(),
                            num_shuffles = num_shuffles())
          isolate(num_shuffles(num_shuffles() + 1))
          player_direction(initial$player_direction)
          player_position(initial$player_position)
          ghost_positions(initial$ghost_positions)
          zombie_positions(initial$zombie_positions)
          coin_gold_positions(initial$coin_gold_positions)
          ghost_moves(0)
          player_moves_since_last_ghost_move(0)
          zombie_moves(0)
          player_moves_since_last_zombie_move(0)
          player_moves(0)
        }
        else {
          game_info$scene = "you_won"
          isolate(autoInvalidate <- NULL)
          isolate(startedTimer(FALSE))
        }
        isolate(console$data <- sprintf("You have escaped in %d moves\n", move_counter))
      }
      else {
        move_monsters()
        if(isolate(console$data == "")) {
          isolate(console$data <- "Walking forward")
        }

      }
    }
    else {
      enable_buttons()
      isolate(console$data <- "You are a muggle, you cannot walk through the walls!!\n")
    }
  })

  output$banner = renderText({banner()})
  output$level = renderText({level()})
  output$players_view = renderUI({players_view()})
  output$console = renderText({console$data})
}

# Run the application 
shinyApp(ui = ui, server = server)
