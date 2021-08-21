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

When doing data analysis using spatial data, it is important that the spatial data is collected at a good-enough resolution to avoid excessive missing data which will severly impact the quality of this data to be used as a feature. In reality, one can easily have limited the data due to only limited samples being available, as a result spatial data interpolation becomes necessary and key to fill the missing values.

In the semiconductor manufacturing, key parameters such as film thickness after deposition or etch process are monitored across wafers that are 300mm in diameter, this data is measured in-line (during production) through advanced optical x-ray based metrology equipment via a single probe measuring one site at a time, the total site numbers measured per wafer is limited primarily by the measurement speed that is in turn affecting the cycle time of the materials and the ability for a facility to output products and make money, therefore the number of sites per wafer measured in-line is typically limited to under 20 sites which is too sparse for any precise readings when the number of dies can easily reach hundreds if not thousands per single silicon wafer (one healthy die yields one chip when dice are sliced at the end of production). 

To increase the resolution from the few measurements obtained on a wafer, one has to use **spatial data interpolation techniques** in order to have an 'educated guess' of the likely thickness across different un-measured regions on a wafer, which becomes especially useful when one is trying to use this measurement as a feature for model building and can use such interpolated data to fill the missing values.

Luckily for me, these thickness data are spatially autocorrelated in nature and are similar to geological data, a great deal of research and work has been done by many in the field of Statistics and Data Analyis in Geology and a great book on the specifically on the topic of 'Geocomputation' is [Geocomputation with R](http://geocompr.robinlovelace.net) by Robin Lovelace, Jakub Nowosad, Jannes Muenchow.

![Geocomputation with R](/post/2021-08-20-r-hands-on-spatial-data-interpolation-with-r-raster-package.en_files/cover.png)

In this book the author coined the term of 'Geocomputation' as follows: 

> we define the term as follows: working with geographic data in a computational way, focusing on code, reproducibility and modularity.

Before I proceed with an example of spatial data interpolation using R and `raster`, the concepts of **Geographic data models** and **Spatial autocorrelation** should be introduced.

**Geopgraphic data models**

The author listed 2 fundamental geographic data models: *vector* and *raster*.

- The *vector data model* represents the world using points, lines and polygons. These have discrete, well-defined borders, meaning that vector datasets usually have a high level of precision(but not necessarily accuracy.)

- The *raster data model* divides the surface up into cells of constant size. Raster datasets are the basis of background images used in web-mapping and have been a vital source of geographic data since the origins of aerial photography and satellite-based remote sensing devices. Rasters aggregate spatially specific features to a given resolution, meaning that they are consistent over space and scalable.

Think of the difference between vector data model and raster data model as vectorized images versus a real photo images, where the former is precise in the sense that you will still receive a smooth image as resolution increases, but it is no where as accurate as the latter which represents a real image but is limited by the resolution given.
![tigers](/post/2021-08-20-r-hands-on-spatial-data-interpolation-with-r-raster-package.en_files/tigers_fixed_resolution.png)

**Spatial autocorrelation**

Autocorrelation is a measure of similarity, or correlation, between nearby observations, temporal and spatial autocorrelation are two of the common examples of autocorelation.

- Temporal autocorrelation
If you measure something about he same object over time, such as a person's weight or wealth, it is likely that two observations that are close to each other in time are also close in measurements, in other words the data measured close-by in time tend to correlate with each other. Temporal autocorrelation is also the basis to many of the Time Series analysis.

- Spatial autocorrelation
The concept of spatial autocorrelation is an extension of temporal autocorrelation, time is one-dimensional and only goes in one direction (ever forward). spatial objects have (at least) two dimensions and complex shapes, and it may not be obvious how to determine what is "near". Measures of spatial autocorrelation describe the degree to which observations at spatial locations (whether they are points, areas, or raster cells), are similar to each other. So two things are needed: observation and location.