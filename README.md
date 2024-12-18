# Predictive Modeling of Australian Vehicle Prices and Manufacturing Year

## Project Overview

This project explores statistical and machine learning techniques to predict vehicle prices and classify manufacturing year ranges using a dataset of [Australian vehicle listings](https://www.kaggle.com/datasets/nelgiriyewithana/australian-vehicle-prices). It applies exploratory data analysis (EDA), inferential statistics, and predictive modeling to uncover insights and build robust models.

## Key Achievements

1. Multiple Regression: Built a model to predict vehicle prices, achieving an R² of 0.7437.
2. Classification: Developed models to classify manufacturing year ranges, with Random Forests achieving 80% accuracy.
3. Preprocessing: Addressed missing values, outliers, and high-cardinality variables through extensive data cleaning.

## Data Set Information

The [Australian Vehicle Prices dataset](https://www.kaggle.com/datasets/nelgiriyewithana/australian-vehicle-prices) contains 16,734 car listings from Australia in 2023, capturing essential car attributes and price information. The dataset contains 19 columns that allow for analyzing the factors influencing vehicle prices in the Australian market.

***Features:***

1. **Brand**: Categorical nominal variable indicating the car manufacturer (e.g., Toyota, BMW).
2. **Year**: Numeric variable indicating the manufacturing year of the vehicle.
3. **Model**: Categorical nominal variable for the specific vehicle model.
4. **Car/SUV**: Categorical nominal variable indicating the type of vehicle (e.g., SUV, Hatchback).
5. **Title**: Categorical nominal variable indicating the title/description of the car.
6. **UsedOrNew**: Categorical nominal variable specifying whether the vehicle is used, new, or demo.
7. **Transmission**: Categorical nominal variable specifying the type of transmission (e.g., Automatic, Manual).
8. **Engine**: Categorical nominal variable detailing engine configuration (e.g., "4 cyl, 2.2 L").
9. **DriveType**: Categorical nominal variable for the drivetrain type (e.g., AWD, FWD, RWD).
10. **FuelType**: Categorical nominal variable for the type of fuel used (e.g., Diesel, Unleaded, Premium).
11. **FuelConsumption**: Categorical nominal variable specifying fuel consumption (e.g., "6.7 L / 100 km").
12. **Kilometers**: Categorical ordinal variable representing the vehicle mileage.
13. **ColourExtInt**: Categorical nominal variable for exterior and interior colors (e.g., "White / Black").
14. **Location**: Categorical nominal variable specifying the location of the vehicle listing.
15. **CylindersinEngine**: Categorical nominal variable for the number of cylinders in the engine (e.g., "4 cyl").
16. **BodyType**: Categorical nominal variable describing the body type of the vehicle (e.g., SUV, Coupe).
17. **Doors**: Categorical ordinal variable representing the number of doors.
18. **Seats**: Categorical ordinal variable representing the number of seats.
19. **Price**: Numeric variable indicating the price of the car in Australian dollars.

***Target Variables:***

- **Price**: Target variable for regression model
- **Year**: Target variable for classification model

## Dataset Preprocessing

Before implementing models for classification and regression, we performed several preprocessing steps to clean and prepare the dataset. The steps are detailed below:

1. **General Cleaning:**

    - Dropped rows with all missing values (NaN).
    - Converted Year from float to int for consistency.
    - Replaced invalid characters (- and /) with NaN to standardize the dataset.

2. **Feature-Specific Preprocessing:**

    - **Car/SUV:** Dropped this column as it contained inaccurate data and duplicated information already provided by CarType.
    - **CylindersInEngine:** Retained only the numeric value (e.g., removed the "cyl" string) and converted it to an ordinal and categorical variable.
    - **EngineCapacity:** Removed the cylinder count, keeping only the engine size in liters as a float.
    - **FuelConsumption:** Extracted the numeric value, renamed the column to FuelConsumptionPer100km to reflect that all values are in per-100km units.
    - **Kilometres:** Converted this column to numeric format.
    - **ColourExtInt:** Split into two columns: ColourExt (external color) and ColourInter (interior color) and dropped ColurInter since it had more than 7000 missing values with multiple incorrect colours (e.g 2Lle21).
    - **ColurExt:** Changed - to NaN and then replaced invalid colors (like 5 years, 3 years) with the "Other" value.
    - **Doors and Seats:** Removed text like "door" and "seat," converted the values to numeric, and treated them as ordinal and categorical variables.
    - **Price:** Converted "POA" ("Price on Application") to NaN and then to numeric.
    - **Title:** Dropped this column as it overlapped with information in Model, Brand, or Year, and its high cardinality (over 4,500 unique values) was likely to negatively impact the model.
    - **Year:** Binned into four ranges: "2020-2023," "2017-2019," "2012-2016," and "Before 2012." The new column, YearRanges, was created as an ordinal categorical variable to balance the data while maintaining meaningful groupings.

3. **Imputation of Missing Values:**
    - **Dropped rows** where City, Model, or Brand had fewer than 5 occurrences to remove sparse or unreliable data.
    - **Categorical Variables:** Missing values in Transmission, FuelType, BodyType, CylindersInEngine, Doors, and Seats were imputed by:
        - Grouping by Brand and Model and assigning the most frequent value.
        - If both Brand and Model were NaN, the most frequent value from the entire column was used.
    - **Numerical Variables:** Missing values in EngineCapacity, FuelConsumptionPer100km, and Price were imputed by:
        - Grouping by Brand and Model and calculating the mean.
        - If both Brand and Model were NaN, the mean of the entire column was used.
    - **Kilometres:** Imputed by grouping by UsedOrNew and YearRanges since mileage is closely tied to these factors.
    - **ColourExt, City, and State:** Missing values were imputed with the category "Other."

4. **Final Dataset:** After preprocessing, the cleaned and imputed dataset contained **15,779 rows and 18 columns**. Below is a summary of the dataset's features:

| **Feature**               | **Type**                 | **Possible Values** |
|---------------------------|--------------------------|----------------------|
| **Brand**                 | Categorical, nominal    | 49                   |
| **Model**                 | Categorical, nominal    | 358                  |
| **UsedOrNew**             | Categorical, nominal    | 3                    |
| **Transmission**          | Categorical, binary     | 2                    |
| **DriveType**             | Categorical, nominal    | 5                    |
| **FuelType**              | Categorical, nominal    | 8                    |
| **Kilometers**            | Numerical, continuous   | -                    |
| **CylindersInEngine**     | Categorical, ordinal    | 8                    |
| **BodyType**              | Categorical, nominal    | 10                   |
| **Doors**                 | Categorical, ordinal    | 4                    |
| **Seats**                 | Categorical, ordinal    | 12                   |
| **Price**                 | Numerical, continuous   | -                    |
| **EngineCapacity**        | Numerical, continuous   | -                    |
| **FuelConsumptionPer100km** | Numerical, continuous | -                    |
| **ColourExt**             | Categorical, nominal    | 18                   |
| **City**                  | Categorical, nominal    | 511                  |
| **State**                 | Categorical, nominal    | 9                    |
| **YearRanges**            | Categorical, ordinal    | 4                    |

### Statistical Methods

1. EDA: Correlation analysis and hypothesis testing to identify key predictors.
2. Inferential Statistics: ANOVA and t-tests for variable significance.

### Predictive Models

1. Regression:
    - Achieved an R² of 0.7437 using multiple regression.
    - Applied Box-Cox transformations to address non-normality.
2. Classification:
    - Random Forests (80% accuracy) for non-linear modeling.
    - Logistic Regression (68% accuracy) for interpretability.

## Collaborators

This project was worked on with the contributions of [mohd-hani](https://github.com/arcarum) and [dheemanG](https://github.com/dheemanG).
