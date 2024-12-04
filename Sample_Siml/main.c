#include <stdio.h>
#include <stdlib.h>

struct tank {
  char id[20];
  float capacity;
  float initial_volume;
  float tank_volume;
  float tank_wq[5];
};

float tot_in = 0, tot_out = 0;

void check_result(int x);
float inflow(float pc, float *t);
float outflow(float pc, float *t);
void display(struct tank t);

int main() {
  int result, sim_days;
  printf("Water Tank Simulation\n\n");

  float use_pd, pump_cap;
  struct tank t = {"Tank_001", 500, 0, 0, {0, 0, 0, 0, 0}};

  printf("Enter pump capacity (LPM): ");
  result = scanf("%f", &pump_cap);
  check_result(result);

  printf("Enter usage (L/day): ");
  result = scanf("%f", &use_pd);
  check_result(result);

  printf("Enter duration of simulation (days): ");
  result = scanf("%d", &sim_days);
  check_result(result);

  printf(
      "Tank no\tTank capacity\tTank volume\tTotal Inflow\tTotal_Outflow\n"); // write to a datastructure and call it in display()
  display(t);
  for (int i = 0; i < sim_days; i++) {

    if (t.tank_volume < 1) {
      tot_in = inflow(pump_cap, &t.tank_volume);
    } else
      tot_out = outflow(pump_cap, &t.tank_volume);
    display(t);
  };
  return 1;
}

void check_result(int x) {
  if (x != 1) {
    printf("Invalid input");
    exit(0);
  }
}

float inflow(float pc, float *t) {
  *t += pc;
  return *t;
}

float outflow(float pc, float *t) {
  *t -= pc;
  return *t;
}

void display(struct tank t) {
  printf("%s\t%f\t%f\t%f\t%f\n", t.id, t.capacity, t.tank_volume, tot_in,
         tot_out);
}
