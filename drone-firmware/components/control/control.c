#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include <string.h>

#include "commander.h"
#include "crtp_commander_high_level.h"
#include "projdefs.h"
#include "stabilizer_types.h"

static TaskHandle_t script_control_handle = NULL;
static const int COMMAND_RATE_HZ = 50;  // Setpoint update rate


void drone_script_control(void *pvParameter) {
    //crtpCommanderHighLevelTakeoff(0.3,2);
    setpoint_t sp;
    state_t state;
    memset(&sp, 0, sizeof(sp));
    memset(&state, 0, sizeof(state));
    commanderGetSetpoint(&sp, &state);
    sp.thrust = 25000;
    while(1) {
        commanderSetSetpoint(&sp,COMMANDER_PRIORITY_CRTP);
        vTaskDelay(pdMS_TO_TICKS(1000/COMMAND_RATE_HZ));
    }
    vTaskDelete(NULL);
}


void drone_script_control_start(void) {
    xTaskCreate(&drone_script_control, "script_control", 1024, NULL, 5, &script_control_handle); //TODO fix stack size. Make sure to kill task properly
}
