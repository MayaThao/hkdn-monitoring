# Triển khai Alertmanager và tích hợp Telegram

## 1. Mục đích

Triển khai Alertmanager trên máy chủ Monitoring dùng chung, cấu hình nhận cảnh báo từ Prometheus và gửi thông báo đến nhóm Telegram.

Mục tiêu thực hiện:

- Cài đặt và cấu hình Alertmanager trên máy chủ Monitoring.
- Thiết lập Telegram Bot và nhóm nhận thông báo.
- Kết nối Prometheus với Alertmanager.
- Kiểm thử luồng gửi cảnh báo từ Prometheus đến Telegram.
- Kiểm tra và xử lý lỗi phát sinh trong quá trình triển khai.
- Dọn dẹp rule thử nghiệm sau khi hoàn thành kiểm thử.

## 2. Môi trường thực hiện

| Thành phần | Thông tin |
|---|---|
| Máy chủ | `hkdn-server` |
| Hệ điều hành | Ubuntu 26.04 LTS |
| Kiến trúc | Linux AMD64 |
| Địa chỉ Tailscale | `100.93.18.76` |
| Prometheus | `3.16.0` |
| Alertmanager | `0.35.1` |
| Prometheus Web UI | `http://100.93.18.76:9090` |
| Alertmanager Web UI | `http://100.93.18.76:9093` |
| Telegram Bot | `@HKDN_Monitoring_Alert_Bot` |
| Telegram Group | `HKDN Monitoring Alerts` |

Các đường dẫn cấu hình:

- Alertmanager: `/etc/alertmanager/alertmanager.yml`
- Telegram Bot Token: `/etc/alertmanager/telegram_bot_token`
- Prometheus: `/etc/prometheus/prometheus.yml`
- Rule thử nghiệm: `/etc/prometheus/test-alerts.yml`
- Dữ liệu Alertmanager: `/var/lib/alertmanager`

## 3. Các bước triển khai

### 3.1. Cài đặt Alertmanager

Tải gói Alertmanager phiên bản 0.35.1 dành cho Linux AMD64.

Tệp cài đặt:

`alertmanager-0.35.1.linux-amd64.tar.gz`

Kiểm tra SHA256 của gói tải về:

```bash
sha256sum /tmp/alertmanager-0.35.1.linux-amd64.tar.gz
```

SHA256 đã xác minh:

```text
626bb9ae4486e14044705a6d6a0394f2ad8e3bf40df918f18f15b3d3775aa069
```

Cài đặt hai chương trình:

- `/usr/local/bin/alertmanager`
- `/usr/local/bin/amtool`

### 3.2. Tạo tài khoản dịch vụ và phân quyền

Tạo tài khoản hệ thống `alertmanager` để chạy dịch vụ với quyền riêng, không sử dụng tài khoản root.

Các thư mục được thiết lập:

| Đường dẫn | Quyền sở hữu |
|---|---|
| `/etc/alertmanager` | `root:alertmanager`, quyền `0750` |
| `/var/lib/alertmanager` | `alertmanager:alertmanager`, quyền `0750` |

Tệp Telegram Bot Token được lưu riêng tại:

`/etc/alertmanager/telegram_bot_token`

Phân quyền:

- Owner: `root`
- Group: `alertmanager`
- Permission: `0640`

Không ghi giá trị Token trực tiếp vào tài liệu hoặc đưa lên Git repository.

### 3.3. Cấu hình Telegram Bot và Group

Sử dụng Telegram Bot:

- Tên hiển thị: HKDN Monitoring Alert
- Username: `@HKDN_Monitoring_Alert_Bot`
- Nhóm nhận cảnh báo: `HKDN Monitoring Alerts`

Bot được thêm vào nhóm để nhận thông báo từ Alertmanager.

Thông tin nhóm:

- Loại nhóm: Group
- Chat ID: `-5441789523`

Đã kiểm tra khả năng gửi tin nhắn bằng Telegram Bot API. Kết quả trả về `ok: true` và tin nhắn kiểm thử xuất hiện trong nhóm Telegram.

### 3.4. Cấu hình Alertmanager

Tạo tệp cấu hình:

`/etc/alertmanager/alertmanager.yml`

Nội dung:

```yaml
global:
  resolve_timeout: 5m

route:
  receiver: telegram-group
  group_by: ['alertname']
  group_wait: 10s
  group_interval: 1m
  repeat_interval: 4h

receivers:
  - name: telegram-group
    telegram_configs:
      - bot_token_file: /etc/alertmanager/telegram_bot_token
        chat_id: -5441789523
        send_resolved: true
```

Cấu hình sử dụng `bot_token_file` để đọc Token từ tệp riêng, tránh lưu thông tin nhạy cảm trực tiếp trong cấu hình.

Kiểm tra quyền đọc cấu hình và Token:

```bash
sudo -u alertmanager test -r /etc/alertmanager/alertmanager.yml && echo "CONFIG READ OK"

sudo -u alertmanager test -r /etc/alertmanager/telegram_bot_token && echo "TOKEN READ OK"
```

Kiểm tra cú pháp cấu hình:

```bash
sudo amtool check-config /etc/alertmanager/alertmanager.yml
```

Kết quả: cấu hình hợp lệ.

### 3.5. Tạo và khởi chạy dịch vụ Alertmanager

Tạo systemd service tại:

`/etc/systemd/system/alertmanager.service`

Nội dung:

```ini
[Unit]
Description=Prometheus Alertmanager
Wants=network-online.target
After=network-online.target

[Service]
User=alertmanager
Group=alertmanager
Type=simple
ExecStart=/usr/local/bin/alertmanager \
  --config.file=/etc/alertmanager/alertmanager.yml \
  --storage.path=/var/lib/alertmanager \
  --web.listen-address=0.0.0.0:9093
Restart=on-failure
RestartSec=5s

[Install]
WantedBy=multi-user.target
```

Kích hoạt và khởi động dịch vụ:

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now alertmanager
```

Kiểm tra trạng thái:

```bash
sudo systemctl status alertmanager --no-pager
```

Kiểm tra tình trạng sẵn sàng:

```bash
curl -s http://127.0.0.1:9093/-/healthy
```

```bash
curl -s http://127.0.0.1:9093/-/ready
```

Kết quả: Alertmanager hoạt động và phản hồi `OK`.

### 3.6. Kết nối Prometheus với Alertmanager

Phối hợp với thành viên phụ trách Prometheus (3A) để cập nhật cấu hình kết nối trong:

`/etc/prometheus/prometheus.yml`

Cấu hình Alertmanager được khai báo trong phần `alerting`:

```yaml
alerting:
  alertmanagers:
    - static_configs:
        - targets:
            - 127.0.0.1:9093
```

Lưu ý: Cấu hình Prometheus được thực hiện phối hợp với thành viên 3A phụ trách máy chủ, không tự ý thay đổi cấu hình dùng chung.

Kiểm tra trạng thái kết nối Alertmanager qua API:

```bash
curl -sS http://127.0.0.1:9090/api/v1/alertmanagers | jq
```

Kết quả: Prometheus hiển thị Alertmanager đang hoạt động.

### 3.7. Kiểm thử gửi cảnh báo Telegram

Sử dụng rule thử nghiệm `AlwaysFiring` trong tệp:

`/etc/prometheus/test-alerts.yml`

Nội dung rule:

```yaml
groups:
  - name: test-alerts
    rules:
      - alert: AlwaysFiring
        expr: vector(1)
        for: 30s
        labels:
          severity: warning
        annotations:
          summary: "Test Alert"
          description: "This is a test alert from Prometheus."
```

Kiểm tra rule qua API Prometheus:

```bash
curl -sS http://127.0.0.1:9090/api/v1/rules | jq
```

Kết quả kiểm thử:

- Rule `AlwaysFiring` được Prometheus nhận diện.
- Alert xuất hiện trong giao diện Alertmanager.
- Telegram nhận được thông báo cảnh báo trong nhóm `HKDN Monitoring Alerts`.
- Nội dung thông báo có tên cảnh báo, mức độ nghiêm trọng và thông tin mô tả.

Log Alertmanager ghi nhận:

```text
msg="Notify success" component=dispatcher receiver=telegram-group
```

Đây là kết quả xác nhận Alertmanager gửi thông báo thành công đến Telegram.

### 3.8. Khắc phục lỗi DNS

Trong quá trình gửi cảnh báo, Alertmanager phát sinh lỗi không phân giải được tên miền `api.telegram.org`.

Thông báo lỗi ghi nhận:

```text
dial tcp: lookup api.telegram.org on 127.0.0.53:53: read udp: i/o timeout
```

Tiến hành kiểm tra kết nối mạng và DNS:

```bash
ping -c 4 1.1.1.1
```

```bash
nslookup api.telegram.org 1.1.1.1
```

Kết quả kiểm tra cho thấy máy chủ vẫn có kết nối Internet qua địa chỉ IP nhưng DNS mặc định gặp sự cố.

Sau khi phối hợp với thành viên phụ trách máy chủ, DNS trên giao diện mạng chính `enp0s3` được điều chỉnh sang:

- `1.1.1.1`
- `8.8.8.8`

Kiểm tra lại khả năng truy cập Telegram API:

```bash
curl -I --connect-timeout 10 https://api.telegram.org
```

Kết quả: máy chủ nhận phản hồi HTTP/2 302 từ Telegram API, xác nhận kết nối HTTPS thành công.

Sau khi DNS được xử lý, log Alertmanager ghi nhận `Notify success` và Telegram nhận được cảnh báo.

### 3.9. Dọn dẹp rule thử nghiệm

Sau khi hoàn thành kiểm thử, tiến hành sao lưu và xóa rule `AlwaysFiring` để tránh tiếp tục phát sinh cảnh báo thử nghiệm.

Sao lưu tệp:

```bash
sudo cp /etc/prometheus/test-alerts.yml /etc/prometheus/test-alerts.yml.bak
```

Kiểm tra tệp sao lưu:

```bash
sudo ls -l /etc/prometheus/test-alerts.yml*
```

Làm rỗng tệp rule thử nghiệm:

```bash
sudo truncate -s 0 /etc/prometheus/test-alerts.yml
```

Kiểm tra lại cấu hình Prometheus:

```bash
sudo promtool check config /etc/prometheus/prometheus.yml
```

Kết quả:

```text
SUCCESS: 0 rule found
```

Prometheus chưa hỗ trợ reload qua systemd service và Lifecycle API chưa được bật. Sau khi thực hiện restart dịch vụ để áp dụng thay đổi:

```bash
sudo systemctl restart prometheus
```

Kiểm tra trạng thái dịch vụ:

```bash
sudo systemctl status prometheus --no-pager
```

Kết quả: Prometheus ở trạng thái `active (running)`.

Kiểm tra danh sách rule sau khi khởi động lại:

```bash
curl -s http://127.0.0.1:9090/api/v1/rules | jq
```

Kết quả:

```json
{
  "status": "success",
  "data": {
    "groups": []
  }
}
```

Như vậy, rule thử nghiệm đã được dọn dẹp và Prometheus không còn nhóm rule thử nghiệm được tải.

Tệp sao lưu `test-alerts.yml.bak` được giữ lại để phục vụ khôi phục khi cần.

## 4. Cấu hình và lệnh sử dụng

### 4.1. Các đường dẫn cấu hình quan trọng

| Thành phần | Đường dẫn |
|---|---|
| Alertmanager binary | `/usr/local/bin/alertmanager` |
| AMTool | `/usr/local/bin/amtool` |
| Alertmanager config | `/etc/alertmanager/alertmanager.yml` |
| Telegram Bot Token | `/etc/alertmanager/telegram_bot_token` |
| Alertmanager service | `/etc/systemd/system/alertmanager.service` |
| Prometheus config | `/etc/prometheus/prometheus.yml` |
| Test alert rules | `/etc/prometheus/test-alerts.yml` |

### 4.2. Các lệnh kiểm tra thường dùng

Kiểm tra Alertmanager:

```bash
sudo systemctl status alertmanager --no-pager
```

Kiểm tra cấu hình Alertmanager:

```bash
sudo amtool check-config /etc/alertmanager/alertmanager.yml
```

Kiểm tra Prometheus:

```bash
sudo systemctl status prometheus --no-pager
```

Kiểm tra cấu hình Prometheus:

```bash
sudo promtool check config /etc/prometheus/prometheus.yml
```

Kiểm tra log Alertmanager:

```bash
sudo journalctl -u alertmanager --since "10 minutes ago" --no-pager
```

Kiểm tra danh sách rule:

```bash
curl -s http://127.0.0.1:9090/api/v1/rules | jq
```

## 5. Kết quả mong đợi và kết quả thực tế

| Nội dung | Kết quả mong đợi | Kết quả thực tế |
|---|---|---|
| Cài đặt Alertmanager | Cài đặt thành công | Đã cài đặt phiên bản 0.35.1 |
| Cấu hình Alertmanager | Cấu hình hợp lệ | `amtool check-config` thành công |
| Dịch vụ Alertmanager | Hoạt động ổn định | `active (running)` |
| Kết nối Prometheus | Prometheus nhận diện Alertmanager | API hiển thị Alertmanager đang hoạt động |
| Gửi cảnh báo Telegram | Telegram nhận được cảnh báo | Đã nhận được cảnh báo `AlwaysFiring` |
| Khắc phục DNS | Telegram API truy cập được | HTTPS trả về HTTP/2 302 |
| Dọn rule thử nghiệm | Không còn rule thử nghiệm | API trả về `groups: []` |

**Kết luận:** Đã triển khai Alertmanager, tích hợp Prometheus với Telegram và kiểm thử thành công luồng gửi cảnh báo. Sau kiểm thử, rule `AlwaysFiring` đã được sao lưu và dọn dẹp. Prometheus tiếp tục hoạt động bình thường.

## 6. Lỗi gặp phải và cách xử lý

### 6.1. Lỗi phân giải DNS

**Hiện tượng:** Alertmanager không thể phân giải `api.telegram.org`, dẫn đến việc gửi cảnh báo Telegram thất bại.

**Nguyên nhân:** DNS trên giao diện mạng chính của máy chủ gặp sự cố.

**Cách xử lý:** Phối hợp điều chỉnh DNS trên giao diện mạng `enp0s3` sang `1.1.1.1` và `8.8.8.8`.

**Kết quả:** Telegram API truy cập thành công và Alertmanager ghi nhận `Notify success`.

### 6.2. Không thể reload Prometheus bằng systemd

**Hiện tượng:**

```text
Failed to reload prometheus.service:
Job type reload is not applicable for unit prometheus.service.
```

**Nguyên nhân:** Prometheus service chưa khai báo `ExecReload`.

Khi thử gọi HTTP reload API, máy chủ trả về:

```text
HTTP/1.1 403 Forbidden

Lifecycle API is not enabled.
```

**Cách xử lý:** Sau khi kiểm tra cấu hình và được phép thực hiện trên máy chủ dùng chung, sử dụng:

```bash
sudo systemctl restart prometheus
```

**Kết quả:** Prometheus khởi động lại thành công và hoạt động ở trạng thái `active (running)`.

## 7. Minh chứng thực hiện

Các hình ảnh minh chứng được lưu tại:

`monitoring/evidence/25-11-2026/SCRUM-36/`

Danh sách minh chứng:

| STT | Tên tệp | Nội dung |
|---|---|---|
| 01 | `01-alertmanager-installation-verification.png` | Kiểm tra cài đặt Alertmanager |
| 02 | `02-alertmanager-status.png` | Trạng thái hoạt động của Alertmanager |
| 03 | `03-alertmanager-telegram-config.png` | Cấu hình Telegram Receiver |
| 04 | `04-alertmanager-telegram-notification-success.png` | Log xác nhận gửi thông báo thành công |
| 05 | `05-prometheus-alertmanager-connection.png` | Kết nối Prometheus với Alertmanager |
| 06 | `06-telegram-notification-test.png` | Tin nhắn cảnh báo thử nghiệm trên Telegram |
| 07 | `07-prometheus-test-alert-cleanup.png` | Kết quả dọn dẹp rule thử nghiệm |

