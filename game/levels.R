source("game/mazes.R")
source("game/constants.R")

# Game level map
game_level_map <- dict()
game_level_map$set("level1",list(
  "name"="1",
  "maze"=maze1,
  "num_ghosts"= 2,
  "ghost_speed"=GHOST_SEC_TO_MOVE,
  "num_zombies"=0,
  "num_zombies2"=0,
  "num_hostages"=1,
  "zombie_speed"=ZOMBIE_SEC_TO_MOVE,
  "num_coins_gold"= floor(dim(CORRIDOR %ai% maze1)[1] * 0.1),
  "forward_vision"= 6,
  "rear_vision"= 1,
  "radius_to_player"=4,
  "radius_to_exit"=5
))
game_level_map$set("level2",list(
  "name"="2",
  "maze"=maze11,
  "num_ghosts"= 3,
  "ghost_speed"=GHOST_SEC_TO_MOVE,
  "num_zombies"=1,
  "num_zombies2"=0,
  "num_hostages"=1,
  "zombie_speed"=ZOMBIE_SEC_TO_MOVE,
  "num_coins_gold"= floor(dim(CORRIDOR %ai% maze11)[1] * 0.1),
  "forward_vision"=6,
  "rear_vision"=1,
  "radius_to_player"=4,
  "radius_to_exit"=5
))
game_level_map$set("level3",list(
  "name"="3",
  "maze"=maze111,
  "num_ghosts"=3,
  "ghost_speed"=GHOST_SEC_TO_MOVE,
  "num_zombies"=2,
  "num_zombies2"=0,
  "num_hostages"=2,
  "zombie_speed"=ZOMBIE_SEC_TO_MOVE,
  "num_coins_gold"= floor(dim(CORRIDOR %ai% maze11)[1] * 0.1),
  "forward_vision"=6,
  "rear_vision"=1,
  "radius_to_player"=4,
  "radius_to_exit"=5
))
game_level_map$set("level4",list(
  "name"="4",
  "maze"=maze0,
  "num_ghosts"=1,
  "ghost_speed"=GHOST_SEC_TO_MOVE,
  "num_zombies"=1,
  "num_zombies2"=0,
  "num_hostages"=0,
  "zombie_speed"=ZOMBIE_SEC_TO_MOVE,
  "num_coins_gold"=floor(dim(CORRIDOR %ai% maze0)[1] * 0.1),
  "forward_vision"=6,
  "rear_vision"=1,
  "radius_to_player"=2,
  "radius_to_exit"=4
))
game_level_map$set("level5",list(
  "name"="5",
  "maze"=maze2,
  "num_ghosts"=3,
  "ghost_speed"=GHOST_SEC_TO_MOVE,
  "num_zombies"=1,
  "num_zombies2"=1,
  "num_hostages"=2,
  "zombie_speed"=ZOMBIE_SEC_TO_MOVE,
  "num_coins_gold"= floor(dim(CORRIDOR %ai% maze2)[1] * 0.1),
  "forward_vision"=5,
  "rear_vision"=1,
  "radius_to_player"=4,
  "radius_to_exit"=5
))
game_level_map$set("level6",list(
  "name"="6",
  "maze"= maze21,
  "num_ghosts"=4,
  "ghost_speed"=GHOST_SEC_TO_MOVE,
  "num_zombies"=2,
  "num_zombies2"=2,
  "num_hostages"=2,
  "zombie_speed"=ZOMBIE_SEC_TO_MOVE,
  "num_coins_gold"= floor(dim(CORRIDOR %ai% maze21)[1] * 0.1),
  "forward_vision"=5,
  "rear_vision"=1,
  "radius_to_player"=4,
  "radius_to_exit"=3
))
game_level_map$set("level7",list(
  "name"="7",
  "maze"=maze3,
  "num_ghosts"=5,
  "ghost_speed"=GHOST_SEC_TO_MOVE,
  "num_zombies"=3,
  "num_zombies2"=0,
  "num_hostages"=2,
  "zombie_speed"=ZOMBIE_SEC_TO_MOVE,
  "num_coins_gold"= floor(dim(CORRIDOR %ai% maze3)[1] * 0.1),
  "forward_vision"=5,
  "rear_vision"=1,
  "radius_to_player"=3,
  "radius_to_exit"=5
))
game_level_map$set("level8",list(
  "name"="8",
  "maze"=maze4,
  "num_ghosts"=4,
  "ghost_speed"=GHOST_SEC_TO_MOVE,
  "num_zombies"=4,
  "num_zombies2"=0,
  "num_hostages"=2,
  "zombie_speed"=ZOMBIE_SEC_TO_MOVE,
  "num_coins_gold"= floor(dim(CORRIDOR %ai% maze4)[1] * 0.1),
  "forward_vision"=5,
  "rear_vision"=1,
  "radius_to_player"=3,
  "radius_to_exit"=6
))
game_level_map$set("level9",list(
  "name"="9",
  "maze"=maze5,
  "num_ghosts"=4,
  "ghost_speed"=GHOST_SEC_TO_MOVE,
  "num_zombies"=5,
  "num_zombies2"=0,
  "num_hostages"=3,
  "zombie_speed"=ZOMBIE_SEC_TO_MOVE,
  "num_coins_gold"=floor(dim(CORRIDOR %ai% maze5)[1] * 0.2),
  "forward_vision"=5,
  "rear_vision"=1,
  "radius_to_player"=1,
  "radius_to_exit"=5
))
