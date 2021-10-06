## script available at:
## https://raw.githubusercontent.com/flyaflya/juliaVideosCode/main/makie.jl
using CairoMakie, Format, DataFramesMeta, Colors, ColorSchemes, CategoricalArrays, StatsBase
using CSV, HTTP             ##for retrieving data
import ColorSchemes.batlow  ##color gradients to use for sequential data
import ColorSchemes.viridis ## default Makie color scale for seq. data
import ColorSchemes.mk_12   ##discrete color scale for categorical data
CairoMakie.activate!(type = "svg") # crisper plots

## get data for our plotting example
url = "https://raw.githubusercontent.com/flyaflya/juliaVideosCode/main/winnings.csv"
plotDF = CSV.read(HTTP.get(url).body, DataFrame)


################################################################
# THEME -------------------------------------------
@with plotDF begin  # plot WITHOUT theme applied
    scatter(:winningsMultiplier,:maxWinnings)
end

## Use THEME for visual attributes that will not change based on DATA
## Details of this intentionally hidden.  See video notes for link to this file 
themeForAttributes = Theme(fontsize = 24,   #FIGURE ATTRIBUTE
            Scatter = (colormap = :viridis,  #SCATTER ATTRIBUTES
                        markersize = 14),
            Axis = (palette =               #AXIS ATTRIBUTES      
                        (color = [colorant"blue",colorant"purple",colorant"pink"],),
                    limits = (0,1,0,10^5),
                    ytickformat = x -> format.(x, commas = true),
                    xlabel = "Winnings Multiplier",
                    ylabel = "Max Winnings"),
            Colorbar = (colormap = :viridis,  #COLORBAR ATTRIBUTES 
                        label = "Actual Winnings",
                        flip_vertical_label = true,
                        labelsize = 12,
                        ticklabelsize = 14,
                        tickformat =  x -> format.(x, commas = true),
            Legend = "Post-winnings Emotion", titlesize = 16,  #LEGEND ATTRIBUTES
                    position = :rt, orientation = :horizontal))
set_theme!(themeForAttributes)

@with plotDF begin  # plot with THEME applied
    scatter(:winningsMultiplier,:maxWinnings)
end
scatter!([0.25],[75000], markersize = 80)#additional point in purple
scatter!([0.75],[75000], markersize = 80)#additional point in pink
current_figure()

@with plotDF begin  # plot with THEME applied and seq. color map
    scatter(:winningsMultiplier,:maxWinnings, color = :winnings)
end

################################################################
# USING CONTINUOUS/SEQUENTIAL and CATEGORICAL COLOR SCALES
# let's talk mappings to color using ColorSchemes.jl
# see https://juliagraphics.github.io/ColorSchemes.jl/stable/basics/
# COLOR SCHEMES (two color-blind friendly schemes)
batlow ## FOR CONTINUOUS/SEQUENTIAL SCALES - colorscheme goes from 0 to 1
[ batlow[0.1], batlow[0.5], batlow[0.9]   ] ## see color by indexing
viridis
[ batlow[0.1], batlow[0.5], batlow[0.9], 
    viridis[0.1], viridis[0.5], viridis[0.9]   ] 

mk_12  ## colorscheme from ColorSchemes.jl indexed 1,2,3,...,12
[   mk_12[1], mk_12[2], mk_12[3]  ] #FIRST THREE COLORS

myDiscColorScale = [colorant"orange",colorant"purple",colorant"cyan"]  ## custom discrete scale using named colors 
# see colors at https://juliagraphics.github.io/Colors.jl/stable/namedcolors/
[   myDiscColorScale[1], myDiscColorScale[2], myDiscColorScale[3]  ]

################################################################
# SEQUENTIAL COLOR SCALE: use sequential winnings column to color the points
seqDF = @chain plotDF begin
    @transform(:winningsIndex = standardize(UnitRangeTransform,:winnings))
    @transform(:seqColor = batlow[:winningsIndex])
end

### each points color is on :seqColor
fig, ax, plt = @with seqDF begin
    scatter(:winningsMultiplier,:maxWinnings, color = :seqColor)
end 

### make colorbar of the mapping from winningsIndex to batlow's 0,1 scale
Colorbar(fig[1,2], colormap = :batlow, limits = extrema(seqDF.winnings))
fig

################################################################
## FOR CATEGORICAL SCALES - indexed by integers starting at 1
# use unordered discrete happyFlag to color points based on chosen colors
discDF = @chain plotDF begin
    @transform(:happyFlagC = categorical(:happyFlag))
    @transform!(:happyFlagIndex = :happyFlagC.refs)
    @rtransform!(:myColor = myDiscColorScale[:happyFlagIndex])
end

fig, ax, plt = @with discDF begin
    scatter(:winningsMultiplier,:maxWinnings, color = :myColor)
end

## get mapping of color to string
legendDF = @chain discDF begin
    @select(:myColor,:happyFlagC)
    unique()
    @rtransform(:markElement = MarkerElement(color = :myColor, 
                                            marker = ^(:circle),
                                            markersize = 16))
end

axislegend(ax,legendDF.markElement, Array(legendDF.happyFlagC), 
            "Post-winnings Emotion",
            position = :rt, orientation = :horizontal)
fig


################################################################
# use unordered discrete happyFlag to color points based on mk_12 scheme
## colorscheme from ColorSchemes.jl also indexed starting at 1

discDF = @chain discDF begin
    @rtransform!(:discColor = mk_12[:happyFlagIndex])
end

fig, ax, plt = @with discDF begin
    scatter(:winningsMultiplier,:maxWinnings, color = :discColor)
end

## get mapping of color to string
legendDF = @chain discDF begin
    @select(:discColor,:happyFlagC)
    unique()
    @rtransform(markElement = MarkerElement(color = :discColor, 
                                            marker = ^(:circle),
                                            markersize = 16))
end

axislegend(ax,legendDF.markElement, Array(legendDF.happyFlagC))
fig

# video helpers below - pls ignore
# save("../toolingForDSVids/fig5.pdf", current_figure())
# set_theme!(Theme()) # reset theme