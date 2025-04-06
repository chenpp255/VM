#!/bin/bash
set -e

echo "📥 下载 fix_grub.sh..."
curl -fsSL https://raw.githubusercontent.com/chenpp255/VM/refs/heads/main/fix_grub.sh -o /tmp/fix_grub.sh

echo "🔐 设置执行权限..."
chmod +x /tmp/fix_grub.sh

echo "⚙️ 运行 fix_grub.sh..."
sudo /tmp/fix_grub.sh

echo "✅ GRUB 修复执行完毕。请根据提示 reboot 或检查 /etc/default/grub。"
