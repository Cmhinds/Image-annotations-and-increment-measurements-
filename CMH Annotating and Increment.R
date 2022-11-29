#Incremental aging code #### 
# Author: Chris Hinds with original code by Derek Ogle and Taylor Cubbage
#https://fishr-core-team.github.io/RFishBC/articles/collectRadiiData.html
#Date: 11/16/22

#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++####

#Imaging####
#Images in IPP 10 need to be Published with the scale bar burned into the calibrated image 
#Configure "Quick Save to Publication to prompt for file name and un-check current zoom box, file type Tif, set image size to 0
#Scale bars need to be standardized to 2mm across ALL images
#Images need to be stored in folders separated by magnifications or taken at one magnification  
#All images need to be saved as all Tiff or all jpg. You can't change between formats.
#Example of nomenclature: M125C_0.8_DMC4500_0.63x_22LC_103_1 (the _ is very important!)

#Install packages####

#install.packages("renv")
#install.packages("renv", repos = "https://rstudio.r-universe.dev")
#renv::init() #makes the folder that stores the library for the project
#renv::activate() #takes snapshot of current libraries and stores versions in folder
#only have to run renv when you add more packages

#install.packages("RFishBC")
library(RFishBC)
library(dplyr) 


#Setting working directory.#### 
#This is where the IPP images are saved on your computer (V drive)
#Images should be in all Jpegs or all TiffS and have nomenclature by magnification and _specimen number at the end.
#getwd() if needed
#remember that you need two \\ or one / to code directories
setwd("V:\\ADU\\Chris test images for RFishBC\\R1 710 22LC~103\\M125C_0.8_DMC4500_0.63x")

#Set your images (imgs) and specimens (ids) as Characters for the first magnification.Populates in Env####
imgs <- listFiles("tif",other="0.8")
ids <- getID(imgs)

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++####

#digitizeRadii will pull up the first specimen image to be annotated and set some default settings#### 
#SINGLE IMAGE imgs[#] is which image/set of images you are calling (example 0.8x) 
#SINGLE SPECIMEN id=ids[#] is the specimen number/s you want (example specimen 1)
#MULTIPLE IMAGES OR SPECIEMNS digitizeRadii(imgs[1:3],id=ids[1:3] calls up ids and imgs from Environment
#"Reading" is the reader's initials (mine is CMH, replace with your initials). Multiple readers on one image or multiple reads on one image allowed
#edgeIsAnnulus = FALSE if you do not want to count the edge OR = TRUE if you count the edge
#makeTransect = FALSE to follow the curve of the specimen OR = TRUE to place a straight transect
#snap2Transect = True if Coordinates of annuli are moved to fall exactly on the transect from the structure center. If FALSE the annuli will be where you place them regardless of transect line
#ScaleBar = TRUE if you have a scale bar in the image OR FASLE if you upload an image without a bar (calibrate a measurement please refer to https://fishr-core-team.github.io/RFishBC/articles/collectRadiiData.html)
#scalebarlength = standardized 2mm
#scalebarunit = mm
#To include the radial measurement with “plus-growth” then use deletePlusGrowth=FALSE
#addNote = TRUE user will be prompted to add a special note to the RData file. Example: image was poor, some annuli were suspect
#windowSize defaults to 7 and >7 is how you make the image window bigger aka zoom
######zoom in and out: Actual size = ctrl + 0, zoom in = ctrl ++, zoom out = crtl +- (does this work?)

RFBCoptions() #see or set arguments for annotating, https://fishr-core-team.github.io/RFishBC/reference/RFBCoptions.html

#imgs [how many images total], id=ids [how many specimens total, not specimen #]. Specimen # will populate on image
digitizeRadii(imgs[1:3],id=ids[1:3],reading="CMH",edgeIsAnnulus=FALSE, scaleBar = TRUE, 
              scaleBarLength = 2, scaleBarUnits = "mm",makeTransect = FALSE, windowSize = 25) #3 images and 3 different ids

#Annotations (capitalization matters!)
# f for finish will move to the next task/image
# d for delete will delete the point you just marked
# q for abort will skip the current image and move to the next image - takes you to next image
# z for restart will let you begin labeling the current image again
# k for kill will exit out of labeling images but save the previously labeled images - saves previous image and exits out

#When the image comes up, measure the scale bar in the image to give a reference point for the annual increments.Check console. Select F when done.
#Mark the focus/origin of the specimen, each annulus, then mark the margin/edge of the specimen. Select F when done.  
#All measurements are saved in an R file that is created for each specimen (.rds file) in your Setwd()
#Check the console for warnings and run warnings() to see them

warnings()

#To view the annotated image####
#showDigitizedImage Shows annotations. Able to re-examinine annotations overlay selected points from multiple readings of the structure.
#connect = TRUE if the selected points should be connected with a line and FALSE for annotations only. Default = TRUE
#Must not annotate out of order. The annuli numbers won't match up if you go out of order.


showDigitizedImage("M125C_1.0x_0.8x_DMC4500_0.63x_22LC_103_1_CMH.rds")
showDigitizedImage("M125C_1.0x_0.8x_DMC4500_0.63x_22LC_103_2_CMH.rds")
showDigitizedImage("M125C_1.0x_0.8x_DMC4500_0.63x_22LC_103_3_CMH.rds")
showDigitizedImage("M125C_1.0x_0.8x_DMC4500_0.63x_22LC_103_3_CMH.rds", connect = TRUE)
showDigitizedImage("M125C_1.0x_0.8x_DMC4500_0.63x_22LC_103_3_CMH.rds", 
                   connect = FALSE) #False takes the point to point lines away

#You can also manipulate the display colors/shapes
showDigitizedImage("M125C_1.0x_0.8x_DMC4500_0.63x_22LC_103_1_CMH.rds",pch.show="+",col.show="blue",
                   col.connect="red",col.ann="black",cex.ann=1,
                   annuliLabels=c(1:4))

#You can also visualize different readers' annotations on the same structure. Let's say reader CMH reads M125C_1.0x_0.8x_DMC4500_0.63x_22LC_103_1_CMH.rds
digitizeRadii(imgs[1],id=ids[1],reading="CMH"#Update with your initials
              ,edgeIsAnnulus=FALSE, scaleBar = TRUE, scaleBarLength = 2, scaleBarUnits = "mm", makeTransect = FALSE)

#Now, lets make an object just containing the different readings of M125C_1.0x_0.8x_DMC4500_0.63x_22LC_103_1_CMH.rds by readers CMH and KWM
compare_readers <- listFiles("rds",other="M125C_1.0x_0.8x_DMC4500_0.63x_22LC_103_1_CMH.rds")

#And visualize them together
showDigitizedImage(compare_readers,col.show=c("yellow","red"),
                   col.connect=c("red","yellow"),lwd.connect=2)


#########figure out how to combine all the images so you can view them all in succession 
#showDigitizedImage(c("M125C_1.0x_0.8x_DMC4500_0.63x_22LC_103_1_CMH.rds",
"M125C_1.0x_0.8x_DMC4500_0.63x_22LC_103_2_CMH.rds",
"M125C_1.0x_0.8x_DMC4500_0.63x_22LC_103_3_CMH.rds"))

# if images won't open you have an old image open
# if you can't see the whole image or the scale bar in the photo, make the window a bit bigger by pulling on the edges. 

#visualize .rds files we just saved ####
#listfile This returns a vector with all file names with the ext extension in the path folder/directory. 
#In RfishBC this is used primarily to create a list of image file names for use in digitizeRadii or RData file names
#created with digitizeRadii and to be given to combineData.

listFiles("rds")

#Create object of .rds files (code won't accept numbers first, populates in Env)
X0.8_22LC_103_CMH <- listFiles("rds",other=c("0.8","CMH"))

#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++####

# Do this for the 1.25x magnification images#### 
getwd()
setwd("V:\\ADU\\Chris test images for RFishBC\\R1 710 22LC~103\\M125C_1.25_DMC4500_0.63x")

imgs <- listFiles("tif",other="1.25")

ids <- getID(imgs)

digitizeRadii(imgs[1:3],id=ids[1:3],reading="CMH",edgeIsAnnulus=FALSE, scaleBar = TRUE, 
              scaleBarLength = 2, scaleBarUnits = "mm", makeTransect = FALSE, windowSize = 25)

warnings()

showDigitizedImage("M125C_1.0x_1.25x_DMC4500_0.63x_22LC_103_4_CMH.rds", connect = FALSE) #windowSize = 25 if needed
showDigitizedImage("M125C_1.0x_1.25x_DMC4500_0.63x_22LC_103_5_CMH.rds", connect = FALSE)
showDigitizedImage("M125C_1.0x_1.25x_DMC4500_0.63x_22LC_103_6_CMH.rds", connect = FALSE)


listFiles("rds")

X1.25_22LC_103_CMH <- listFiles("rds",other=c("1.25","CMH"))

#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++####

#Do this for 1.0X magnification images ####
setwd("V:\\ADU\\Chris test images for RFishBC\\R1 710 22LC~103\\M125C_1.0_DMC4500_0.63x")

imgs <- listFiles("tif",other="1.0")

ids <- getID(imgs)

digitizeRadii(imgs[1:3],id=ids[1:3],reading="CMH",edgeIsAnnulus=FALSE, scaleBar = TRUE, 
              scaleBarLength = 2, scaleBarUnits = "mm", makeTransect = FALSE, windowSize = 25)

showDigitizedImage("M125C_1.0x_1.00x_DMC4500_0.63x_22LC_103_7_CMH.rds", connect = FALSE) ##windowSize = 25 if needed
showDigitizedImage("M125C_1.0x_1.00x_DMC4500_0.63x_22LC_103_8_CMH.rds", connect = FALSE)
showDigitizedImage("M125C_1.0x_1.00x_DMC4500_0.63x_22LC_103_9_CMH.rds", connect = FALSE)

listFiles("rds")

X1.0_22LC_103_CMH <- listFiles("rds",other=c("1.0","CMH"))

#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++####

#Combining annotated images (rds) into a single file####
#Go into the separate magnification value folders and pull out and combine all the .rds files into a single folder. 
#Setwd to the new folder  

setwd("V:\\ADU\\Chris test images for RFishBC\\R1 710 22LC~103\\22LC~103 Annotated Images .RDS files")

#now we make long and wide formats of the data.#### 
#It will include ID, the reader, age at capture, total radius at capture, and radius at each annuli. 
#The long format is required to backcalculate length at age with the Fraser-lee model using the code below. 
#Then I turn it into a wide format to convert change in FL across ages to growth in mm/day using excel. 
#combine the Values (chr in Env. box) you set for each magnification rds file. Name spreadsheet with the structure and ID 
#Rename the combined data with the sample ID and what structure 
Oto_22LC_103_CMH_long_all_mm <- combineData(c(X0.8_22LC_103_CMH,X1.0_22LC_103_CMH,
                                              X1.25_22LC_103_CMH), formatOut= "long")

Oto_22LC_103_CMH_wide_all_mm <- combineData(c(X0.8_22LC_103_CMH,X1.0_22LC_103_CMH,
                                              X1.25_22LC_103_CMH), formatOut= "wide")


#Saving csv file of increments - update with your initials.
#these populate in the RDS folder as excel csv files
write.csv(Oto_22LC_103_CMH_long_all_mm,file="Oto_22LC_103_CMH_long.csv",
          quote=FALSE,row.names=FALSE)
write.csv(Oto_22LC_103_CMH_wide_all_mm,file="Oto_22LC_103_CMH_wide.csv",
          quote=FALSE,row.names=FALSE)

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++####

#CODE NOT DONE BELOW THIS LINE#### #Pull images from reference collection and call in associated somatic data from .csv

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++####

#Back-calculating lengths and other random code####
#You will need Fork Length data for each specimen


#Reading in dataframe with biological/catch data associated with each specimen

setwd("/Users/tlcubbage/OneDrive - University of Alaska/Documents/UAF1/Thesis materials/Pike collection_summer20/Cleithra")

#read in CSV with fish ID and length at capture. Data must include Sample ID and length at capture
pike_cleithra <- read.csv("pike_ID_data.csv", stringsAsFactors=FALSE) %>%
  mutate(id=as.character(id))

str(pike_cleithra)
unique(pike_cleithra$id)

#Joining the two dataframes to include both biological/catch/ and increments####
pike_cleithra_TLC_long <- pike_cleithra %>%
  inner_join(dfrad_TLC_long,by="id")
str(pike_cleithra_TLC_long)
pike_cleithra_TLC_long$Population <- trimws(pike_cleithra_TLC_long$Population, which = "both")
pike_cleithra_TLC_long$Habitat <- trimws(pike_cleithra_TLC_long$Habitat, which = "both")
pike_cleithra_TLC_long$Population_Habitat <- paste(pike_cleithra_TLC_long$Population, pike_cleithra_TLC_long$Habitat, sep = " ")
table(pike_cleithra_TLC_long$Population_Habitat)

pike_cleithra_TLC_wide <- pike_cleithra %>%
  inner_join(dfrad_TLC_wide,by="id")
str(pike_cleithra_TLC_wide)
pike_cleithra_TLC_wide$Population <- trimws(pike_cleithra_TLC_wide$Population, which = "both")
pike_cleithra_TLC_wide$Habitat <- trimws(pike_cleithra_TLC_wide$Habitat, which = "both")
pike_cleithra_TLC_wide$Population_Habitat <- paste(pike_cleithra_TLC_wide$Population, pike_cleithra_TLC_wide$Habitat, sep = " ")
table(pike_cleithra_TLC_wide$Population_Habitat)
str(pike_cleithra_TLC_wide)



#Saving csv file of pike bio data and cleithral increments ####
write.csv(pike_cleithra_TLC_long,file="Pike_Cleithra_all_dat_TLC_long.csv",quote=FALSE,row.names=FALSE)
write.csv(pike_cleithra_TLC_wide,file="Pike_Cleithra_all_dat_TLC_wide.csv",quote=FALSE,row.names=FALSE)
#Visualizing relationship between Fork length and radius at capture (radcap) to make sure there is a high association ####

ggplot(pike_cleithra_TLC_long, aes(x = Fork_Length_mm, y = radcap, col = Location))+
  geom_point()+
  geom_smooth(method = "lm")+
  ggtitle("Fork length positively associated with cleithra radius \n across locations")

lm_radius_fl <- lm(radcap ~ Fork_Length_mm + Location, data = pike_cleithra_TLC_long)
summary(lm_radius_fl)
#R squared = 0.886 
#Location does not signficantly affect the relationship between radius and fork length 


#Using the RFishBC Fraser-Lee model to estimate lengths #### 
#the alpha parameter is the size of the grayling in mm at fin ray formation, e.g. the biological intercept. Study on Bull trout < 300 mm used an alpha of 20, which might
#be a good proxy for grayling. 
pike_length_est_long <- backCalc(pike_cleithra_TLC_long,lencap = "Fork_Length_mm",BCM="FRALE",inFormat="long", a = 20, digits=0)
pike_length_est_long_test_false <- backCalc(pike_cleithra_TLC_long,lencap = "Fork_Length_mm",BCM="FRALE",inFormat="long", a = 20, deletePlusGrowth = FALSE, digits=0)

# I used a different back calculation formula for my final length estimations, but I think this wide format version should work for your grayling.
pike_length_est_wide <- backCalc(pike_cleithra_TLC_wide,lencap = "Fork_Length_mm",BCM="FRALE",inFormat="wide", a = 20, digits=0)

#Then save it as a csv, open it in excel, and I can send you my example excel sheet of how I took this data and calculated growth in mm/day for each age, ####
#by basically dividing the length of the growing season by the change in FL for that year of life of the grayling. This growing season varies only for the YOY 
#period, and the year of capture. Ie instead of the grayling growing between May and September for example, it would grow from May until day of capture.
write.csv(pike_length_est_long,file="pike_estlengths_fraser_lee_long_update.csv",quote=FALSE,row.names=FALSE)
write.csv(pike_length_est_wide,file="pike_estlengths_fraser_lee_wide_update.csv",quote=FALSE,row.names=FALSE)
pike_length_est_long <- read.csv("pike_estlengths_fraser_lee_long.csv", header = TRUE, sep = ",")
View(pike_length_est_long)

#plotting age vs length ####
ggplot(pike_length_est_long, aes(y = Fork_Length_mm, x = agecap, col = Location))+
  geom_point()+
  geom_smooth(method = "lm")

ggplot(pike_length_est_long, aes(y = bclen, x = ann, col = Sex))+
  geom_point()+
  geom_smooth(method = "lm")

#Linear modeling ####
mod1 <- lm(Fork_Length_mm ~ agecap + Location + Sex + Maturity, data = pike_length_est_long)
summary(mod1)

pike_length_est_long$agecap <- as.character(pike_length_est_long$agecap)

ggplot(pike_length_est_long, aes(x = Fork_Length_mm, y = Weight_g, col= agecap))+
  geom_point()+
  facet_wrap(~Population_Habitat)


#visualizing mean size at age among populations ####
#Creating mean size at age table ####

pike_cleithra_plus_age <- read.csv("pike_estlengths_fraser_lee_long_plusage.csv", header = TRUE, sep = ",")


size_at_age1 <- aggregate(pike_length_est_long$bclen, list(pike_length_est_long$ann,pike_length_est_long$Population_Habitat), mean)
size_at_age_sd1 <- aggregate(pike_length_est_long$bclen, list(pike_length_est_long$ann,pike_length_est_long$Population_Habitat), sd)
colnames(size_at_age1) <-c("Age","Population","Forklength")
colnames(size_at_age_sd1) <-c("Age","Population","St.dev")

size_at_age2 <- aggregate(pike_cleithra_plus_age$Fork_Length_mm, list(pike_cleithra_plus_age$agecap,pike_cleithra_plus_age$Population_Habitat), mean)
size_at_age_sd2 <- aggregate(pike_cleithra_plus_age$Fork_Length_mm, list(pike_cleithra_plus_age$agecap,pike_cleithra_plus_age$Population_Habitat), sd)
colnames(size_at_age2) <-c("Age","Population","Forklength")
colnames(size_at_age_sd2) <-c("Age","Population","St.dev")

size_at_age_1 <- left_join(size_at_age1, size_at_age_sd1, by = c("Age", "Population"))

size_at_age_2 <- left_join(size_at_age2, size_at_age_sd2, by = c("Age", "Population")) 

size_at_age_all <- rbind(size_at_age_1,size_at_age_2)

size_at_age_all$Age <- as.character(size_at_age_all$Age)
table(size_at_age_all$Age)

dev.off()

ggplot(size_at_age_all, aes( x = Age, y = Forklength ))+
  geom_density()+
  facet_wrap(~ Population)

ggplot(size_at_age_all, aes(x=Age, y=Forklength, fill = Population)) + 
  geom_bar(stat="identity", position=position_dodge())+
  geom_errorbar(aes(ymin=Forklength-St.dev, ymax=Forklength+St.dev), width=.2,position=position_dodge(.9))



