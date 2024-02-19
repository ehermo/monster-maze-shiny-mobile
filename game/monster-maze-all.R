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
library(glue)
library(logger)

source("game/ascii_art.R")
source("game/levels.R")

# Graph map
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
graph_map$set(ZOMBIE2,   list(
  "block"="<img src=\"zombie2_ORIENTATION.gif\" height=32, width=32>",
  "desc"="zombie2", 
  "orientation"="focused-on-player"))
graph_map$set(HOSTAGE,   list(
  "block"="<img src=\"hostage.gif\" height=32, width=32>",
  "desc"="hostage", 
  "orientation"="none"))

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
has_found <- function(interesting_positions, position) {
  return (interesting_positions %>% has_element(position))
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

  if(isTRUE(distance > max_distance)) {
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

#
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
        
        if(maze_view[i,j] %in% c(PLAYER, GHOST, ZOMBIE, ZOMBIE2, HOSTAGE,COIN_GOLD)) {
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
        
        if(maze_view[i,j] %in% c(PLAYER, GHOST, ZOMBIE, ZOMBIE2)) {
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
                                 zombie2_positions,
                                 hostage_positions,
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
  for (zombie2_position in zombie2_positions) {
    meta_maze[zombie2_position$row + padding,zombie2_position$col + padding] <- ZOMBIE2
  }
  for (hostage_position in hostage_positions) {
    meta_maze[hostage_position$row + padding,hostage_position$col + padding] <- HOSTAGE
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
move_zombies <- function(maze, 
                         zombie_positions = list(),
                         other_positions = list(),
                         player_position) {
  new_zombie_positions <- list()
  occupied_positions <- append(zombie_positions,other_positions)
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
  if(nrow(available_positions) > 0) {
    new_position_df <- available_positions[sample(1:nrow(available_positions),1),]
    result <- new_position(row = new_position_df$row, col= new_position_df$col)
  }
  else {
    log_warn("Null free position this should never happend.")
    result <- new_position(row=NULL, col=NULL)
  }
  return(result)
}

#
get_random_free_positions <- function(maze, num, occupied_positions, distance=2) {
  positions <- list()
  occupied <- occupied_positions
  if(num > 0) {
    for (counter in 1:num) {
      new_position <- get_random_free_position(maze=maze, occupied_positions = occupied)
      positions <- append(positions, list(new_position))
      occupied <- append(occupied, get_positions_nearby(
        maze = maze,
        this_position = new_position,
        radius = distance)
        )
    }
  }
  return (positions)
}

#
shuffle <- function(maze, num_ghosts = 1, 
                    num_zombies = 0,
                    num_zombies2 = 0,
                    num_hostages = 0,
                    num_coins_gold = 5, 
                    occupied_positions = list(), 
                    radius_to_exit = 4, 
                    radius_to_player=4,
                    num_shuffles = 0) {
  
  exit_position <- get_exit_position(maze = maze)
  player_position <- get_random_free_position(maze=maze, 
                                         occupied_positions = append(occupied_positions,get_positions_nearby(
                                           maze = maze,
                                           this_position = exit_position,
                                           radius = radius_to_exit)))
  if(num_shuffles <1) {
    coin_gold_positions <- get_random_free_positions(maze=maze,
                                                    num=num_coins_gold,
                                                    occupied_positions = get_positions_nearby(
                                                      maze = maze,
                                                      this_position = player_position,
                                                      radius = radius_to_player-1))
    hostage_positions <- get_random_free_positions(maze=maze,
                                                     num=num_hostages,
                                                     occupied_positions = append(append(coin_gold_positions,
                                                                                 get_positions_nearby(
                                                                                   maze = maze,
                                                                                   this_position = player_position,
                                                                                   radius = 3)),
                                                                                 get_positions_nearby(
                                                                                   maze = maze,
                                                                                   this_position = exit_position,
                                                                                   radius = 3
                                                                                   
                                                                                 ))
                                                   ,distance=3)
  }
  else {
    coin_gold_positions <- list()
    hostage_positions <- list()
  }
  occupied_positions <- append(occupied_positions, 
                               get_positions_nearby(maze=maze,
                                                    this_position=player_position,
                                                    radius=radius_to_player))
  ghost_positions <- get_random_free_positions(maze=maze,
                                               num=num_ghosts,
                                               occupied_positions=occupied_positions)
  occupied_positions <- append(occupied_positions,ghost_positions)
  zombie_positions <- get_random_free_positions(maze=maze,
                                                num=num_zombies, 
                                                occupied_positions=occupied_positions)
  occupied_positions <- append(occupied_positions,zombie_positions)
  zombie2_positions <- get_random_free_positions(maze=maze,
                                                num=num_zombies2, 
                                                occupied_positions=occupied_positions)
  player_direction <- get_random_direction()
  return (list("player_position"=player_position, 
               "ghost_positions"=ghost_positions, 
               "player_direction"=player_direction, 
               "zombie_positions"=zombie_positions,
               "zombie2_positions"=zombie2_positions,
               "hostage_positions"=hostage_positions,
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


# audios
audio_files_dir <- system.file("sounds", package = "beepr")
addResourcePath("sample_audio", audio_files_dir)
audio_files <- file.path("sample_audio", list.files(audio_files_dir, ".wav$"))


intro_audio <-"sample_audio/smb_stage_clear.wav"
new_level_audio <- "sample_audio/victory_fanfare_mono.wav"
ghost_audio <- "audio/evil_laugh.ogg.mp3"
zombie_audio <- "audio/Zombie.mp3"
coin_audio <- "audio/coin_0.ogg.mp3" 
rescue_audio <- "audio/Accept.mp3" 
background_audio <- "audio/In_Darkness_(CC-BY).mp3"
win_audio <- "audio/win_sound.mp3"
scene_map <- dict()
scene_map$set("intro",list("name" ="intro",
                           "sound" = list("beep" = -1,  
                                          "audio" = "",
                                          "duration" = 3),
                           "ascii" = ghost_intro(),
                           "style" = "display:inline-flex;justify-content:center;font-size:5px;background-color:#D7D5D2;color:black;font-family:'DroidSansMono'",
                           "invalidate" = FALSE
)
)
scene_map$set("ghost",list("name" ="ghost",
                           "sound" = list("beep" = -1,  
                                          "audio" = ghost_audio,
                                          "duration" = 3),
                           "ascii" = ghost_encounter(),
                           "style" = "display:inline-flex;justify-content:center;font-size:5px;background-color:#D7D5D2;color:black;font-family:'DroidSansMono'",
                           "invalidate" = TRUE
)
)
scene_map$set("zombie",list("name" ="zombie",
                            "sound" = list("beep" = -1,
                                           "audio" = zombie_audio,
                                           "duration" = 1),
                            "ascii" = zombie_encounter(),
                            "style" = "display:inline-flex;justify-content:center;font-size:2px;background-color:#D7D5D2;;color:black;font-family:'DroidSansMono'",
                            "invalidate" = TRUE
)
)
scene_map$set("new_level",list("name" ="win",
                               "sound" = list("beep" = -1, 
                                              "audio" = win_audio,
                                              "duration" = 1),
                               "ascii" = level_up(),
                               "style" = "display:inline-flex;justify-content:center;font-size:3px;background-color:#D7D5D2;;color:black;font-family:'DroidSansMono'",
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
build_players_view <- function(maze,
                               player_position,
                               ghost_positions,
                               zombie_positions,
                               zombie2_positions,
                               hostage_positions,
                               coin_gold_positions,
                               player_direction, 
                               forward_vision, 
                               rear_vision) {
  
  maze_view <- what_player_can_see(maze = maze,
                                   player_position = player_position, 
                                   ghost_positions = ghost_positions, 
                                   zombie_positions = zombie_positions,
                                   zombie2_positions = zombie2_positions,
                                   hostage_positions = hostage_positions,
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



