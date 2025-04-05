#!/bin/bash

GRUB_FILE="/boot/grub/grub.cfg"
BACKUP_FILE="/boot/grub/grub.cfg.bak"

# 要添加的启动参数
APPEND_PARAMS="intel_iommu=on iommu=pt nvidia_drm.modeset=0 rd.driver.blacklist=nouveau modprobe.blacklist=nouveau"

# 备份原始 grub 文件
echo "📦 备份 grub.cfg 到 $BACKUP_FILE ..."
cp "$GRUB_FILE" "$BACKUP_FILE"

# 修改启动项
echo "🛠 正在修改 grub.cfg 中的 linux 启动项..."
sed -i "/^\s*linux\s\+\/boot\/vmlinuz.*$/{
/intel_iommu=on/! s/$/ $APPEND_PARAMS/
}" "$GRUB_FILE"

echo "✅ 修改完成。请重启系统并使用以下命令确认参数是否生效："
echo ""
echo "  cat /proc/cmdline"
echo ""
echo "🌀 然后执行 IOMMU 分组检测命令："
echo ""
echo "  for d in /sys/kernel/iommu_groups/*/devices/*; do echo -e \"\\nIOMMU Group \$(basename \$(dirname \$d)):\"; lspci -nns \${d##*/}; done"
