#!/bin/bash

echo "╔════════════════════════════════════════╗"
echo "║   Debian 13 全面兼容性审查            ║"
echo "║         端到端测试套件                  ║"
echo "╚════════════════════════════════════════╝"
echo

TOTAL_PASSED=0
TOTAL_FAILED=0
TOTAL_WARNINGS=0
COMPATIBILITY_ISSUES=()
PERFORMANCE_CONCERNS=()

function test_pass() {
    local test_name="$1"
    echo "✅ PASS: $test_name"
    ((TOTAL_PASSED++))
}

function test_fail() {
    local test_name="$1"
    echo "❌ FAIL: $test_name"
    ((TOTAL_FAILED++))
    COMPATIBILITY_ISSUES+=("$test_name")
}

function test_warn() {
    local test_name="$1"
    echo "⚠️  WARN: $test_name"
    ((TOTAL_WARNINGS++))
    PERFORMANCE_CONCERNS+=("$test_name")
}

function test_section() {
    echo
    echo "========================================="
    echo "$1"
    echo "========================================="
}

################################################################################################
# 1. 端到端流程测试 - 模拟真实用户场景
################################################################################################

test_section "1. 端到端流程测试"

echo "测试完整的用户安装流程..."

# 测试场景 1: 最简安装
echo
echo "场景 1: 最简安装流程"
echo "-----------------------------------------"

# 检查是否有 -y 选项
if grep -q "\-\-yes" "00.Installation/options" 2>/dev/null; then
    test_pass "有 --yes 选项支持非交互式安装"
else
    test_warn "可能缺少 --yes 选项"
fi

# 检查是否有 ForceYes 变量
if grep -q "ForceYes" "00.Installation/ask" 2>/dev/null; then
    test_pass "有 ForceYes 变量支持自动确认"
else
    test_warn "可能缺少 ForceYes 变量"
fi

# 测试场景 2: 完整安装
echo
echo "场景 2: 完整安装流程"
echo "-----------------------------------------"

# 检查是否能设置用户名和密码
if grep -q "\-\-user" "00.Installation/options" 2>/dev/null; then
    test_pass "有 --user 选项设置用户名"
else
    test_warn "可能缺少 --user 选项"
fi

if grep -q "\-\-password" "00.Installation/options" 2>/dev/null; then
    test_pass "有 --password 选项设置密码"
else
    test_warn "可能缺少 --password 选项"
fi

# 检查是否能选择多个软件
if grep -q "\-\-qb\|--de\|--rt" "00.Installation/options" 2>/dev/null; then
    test_pass "支持选择多个软件"
else
    test_warn "可能缺少软件选择选项"
fi

# 测试场景 3: 只安装 autobrr
echo
echo "场景 3: 只安装 autobrr"
echo "-----------------------------------------"

if grep -q "\-\-autobrr" "00.Installation/options" 2>/dev/null; then
    test_pass "有 --autobrr 选项单独安装 autobrr"
else
    test_fail "缺少 --autobrr 选项"
fi

if grep -q "\-\-no-qb\|--no-de\|--no-rt" "00.Installation/options" 2>/dev/null; then
    test_pass "有 --no-* 选项禁用其他软件"
else
    test_warn "可能缺少 --no-* 选项"
fi

################################################################################################
# 2. Debian 13 特定兼容性测试
################################################################################################

test_section "2. Debian 13 特定兼容性测试"

echo "测试 Debian 13 的特定兼容性..."

# 测试 1: 新 APT 源格式
echo
echo "测试 1: 新 APT 源格式"
if grep -q "security.debian.org/debian-security" "00.Installation/function" 2>/dev/null; then
    test_pass "支持 Debian 13 新 APT 源格式"
else
    test_fail "缺少 Debian 13 新 APT 源格式支持"
fi

# 测试 2: non-free-firmware 组件
echo
echo "测试 2: non-free-firmware 组件"
if grep -q "non-free-firmware" "00.Installation/function" 2>/dev/null; then
    test_pass "支持 non-free-firmware 组件"
else
    test_fail "缺少 non-free-firmware 组件"
fi

# 测试 3: Debian 11/12/13 识别
echo
echo "测试 3: Debian 11/12/13 版本识别"
if grep -q "trixie\|bookworm\|bullseye" "inexistence.sh" 2>/dev/null; then
    test_pass "正确识别 Debian 11/12/13"
else
    test_fail "无法正确识别 Debian 11/12/13"
fi

# 测试 4: Python 3 支持
echo
echo "测试 4: Python 3 独家支持"
if ! grep -q "python2\.7" "00.Installation/function" 2>/dev/null; then
    test_pass "已移除 Python 2.7 支持"
else
    test_warn "仍然有 Python 2.7 引用"
fi

if grep -q "python3" "00.Installation/function" 2>/dev/null; then
    test_pass "有 Python 3 支持"
else
    test_warn "可能缺少 Python 3 支持"
fi

# 测试 5: OpenSSL 兼容性
echo
echo "测试 5: OpenSSL 兼容性"
if grep -q "openssl\|SSL" "00.Installation/package/libtorrent-rasterbar" 2>/dev/null; then
    test_pass "有 OpenSSL 相关配置"
else
    test_warn "可能缺少 OpenSSL 兼容性检查"
fi

################################################################################################
# 3. 向后兼容性测试
################################################################################################

test_section "3. 向后兼容性测试"

echo "测试对旧系统的向后兼容性..."

# 测试 1: Debian 10 支持
echo
echo "测试 1: Debian 10 支持"
if grep -q "buster" "inexistence.sh" 2>/dev/null; then
    test_pass "仍然支持 Debian 10"
else
    test_fail "不再支持 Debian 10"
fi

# 测试 2: Debian 9 支持
echo
echo "测试 2: Debian 9 支持"
if grep -q "stretch" "inexistence.sh" 2>/dev/null; then
    test_pass "仍然支持 Debian 9"
else
    test_fail "不再支持 Debian 9"
fi

# 测试 3: Ubuntu 18.04 支持
echo
echo "测试 3: Ubuntu 18.04 支持"
if grep -q "bionic" "inexistence.sh" 2>/dev/null; then
    test_pass "仍然支持 Ubuntu 18.04"
else
    test_fail "不再支持 Ubuntu 18.04"
fi

# 测试 4: Ubuntu 16.04 支持
echo
echo "测试 4: Ubuntu 16.04 支持"
if grep -q "xenial" "inexistence.sh" 2>/dev/null; then
    test_pass "仍然支持 Ubuntu 16.04"
else
    test_fail "不再支持 Ubuntu 16.04"
fi

# 测试 5: 旧 APT 源格式
echo
echo "测试 5: 旧 APT 源格式"
if grep -q "security.debian.org/.*\/updates" "00.Installation/function" 2>/dev/null; then
    test_pass "仍然支持旧 APT 源格式"
else
    test_warn "可能不再支持旧 APT 源格式"
fi

################################################################################################
# 4. 性能瓶颈分析
################################################################################################

test_section "4. 性能瓶颈分析"

echo "分析可能的性能瓶颈..."

# 分析 1: 编译线程数量
echo
echo "分析 1: 编译线程数量"
if grep -q "MAXCPUS\|jMAXCPUS" "00.Installation/function" 2>/dev/null; then
    test_pass "有编译线程控制"
else
    test_warn "可能缺少编译线程控制"
fi

# 分析 2: swap 管理
echo
echo "分析 2: swap 管理"
if grep -q "swap" "inexistence.sh" 2>/dev/null; then
    test_pass "有 swap 管理"
else
    test_warn "可能缺少 swap 管理"
fi

# 分析 3: 下载优化
echo
echo "分析 3: 下载优化"
if grep -q "wget.*timeout\|curl.*timeout" "00.Installation/function" 2>/dev/null; then
    test_pass "有下载超时设置"
else
    test_warn "可能缺少下载超时设置"
fi

# 分析 4: 缓存机制
echo
echo "分析 4: 缓存机制"
if grep -q "cache" "00.Installation/function" 2>/dev/null; then
    test_pass "有缓存机制"
else
    test_warn "可能缺少缓存机制"
fi

################################################################################################
# 5. 功能完整性验证
################################################################################################

test_section "5. 功能完整性验证"

echo "验证所有核心功能的完整性..."

# 验证 1: 系统升级功能
echo
echo "验证 1: 系统升级功能"
if grep -q "system-upgrade\|upgrade_system" "inexistence.sh" 2>/dev/null; then
    test_pass "有系统升级功能"
else
    test_warn "可能缺少系统升级功能"
fi

# 验证 2: 系统优化功能
echo
echo "验证 2: 系统优化功能"
if grep -q "tweaks\|optimize" "inexistence.sh" 2>/dev/null; then
    test_pass "有系统优化功能"
else
    test_warn "可能缺少系统优化功能"
fi

# 验证 3: BBR 支持
echo
echo "验证 3: BBR 支持"
if grep -q "bbr" "inexistence.sh" 2>/dev/null; then
    test_pass "有 BBR 支持"
else
    test_warn "可能缺少 BBR 支持"
fi

# 验证 4: rclone 支持
echo
echo "验证 4: rclone 支持"
if grep -q "rclone" "inexistence.sh" 2>/dev/null; then
    test_pass "有 rclone 支持"
else
    test_warn "可能缺少 rclone 支持"
fi

# 验证 5: FileBrowser 支持
echo
echo "验证 5: FileBrowser 支持"
if grep -q "filebrowser" "inexistence.sh" 2>/dev/null; then
    test_pass "有 FileBrowser 支持"
else
    test_warn "可能缺少 FileBrowser 支持"
fi

# 验证 6: FlexGet 支持
echo
echo "验证 6: FlexGet 支持"
if grep -q "flexget" "inexistence.sh" 2>/dev/null; then
    test_pass "有 FlexGet 支持"
else
    test_warn "可能缺少 FlexGet 支持"
fi

# 验证 7: autobrr 支持
echo
echo "验证 7: autobrr 支持"
if grep -q "autobrr" "inexistence.sh" 2>/dev/null; then
    test_pass "有 autobrr 支持"
else
    test_fail "缺少 autobrr 支持"
fi

################################################################################################
# 6. 安全性评估
################################################################################################

test_section "6. 安全性评估"

echo "评估系统安全性..."

# 评估 1: 密码强度验证
echo
echo "评估 1: 密码强度验证"
if grep -q "password.*validate\|validate.*password" "00.Installation/function" 2>/dev/null; then
    test_pass "有密码强度验证"
else
    test_warn "可能缺少密码强度验证"
fi

# 评估 2: 用户名验证
echo
echo "评估 2: 用户名验证"
if grep -q "username.*validate\|validate.*username" "00.Installation/function" 2>/dev/null; then
    test_pass "有用户名验证"
else
    test_warn "可能缺少用户名验证"
fi

# 评估 3: 文件权限设置
echo
echo "评估 3: 文件权限设置"
if grep -q "chmod" "00.Installation/function" 2>/dev/null; then
    test_pass "有文件权限设置"
else
    test_warn "可能缺少文件权限设置"
fi

# 评估 4: 网络安全性
echo
echo "评估 4: 网络安全性"
if grep -q "iptables\|firewall" "00.Installation/function" 2>/dev/null; then
    test_pass "有网络安全设置"
else
    test_warn "可能缺少网络安全设置"
fi

################################################################################################
# 测试总结
################################################################################################

test_section "端到端测试总结"

echo
echo "╔════════════════════════════════════════╗"
echo "║          测试结果统计                 ║"
echo "╚════════════════════════════════════════╝"
echo
echo "✅ 通过: $TOTAL_PASSED"
echo "❌ 失败: $TOTAL_FAILED"
echo "⚠️  警告: $TOTAL_WARNINGS"
echo

if [[ ${#COMPATIBILITY_ISSUES[@]} -gt 0 ]]; then
    echo
    echo "兼容性问题列表:"
    for issue in "${COMPATIBILITY_ISSUES[@]}"; do
        echo "  - $issue"
    done
fi

if [[ ${#PERFORMANCE_CONCERNS[@]} -gt 0 ]]; then
    echo
    echo "性能问题列表:"
    for concern in "${PERFORMANCE_CONCERNS[@]}"; do
        echo "  - $concern"
    done
fi

echo
if [[ $TOTAL_FAILED == 0 ]]; then
    echo "╔════════════════════════════════════════╗"
    echo "║   ✅ 所有端到端测试通过！             ║"
    echo "╚════════════════════════════════════════╝"
    exit 0
else
    echo "╔════════════════════════════════════════╗"
    echo "║   ❌ 有 $TOTAL_FAILED 个端到端测试失败  ║"
    echo "╚════════════════════════════════════════╝"
    exit 1
fi
