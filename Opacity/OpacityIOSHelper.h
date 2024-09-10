namespace opacity {

extern "C" {

void ios_prepare_request(const char *url);

void ios_set_request_header(const char *key, const char *value);

void ios_present_webview();

void ios_close_webview();
}

} // namespace opacity
