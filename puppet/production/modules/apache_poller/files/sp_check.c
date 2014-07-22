/* With Debian Wheezy, to compile the source:
 *
 *    sudo apt-get install libcurl4-openssl-dev
 *    gcc -std=c99 -Wextra -Wall -O2 -o sp_check sp_check.c -lcurl
 *
 * With Debian Wheezy, to execute the binary command:
 *
 *    sudo apt-get install libcurl3
 *    ./sp_check 5 localhost/plugin.pl -w 10 -c 20 --login xyz
 *
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <curl/curl.h>
//#include <assert.h>

#define MAX_BUF_IN_BYTES  65536
#define MAX_POST_IN_BYTES 4096
#define OK                0
#define WARNING           1
#define CRITICAL          2
#define UNKNOWN           3

// Define our assert macro.
#undef assert
#define assert(exp) (void) ( (exp) || (assert_failed(#exp, __FILE__, __LINE__), 0) )

static void assert_failed ( char *exp, char *file, int line )
{
  fprintf ( stderr, "Assertion failed in %s line %d with `%s'.\n", file, line,
            exp );
  exit ( UNKNOWN );
}

typedef struct Buffer Buffer;

struct Buffer
{
  char wr_buf[MAX_BUF_IN_BYTES];
  size_t index;
  size_t capa;
};

static void init_buffer ( Buffer * buffer )
{
  buffer->wr_buf[0] = '\0';     // an empty string by default.
  buffer->index = 0;
  buffer->capa = sizeof ( buffer->wr_buf );
}

static int is_filled ( const Buffer * const buffer )
{
  // (buffer->wr_buf)[buffer->cap - 1] must contain '\0'
  // and can not be used.
  return buffer->index >= buffer->capa - 1;
}

// If this function does not return segsize, it will signal an error 
// condition to the library. This will cause the transfer to get aborted
// and the libcurl function used will return CURLE_WRITE_ERROR.
static size_t write_data ( void *buffer, size_t size, size_t nmemb,
                           void *userp )
{
  // The size (in bytes) of the received buffer.
  const int segsize = size * nmemb;

  // In this function, userp refers to a Buffer structure.
  Buffer *const userbuf = userp;

  if ( is_filled ( userbuf ) )
  {
    return 0;
  }

  // Get truncated_segsize.
  int truncated_segsize = segsize;

  if ( userbuf->index + segsize >= userbuf->capa )
  {
    truncated_segsize = userbuf->capa - 1 - userbuf->index;
  }

  if ( truncated_segsize > 0 )
  {
    memcpy ( &( userbuf->wr_buf )[userbuf->index], buffer,
             truncated_segsize );
    userbuf->index += truncated_segsize;
    // After each change, userbuf->wr_buf must be a valid string.
    ( userbuf->wr_buf )[userbuf->index] = '\0';
    return truncated_segsize;
  }
  else
  {
    userbuf->index = userbuf->capa - 1;
    return 0;
  }
}

static int is_positive_integer ( const char s[] )
{
  assert ( s != NULL );

  size_t i;

  for ( i = 0; s[i] != '\0'; i++ )
  {
    // Test if all the characters are digits.
    if ( !isdigit ( s[i] ) )
    {
      return 0;
    }
  }
  // return 1 unless s is an empty string.
  return i != 0 ? 1 : 0;
}




int main ( int argc, char *argv[] )
{
  if ( argc < 4 )
  {
    fprintf ( stderr,
              "Sorry, bad syntax. You must apply at least 3 arguments.\n" );
    fprintf ( stderr, "%s <timeout> <url> <args>...\n", argv[0] );
    return UNKNOWN;
  }

  if ( !is_positive_integer ( argv[1] ) )
  {
    fprintf ( stderr,
              "Sorry, bad syntax. The first argument must be a positive" );
    fprintf ( stderr, " integer (it is a timeout in seconds).\n" );
    return UNKNOWN;
  }

  const int timeout = atoi ( argv[1] );
  const char *const url = argv[2];

  // First step, init curl.
  CURL *curl;

  curl = curl_easy_init (  );

  if ( !curl )
  {
    fprintf ( stderr, "Sorry, could not init curl.\n" );
    return UNKNOWN;
  }

  // Construction of the post variable, a string with this form:
  //      token1=<urlencoded data1>&token2=<urlencoded data2>&...
  char post[MAX_POST_IN_BYTES];

  post[0] = '\0';

  int token_num = 1;
  char *urlencoded_str = NULL;
  int i = 0;

  for ( i = 3; i < argc; i++ )
  {
    if ( token_num > 999 )
    {
      fprintf
        ( stderr,
          "Sorry, the limit number (999) of POST variables is exceeded.\n" );
      curl_easy_cleanup ( curl );
      return UNKNOWN;
    }

    //printf("token%d: [%s]\n", token_num, argv[i]);

    urlencoded_str = curl_easy_escape ( curl, argv[i], 0 );

    // 10 is the max length of the string "token<num>=&".
    // The maximum is reached with "token999=&".
    int temp_size = 10 + strlen ( urlencoded_str ) + 1;
    char temp[temp_size];

    sprintf ( temp, "token%d=%s&", token_num, urlencoded_str );

    if ( strlen ( post ) + strlen ( temp ) + 1 < MAX_POST_IN_BYTES )
    {
      strcat ( post, temp );
    }
    else
    {
      fprintf ( stderr, "Sorry, the max POST size is exceeded.\n" );
      curl_free ( urlencoded_str );
      curl_easy_cleanup ( curl );
      return UNKNOWN;
    }

    curl_free ( urlencoded_str );
    token_num++;
  }

  // Remove the last character "&".
  post[strlen ( post ) - 1] = '\0';

  //printf("POST [%s]\n", post);

  curl_easy_setopt ( curl, CURLOPT_URL, url );
  curl_easy_setopt ( curl, CURLOPT_TIMEOUT, timeout );
  curl_easy_setopt ( curl, CURLOPT_POSTFIELDS, post );

  // Tell curl that we will receive data to the function write_data
  // which will write the data in "buf".
  Buffer buf;

  init_buffer ( &buf );
  curl_easy_setopt ( curl, CURLOPT_WRITEFUNCTION, write_data );
  curl_easy_setopt ( curl, CURLOPT_WRITEDATA, &buf );

  // Allow curl to perform the action.
  CURLcode ret;

  ret = curl_easy_perform ( curl );

  if ( ret )
  {
    if ( ret != CURLE_WRITE_ERROR || !is_filled ( &buf ) )
    {
      curl_easy_cleanup ( curl );
      fprintf ( stderr, "Sorry, exit value of curl_easy_perform is %d.",
                ret );

      switch ( ret )
      {
      case CURLE_COULDNT_RESOLVE_HOST:
        fprintf ( stderr, " Could not resolve the host address.\n" );
        break;

      case CURLE_OPERATION_TIMEDOUT:
        fprintf ( stderr, " Operation timeout.\n" );
        break;

      default:
        fprintf ( stderr, "\n" );
        break;
      }
      return UNKNOWN;
    }
  }

  curl_easy_cleanup ( curl );

  /*
     printf("----------------------------------\n");
     printf("%s", buf.wr_buf);
     printf("----------------------------------\n");
   */

  int return_value;

  if ( !strncmp ( buf.wr_buf, "0\n", 2 ) )
  {
    return_value = OK;
  }
  else if ( !strncmp ( buf.wr_buf, "1\n", 2 ) )
  {
    return_value = WARNING;
  }
  else if ( !strncmp ( buf.wr_buf, "2\n", 2 ) )
  {
    return_value = CRITICAL;
  }
  else if ( !strncmp ( buf.wr_buf, "3\n", 2 ) )
  {
    return_value = UNKNOWN;
  }
  else
  {
    fprintf ( stderr, "Unexpected output of the plugin, return value not" );
    fprintf ( stderr, " displayed or not in {0, 1, 2, 3}.\n" );
    return UNKNOWN;
  }

  char *output = buf.wr_buf + 2;
  size_t len = strlen ( output );

  if ( len > 0 && output[len - 1] == '\n' )
  {
    printf ( "%s", output );
  }
  else
  {
    printf ( "%s\n", output );
  }

  return return_value;
}
