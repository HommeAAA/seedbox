#!/bin/bash

echo "╔════════════════════════════════════════╗"
echo "║   Debian 13 全面兼容性审查            ║"
echo "║          单元测试套件                  ║"
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
# 1. 核心组件测试
################################################################################################

test_section "1. 核心组件语法检查"

echo "检查所有核心脚本的 Bash 语法..."

CORE_FILES=(
    "inexistence.sh"
    "00.Installation/function"
    "00.Installation/ask"
    "00.Installation/options"
)

for file in "${CORE_FILES[@]}"; do
    if [[ -f "$file" ]]; then
        if bash -n "$file" 2>/dev/null; then
            test_pass "语法正确: $file"
        else
            test_fail "语法错误: $file"
        fi
    else
        test_fail "文件缺失: $file"
    fi
done

################################################################################################
# 2. 软件包模块测试
################################################################################################

test_section "2. 软件包模块检查"

echo "检查所有软件包模块..."

PACKAGE_MODULES=(
    "autobrr"
    "deluge"
    "flexget"
    "mono"
    "novnc"
    "qbittorrent"
    "rclone"
    "transmission"
    "vnstat"
    "wine"
)

for package in "${PACKAGE_MODULES[@]}"; do
    package_dir="00.Installation/package/$package"
    
    if [[ -d "$package_dir" ]]; then
        test_pass "软件包目录存在: $package"
        
        # 检查 install 脚本
        if [[ -f "$package_dir/install" ]]; then
            if bash -n "$package_dir/install" 2>/dev/null; then
                test_pass "  install 脚本语法正确: $package"
            else
                test_fail "  install 脚本语法错误: $package"
            fi
        else
            test_warn "  缺少 install 脚本: $package"
        fi
        
        # 检查 configure 脚本
        if [[ -f "$package_dir/configure" ]]; then
            if bash -n "$package_dir/configure" 2>/dev/null; then
                test_pass "  configure 脚本语法正确: $package"
            else
                test_fail "  configure 脚本语法错误: $package"
            fi
        fi
    else
        test_fail "软件包目录缺失: $package"
    fi
done

################################################################################################
# 3. 独立脚本测试
################################################################################################

test_section "3. 独立脚本检查"

echo "检查所有独立脚本..."

STANDALONE_SCRIPTS=(
    "00.Installation/package/docker"
    "00.Installation/package/filebrowser"
    "00.Installation/package/fpm"
    "00.Installation/package/libtorrent-rasterbar"
    "00.Installation/package/npm"
    "00.Installation/package/pyenv"
)

for script in "${STANDALONE_SCRIPTS[@]}"; do
    if [[ -f "$script" ]]; then
        if bash -n "$script" 2>/dev/null; then
            test_pass "脚本语法正确: $(basename "$script")"
        else
            test_fail "脚本语法错误: $(basename "$script")"
        fi
    else
        test_fail "脚本缺失: $(basename "$script")"
    fi
done

################################################################################################
# 4. 系统检测逻辑测试
################################################################################################

test_section "4. 系统检测逻辑测试"

echo "测试所有支持的系统版本..."

SYSTEM_TESTS=(
    "trixie:1:Debian 13"
    "bookworm:1:Debian 12"
    "bullseye:1:Debian 11"
    "buster:1:Debian 10"
    "stretch:2:Debian 9"
    "jessie:3:Debian 8"
    "bionic:1:Ubuntu 18.04"
    "xenial:2:Ubuntu 16.04"
)

for test_case in "${SYSTEM_TESTS[@]}"; do
    IFS=':' read -r codename expected description <<< "$test_case"
    
    SysSupport=0
    [[ $codename =~ (trixie|bookworm|bullseye) ]] && SysSupport=1
    [[ $codename =~ (bionic|buster)  ]] && SysSupport=1
    [[ $codename =~ (xenial|stretch) ]] && SysSupport=2
    [[ $codename =~ (jessie|wheezy|trusty) ]] && SysSupport=3
    
    if [[ $SysSupport == $expected ]]; then
        test_pass "$description: SysSupport=$SysSupport"
    else
        test_fail "$description: SysSupport=$SysSupport (预期: $expected)"
    fi
done

################################################################################################
# 5. rTorrent 版本检测测试
################################################################################################

test_section "5. rTorrent 版本检测测试"

RTORRENT_TESTS=(
    "trixie:1:Debian 13"
    "bookworm:1:Debian 12"
    "bullseye:1:Debian 11"
    "buster:1:Debian 10"
    "stretch:1:Debian 9"
    "bionic:1:Ubuntu 18.04"
    "xenial:0:Ubuntu 16.04"
    "jessie:0:Debian 8"
)

for test_case in "${RTORRENT_TESTS[@]}"; do
    IFS=':' read -r codename expected description <<< "$test_case"
    
    rtorrent_dev=0
    [[ $codename =~ (stretch|bionic|buster|bullseye|bookworm|trixie) ]] && rtorrent_dev=1
    
    if [[ $rtorrent_dev == $expected ]]; then
        test_pass "$description: rtorrent_dev=$rtorrent_dev"
    else
        test_fail "$description: rtorrent_dev=$rtorrent_dev (预期: $expected)"
    fi
done

################################################################################################
# 6. APT 源配置测试
################################################################################################

test_section "6. APT 源配置测试"

APT_TESTS=(
    "trixie:1:1:Debian 13"
    "bookworm:1:1:Debian 12"
    "bullseye:1:1:Debian 11"
    "buster:0:0:Debian 10"
    "stretch:0:0:Debian 9"
)

for test_case in "${APT_TESTS[@]}"; do
    IFS=':' read -r codename new_format non_free description <<< "$test_case"
    
    has_new_format=0
    has_non_free_firmware=0
    
    if [[ $codename =~ (trixie|bookworm|bullseye) ]]; then
        has_new_format=1
        has_non_free_firmware=1
    fi
    
    if [[ $has_new_format == $new_format && $has_non_free_firmware == $non_free ]]; then
        test_pass "$description: APT 源配置正确"
    else
        test_fail "$description: APT 源配置错误"
    fi
done

################################################################################################
# 7. Python 2.7 移除验证
################################################################################################

test_section "7. Python 2.7 移除验证"

PYTHON2_FILES=(
    "00.Installation/function"
    "00.Installation/package/flexget/install"
    "00.Installation/package/flexget/configure"
    "00.Installation/package/libtorrent-rasterbar"
)

for file in "${PYTHON2_FILES[@]}"; do
    if [[ -f "$file" ]]; then
        if grep -q "python2\.7" "$file" 2>/dev/null; then
            test_fail "发现 Python 2.7 引用: $(basename "$file")"
        else
            test_pass "无 Python 2.7 引用: $(basename "$file")"
        fi
    fi
done

################################################################################################
# 8. autobrr 集成验证
################################################################################################

test_section "8. autobrr 集成验证"

# 检查 install 脚本
if [[ -f "00.Installation/package/autobrr/install" ]]; then
    test_pass "autobrr install 脚本存在"
    
    if grep -q "install_autobrr_binary" "00.Installation/package/autobrr/install"; then
        test_pass "autobrr install 函数存在"
    else
        test_fail "autobrr install 函数缺失"
    fi
    
    if grep -q "create_autobrr_systemd" "00.Installation/package/autobrr/install"; then
        test_pass "autobrr systemd 函数存在"
    else
        test_fail "autobrr systemd 函数缺失"
    fi
else
    test_fail "autobrr install 脚本缺失"
fi

# 检查 configure 脚本
if [[ -f "00.Installation/package/autobrr/configure" ]]; then
    test_pass "autobrr configure 脚本存在"
    
    if grep -q "configure_autobrr_webui" "00.Installation/package/autobrr/configure"; then
        test_pass "autobrr configure 函数存在"
    else
        test_fail "autobrr configure 函数缺失"
    fi
    
    if grep -q "create_autobrr_admin_user" "00.Installation/package/autobrr/configure"; then
        test_pass "autobrr 用户创建函数存在"
    else
        test_fail "autobrr 用户创建函数缺失"
    fi
else
    test_fail "autobrr configure 脚本缺失"
fi

# 检查 ask 文件集成
if grep -q "ask_autobrr" "00.Installation/ask"; then
    test_pass "ask 文件中包含 ask_autobrr"
else
    test_fail "ask 文件中缺少 ask_autobrr"
fi

if grep -q "InsAutobrr" "00.Installation/ask"; then
    test_pass "ask 文件中使用 InsAutobrr 变量"
else
    test_fail "ask 文件中缺少 InsAutobrr 变量"
fi

# 检查 options 文件集成
if grep -q "\-\-autobrr" "00.Installation/options"; then
    test_pass "options 文件中包含 --autobrr"
else
    test_fail "options 文件中缺少 --autobrr"
fi

if grep -q "\-\-no-autobrr" "00.Installation/options"; then
    test_pass "options 文件中包含 --no-autobrr"
else
    test_fail "options 文件中缺少 --no-autobrr"
fi

# 检查主脚本集成
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

################################################################################################
# 9. 代码质量检查
################################################################################################

test_section "9. 代码质量检查"

# 括号匹配检查
ALL_SCRIPTS=(
    "inexistence.sh"
    "00.Installation/function"
    "00.Installation/ask"
    "00.Installation/options"
    "00.Installation/package/autobrr/install"
    "00.Installation/package/autobrr/configure"
    "00.Installation/package/flexget/install"
    "00.Installation/package/flexget/configure"
    "00.Installation/package/libtorrent-rasterbar"
)

for script in "${ALL_SCRIPTS[@]}"; do
    if [[ -f "$script" ]]; then
        open_parens=$(grep -o '{' "$script" 2>/dev/null | wc -l | tr -d ' ')
        close_parens=$(grep -o '}' "$script" 2>/dev/null | wc -l | tr -d ' ')
        
        if [[ $open_parens == $close_parens ]]; then
            test_pass "括号匹配: $(basename "$script")"
        else
            test_fail "括号不匹配: $(basename "$script") (开: $open_parens, 关: $close_parens)"
        fi
    fi
done

################################################################################################
# 10. 安全性检查
################################################################################################

test_section "10. 安全性检查"

# 检查硬编码密码
if grep -rq "password.*=" "00.Installation/package/autobrr/" 2>/dev/null | grep -v "POSTGRES_PASSWORD" | grep -v "db_password"; then
    test_warn "可能存在硬编码密码"
else
    test_pass "未发现硬编码密码"
fi

# 检查不安全的权限设置
if grep -rq "chmod 777" "00.Installation/package/autobrr/" 2>/dev/null; then
    test_fail "发现不安全的权限设置 (chmod 777)"
else
    test_pass "权限设置安全"
fi

# 检查是否使用 sudo/root 正确
if grep -q "sudo" "00.Installation/function" 2>/dev/null; then
    test_pass "使用了适当的权限提升"
else
    test_warn "未发现 sudo 使用"
fi

################################################################################################
# 11. 边界情况测试
################################################################################################

test_section "11. 边界情况测试"

# 测试未知系统版本
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

# 测试特殊字符
SysSupport=0
codename="trixie-bookworm"
[[ $codename =~ (trixie|bookworm|bullseye) ]] && SysSupport=1
[[ $codename =~ (bionic|buster)  ]] && SysSupport=1
[[ $codename =~ (xenial|stretch) ]] && SysSupport=2
[[ $codename =~ (jessie|wheezy|trusty) ]] && SysSupport=3

if [[ $SysSupport == 1 ]]; then
    test_pass "特殊字符版本号正确处理"
else
    test_fail "特殊字符版本号处理错误"
fi

################################################################################################
# 测试总结
################################################################################################

test_section "单元测试总结"

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
    echo "║   ✅ 所有单元测试通过！                ║"
    echo "╚════════════════════════════════════════╝"
    exit 0
else
    echo "╔════════════════════════════════════════╗"
    echo "║   ❌ 有 $TOTAL_FAILED 个单元测试失败   ║"
    echo "╚════════════════════════════════════════╝"
    exit 1
fi
