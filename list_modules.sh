#!/bin/bash

echo "╔════════════════════════════════════════╗"
echo "║   项目功能模块清单                     ║"
echo "╚════════════════════════════════════════╝"
echo

PACKAGE_DIR="00.Installation/package"

echo "软件包模块:"
echo "========================================="

total_packages=0
for package_dir in "$PACKAGE_DIR"/*; do
    if [ -d "$package_dir" ]; then
        package_name=$(basename "$package_dir")
        echo -e "  📦 $package_name"
        ((total_packages++))
    fi
done

echo
echo "独立脚本:"
echo "========================================="

total_scripts=0
for script in "$PACKAGE_DIR"/*; do
    if [ -f "$script" ] && [ "$(basename "$script")" != "." ] && [ "$(basename "$script")" != ".." ]; then
        script_name=$(basename "$script")
        echo -e "  📜 $script_name"
        ((total_scripts++))
    fi
done

echo
echo "========================================="
echo "总计: $total_packages 个软件包目录"
echo "      $total_scripts 个独立脚本"
echo "========================================="

echo
echo "核心组件:"
echo "========================================="
echo "  📋 inexistence.sh          - 主安装脚本"
echo "  🔧 00.Installation/function - 核心函数库"
echo "  📊 00.Installation/ask       - 交互式询问"
echo "  ⚙️  00.Installation/options   - 命令行选项处理"

echo
echo "软件包清单:"
echo "========================================="

# 列出所有有 install 的软件包
echo "有 install 脚本的软件包:"
for package_dir in "$PACKAGE_DIR"/*; do
    if [ -d "$package_dir" ]; then
        package_name=$(basename "$package_dir")
        if [ -f "$package_dir/install" ]; then
            echo "  ✅ $package_name"
        fi
    fi
done

echo
echo "有 configure 脚本的软件包:"
for package_dir in "$PACKAGE_DIR"/*; do
    if [ -d "$package_dir" ]; then
        package_name=$(basename "$package_dir")
        if [ -f "$package_dir/configure" ]; then
            echo "  ✅ $package_name"
        fi
    fi
done
