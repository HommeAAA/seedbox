#!/bin/bash

test_system_detection() {
    echo "========================================="
    echo "测试系统版本检测逻辑"
    echo "========================================="
    echo
    
    test_cases=(
        "trixie:Debian 13:1"
        "bookworm:Debian 12:1"
        "bullseye:Debian 11:1"
        "buster:Debian 10:1"
        "stretch:Debian 9:2"
        "xenial:Ubuntu 16.04:2"
        "bionic:Ubuntu 18.04:1"
        "jessie:Debian 8:3"
    )
    
    passed=0
    failed=0
    
    for test_case in "${test_cases[@]}"; do
        IFS=':' read -r codename name expected <<< "$test_case"
        
        SysSupport=0
        [[ $codename =~ (trixie|bookworm|bullseye) ]] && SysSupport=1
        [[ $codename =~ (bionic|buster)  ]] && SysSupport=1
        [[ $codename =~ (xenial|stretch) ]] && SysSupport=2
        [[ $codename =~ (jessie|wheezy|trusty) ]] && SysSupport=3
        
        if [[ $SysSupport == $expected ]]; then
            echo "✅ PASS: $name ($codename) -> SysSupport=$SysSupport (预期: $expected)"
            ((passed++))
        else
            echo "❌ FAIL: $name ($codename) -> SysSupport=$SysSupport (预期: $expected)"
            ((failed++))
        fi
    done
    
    echo
    echo "========================================="
    echo "测试结果: 通过 $passed, 失败 $failed"
    echo "========================================="
    
    return $failed
}

test_rtorrent_detection() {
    echo
    echo "========================================="
    echo "测试 rTorrent 版本检测逻辑"
    echo "========================================="
    echo
    
    test_cases=(
        "trixie:Debian 13:1"
        "bookworm:Debian 12:1"
        "bullseye:Debian 11:1"
        "buster:Debian 10:1"
        "stretch:Debian 9:1"
        "bionic:Ubuntu 18.04:1"
        "xenial:Ubuntu 16.04:0"
        "jessie:Debian 8:0"
    )
    
    passed=0
    failed=0
    
    for test_case in "${test_cases[@]}"; do
        IFS=':' read -r codename name expected <<< "$test_case"
        
        rtorrent_dev=0
        [[ $codename =~ (stretch|bionic|buster|bullseye|bookworm|trixie) ]] && rtorrent_dev=1
        
        if [[ $rtorrent_dev == $expected ]]; then
            echo "✅ PASS: $name ($codename) -> rtorrent_dev=$rtorrent_dev (预期: $expected)"
            ((passed++))
        else
            echo "❌ FAIL: $name ($codename) -> rtorrent_dev=$rtorrent_dev (预期: $expected)"
            ((failed++))
        fi
    done
    
    echo
    echo "========================================="
    echo "测试结果: 通过 $passed, 失败 $failed"
    echo "========================================="
    
    return $failed
}

test_apt_sources() {
    echo
    echo "========================================="
    echo "测试 APT 源配置逻辑"
    echo "========================================="
    echo
    
    test_cases=(
        "trixie:Debian 13:新格式+non-free-firmware"
        "bookworm:Debian 12:新格式+non-free-firmware"
        "bullseye:Debian 11:新格式+non-free-firmware"
        "buster:Debian 10:旧格式"
        "stretch:Debian 9:旧格式"
    )
    
    passed=0
    failed=0
    
    for test_case in "${test_cases[@]}"; do
        IFS=':' read -r codename name expected <<< "$test_case"
        
        has_new_format=0
        has_non_free_firmware=0
        
        if [[ $codename =~ (trixie|bookworm|bullseye) ]]; then
            has_new_format=1
            has_non_free_firmware=1
        fi
        
        result=""
        [[ $has_new_format == 1 ]] && result="新格式" || result="旧格式"
        [[ $has_non_free_firmware == 1 ]] && result+="+non-free-firmware"
        
        if [[ $result == $expected ]]; then
            echo "✅ PASS: $name ($codename) -> $result"
            ((passed++))
        else
            echo "❌ FAIL: $name ($codename) -> $result (预期: $expected)"
            ((failed++))
        fi
    done
    
    echo
    echo "========================================="
    echo "测试结果: 通过 $passed, 失败 $failed"
    echo "========================================="
    
    return $failed
}

test_python_version() {
    echo
    echo "========================================="
    echo "测试 Python 版本检测"
    echo "========================================="
    echo
    
    python3_version=$(python3 -c 'import sys; print(".".join(map(str, sys.version_info[:2])))' 2>/dev/null)
    
    if [[ -n $python3_version ]]; then
        echo "✅ PASS: 检测到 Python 3 版本: $python3_version"
        echo "   路径: /usr/local/lib/python${python3_version}/"
        return 0
    else
        echo "❌ FAIL: 无法检测 Python 3 版本"
        return 1
    fi
}

main() {
    echo
    echo "╔════════════════════════════════════════╗"
    echo "║   Debian 13 兼容性测试套件            ║"
    echo "╚════════════════════════════════════════╝"
    echo
    
    total_failed=0
    
    test_system_detection || ((total_failed++))
    test_rtorrent_detection || ((total_failed++))
    test_apt_sources || ((total_failed++))
    test_python_version || ((total_failed++))
    
    echo
    echo "╔════════════════════════════════════════╗"
    if [[ $total_failed == 0 ]]; then
        echo "║   ✅ 所有测试通过！                   ║"
    else
        echo "║   ❌ 有 $total_failed 个测试套件失败            ║"
    fi
    echo "╚════════════════════════════════════════╝"
    echo
    
    return $total_failed
}

main "$@"
