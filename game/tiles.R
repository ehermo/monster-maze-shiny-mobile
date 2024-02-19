library(magick)

# tiles <- image_read("game/basictiles.png")
# wall<- image_crop(tiles,"16x16+16+144")
# print(wall)
# image_write(wall,"www/wall.png")

# tiles <- image_read("game/basictiles.png")
# 
# path <- image_crop(tiles,"16x16+32+16")
# 
# print(path)
# image_write(path,"www/path.png")
# 
# tiles <- image_read("game/characters.png")
# char<- image_crop(tiles,"16x16+64+48")
# print(char)
# image_write(char,"www/char.png")
# 
# tiles <- image_read("game/characters.png")
# ghost <- image_crop(tiles,"16x16+112+64")
# print(ghost)
# image_write(ghost,"www/ghost.png")
# 
# tiles <- image_read("game/characters.png")
# ghost_1 <- image_crop(tiles,"16x16+98+64")
# print(ghost_1)
# ghost_2 <- image_crop(tiles,"16x16+112+64")
# print(ghost_2)
# ghost_3 <- image_crop(tiles,"16x16+128+64")
# print(ghost_3)
# 
# ghost_ani <- image_animate(image_composite(path,c(ghost_1,ghost_2,ghost_3)), fps=4, dispose="background")
# ghost_ani
# image_write(ghost_ani, "www/ghost.gif")
# 
# 
# 
# image_write(ghost,"www/ghost.png")
# 
# 
# 
# tiles <- image_read("game/characters.png")
# char1 <- image_crop(tiles,"16x16+48+48")
# print(char1)
# char2 <- image_crop(tiles,"16x16+64+48")
# print(char2)
# char3 <- image_crop(tiles,"16x16+80+48")
# print(char3)
# char_ani <- image_animate(image_composite(path,c(char1,char2,char3)), fps=4, loop=0, dispose="background")
# char_ani
# image_write(char_ani,"www/char.gif")


tiles <- image_read("game/dungeon.png")
path <- image_crop(tiles,"32x32+96+64")
path
image_write(path, "www/path2.png")

# tiles <- image_read("game/characters.png")
# char1 <- image_crop(tiles,"16x16+48+32")
# print(char1)
# char2 <- image_crop(tiles,"16x16+64+32")
# print(char2)
# char3 <- image_crop(tiles,"16x16+80+32")
# print(char3)
# char_ani <- image_animate(image_composite(path,c(char1,char2,char3)), fps=4, loop=0, dispose="background")
# char_ani
# image_write(char_ani,"www/char_right.gif")

# 
# tiles <- image_read("game/characters.png")
# print(tiles)
# zombie <- image_crop(tiles,"16x16+160")
# print(zombie)
# image_write(zombie,"www/zombie.png")
# 
# 
# tiles <- image_read("game/characters.png")
# print(tiles)
# zombie11 <- image_crop(tiles,"16x16+144")
# print(zombie1)
# zombie21 <- image_crop(tiles,"16x16+160")
# print(zombie2)
# zombie31 <- image_crop(tiles,"16x16+176")
# print(zombie3)
# zombie12 <- image_crop(tiles,"16x16+144+16")
# print(zombie12)
# zombie22 <- image_crop(tiles,"16x16+160+16")
# print(zombie22)
# zombie32 <- image_crop(tiles,"16x16+176+16")
# print(zombie32)
# zombie13 <- image_crop(tiles,"16x16+144+32")
# print(zombie13)
# zombie23 <- image_crop(tiles,"16x16+160+32")
# print(zombie23)
# zombie33 <- image_crop(tiles,"16x16+176+32")
# print(zombie33)
# 
# zombie_ani <- image_animate(image_composite(path,c(zombie11,zombie12,zombie22,zombie13,zombie21,zombie23,zombie31,zombie32,zombie33)), fps=1, loop=0, dispose="background")
# zombie_ani
# 
# image_write(zombie_ani,"www/zombie.gif")


# tiles <- image_read("game/things.png")
# print(tiles)
# exit <- image_crop(tiles,"16x16+32+80")
# print(exit)
# image_write(exit,"www/exit.png")



# tiles <- image_read("game/things.png")
# print(tiles)
# exit1 <- image_crop(tiles,"16x16+0+80")
# print(exit1)
# exit2 <- image_crop(tiles,"16x16+16+80")
# print(exit2)
# exit3 <- image_crop(tiles,"16x16+32+80")
# print(exit3)
# exit_ani <- image_animate(image_composite(path,c(exit1,exit2,exit3)), fps=4, loop=0, dispose="background")
# exit_ani
# image_write(exit_ani,"www/exit.gif")

library(magick)



tiles <- image_read("game/dungeon.png")
tiles
# z1 <- image_crop(tiles,"32x32")
# print(z1)
# z2 <- image_crop(tiles,"32x32+32")
# print(z2)
# 
# print(image_crop(tiles,"32x32+160+128"))
# out <- image_crop(tiles,"32x32+160+128")
# image_write(out, "www/out.png")

path <- image_crop(tiles,"32x32+32+32")
path
image_write(path, "www/path2.png")
wallcenter <- image_crop(tiles,"32x32+96+0")
image_write(wallcenter,"www/wall2.png")

#Zombies
tiles <- image_read("game/5ZombieSpriteSheet.png")
tiles
z1 <- image_scale(image_crop(tiles,"36x36+0"),"32x32")
print(z1)
z2 <- image_scale(image_crop(tiles,"36x36+44"),"32x32")
print(z2)
z3 <- image_scale(image_crop(tiles,"36x36+90"),"32x32")
print(z3)

zombie_ani <- image_animate(c(z1,z2,z3), fps=4, dispose="background")
zombie_ani
image_write(zombie_ani, "www/zombie_down.gif")

tiles <- image_read("game/5ZombieSpriteSheet.png")
tiles
z1 <- image_scale(image_crop(tiles,"36x36+0+36"),"32x32")
print(z1)
z2 <- image_scale(image_crop(tiles,"36x36+44+36"),"32x32")
print(z2)
z3 <- image_scale(image_crop(tiles,"36x36+90+36"),"32x32")
print(z3)

zombie_ani <- image_animate(c(z1,z2,z3), fps=4, dispose="background")
zombie_ani
image_write(zombie_ani, "www/zombie_right.gif")

tiles <- image_read("game/5ZombieSpriteSheet.png")
tiles
z1 <- image_scale(image_crop(tiles,"36x36+0+72"),"32x32")
print(z1)
z2 <- image_scale(image_crop(tiles,"36x36+44+72"),"32x32")
print(z2)
z3 <- image_scale(image_crop(tiles,"36x36+90+72"),"32x32")
print(z3)

zombie_ani <- image_animate(c(z1,z2,z3), fps=4, dispose="background")
zombie_ani
image_write(zombie_ani, "www/zombie_up.gif")

tiles <- image_read("game/5ZombieSpriteSheet.png")
tiles
z1 <- image_scale(image_crop(tiles,"36x36+0+108"),"32x32")
print(z1)
z2 <- image_scale(image_crop(tiles,"36x36+44+108"),"32x32")
print(z2)
z3 <- image_scale(image_crop(tiles,"36x36+90+108"),"32x32")
print(z3)

zombie_ani <- image_animate(c(z1,z2,z3), fps=4, dispose="background")
zombie_ani
image_write(zombie_ani, "www/zombie_left.gif")

#Zombie2
tiles <- image_read("game/3ZombieSpriteSheet.png")
tiles
z1 <- image_scale(image_crop(tiles,"36x36+0"),"32x32")
print(z1)
z2 <- image_scale(image_crop(tiles,"36x36+44"),"32x32")
print(z2)
z3 <- image_scale(image_crop(tiles,"36x36+90"),"32x32")
print(z3)

zombie_ani <- image_animate(c(z1,z2,z3), fps=2, dispose="background")
zombie_ani
image_write(zombie_ani, "www/zombie2_down.gif")

z1 <- image_scale(image_crop(tiles,"36x36+0+36"),"32x32")
print(z1)
z2 <- image_scale(image_crop(tiles,"36x36+44+36"),"32x32")
print(z2)
z3 <- image_scale(image_crop(tiles,"36x36+90+36"),"32x32")
print(z3)

zombie_ani <- image_animate(c(z1,z2,z3), fps=2,dispose="previous")
zombie_ani
image_write(zombie_ani, "www/zombie2_right.gif")

z1 <- image_scale(image_crop(tiles,"36x36+0+72"),"32x32")
print(z1)
z2 <- image_scale(image_crop(tiles,"36x36+44+72"),"32x32")
print(z2)
z3 <- image_scale(image_crop(tiles,"36x36+90+72"),"32x32")
print(z3)

zombie_ani <- image_animate(c(z1,z2,z3), fps=2, dispose="background")
zombie_ani
image_write(zombie_ani, "www/zombie2_up.gif")

z1 <- image_scale(image_crop(tiles,"36x36+0+108"),"32x32")
print(z1)
z2 <- image_scale(image_crop(tiles,"36x36+44+108"),"32x32")
print(z2)
z3 <- image_scale(image_crop(tiles,"36x36+90+108"),"32x32")
print(z3)

zombie_ani <- image_animate(c(z1,z2,z3), fps=2, dispose="background")
zombie_ani
image_write(zombie_ani, "www/zombie2_left.gif")


tiles <- image_read("game/characters.png")
char1 <- image_scale(image_crop(tiles,"16x16+48+48"),"32x32")
print(char1)
char2 <- image_scale(image_crop(tiles,"16x16+64+48"),"32x32")
print(char2)
char3 <- image_scale(image_crop(tiles,"16x16+80+48"),"32x32")
print(char3)
char_ani <- image_animate(c(char1,char2,char3, char2), fps=4, loop=1, dispose="background")
char_ani
image_write(char_ani,"www/char_walking.gif")


tiles <- image_read("game/characters.png")
char1 <- image_scale(image_crop(tiles,"16x16+48+48"),"32x32")
print(char1)
char2 <- image_scale(image_crop(tiles,"16x16+64+48"),"32x32")
print(char2)
char3 <- image_scale(image_crop(tiles,"16x16+80+48"),"32x32")
print(char3)
char_ani <- image_animate(c(char1,char2,char3, char2), fps=4, loop=0, dispose="background")
char_ani
image_write(char_ani,"www/char.gif")


tiles <- image_read("game/characters.png")
char1 <- image_scale(image_crop(tiles,"16x16+48+32"),"32x32")
print(char1)
char2 <- image_scale(image_crop(tiles,"16x16+64+32"),"32x32")
print(char2)
char3 <- image_scale(image_crop(tiles,"16x16+80+32"),"32x32")
print(char3)
char_ani <- image_animate(c(char1,char2,char3), fps=4, loop=0, dispose="background")
char_ani
image_write(char_ani,"www/char_right.gif")


tiles <- image_read("game/characters.png")
char1 <- image_scale(image_crop(tiles,"16x16+64+48"),"32x32")
print(char1)
char2 <- image_scale(image_crop(tiles,"16x16+80+48"),"32x32")
print(char2)
char3 <- image_scale(image_crop(tiles,"16x16+80+32"),"32x32")
print(char3)
char4 <- image_scale(image_crop(tiles,"16x16+64+32"),"32x32")
char_ani <- image_animate(c(char1,char2,char3,char4), fps=4, loop=1, dispose="background")
char_ani
image_write(char_ani,"www/turning_right.gif")

tiles <- image_read("game/characters.png")
tiles
char1 <- image_scale(image_crop(tiles,"16x16+112+0"),"32x32")
print(char1)
char2 <- image_scale(image_crop(tiles,"16x16+128+0"),"32x32")
print(char2)
char3 <- image_scale(image_crop(tiles,"16x16+96+16"),"32x32")
print(char3)
char4 <- image_scale(image_crop(tiles,"16x16+96+0"),"32x32")
print(char4)
char5 <- image_scale(image_crop(tiles,"16x16+128+32"),"32x32")
print(char5)
char_ani <- image_animate(c(char1,char3,char1,char5), fps=1, loop=0, dispose="background")
char_ani
image_write(char_ani,"www/hostage.gif")


#Hostage

tiles <- image_read("game/characters.png")
tiles

char1 <- image_scale(image_crop(tiles,"16x16+64+48"),"32x32")
print(char1)
char2 <- image_scale(image_crop(tiles,"16x16+80+48"),"32x32")
print(char2)
char3 <- image_scale(image_crop(tiles,"16x16+80+32"),"32x32")
print(char3)
char4 <- image_scale(image_crop(tiles,"16x16+64+32"),"32x32")
char_ani <- image_animate(c(char1,char2,char3,char4), fps=4, loop=1, dispose="background")
char_ani
image_write(char_ani,"www/turning_right.gif")

tiles <- image_read("game/things.png")
exit1 <- image_scale(image_crop(tiles,"16x16+0+80"),"32x32")
print(exit1)
exit2 <- image_scale(image_crop(tiles,"16x16+16+80"),"32x32")
print(exit2)
exit3 <- image_scale(image_crop(tiles,"16x16+32+80"),"32x32")
print(exit3)
exit_ani <- image_animate(image_composite(path,c(exit1,exit2,exit3)), fps=4, loop=0, dispose="background")
exit_ani
image_write(exit_ani,"www/exit.gif")

tiles <- image_read("game/characters.png")
ghost_1 <- image_scale(image_crop(tiles,"16x16+98+64"),"32x32")
print(ghost_1)
ghost_2 <- image_scale(image_crop(tiles,"16x16+112+64"),"32x32")
print(ghost_2)
ghost_3 <- image_scale(image_crop(tiles,"16x16+128+64"),"32x32")
print(ghost_3)

ghost_ani <- image_animate(c(ghost_1,ghost_2,ghost_3), fps=4, dispose="background")
ghost_ani
image_write(ghost_ani, "www/ghost.gif")


# tiles <- image_read("game/dungeon.png")
# wall1 <- image_crop(tiles,"32x32+96+0")
# wall1
# image_write(wall1,"www/wallTop_N.png")
# image_write(wall1,"www/wallRight_E.png")
# image_write(wall1,"www/wallDown_S.png")
# image_write(wall1,"www/wallLeft_W.png")
# 
# wall2 <- image_rotate(wall1,90)
# wall2
# image_write(wall2,"www/wallTop_E.png")
# image_write(wall2,"www/wallRight_S.png")
# image_write(wall2,"www/wallDown_W.png")
# image_write(wall2,"www/wallLeft_N.png")
# 
# wall3 <- image_rotate(wall2,90)
# wall3
# image_write(wall3,"www/wallTop_S.png")
# image_write(wall3,"www/wallRight_W.png")
# image_write(wall3,"www/wallDown_N.png")
# image_write(wall3,"www/wallLeft_E.png")
# 
# wall4 <- image_rotate(wall3,90)
# wall4
# image_write(wall4,"www/wallTop_W.png")
# image_write(wall4,"www/wallRight_N.png")
# image_write(wall4,"www/wallDown_E.png")
# image_write(wall4,"www/wallLeft_S.png")
# 

# Mazes
maze0_data <-            c(0,0,0,0,0,0,0,0,0,0,0,0)
maze0_data <- c(maze0_data,4,6,6,6,9,6,6,6,6,6,6,7)
maze0_data <- c(maze0_data,4,1,1,1,1,1,1,1,1,1,1,7)
maze0_data <- c(maze0_data,4,1,1,1,0,1,1,0,1,1,1,7)
maze0_data <- c(maze0_data,4,1,1,1,1,1,1,1,1,1,1,7)
maze0_data <- c(maze0_data,4,8,8,8,8,8,8,8,8,8,8,7)
maze0 = matrix(maze0_data,nrow=6,ncol=12,byrow=TRUE);


#tiles <- image_read("game/dungeon.png")
#path <- image_crop(tiles,"32x32+96+64")

tiles <- image_read("game/coin.png")
tiles
coin1 <- image_scale(image_crop(tiles,"16x16+0+0"),"32x32")
coin2 <- image_scale(image_crop(tiles,"16x16+16+0"),"32x32")
coin3 <- image_scale(image_crop(tiles,"16x16+32+0"),"32x32")
coin4 <- image_scale(image_crop(tiles,"16x16+48+0"),"32x32")
coin5 <- image_scale(image_crop(tiles,"16x16+64+0"),"32x32")
coin6 <- image_scale(image_crop(tiles,"16x16+80+0"),"32x32")
coin7 <- image_scale(image_crop(tiles,"16x16+66+0"),"32x32")

coin_ani <- image_animate(c(coin1,coin2,coin3,coin4,coin5,coin6, coin7), fps=10, dispose="background")
coin_ani
image_write(coin_ani,"www/coin_gold.gif")


tiles <- image_read("game/basictiles.png")

col1 <- image_composite(path,image_scale(image_crop(tiles,"16x16+112+64"),"32x32"))
print(col1)
image_write(col1,"www/col.png")




print(image_scale(image_read("www/wallTop_N.png"), "384x32!"))

#map <- c()
map<-c(image_scale(image_read("www/wallTop_N.png"), "384x192!"))
for (i in 1: nrow(maze0)) {
  
  image_row <- c(image_scale(image_read("www/wallTop_N.png"), "384x32!"))
  for (j in 1:ncol(maze0)) {
    if(maze0[i,j]==6) {
      image_row <- c(image_row,image_read("www/wallTop_N.png"))
    }
    else if (maze0[i,j]==7) {
      image_row <- c(image_row,image_read("www/wallLeft_N.png"))
    }
    else if (maze0[i,j]==8) {
      image_row <- c(image_row,image_read("www/wallDown_N.png"))
    }
    else if (maze0[i,j]==4) {
      image_row <- c(image_row,image_read("www/wallRight_N.png"))
    }
    else if (maze0[i,j]==1) {
      image_row <- c(image_row,image_read("www/path2.png"))
    }
    else if (maze0[i,j]==9) {
      image_row <- c(image_row,image_read("www/exit.gif"))
    }

  }
  #map <- c(map,image_append(image_join(image_row),stack=FALSE))
  map <- c(map,image_composite(image_join(image_row), offset = "+0+32"))
 
}
#print(image_append(image_join(map), stack=TRUE))
print(image_composite(image_join(map), offset = "+32+0"))
image_composite(image_row)







image_row
image_composite(image_row)

print(image_animate(image_composite(image_scale(image_read("www/wallTop_N.png"), "384x32!"),image_read("www/exit.gif"))))

maze0


mazes <- c("maze0", "maze1", "maze11", "maze111","maze2", "maze21", "maze3","maze4","maze5")





#########

#map <- c()

for (maze_name in mazes) {
maze <- eval(parse(text=maze_name))
background <-image_fill(image_scale(image_read("www/wallTop_N.png"), paste0(32*ncol(maze),"x",32*nrow(maze),"!")), "white", fuzz=100)
map <-background
print(map)

for (i in 1: nrow(maze)) {
  
  image_row <- image_scale(image_read("www/wallTop_N.png"), paste0(32*ncol(maze),"x32!"))
  for (j in 1:ncol(maze)) {
    if(maze[i,j]==WALL) {
      image_row <- image_composite(image_row,image_read("www/wall2.png"),offset=paste0("+",32*(j-1)))
    }
    else if (maze[i,j]==COL) {
      image_row <- image_composite(image_row,image_read("www/col.png"),offset=paste0("+",32*(j-1)))
    }
    else if (maze[i,j]==8) {
      image_row <- image_composite(image_row,image_read("www/wallDown_N.png"),offset=paste0("+",32*(j-1)))
    }
    else if (maze[i,j]==4) {
      image_row <- image_composite(image_row,image_read("www/wallRight_N.png"),offset=paste0("+",32*(j-1)))
    }
      
    else if (maze[i,j]==CORRIDOR) {
      image_row <- image_composite(image_row,image_read("www/path2.png"),offset=paste0("+",32*(j-1)))
    }
    else if (maze[i,j]==EXIT) {
      image_row <- image_composite(image_row,image_read("www/exit.gif"),offset=paste0("+",32*(j-1)))
    }
  }
  #map <- c(map,image_append(image_join(image_row),stack=FALSE))
  map <- image_composite(map,image_row, offset=paste0("+0+",32*(i-1)))
}
#print(image_append(image_join(map), stack=TRUE))
print(image_animate(map))

image_write(image_animate(map),paste0("mazes/",maze_name,".gif"))
}
#player_positions <- get_random_free_positions(maze,1, list())
#ghost_positions <- get_random_free_positions(maze,2, player_positions)
#zombie_positions <- get_random_free_positions(maze,2, c(ghost_positions, player_positions))
 positions <- shuffle(maze,num_ghosts = 2, num_zombies = 2)

char_layer <- image_fill(image_scale(image_read("www/wallTop_N.png"), paste0(32*ncol(maze),"x",32*nrow(maze),"!")), "white", fuzz=100)

 
 draw_character <- function(char_id, positions, nrow, ncol, background) {
   
   layer <- background
   for (position in positions) {
     if (char_id == PLAYER) {
       img_char <- image_read("www/char.gif")
     }
     else if (char_id == GHOST) {
       img_char <- image_read("www/ghost.gif")
     }
     else if (char_id == ZOMBIE) {
       img_char <- image_read("www/zombie.gif")
     }
     i <- position$row
     j <- position$col
     layer <- image_composite(layer,img_char, offset=paste0("+",32*(j-1),"+",32*(i-1)))
   }
   layer
   
 }
 
 positions
 char_layer <- draw_character(PLAYER, positions$player_position,nrow(maze),ncol(maze), char_layer)
 char_layer <- draw_character(GHOST, positions$ghost_positions,nrow(maze),ncol(maze), char_layer)
 char_layer <- draw_character(ZOMBIE, positions$zombie_positions,nrow(maze),ncol(maze), char_layer)
 print(image_animate(char_layer))
 