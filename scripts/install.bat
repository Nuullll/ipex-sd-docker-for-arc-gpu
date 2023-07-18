:: Prerequisite | 前置需求
:: Install Docker Desktop | 安装 Docker Desktop


:: Import image | 导入镜像
:: Will automatically skip if the image 'nuullll/ipex-arc-sd:latest' already exists
:: 如果镜像'nuullll/ipex-arc-sd:latest'存在，会自动跳过导入
docker load --input image.tar
pause

:: Import volumes | 导入数据卷
set cwd=%cd%
docker run --rm -it `
-v %cwd%:/backup `
-v deps-test:/deps `
-v huggingface-test:/root/.cache/huggingface `
--entrypoint bash `
nuullll/ipex-arc-sd:latest `
"cd /deps && tar xvf /backup/volume-deps.tar --strip 1 && cd /root/.cache/huggingface && tar xvf /backup/volume-huggingface.tar --strip 1"