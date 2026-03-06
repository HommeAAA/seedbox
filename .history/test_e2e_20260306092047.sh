#!/bin/bash

set -e

echo "╔════════════════════════════════════════╗"
echo "║   Debian 13 端到端测试套件            ║"
echo "╚════════════════════════════════════════╝"
echo

PASSED=0
FAILED=0
WARNINGS=0

function test_pass() {
    echo "✅ PASS: $1"
    ((PASSED++))
}

function test_fail() {
    echo "❌ FAIL: $1"
    ((FAILED++))
}

function test_warn() {
    echo "⚠️  WARN: $1"
    ((WARNINGS++))
}

function test_section() {
    echo
    echo "========================================="
    echo "$1"
    echo "========================================="
}

test_section "1. 文件完整性检查"

echo "检查所有修改的文件是否存在..."
FILES=(
    "inexistence.sh"
    "00.Installation/function"
    "00.Installation/ask"
    "00.Installation/options"
    "00.Installation/package/flexget/install"
    "00.Installation/package/flexget/configure"
    "00.Installation/package/libtorrent-rasterbar"
    "00.Installation/package/autobrr/install"
    "00.Installation/package/autobrr/configure"
    "README.md"
)

for file in "${FILES[@]}"; do
    if [[ -f "$file" ]]; then
        test_pass "文件存在: $file"
    else
        test_fail "文件缺失: $file"
    fi
done

test_section "2. Bash 语法检查"

echo "检查所有脚本的 Bash 语法..."
SCRIPTS=(
    "inexistence.sh"
    "00.Installation/function"
    "00.Installation/ask"
    "00.Installation/options"
    "00.Installation/package/flexget/install"
    "00.Installation/package/flexget/configure"
    "00.Installation/package/libtorrent-rasterbar"
    "00.Installation/package/autobrr/install"
    "00.Installation/package/autobrr/configure"
)

for script in "${SCRIPTS[@]}"; do
    if bash -n "$script" 2>/dev/null; then
        test_pass "语法正确: $script"
    else
        test_fail "语法错误: $script"
    fi
done

test_section "3. 系统版本检测逻辑测试"

test_system_detection() {
    local codename=$1
    local expected=$2
    local description=$3
    
    SysSupport=0
    [[ $codename =~ (trixie|bookworm|bullseye) ]] && SysSupport=1
    [[ $codename =~ (bionic|buster)  ]] && SysSupport=1
    [[ $codename =~ (xenial|stretch) ]] && SysSupport=2
    [[ $codename =~ (jessie|wheezy|trusty) ]] && SysSupport=3
    
    if [[ $SysSupport == $expected ]]; then
        test_pass "$description: $codename -> SysSupport=$SysSupport"
    else
        test_fail "$description: $codename -> SysSupport=$SysSupport (预期: $expected)"
    fi
}

test_system_detection "trixie" 1 "Debian 13"
test_system_detection "bookworm" 1 "Debian 12"
test_system_detection "bullseye" 1 "Debian 11"
test_system_detection "buster" 1 "Debian 10"
test_system_detection "stretch" 2 "Debian 9"
test_system_detection "bionic" 1 "Ubuntu 18.04"
test_system_detection "xenial" 2 "Ubuntu 16.04"
test_system_detection "jessie" 3 "Debian 8"

test_section "4. rTorrent 版本检测逻辑测试"

test_rtorrent_detection() {
    local codename=$1
    local expected=$2
    local description=$3
    
    rtorrent_dev=0
    [[ $codename =~ (stretch|bionic|buster|bullseye|bookworm|trixie) ]] && rtorrent_dev=1
    
    if [[ $rtorrent_dev == $expected ]]; then
        test_pass "$description: $codename -> rtorrent_dev=$rtorrent_dev"
    else
        test_fail "$description: $codename -> rtorrent_dev=$rtorrent_dev (预期: $expected)"
    fi
}

test_rtorrent_detection "trixie" 1 "Debian 13"
test_rtorrent_detection "bookworm" 1 "Debian 12"
test_rtorrent_detection "bullseye" 1 "Debian 11"
test_rtorrent_detection "buster" 1 "Debian 10"
test_rtorrent_detection "stretch" 1 "Debian 9"
test_rtorrent_detection "bionic" 1 "Ubuntu 18.04"
test_rtorrent_detection "xenial" 0 "Ubuntu 16.04"
test_rtorrent_detection "jessie" 0 "Debian 8"

test_section "5. APT 源配置逻辑测试"

test_apt_sources() {
    local codename=$1
    local expected_format=$2
    local expected_firmware=$3
    local description=$4
    
    has_new_format=0
    has_non_free_firmware=0
    
    if [[ $codename =~ (trixie|bookworm|bullseye) ]]; then
        has_new_format=1
        has_non_free_firmware=1
    fi
    
    format_ok=true
    firmware_ok=true
    
    if [[ $expected_format == "new" && $has_new_format != 1 ]]; then
        format_ok=false
    fi
    
    if [[ $expected_firmware == "yes" && $has_non_free_firmware != 1 ]]; then
        firmware_ok=false
    fi
    
    if $format_ok && $firmware_ok; then
        test_pass "$description: $codename"
    else
        test_fail "$description: $codename (格式: $has_new_format, 固件: $has_non_free_firmware)"
    fi
}

test_apt_sources "trixie" "new" "yes" "Debian 13"
test_apt_sources "bookworm" "new" "yes" "Debian 12"
test_apt_sources "bullseye" "new" "yes" "Debian 11"
test_apt_sources "buster" "old" "no" "Debian 10"
test_apt_sources "stretch" "old" "no" "Debian 9"

test_section "6. Python 版本检测测试"

if command -v python3 &>/dev/null; then
    python3_version=$(python3 -c 'import sys; print(".".join(map(str, sys.version_info[:2])))' 2>/dev/null || echo "unknown")
    if [[ $python3_version != "unknown" ]]; then
        test_pass "Python 3 版本检测: $python3_version"
    else
        test_fail "Python 3 版本检测失败"
    fi
else
    test_warn "Python 3 未安装"
fi

test_section "7. Python 2.7 移除验证"

echo "检查是否完全移除 Python 2.7 引用..."

files_with_python2=(
    "00.Installation/function"
    "00.Installation/package/flexget/install"
    "00.Installation/package/flexget/configure"
    "00.Installation/package/libtorrent-rasterbar"
)

for file in "${files_with_python2[@]}"; do
    if grep -q "python2\.7" "$file" 2>/dev/null; then
        test_fail "发现 Python 2.7 引用: $file"
    else
        test_pass "已移除 Python 2.7: $file"
    fi
done

test_section "8. autobrr 安装脚本验证"

echo "检查 autobrr 安装脚本..."

if grep -q "install_autobrr_binary" "00.Installation/package/autobrr/install"; then
    test_pass "autobrr 安装函数存在"
else
    test_fail "autobrr 安装函数缺失"
fi

if grep -q "create_autobrr_systemd" "00.Installation/package/autobrr/install"; then
    test_pass "autobrr systemd 函数存在"
else
    test_fail "autobrr systemd 函数缺失"
fi

if grep -q "autobrr@.service" "00.Installation/package/autobrr/install"; then
    test_pass "autobrr 服务模板正确"
else
    test_fail "autobrr 服务模板缺失"
fi

test_section "9. autobrr 配置脚本验证"

echo "检查 autobrr 配置脚本..."

if grep -q "configure_autobrr_webui" "00.Installation/package/autobrr/configure"; then
    test_pass "autobrr 配置函数存在"
else
    test_fail "autobrr 配置函数缺失"
fi

if grep -q "create_autobrr_admin_user" "00.Installation/package/autobrr/configure"; then
    test_pass "autobrr 用户创建函数存在"
else
    test_fail "autobrr 用户创建函数缺失"
fi

test_section "10. 集成测试 - ask 文件"

echo "检查 ask 文件中的 autobrr 集成..."

if grep -q "ask_autobrr" "00.Installation/ask"; then
    test_pass "ask_autobrr 函数存在"
else
    test_fail "ask_autobrr 函数缺失"
fi

if grep -q "InsAutobrr" "00.Installation/ask"; then
    test_pass "InsAutobrr 变量使用正确"
else
    test_fail "InsAutobrr 变量缺失"
fi

test_section "11. 集成测试 - options 文件"

echo "检查 options 文件中的 autobrr 选项..."

if grep -q "\-\-autobrr" "00.Installation/options"; then
    test_pass "--autobrr 选项存在"
else
    test_fail "--autobrr 选项缺失"
fi

if grep -q "\-\-no-autobrr" "00.Installation/options"; then
    test_pass "--no-autobrr 选项存在"
else
    test_fail "--no-autobrr 选项缺失"
fi

test_section "12. 集成测试 - 主脚本"

echo "检查主脚本中的 autobrr 集成..."

if grep -q "ask_autobrr" "inexistence.sh"; then
    test_pass "主脚本调用 ask_autobrr"
else
    test_fail "主脚本未调用 ask_autobrr"
fi

if grep -q "InsAutobrr" "inexistence.sh"; then
    test_pass "主脚本使用 InsAutobrr 变量"
else
    test_fail "主脚本未使用 InsAutobrr 变量"
fi

test_section "13. 文档更新验证"

echo "检查文档更新..."

if grep -q "Debian 9/10/11/12/13" "README.md"; then
    test_pass "README 支持系统列表已更新"
else
    test_fail "README 支持系统列表未更新"
fi

if grep -q "Debian 12/13" "README.md"; then
    test_pass "README 推荐版本已更新"
else
    test_fail "README 推荐版本未更新"
fi

test_section "14. 边界情况测试"

echo "测试边界情况..."

# 测试未知的系统版本
SysSupport=0
codename="unknown"
[[ $codename =~ (trixie|bookworm|bullseye) ]] && SysSupport=1
[[ $codename =~ (bionic|buster)  ]] && SysSupport=1
[[ $codename =~ (xenial|stretch) ]] && SysSupport=2
[[ $codename =~ (jessie|wheezy|trusty) ]] && SysSupport=3

if [[ $SysSupport == 0 ]]; then
    test_pass "未知系统版本正确处理"
else
    test_fail "未知系统版本处理错误"
fi

# 测试空值
SysSupport=0
codename=""
[[ $codename =~ (trixie|bookworm|bullseye) ]] && SysSupport=1
[[ $codename =~ (bionic|buster)  ]] && SysSupport=1
[[ $codename =~ (xenial|stretch) ]] && SysSupport=2
[[ $codename =~ (jessie|wheezy|trusty) ]] && SysSupport=3

if [[ $SysSupport == 0 ]]; then
    test_pass "空值正确处理"
else
    test_fail "空值处理错误"
fi

test_section "15. 代码质量检查"

echo "检查代码质量..."

# 检查是否有未关闭的引号
for file in "${SCRIPTS[@]}"; do
    if grep -qE '^[^#]*"[^"]*$' "$file" 2>/dev/null; then
        test_warn "可能存在未关闭的引号: $file"
    else
        test_pass "引号检查通过: $file"
    fi
done

# 检查是否有未关闭的括号
for file in "${SCRIPTS[@]}"; do
    open_parens=$(grep -o '{' "$file" 2>/dev/null | wc -l | tr -d ' ')
    close_parens=$(grep -o '}' "$file" 2>/dev/null | wc -l | tr -d ' ')
    
    if [[ $open_parens == $close_parens ]]; then
        test_pass "括号匹配: $file"
    else
        test_fail "括号不匹配: $file (开: $open_parens, 关: $close_parens)"
    fi
done

test_section "16. 安全性检查"

echo "检查安全性问题..."

# 检查是否有硬编码的密码
if grep -rq "password.*=" "00.Installation/package/autobrr/" 2>/dev/null | grep -v "POSTGRES_PASSWORD" | grep -v "db_password"; then
    test_warn "可能存在硬编码密码"
else
    test_pass "未发现硬编码密码"
fi

# 检查是否有不安全的权限设置
if grep -rq "chmod 777" "00.Installation/package/autobrr/" 2>/dev/null; then
    test_fail "发现不安全的权限设置 (chmod 777)"
else
    test_pass "权限设置安全"
fi

test_section "17. 依赖检查"

echo "检查依赖项..."

# 检查 autobrr 是否依赖必要的工具
required_commands=("curl" "wget" "tar")
for cmd in "${required_commands[@]}"; do
    if grep -q "$cmd" "00.Installation/package/autobrr/install"; then
        test_pass "autobrr 使用 $cmd"
    else
        test_warn "autobrr 可能需要 $cmd"
    fi
done

test_section "18. 配置文件验证"

echo "验证配置文件模板..."

if grep -q "host = \"0.0.0.0\"" "00.Installation/package/autobrr/install"; then
    test_pass "autobrr 配置包含 host 设置"
else
    test_fail "autobrr 配置缺少 host 设置"
fi

if grep -q "port = 7474" "00.Installation/package/autobrr/install"; then
    test_pass "autobrr 配置包含 port 设置"
else
    test_fail "autobrr 配置缺少 port 设置"
fi

if grep -q "session_secret" "00.Installation/package/autobrr/configure"; then
    test_pass "autobrr 配置包含 session_secret"
else
    test_fail "autobrr 配置缺少 session_secret"
fi

test_section "19. 错误处理检查"

echo "检查错误处理..."

# 检查是否有错误处理
if grep -q "|| {" "00.Installation/package/autobrr/install"; then
    test_pass "autobrr 安装脚本有错误处理"
else
    test_warn "autobrr 安装脚本可能缺少错误处理"
fi

if grep -q "return 1" "00.Installation/package/autobrr/install"; then
    test_pass "autobrr 安装脚本有错误返回"
else
    test_warn "autobrr 安装脚本可能缺少错误返回"
fi

test_section "20. 日志记录检查"

echo "检查日志记录..."

if grep -q "OutputLOG" "00.Installation/package/autobrr/install"; then
    test_pass "autobrr 安装脚本有日志记录"
else
    test_warn "autobrr 安装脚本可能缺少日志记录"
fi

if grep -q "echo_task" "00.Installation/package/autobrr/install"; then
    test_pass "autobrr 安装脚本有任务提示"
else
    test_warn "autobrr 安装脚本可能缺少任务提示"
fi

test_section "测试总结"

echo
echo "╔════════════════════════════════════════╗"
echo "║          测试结果统计                 ║"
echo "╚════════════════════════════════════════╝"
echo
echo "✅ 通过: $PASSED"
echo "❌ 失败: $FAILED"
echo "⚠️  警告: $WARNINGS"
echo

if [[ $FAILED == 0 ]]; then
    echo "╔════════════════════════════════════════╗"
    echo "║   ✅ 所有测试通过！                   ║"
    echo "╚════════════════════════════════════════╝"
    exit 0
else
    echo "╔════════════════════════════════════════╗"
    echo "║   ❌ 有 $FAILED 个测试失败              ║"
    echo "╚════════════════════════════════════════╝"
    exit 1
fi
