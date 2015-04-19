# Getting and Cleaning Data Course Project
The script consists of two functions: run_analysis() and createMeanDataset(). The first one does the actual reshaping of the data (steps 1-4 in the assignment), the second one produces an averaged data set, as required by step 5.

*Note:* Since the values in the second output data set are averaged, the information about incoming dataset (the *dataset* column) is lost.

The functions are called directly in the script, so calling ```source('run_analysis.R')``` will perform the calculation.

The *train* and *test* datasets were merged and can be identified using the value in column *dataset*.

## Features used
The instructions mention leaving only the data that is related to mean and standard deviation, thus only the columns marked as *mean()* or *std()* were preserved.

## Column naming
All unsafe characters appearing in original column names were removed, optionally replaced with R-safe dots. Also, *t-* and *f-* prefixes were expanded to a more readable form *time-* and *freq-*, indicating a time-based and frequency-based value, respectively. The abbreviations were left as they were and I believe they offer a reasonable compromise in being informative and concise.