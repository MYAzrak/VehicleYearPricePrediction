

######################################################

data<-cleaned_australian_vehicles_prices
sum_occurrences <- sum(data$Brand == "Toyota" & data$Model == "Corolla")

# Print the result
print(sum_occurrences)

library(ggplot2)
library(dplyr)

# Count the number of observations for each unique combination of Brand and Model
brand_model_counts <- filtered_data %>%
  dplyr::count(Brand, Model)



filtered_data <- data %>%
  group_by(Brand, Model) %>%             # Group by Brand and Model
  filter(n() >= 5) %>%                   # Keep groups with at least 5 observations
  ungroup()           

city_counts <- filtered_data %>%
  dplyr::count(City)

filtered_data <- filtered_data %>%
  group_by(City) %>%             
  filter(n() >= 3) %>%                   #group by city remove city with 1 or 2 records
  ungroup()           

#impute transmission

filtered_data <- filtered_data %>%
  group_by(Brand, Model) %>%
  mutate(
    Transmission = ifelse(
      is.na(Transmission), 
      # Replace missing values with the most frequent Transmission
      names(which.max(table(Transmission, useNA = "no"))),
      Transmission
    )
  ) %>%
  ungroup()



most_fueltype <- names(which.max(table(filtered_data$FuelType, useNA = "no")))

# Impute missing FuelType values
filtered_data <- filtered_data %>%
  group_by(Brand, Model) %>%
  mutate(
    FuelType = ifelse(
      is.na(FuelType),
      # If most of the FuelType values in the group are NA, use overall most frequent
      ifelse(
        all(is.na(FuelType)),
        most_fueltype,
        # Otherwise, use the most frequent FuelType in the group
        names(which.max(table(FuelType, useNA = "no")))
      ),
      FuelType
    )
  ) %>%
  ungroup()

#impute kilometres

filtered_data <- filtered_data %>%
  group_by( UsedOrNew, YearRanges) %>%
  mutate(
    Kilometres = ifelse(
      is.na(Kilometres), 
      
      mean(Kilometres, na.rm = TRUE),  
      
      Kilometres
    )
  ) %>%
  ungroup()

#impute bodytype

filtered_data <- filtered_data %>%
  group_by(Brand, Model) %>%
  mutate(
    BodyType = ifelse(
      is.na(BodyType),
      
      ifelse(
        all(is.na(BodyType)),
        names(which.max(table(filtered_data$BodyType[filtered_data$Brand == Brand], useNA = "no"))),
        # Otherwise, use the most frequent BodyType by Brand and Model
        names(which.max(table(BodyType, useNA = "no")))
      ),
      BodyType
    )
  ) %>%
  ungroup()

#convert num to char

filtered_data$CylindersinEngine <- as.character(filtered_data$CylindersinEngine)

most_cylinders <- names(which.max(table(filtered_data$CylindersinEngine, useNA = "no")))

# Impute missing FuelType values
filtered_data <- filtered_data %>%
  group_by(Brand, Model) %>%
  mutate(
    CylindersinEngine = ifelse(
      is.na(CylindersinEngine),
      
      ifelse(
        all(is.na(CylindersinEngine)),
        most_cylinders,
        
        names(which.max(table(CylindersinEngine, useNA = "no")))
      ),
      CylindersinEngine
    )
  ) %>%
  ungroup()



filtered_data$Doors <- as.character(filtered_data$Doors)

most_doors<- names(which.max(table(filtered_data$Doors, useNA = "no")))

# Impute missing Door values
filtered_data <- filtered_data %>%
  group_by(Brand, Model) %>%
  mutate(
    Doors = ifelse(
      is.na(Doors),
      
      ifelse(
        all(is.na(Doors)),
        most_doors,
        
        names(which.max(table(Doors, useNA = "no")))
      ),
      Doors
    )
  ) %>%
  ungroup()


#imputing seats

filtered_data$Seats <- as.character(filtered_data$Seats)


most_seats <- names(which.max(table(filtered_data$Seats, useNA = "no")))

filtered_data <- filtered_data %>%
  group_by(Brand, Model) %>%
  mutate(
    Seats = ifelse(
      is.na(Seats),
      
      ifelse(
        all(is.na(Seats)),
        most_seats,
        
        names(which.max(table(Seats, useNA = "no")))
      ),
      Seats
    )
  ) %>%
  ungroup()

#impute engine cap

filtered_data$EngineCapacity <- as.numeric(filtered_data$EngineCapacity)

mean_engine <- mean(filtered_data$EngineCapacity, na.rm=TRUE)

filtered_data <- filtered_data %>%
  group_by(Brand, Model) %>%
  mutate(
    EngineCapacity = ifelse(
      is.na(EngineCapacity),
      
      ifelse(
        sum(!is.na(EngineCapacity)) == 0,
        mean_engine,        
        mean(EngineCapacity, na.rm = TRUE)
      ),
      EngineCapacity
    )
  ) %>%
  ungroup()

#impute fuel consumption

mean_fuelcap <- mean(filtered_data$FuelConsumptionPer100km, na.rm=TRUE)



filtered_data <- filtered_data %>%
  group_by(Brand, Model) %>%
  mutate(
    FuelConsumptionPer100km = ifelse(
      is.na(FuelConsumptionPer100km),
      
      ifelse(
        sum(!is.na(FuelConsumptionPer100km)) == 0,
        mean_fuelcap,       
        mean(FuelConsumptionPer100km, na.rm = TRUE)
      ),
      FuelConsumptionPer100km
    )
  ) %>%
  ungroup()

#impute price

mean_price <- mean(filtered_data$Price, na.rm=TRUE)



filtered_data <- filtered_data %>%
  group_by(Brand, Model) %>%
  mutate(
    Price = ifelse(
      is.na(Price),
      
      ifelse(
        sum(!is.na(Price)) == 0,
        mean_price,        
        mean(Price, na.rm = TRUE)
      ),
      Price
    )
  ) %>%
  ungroup()


#impute Colorext, city and state

filtered_data <- filtered_data %>%
  mutate(
    ColourExt = ifelse(is.na(ColourExt), "Other", ColourExt),
    City = ifelse(is.na(City), "Other", City),
    State = ifelse(is.na(State), "Other", State)
  )






na_counts <- sapply(filtered_data, function(x) sum(is.na(x)))

# Print the result
print(na_counts)



downloads_path <- "C:/Users/HP/Downloads/filtered_data.xlsx"

# Write the data to an Excel file
write_xlsx(filtered_data, path = downloads_path)

