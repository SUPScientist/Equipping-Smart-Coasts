### Summary
This repository complements the open access micromanuscript [*Equipping Smart Coasts with Marine Water Quality IoT Sensors*](https://www.sciencedirect.com/science/article/pii/S2590123019300878) by Philip J. Bresnahan, Taylor Wirth, Todd Martz, Kenisha Shipley, Vicky Rowley, Clarissa Anderson, and Thomas Grimm. Please see that article for a more thorough description of the items mentioned below.

### Contents
Here you can find code to deploy on a Particle.io device (I used a Particle Electron) as well as code to use a webhook to push data to a Google Sheet in the [Cellular-Communications](../../tree/master/Cellular-Communications) directory. The [Post-Processing](../../tree/master/Post-Processing) directory contains R code which pulls data from the SCCOOS ERDDAP site and combines measured pH with an average of measured total alkalinity to estimate the saturation state of aragonite.

Please visit http://sccoos.org/ocean-acidification/ in order to see the final results from the sensor in near real time.
