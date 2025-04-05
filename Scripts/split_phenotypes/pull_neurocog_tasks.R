## Pull neurocog tasks from SQL server (UKBB application 18177)

library(data.table)
library(RSQLite)
library(dplyr)

#Setting up SQL connection 
sqlite     <- dbDriver("SQLite")
db.file    <- "/sc/arion/projects/data-ark/ukb/application/ukb18177/phenotype/ukb18177.db"
setwd("/sc/arion/projects/data-ark/ukb/application/ukb18177/phenotype")
query <- function(...) dbGetQuery(db, ...)
db <- dbConnect(sqlite,db.file)

## Neurocog Measures:
#Extracting Pairs Matching neurocog data (Number of incorrect matches in round) 2020 (f399) --> need to reverse code
ukbb_data_f399_pairs_matching_incorrect_2020 <- as.data.table(query('select * from f399'))
#This category contains data on 'pairs' matching tests. Participants are asked to memorise the position 
#of as many matching pairs of cards as possible. The cards are then turned face down on the screen 
#and the participant is asked to touch as many pairs as possible in the fewest tries.

#Extracting Reaction Time neurocog data (Mean time to correctly identify matches) 2020 (f20023) --> need to reverse code 
ukbb_data_f20023_reaction_time_mean_2020 <- as.data.table(query('select * from f20023'))
#This category contains data on a test to assess reaction time and is based on 12 rounds of the card-game 'Snap'. 
#The participant is shown two cards at a time; if both cards are the same, they press a button-box that is on the 
#table in front of them as quickly as possible.

#Extracting Fluid Intelligence/reasoning neurocog data (Fluid intelligence score) 2020 (f20016)
ukbb_data_f20016_fluid_intelligence_score_2020 <- as.data.table(query('select * from f20016'))
#This category contains data on questions designed to assess 'Fluid intelligence' (i.e. the capacity to 
#solve problems that require logic and reasoning ability, independent of acquired knowledge). 
#The participant has 2 minutes to complete as many questions as possible from the test.

#Extracting Numeric Memory neurocog data (Maximum digits remembered correctly) 2020 (f4282) - only 85,252 subset
ukbb_data_f4282_numeric_memory_score_2020 <- as.data.table(query('select * from f4282'))
#The participant was shown a 2-digit number to remember. The number then disappeared and after a short while 
#they were asked to enter the number onto the screen. The number became one digit longer each time they 
#remembered correctly (up to a maximum of 12 digits). Data collected include the number of digits and value of the number, 
#the length of time the number was displayed, the time that the participant first entered and last entered a digit, the 
#time taken to complete the test, the value of the number entered by the participant, whether or not the participant was correct, 
#the maximum number of digits remembered, and whether the test was completed.

#Extracting Symbol Digit Substitution neurocog data (Number of symbol digit matches made correctly) 2020 (f23324) - only 36,298 subset, not baseline (started imaging clinics)
ukbb_data_f23324_symbol_digits_correct_2020 <- as.data.table(query('select * from f23324'))
#The participant was presented with one grid linking symbols to single-digit integers 
#and a second grid containing only the symbols. They were then asked to indicate the 
#numbers attached to each of the symbols in the second grid using the first one as a key.
ukbb_data_f23323_symbol_digits_attempted_2020 <- as.data.table(query('select * from f23323')) # substitutions attempted 
#^to get an accurate score of performance, do f23324/f23323 ratio

#Extracting Trail Making A (Numeric) neurocog data (Duration to complete numeric path (trail #1)) 2020 (f6348) - only 36,696 subset, not baseline (started imaging clinics)
ukbb_data_f6348_trail_making_numeric_duration_2020 <- as.data.table(query('select * from f6348')) #--> reverse code! 
#The participant was presented with sets of digits in circles scattered around the screen and 
#asked to click on them sequentially according to a specific algorithm.

#Extracting Trail Making B (Alphanumeric) neurocog data (Duration to complete alphanumeric path (trail #2)) 2020 (f6350) - only 36,696 subset, not baseline (started imaging clinics)
ukbb_data_f6350_trail_making_alphanumeric_duration_2020 <- as.data.table(query('select * from f6350')) #--> reverse code! 
#The participant was presented with sets of digits/letters in circles scattered around the screen and 
#asked to click on them sequentially according to a specific algorithm.

#Extracting Matrix Reasoning neurocog data (Number of puzzles correctly solved) 2020 (f6373) - only 36,276 subset, not baseline (started imaging clinics)
ukbb_data_f6373_matrix_reasoning_2020 <- as.data.table(query('select * from f6373'))
#The participant was presented with a series of matrix pattern blocks with an element missing and 
#asked to select the element that best completed the pattern from a range of displayed choices.
ukbb_data_f6374_matrix_reasoning_attempted_2020 <- as.data.table(query('select * from f6374')) #problems attempted
#^to get an accurate score of performance, do f6373/f6374

#Extracting Tower rearranging neurocog data (Number of puzzles correct) 2020 (f21004) - only 35,983 subset, not baseline (started imaging clinics)
ukbb_data_f21004_tower_rearranging_2020 <- as.data.table(query('select * from f21004'))
#The participant was presented with an illustration of three pegs (towers) on which three differently-coloured hoops had been placed. 
#The were then asked to indicate how many moves it would take to re-arrange the hoops into another specific position.

#Extracting Prospective Memory neurocog data (Prospective memory result) 2020 (f20018)
ukbb_data_f20018_prospective_memory_score_2020 <- as.data.table(query('select * from f20018'))
#Early in the touchscreen cognitive section, the participant is shown the mesage "At the end of 
#the games we will show you four coloured shapes and ask you to touch the Blue Square. However, to 
#test your memory, we want you to actually touch the Orange Circle instead." This category includes 
#data on the first and final answer, the history of attempts and the time it took to answer.

## NOTE: In our 18177 application we don't have access to the following tasks:
#Paired associate learning neurocog data (Number of puzzles correct) 2020 (f20197): https://biobank.ndph.ox.ac.uk/showcase/field.cgi?id=20197
#Picture vocabulary neurocog data (Vocabulary level) 2020 (f6364): https://biobank.ndph.ox.ac.uk/showcase/field.cgi?id=6364  

#Disconnect SQL connection
dbDisconnect(db)

## Formatting and saving data:
output_dir <- "/sc/arion/projects/rg_voloug01/UKBB_18177_EUR/neurocognitive_baseline_imaging"

# Pairs matching
head(ukbb_data_f399_pairs_matching_incorrect_2020)
unique(ukbb_data_f399_pairs_matching_incorrect_2020$instance) #multiple timepoints
unique(ukbb_data_f399_pairs_matching_incorrect_2020$array) #1 2 3
pairs_incorrect <- ukbb_data_f399_pairs_matching_incorrect_2020[which(ukbb_data_f399_pairs_matching_incorrect_2020$instance == 0),] #restrict to baseline only 

unique(pairs_incorrect$array) #1,2 --> Multiple rounds were conducted. The first round used 3 pairs of cards and the second 6 pairs of cards
pairs_incorrect$pheno <- as.numeric(pairs_incorrect$pheno)
#seems like other studies only took data from 2nd trial (when 6 pairs of cards shown) --> 
#see https://www.nature.com/articles/mp201645, https://bmjopen.bmj.com/content/6/11/e012177.short, https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0154222
pairs_incorrect_trial2 <- pairs_incorrect[which(pairs_incorrect$array == 2),]
table(pairs_incorrect_trial2$pheno)

pairs_incorrect_trial2 <- pairs_incorrect_trial2[,c(1,3)]
names(pairs_incorrect_trial2) <- c("sample_id", "pairs_matching")

write.table(pairs_incorrect_trial2, 
            file = paste0(output_dir, "/pairs_matching_baseline_trial2_only.tsv"), 
            quote=F,row.names=F,col.names=T, sep="\t")

#Reaction Time
head(ukbb_data_f20023_reaction_time_mean_2020)
unique(ukbb_data_f20023_reaction_time_mean_2020$instance) #0 1 2 3
reaction_time <- ukbb_data_f20023_reaction_time_mean_2020[which(ukbb_data_f20023_reaction_time_mean_2020$instance == 0),]

sum(duplicated(reaction_time$sample_id)) #0
reaction_time$pheno <- as.numeric(reaction_time$pheno)
reaction_time <- reaction_time[,c(1,3)]
names(reaction_time) <- c("sample_id", "reaction_time")

write.table(reaction_time, 
            file = paste0(output_dir, "/reaction_time_baseline.tsv"),
            quote=F,row.names=F,col.names=T, sep="\t")

#Fluid Intelligence/Reasoning
head(ukbb_data_f20016_fluid_intelligence_score_2020)
unique(ukbb_data_f20016_fluid_intelligence_score_2020$instance)
fluid_intelligence <- ukbb_data_f20016_fluid_intelligence_score_2020[which(ukbb_data_f20016_fluid_intelligence_score_2020$instance == 0),]
sum(duplicated(fluid_intelligence$sample_id)) #0
fluid_intelligence$pheno <- as.numeric(fluid_intelligence$pheno)

fluid_intelligence <- fluid_intelligence[,c(1,3)]
names(fluid_intelligence) <- c("sample_id", "fluid_intelligence")

write.table(fluid_intelligence, 
            file = paste0(output_dir, "/fluid_intelligence_baseline.tsv"), 
            quote=F,row.names=F,col.names=T, sep="\t")

#Numeric Memory
head(ukbb_data_f4282_numeric_memory_score_2020)
unique(ukbb_data_f4282_numeric_memory_score_2020$instance) #0 2 3
numeric_memory <- ukbb_data_f4282_numeric_memory_score_2020[which(ukbb_data_f4282_numeric_memory_score_2020$instance == 0),]
sum(duplicated(numeric_memory$sample_id)) #0
length(which(numeric_memory$pheno == -1)) #1444 --> -1 means participant abandoned test before completion
numeric_memory <- numeric_memory[which(numeric_memory$pheno != -1),] #remove these! 
numeric_memory$pheno <- as.numeric(numeric_memory$pheno)

numeric_memory <- numeric_memory[,c(1,3)]
names(numeric_memory) <- c("sample_id", "numeric_memory")

write.table(numeric_memory, 
            file = paste0(output_dir, "/numeric_memory_baseline.tsv"), 
            quote=F,row.names=F,col.names=T, sep="\t")

#Symbol digit substitution
head(ukbb_data_f23324_symbol_digits_correct_2020)
unique(ukbb_data_f23324_symbol_digits_correct_2020$instance) # 2 3 --> 2 is the imaging visit we want!
symbol_digits <- ukbb_data_f23324_symbol_digits_correct_2020[which(ukbb_data_f23324_symbol_digits_correct_2020$instance == 2),]
sum(duplicated(symbol_digits$sample_id)) #0
names(symbol_digits)[3] <- "correct"
symbol_digits$correct <- as.numeric(symbol_digits$correct)

# #Try to adjust for # of attempted: due to Notes on https://biobank.ndph.ox.ac.uk/showcase/field.cgi?id=23324
# head(ukbb_data_f23323_symbol_digits_attempted_2020)
# range(ukbb_data_f23323_symbol_digits_attempted_2020$pheno) #no 0s!
# unique(ukbb_data_f23323_symbol_digits_attempted_2020$instance) #2 3
# symbol_digits_attempted <- ukbb_data_f23323_symbol_digits_attempted_2020[which(ukbb_data_f23323_symbol_digits_attempted_2020$instance == 2),]
# sum(duplicated(symbol_digits_attempted$sample_id)) #0
# names(symbol_digits_attempted)[3] <- "attempted"
# symbol_digits_attempted$attempted <- as.numeric(symbol_digits_attempted$attempted)
# symbol_digits_attempted$instance <- NULL
# symbol_digits <- left_join(symbol_digits, symbol_digits_attempted, by = "sample_id")
# symbol_digits$ratio <- symbol_digits$correct/symbol_digits$attempted
# hist(symbol_digits$ratio) #left-skewed
# 
# skewness(symbol_digits$ratio, na.rm = TRUE) #-4.714211
# symbol_digits$ratio_transformed <- 1/(max(symbol_digits$ratio+1) - symbol_digits$ratio)
# skewness(symbol_digits$ratio_transformed, na.rm = TRUE) #-2.8615
# hist(symbol_digits$ratio_transformed)
# #none of the transformations work... let's abandon the ratio idea 

symbol_digits <- symbol_digits[,c(1,3)]
names(symbol_digits) <- c("sample_id", "symbol_digits")

write.table(symbol_digits, 
            file = paste0(output_dir, "/symbol_digits_imaging_visit.tsv"), 
            quote=F,row.names=F,col.names=T, sep="\t")

#Trail Making Numeric 
head(ukbb_data_f6348_trail_making_numeric_duration_2020)
unique(ukbb_data_f6348_trail_making_numeric_duration_2020$instance) #2 3 
trail_making_numeric <- ukbb_data_f6348_trail_making_numeric_duration_2020[which(ukbb_data_f6348_trail_making_numeric_duration_2020$instance == 2),]
sum(duplicated(trail_making_numeric$sample_id)) #0
range(trail_making_numeric$pheno) #0,988
length(which(trail_making_numeric$pheno == 0)) #417 --> 0 means trial was not completed
trail_making_numeric <- trail_making_numeric[which(trail_making_numeric$pheno != 0),] #remove
trail_making_numeric$pheno <- as.numeric(trail_making_numeric$pheno)

trail_making_numeric <- trail_making_numeric[,c(1,3)]
names(trail_making_numeric) <- c("sample_id", "trail_making_numeric")

write.table(trail_making_numeric, 
            file = paste0(output_dir, "/trail_making_numeric_imaging_visit.tsv"), 
            quote=F,row.names=F,col.names=T, sep="\t")

#Trail Making Alphanumeric
head(ukbb_data_f6350_trail_making_alphanumeric_duration_2020)
unique(ukbb_data_f6350_trail_making_alphanumeric_duration_2020$instance) # 2 3 
trail_making_alphanumeric <- ukbb_data_f6350_trail_making_alphanumeric_duration_2020[which(ukbb_data_f6350_trail_making_alphanumeric_duration_2020$instance == 2),]
sum(duplicated(trail_making_alphanumeric$sample_id))
length(which(trail_making_alphanumeric$pheno == 0)) #1272 --> 0 means trial was not completed
trail_making_alphanumeric <- trail_making_alphanumeric[which(trail_making_alphanumeric$pheno != 0),] #remove
trail_making_alphanumeric$pheno <- as.numeric(trail_making_alphanumeric$pheno)

trail_making_alphanumeric <- trail_making_alphanumeric[,c(1,3)]
names(trail_making_alphanumeric) <- c("sample_id", "trail_making_alphanumeric")

write.table(trail_making_alphanumeric, 
            file = paste0(output_dir, "/trail_making_alphanumeric_imaging_visit.tsv"), 
            quote=F,row.names=F,col.names=T, sep="\t")

#Matrix Reasoning
head(ukbb_data_f6373_matrix_reasoning_2020)
unique(ukbb_data_f6373_matrix_reasoning_2020$instance) #2 3
matrix_reasoning <- ukbb_data_f6373_matrix_reasoning_2020[which(ukbb_data_f6373_matrix_reasoning_2020$instance == 2),]
sum(duplicated(matrix_reasoning$sample_id)) #0 
matrix_reasoning$pheno <- as.numeric(matrix_reasoning$pheno)
names(matrix_reasoning)[3] <- "correct"

head(ukbb_data_f6374_matrix_reasoning_attempted_2020)
unique(ukbb_data_f6374_matrix_reasoning_attempted_2020$instance) #2 3 
matrix_reasoning_attempted <- ukbb_data_f6374_matrix_reasoning_attempted_2020[which(ukbb_data_f6374_matrix_reasoning_attempted_2020$instance == 2),]
sum(duplicated(matrix_reasoning_attempted$sample_id)) #0
matrix_reasoning_attempted$pheno <- as.numeric(matrix_reasoning_attempted$pheno)
names(matrix_reasoning_attempted)[3] <- "attempted"
matrix_reasoning_attempted$instance <- NULL
matrix_reasoning <- left_join(matrix_reasoning, matrix_reasoning_attempted, by = "sample_id")
matrix_reasoning$ratio <- matrix_reasoning$correct/matrix_reasoning$attempted

matrix_reasoning <- matrix_reasoning[,c(1,5)]
names(matrix_reasoning) <- c("sample_id", "matrix_reasoning")

write.table(matrix_reasoning, 
            file = paste0(output_dir, "/matrix_reasoning_imaging_visit_correct_div_by_attempted.tsv"), 
            quote=F,row.names=F,col.names=T, sep="\t")

# Tower Rearranging
head(ukbb_data_f21004_tower_rearranging_2020)
unique(ukbb_data_f21004_tower_rearranging_2020$instance) # 2 3
tower_rearranging <- ukbb_data_f21004_tower_rearranging_2020[which(ukbb_data_f21004_tower_rearranging_2020$instance == 2),]
sum(duplicated(tower_rearranging$sample_id)) #0
tower_rearranging$pheno <- as.numeric(tower_rearranging$pheno)

tower_rearranging <- tower_rearranging[,c(1,3)]
names(tower_rearranging) <- c("sample_id", "tower_rearranging")

write.table(tower_rearranging, 
            file = paste0(output_dir, "/tower_rearranging_imaging_visit.tsv"), 
            quote=F,row.names=F,col.names=T, sep="\t")

# Prospective Memory
head(ukbb_data_f20018_prospective_memory_score_2020)
unique(ukbb_data_f20018_prospective_memory_score_2020$instance) #0,1,2,3,4
prospective_mem <- ukbb_data_f20018_prospective_memory_score_2020[which(ukbb_data_f20018_prospective_memory_score_2020$instance == 0),]
unique(prospective_mem$pheno) #0,1,2
#0 = Instruction not recalled, either skipped or incorrect, 1 = Correct recall on first attempt, 2 = 	Correct recall on second attempt
prospective_mem <- prospective_mem[which(prospective_mem$pheno != 0),] 
sum(duplicated(prospective_mem$sample_id)) #0
prospective_mem$pheno <- as.numeric(prospective_mem$pheno)

prospective_mem <- prospective_mem[,c(1,3)]
names(prospective_mem) <- c("sample_id", "prospective_memory")

write.table(prospective_mem, 
            file = paste0(output_dir, "/prospective_memory_baseline_binary.tsv"), 
            quote=F,row.names=F,col.names=T, sep="\t")
