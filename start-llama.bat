@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

REM ============================================
REM  Inkling 2 Mini 本地启动脚本
REM  实测环境：RTX 5070 Ti 16G / Q3_K_M / CUDA 13
REM  改下面三处路径为你自己的实际路径
REM ============================================

set MODEL_DIR=D:\DSH 对话\AI\gguf
set MODEL_FILE=q3.gguf
set LLAMA_DIR=D:\DSH 对话\AI\llama2

REM ---------- 参数区 ----------
REM CTX      上下文，8192 保守 / 16384 日常 / 32768 吃紧 / 65536 极限
REM MM_PROJ  视觉投影层，纯文本留空
REM FA       flash attention，这个构建必须写 on/off/auto，不能省

set CTX=8192
set MM_PROJ=mmproj.gguf
set FA=on

REM ---------- 上卡前先自检 ----------
echo [自检] 检测可用设备...
"!LLAMA_DIR!\llama-server.exe" --list-devices
echo.
echo [提示] 上面必须看到 CUDA0 才是真上卡。只有 (none) 说明缺 CUDA 运行库，
echo        这种情况下 -ngl 参数无效，模型会静默跑在 CPU 上，速度差 4 倍。
echo.

REM ---------- 组装命令 ----------
set CMD="!LLAMA_DIR!\llama-server.exe" -m "!MODEL_DIR!\!MODEL_FILE!" -ngl 99 -c !CTX! -fa !FA! -ctk q8_0 -ctv q8_0 -ub 256 --no-warmup --port 8080 -t 8

if not "!MM_PROJ!"=="" (
  set CMD=!CMD! --mmproj "!MODEL_DIR!\!MM_PROJ!"
)

echo [参数] 上下文=!CTX!  FA=!FA!  视觉层=!MM_PROJ!
echo.

!CMD!

endlocal
pause
