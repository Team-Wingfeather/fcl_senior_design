# Meeting Notes 2025-9-5
## Thoughts
Be up-front in the proposal about what decisions have already been made.

## This Week
Simon - Schedule a meeting with the Microcontrollers Drone Team
Gabe - Microcontrollers Presentation
Everyone - Work on Proposal

## Engineering Requirements Draft
-	Constraints:
-	Platform is a drone
-	We need to be able to access the raw data whether or not we get wireless to work.
-	Drone must be able to hover without drifting horizontally (specify how much), allowing students to analyze vertical motion
-	Drone must be able to estimate altitude (specify precision level)
-	Consider ultrasonic sensor
-	Consider using IMU - is that enough?
-	Drone must be able to follow some sort of path (this is super undefined)
-	Drone must not use image recognition
-	Drone must be able to fly for at least 5 minutes without charging 
-	Drone must have a remote way to stop (manual, wireless, etc.)
-	Drone must be able to withstand some sort of disturbance (super undefined)
-	Drone must be able to be charged [safely] (Brady) (define more)
-	Drone must fly

## Marketing requirements draft
-	Focus on autonomous actuation and control (as opposed to remote control)
-	Visually and graphically display a step response
-	Measure a Bode plot in real life
-	Include a PID control design experience (competition?)
-	Showcase the results of the controllers physically in real life 
-	Include disturbance/noise in a real and physical way (fans, wind, offset loading, bopping the vehicle with your hand, are examples)
-	Include a data acquisition widget that makes beautiful plots (could be real time or post process)
-	Include relevant safety measures–anticipate and avoid typical damage situations
-	Include the capability of a tracking experiment (tracking a changing altitude path, tracking a path on the floor, following a wall, following a bright object, or following another drone, tracking with disturbance)
-	Data logging to a neutral format (like csv) regardless of what real time visualizations are happening

## Tasks to be done
-	Choose body design
-	Design power supply system
-	Research and choose microcontroller
-	Research and choose sensors
-	Realize a basic flight control system
-	Choose open source platform to start
-	Modify so the thing can hover, fly
-	Create front end for students to interact with 

We need tasks/subtasks - map to timing
Loose plan: get the drone built/flying by Christmas

