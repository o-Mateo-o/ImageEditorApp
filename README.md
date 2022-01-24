# <span style="color:#e9967a"><p align = "center">**Transformations of colors matrices - algorithms of graphics editing implementations in Julia** </p></span>

## <span style="color:	#ffb6c1">**This application was made as a course assignment.**</span>
 
Faculty of Pure and Applied Mathematics at Wroclaw Univeristy of Science and Technology.
 

## <span style="color:  #ffb6c1">**Short program description**</span>
<div style="text-align: justify">This program is used to graphics editing and and accepts jpg files formats. It offers wide variety of transitions, which are available through a user-friendly Graphical User Interface.</div>

### <span style="color:	#ffb6c1"> **Available functionality:**</span>
* color transformations:
  * changing contrast,
  * changing lightness,
  * changing saturation
  * changing colors,
* blurring,
* sharpening,
* affine transformations:
  * scaling,
  * rotation,
  * translation,
  * mirror reflection.
***
### <span style="color:	#ffb6c1"> **Contributors' course nicknames:**</span>
1. [Oriolus](https://github.com/Blueberrybug),
2. [Jelonek](https://github.com/jesionka),
3. [Wariacino](https://github.com/o-Mateo-o),
4. [Sheldon Cooper](https://github.com/neras).
***
## <span style="color:	#ffb6c1">**Technologies:**</span>
* [Julia](https://docs.julialang.org/en/v1/) - programming language,
* [FileIO](https://juliapackages.com/p/fileio) - package that enable loading and saving images,
* [Images](https://juliaimages.org/stable/) - package for images processing,
* [ImageShow](https://juliahub.com/docs/ImageShow/76qZM/0.2.3/) - package providing image *show* methods.
***
## <span style="color:	#ffb6c1">**How to run this program?**</span>
1. Clone the project to your directory: `git clone https://github.com/o-Mateo-o/grafika-pakiety.git. `


2. Type in Julia terminal: 
   
  * `cd("path/repo")` -*path/repo* is path to the repository on your computer 

   * `using Pkg; Pkg.add(["Gtk", "Images", "ImageView", "FileIO", "ImageShow"])`

  * `include("runROMEO.jl")`.
  
    
   Installing packages mentioned above is essential to succesfully precompile this project and make use of every its functionality.

***

