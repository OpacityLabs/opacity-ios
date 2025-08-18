#ifdef __cplusplus
extern "C" {
#endif

// Webview functions
void ios_prepare_request(const char *url);
void ios_set_request_header(const char *key, const char *value);
void ios_present_webview();
void ios_close_webview();
const char *ios_get_browser_cookies_for_domain(const char *domain);
const char *ios_get_browser_cookies_for_current_url();

// Device information functions
double get_battery_level();
const char *get_battery_status();
const char *get_carrier_name();
const char *get_carrier_mcc();
const char *get_carrier_mnc();
double get_course();
const char *get_cpu_abi();
double get_altitude();
double get_latitude();
double get_longitude();
const char *get_device_model();
const char *get_os_name();
const char *get_os_version();
bool is_emulator();
double get_horizontal_accuracy();
double get_vertical_accuracy();
const char *get_ip_address();
bool is_location_services_enabled();
bool is_wifi_connected();
bool is_rooted();

#ifdef __cplusplus
}
#endif