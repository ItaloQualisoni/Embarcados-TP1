#include <prototypes.h>

int32_t lastTasksTicks[6];

void task(void){
	int32_t tid;

	tid = HF_CurrentTaskId();

	for (;;){
		if(lastTasksTicks[tid] != HF_TaskTicks(tid)){
			lastTasksTicks[tid] = HF_TaskTicks(tid);
			printf("%d,%d\n", tid,HF_TaskTicks(tid));
		}
	}
}

void ApplicationMain(void){
	//period,capacity,deadline,description...
	HF_AddPeriodicTask(task, 5, 1, 5, "task1", 2048, 0, 0);
	HF_AddPeriodicTask(task, 10, 3, 10, "task2", 2048, 0, 0);
	HF_AddPeriodicTask(task, 15, 3, 15, "task3", 2048, 0, 0);
	HF_AddPeriodicTask(task, 20, 5, 20, "task4", 2048, 0, 0);
	HF_AddPeriodicTask(task, 25, 2, 25, "task5", 2048, 0, 0);
	HF_Start();
}