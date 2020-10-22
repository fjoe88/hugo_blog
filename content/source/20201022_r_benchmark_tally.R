
library(dplyr)
library(magrittr) # for pipes
library(rlang) # for NSE
library(data.table)
library(janitor)

set.seed(123)

#generate a random dataframe out of a random normal distribution
#adding 2 id columns
num <- as.data.frame(matrix(rnorm(5000*50, 10, 1), ncol = 50))
id1 <- Reduce(c, sapply(1:500, function(x) rep(x, 10)))
id2 <- rep(1:10, 500)

df <- cbind(id1, id2, num)

# id1 id2        V1        V2        V3
# 1    1   1  9.439524  9.505826 12.370725
# 2    1   2  9.769823 11.127593  9.833188
# 3    1   3 11.558708  8.853050 10.926961
# 4    1   4 10.070508 11.481019  9.431848
# 5    1   5 10.129288 10.916191 10.225090
# 6    1   6 11.715065 10.335131 11.131986
# 7    1   7 10.460916 10.574675 11.380482
# 8    1   8  8.734939 10.203620  9.767197
# 9    1   9  9.313147  9.552959  8.399357
# 10   1  10  9.554338  9.656474  9.701631

new_row_order <- sample(nrow(df), 5000, replace = T)
df1 <- df[new_row_order, ]

ids <- c('id1', 'id2')

t0 <- Sys.time()

df2 <- df1[, ids]
df2$comb_ids <- apply(df2, 1, paste, collapse = "-")
df2$N <- sapply(df2$comb_ids, function(x) sum(x==df2$comb_ids))

#Time difference of 0.2090468 secs
Sys.time()-t0

df2[1:10, ]
#      id1 id2 comb_ids N
# 4587 459   7    459-7 1
# 631   64   1     64-1 1
# 3625 363   5    363-5 3
# 2286 229   6    229-6 2
# 3809 381   9    381-9 2
# 3807 381   7    381-7 2
# 504   51   4     51-4 1
# 2810 281  10   281-10 1
# 4809 481   9    481-9 1
# 4840 484  10   484-10 3

t0 <- Sys.time()

df2 <- df1 %>% group_by(!!!rlang::syms(ids)) %>% add_tally() %>% select(!!!rlang::syms(ids), n)

#Time difference of 0.05801296 secs
Sys.time()-t0

df2[1:10, ]
# A tibble: 10 x 3
# Groups:   id1, id2 [10]
#     id1   id2     n
#   <int> <int> <int>
# 1   459     7     1
# 2    64     1     1
# 3   363     5     3
# 4   229     6     2
# 5   381     9     2
# 6   381     7     2
# 7    51     4     1
# 8   281    10     1
# 9   481     9     1
# 10  484    10     3

t0 <- Sys.time()

df2 <- janitor::get_dupes(df1, ids)

#Time difference of 0.06700683 secs
Sys.time()-t0

df2[1:10, 1:5]
#    id1 id2 dupe_count        V1        V2
# 1    1   1          2  9.439524  9.505826
# 2    1   1          2  9.439524  9.505826
# 3    1   3          2 11.558708  8.853050
# 4    1   3          2 11.558708  8.853050
# 5    1  10          2  9.554338  9.656474
# 6    1  10          2  9.554338  9.656474
# 7    2   1          2 11.224082  9.396164
# 8    2   1          2 11.224082  9.396164
# 9    2   6          2 11.786913 10.319855
# 10   2   6          2 11.786913 10.319855

t0 <- Sys.time()

dt <- as.data.table(df1)
dt1 <- dt[, N := .N, by=ids]

dt2 <- dt1[, .SD, .SDcols=c(ids, 'N')]
#Time difference of 0.03399897 secs!
Sys.time()-t0

dt2[1:10, ]
#    id1 id2 N
# 1: 459   7 1
# 2:  64   1 1
# 3: 363   5 3
# 4: 229   6 2
# 5: 381   9 2
# 6: 381   7 2
# 7:  51   4 1
# 8: 281  10 1
# 9: 481   9 1
# 10: 484  10 3
