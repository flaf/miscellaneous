/*
 * With Debian Wheezy, to compile the source:
 *
 *    sudo apt-get install libcurl4-openssl-dev
 *    gcc -std=c89 -pedantic -Wextra -Wall -O2 -o sp_check sp_check.c -lcurl
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

/*
 * PATTERN_SIZE must be equal to:
 *      number of digits in MAX_POST_IN_BYTES + strlen("token=&")
 *      number of digits in MAX_POST_IN_BYTES + 7
 */
#define MAX_POST_IN_BYTES  4096
#define PATTERN_SIZE         11
#define MAX_BUF_IN_BYTES  65536

#define OK                    0
#define WARNING               1
#define CRITICAL              2
#define UNKNOWN               3

/* Define our assert macro. */
#undef assert
#define assert(exp) (void) ( (exp) || (assert_failed(#exp, __FILE__, __LINE__), 0) )




static void assert_failed ( const char *exp, const char *file,
                            const int line )
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
  buffer->wr_buf[0] = '\0';     /* an empty string by default. */
  buffer->index = 0;
  buffer->capa = sizeof ( buffer->wr_buf );
}

static int is_filled ( const Buffer * const buffer )
{
  /*
   * (buffer->wr_buf)[buffer->cap - 1] must contain '\0'
   * and can not be used.
   */
  return buffer->index >= buffer->capa - 1;
}


static int is_positive_integer ( const char s[] )
{
  assert ( s != NULL );

  size_t i;

  for ( i = 0; s[i] != '\0'; i++ )
  {
    /* Test if all the characters are digits. */
    if ( !isdigit ( s[i] ) )
    {
      return 0;
    }
  }
  /* Return 1 unless s is an empty string. */
  return i != 0 ? 1 : 0;
}


/*
 * This function writes the post variable, a string with this form:
 *       token0=<urlencoded data1>&token1=<urlencoded data2>&...
 */
static int write_post ( char *post, const unsigned int post_size,
                        const char *const data[], const unsigned int data_num,
                        CURL * const curl )
{
  unsigned int d_index = 0;     /* data index */
  unsigned int p_index = 0;     /* post index is 0 initially (firt element of the post array) */
  int add;
  char *urlencoded = NULL;

  /* Initially, post is an empty string. */
  post[0] = '\0';

  for ( d_index = 0; d_index < data_num; d_index++ )
  {
    urlencoded = curl_easy_escape ( curl, data[d_index], 0 );

    /*
     * printf ( "%d + %zu + %d < %d\n", p_index, strlen ( urlencoded ),
     *          PATTERN_SIZE, post_size );
     * printf ( "token%d: [%s]\n", d_index, data[d_index] );
     */
    if ( p_index + strlen ( urlencoded ) + PATTERN_SIZE < post_size )
    {
      add = sprintf ( post, "token%d=%s&", d_index, urlencoded );
      curl_free ( urlencoded );
      if ( add < 0 )
      {
        fprintf ( stderr, "Sorry, error with the sprintf function.\n" );
        return 0;
      }
      post += add;
      p_index += add;
    }
    else
    {
      curl_free ( urlencoded );
      fprintf ( stderr, "Sorry, the max POST size is exceeded.\n" );
      return 0;
    }
  }

  /* Remove the last character "&" */
  *( post - 1 ) = '\0';

  return 1;
}


/*
 * If this function does not return segsize, it will signal an error
 * condition to the library. This will cause the transfer to get aborted
 * and the libcurl function used will return CURLE_WRITE_ERROR.
 */
static size_t write_data ( void *buffer, size_t size, size_t nmemb,
                           void *userp )
{
  /* The size (in bytes) of the received buffer. */
  const int segsize = size * nmemb;

  /* In this function, userp refers to a Buffer structure. */
  Buffer *const userbuf = userp;

  if ( is_filled ( userbuf ) )
  {
    return 0;
  }

  /* Get truncated_segsize. */
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
    /* After each change, userbuf->wr_buf must be a valid string. */
    ( userbuf->wr_buf )[userbuf->index] = '\0';
    return truncated_segsize;
  }
  else
  {
    userbuf->index = userbuf->capa - 1;
    return 0;
  }
}




int main ( const int argc, const char *const argv[] )
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

  /* First step, init curl. */
  CURL *curl;

  curl = curl_easy_init (  );

  if ( !curl )
  {
    fprintf ( stderr, "Sorry, could not init curl.\n" );
    return UNKNOWN;
  }

  /* Construction of the post string. */
  char post[MAX_POST_IN_BYTES];

  if ( !write_post ( post, MAX_POST_IN_BYTES, argv + 3, argc - 3, curl ) )
  {
    curl_easy_cleanup ( curl );
    return UNKNOWN;
  }

  curl_easy_setopt ( curl, CURLOPT_URL, url );
  curl_easy_setopt ( curl, CURLOPT_TIMEOUT, timeout );
  curl_easy_setopt ( curl, CURLOPT_POSTFIELDS, post );

  /*
   * Tell curl that we will receive data to the function write_data
   * which will write the data in "buf".
   */
  Buffer buf;

  init_buffer ( &buf );
  curl_easy_setopt ( curl, CURLOPT_WRITEFUNCTION, write_data );
  curl_easy_setopt ( curl, CURLOPT_WRITEDATA, &buf );

  CURLcode ret;

  /* Allow curl to perform the action. */
  ret = curl_easy_perform ( curl );
  curl_easy_cleanup ( curl );

  if ( ret )
  {
    if ( ret != CURLE_WRITE_ERROR || !is_filled ( &buf ) )
    {
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

  /*
   * printf("----------------------------------\n");
   * printf("%s", buf.wr_buf);
   * printf("----------------------------------\n");
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
