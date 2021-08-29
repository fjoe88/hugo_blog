---
title: '[R] Write up a wafer map generator function from scratch.'
author: zhoufang
date: '2020-11-21'
slug: []
categories:
  - R
tags:
  - R
  - semiconductor
description: ~
featured_image: ~
---

Objective: to write a `create_wafer` function that returns a data frame that represent a wafer mapping of dice, each row contains the center and 4 corner locations of a die, along with region location and if it is a partial die(part of the die falls outside of the wafer boundary).

Note that two additional columns of 'circle_x' and 'circle_y' are added to the return data frame only for the visual assist of adding a wafer parameter drawing on top of the wafer map.

```R

create_wafer <- function(d=300, die_x=1, die_y=1, origin_x=0, origin_y=0) {
  # browser()
  #generate a wafer map bound by radius of 10 consists of number of 1x1 dice
  x <- rep(seq(-d/2+origin_x, d/2+origin_x, die_x), ceiling(d/die_x))
  y <- rep(seq(-d/2+origin_y, d/2+origin_y, die_y), ceiling(d/die_y))
  
  df <- as.data.frame(expand.grid(x,y))
  
  names(df) <- c("x", "y")
  
  df$r <- sqrt((df$x-origin_x)^2+(df$y-origin_y)^2)
  
  df <- df[which(df$r<=d/2), ]
  
  df$ur_x <- df$x+die_x/2
  df$lr_x <- df$x+die_x/2
  df$ul_x <- df$x-die_x/2
  df$ll_x <- df$x-die_x/2
  
  df$ul_y <- df$y+die_y/2
  df$ur_y <- df$y+die_y/2
  df$ll_y <- df$y-die_y/2
  df$lr_y <- df$y-die_y/2

  df$partial_die <- 
    sqrt((df$ul_x-origin_x)^2+(df$ul_y-origin_y)^2)>d/2 |
    sqrt((df$ur_x-origin_x)^2+(df$ur_y-origin_y)^2)>d/2 |
    sqrt((df$ll_x-origin_x)^2+(df$ll_y-origin_y)^2)>d/2 |
    sqrt((df$lr_x-origin_x)^2+(df$lr_y-origin_y)^2)>d/2
  
  get_region <- function(x, r){
    region <- ifelse(0<x & x<=r/5, "A", ifelse(
      r/5<x & x<=2*r/5, "B", ifelse(
        2*r/5<x & x<=3*r/5, "C", ifelse(
          3*r/5<x & x<=4*r/5, "D", ifelse(
            4*r/5<x & x<=r, "E", "Unknown"
          )))))
    return(region)
  }
  
  df$region <- get_region(df$r, r=d/2)
  
  #create a custom function to draw circle to depict a wafer perimeter.
  draw_circle <- function(center = c(0,0),diameter = 1, npoints = 100){
    r = diameter / 2
    tt <- seq(0,2*pi,length.out = npoints)
    xx <- center[1] + r * cos(tt)
    yy <- center[2] + r * sin(tt)
    return(data.frame(circle_x = xx, circle_y = yy))
  }
  
  circle_xy <- draw_circle(c(origin_x, origin_y), d, npoints = nrow(df))
  
  df <- cbind(df, circle_xy)
  
  return(df)
}

```

Simply call `create_wafer` now and passing in die size and origin arguments or accept the defaults, try plot the wafer map using `ggplot2`'s `geom_tile` or `geom_raster` functions that are suited for plotting wafer maps.

```R
wf <- create_wafer(die_x = 10, die_y = 20, origin_x=0, origin_y = 0)

library(ggplot2)
ggplot(wf, aes(x, y)) +
  geom_tile(aes(fill=partial_die), size=0.5, colour = "grey80") +
  scale_fill_manual(values = c("steelblue2", "darkorange2")) +
  # geom_point() +
  geom_path(aes(circle_x, circle_y)) +
  theme_bw()
```

<img src="images/Screenshot at Aug 29 10-11-39.png" alt="" width="400px"/>