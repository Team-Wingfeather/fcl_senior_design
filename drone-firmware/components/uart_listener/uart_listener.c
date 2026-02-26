#include "freertos/FreeRTOS.h"
#include "freertos/idf_additions.h"
#include "freertos/task.h"
#include "driver/uart.h"
#include <unistd.h>
#include "string.h"

#include "storage.h"
#include "uart_listener.h"
#include "esp_log_level.h"

#define UART_NUM UART_NUM_0

static const int BUF_SIZE = 1024;
//static const char *TAG = "uart_listener"; //I should probably use or lose this
static TaskHandle_t listener_handle = NULL;

void listener_task(void *pvParameter)
{

   uint8_t buf[BUF_SIZE];
   
    // char buf[64];

   // Drain any existing garbage
   while (read(0, buf, sizeof(buf)) > 0) {
      vTaskDelay(pdMS_TO_TICKS(10));
   }

   while (1) {
      // int len = uart_read_bytes(  /*this is likely a better way to do all of this, but we can get there later */
      //    UART_NUM,
      //    buf,
      //    sizeof(buf),
      //    pdMS_TO_TICKS(1000)   // timeout
      // );
      int len = read(0, buf, sizeof(buf));

      if (len > 0) {
         write_file("commands.txt", buf, len); //TODO need a command to first parse the input and see what file is to be written
         //write(1, buf, 5);
      }
      vTaskDelay(pdMS_TO_TICKS(10));
   }
}

void uart_listener_start(void)
{
   unlink("/littlefs/commands.txt");
   xTaskCreate(&listener_task, "uart_listener", 6144, NULL, 5, &listener_handle); //TODO make sure to kill task
}

void uart_listener_stop(void)
{
    // Stop listener task first so it doesn't fight for UART
    if (listener_handle != NULL) {
        vTaskDelete(listener_handle);
        listener_handle = NULL;
    }
    
    FILE *f = fopen("/littlefs/commands.txt", "rb");
    if (f != NULL) {

        uint8_t buf[1024] = {0};   // zero-filled buffer

        // Read up to 1024 bytes
        fread(buf, 1, sizeof(buf), f);

        fclose(f);

        // Always send exactly 1024 bytes
        write(1, buf, sizeof(buf));

    } else {
        const char *msg = "Failed to open file\n";
        write(1, msg, strlen(msg));
    }

    esp_log_level_set("*", ESP_LOG_INFO);
}

void uart_listener_init(void)
{
   esp_log_level_set("*", ESP_LOG_NONE);
   uart_listener_start();
}