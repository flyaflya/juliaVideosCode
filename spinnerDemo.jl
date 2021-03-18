using Luxor
using Printf

## function to create circle
function drawSpinnerCircle(circRadius::Real = 210)
    background(0,0,0,1)
    sethue("orange")
    setline(16)
    circle(Point(0,0), circRadius, :stroke)
    ## put measurments 
    fontsize(30)
    text("0", Point(0,-(circRadius+20)), valign=:bottom,halign=:center)
    text("0.25", Point(circRadius+20,0), valign=:middle,halign=:left)
    text("0.50", Point(0,(circRadius+20)), valign=:top,halign=:center)
    text("0.75", Point(-(circRadius+20),0), valign=:middle,halign=:right)
end

## function to create pointer arrow
function drawPointer(theta::Real,endRadius::Real = 180)
    coordStart = Point(0,0)
    coordEnd = Point(endRadius * cos((theta - 0.25)*2*π),
                    endRadius * sin((theta - 0.25)*2*π))
    arrow(coordStart,coordEnd,
            arrowheadlength = 45,
            arrowheadangle = pi/12,
            linewidth = 2)
end

## put the outcome of spin on the screen
function drawOutcome(theta::Real)
    spinnerPos = theta - floor(theta)
    textToAdd = @sprintf("%.3f",round(spinnerPos, digits = 3))
    fontsize(50)
    sethue("grey80")
    text(textToAdd, valign=:middle, halign=:center)
end

# draw a spinner
@draw begin
    drawSpinnerCircle()
    drawPointer(1.5)
    drawOutcome(1.5)
end

##animate the spinner
for theta in range(0,2,step = 0.01)
    @draw begin
        drawSpinnerCircle()
        drawPointer(theta)
    end
    display(preview())
    sleep(0.001)
end

## luxor animate function 
spinnerMovie = Movie(600,600,"Spinner")

function backdrop(scene, framenumber)
    background(0,0,0,1)
end

function frame(scene,framenumber)
    drawSpinnerCircle()
    eased_n = scene.easingfunction(framenumber, 0, 400, scene.framerange.stop)
    drawPointer(eased_n / 100)
    if framenumber > 200
        drawOutcome(eased_n / 100)
    end
end

animate(spinnerMovie, [
    Scene(spinnerMovie,backdrop,0:400),
    Scene(spinnerMovie,frame,0:400,easingfunction = easeoutquint)],
    framerate = 40,
    pathname = "spinner.gif",
    creategif=true)

