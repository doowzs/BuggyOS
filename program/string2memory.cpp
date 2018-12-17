#include <bits/stdc++.h>
using namespace std;

char s[100005] = "fibo";

int main() {
  int addr = 0x2a00 >> 2;
  char *c = s;
  while (*c != '\0') {
    printf("  %04x: %08x;\n", addr, *c);
    addr += 1;
    c += 1;
  }
  printf("ended at 0x%08x\n", addr << 2);
  return 0;
}
