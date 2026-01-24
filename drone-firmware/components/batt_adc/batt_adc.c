#include "esp_err.h"
#include "esp_adc/adc_oneshot.h"
#include "esp_adc/adc_cali.h"
#include "esp_timer.h"
#include "esp_log.h"

#include "batt_adc.h"
#include "board.h"

#define BATT_ADC_CHAN ADC_CHANNEL_7

static const char *TAG = "batt_adc";
static adc_oneshot_unit_handle_t batt_adc_handle = NULL;
static adc_cal_handle_t adc_cal_handle = NULL;
static const float V_DIVIDER_SCALE = 3; //multiply measurements by factor accounting for V divider

void batt_logging(void *pvParameters)
{
   int32_t raw_voltage, voltage_mv;

   while(1) {
      // Update time
      int64_t now_time = esp_timer_get_time();

      batt_adc_read(&raw_voltage);

      convert_raw(raw_voltage, &voltage_mv); //ERROR CHECK?? SEPARATE LINES??
      
      voltage_mv = V_DIVIDER_SCALE*voltage_mv;

      ESP_LOGW(TAG, "%.3f,%2f\n", now_time / 1e6, voltage_mv);

      vTaskDelay(pdMS_TO_TICKS(5000));
   }
}

void batt_adc_start(void)
{
   batt_adc_init();
   adc_cal_init();
   xTaskCreate(&batt_logging, "batt", 0, NULL, 1, NULL);
   return;
}

void batt_adc_init(void)
{
   adc_oneshot_unit_init_cfg_t init_config = {
      .unit_id = ADC_UNIT_1,
      .ulp_mode = ADC_ULP_MODE_DISABLE,
   };

   adc_oneshot_chan_cfg_t config = {
    .bitwidth = ADC_BITWIDTH_12,
    .atten = ADC_ATTEN_DB_12,
   };
   
   ESP_ERROR_CHECK(adc_oneshot_new_unit(&init_config, &batt_adc_handle));
   ESP_ERROR_CHECK(adc_oneshot_config_channel(batt_adc_handle, BATT_ADC_CHAN, &config));
   return;
}

void adc_cal_init(void)
{
   //ESP_LOGI(TAG, "calibration scheme version is %s", "Line Fitting");
   adc_cali_line_fitting_config_t cal_config = {
      .unit_id = ADC_UNIT_1,
      .atten = ADC_ATTEN_DB_12,
      .bitwidth = ADC_BITWIDTH_12,
   };
   ESP_ERROR_CHECK(adc_cali_create_scheme_line_fitting(&cal_config, &adc_cal_handle));
}

void batt_adc_read(int32_t* raw)
{
   adc_oneshot_read(batt_adc_handle, BATT_ADC_CHAN, raw); //returns ESP_ERR_TIMEOUT if data is bad
   //ESP_LOGI(TAG, "ADC%d Channel[%d] Raw Data: %d", ADC_UNIT_1 + 1, EXAMPLE_ADC1_CHAN0, adc_raw[0][0]);
   return;
}

void convert_raw(int32_t raw_value, int32_t* voltage)
{
   ESP_ERROR_CHECK(adc_cali_raw_to_voltage(adc_cal_handle, raw_value, voltage));
   //ESP_LOGI(TAG, "ADC%d Channel[%d] Cali Voltage: %d mV", ADC_UNIT_1 + 1, EXAMPLE_ADC1_CHAN0, voltage[0][0]);
   return;
}