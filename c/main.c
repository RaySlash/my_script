#include <stdio.h>
#include <assert.h>
#include <time.h>
#include <unistd.h>

// Microsoft Windows workaround for access() in unistd.h. See more: https://stackoverflow.com/questions/230062/whats-the-best-way-to-check-if-a-file-exists-in-c
#ifdef WIN32
#include <io.h>
#define F_OK 0
#define access _access
#endif

int main() {

  char jlog[10];
  printf("Enter Joblog: ");
  scanf("%10s", jlog);
  printf(" %s\n", jlog);

  char comments[100];
  printf("Enter Additional Comments(Optional): ");
  scanf(" %99[^\n]", comments);
  printf("%s\n", comments);

  time_t t = time(NULL);
  struct tm *tm = localtime(&t);
  char bTime[20];
  size_t btCount = strftime(bTime, sizeof(bTime), "%H:%M:%S", tm);
  assert(btCount);
  printf(" %s\n", bTime);
  char bDate[20];
  size_t bdCount = strftime(bDate, sizeof(bDate), "%d/%m/%y", tm);
  assert(bdCount);
  printf(" %s\n", bDate);
  char bZone[20];
  size_t bzCount = strftime(bZone, sizeof(bZone), "%Z %z", tm);
  assert(bzCount);
  printf(" %s\n", bZone);

  const char fname[11] = "Joblog.csv";

  if (access(fname, F_OK) == 0){
    FILE *file;
    file = fopen(fname, "a");
    fprintf(file,"%s, %s, %s, %s, %s\n", bDate, bTime, bZone, jlog, comments);
    fclose(file);
  } else {
    FILE *file;
    file = fopen(fname, "w+");
    fprintf(file, "Date, Time, Timezone, Joblog, Comments\n");
    fprintf(file,"%s, %s, %s, %s, %s\n", bDate, bTime, bZone, jlog, comments);
    fclose(file);
  }

  return 0;
}
