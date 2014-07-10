// Sur Debian Wheezy, faire :
//
//     sudo apt-get install libcurl4-openssl-dev libssl-dev
//     gcc -lssl -lcurl -o curl-launcher.exe curl-launcher.c
//

#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <curl/curl.h>
#include <openssl/sha.h>
#include <openssl/hmac.h>
#include <openssl/evp.h>
#include <openssl/bio.h>
#include <openssl/buffer.h>

#define MAX_BUF 65536
#define MAX_POST_LENGTH 4096


char wr_buf[MAX_BUF+1];
int  wr_index;

// Write data callback function (called within the context of
// curl_easy_perform.
size_t write_data(void *buffer, size_t size, size_t nmemb, void *userp) {

    int segsize = size * nmemb;

    // Check to see if this data exceeds the size of our buffer. If so,
    // set the user-defined context value and return 0 to indicate a
    // problem to curl.
    if ( wr_index + segsize > MAX_BUF ) {
        *(int *)userp = 1;
        return 0;
    }

    // Copy the data from the curl buffer into our buffer.
    memcpy( (void *)&wr_buf[wr_index], buffer, (size_t)segsize );

    // Update the write index.
    wr_index += segsize;

    // Null terminate the buffer.
    wr_buf[wr_index] = 0;

    // Return the number of bytes received, indicating to curl that all is okay.
    return segsize;
}

int isPositiveInteger(const char *s) {

    if (s == NULL || *s == '\0' || isspace(*s)) {
      return 0;
    }

    int i;
    for(i = 0; i < strlen(s); i++) {
        // ASCII value of 0 = 48, 9 = 57.
        if (s[i] < 48 || s[i] > 57) {
            return 0;
        }
    }

    return 1;
}

char *base64(const unsigned char *input, int length) {
  BIO *bmem, *b64;
  BUF_MEM *bptr;

  b64 = BIO_new(BIO_f_base64());
  bmem = BIO_new(BIO_s_mem());
  b64 = BIO_push(b64, bmem);
  BIO_write(b64, input, length);
  BIO_flush(b64);
  BIO_get_mem_ptr(b64, &bptr);

  char *buff = (char *)malloc(bptr->length);
  memcpy(buff, bptr->data, bptr->length-1);
  buff[bptr->length-1] = 0;

  BIO_free_all(b64);

  return buff;
}




int main(int argc, char *argv[]) {

    CURL *curl;
    CURLcode ret;
    int wr_error;
    wr_error = 0;
    wr_index = 0;

    if (argc < 4) {
        printf("Sorry, bad syntax. You must apply at least 3 arguments.\n");
        return 3;
    }

    if (!isPositiveInteger(argv[1])) {
        printf("Sorry, bad syntax. The first argument must be a positive integer.\n");
        return 3;
    }

    int timeout = atoi(argv[1]);
    char* url = argv[2];

    // First step, init curl.
    curl = curl_easy_init();
    if (!curl) {
        printf("Sorry, couldn't init curl.\n");
        return 3;
    }

    // Tell curl the URL of the file we're going to retrieve.
    curl_easy_setopt(curl, CURLOPT_URL, url);

    // Tell curl that we'll receive data to the function write_data, and
    // also provide it with a context pointer for our error return.
    curl_easy_setopt(curl, CURLOPT_WRITEDATA, (void *)&wr_error);
    curl_easy_setopt(curl, CURLOPT_TIMEOUT, timeout);
    curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, write_data);

    int i;
    int tn = 1;
    char post[MAX_POST_LENGTH] = {0};

    for (i = 3; i < argc; i++) {
        printf("Language C: arg %d: [%s]\n", i, argv[i]);
        char temp[100] = {0};
        char *s = NULL;
        s = curl_easy_escape(curl, argv[i], 0);
        sprintf(temp, "token%d=%s&", tn, s);
        curl_free(s);
        strcat(post, temp);
        tn++;
        //printf("c: token%d clear  [%s]\n", tn, argv[i]);
        //printf("taille de [%s] -> %d\n", argv[i], strlen(argv[i]));
        //char *output = base64(argv[i], strlen(argv[i]));
        //printf("c: token%d base64 [%s]\n", tn, output);
        //free(output);
    }
    //printf("POST [%s]\n", post);
    // Remove the last character &.
    post[strlen(post)-1] = 0;
    printf("POST [%s]\n", post);

    //char *output1 = base64("-c", sizeof("-c")-1);
    //char *output2 = base64("éléphantça456", sizeof("éléphantça456")-1);
    //char post[500];

    //strcat(post, "token1=");
    //strcat(post, output1);
    //strcat(post, "&");
    //strcat(post, "token2=");
    //strcat(post, output2);
    //free(output1);
    //free(output2);

    curl_easy_setopt(curl, CURLOPT_POSTFIELDS, post);


    // Allow curl to perform the action/
    ret = curl_easy_perform(curl);

    if (ret) {
        printf("exit value of curl %d (write_error = %d)\n", ret, wr_error);
        return 3;
    }

    // Emit the page if curl indicates that no errors occurred.
    if (ret == 0) {
        printf( "%s", wr_buf );
    }

    curl_easy_cleanup(curl);
    return 0;

}


