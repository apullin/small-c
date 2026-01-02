#include <stdio.h>
#include <string.h>

#define SMALLC_LINESIZE 80

char *gets(char *s)
{
        size_t len;
        if (fgets(s, SMALLC_LINESIZE, stdin)==NULL) return NULL;
        len=strlen(s);
        while(len>0 && (s[len-1]=='\n' || s[len-1]=='\r'))
                s[--len]='\0';
        return s;
}
