#!/bin/bash

# 日志位置变量

SYNC_LOG="/home/remote_backup/log/main_sync_log_$(date +%Y-%m-%d_%H-%M-%S).log"

echo "$(date): Starting sync tasks..." >> $SYNC_LOG

# 运行第一个同步任务
bash /home/remote_backup/sh/tasks/task1_remote_backup.sh
if [ $? -ne 0 ]; then
    echo "$(date): task1 failed." >> $SYNC_LOG
    exit 1
fi

# 运行第二个同步任务
bash /home/remote_backup/sh/tasks/task2_remote_backup.sh
if [ $? -ne 0 ]; then
    echo "$(date): task2 failed." >> $SYNC_LOG
    exit 1
fi

# 运行第三个同步任务
bash /home/remote_backup/sh/tasks/task3_remote_backup.sh
if [ $? -ne 0 ]; then
    echo "$(date): task3 failed." >> $SYNC_LOG
    exit 1
fi

# 运行第四个同步任务
bash /home/remote_backup/sh/tasks/task4_remote_backup.sh
if [ $? -ne 0 ]; then
    echo "$(date): task4 failed." >> $SYNC_LOG
    exit 1
fi

echo "$(date): All sync tasks completed." >> $SYNC_LOG

exit 0
