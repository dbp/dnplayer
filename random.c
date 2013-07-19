#include "random.h"
#include <stdlib.h>
#include <time.h> 
#include "urweb.h"

/* Note: This is not cryptographically secure (bad PRNG and if it was called two times close enough together it could be seeded with the same value), but this is just a demo. */
uw_Basis_string uw_Random_str(uw_context ctx, uw_Basis_int len) {
  uw_Basis_string s;
  int i;

  s = uw_malloc(ctx, len + 1);

  srand((unsigned int)time(0));
  for (i = 0; i < len; i++) {
    s[i] = rand() % 93 + 33; /* ASCII characters 33 to 126 */
  }
  s[i] = 0;

  return s;
}

uw_Basis_string uw_Random_lower_str(uw_context ctx, uw_Basis_int len) {
  uw_Basis_string s;
  int i;

  s = uw_malloc(ctx, len + 1);

  srand((unsigned int)time(0));
  for (i = 0; i < len; i++) {
    s[i] = rand() % 26 + 97; /* ASCII lowercase letters */
  }
  s[i] = 0;

  return s;
} 

