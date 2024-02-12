# Monster Maze
# Naming conventions
# http://adv-r.had.co.nz/Style.html
# https://www.datanovia.com/en/blog/r-coding-style-best-practices/#function-naming-convention

# Packages
# https://statsandr.com/blog/an-efficient-way-to-install-and-load-r-packages/
# install.packages("pacman", repos = "http://cran.us.r-project.org")
# pacman::p_load(collections, knitr, invctr, beepr, dplyr, stringr,purrr)

#install.packages(c('collections', 'knitr', 'invctr', 'beepr', 'dplyr', 'stringr','purrr'),quiet = TRUE)
#install.packages('microbenchmark')
library(collections)
library(knitr)
library(invctr)
library(beepr)
library(dplyr)
library(stringr)
library(purrr)

source("ascii_art.R")
                 

# Constants
NONE <- -1
WALL <- 0
CORRIDOR <- 1
EXIT <- 9
GHOST <- 2
ZOMBIE <- 3
PLAYER <- 5
COL <- 6
COIN_GOLD <- 7
DIRECTIONS <- c("N", "E", "S", "W")

# Action map
# * key (name):""
# * value (action): list
# * * desc:""
# * * keys (keyboard):c()
# * * echo:""
action_map <- dict()
action_map$set("turnl",
               list(
                 "desc" = "turn left ←L",
                 "keys" = c("left arrow"),
                 "echo" = "%s: turning left ←"))
action_map$set("walk" ,
               list(
                 "desc" = "walk forward ↑F",
                 "keys" = c("up arrow"),
                 "echo" = "%s: moving forward ↑"))
action_map$set("turnr",
               list(
                 "desc" = "turn right →R", 
                 "keys" = c("right arrow"),
                 "echo" = "%s: turning right →"))

# Graph map
# https://invisible-characters.com/
#graph_sep="\U17B5\U2063" # each invisible char works on a different terminal
#graph_sep=" " # each invisible char works on a different terminal
# https://www.w3schools.com/charsets/ref_emoji.asp
graph_map <- dict()
graph_map$set(NONE,     list(
  "block"="<div style='background-color:#442D17;height:32px;width:32px'/>",
  "desc"="out",
  "orientation"="none")) 
graph_map$set(WALL,     list(
  "block"="<img src=\"wall2.png\" height=32, width=32/>",
  "desc"="wall",
  "orientation"="none")) 
graph_map$set(CORRIDOR, list(
  "block"="<img src=\"path2.png\" height=32, width=32/>",
  "desc"="corridor", 
  "orientation"="none"))
graph_map$set(COIN_GOLD,list(
  "block"="<img src=\"coin_gold.gif\" height=32, width=32/>",
  "desc"="column",
  "orientation"="none")) 
graph_map$set(COL,      list(
  "block"="<img src=\"col.png\" height=32, width=32/>",
  "desc"="column",
  "orientation"="none")) 
graph_map$set(GHOST,    list(
  "block"="<img src=\"ghost.gif\" height=32, width=32>", 
  "desc"="ghost",
  "orientation"="none" ))
graph_map$set(EXIT,     list(
  "block"="<img src=\"exit.gif\" height=32, width=32>",
  "desc"="exit", 
  "orientation"="none"))
graph_map$set(PLAYER,   list(
  "block"="<img id=\"player\" src=\"char_walking.gif\" height=32, width=32>",
  "desc"="player", 
  "orientation"="none")) 
graph_map$set(ZOMBIE,   list(
  "block"="<img src=\"zombie_ORIENTATION.gif\" height=32, width=32>",
  "desc"="zombie", 
  "orientation"="focused-on-player"))


#
credits <- function() {
  msg <-"
  \n
  Creator
  Enrique Hermo
  
  Based on Ghost Maze by Colin Reynolds 
  
  ASCII art
  https://textart.sh/
  
  ASCII banners
  https://manytools.org/hacker-tools/ascii-banner/
  
  Art
  https://opengameart.org/
  tileset  HorusKDI
  " 
}


#
new_position <- function (row,col) {
  return (list("row" = as.integer(row),
               "col" = as.integer(col)))
}

#
get_random_direction <- function() {
  sample(DIRECTIONS,1)
}

#
can_move_to <- function(maze, destination) {
  return (maze[destination$row,destination$col] == CORRIDOR ||
            maze[destination$row,destination$col] == EXIT)
}

#
is_exit <- function(maze,position) {
  return (maze[position$row,position$col] == EXIT)
}

#
has_coin <- function(coin_positions, position) {
  return (coin_positions %>% has_element(position))
}

#
get_position_forward <- function(current_position, direction) {
  position_forward <- current_position
  if(direction == "N") {
    position_forward$row <- as.integer(position_forward$row - 1)
  } 
  else if (direction == "S") {
    position_forward$row <- as.integer(position_forward$row + 1)
  }
  else if (direction == "W") {
    position_forward$col <- as.integer(position_forward$col - 1)
  }
  else if (direction == "E") {
    position_forward$col <- as.integer(position_forward$col + 1) 
  }
  position_forward
}

#
calc_distance <- function(position_1, position_2) {
  row_distance <- abs(position_1$row - position_2$row)
  col_distance <- abs(position_1$col - position_2$col)
  distance <- row_distance + col_distance
}

# 
is_next_to <- function(position_1, position_2, max_distance) {
  distance <- calc_distance(position_1 = position_1, position_2 = position_2)
  if(distance > max_distance) {
    return(FALSE)
  }
  TRUE
}

#
is_player_next_to_any_ghost <-  function(player_position, positions) {
  if(length(positions) == 0) {
    return (FALSE)
  }
  Reduce('|',lapply(positions,is_next_to,position_2 = player_position, max_distance = 0))
}

#
is_player_caught_by_any_zombie <- function(player_position, zombie_positions) {
  if(length(zombie_positions) == 0) {
    return (FALSE)
  }
  Reduce('|',lapply(zombie_positions,is_next_to,position_2 = player_position, max_distance = 0))
}


#
get_player_position <- function(maze) {
  exit_idx <- PLAYER %ai% maze 
  new_position(exit_idx$row, exit_idx$col)
}

get_orientation_to_player <- function(position,player_position) {
 
  if(position$col < player_position$col) {
    return ("right")
  }
  else if (position$col > player_position$col) {
    return ("left")
  }
  else {
    if(position$row < player_position$row) {
      return ("down")
    }
    else {
      return("up")
    }
  }
} 

#
get_graphics <- function(maze_view,graph_map,direction) {
  player_position <- get_player_position(maze_view)
  nrow <- nrow(maze_view)
  ncol <- ncol(maze_view)
  graphics <- c()
  for(j in 1:ncol) {
    for (i in 1:nrow) {
      graph <- graph_map$get(maze_view[i,j])
      if (graph$orientation == "none" ) {
        
        if(maze_view[i,j] %in% c(PLAYER, GHOST, ZOMBIE,COIN_GOLD)) {
          graphics <- c(graphics, paste0("<td style='padding-top:0px;margin-top:0px;display:table-cell'>",
                                       "<div style='position:relative;height:32px;width:32px;fline-height:0px>",
                                       "<span style='position:absolute;top:0px;left:0px'>",
                                       graph_map$get(1)$block,
                                       "</span>",
                                       "<span style='position:absolute;top:0px;left:0px'>",
                                       graph$block,
                                       "</span>",
                                       "</div>",
                                       "</td>",sep="") )
        }
        else {
          graphics <- c(graphics, paste0("<td style='padding-top:0px;margin-top:0px;display:table-cell'>",graph$block, "</td>",sep=""))
        }
      }
      else if( graph$orientation == "spatial"){

        graphics <- c(graphics, paste0("<td style='padding-top:0px;margin-top:0px;display:table-cell'>",str_replace(graph$block,"ORIENTATION", direction), "</td>",sep="") )
      }
      else if(graph$orientation == "focused-on-player") {
        orientation <- get_orientation_to_player(new_position(row=i, col=j), player_position)
        
        if(maze_view[i,j] %in% c(PLAYER, GHOST, ZOMBIE)) {
          graphics <- c(graphics, paste0("<td style='padding-top:0px;margin-top:0px;display:table-cell'>",
                                         "<div style='position:relative;height:32px;width:32px;line-height:0px>",
                                         "<span style='position:absolute;top:0px;left:0px'>",
                                         graph_map$get(1)$block,
                                         "</span>",
                                         "<span style='position:absolute;top:0px;left:0px'>",
                                         str_replace(graph$block,"ORIENTATION", orientation),
                                         "</span>",
                                         "</div>",
                                         "</td>",sep="") )
        }
        else {
          graphics <- c(graphics, paste0("<td style='padding-top:0px;margin-top:0px;display:table-cell'>",graph$block, "</td>",sep=""))
        }
      }
    }
  }
  matrix(graphics, nrow, ncol)
  
}

#
rotate_clockwise <- function(x) {t( apply(x, 2, rev))}

#
what_player_can_see <- function (maze, 
                                 player_position,
                                 ghost_positions,
                                 zombie_positions,
                                 coin_gold_positions, 
                                 direction, 
                                 forward_vision = 0, 
                                 rear_vision = 0) {
  lateral_vision <- floor((forward_vision - 1)/2)
  padding <- forward_vision
  number_rot <- 0
  meta_maze <- matrix(-1,nrow(maze) + (2 * padding), ncol(maze) + (2 * padding))
  meta_maze[(1 + padding):(nrow(maze) + padding ), (1 + padding):(ncol(maze) + padding)] <- maze
  # TODO function
  for (coin_gold_position in coin_gold_positions) {
    meta_maze[coin_gold_position$row + padding,coin_gold_position$col + padding] <- COIN_GOLD
  }
  for (ghost_position in ghost_positions) {
    meta_maze[ghost_position$row + padding,ghost_position$col + padding] <- GHOST
  }
  for (zombie_position in zombie_positions) {
    meta_maze[zombie_position$row + padding,zombie_position$col + padding] <- ZOMBIE
  }
  

  if(direction == "N") {
    start_row <- player_position$row  - forward_vision
    end_row <- player_position$row + rear_vision
    start_col <- player_position$col - lateral_vision
    end_col <- player_position$col + lateral_vision 
    number_rot <- 0
  }
  else if (direction == "W") {
    start_row <- player_position$row - lateral_vision
    end_row <- player_position$row + lateral_vision 
    start_col <- player_position$col - forward_vision
    end_col <- player_position$col + rear_vision
    number_rot <- 1
  }
  else if (direction == "S") {
    start_row <- player_position$row - rear_vision
    end_row <- player_position$row + forward_vision
    start_col <- player_position$col - lateral_vision
    end_col <- player_position$col + lateral_vision 
    number_rot <- 2
  }
  else if (direction == "E") {
    start_row <- player_position$row - lateral_vision
    end_row <- player_position$row + lateral_vision
    start_col <- player_position$col - rear_vision
    end_col <- player_position$col + forward_vision
    number_rot <- 3
  }
  start_row <- start_row + padding
  end_row <- end_row + padding
  start_col <- start_col + padding
  end_col <- end_col + padding
  maze_view <- meta_maze[start_row:end_row, start_col:end_col]
  
  count_rot <- 0
  while(count_rot < number_rot)
  {
    maze_view <- rotate_clockwise(maze_view)
    count_rot <- count_rot + 1
  }

  maze_view[nrow(maze_view) - rear_vision,lateral_vision  + 1] <- PLAYER
  maze_view
}

legend <- function() {
  
  action_height <- action_map$size()
  legend_height <- graph_map$size()
  pane1_height <- legend_height
  pane1 <- matrix("", nrow = pane1_height, ncol = 1 )
  colnames(pane1) <- c("Legend")
  legend_idx <- 1
  for(stripe in graph_map$values()) {
    pane1[legend_idx,"Legend"] <- paste0( stripe$block," ", stripe$desc)
    legend_idx <- legend_idx + 1
  }
  paste(pane1,collapse="\n")
}

# actions <- function() {
#   action_height <- action_map$size()
#   pane1_height <-  action_height
#   pane1 <- matrix("", nrow = pane1_height, ncol = 1 )
#   colnames(pane1) <- c("Actions")
#   action_idx <- 1
#   for(action_value in action_map$values()) {
#     pane1[action_idx,"Actions"] <- paste0("", action_value$desc," ", paste(action_value$keys,collapse=" or "))
#     action_idx <- action_idx + 1
#   }
#   paste(pane1,collapse="\n")
# }


#
turn <- function(direction, towards) {
  curr_direction_idx <- match(direction,DIRECTIONS) # 1:0
  next_direction_idx <- switch(towards,
                              "LEFT" = curr_direction_idx - 1,
                              "RIGHT" = curr_direction_idx + 1)
  
  if (next_direction_idx == 0) {
    next_direction_idx <- 4
  }  else if (next_direction_idx == 5){
    next_direction_idx <- 1
  }
  DIRECTIONS[next_direction_idx]
}

#
play <- function(sound_map, x) {
  sound <- sound_map$get(x)
  beep(sound$beep)
}


#
get_closer_to_player <- function(maze, position_1, position_2, occupied_positions) {
   maze_layer <- matrix(0,nrow=nrow(maze),ncol=ncol(maze))
   maze_layer[(position_1$row-1):(position_1$row+1), (position_1$col-1):(position_1$col+1)] <- maze[(position_1$row-1):(position_1$row+1), (position_1$col-1):(position_1$col+1)]
   corridor <- CORRIDOR %ai% maze_layer # gets the indices for all CORRIDOR places in the around
   curr_distance <- calc_distance(position_1 = position_1, position_2 = position_2)
   for (i in 1:nrow(corridor)) {
     new_position <- new_position(row=corridor[i,]$row,col=corridor[i,]$col)
     if(has_element(occupied_positions,new_position)) 
     {
       next
     }
     new_distance <- calc_distance(new_position, position_2)
     if (new_distance < curr_distance) {
       return(new_position)
     }
   }
   position_1
}

#
remove_position_from_list <- function(position, list) {
  this_position <- position
  list %>% discard(function(x,position = this_position) {
    return(x$row == position$row && x$col == position$col)
  })
}

#
move_zombies <- function(maze, zombie_positions = list(), ghost_positions = list(), player_position) {
  new_zombie_positions <- list()
  occupied_positions <- c(zombie_positions,ghost_positions)
  for(zombie_position in zombie_positions) {
    occupied_positions <- remove_position_from_list(position = zombie_position, list = occupied_positions)
    new_zombie_position <- get_closer_to_player(maze = maze, position_1=zombie_position,position_2=player_position, occupied_positions = occupied_positions)
    new_zombie_positions <- append(new_zombie_positions,list(new_zombie_position))
    occupied_positions <- append(occupied_positions, list(new_zombie_position))
  }
  return(new_zombie_positions)
}

#
offset_point <- function(maze,point,towards,offset = 1) {
  if (towards  == "up" ) {
    if((point - offset) < 1)
    {
      new_point <- 1
    }
    else {
      new_point <- point - offset
    }
  }
  else if (towards == "down") {
    if( (point + offset) > nrow(maze))
    {
      new_point <- nrow(maze)
    }
    else {
      new_point <- point + offset
    }
  }
  else if (towards == "left") {
    if( (point - offset)  < 1)
    {
      new_point <- 1
    }
    else {
      new_point <- point - offset
    }
  }
  else if (towards == "right") {
    if( (point + offset) > ncol(maze))
    {
      new_point <- ncol(maze)
    }
    else {
      new_point <- point + offset
    }
  }
  return (new_point)
}

#
get_exit_position <- function(maze) {
  exit_idx <-EXIT %ai% maze 
  new_position(exit_idx$row, exit_idx$col)
}

#
# Gets list of positions around within the given radius
get_positions_nearby <- function(maze, this_position, radius) {
  positions <- list()
  corridor <- CORRIDOR %ai% maze
  positions <- corridor %>%
    mutate(is_nearby = apply(corridor,
                             1,
                             function(x, to_this, distance) {is_next_to(position_1 = new_position(x["row"],x["col"]), position_2 = to_this,max_distance = distance)},
                             to_this = this_position,
                             distance = radius)) %>%
    filter(is_nearby) %>% 
    apply(1, function(x) {new_position(x["row"],x["col"])})
  return (positions)
}

# Gets a random free position in a corridor
# return position: list
# * row:int
# * col:int
get_random_free_position <- function (maze, occupied_positions = list()) {
  corridor_positions <- CORRIDOR %ai% maze # gets the indices for all CORRIDOR places in the maze
  available_positions <- corridor_positions
  for(occupied in occupied_positions) {
    available_positions <- available_positions[!((occupied$row == available_positions$row) & (occupied$col == available_positions$col)),]
  }
  new_position <- available_positions[sample(1:nrow(available_positions),1),]
  return(new_position(row = new_position$row, col= new_position$col))
}

#
get_random_free_positions <- function(maze, num, occupied_positions) {
  positions <- list()
  if(num > 0) {
    for (counter in 1:num) {
      new_position <- get_random_free_position(maze=maze, occupied_positions = occupied_positions)
      positions <- append(positions, list(new_position))
      occupied_positions <- append(occupied_positions, list(new_position))
    }
  }
  return (positions)
}

#
shuffle <- function(maze, num_ghosts = 1, 
                    num_zombies = 0,
                    num_coins_gold = 5, 
                    occupied_positions = list(), 
                    radius_to_exit = 4, 
                    radius_to_player=4,
                    num_shuffles = 0) {
  player_position <- get_random_free_position(maze=maze, 
                                         occupied_positions = get_positions_nearby(
                                           maze = maze,
                                           this_position = get_exit_position(maze = maze),
                                           radius = radius_to_exit))
  if(num_shuffles <=2) {
    coin_gold_positions <- get_random_free_positions(maze=maze,
                                                    num=num_coins_gold,
                                                    occupied_positions = get_positions_nearby(
                                                      maze = maze,
                                                      this_position = player_position,
                                                      radius = radius_to_player-1))
  }
  else {
    coin_gold_positions <- list()
  }
  occupied_positions <- append(occupied_positions, 
                               get_positions_nearby(maze=maze,this_position=player_position, radius=radius_to_player))
  ghost_positions <- get_random_free_positions(maze=maze,num=num_ghosts,occupied_positions=occupied_positions)
  occupied_positions <- append(occupied_positions,ghost_positions)
  zombie_positions <- get_random_free_positions(maze=maze,num=num_zombies, occupied_positions=occupied_positions)
  player_direction <- get_random_direction()
  return (list("player_position"=player_position, 
               "ghost_positions"=ghost_positions, 
               "player_direction"=player_direction, 
               "zombie_positions"=zombie_positions,
               "coin_gold_positions"=coin_gold_positions))
}

#
check_collision_monster_player <- function(player_position, ghost_positions, zombie_positions) {
  collision <- NONE
  if (is_player_next_to_any_ghost(player_position, ghost_positions)) {
    collision <- GHOST
    echo(ghost_encounter(), sound_map,"ghost",clear = T)
  }
  else if (is_player_caught_by_any_zombie(player_position, zombie_positions)) {
    collision <- ZOMBIE
    echo(zombie_encounter(), sound_map,"zombie",clear = T)
  }
  return(collision)
}



audio_files_dir <- system.file("sounds", package = "beepr")
addResourcePath("sample_audio", audio_files_dir)
audio_files <- file.path("sample_audio", list.files(audio_files_dir, ".wav$"))


intro_audio <-"sample_audio/smb_stage_clear.wav"
new_level_audio <- "sample_audio/victory_fanfare_mono.wav"
ghost_audio <- "audio/evil_laugh.ogg.mp3"
zombie_audio <- "audio/Zombie.mp3"
coin_audio <- "audio/coin_0.ogg.mp3" 
background_audio <- "audio/In_Darkness_(CC-BY).mp3"

scene_map <- dict()
scene_map$set("intro",list("name" ="intro",
                           "sound" = list("beep" = -1,  
                                          "audio" = "",
                                          "duration" = 3),
                           "ascii" = ghost_intro(),
                           "style" = "display:inline-flex;justify-content:center;font-size:5px;background-color:white;color:black;font-family:'DroidSansMono'",
                           "invalidate" = FALSE
)
)
scene_map$set("ghost",list("name" ="ghost",
                           "sound" = list("beep" = -1,  
                                          "audio" = ghost_audio,
                                          "duration" = 3),
                           "ascii" = ghost_encounter(),
                           "style" = "display:inline-flex;justify-content:center;font-size:5px;background-color:white;color:black;font-family:'DroidSansMono'",
                           "invalidate" = TRUE
)
)
scene_map$set("zombie",list("name" ="zombie",
                            "sound" = list("beep" = -1,
                                           "audio" = zombie_audio,
                                           "duration" = 1),
                            "ascii" = zombie_encounter(),
                            "style" = "display:inline-flex;justify-content:center;font-size:2px;background-color:white;color:black;font-family:'DroidSansMono'",
                            "invalidate" = TRUE
)
)
scene_map$set("new_level",list("name" ="new_level",
                               "sound" = list("beep" = -1, 
                                              "audio" = new_level_audio,
                                              "duration" = 3),
                               "ascii" = level_up(),
                               "style" = "display:inline-flex;justify-content:center;font-size:3px;background-color:white;color:black;font-family:'DroidSansMono'",
                               "invalidate" = TRUE
)
)
scene_map$set("end",list("name" ="end",
                         "sound" = list("beep" = -1, 
                                        "audio" = new_level_audio,
                                        "duration" = 3),
                         "ascii" = game_over(),
                         "style" = "display:inline-flex;justify-content:center;font-size:6px;background-color:black;color:green;text-align=center;font-family:'DroidSansMono'",
                         "invalidate" = FALSE
)
)
scene_map$set("you_won",list("name" ="you_won",
                             "sound" = list("beep" = -1,
                                            "audio" = new_level_audio,
                                            "duration" = 3),
                             "ascii" = you_won(),
                             "style" = "display:inline-flex;justify-content;font-size:6px;background-color:black;color:green;text-align=center;font-family:'DroidSansMono'",
                             "invalidate" = FALSE
)
)

#

# Mazes
maze0_data <-            c(0,0,0,0,0,0,0,0,0,0,0,0)
maze0_data <- c(maze0_data,0,0,0,0,9,0,0,0,0,0,0,0)
maze0_data <- c(maze0_data,0,1,1,1,1,1,1,1,1,1,1,0)
maze0_data <- c(maze0_data,0,1,1,1,6,1,1,6,1,1,1,0)
maze0_data <- c(maze0_data,0,1,1,1,1,1,1,1,1,1,1,0)
maze0_data <- c(maze0_data,0,0,0,0,0,0,0,0,0,0,0,0)
maze0 = matrix(maze0_data,nrow=6,ncol=12,byrow=TRUE);

maze1_data <-            c(0,0,0,0,0,0,0,0,0,0)
maze1_data <- c(maze1_data,0,1,1,1,1,1,0,1,1,0)
maze1_data <- c(maze1_data,0,0,1,0,0,1,1,1,0,0)
maze1_data <- c(maze1_data,0,0,1,1,0,1,6,1,1,0)
maze1_data <- c(maze1_data,0,1,1,0,1,0,0,1,0,0)
maze1_data <- c(maze1_data,0,1,1,1,1,1,1,1,0,0)
maze1_data <- c(maze1_data,0,0,0,0,0,0,0,9,0,0)
maze1 = matrix(maze1_data,nrow=7,ncol=10,byrow=TRUE);

maze11_data <-             c(0,0,0,0,0,0,0,0,0,0)
maze11_data <- c(maze11_data,0,1,1,1,1,1,0,1,1,0)
maze11_data <- c(maze11_data,0,0,1,0,0,1,1,1,0,0)
maze11_data <- c(maze11_data,0,0,1,1,6,1,6,1,1,0)
maze11_data <- c(maze11_data,0,1,1,6,1,0,0,1,0,0)
maze11_data <- c(maze11_data,0,1,1,1,1,1,1,1,1,0)
maze11_data <- c(maze11_data,0,1,0,1,6,1,1,9,1,0)
maze11_data <- c(maze11_data,0,1,1,1,1,1,0,1,1,0)
maze11_data <- c(maze11_data,0,0,1,0,0,1,1,1,0,0)
maze11_data <- c(maze11_data,0,0,1,1,1,1,0,1,1,0)
maze11_data <- c(maze11_data,0,1,1,0,1,0,0,1,0,0)
maze11_data <- c(maze11_data,0,0,0,0,0,0,0,0,0,0)
maze11 = matrix(maze11_data,nrow=12,ncol=10,byrow=TRUE);

maze2_data <-            c(0,0,0,0,0,0,0,0,0,0,0,0,0)
maze2_data <- c(maze2_data,0,1,1,1,1,0,0,1,1,1,1,0,0)
maze2_data <- c(maze2_data,0,6,1,6,0,1,1,1,0,0,1,0,0)
maze2_data <- c(maze2_data,0,1,1,1,0,1,0,1,1,6,1,0,0)
maze2_data <- c(maze2_data,0,0,0,1,0,1,0,1,1,1,1,1,0)
maze2_data <- c(maze2_data,0,0,1,1,1,1,0,1,1,0,0,1,0)
maze2_data <- c(maze2_data,0,1,1,0,9,0,0,1,0,0,0,1,0)
maze2_data <- c(maze2_data,0,0,1,1,1,1,1,1,1,1,1,1,0)
maze2_data <- c(maze2_data,0,0,0,0,0,0,0,0,0,0,0,0,0)
maze2 = matrix(maze2_data,nrow=9,ncol=13,byrow=TRUE);

maze3_data <-            c(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)
maze3_data <- c(maze3_data,0,1,1,1,0,1,1,0,1,1,0,1,1,0,0)
maze3_data <- c(maze3_data,0,1,0,1,1,1,1,0,1,1,1,1,0,0,0)
maze3_data <- c(maze3_data,0,1,1,1,1,1,1,0,1,1,1,1,0,0,0)
maze3_data <- c(maze3_data,0,0,1,6,0,1,1,1,1,0,6,1,1,0,0)
maze3_data <- c(maze3_data,0,1,1,1,1,1,1,0,1,1,1,1,0,0,0)
maze3_data <- c(maze3_data,0,0,1,1,1,1,1,0,1,0,0,1,1,0,0)
maze3_data <- c(maze3_data,0,1,1,1,0,1,1,0,1,1,0,1,0,0,0)
maze3_data <- c(maze3_data,0,0,1,1,6,1,1,0,1,1,1,1,1,1,0)
maze3_data <- c(maze3_data,0,0,1,1,0,1,1,9,1,1,6,0,0,1,0)
maze3_data <- c(maze3_data,0,1,1,1,1,1,1,0,1,1,1,1,0,0,0)
maze3_data <- c(maze3_data,0,1,1,1,1,1,1,6,1,1,0,1,0,0,0)
maze3_data <- c(maze3_data,0,1,1,0,1,0,1,1,1,1,1,1,1,1,0)
maze3_data <- c(maze3_data,0,0,1,1,1,1,1,0,1,0,0,0,1,0,0)
maze3_data <- c(maze3_data,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)
maze3 = matrix(maze3_data,nrow=15,ncol=15,byrow=TRUE);

maze4_data <-            c(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)
maze4_data <- c(maze4_data,0,1,1,1,1,1,1,1,1,1,1,1,1,1,0)
maze4_data <- c(maze4_data,0,1,0,0,0,0,0,0,0,0,0,0,0,1,0)
maze4_data <- c(maze4_data,0,1,0,1,1,1,1,1,1,1,1,1,0,1,0)
maze4_data <- c(maze4_data,0,1,0,1,0,0,0,1,0,0,0,1,0,1,0)
maze4_data <- c(maze4_data,0,1,0,1,0,1,1,1,1,1,0,1,0,1,0)
maze4_data <- c(maze4_data,0,1,0,1,0,1,6,0,6,1,0,1,0,1,0)
maze4_data <- c(maze4_data,0,1,1,1,0,1,1,9,1,1,0,1,1,1,0)
maze4_data <- c(maze4_data,0,1,0,1,0,1,6,0,6,1,0,1,0,1,0)
maze4_data <- c(maze4_data,0,1,0,1,0,1,1,1,1,1,0,1,0,1,0)
maze4_data <- c(maze4_data,0,1,0,1,0,0,0,1,0,0,0,1,0,1,0)
maze4_data <- c(maze4_data,0,1,0,1,1,1,1,1,1,1,1,1,0,1,0)
maze4_data <- c(maze4_data,0,1,0,0,0,0,0,0,0,0,0,0,0,1,0)
maze4_data <- c(maze4_data,0,1,1,1,1,1,1,1,1,1,1,1,1,1,0)
maze4_data <- c(maze4_data,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)
maze4 = matrix(maze4_data,nrow=15,ncol=15,byrow=TRUE);

maze5_data <-            c(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)
maze5_data <- c(maze5_data,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0)
maze5_data <- c(maze5_data,0,1,1,1,1,1,1,1,1,1,1,1,1,1,0)
maze5_data <- c(maze5_data,0,0,1,6,1,6,1,6,1,6,1,6,1,0,0)
maze5_data <- c(maze5_data,0,1,1,1,1,1,1,1,1,1,1,1,1,1,0)
maze5_data <- c(maze5_data,0,1,6,1,6,1,6,1,6,1,6,1,6,1,0)
maze5_data <- c(maze5_data,0,1,1,1,1,1,1,1,1,1,1,1,1,1,0)
maze5_data <- c(maze5_data,0,0,1,6,1,6,1,6,1,6,1,6,1,0,0)
maze5_data <- c(maze5_data,0,1,1,1,1,1,1,9,1,1,1,1,1,1,0)
maze5_data <- c(maze5_data,0,1,6,1,6,1,6,1,6,1,6,1,0,1,0)
maze5_data <- c(maze5_data,0,1,1,1,1,1,1,1,1,1,1,1,1,1,0)
maze5_data <- c(maze5_data,0,0,1,6,1,6,1,6,1,6,1,6,1,0,0)
maze5_data <- c(maze5_data,0,1,1,1,1,1,1,1,1,1,1,1,1,1,0)
maze5_data <- c(maze5_data,0,1,6,1,6,1,6,1,6,1,6,1,0,1,0)
maze5_data <- c(maze5_data,0,1,1,1,1,1,1,1,1,1,1,1,1,1,0)
maze5_data <- c(maze5_data,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)
maze5 = matrix(maze5_data,nrow=16,ncol=15,byrow=TRUE);

GHOST_SEC_TO_MOVE <- 2
ZOMBIE_SEC_TO_MOVE <- 2

# Game level map
game_level_map <- dict()
game_level_map$set("level1",list(
  "name"="1",
  "maze"=maze1,
  "num_ghosts"= 3,
  "ghost_speed"=GHOST_SEC_TO_MOVE,
  "num_zombies"=0,
  "zombie_speed"=ZOMBIE_SEC_TO_MOVE,
  "num_coins_gold"= floor(dim(CORRIDOR %ai% maze1)[1] * 0.2),
  "forward_vision"= 6,
  "rear_vision"= 1,
  "radius_to_exit"=5
))
game_level_map$set("level2",list(
  "name"="2",
  "maze"=maze11,
  "num_ghosts"= 3,
  "ghost_speed"=GHOST_SEC_TO_MOVE,
  "num_zombies"=1,
  "zombie_speed"=ZOMBIE_SEC_TO_MOVE,
  "num_coins_gold"= floor(dim(CORRIDOR %ai% maze11)[1] * 0.2),
  "forward_vision"=6,
  "rear_vision"=1,
  "radius_to_exit"=5
))
game_level_map$set("level3",list(
  "name"="3",
  "maze"=maze11,
  "num_ghosts"=3,
  "ghost_speed"=GHOST_SEC_TO_MOVE,
  "num_zombies"=2,
  "zombie_speed"=ZOMBIE_SEC_TO_MOVE,
  "num_coins_gold"= floor(dim(CORRIDOR %ai% maze11)[1] * 0.2),
  "forward_vision"=6,
  "rear_vision"=1,
  "radius_to_exit"=5
))
game_level_map$set("level4",list(
  "name"="4",
  "maze"=maze0,
  "num_ghosts"=3,
  "ghost_speed"=GHOST_SEC_TO_MOVE,
  "num_zombies"=1,
  "zombie_speed"=ZOMBIE_SEC_TO_MOVE,
  "num_coins_gold"=floor(dim(CORRIDOR %ai% maze0)[1] * 0.2),
  "forward_vision"=6,
  "rear_vision"=1,
  "radius_to_exit"=5
))
game_level_map$set("level5",list(
  "name"="5",
  "maze"=maze2,
  "num_ghosts"=3,
  "ghost_speed"=GHOST_SEC_TO_MOVE,
  "num_zombies"=2,
  "zombie_speed"=ZOMBIE_SEC_TO_MOVE,
  "num_coins_gold"= floor(dim(CORRIDOR %ai% maze2)[1] * 0.2),
  "forward_vision"=5,
  "rear_vision"=1,
  "radius_to_exit"=5
))
game_level_map$set("level6",list(
  "name"="6",
  "maze"= maze2,
  "num_ghosts"=4,
  "ghost_speed"=GHOST_SEC_TO_MOVE,
  "num_zombies"=3,
  "zombie_speed"=ZOMBIE_SEC_TO_MOVE,
  "num_coins_gold"= floor(dim(CORRIDOR %ai% maze2)[1] * 0.2),
  "forward_vision"=5,
  "rear_vision"=1,
  "radius_to_exit"=3
))
game_level_map$set("level7",list(
  "name"="7",
  "maze"=maze3,
  "num_ghosts"=5,
  "ghost_speed"=GHOST_SEC_TO_MOVE,
  "num_zombies"=3,
  "zombie_speed"=ZOMBIE_SEC_TO_MOVE,
  "num_coins_gold"= floor(dim(CORRIDOR %ai% maze3)[1] * 0.2),
  "forward_vision"=5,
  "rear_vision"=1,
  "radius_to_exit"=5
))
game_level_map$set("level8",list(
  "name"="8",
  "maze"=maze4,
  "num_ghosts"=4,
  "ghost_speed"=GHOST_SEC_TO_MOVE,
  "num_zombies"=4,
  "zombie_speed"=ZOMBIE_SEC_TO_MOVE,
  "num_coins_gold"= floor(dim(CORRIDOR %ai% maze4)[1] * 0.2),
  "forward_vision"=5,
  "rear_vision"=1,
  "radius_to_exit"=6
))
game_level_map$set("level9",list(
  "name"="9",
  "maze"=maze5,
  "num_ghosts"=4,
  "ghost_speed"=GHOST_SEC_TO_MOVE,
  "num_zombies"=5,
  "zombie_speed"=ZOMBIE_SEC_TO_MOVE,
  "num_coins_gold"=floor(dim(CORRIDOR %ai% maze5)[1] * 0.2),
  "forward_vision"=5,
  "rear_vision"=1,
  "radius_to_exit"=5
))

#
build_players_view <- function(maze,
                               player_position,
                               ghost_positions,
                               zombie_positions,
                               coin_gold_positions,
                               player_direction, 
                               forward_vision, 
                               rear_vision) {
  
  maze_view <- what_player_can_see(maze = maze,
                                   player_position = player_position, 
                                   ghost_positions = ghost_positions, 
                                   zombie_positions = zombie_positions,
                                   coin_gold_positions = coin_gold_positions,
                                   direction = player_direction,
                                   forward_vision = forward_vision,
                                   rear_vision  = rear_vision)
  view = get_graphics(maze_view,graph_map, player_direction)
  map_height <- nrow(view)
  pane2_height <- map_height + 3
  pane2 <- matrix("", nrow = pane2_height, ncol = 1 )
  colnames(pane2) <- c("Map")
  map_idx <- 1
  pane2[map_idx,"Map"] <- '<table style="border-spacing:0;border-collapse:collapse;line-height:0em;background-color:black;color:black;" border="0" borderspacing="0">'
  map_idx <- map_idx + 1
  for (line in apply(view, 1, paste, collapse = "")) {
    pane2[map_idx,"Map"] <- paste0('<tr style="padding:0;margin:0px;height:32px;">',line,'</tr>')
    map_idx <- map_idx + 1
  }
  pane2[map_idx,"Map"] <- '</table>'
  return(paste(pane2,collapse=""))
}



