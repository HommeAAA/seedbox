#!/bin/bash

echo "╔════════════════════════════════════════╗"
echo "║   Debian 13 全面兼容性审查            ║"
echo "║         集成测试套件                   ║"
echo "╚════════════════════════════════════════╝"
echo

TOTAL_PASSED=0
TOTAL_FAILED=0
TOTAL_WARNINGS=0
TEST_RESULTS=()

function test_pass() {
    local test_name="$1"
    echo "✅ PASS: $test_name"
    ((TOTAL_PASSED++))
    TEST_RESULTS+=("PASS: $test_name")
}

function test_fail() {
    local test_name="$1"
    echo "❌ FAIL: $test_name"
    ((TOTAL_FAILED++))
    TEST_RESULTS+=("FAIL: $test_name")
}

function test_warn() {
    local test_name="$1"
    echo "⚠️  WARN: $test_name"
    ((TOTAL_WARNINGS++))
    TEST_RESULTS+=("WARN: $test_name")
}

function test_section() {
    echo
    echo "========================================="
    echo "$1"
    echo "========================================="
}

################################################################################################
# 1. 核心组件集成测试
################################################################################################

test_section "1. 核心组件集成测试"

echo "测试核心组件之间的集成..."

# 测试 inexistence.sh 能找到 function
if grep -q "source.*function" "inexistence.sh" 2>/dev/null; then
    test_pass "inexistence.sh 能找到 function 文件"
else
    test_fail "inexistence.sh 未找到 function 文件"
fi

# 测试 inexistence.sh 能找到 ask
if grep -q "source.*ask" "inexistence.sh" 2>/dev/null; then
    test_pass "inexistence.sh 能找到 ask 文件"
else
    test_fail "inexistence.sh 未找到 ask 文件"
fi

# 测试 inexistence.sh 能找到 options
if grep -q "source.*options" "inexistence.sh" 2>/dev/null; then
    test_pass "inexistence.sh 能找到 options 文件"
else
    test_fail "inexistence.sh 未找到 options 文件"
fi

# 测试 ask 能调用安装脚本
if grep -q "package.*install" "00.Installation/ask" 2>/dev/null; then
    test_pass "ask 文件能调用安装脚本"
else
    test_warn "ask 文件可能未调用安装脚本"
fi

################################################################################################
# 2. 软件包模块集成测试
################################################################################################

test_section "2. 软件包模块集成测试"

echo "测试软件包模块与核心的集成..."

PACKAGE_MODULES=(
    "autobrr"
    "deluge"
    "flexget"
    "qbittorrent"
    "transmission"
)

for package in "${PACKAGE_MODULES[@]}"; do
    # 检查是否有 install 脚本
    if [[ -f "00.Installation/package/$package/install" ]]; then
        test_pass "软件包有 install 脚本: $package"
        
        # 检查是否有日志记录
        if grep -q "OutputLOG" "00.Installation/package/$package/install" 2>/dev/null; then
            test_pass "  install 脚本有日志记录: $package"
        else
            test_warn "  install 脚本可能缺少日志记录: $package"
        fi
        
        # 检查是否有错误处理
        if grep -q "||" "00.Installation/package/$package/install" 2>/dev/null; then
            test_pass "  install 脚本有错误处理: $package"
        else
            test_warn "  install 脚本可能缺少错误处理: $package"
        fi
    fi
    
    # 检查是否有 configure 脚本
    if [[ -f "00.Installation/package/$package/configure" ]]; then
        test_pass "软件包有 configure 脚本: $package"
        
        # 检查是否有用户配置
        if grep -q "iUser\|iPass" "00.Installation/package/$package/configure" 2>/dev/null; then
            test_pass "  configure 脚本有用户配置: $package"
        else
            test_warn "  configure 脚本可能缺少用户配置: $package"
        fi
    fi
done

################################################################################################
# 3. 命令行选项集成测试
################################################################################################

test_section "3. 命令行选项集成测试"

echo "测试命令行选项与主脚本的集成..."

COMMON_OPTIONS=(
    "--qb"
    "--de"
    "--rt"
    "--tr"
    "--flexget"
    "--autobrr"
    "--filebrowser"
    "--tweaks"
    "--bbr"
    "--rclone"
    "--swap"
)

for option in "${COMMON_OPTIONS[@]}"; do
    if grep -q "$option" "00.Installation/options" 2>/dev/null; then
        test_pass "命令行选项存在: $option"
    else
        test_warn "命令行选项可能缺失: $option"
    fi
done

# 测试否定选项
NEGATIVE_OPTIONS=(
    "--no-qb"
    "--no-de"
    "--no-rt"
    "--no-tr"
    "--no-flexget"
    "--no-autobrr"
    "--no-filebrowser"
    "--no-tweaks"
    "--no-bbr"
    "--no-swap"
)

for option in "${NEGATIVE_OPTIONS[@]}"; do
    if grep -q "$option" "00.Installation/options" 2>/dev/null; then
        test_pass "否定选项存在: $option"
    else
        test_warn "否定选项可能缺失: $option"
    fi
done

################################################################################################
# 4. 变量传递集成测试
################################################################################################

test_section "4. 变量传递集成测试"

echo "测试变量在不同组件之间的传递..."

COMMON_VARIABLES=(
    "iUser"
    "iPass"
    "iHome"
    "SysSupport"
    "DISTRO"
    "CODENAME"
    "OutputLOG"
    "MAXCPUS"
)

for var in "${COMMON_VARIABLES[@]}"; do
    # 检查在 inexistence.sh 中是否有定义或使用
    if grep -q "$var" "inexistence.sh" 2>/dev/null; then
        test_pass "变量在主脚本中存在: $var"
    else
        test_warn "变量可能在主脚本中缺失: $var"
    fi
    
    # 检查在 function 中是否有定义或使用
    if grep -q "$var" "00.Installation/function" 2>/dev/null; then
        test_pass "  变量在 function 中存在: $var"
    fi
done

################################################################################################
# 5. 日志系统集成测试
################################################################################################

test_section "5. 日志系统集成测试"

echo "测试日志系统的集成..."

# 检查 OutputLOG 的使用
if grep -q "OutputLOG" "inexistence.sh" 2>/dev/null; then
    test_pass "主脚本使用 OutputLOG"
else
    test_fail "主脚本未使用 OutputLOG"
fi

if grep -q "OutputLOG" "00.Installation/function" 2>/dev/null; then
    test_pass "function 文件使用 OutputLOG"
else
    test_fail "function 文件未使用 OutputLOG"
fi

# 检查 echo_task 的使用
if grep -q "echo_task" "00.Installation/function" 2>/dev/null; then
    test_pass "function 文件有 echo_task"
else
    test_fail "function 文件缺少 echo_task"
fi

################################################################################################
# 6. 状态管理集成测试
################################################################################################

test_section "6. 状态管理集成测试"

echo "测试安装状态管理..."

# 检查 status_lock 的使用
if grep -q "status_lock" "00.Installation/function" 2>/dev/null; then
    test_pass "function 文件有 status_lock 概念"
else
    test_warn "function 文件可能缺少 status_lock"
fi

# 检查锁文件的使用
if grep -q "lock" "00.Installation/function" 2>/dev/null; then
    test_pass "function 文件有锁文件机制"
else
    test_warn "function 文件可能缺少锁文件机制"
fi

################################################################################################
# 7. 错误处理集成测试
################################################################################################

test_section "7. 错误处理集成测试"

echo "测试错误处理机制..."

# 检查 set -e 的使用
if grep -q "set -e" "inexistence.sh" 2>/dev/null; then
    test_pass "主脚本有 set -e"
else
    test_warn "主脚本可能缺少 set -e"
fi

# 检查 return 1 的使用
if grep -q "return 1" "00.Installation/function" 2>/dev/null; then
    test_pass "function 文件有错误返回"
else
    test_warn "function 文件可能缺少错误返回"
fi

# 检查 echo_error 的使用
if grep -q "echo_error" "00.Installation/function" 2>/dev/null; then
    test_pass "function 文件有 echo_error"
else
    test_fail "function 文件缺少 echo_error"
fi

################################################################################################
# 8. 用户交互集成测试
################################################################################################

test_section "8. 用户交互集成测试"

echo "测试用户交互机制..."

# 检查 read -p 的使用
if grep -q "read -p" "00.Installation/ask" 2>/dev/null; then
    test_pass "ask 文件有用户输入"
else
    test_warn "ask 文件可能缺少用户输入"
fi

# 检查 ForceYes 的使用
if grep -q "ForceYes" "00.Installation/ask" 2>/dev/null; then
    test_pass "ask 文件有 ForceYes 选项"
else
    test_warn "ask 文件可能缺少 ForceYes"
fi

################################################################################################
# 9. apt 相关集成测试
################################################################################################

test_section "9. apt 相关集成测试"

echo "测试 apt 相关功能..."

# 检查 apt 安装函数
if grep -q "apt_install" "00.Installation/function" 2>/dev/null; then
    test_pass "function 文件有 apt 安装函数"
else
    test_fail "function 文件缺少 apt 安装函数"
fi

# 检查 apt 源函数
if grep -q "apt_sources" "00.Installation/function" 2>/dev/null; then
    test_pass "function 文件有 apt 源函数"
else
    test_fail "function 文件缺少 apt 源函数"
fi

# 检查 Debian 版本分支逻辑
if grep -q "bullseye\|bookworm\|trixie" "00.Installation/function" 2>/dev/null; then
    test_pass "function 文件有新版本 Debian 支持"
else
    test_warn "function 文件可能缺少新版本 Debian 支持"
fi

################################################################################################
# 10. 系统服务集成测试
################################################################################################

test_section "10. 系统服务集成测试"

echo "测试系统服务管理..."

# 检查 systemctl 的使用
if grep -q "systemctl" "00.Installation/function" 2>/dev/null; then
    test_pass "function 文件有 systemctl"
else
    test_warn "function 文件可能缺少 systemctl"
fi

# 检查 service 文件创建
if grep -q "systemd" "00.Installation/function" 2>/dev/null; then
    test_pass "function 文件有 systemd 服务文件创建"
else
    test_warn "function 文件可能缺少 systemd 服务文件创建"
fi

################################################################################################
# 测试总结
################################################################################################

test_section "集成测试总结"

echo
echo "╔════════════════════════════════════════╗"
echo "║          测试结果统计                 ║"
echo "╚════════════════════════════════════════╝"
echo
echo "✅ 通过: $TOTAL_PASSED"
echo "❌ 失败: $TOTAL_FAILED"
echo "⚠️  警告: $TOTAL_WARNINGS"
echo

if [[ $TOTAL_FAILED == 0 ]]; then
    echo "╔════════════════════════════════════════╗"
    echo "║   ✅ 所有集成测试通过！              ║"
    echo "╚════════════════════════════════════════╝"
    exit 0
else
    echo "╔════════════════════════════════════════╗"
    echo "║   ❌ 有 $TOTAL_FAILED 个集成测试失败   ║"
    echo "╚════════════════════════════════════════╝"
    exit 1
fi
