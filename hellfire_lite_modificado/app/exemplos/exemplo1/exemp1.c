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
	HF_AddPeriodicTask(task, 10, 3, 10, "task1", 2048, 0, 0);
	HF_AddPeriodicTask(task, 15, 2, 15, "task2", 2048, 0, 0);
	HF_AddPeriodicTask(task, 20, 5, 20, "task3", 2048, 0, 0);
	HF_AddPeriodicTask(task, 25, 5, 25, "task4", 2048, 0, 0);
	HF_AddPeriodicTask(task, 30, 2, 30, "task5", 2048, 0, 0);
	HF_Start();
}