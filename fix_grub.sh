#!/bin/bash

set -e

echo "🔍 [1/6] 检测 CPU 品牌..."

CPU_VENDOR=$(lscpu | grep 'Vendor ID:' | awk '{print $3}')

if [[ "$CPU_VENDOR" == "GenuineIntel" ]]; then
    IOMMU_PARAM="intel_iommu=on"
    echo "✅ 检测到 Intel CPU，将使用参数: $IOMMU_PARAM"
elif [[ "$CPU_VENDOR" == "AuthenticAMD" ]]; then
    IOMMU_PARAM="amd_iommu=on"
    echo "✅ 检测到 AMD CPU，将使用参数: $IOMMU_PARAM"
else
    echo "❌ 未识别的 CPU 品牌: $CPU_VENDOR"
    exit 1
fi

GRUB_FILE="/etc/default/grub"
BACKUP_FILE="/etc/default/grub.bak"

echo "📦 [2/6] 备份 grub 配置到 $BACKUP_FILE ..."
cp "$GRUB_FILE" "$BACKUP_FILE"

APPEND_PARAMS="$IOMMU_PARAM nvidia_drm.modeset=0 rd.driver.blacklist=nouveau modprobe.blacklist=nouveau"

echo "🛠 [3/6] 修改 GRUB_CMDLINE_LINUX_DEFAULT ..."
if grep -q '^GRUB_CMDLINE_LINUX_DEFAULT=' "$GRUB_FILE"; then
    sed -i "/^GRUB_CMDLINE_LINUX_DEFAULT=/ {
        /$IOMMU_PARAM/! s/\"$/ $APPEND_PARAMS\"/
    }" "$GRUB_FILE"
else
    echo "GRUB_CMDLINE_LINUX_DEFAULT=\"$APPEND_PARAMS\"" >> "$GRUB_FILE"
fi

echo "🔄 [4/6] 更新 grub 配置..."
update-grub

echo "🛑 [5/6] 禁用 display manager（如果存在）..."
systemctl disable gdm || true
systemctl disable lightdm || true
systemctl disable sddm || true
systemctl stop gdm || true
systemctl stop lightdm || true
systemctl stop sddm || true

echo "🔁 [6/6] 重启系统以使配置生效..."
sleep 3
reboot

# ✨ 可选：系统启动后执行以下命令启用 Vast VM
# python3 /var/lib/vastai_kaalia/enable_vms.py on -f
