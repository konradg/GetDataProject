## Prepares the smartphone usage data
run_analysis <- function(outfile = 'tidy_data.txt', writefile=!is.null(outfile), printdebug=TRUE) {
    
    # Allows quick print enable/disable
    debugprint <- function(msg) {
        if (printdebug) {
            print(msg)
        }
    }
    
    if (!file.exists("UCI HAR Dataset")) {
        if(!file.exists("data.zip")){
            debugprint("No data archive found, downloading...")
            dataUrl="https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
            download.file(destfile="data.zip", url=dataUrl)
            unzip("data.zip")
        } else {
            debugprint("Data archive found, unzipping...")
            unzip("data.zip")
        }
    } else {
        debugprint("Unpacked data found")
    }
    
    fname <- function(name) {
        paste0('UCI HAR Dataset/', name, '.txt')
    }
    
    debugprint("Reading features...")
    # 'features.txt': List of all features.
    feature_names = read.table(fname('features'),
                               stringsAsFactors=FALSE)[,2];
    
    debugprint("Reading activity labels...")
    # 'activity_labels.txt': Links the class labels with their activity name.
    activity_labels = read.table(fname('activity_labels'))[,2];
    
    sets = c("train", "test")
    data = data.frame()
    for (i in seq(along=sets)) {
        dataset = sets[i]
        
        debugprint(sprintf("Reading %s features data (X)...", dataset))
        data.filename = sprintf(fname('%s/X_%s'),
                                dataset, dataset)
        datapart = read.table(data.filename, stringsAsFactors=FALSE);
        datapart$dataset = dataset
        
        debugprint(sprintf("Reading %s activity data (y)...", dataset))
        y.filename = sprintf(fname('%s/y_%s'),
                             dataset, dataset)
        y.data = read.table(y.filename)[,1]
        y.data <- as.factor(y.data)
        levels(y.data) <- activity_labels
        datapart$activity = y.data
        
        debugprint(sprintf("Reading %s subject data...", dataset))
        subject.filename = sprintf(fname('%s/subject_%s'),
                                   dataset, dataset)
        datapart$subject = read.table(subject.filename)[,1]
        data <- rbind(data, datapart)
    }
    
    debugprint("Assigning variable names...")
    colnames(data) <- c(feature_names, "dataset", "activity", "subject")
    
    # Leaving only mean/sd columns + dataset + activity
    nfeat = length(feature_names)
    data <- data[,c(nfeat+3, nfeat+2, nfeat+1,
                    grep("mean\\(\\)|std\\(\\)",feature_names))]
    
    # Column name cleanup
    debugprint("Cleaning up column names...")
    names(data) <- gsub("[-_]", "\\.", names(data)) # getting rid of unnecessary characters
    names(data) <- gsub("[\\(\\)]", "", names(data))
    names(data) <- gsub("^f([A-Z])", "freq\\.\\1", names(data))
    names(data) <- gsub("^t([A-Z])", "time\\.\\1", names(data))
    names(data) <- gsub("([a-z])([A-Z])", "\\1\\.\\2", names(data))
    names(data) <- gsub("body\\.body", "body", names(data)) # weird original feature name corrected
    names(data) <- tolower(names(data))

    # Writing output data to file
    if (writefile) {
        debugprint(sprintf("Writing output file to %s...", outfile));
        write.table(file = outfile, x = data)
    }
    
    debugprint("Done.")
    data
}

createMeanDataset <- function(data, outfile = 'tidy_data_averaged.txt', writefile=!is.null(outfile)) {
    datacopy <- data
    datacopy$activity.subject <- paste(data$activity, data$subject, sep = '|')
    outdata <- as.data.frame(t(sapply(split(datacopy, datacopy$activity.subject), 
           function(x) {colSums(x[,5:length(datacopy)-1])})))
    outdata$activity <- as.factor(gsub("(.*)\\|.*", "\\1", row.names(outdata)))
    outdata$subject <- as.factor(gsub(".*\\|(.*)", "\\1", row.names(outdata)))
    n <- length(outdata)
    outdata <- outdata[c(n-1, n, 1:(n-2))]
    row.names(outdata) <- NULL
    if (writefile) {
        write.table(file=outfile, x = outdata)
    }
    outdata
}

data <- run_analysis()
outdata <- createMeanDataset(data)