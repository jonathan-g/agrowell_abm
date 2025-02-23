#process raw survey data to create variables for analysis

require(dplyr)
require(gdata)
require(ggplot2)
require(lme4)
require(ggmcmc)
require(BEST)
require(foreign)

c1 <- tbl_df(read.csv("c1.csv", stringsAsFactors = FALSE))

#number of fields
fields <- c1[,c("LAN1B.01", "LAN1B.02", "LAN1B.03", "LAN1B.04", "LAN1B.05", "LAN1B.06", "LAN1B.07", "LAN1B.08" )]
field.count <- rowSums(!is.na(fields))
c1$fieldcount <- field.count

#position of paddy fields
#he = 1, me = 2, te = 3
positions <- c1[,c("LAN1L.01", "LAN1L.02", "LAN1L.03", "LAN1L.04", "LAN1L.05", "LAN1L.06", "LAN1L.07", "LAN1L.08" )]
positions[fields > 1] <- NA  #select subset of paddy fields

paddy.position <- data.frame(f1 = numeric(607), f2 = numeric(607), f3 = numeric(607), f4 = numeric(607), f5 = numeric(607), f6 = numeric(607), f7 = numeric(607), f8 = numeric(607))
for (c in 1:8)  {
  for (r in 1:607) {
    out <- ifelse(fields[r,c] == 1 & (!is.na(fields[r,c])), positions[r,c], NA)
    paddy.position[r,c] = out
  }}

#head = 1, middle = 2, tail = 3
he.count <- rowSums(paddy.position == 1, na.rm = T)
me.count <- rowSums(paddy.position == 2, na.rm = T)
te.count <- rowSums(paddy.position == 3, na.rm = T)
field.count <- rowSums(!is.na(paddy.position))  #why are there farmres listing NO field in the LAN table?
prop.he <- he.count/field.count
prop.te <- te.count/field.count
prop.he[is.na(prop.he)] <- 0
prop.te[is.na(prop.te)] <- 0
c1$prop.he <- prop.he
c1$prop.te <- prop.te

te <- ifelse(prop.te > 0.5, 1, 0)
te[is.na(te)] <- 0
c1$tail_end <- te
c1$tail_end_prop <- prop.te

#minority flag (1 = S, 2 = T)
sinhalese <- ifelse(c1$HH_K.1 == 1, 1,0)
c1$sinhalese <- sinhalese

#female flag (1 = M, 2 = F)
female <- ifelse(c1$HH2_D.01 == 2, 1, 0)
c1$female <- female

#ownership majority of fields listed (farmer, government, non-owner)
ownership <- c1[,c("LAN1D.01", "LAN1D.02", "LAN1D.03", "LAN1D.04", "LAN1D.05", "LAN1D.06", "LAN1D.07", "LAN1D.08" )]
owner <- rowSums(ownership == 1, na.rm = T)/field.count
owner[is.na(owner)] <- 0
gvt_owner <- rowSums(ownership == 2, na.rm = T)/field.count
non_owner <- rowSums(ownership > 2, na.rm = T)/field.count
c1$owner <- ifelse(owner > .5, 1, 0)
c1$gvt_owner <- ifelse(gvt_owner > .5, 1, 0)
c1$non_owner <- ifelse(non_owner > .5, 1, 0)


#majority of fields receive irrigation water from (major, minor, majon_minor, rf)
irrigation <- c1[,c("LAN1H_1.01", "LAN1H_1.02", "LAN1H_1.03", "LAN1H_1.04", "LAN1H_1.05", "LAN1H_1.06", "LAN1H_1.07", "LAN1H_1.08" )]
major <- (rowSums(irrigation == 1, na.rm = T) + rowSums(irrigation == 2, na.rm = T))/field.count
major[is.na(major)] <- 0
minor <- (rowSums(irrigation == 5, na.rm = T) + rowSums(irrigation == 6, na.rm = T))/field.count 
minor[is.na(minor)] <- 0
major_minor <- (rowSums(irrigation == 3, na.rm = T) + rowSums(irrigation == 4, na.rm = T))/field.count
major_minor[is.na(major_minor)] <- 0
rainfed <- rowSums(irrigation == 8, na.rm = T)/field.count
c1$major <- ifelse(major > .5, 1, 0)
c1$minor <- ifelse(minor > .5, 1, 0)
c1$major_minor <- ifelse(major_minor > .5, 1, 0)
c1$rf <- ifelse(rainfed > .5, 1, 0)

#major irrigation flag
c1$major_flag = c1$major + c1$major_minor

#agrowell user
agrowell_user <- rowSums(irrigation == 7, na.rm = T)
c1$agrowell_user <- ifelse(agrowell_user > 0, 1,0)

#fo membership
c1$fo <- ifelse(c1$SAT1_1 == 1, 1, 0)  #note that there were entries with value of 3, not sure what this meant, counted it as no


