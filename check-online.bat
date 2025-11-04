@echo off
chcp 65001 >nul
echo ========================================
echo 在线人数功能诊断工具
echo ========================================
echo.

echo [步骤 1] 检查依赖是否安装...
echo.
call npm list socket.io socket.io-client
if %errorlevel% neq 0 (
    echo.
    echo [❌ 错误] socket.io 依赖未安装
    echo [解决] 运行: npm install
    echo.
    goto :end
) else (
    echo [✅ 成功] socket.io 依赖已安装
)
echo.

echo [步骤 2] 检查文件是否存在...
echo.
if exist "src\stores\online.js" (
    echo [✅] src\stores\online.js - 存在
) else (
    echo [❌] src\stores\online.js - 不存在
)

if exist "src\components\Header.vue" (
    echo [✅] src\components\Header.vue - 存在
) else (
    echo [❌] src\components\Header.vue - 不存在
)

if exist "server\index.js" (
    echo [✅] server\index.js - 存在
) else (
    echo [❌] server\index.js - 不存在
)
echo.

echo [步骤 3] 检查后端服务器...
echo.
curl -s http://localhost:3001/api/health >nul 2>&1
if %errorlevel% equ 0 (
    echo [✅ 成功] 后端服务器正在运行
    echo     URL: http://localhost:3001
    curl -s http://localhost:3001/api/health
    echo.
) else (
    echo [❌ 错误] 后端服务器未运行
    echo [解决] 运行: npm run server
    echo.
)

echo [步骤 4] 检查前端服务器...
echo.
curl -s http://localhost:3000 >nul 2>&1
if %errorlevel% equ 0 (
    echo [✅ 成功] 前端服务器正在运行
    echo     URL: http://localhost:3000
) else (
    echo [❌ 错误] 前端服务器未运行
    echo [解决] 运行: npm run dev
)
echo.

:end
echo ========================================
echo 诊断完成
echo ========================================
echo.
echo 如果所有检查都通过，访问:
echo http://localhost:3000
echo.
echo 应该看到右上角显示在线人数
echo.
pause

