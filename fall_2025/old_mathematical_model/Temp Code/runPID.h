#pragma once

#include "PWM.h"
#include "PID.h"

#define A = 0.7;    //Constants used in final Duty Cycle calculations. Remember: A + 3B = 1
#define B = 0.1;
#define PITCH_SCALE = 2;    //Scaling factors to convert 0-255 value to range for PITCH/ROLL
#define ROLL_SCALE = 2;

/*
This is initializing the PID structs. This should be done outside of this function
struct PID* thrust = (struct PID*)malloc(sizeof(struct PID));
struct PID* yaw = (struct PID*)malloc(sizeof(struct PID));
struct PID* pitch = (struct PID*)malloc(sizeof(struct PID));
struct PID* roll = (struct PID*)malloc(sizeof(struct PID));
struct PID* xpos = (struct PID*)malloc(sizeof(struct PID));
struct PID* ypos = (struct PID*)malloc(sizeof(struct PID));


thrust* = PID_init(10, 0.1, 0.1);
yaw* = PID_init(10, 0.1, 0.1);
pitch* = PID_init(10, 0.1, 0.1);
roll* = PID_init(10, 0.1, 0.1);
xpos* = PID_init(10, 0.1, 0.1);
ypos* = PID_init(10, 0.1, 0.1);

    //deallocate PIDs
    free(thrust);
    ...
*/

//2 NOTES:  this file (presently) assumes that the desired pitch and roll have been found from the xy positional PIDs
//          the PIDs should be allocated and deallocated outside of this function. 
void runPID(float errors[4], float curPitch, float curRoll, PID* thrust, PID* yaw, PID* pitch, PID* roll, PID* xpos, PID* ypos) {//These should be the errors for thrust, yaw, xpos, and ypos
    int dc[4] = 0;          // the duty cycles obtained from the last PID controllers
    int pwm[4] = 0;         // the final pwm signal used

    PID_updateVals(xpos, error[2]);
    PID_updateVals(ypos, error[3]);

    PID_updateVals(thrust, errors[0]);
    PID_updateVals(yaw, errors[1]);
    PID_updateVals(pitch, (PITCH_SCALE * getDutyCycle(xpos)) - currPitch);
    PID_updateVals(roll, (ROLL_SCALE * getDutyCycle(ypos)) - currPitch);

    int thrustDC = getDutyCycle(thrust);
    int yawDC = getDutyCycle(yaw);
    int pitchDC = getDutyCycle(pitch);
    int rollDC = getDutyCycle(roll);


    pwm[0] = (int)(A * thrustDC + B * yawDC + B * pitchDC + B * rollDC);
    pwm[1] = (int)(A * thrustDC - B * yawDC + B * pitchDC - B * rollDC);
    pwm[2] = (int)(A * thrustDC - B * yawDC - B * pitchDC + B * rollDC);
    pwm[3] = (int)(A * thrustDC + B * yawDC - B * pitchDC - B * rollDC);

    for (int i = 0; i < 4; i++) {
        ledc_set_duty(SPEED_MODE, i, pwm[i]);   //sets the new value
        ledc_update_duty(SPEED_MODE, i);        //applies the new value
    }
}