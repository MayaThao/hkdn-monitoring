# SCRUM-30 – Cấu hình Prometheus giám sát VM2 Webserver

## 1. Mục tiêu

Cấu hình Prometheus trên Monitoring Server để thu thập dữ liệu giám sát (metrics) từ VM2 Webserver thông qua Node Exporter.

Sau khi cấu hình, tiến hành kiểm tra kết nối, xác thực cấu hình Prometheus, kiểm tra trạng thái Target và truy vấn dữ liệu nhằm xác nhận VM2 đã được tích hợp thành công vào hệ thống Monitoring.

## 2. Môi trường triển khai

| Thành phần | Thông tin |
|---|---|
| Monitoring Server | Ubuntu – `hkdn-server` |
| Công cụ giám sát | Prometheus |
| Máy được giám sát | VM2 Webserver |
| Exporter | Node Exporter |
| Kết nối mạng | Tailscale |
| IP Tailscale của VM2 | `100.96.202.53` |
| Cổng Node Exporter | `9100` |
| Endpoint Metrics | `http://100.96.202.53:9100/metrics` |
| Job Name | `vm2-webserver` |
| Scrape Interval | `15s` |

## 3. Kiểm tra Node Exporter và kết nối VM2

Node Exporter đã được cài đặt và hoạt động trên VM2 Webserver.

Tiến hành kiểm tra khả năng truy cập endpoint metrics từ Monitoring Server bằng lệnh:

```bash
curl -sS -o /tmp/vm2_metrics.txt -w "HTTP Status: %{http_code}\n" http://100.96.202.53:9100/metrics
```

**Kết quả:** Endpoint Node Exporter trả về HTTP Status `200`, xác nhận Monitoring Server có thể truy cập và lấy dữ liệu metrics từ VM2.

## 4. Cấu hình Prometheus

### 4.1. Sao lưu cấu hình

Trước khi chỉnh sửa cấu hình Prometheus, tiến hành sao lưu file cấu hình hiện tại:

```bash
sudo cp /etc/prometheus/prometheus.yml /etc/prometheus/prometheus.yml.bak-week4
```

File sao lưu được tạo thành công tại:

```text
/etc/prometheus/prometheus.yml.bak-week4
```

### 4.2. Thêm cấu hình scrape VM2

Thêm job `vm2-webserver` vào file cấu hình:

```text
/etc/prometheus/prometheus.yml
```

Nội dung cấu hình:

```yaml
  - job_name: "vm2-webserver"
    static_configs:
      - targets: ["100.96.202.53:9100"]
```

Cấu hình sử dụng địa chỉ Tailscale của VM2 và cổng Node Exporter `9100` làm target thu thập metrics.

Scrape Interval của Prometheus được cấu hình ở mức `15s`.

## 5. Kiểm tra cấu hình Prometheus

Sau khi cập nhật cấu hình, tiến hành kiểm tra cú pháp và tính hợp lệ bằng `promtool`:

```bash
sudo promtool check config /etc/prometheus/prometheus.yml
```

**Kết quả:** Prometheus configuration hợp lệ, kiểm tra thành công. Các rule hiện có cũng được nhận diện trong quá trình kiểm tra.

## 6. Khởi động lại Prometheus

Sau khi xác nhận cấu hình hợp lệ, khởi động lại Prometheus để áp dụng cấu hình mới:

```bash
sudo systemctl restart prometheus
```

Kiểm tra trạng thái service:

```bash
sudo systemctl status prometheus
```

**Kết quả:** Prometheus hoạt động ở trạng thái `active (running)`.

## 7. Kiểm tra Target trên Prometheus

Truy cập giao diện Prometheus Targets để kiểm tra trạng thái scrape của các target.

Target mới được cấu hình:

| Thuộc tính | Giá trị |
|---|---|
| Job | `vm2-webserver` |
| Endpoint | `100.96.202.53:9100` |
| Scrape Interval | `15s` |
| Scrape Timeout | `10s` |
| Health | `UP` |

**Kết quả kiểm tra:** Target `vm2-webserver` hiển thị trạng thái `UP`, số target hoạt động là `1/1 up`. Prometheus đã thu thập metrics từ VM2 Webserver thành công.

## 8. Kiểm tra dữ liệu bằng PromQL

Tiến hành truy vấn trạng thái hoạt động của target VM2:

```promql
up{job="vm2-webserver"}
```

Có thể kiểm tra kết quả thông qua Prometheus API bằng lệnh:

```bash
curl -s 'http://localhost:9090/api/v1/query?query=up%7Bjob%3D%22vm2-webserver%22%7D'
```

**Kết quả:** API trả về trạng thái truy vấn thành công, target `100.96.202.53:9100` thuộc job `vm2-webserver` có giá trị `1`.

Ý nghĩa:

- `1`: Target đang hoạt động và Prometheus scrape thành công.
- `0`: Target không hoạt động hoặc scrape thất bại.

Kết quả `1` xác nhận VM2 Webserver đang được Prometheus giám sát bình thường.

## 9. Kết quả thực hiện

Các công việc thuộc SCRUM-30 đã hoàn thành:

- [x] Cấu hình Prometheus scrape VM2 Webserver.
- [x] Sử dụng Tailscale IP để kết nối đến VM2.
- [x] Cấu hình Node Exporter target tại cổng `9100`.
- [x] Sao lưu file cấu hình Prometheus trước khi chỉnh sửa.
- [x] Kiểm tra cấu hình bằng `promtool`.
- [x] Khởi động lại Prometheus và xác nhận service hoạt động.
- [x] Kiểm tra target `vm2-webserver` trên Prometheus UI.
- [x] Xác nhận target có trạng thái `UP`.
- [x] Kiểm tra dữ liệu bằng PromQL.
- [x] Xác nhận kết quả `up = 1`.
- [x] Ghi nhận cấu hình và kết quả tích hợp.

## 10. Kết luận

VM2 Webserver đã được tích hợp thành công vào hệ thống Prometheus Monitoring.

Prometheus có thể truy cập Node Exporter thông qua Tailscale, thu thập metrics từ VM2 và hiển thị target `vm2-webserver` ở trạng thái `UP`.

Kết quả kiểm tra trên Prometheus UI và truy vấn PromQL đều xác nhận VM2 hoạt động bình thường trong hệ thống giám sát.

SCRUM-30 đã hoàn thành về mặt kỹ thuật.