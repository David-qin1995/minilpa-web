@echo off
echo ========================================
echo MiniLPA Web - 一键启动所有服务
echo ========================================
echo.

echo 正在启动后端服务器（新窗口）...
start "MiniLPA 后端" cmd /k "npm run server"
timeout /t 3 /nobreak >nul

echo 正在启动前端开发服务器（新窗口）...
start "MiniLPA 前端" cmd /k "npm run dev"
timeout /t 3 /nobreak >nul

echo.
echo ========================================
echo 启动完成！
echo ========================================
echo.
echo 后端服务: http://localhost:3001
echo 前端服务: http://localhost:3000
echo.
echo 等待 5 秒后自动打开浏览器...
timeout /t 5 /nobreak

start http://localhost:3000

echo.
echo 提示：
echo - 后端和前端在独立窗口运行
echo - 关闭窗口即可停止服务
echo - 页面右上角应显示在线人数
echo.
pause

