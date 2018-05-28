//
//  launch_task.h
//  ffmpegHelper
//
//  Created by Terminator on 2018/05/12.
//  Copyright © 2018年 Terminator. All rights reserved.
//

#ifndef launch_task_h
#define launch_task_h

#include <stdio.h>
#include <stdbool.h>

typedef struct Output_ {
    char *data;
    size_t allocated;
    size_t size;
} Output;

typedef struct Task_ {
    char **args;
    Output output;
    bool finished;
} Task;

/* args - a NULL terminated array */
void task_init(Task *task, char **args);
void task_destroy(Task *task);
int task_launch(Task *task);

static inline bool task_is_finished(Task *task) {
    return task->finished;
}

static inline char *task_output(Task *task) {
    return task->output.data;
}

static inline size_t task_output_size(Task *task) {
    return task->output.size;
}

#endif /* launch_task_h */
