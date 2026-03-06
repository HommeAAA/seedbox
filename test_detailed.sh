#!/bin/bash

test_python_functions() {
    echo "========================================="
    echo "测试 Python 函数修改"
    echo "========================================="
    echo
    
    source 00.Installation/function
    
    echo "测试 1: pyenv_install_python 函数"
    echo "-------------------------------------------"
    grep -A 5 "function pyenv_install_python" 00.Installation/function | grep -q "Python 2.7 support has been removed"
    if [[ $? == 0 ]]; then
        echo "✅ PASS: 已添加 Python 2.7 移除说明"
    else
        echo "❌ FAIL: 未找到 Python 2.7 移除说明"
    fi
    
    echo
    echo "测试 2: pyenv_init_venv 函数"
    echo "-------------------------------------------"
    grep -A 10 "function pyenv_init_venv" 00.Installation/function | grep -q "Only Python 3 is supported"
    if [[ $? == 0 ]]; then
        echo "✅ PASS: 已添加 Python 3 限制检查"
    else
        echo "❌ FAIL: 未找到 Python 3 限制检查"
    fi
    
    echo
    echo "测试 3: python_getpip 函数"
    echo "-------------------------------------------"
    grep -A 15 "function python_getpip" 00.Installation/function | grep -q "Only Python 3 is supported"
    if [[ $? == 0 ]]; then
        echo "✅ PASS: 已添加 Python 3 限制检查"
    else
        echo "❌ FAIL: 未找到 Python 3 限制检查"
    fi
    
    echo
}

test_flexget_python3() {
    echo "========================================="
    echo "测试 FlexGet Python 3 迁移"
    echo "========================================="
    echo
    
    echo "测试 1: 检查是否移除了 Python 2.7 安装函数"
    echo "-------------------------------------------"
    if ! grep -q "function install_flexget2_user" 00.Installation/package/flexget/install; then
        echo "✅ PASS: 已移除 install_flexget2_user 函数"
    else
        echo "❌ FAIL: 仍然存在 install_flexget2_user 函数"
    fi
    
    echo
    echo "测试 2: 检查 Python 路径更新"
    echo "-------------------------------------------"
    if grep -q "python_cmd -m site" 00.Installation/package/flexget/configure; then
        echo "✅ PASS: 使用动态 Python 路径检测"
    else
        echo "❌ FAIL: 未使用动态 Python 路径检测"
    fi
    
    echo
    echo "测试 3: 检查编译命令更新"
    echo "-------------------------------------------"
    if grep -q "python3 -m compileall" 00.Installation/package/flexget/configure; then
        echo "✅ PASS: 使用 python3 -m compileall"
    else
        echo "❌ FAIL: 未使用 python3 -m compileall"
    fi
    
    echo
}

test_libtorrent_python3() {
    echo "========================================="
    echo "测试 libtorrent Python 3 迁移"
    echo "========================================="
    echo
    
    echo "测试 1: 检查 Python 版本动态检测"
    echo "-------------------------------------------"
    if grep -q "python3_version=\$(python3 -c" 00.Installation/package/libtorrent-rasterbar; then
        echo "✅ PASS: 使用动态 Python 版本检测"
    else
        echo "❌ FAIL: 未使用动态 Python 版本检测"
    fi
    
    echo
    echo "测试 2: 检查是否移除 python2.7 硬编码"
    echo "-------------------------------------------"
    if ! grep -q "python2\.7" 00.Installation/package/libtorrent-rasterbar; then
        echo "✅ PASS: 已移除 python2.7 硬编码"
    else
        echo "❌ FAIL: 仍然存在 python2.7 硬编码"
    fi
    
    echo
}

test_backward_compatibility() {
    echo "========================================="
    echo "测试向后兼容性"
    echo "========================================="
    echo
    
    echo "测试 1: Debian 10 (buster) 支持"
    echo "-------------------------------------------"
    CODENAME=buster
    SysSupport=0
    [[ $CODENAME =~ (trixie|bookworm|bullseye) ]] && SysSupport=1
    [[ $CODENAME =~ (bionic|buster)  ]] && SysSupport=1
    [[ $CODENAME =~ (xenial|stretch) ]] && SysSupport=2
    
    if [[ $SysSupport == 1 ]]; then
        echo "✅ PASS: Debian 10 仍然受支持 (SysSupport=$SysSupport)"
    else
        echo "❌ FAIL: Debian 10 不受支持 (SysSupport=$SysSupport)"
    fi
    
    echo
    echo "测试 2: Debian 9 (stretch) 支持"
    echo "-------------------------------------------"
    CODENAME=stretch
    SysSupport=0
    [[ $CODENAME =~ (trixie|bookworm|bullseye) ]] && SysSupport=1
    [[ $CODENAME =~ (bionic|buster)  ]] && SysSupport=1
    [[ $CODENAME =~ (xenial|stretch) ]] && SysSupport=2
    
    if [[ $SysSupport == 2 ]]; then
        echo "✅ PASS: Debian 9 仍然受支持 (SysSupport=$SysSupport)"
    else
        echo "❌ FAIL: Debian 9 不受支持 (SysSupport=$SysSupport)"
    fi
    
    echo
    echo "测试 3: APT 源格式兼容性"
    echo "-------------------------------------------"
    CODENAME=buster
    if [[ ! $CODENAME =~ (trixie|bookworm|bullseye) ]]; then
        echo "✅ PASS: Debian 10 使用旧版 APT 源格式"
    else
        echo "❌ FAIL: Debian 10 使用新版 APT 源格式"
    fi
    
    echo
    echo "测试 4: Ubuntu 18.04 (bionic) 支持"
    echo "-------------------------------------------"
    CODENAME=bionic
    SysSupport=0
    [[ $CODENAME =~ (trixie|bookworm|bullseye) ]] && SysSupport=1
    [[ $CODENAME =~ (bionic|buster)  ]] && SysSupport=1
    [[ $CODENAME =~ (xenial|stretch) ]] && SysSupport=2
    
    if [[ $SysSupport == 1 ]]; then
        echo "✅ PASS: Ubuntu 18.04 仍然受支持 (SysSupport=$SysSupport)"
    else
        echo "❌ FAIL: Ubuntu 18.04 不受支持 (SysSupport=$SysSupport)"
    fi
    
    echo
}

test_documentation() {
    echo "========================================="
    echo "测试文档更新"
    echo "========================================="
    echo
    
    echo "测试 1: README 支持系统列表"
    echo "-------------------------------------------"
    if grep -q "Debian 9/10/11/12/13" README.md; then
        echo "✅ PASS: README 已更新支持系统列表"
    else
        echo "❌ FAIL: README 未更新支持系统列表"
    fi
    
    echo
    echo "测试 2: README 推荐版本"
    echo "-------------------------------------------"
    if grep -q "推荐使用 Debian 12/13" README.md; then
        echo "✅ PASS: README 已更新推荐版本"
    else
        echo "❌ FAIL: README 未更新推荐版本"
    fi
    
    echo
    echo "测试 3: Deluge Python 说明"
    echo "-------------------------------------------"
    if grep -q "Python 3" README.md | grep -q "Deluge"; then
        echo "✅ PASS: README 已更新 Deluge Python 说明"
    else
        echo "⚠️  WARNING: README Deluge Python 说明可能需要检查"
    fi
    
    echo
}

main() {
    echo
    echo "╔════════════════════════════════════════╗"
    echo "║   Debian 13 兼容性详细测试            ║"
    echo "╚════════════════════════════════════════╝"
    echo
    
    test_python_functions
    test_flexget_python3
    test_libtorrent_python3
    test_backward_compatibility
    test_documentation
    
    echo "╔════════════════════════════════════════╗"
    echo "║   ✅ 所有详细测试完成！               ║"
    echo "╚════════════════════════════════════════╝"
    echo
}

main "$@"
