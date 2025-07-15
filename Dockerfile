FROM debian:bullseye

ENV DEBIAN_FRONTEND=noninteractive

# --- 环境变量（可通过 docker run -e 覆盖） ---
ENV GITHUB_REPO_URL=""
ENV GITHUB_USER=""
ENV GITHUB_TOKEN=""
ENV GITHUB_BRANCH="master"
ENV GIT_AUTHOR_NAME="DockerContainer"
ENV GIT_AUTHOR_EMAIL="DockerContainer"

# --- 安装 ca-certificates 和 curl（HTTP 清华源） ---
RUN echo "deb http://mirrors.tuna.tsinghua.edu.cn/debian bullseye main contrib non-free" > /etc/apt/sources.list && \
    echo "deb http://mirrors.tuna.tsinghua.edu.cn/debian bullseye-updates main contrib non-free" >> /etc/apt/sources.list && \
    echo "deb http://mirrors.tuna.tsinghua.edu.cn/debian-security bullseye-security main contrib non-free" >> /etc/apt/sources.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends ca-certificates curl gnupg && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# --- 切换为 HTTPS 源并安装 git ---
RUN echo "deb https://mirrors.tuna.tsinghua.edu.cn/debian bullseye main contrib non-free" > /etc/apt/sources.list && \
    echo "deb https://mirrors.tuna.tsinghua.edu.cn/debian bullseye-updates main contrib non-free" >> /etc/apt/sources.list && \
    echo "deb https://mirrors.tuna.tsinghua.edu.cn/debian-security bullseye-security main contrib non-free" >> /etc/apt/sources.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends git && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# --- 安装 Node.js 22 和 Yarn ---
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
    apt-get install -y --no-install-recommends nodejs && \
    npm install -g yarn && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# --- 创建默认目录 ---
RUN mkdir -p /host/data

# --- 启动脚本 ---
RUN echo '#!/bin/sh\n\
set -e\n\
REPO_DIR="/host/data"\n\
\n\
git config --global --add safe.directory "$REPO_DIR"\n\
git config --global user.name "$GIT_AUTHOR_NAME"\n\
git config --global user.email "$GIT_AUTHOR_EMAIL"\n\
\n\
if [ -z "$GITHUB_REPO_URL" ]; then\n\
  echo "❌ GITHUB_REPO_URL 未设置"; exit 1\n\
fi\n\
\n\
if [ ! -d "$REPO_DIR/.git" ]; then\n\
  echo "📥 正在 clone 仓库 (分支: $GITHUB_BRANCH)..."\n\
  if [ -n "$GITHUB_TOKEN" ] && [ -n "$GITHUB_USER" ]; then\n\
    AUTH_URL=$(echo "$GITHUB_REPO_URL" | sed "s#https://#https://$GITHUB_USER:$GITHUB_TOKEN@#")\n\
    git clone -b "$GITHUB_BRANCH" "$AUTH_URL" "$REPO_DIR"\n\
  else\n\
    git clone -b "$GITHUB_BRANCH" "$GITHUB_REPO_URL" "$REPO_DIR"\n\
  fi\n\
else\n\
  echo "🔄 仓库存在，执行 pull (分支: $GITHUB_BRANCH) ..."\n\
  cd "$REPO_DIR"\n\
  git fetch origin "$GITHUB_BRANCH"\n\
  git checkout "$GITHUB_BRANCH"\n\
  git pull origin "$GITHUB_BRANCH"\n\
fi\n\
\n\
if [ -f /host/.env ]; then\n\
  echo "📄 检测到 /host/.env，移动到 strapi 目录..."\n\
  mv /host/.env "$REPO_DIR/strapi/.env"\n\
fi\n\
\n\
cd "$REPO_DIR/strapi"\n\
echo "📦 安装依赖..."\n\
yarn install\n\
echo "🚀 启动 yarn develop..."\n\
yarn develop\n' > /start.sh && chmod +x /start.sh

CMD ["/start.sh"]
