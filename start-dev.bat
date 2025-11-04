@echo off
echo ========================================
echo MiniLPA Web - 开发环境启动
echo ========================================
echo.

echo 步骤 1: 安装依赖...
call npm install
if %errorlevel% neq 0 (
    echo [错误] 依赖安装失败！
    pause
    exit /b 1
)
echo [完成] 依赖安装成功
echo.

echo 步骤 2: 启动后端服务器...
echo 请在另一个终端窗口运行: npm run server
echo.

echo 步骤 3: 启动前端开发服务器...
echo.
echo ========================================
echo 开发服务器即将启动
echo ========================================
echo.
echo 前端: http://localhost:3000
echo 后端: http://localhost:3001
echo.

call npm run dev

