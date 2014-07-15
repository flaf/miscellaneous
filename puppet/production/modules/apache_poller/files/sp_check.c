/* With Debian Wheezy:
 *
 *    sudo apt-get install libcurl4-openssl-dev
 *    gcc -std=c99 -Wextra -Wall -O2 -o sp_check sp_check.c -lcurl
 *
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <curl/curl.h>

#define MAX_BUF_IN_BYTES  65536
#define MAX_POST_IN_BYTES 4096
#define OK                0
#define WARNING           1
#define CRITICAL          2
#define UNKNOWN           3

size_t write_data(void *buffer, size_t size, size_t nmemb, void *userp);
int isPositiveInteger(const char s[]);

int main(int argc, char *argv[]) {

  if (argc < 4) {
    printf("Sorry, bad syntax. You must apply at least 3 arguments.\n");
    printf("%s <timeout> <url> <args>...\n", argv[0]);
    return UNKNOWN;
  }

  if (!isPositiveInteger(argv[1])) {
    printf("Sorry, bad syntax. The first argument must be a positive");
    printf(" integer (it's a timeout in seconds).\n");
    return UNKNOWN;
  }

  int timeout = atoi(argv[1]);
  char *url = argv[2];

  // First step, init curl.
  CURL *curl;
  curl = curl_easy_init();

  if (!curl) {
    printf("Sorry, couldn't init curl.\n");
    return UNKNOWN;
  }

  // Construction of the post variable, a string with this form:
  //      token1=<urlencoded data1>&token2=<urlencoded data2>&...
  char post[MAX_POST_IN_BYTES] = { 0 };
  int token_num = 1;
  char *urlencoded_str = NULL;
  int i = 0;

  for (i = 3; i < argc; i++) {

    if (token_num > 999) {
      printf
        ("Sorry, the limit number (999) of POST variables is exceeded.\n");
      curl_easy_cleanup(curl);
      return UNKNOWN;
    }

    //printf("C: token%d: [%s]\n", token_num, argv[i]);

    urlencoded_str = curl_easy_escape(curl, argv[i], 0);

    // 10 is the max length of the string "token<num>=&".
    // The maximum is reached with "token999=&".
    int temp_size = 10 + strlen(urlencoded_str) + 1;
    char temp[temp_size];
    //memset(temp, 0, temp_size*sizeof(char));
    sprintf(temp, "token%d=%s&", token_num, urlencoded_str);

    if (strlen(post) + strlen(temp) + 1 < MAX_POST_IN_BYTES) {
      strcat(post, temp);
    }
    else {
      printf("Sorry, the max POST size is exceeded.\n");
      curl_easy_cleanup(curl);
      return UNKNOWN;
    }

    curl_free(urlencoded_str);
    token_num++;

  }

  // Remove the last character "&".
  post[strlen(post) - 1] = 0;
  //printf("C: POST [%s]\n", post);

  char wr_buf[MAX_BUF_IN_BYTES + 1] = { 0 };

  curl_easy_setopt(curl, CURLOPT_URL, url);
  curl_easy_setopt(curl, CURLOPT_TIMEOUT, timeout);
  curl_easy_setopt(curl, CURLOPT_POSTFIELDS, post);

  // Tell curl that we'll receive data to the function write_data
  // which will write the data in wr_buf.
  curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, write_data);
  curl_easy_setopt(curl, CURLOPT_WRITEDATA, (void *) wr_buf);

  // Allow curl to perform the action.
  CURLcode ret;
  ret = curl_easy_perform(curl);

  if (ret) {
    curl_easy_cleanup(curl);
    printf("Sorry, exit value of curl is %d.", ret);

    switch (ret) {

    case CURLE_COULDNT_RESOLVE_HOST:
      printf(" Could not resolve the host address.\n");
      break;

    case CURLE_OPERATION_TIMEDOUT:
      printf(" Operation timeout.\n");
      break;

    default:
      printf("\n");
      break;

    }

    return UNKNOWN;
  }

  curl_easy_cleanup(curl);

  /*
     printf("----------------------------------\n");
     printf("%s", wr_buf);
     printf("----------------------------------\n");
   */

  int return_value;
  if (!strncmp(wr_buf, "0\n", 2)) {
    return_value = OK;
  }
  else if (!strncmp(wr_buf, "1\n", 2)) {
    return_value = WARNING;
  }
  else if (!strncmp(wr_buf, "2\n", 2)) {
    return_value = CRITICAL;
  }
  else if (!strncmp(wr_buf, "3\n", 2)) {
    return_value = UNKNOWN;
  }
  else {
    printf("Unexpected output of the plugin, return value not");
    printf(" displayed or not in {0, 1, 2, 3}.\n");
    return UNKNOWN;
  }

  printf("%s", wr_buf + 2);
  return return_value;

}

// Write data callback function (called within the context
// of curl_easy_perform).
size_t write_data(void *buffer, size_t size, size_t nmemb, void *userp) {

  // We want to keep the value of wr_index for the next call
  // this function. So, wr_index is a static variable.
  static int wr_index = 0;

  // The size (in bytes) of the received buffer.
  int segsize = size * nmemb;

  // In this function, userp refers to a simple array of bytes.
  char *wr_buf = userp;

  // Check to see if this data exceeds the size of our buffer. If so,
  // it's possible to return O to indicate a problem to curl.
  // But here, we just stop the function without error (ie, we return
  // segsize) and our buffer will be troncated.
  if (wr_index + segsize > MAX_BUF_IN_BYTES) {
    if (MAX_BUF_IN_BYTES - wr_index > 0) {
      memcpy(&wr_buf[wr_index], buffer,
             (MAX_BUF_IN_BYTES - wr_index));
    }
    wr_index = MAX_BUF_IN_BYTES + 1; // wr_buf will be not written anymore.
    return segsize;
  }

  // Copy the data from the curl buffer into our buffer.
  memcpy(&wr_buf[wr_index], buffer, segsize);

  // Update the write index.
  wr_index += segsize;

  // Return the number of bytes received, indicating to curl that
  // all is okay.
  return segsize;
}

int isPositiveInteger(const char s[]) {

  if (s == NULL || *s == '\0') {
    return 0;
  }

  size_t i;
  for (i = 0; i < strlen(s); i++) {
    // ASCII value of 0 -> 48, of 1 -> 49, ..., of 9 -> 57.
    if (s[i] < 48 || s[i] > 57) {
      return 0;
    }
  }

  return 1;
}


