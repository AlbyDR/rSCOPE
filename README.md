## rSCOPE
Run SCOPE model from R. There are functions to download and interpolate the DWD data to use as model inputs. Download Berlin Environmental Atlas maps. Calculate zd/z0 and hourly footprints to extract information about surface properties from raster layers (e.g. LAI, vegetation height and #' vegetation cover). Organize the model inputs and run SCOPE. Get the parameters (input, constant and settings), calculate model accuracy. Functions to generate Urban ET maps and indices of greening cooling services, and also create a animate 24 hours or month ET GIF maps. 

#### devtools::install_github("AlbyDR/rSCOPE")
#### library(rSCOPE)

#### Citation
Duarte Rocha, A.: AlbyDR/rSCOPE: rSCOPE v1.0 (Evapotranspiration), Zenodo [code], https://doi.org/10.5281/zenodo.6204580, 2022.

#### References
Rocha, A. D., Vulova, S., Meier, F., Förster, M., & Kleinschmit, B. (2022). Mapping evapotranspirative and radiative cooling services in an urban environment. SSRN Electronic Journal, 85. https://doi.org/10.2139/ssrn.4089553.

Duarte Rocha, A., Vulova, S., van der Tol, C., Förster, M., and Kleinschmit, B.: Modelling hourly evapotranspiration in urban environments with SCOPE using open remote sensing and meteorological data, Hydrol. Earth Syst. Sci., 26, 1111–1129, https://doi.org/10.5194/hess-26-1111-2022, 2022.

#### Code repository
The codes to run the rSCOPE package for the input pre-processing, modelling and mapping for the Berlin study case is available in the GitHub https://github.com/AlbyDR/URBAN_ET

#### Data repository
Duarte Rocha, A. (2022). Berlin Evapotranspiration and Cooling Services. https://doi.org/10.14279/depositonce-15870

#### MATLAB R2015b or superior is required to run SCOPE and the SCOPE code need to be downloaded and unzipped in a directory of your choice. The SCOPE code is available at https://github.com/Christiaanvandertol/SCOPE/releases/tag/v2.0 and the documentation at https://scope-model.readthedocs.io/en/latest/

#### FREddyPro is needed to extrat footprints
install.packages("https://cran.r-project.org/src/contrib/Archive/FREddyPro/FREddyPro_1.0.tar.gz", repo = NULL, type = "source")

### Methodology framework
The flowchart shows the two-stage modelling processing to derive urban ET and greening cooling service index from open-access data inputs.

<img src="https://user-images.githubusercontent.com/40297927/179981190-b0a6445c-e067-40cd-8e4c-78d7d809bad7.png" width=70% height=70%>

###### Fig. Flowchart of the two-stage modelling approach to derive urban ET from open-access data inputs.

### Output products:

  - Urban ET [mm] for different aggregation periods (from hourly to annual) that can be divided by soil and canopy.

<img src="https://user-images.githubusercontent.com/40297927/179995862-a31b8c07-e85e-4b4f-853c-35d06788b16e.png" width=80% height=80%>

###### Fig. Map of annual ET for Berlin in 2020 (a), zoom-in for the surroundings of the two EC towers, the built-up area TUCC (b) and the residential area ROTH (c), and an urban forest close to residential areas. The distribution of daily modelled ET in the year 2020 at the three locations (e), the red line (built-up area), the black (residential area) and the green (urban forest). The daily ET values from the two towers were extracted (average) using footprints, while the forest values were extracted for the specific forest polygon. Water bodies are not considered in the model and are represented in white.

  - Greening cooling service index (GCoS) and two sub-indices: Evapotranspirative Cooling Service (ECoS) and Radiative Cooling Service (RCoS).

<img src="https://user-images.githubusercontent.com/40297927/179998177-d884881d-7e04-4420-bc66-aa5e3dd819f8.png" width=80% height=80%>

###### Fig. Greening cooling service index for the hottest day in 2020 (8th of August) - Berlin (a). The two sub-indices: Evapotranspirative Cooling Service (b) and Radiative Cooling Service. GCoS for six locations (1 km2) for which different surface characteristics (see below LC/LU – Copernicus, Urban Atlas - 2018).
