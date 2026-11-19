# Báo cáo công việc – Nhiệm vụ 3C: Thử nghiệm Prometheus Alert Rule

- **Dự án:** Xây dựng hệ thống giám sát máy chủ, Cloud và trung tâm dữ liệu – HKDN UTH–VNPT NET
- **Nhóm:** Nhóm 3 – Monitoring & Alerting
- **Thành viên:** 3C – Lê Minh Đức
- **Jira Issue:** SCRUM-13 – [N3-3C] Tạo và thử nghiệm một Alert Rule
- **Thời gian thực hiện:** 18/11/2026 – 19/11/2026

---

## 1. Mục tiêu công việc

Thực hiện nhiệm vụ 3C trong tuần 3: tìm hiểu cơ chế hoạt động của Prometheus Alert Rule, tạo ít nhất một Alert Rule thử nghiệm, kiểm tra cú pháp và cấu hình, nạp rule vào Prometheus và xác nhận trạng thái cảnh báo trên giao diện.

Mục tiêu kiểm thử chính là xác nhận Alert Rule hoạt động và có thể chuyển sang trạng thái `FIRING` khi điều kiện cảnh báo được duy trì đủ thời gian cấu hình.

## 2. Môi trường thực hiện

### 2.1. Máy ảo cá nhân

| Thành phần | Thông tin |
|---|---|
| Phần mềm ảo hóa | Oracle VirtualBox |
| Tên máy ảo | HKDN-Ubuntu-Server |
| Hệ điều hành | Ubuntu Server 26.04.1 LTS |
| Hostname | hkdn-server |
| Username | duc |
| Kernel | 7.0.0-43-generic |
| Kiến trúc | x86-64 |
| Network Adapter | NAT |

Thông tin tài nguyên được kiểm tra:
- RAM khả dụng được hệ điều hành nhận diện khoảng 2.6 GiB.
- Phân vùng root có dung lượng khoảng 12 GB.
- Dung lượng còn trống tại thời điểm kiểm tra khoảng 5.4 GB.
- Chưa có swap tại thời điểm kiểm tra.

### 2.2. Máy chủ Prometheus sử dụng để thử nghiệm

Prometheus được truy cập thông qua kết nối Tailscale tới máy Ubuntu Server của thành viên Tuyền.

| Thành phần | Thông tin |
|---|---|
| Máy chủ | hkdn-server |
| Tài khoản Terminal | tuyen |
| Giao diện Prometheus | http://100.93.18.76:9090 |
| Prometheus executable | /usr/local/bin/prometheus |
| File cấu hình | /etc/prometheus/prometheus.yml |
| File Alert Rule | /etc/prometheus/test-alerts.yml |
| Cổng truy cập | 9090 |

**Lưu ý:** Việc thử nghiệm Alert Rule được thực hiện trên Prometheus của Tuyền sau khi đã trao đổi và nhận được sự đồng ý của thành viên này.

## 3. Công việc thực hiện ngày 18/11/2026

### 3.1. Cài đặt và thiết lập Ubuntu Server

- Tạo và khởi động máy ảo HKDN-Ubuntu-Server bằng Oracle VirtualBox.
- Hoàn tất thiết lập Ubuntu Server.
- Đăng nhập bằng tài khoản `duc`.
- Kiểm tra hostname của máy ảo là `hkdn-server`.
- Kiểm tra thông tin hệ điều hành và phần cứng ảo hóa.

### 3.2. Cấu hình kết nối mạng

- Thiết lập Network Adapter của VirtualBox ở chế độ NAT.
- Kiểm tra kết nối Internet từ Ubuntu Server bằng lệnh `ping`.
- Xác nhận máy ảo có thể kết nối mạng để phục vụ các bước cài đặt và cấu hình tiếp theo.

### 3.3. Kiểm tra thông tin và tài nguyên hệ thống

Sử dụng các lệnh:

```bash
hostnamectl
free -h
df -h
```

Kết quả ghi nhận:
- Hệ điều hành Ubuntu Server 26.04.1 LTS.
- Kernel Linux 7.0.0-43-generic.
- Kiến trúc x86-64.
- RAM khả dụng khoảng 2.6 GiB.
- Phân vùng root khoảng 12 GB, còn khoảng 5.4 GB trống tại thời điểm kiểm tra.

## 4. Công việc thực hiện ngày 19/11/2026

### 4.1. Kết nối và truy cập Prometheus

- Trao đổi với Tuyền (thành viên 3A) để kết nối thông qua Tailscale.
- Truy cập thành công giao diện Prometheus tại:

```text
http://100.93.18.76:9090
```

- Kiểm tra truy vấn `up` trên Prometheus Graph.
- Kiểm tra tại mục Status → Targets.

Kết quả ghi nhận:

| Thành phần | Kết quả |
|---|---|
| Job | prometheus |
| Instance | localhost:9090 |
| Endpoint | http://localhost:9090/metrics |
| Target | 1 / 1 UP |
| State | UP |

Kết quả này xác nhận Prometheus đang thu thập metrics thành công từ chính endpoint của nó.

Tại thời điểm kiểm tra ban đầu, mục Alerts hiển thị `No rules found`, cho thấy chưa có Alert Rule nào được cấu hình.

### 4.2. Kiểm tra cấu hình Prometheus

Sử dụng lệnh:

```bash
ps aux | grep prometheus
```

Xác định Prometheus đang chạy trực tiếp trên Ubuntu Server, không sử dụng Docker.

Thông tin cấu hình ghi nhận:

```text
/usr/local/bin/prometheus
--config.file=/etc/prometheus/prometheus.yml
--web.listen-address=0.0.0.0:9090
```

Đọc nội dung file cấu hình:

```bash
sudo cat /etc/prometheus/prometheus.yml
```

Phát hiện file đã có mục `rule_files`, tuy nhiên các dòng cấu hình mẫu đang bị comment.

Tiến hành bổ sung đường dẫn đến file Alert Rule thử nghiệm:

```yaml
rule_files:
  - "/etc/prometheus/test-alerts.yml"
  # - "first_rules.yml"
  # - "second_rules.yml"
```

Các phần cấu hình khác được giữ nguyên.

### 4.3. Tạo Alert Rule thử nghiệm

Tạo file:

```text
/etc/prometheus/test-alerts.yml
```

Nội dung:

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

Giải thích cấu hình:

| Thuộc tính | Giá trị | Ý nghĩa |
|---|---|---|
| groups | test-alerts | Tên nhóm Alert Rule |
| alert | AlwaysFiring | Tên cảnh báo |
| expr | vector(1) | Biểu thức luôn trả về giá trị 1 |
| for | 30s | Điều kiện phải duy trì đủ 30 giây |
| severity | warning | Nhãn mức độ cảnh báo |
| summary | Test Alert | Nội dung tóm tắt |
| description | This is a test alert from Prometheus. | Mô tả cảnh báo |

Rule `AlwaysFiring` được sử dụng để kiểm tra cơ chế hoạt động của Alert Rule, không phải cảnh báo giám sát tài nguyên thực tế.

### 4.4. Kiểm tra cú pháp Alert Rule

Sử dụng lệnh:

```bash
sudo promtool check rules /etc/prometheus/test-alerts.yml
```

Trong lần kiểm tra đầu tiên, file bị lỗi do sai cấu trúc YAML và thụt dòng.

Sau khi sửa lại nội dung file, lệnh kiểm tra được thực hiện thành công.

Kết quả:

```text
SUCCESS: 1 rules found
```

Điều này xác nhận file Alert Rule có cấu trúc hợp lệ và Prometheus có thể đọc được rule.

### 4.5. Kiểm tra cấu hình Prometheus

Sử dụng lệnh:

```bash
sudo promtool check config /etc/prometheus/prometheus.yml
```

Kết quả kiểm tra được xác nhận thành công (`SUCCESS`).

Điều này xác nhận file cấu hình Prometheus hợp lệ và đường dẫn đến file Alert Rule đã được khai báo.

### 4.6. Nạp và kiểm tra Alert Rule

Sau khi hai bước kiểm tra đều thành công, tiến hành khởi động lại Prometheus:

```bash
sudo systemctl restart prometheus
```

Kiểm tra trạng thái dịch vụ:

```bash
sudo systemctl status prometheus --no-pager
```

Sau đó truy cập lại giao diện Prometheus và mở mục Alerts.

Kết quả quan sát:
- Rule Group: `test-alerts`.
- Alert Name: `AlwaysFiring`.
- Expression: `vector(1)`.
- For: `30s`.
- Severity: `warning`.
- State: `FIRING`.
- Value: `1`.

Thời gian hoạt động được hiển thị trên ảnh chụp màn hình khoảng 3 phút 22 giây.

Kết quả này xác nhận:
- Prometheus đã nạp thành công Alert Rule.
- Biểu thức `vector(1)` được đánh giá thành công.
- Điều kiện cảnh báo luôn đúng.
- Alert đã chuyển sang trạng thái `FIRING` sau thời gian chờ được cấu hình.

**Lưu ý về bằng chứng:** Đã ghi nhận ảnh giao diện ở trạng thái `FIRING`. Chưa có ảnh chụp riêng ở trạng thái `PENDING`, vì vậy không ghi nhận đã lưu được bằng chứng hình ảnh cho trạng thái này.

## 5. Kết quả đạt được

| STT | Công việc | Kết quả |
|---|---|---|
| 1 | Thiết lập máy ảo Ubuntu Server | Hoàn thành |
| 2 | Cấu hình NAT và kiểm tra Internet | Hoàn thành |
| 3 | Kiểm tra thông tin hệ thống | Hoàn thành |
| 4 | Kết nối Tailscale tới Prometheus | Hoàn thành |
| 5 | Kiểm tra Prometheus Targets | 1 / 1 UP |
| 6 | Tạo file test-alerts.yml | Hoàn thành |
| 7 | Khai báo rule_files trong prometheus.yml | Hoàn thành |
| 8 | Kiểm tra bằng promtool check rules | SUCCESS |
| 9 | Kiểm tra bằng promtool check config | SUCCESS |
| 10 | Nạp Alert Rule vào Prometheus | Hoàn thành |
| 11 | Xác nhận AlwaysFiring chuyển sang FIRING | Thành công |

## 6. Bằng chứng thực hiện ngày 19/11/2026

Đã chụp và lưu cục bộ 4 ảnh bằng chứng trên máy tính:

| STT | Tên ảnh hiện tại | Nội dung |
|---|---|---|
| 1 | giao diện prometheus-alerts.png | Giao diện Prometheus Alerts, hiển thị AlwaysFiring ở trạng thái FIRING |
| 2 | giao diện prometheus-graph.png | Giao diện Prometheus Graph |
| 3 | giao diện prometheus-status.png | Giao diện Prometheus Status/Targets |
| 4 | termial alert.png | Ảnh Terminal liên quan đến cấu hình và kiểm tra Alert Rule |

Cấu trúc thư mục đề xuất khi đưa lên GitHub:

```text
monitoring/
└── evidence/
    └── 19-11-2026/
        ├── prometheus-alerts.png
        ├── prometheus-graph.png
        ├── prometheus-status.png
        └── terminal-alert-checks.png
```

Lưu ý: Các ảnh hiện mới được lưu trên máy tính cá nhân, chưa được xác nhận đã đưa vào GitHub Repository.

## 7. Công việc còn lại

1. Đưa file Alert Rule `test-alerts.yml` vào GitHub Repository.
2. Lưu báo cáo Markdown này trong thư mục `reports/`.
3. Đưa 4 ảnh bằng chứng vào thư mục `monitoring/evidence/19-11-2026/`.
4. Kiểm tra lại cấu trúc thư mục và các file trước khi commit.
5. Tạo branch theo quy định trong CONTRIBUTING.md.
6. Commit và push các thay đổi lên GitHub.
7. Tạo Pull Request để thành viên khác review trước khi merge.
8. Cập nhật Jira `SCRUM-13` bằng kết quả thực hiện và liên kết branch/commit/PR.
9. Chỉ chuyển Jira sang Done sau khi hoàn tất các yêu cầu bàn giao và review.

## 8. Kết luận

Trong khoảng thời gian từ ngày 18/11/2026 đến ngày 19/11/2026, đã hoàn thành việc thiết lập môi trường Ubuntu Server cá nhân, cấu hình kết nối mạng, kiểm tra tài nguyên hệ thống và kết nối tới Prometheus của nhóm thông qua Tailscale.

Đối với nhiệm vụ 3C, đã tạo thành công Alert Rule `AlwaysFiring`, khai báo `rule_files`, kiểm tra cú pháp và cấu hình bằng `promtool`, nạp rule vào Prometheus và xác nhận cảnh báo xuất hiện ở trạng thái `FIRING`.

Phần kiểm thử kỹ thuật chính đã đạt kết quả mong đợi. Các công việc bàn giao tài liệu, bằng chứng lên GitHub, tạo Pull Request và cập nhật Jira vẫn cần được thực hiện tiếp theo.