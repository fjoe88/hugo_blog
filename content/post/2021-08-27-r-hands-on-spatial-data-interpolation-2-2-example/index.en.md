---
title: '[R] Hands-on spatial data interpolation 2/2 - Example'
author: zhoufang
date: '2021-08-27'
slug: []
categories:
  - R
tags:
  - spatial data
  - spatial autocorrelation
  - R
  - interpolation
  - raster
  - gstat
description: ~
featured_image: ~
---


```R
set.seed(99)

#generate a wafer map bound by radius of 10 consists of number of 1x1 dice
x <- rep(-10:10, 21)
y <- rep(-10:10, each=21)
r <- sqrt(x^2+y^2)

df <- data.frame(x, y, r)
df <- df[which(df$r<10), ]

#generate random data of 8 random dice on the wafer
df$z <- NA 
df$z[sample(1:nrow(df), 8)] <- runif(8)

library(ggplot2)

ggplot(df, aes(x = x, y = y, z = z, fill = z)) + 
  geom_tile() + #or use geom_raster()
  geom_contour() + 
  scale_fill_continuous(type = 'viridis') + 
  theme_bw()

```

![](images/2021-08-27 13_54_12-RStudio.png)


```R
#interpolate missing values
test <- df[is.na(df$z), ]
train <- df[!is.na(df$z), ]

library(gstat)
#IDW (inverse distance weighted)
#~1 meaning use intercept only (e.g. x+y)
gscv <- gstat(formula=z~1, location=~x+y, data=train)
p <- predict(gscv, test)$var1.pred

df$z2 <- df$z
df$z2[is.na(df$z)] <- p

ggplot(df, aes(x, y, z = z2, fill = z2)) + 
  geom_tile() +
  geom_contour() +
  scale_fill_continuous(type = 'viridis') +
  theme_bw()
```

![](images/2021-08-27 13_54_02-RStudio.png)