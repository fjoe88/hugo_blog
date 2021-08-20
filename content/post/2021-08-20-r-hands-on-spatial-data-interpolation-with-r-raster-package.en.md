---
title: '[R] Hands-on spatial data interpolation with R raster package. '
author: zhoufang
date: '2021-08-20'
slug: r-hands-on-spatial-data-interpolation-with-r-raster-package
categories:
  - R
tags:
  - R
  - spatial data
  - interpolation
  - raster
  - spatial autocorrelation
description: ~
featured_image: ~
---

![Geocomputation with R](/post/2021-08-20-r-hands-on-spatial-data-interpolation-with-r-raster-package.en_files/cover.png)
[Geocomputation with R](http://geocompr.robinlovelace.net)

Geocomputation... we define the term as follows: working with geographic data in a compoutational way, focusing on code, reproducibility and modularity.

The author listed 2 fundamental geopgraphic data models: vector and raster.

- The *vector data model* represents the world using points, lines and polygons. These have discrete, well-defined borders, meaning that vector datasets usually have a high level of precision(but not necessarily accuracy.)

- The *raster data model* divides the surface up into cells of constant size. Raster datasets are the basis of background images used in web-mapping and have been a vital source of geographic data since the origins of aerial photography and satellite-based remote sensing devices. Rasters aggregate spatially specific features to a given resolution, meaning that they are consistent over space and scalable.

Think of the difference between vector data model and raster data model as vectorized images versus a real photo images, where the former is precise in the sense that you will still receive a smooth image as resolution increases, but it is no where as accurate as the latter which represents a real image but is limited by the resolution given.
![tigers](/post/2021-08-20-r-hands-on-spatial-data-interpolation-with-r-raster-package.en_files/tigers_fixed_resolution.png)
