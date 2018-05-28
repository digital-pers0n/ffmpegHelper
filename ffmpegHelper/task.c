//
//  launch_task.c
//  ffmpegHelper
//
//  Created by Terminator on 2018/05/12.
//  Copyright © 2018年 Terminator. All rights reserved.
//

#include "task.h"
#include <stdlib.h>
#include <poll.h>
#include <unistd.h>
#include <string.h>
#include <sys/wait.h>
#include <spawn.h>
#include <stdbool.h>
#include <errno.h>

static inline void output_init(Output *output) {
    output->data = malloc(32 * sizeof(char));
    output->allocated = 32;
    output->size = 0;
}

static inline void output_destroy(Output *output) {
    free(output->data);
    memset(output, 0, sizeof(Output));
}

static inline void output_add(Output *output, char byte) {
    if (output->size >= output->allocated) {
        size_t n = output->allocated * 2;
        void *new_data = realloc(output->data, n * sizeof(char));
        if (!new_data) {
            fprintf(stderr, "%s: realloc() failed with error %s \n", __func__, strerror(errno));
            return;
        }
        output->data = new_data;
        output->allocated = n;
    }
    output->data[output->size] = byte;
    output->size++;
}

#pragma mark - task init

void task_init(Task *task, char **args) {
    task->finished = false;
    task->args = args;
    output_init(&(task->output));
}

#pragma mark - task destroy

void task_destroy(Task *task) {
    output_destroy(&(task->output));
    task->args = NULL;
    task->finished = false;
}

#pragma mark - task launch

int task_launch(Task *task) {
    int exit_code;
    int stdout_pipe[2];
    int stderr_pipe[2];
    posix_spawn_file_actions_t action;
    
    if (pipe(stdout_pipe) || pipe(stderr_pipe)) {
        fprintf(stderr, "%s: pipe() failed with error %s \n", __func__, strerror(errno));
        return -1;
    }
    
    posix_spawn_file_actions_init(&action);
    posix_spawn_file_actions_addclose(&action, stdout_pipe[0]);
    posix_spawn_file_actions_addclose(&action, stderr_pipe[0]);
    posix_spawn_file_actions_adddup2(&action, stdout_pipe[1], 1);
    posix_spawn_file_actions_adddup2(&action, stderr_pipe[1], 2);
    
    posix_spawn_file_actions_addclose(&action, stdout_pipe[1]);
    posix_spawn_file_actions_addclose(&action, stderr_pipe[1]);
    
    pid_t pid;
    if (posix_spawnp(&pid, task->args[0], &action, NULL, &(task->args[0]), NULL) != 0) {
        fprintf(stderr, "%s: posix_spawnp() failed with error: %s \n", __func__, strerror(errno));
        posix_spawn_file_actions_destroy(&action);
        return -1;
    }
    close(stdout_pipe[1]), close(stderr_pipe[1]); // close child-side of pipes
   
    // Clear previous output
    if (task->finished) {
        output_destroy(&(task->output));
        output_init(&(task->output));
        task->finished = false;
    }
    
    // Read from pipes
    size_t buf_len = 1024 + 1;
    char *buffer = (char *) malloc(buf_len * sizeof(char));
    bool stdout_empty = false, stderr_empty = false;
    size_t bytes_read = 0;
    struct pollfd plist[] = { { stdout_pipe[0], POLLIN }, { stderr_pipe[0], POLLIN } };
    while (poll(&plist[0], 2, -1) > 0) {
        if ( plist[0].revents &POLLIN && !stdout_empty) {
            bytes_read = read(stdout_pipe[0], buffer, buf_len);
            if (!bytes_read) {
                stdout_empty = true;
                continue;
            }
            for (long i = 0; i < bytes_read; i++) {
                output_add(&(task->output), buffer[i]);
            }
#ifdef DEBUG
            puts("------------------------------");
            printf("read %li bytes from stdout.\n", bytes_read);
            puts("------------------------------");
#endif
        } else if ( plist[1].revents &POLLIN && !stderr_empty) {
            bytes_read = read(stderr_pipe[0], buffer, 1024);
            if (!bytes_read) {
                stderr_empty = true;
                continue;
            }
            for (long i = 0; i < bytes_read; i++) {
                output_add(&(task->output), buffer[i]);
            }
#ifdef DEBUG
            puts("------------------------------");
            printf("read %li bytes from stderr.\n", bytes_read);
            puts("------------------------------");
#endif
        } else if (stderr_empty && stdout_empty) {
            break;
        }
    }
    waitpid(pid, &exit_code, 0);
    
    posix_spawn_file_actions_destroy(&action);
    free(buffer);
    task->finished = true;
    return 0;
}
