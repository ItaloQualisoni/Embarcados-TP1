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
	HF_AddPeriodicTask(task, 6, 1, 6, "task1", 2048, 0, 0);
	HF_AddPeriodicTask(task, 8, 2, 8, "task2", 2048, 0, 0);
	HF_AddPeriodicTask(task, 17, 3, 17, "task3", 2048, 0, 0);
	HF_AddPeriodicTask(task, 20, 4, 20, "task4", 2048, 0, 0);
	HF_AddPeriodicTask(task, 13, 2, 13, "task5", 2048, 0, 0);
	HF_Start();
}