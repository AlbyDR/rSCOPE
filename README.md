## rSCOPE
Run SCOPE model from R. There are functions to download and interpolate the DWD data to use as model inputs. Download Berlin Enviromental Atlas maps. Calculate zd/z0 and hourly footprints to extract information about surface properties from raster layers (e.g. LAI, vegetation height and #' vegetation cover). Organize the model inputs and run SCOPE. Get the parameters (input, constant and settings), calculate model accuracy.

##### devtools::install_github("AlbyDR/rSCOPE")
##### library(rSCOPE)

#### MATLAB R2015b or supirior is required to run SCOPE and the SCOPE code need to be downloaded and unziped in a diretor of you choice. The SCOPE code is available at https://github.com/Christiaanvandertol/SCOPE/releases/tag/v2.0 and the documentation at https://scope-model.readthedocs.io/en/latest/

#### FREddyPro is need to extrat footprints
install.packages("https://cran.r-project.org/src/contrib/Archive/FREddyPro/FREddyPro_1.0.tar.gz", repo = NULL, type = "source")
