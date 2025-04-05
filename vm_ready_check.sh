#!/bin/bash

echo "========== VAST VM Ready Check =========="

check() {
    local desc=$1
    local cmd=$2

    if eval "$cmd" >/dev/null 2>&1; then
        echo -e "✅ $desc"
    else
        echo -e "❌ $desc"
    fi
}

echo
# 1. 检查 IOMMU 参数
check "GRUB 启动参数包含 intel_iommu=on" "grep -q 'intel_iommu=on' /proc/cmdline"
check "GRUB 启动参数包含 iommu=pt" "grep -q 'iommu=pt' /proc/cmdline"

# 2. 检查 nouveau 是否屏蔽
check "nouveau 模块未加载" "! lsmod | grep -q nouveau"

# 3. 检查是否加载 vfio（非必须但推荐）
check "vfio 核心模块已加载" "lsmod | grep -q vfio"

# 4. 检查是否存在 IOMMU 分组
check "存在 IOMMU 分组目录" "[ -d /sys/kernel/iommu_groups ] && ls /sys/kernel/iommu_groups/*/devices/* >/dev/null 2>&1"

# 5. 检查 GPU 是否被进程占用
GPU_USE=$(fuser -v /dev/nvidia[0-9]* 2>/dev/null | grep -E '/dev/nvidia[0-9]+' | wc -l)
if [[ "$GPU_USE" -eq 0 ]]; then
    echo "✅ GPU 当前空闲，无进程占用"
else
    echo "❌ GPU 正被占用：$(fuser -v /dev/nvidia[0-9]* 2>/dev/null | grep '/dev/nvidia')"
fi

# 6. 检查是否有 docker 容器运行
check "无 Docker 容器运行" "[[ \$(docker ps -q | wc -l) -eq 0 ]]"

echo
echo "========= 检查完毕 ========="