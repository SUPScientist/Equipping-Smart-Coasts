library("googledrive")
library("readxl")
library("seacarb")
library("tidyr")
library("httr")


wd = "./Analysis/Data/"
KEYFILE = c('MY_GOOGLE_SHEETS_TOKEN')
XLFILE <- paste0(wd,"mySeapHOx-MS.xlsx")
CSVFILE <- paste0(wd,"pH-MS.csv")


# -------------------------------------------------------------------------

drive_download(
  type = "xlsx",
  file = as_id("THIS_GOOGLE_SHEET_ID"),
  path <- XLFILE,
  overwrite = TRUE
)

pH = read_xlsx(XLFILE, sheet = "QCLevel1_ERDDAP", col_types = c("date", rep(x = "numeric", 6)))

pH$time <- as.integer(as.POSIXct(pH$Date_Time_UTC))
pH$station <- rep("AH",nrow(pH))
pH$long <- rep("-117.32750",nrow(pH))
pH$lat <- rep("33.14250",nrow(pH))
pH$TAlk_molkg <- rep(0.002250,nrow(pH))

# Deal with NAs with which seacarb cannot deal
pH_noNA <- pH %>% drop_na(Temp_C)

# Select very wide ranges but ones that abide by seacarb rules
pH_noNA <- pH_noNA[which(pH_noNA$pH_total>6 & pH_noNA$pH_total<9), ]
pH_noNA <- pH_noNA[which(pH_noNA$Sal_PSS>15 & pH_noNA$Sal_PSS<45), ] # seacarb can't handle low S

# Add CO2 System Calculations; flag 8 is pH and alk inputs
co2sys <- carb(flag=8, var1=pH_noNA$pH_total, var2=pH_noNA$TAlk_molkg,
               S=pH_noNA$Sal_PSS, T=pH_noNA$Temp_C, P=pH_noNA$Pressure_dbar, Patm=1.0,
               Pt=0, Sit=0, pHscale="T", kf="pf", k1k2="l", ks="d", b="u74",
               warn="n", eos="teos10", long=pH_noNA$long, lat=pH_noNA$lat)

pH_noNA$Omega_Ar = co2sys$OmegaAragonite

write.csv(pH_noNA, file = CSVFILE, quote = FALSE, row.names = FALSE)

# -------------------------------------------------------------------------
