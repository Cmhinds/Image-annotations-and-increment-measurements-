################# Cleithra aging and increment analysis example  
################# Author: Taylor Cubbage
################# Date: 11/26/22

#####Installing packages
install.packages("RFishBC")
install.packages("dplyr")
install.packages("FSA")
install.packages("ggplot2")
library(RFishBC)
library(dplyr)
library(FSA)
library(ggplot2)

######Setting working directory. This is where all the cleithra photos and biological datasheet are saved on your computer, so be sure to update accordingly.
setwd("S:\\Shared\\R packages\\Cubbage_RFishBC_Demo\\example_cleithra")


#Creating object of all images with names Cleithra and ending in .jpg
imgs <- listFiles("jpg",other="Cleithra")
#Creating object of all image ID's 
ids <- getID(imgs)

#This next command will pull up the first cleithrum to be labeled with annuli increments. 
#"Reading" is the reader's initials (mine is Taylor Lindsey CUbbage TLC, please update with your initials), edgeIsAnnulus = false
#because pike were still growing at time of capture, makeTransect = false because if true, it makes
#a straight line rather than following the curve of the cleithra. ScaleBar = TRUE because I have a scale bar in the photo.
#When the image comes up, the first task will be to create a 1 mm scale bar on the multiple-mm measuring tape in the photo to give a reference
#point for the annuli increments.Then once the scale bar is labeled, hit "f" and it will ask you to mark the focus/origin of the cleithrum,
#then each annuli, then lastly the margin/edge of the cleithrum and hit "f". All measurements are saved in an R file that is created for each cleithrum. 

#let's annotate the first cleithrum
digitizeRadii(imgs[1],id=ids[1],reading="TLC"#Update with your initials
              ,edgeIsAnnulus=FALSE, scaleBar = TRUE, scaleBarLength = 1, scaleBarUnits = "mm", makeTransect = FALSE, snap2Transect = FALSE)

#Check over the cleithrum that was labeled. Cool right?
showDigitizedImage("Cleithra_1224_TLC.rds")#Update with your initials

#You can also manipulate the display colors/shapes
showDigitizedImage("Cleithra_1224_TLC.rds",pch.show="+",col.show="blue",
                   col.connect="red",col.ann="black",cex.ann=1,
                   annuliLabels=c(1:4))

#You can also visualize different readers' annotations on the same structure. Let's say reader TCL reads cleithra 1224:
digitizeRadii(imgs[1],id=ids[1],reading="TCL"#Update with your initials
              ,edgeIsAnnulus=FALSE, scaleBar = TRUE, scaleBarLength = 1, scaleBarUnits = "mm", makeTransect = FALSE, snap2Transect = FALSE)

#Now, lets make an object just containing the different readings of cliethra 1224 by readers TLC and TCL
compare_readers <- listFiles("rds",other="Cleithra_1224")

#And visualize them together
showDigitizedImage(compare_readers,col.show=c("yellow","red"),
                   col.connect=c("red","yellow"),lwd.connect=2)

###########Commands within digitize radii

# f for finish will move to the next task/image
# d for delete will delete the point you just marked
# q for abort will skip the current image and move to the next image
# z for restart will let you begin labelling the current image again
# k for kill will exit out of labelling images but save the previously labeled images

##########Troubleshooting

# if you try to run code to start labelling images but don't see anything pop up, it's likely you have an old pop-up open and need to close it.
# if you can't see the whole cleithrum in the photo, make the window a bit bigger by pulling on the edges.

#The annuli are the clear, translucent parts of the cleithra during the winter, the thick opaque bands are during faster summer growth
#The edge is always a little translucent and is probably not an annuli because most of the pike would have grown some since the previous "winter" annuli

#This line of code will run you through the next nine cleithra so you have an idea of how it works!

digitizeRadii(imgs[2:10],id=ids[2:10],reading="TLC",edgeIsAnnulus=FALSE, scaleBar = TRUE, scaleBarLength = 1, scaleBarUnits = "mm", makeTransect = FALSE, snap2Transect = FALSE)

#Now let's summarize the data

#Visualize all the files you just created 
listFiles("rds")

#Creating a data frame to hold all the cleithra increments. Please update with your initials.
fns_TLC_ex <- listFiles("rds",other=c("Cleithra","TLC"))
dfrad_TLC_ex <- combineData(fns_TLC_ex,formatOut="long") #you can do this in wide or long format, depending on your needs

dfrad_TLC_ex # in this long format, we have a line for each annuli radius depending on how old each pike is. E.g., four lines for pike 1224 because it was aged at 4 years

dfrad_TLC_ex_wide <- combineData(fns_TLC_ex,formatOut="wide")

#Saving csv file of pike cleithra increments - update with your initials.
write.csv(dfrad_TLC_ex,file="Pike_Cleithra_TLC_ex.csv",quote=FALSE,row.names=FALSE)



####################### Back-calculating lengths

#Reading in dataframe with biological/catch data associated with each pike 

pike_data <- read.csv("Pike_ID_data_example.csv", stringsAsFactors=FALSE) %>% #You need a column in the 
  mutate(id= as.character(id))                                                #catch data with the same "id" name as 
#the one we just made to join the dataframes together
str(pike_data)

#Joining the two dataframes to include both biological/catch/ and cleithral radii
pike_data_all <- pike_data %>%
  inner_join(dfrad_TLC_ex,by="id")

pike_data_all #TAKE A LOOK AT THE DATA IN CONSOLE

#Saving csv file of pike bio data and cleithral increments
write.csv(pike_data_all,file="Pike_data_all_ex.csv",quote=FALSE,row.names=FALSE)

#Observing relationship between Pike FL and cleithral radius. Important, because the Fraser-Lee model is based on this association
ggplot(pike_data_all, aes(x = FL, y = radcap))+
  geom_point()+
  geom_smooth(method = "lm")

#Using the RFishBC Fraser-Lee model to back-calculate lengths  
#lencap is the length at capture, BCM is the model being used (with specific codes for each model), informat is the type of dataframe we are 
#supplying, a is the size of the pike in mm at cleithral formation, e.g. the biological intercept found from the literature, and digits are the
#number of decimal places the model will estimate out the back calculated lengths. digits = 0 will give us whole number FLs, e.g. 455 mm
pike_length_est_ex <- backCalc(pike_data_all,lencap = "FL",BCM="FRALE",inFormat="long", a = 8.6, digits=0) 

pike_length_est_ex #Woohoo! now we have back calculated lengths for each age of each individual pike 

#Save that data
write.csv(pike_length_est_ex,file="pike_estlengths_fraser_lee_ex.csv",quote=FALSE,row.names=FALSE)

#Let's summarize the data
pike_length_est_ex %>%
  group_by(ann) %>%
  summarize(n=validn(bclen),
            mn=round(mean(bclen),0),
            sd=round(sd(bclen),1)) %>%
  as.data.frame()

#Let's plot backcalculated lenghts vs age 
ggplot(pike_length_est_ex, aes(y = bclen, x = ann))+
  geom_point()+
  geom_smooth(method = "loess")+
  ylab("Back-calculated length")+
  xlab("Fish age")

