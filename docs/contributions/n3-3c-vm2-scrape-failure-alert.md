# N3-3C – VM2 Scrape Failure Alert Rule

## 1. Mục đích

Xây dựng và triển khai Alert Rule trên Prometheus nhằm phát hiện tình trạng Prometheus không thể scrape dữ liệu từ Node Exporter trên VM2.

Khi VM2 Node Exporter không phản hồi, Prometheus ghi nhận giá trị `up = 0`. Nếu tình trạng kéo dài liên tục trong 2 phút, cảnh báo `VM2ScrapeFailure` chuyển sang trạng thái `FIRING` và được gửi đến Telegram thông qua Alertmanager.

Khi Node Exporter hoạt động trở lại, cảnh báo chuyển sang `RESOLVED` và Telegram nhận được thông báo phục hồi.

## 2. Môi trường thực hiện

| Thành phần | Thông tin |
|---|---|
| Hệ điều hành máy chủ | Ubuntu |
| Prometheus Server | hkdn-server |
| Prometheus URL | http://100.93.18.76:9090 |
| Alertmanager URL | http://100.93.18.76:9093 |
| VM2 Node Exporter | 100.96.202.53:9100 |
| Prometheus job | vm2-webserver |
| Alert Rule file | /etc/prometheus/alert_rules.yml |
| File cấu hình Prometheus | /etc/prometheus/prometheus.yml |
| Công cụ kiểm tra | promtool |
| Kênh nhận cảnh báo | Telegram |
| Thời gian thực hiện | 26/11/2026 |

## 3. Cấu hình Alert Rule

### 3.1. Tạo file Alert Rule

Tạo file:

`monitoring/prometheus/rules/vm2-alerts.yml`

Nội dung:

```yaml
groups:
  - name: vm2-scrape-alerts
    rules:
      - alert: VM2ScrapeFailure
        expr: up{job="vm2-webserver", instance="100.96.202.53:9100"} == 0
        for: 2m
        labels:
          severity: warning
        annotations:
          summary: "VM2 Node Exporter scrape failure"
          description: "Prometheus cannot scrape VM2 Node Exporter at {{ $labels.instance }} for more than 2 minutes."
```

### 3.2. Ý nghĩa cấu hình

- `alert`: Tên cảnh báo là `VM2ScrapeFailure`.
- `expr`: Kiểm tra trạng thái scrape của VM2 thông qua metric `up`.
- `job`: Giới hạn đối tượng giám sát ở job `vm2-webserver`.
- `instance`: Xác định chính xác Node Exporter tại `100.96.202.53:9100`.
- `for: 2m`: Yêu cầu điều kiện cảnh báo duy trì liên tục trong 2 phút trước khi chuyển sang `FIRING`.
- `severity: warning`: Mức độ cảnh báo Warning.
- `summary`: Nội dung tóm tắt sự cố.
- `description`: Mô tả chi tiết tình trạng không thể scrape VM2.

## 4. Các bước triển khai

### 4.1. Chuyển file Alert Rule lên máy chủ

Sử dụng SCP từ máy Windows:

```powershell
scp monitoring\prometheus\rules\vm2-alerts.yml duc@100.93.18.76:/tmp/vm2-alerts.yml
```

### 4.2. Kiểm tra cú pháp Alert Rule

```bash
promtool check rules /tmp/vm2-alerts.yml
```

Kết quả mong đợi:

```text
SUCCESS: 1 rules found
```

### 4.3. Sao chép Alert Rule vào thư mục cấu hình Prometheus

```bash
sudo cp /tmp/vm2-alerts.yml /etc/prometheus/alert_rules.yml
sudo chown root:prometheus /etc/prometheus/alert_rules.yml
sudo chmod 640 /etc/prometheus/alert_rules.yml
```

### 4.4. Khai báo rule_files trong prometheus.yml

Bổ sung đường dẫn Alert Rule vào cấu hình `/etc/prometheus/prometheus.yml`, đồng thời giữ nguyên file test-alerts.yml hiện có:

```yaml
rule_files:
  - "/etc/prometheus/test-alerts.yml"
  - "/etc/prometheus/alert_rules.yml"
```

### 4.5. Kiểm tra cấu hình Prometheus

```bash
sudo promtool check config /etc/prometheus/prometheus.yml
```

Kết quả xác nhận:
- Có 2 rule files được nhận diện.
- File cấu hình Prometheus hợp lệ.
- `alert_rules.yml` có 1 rule.

### 4.6. Khởi động lại Prometheus

```bash
sudo systemctl restart prometheus
sudo systemctl status prometheus
```

Kiểm tra trạng thái sẵn sàng:

```bash
curl -s http://localhost:9090/-/ready
```

Kết quả mong đợi:

```text
Prometheus Server is Ready.
```

## 5. Kiểm tra hoạt động của Alert Rule

Truy cập Prometheus tại:

`http://100.93.18.76:9090/alerts`

Kiểm tra rule group `vm2-scrape-alerts` và cảnh báo `VM2ScrapeFailure`.

Sử dụng truy vấn PromQL:

```promql
up{job="vm2-webserver", instance="100.96.202.53:9100"}
```

Giá trị:
- `1`: Prometheus scrape VM2 thành công.
- `0`: Prometheus không thể scrape VM2.

## 6. Kiểm thử phát hiện sự cố và phục hồi

### 6.1. Kiểm tra trạng thái bình thường

Ban đầu, VM2 Node Exporter hoạt động và Prometheus ghi nhận:

```text
up = 1
```

### 6.2. Mô phỏng sự cố scrape

Phối hợp với Nhóm 2 để tạm dừng dịch vụ Node Exporter trên VM2:

```bash
sudo systemctl stop prometheus-node-exporter.service
```

Sau khi dịch vụ dừng, Prometheus ghi nhận:

```text
up = 0
```

### 6.3. Xác nhận cảnh báo FIRING

Khi điều kiện `up == 0` duy trì liên tục trong 2 phút, `VM2ScrapeFailure` chuyển sang trạng thái `FIRING`.

Thông tin cảnh báo:
- Alert name: `VM2ScrapeFailure`.
- Instance: `100.96.202.53:9100`.
- Job: `vm2-webserver`.
- Severity: `warning`.

Telegram nhận được thông báo cảnh báo thông qua Alertmanager.

### 6.4. Khôi phục Node Exporter

Sau khi hoàn thành kiểm thử, phối hợp với Nhóm 2 khởi động lại dịch vụ:

```bash
sudo systemctl start prometheus-node-exporter.service
```

Prometheus tiếp tục scrape VM2 thành công và ghi nhận:

```text
up = 1
```

### 6.5. Xác nhận cảnh báo RESOLVED

Sau khi điều kiện lỗi không còn, cảnh báo `VM2ScrapeFailure` chuyển sang trạng thái `RESOLVED`.

Telegram tiếp tục nhận được thông báo phục hồi.

Kết quả xác nhận cả hai trạng thái cảnh báo và phục hồi đều hoạt động.

## 7. Kết quả thực hiện

| Nội dung | Kết quả |
|---|---|
| Tạo Alert Rule VM2ScrapeFailure | Thành công |
| Kiểm tra cú pháp bằng promtool | Thành công |
| Khai báo rule_files trong Prometheus | Thành công |
| Prometheus nhận diện Alert Rule | Thành công |
| Phát hiện VM2 scrape failure (`up = 0`) | Thành công |
| Chuyển cảnh báo sang FIRING sau 2 phút | Thành công |
| Gửi cảnh báo đến Telegram | Thành công |
| Phục hồi trạng thái VM2 (`up = 1`) | Thành công |
| Chuyển cảnh báo sang RESOLVED | Thành công |
| Gửi thông báo phục hồi đến Telegram | Thành công |

### 7.1. Đối chiếu kết quả kiểm thử

| Tình huống | Kết quả mong đợi | Kết quả thực tế |
|---|---|---|
| VM2 hoạt động bình thường | `up = 1` | `up = 1` |
| Node Exporter bị dừng | `up = 0` | `up = 0` |
| Điều kiện lỗi duy trì 2 phút | Alert chuyển `FIRING` | Đã chuyển `FIRING` |
| Gửi cảnh báo | Telegram nhận thông báo | Đã nhận thông báo |
| Node Exporter hoạt động trở lại | `up = 1` | `up = 1` |
| Phục hồi cảnh báo | Alert chuyển `RESOLVED` | Đã chuyển `RESOLVED` |
| Gửi thông báo phục hồi | Telegram nhận thông báo | Đã nhận thông báo |

### 7.2. Lỗi gặp phải và cách xử lý

Trong quá trình kiểm thử SCRUM-38, dịch vụ Node Exporter trên VM2 được tạm dừng có kiểm soát với sự phối hợp của Nhóm 2. Sau khi hoàn tất kiểm thử, dịch vụ được khởi động lại và Prometheus xác nhận trạng thái scrape đã phục hồi.

Không ghi nhận lỗi triển khai Alert Rule cần xử lý thêm.

## 8. Minh chứng

Thư mục minh chứng:

`monitoring/evidence/26-11-2026/SCRUM-38/`

| STT | Tên file | Nội dung |
|---|---|---|
| 01 | `01-prometheus-configuration-validation.png` | Kiểm tra Alert Rule và cấu hình Prometheus |
| 02 | `02-vm2-target-up.png` | Trạng thái VM2 hoạt động bình thường |
| 03 | `03-vm2-target-down.png` | Trạng thái VM2 mất kết nối Node Exporter |
| 04 | `04-vm2-alert-firing.png` | Alert chuyển sang FIRING |
| 05 | `05-telegram-alert-received.png` | Telegram nhận cảnh báo |
| 06 | `06-vm2-target-recovered.png` | VM2 phục hồi và Prometheus scrape thành công |
| 07 | `07-telegram-resolved-notification.png` | Telegram nhận thông báo RESOLVED |

## 9. Liên kết công việc

- Jira: SCRUM-38 – [N3-3C] task-3: Tạo Alert Rule phát hiện VM2 scrape failure (`up == 0`).
- Repository: `MayaThao/hkdn-monitoring`.
- Branch: `config/n3-SCRUM-38-vm2-scrape-failure-alert`.

## 10. Kết luận

Đã triển khai và kiểm thử thành công Alert Rule `VM2ScrapeFailure` trên Prometheus.

Hệ thống phát hiện được tình trạng Prometheus không thể scrape Node Exporter trên VM2 khi metric `up` bằng 0 trong thời gian liên tục 2 phút. Cảnh báo được chuyển đến Telegram thông qua Alertmanager.

Sau khi Node Exporter được khôi phục, Prometheus ghi nhận trạng thái `up = 1`, cảnh báo chuyển sang `RESOLVED` và Telegram nhận được thông báo phục hồi.

Kết quả đáp ứng mục tiêu kiểm thử phát hiện sự cố scrape failure và xác nhận quá trình phục hồi của VM2.