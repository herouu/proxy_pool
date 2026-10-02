FROM python:3.10-alpine AS builder
WORKDIR /wheels
COPY ./requirements.txt .
RUN apk add --no-cache gcc musl-dev libxml2-dev libxslt-dev && pip install --no-cache-dir --upgrade pip && pip wheel --no-cache-dir --wheel-dir=/wheels -r requirements.txt
FROM python:3.10-alpine
LABEL maintainer="jhao104 <j_hao104@163.com>"
WORKDIR /app
RUN apk add --no-cache tini libxml2 libxslt && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && echo "Asia/Shanghai" > /etc/timezone
COPY ./requirements.txt .
COPY --from=builder /wheels /wheels
RUN pip install --no-cache-dir --no-index --find-links=/wheels -r requirements.txt && rm -rf /wheels /root/.cache && find /usr/local/lib/python3.10/site-packages -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null || true
COPY . .
EXPOSE 5010
ENTRYPOINT ["tini", "--", "bash", "proxy_pool.sh", "start", "--fg"]
