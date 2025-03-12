#!/bin/bash

# 设置变量
LOCAL_DIR="/home/your_backup_dir"
WEBDAV_MOUNT_POINT="/home/remote_backup/webdav"
WEBDAV_URL="http://your_webdav_url/dav"
WEBDAV_MOUNT_DIR="/your_webdav_backup_dir"
SYNC_LOG="/home/remote_backup/log/task1_sync_$(date +%Y-%m-%d_%H-%M-%S).log"
TEMP_SIZE_FILE="/home/remote_backup/tmp_size_file/task1_tmp_size_file"

echo "$(date):Start task1_remote_backup.sh." >> $SYNC_LOG

# 检查WebDAV是否已经挂载
if mount | grep -q "$WEBDAV_MOUNT_POINT "; then
    echo "$(date): WebDAV is already mounted at $WEBDAV_MOUNT_POINT" >> $SYNC_LOG
else
    echo "$(date): Mounting WebDAV at $WEBDAV_MOUNT_POINT" >> $SYNC_LOG
    # 挂载WebDAV（这里假设已经配置了davfs2的自动登录或使用密码文件）
    mount -t davfs $WEBDAV_URL $WEBDAV_MOUNT_POINT  >> $SYNC_LOG 2>&1
    if [ $? -ne 0 ]; then
        echo "$(date): Failed to mount WebDAV" >> $SYNC_LOG
        exit 1
    fi
fi

# 执行单向同步（只同步本地存在的文件到WebDAV）
echo "$(date): Starting one-way sync from $LOCAL_DIR to $WEBDAV_MOUNT_POINT" >> $SYNC_LOG
rsync -avz --ignore-existing "$LOCAL_DIR/"* "$WEBDAV_MOUNT_POINT$WEBDAV_MOUNT_DIR/" >> $SYNC_LOG 2>&1
if [ $? -ne 0 ]; then
    echo "$(date): Sync failed" >> $SYNC_LOG
    # 卸载WebDAV（即使同步失败也卸载，以保持系统整洁）
    umount $WEBDAV_MOUNT_POINT >> $SYNC_LOG 2>&1
    exit 1
fi

# 检查同步文件的文件大小是否一致（作为文件一致性的初步检查）
echo "$(date): Verifying file sizes" >> $SYNC_LOG
# 记录本地文件大小
find "$LOCAL_DIR" -type f -exec ls -lh {} \; | awk '{print $9, $5}' > local_sizes.txt
# 记录WebDAV文件大小
find "$WEBDAV_MOUNT_POINT" -type f -exec ls -lh {} \; | awk '{print $9, $5}' | sed "s|$WEBDAV_MOUNT_POINT|$LOCAL_DIR|g" > webdav_sizes.txt # 假设远程路径在日志中需要替换为本地路径以便比较

# 比较文件大小
diff local_sizes.txt webdav_sizes.txt >> size_diff.log 2>&1
if [ $? -ne 0 ]; then
    echo "$(date): File size mismatch detected" >> $SYNC_LOG
    cat size_diff.log >> $SYNC_LOG
    # 根据需要，可以在这里添加重新同步或标记为不同步的逻辑
else
    echo "$(date): All file sizes match" >> $SYNC_LOG
fi

# 清理临时文件
rm local_sizes.txt webdav_sizes.txt size_diff.log

# 卸载WebDAV
echo "$(date): Unmounting WebDAV at $WEBDAV_MOUNT_POINT" >> $SYNC_LOG
umount $WEBDAV_MOUNT_POINT >> $SYNC_LOG 2>&1
if [ $? -ne 0 ]; then
    echo "$(date): Failed to unmount WebDAV" >> $SYNC_LOG
    exit 1
fi

echo "$(date): Sync and unmount completed successfully" >> $SYNC_LOG
exit 0
