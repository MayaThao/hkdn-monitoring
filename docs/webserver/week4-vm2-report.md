# TUẦN 4 – TRIỂN KHAI NGINX VÀ NODE EXPORTER TRÊN VM2

**Dự án:** Xây dựng hệ thống giám sát máy chủ, Cloud và trung tâm dữ liệu

**Chương trình:** Học kỳ doanh nghiệp UTH – VNPT NET

**Nhóm thực hiện:** Nhóm 2

**Thành viên thực hiện:** Mai Trần Thu Sương

**Máy ảo phụ trách:** VM2 – Web Server

**Jira:** SCRUM-40 – TRIỂN KHAI VM2 WEB SERVER

**Thời gian:** 22/11/2026 – 28/11/2026

## 1. Giới thiệu

Trong tuần 4, nhóm tiếp tục triển khai các thành phần phục vụ hệ thống giám sát máy chủ. Đối với nhiệm vụ VM2 – Web Server, công việc tập trung vào việc cài đặt và cấu hình Nginx Web Server, đồng thời triển khai Prometheus Node Exporter để cung cấp dữ liệu Metrics của máy chủ.

Nginx được sử dụng để cung cấp dịch vụ Web trên VM2. Node Exporter đảm nhiệm việc thu thập và cung cấp các thông tin về tài nguyên hệ thống như CPU, RAM, ổ đĩa, mạng và các thông số hoạt động khác.

Sau khi triển khai, tiến hành kiểm tra trạng thái dịch vụ, kiểm tra các cổng đang lắng nghe và xác nhận dữ liệu Metrics được cung cấp. Đồng thời, thực hiện kiểm tra khả năng truy cập các dịch vụ trên VM2 từ VM1 – Monitoring Server.

## 2. Mục tiêu

- Cài đặt và cấu hình Nginx Web Server trên máy ảo VM2.
- Khởi động Nginx và thiết lập dịch vụ tự động chạy khi hệ thống khởi động.
- Kiểm tra khả năng hoạt động của Web Server thông qua Terminal và trình duyệt.
- Cài đặt Prometheus Node Exporter trên Ubuntu Server VM2.
- Thiết lập Node Exporter tự động khởi động cùng hệ thống.
- Kiểm tra trạng thái hoạt động và cổng TCP 9100 của Node Exporter.
- Kiểm tra dữ liệu Metrics do Node Exporter cung cấp.
- Kiểm tra khả năng truy cập Nginx và Node Exporter từ VM1.

## 3. Môi trường triển khai

### 3.1. Cấu hình máy ảo VM2

| Thành phần | Thông tin |
|---|---|
| Tên máy ảo | VM2-Webserver |
| Hệ điều hành | Ubuntu Server 26.04.1 LTS |
| Nền tảng ảo hóa | Oracle VirtualBox |
| Web Server | Nginx |
| Monitoring Agent | Prometheus Node Exporter |
| Giao thức quản trị | SSH |
| IP Host-only | 192.168.56.20 |
| IP NAT | 10.0.2.15 |
| Cổng Nginx | TCP 80 |
| Cổng Node Exporter | TCP 9100 |

### 3.2. Vai trò các thành phần

**Nginx Web Server**

Nginx là phần mềm Web Server mã nguồn mở, được sử dụng để tiếp nhận các yêu cầu HTTP từ trình duyệt hoặc máy khách và trả về nội dung trang Web.

Trong hệ thống, Nginx được cài đặt trên VM2 và sử dụng cổng TCP 80 để cung cấp dịch vụ Web.

**Prometheus Node Exporter**
Node Exporter là thành phần hỗ trợ thu thập các thông số tài nguyên và trạng thái hoạt động của máy chủ Linux.

Node Exporter cung cấp dữ liệu Metrics thông qua giao thức HTTP tại cổng TCP 9100. VM1 có thể sử dụng địa chỉ này để truy cập dữ liệu phục vụ quá trình giám sát bằng Prometheus.

## 4. Triển khai Nginx Web Server trên VM2

### 4.1. Kiểm tra địa chỉ IP của VM2

Trước khi triển khai dịch vụ, tiến hành kiểm tra các giao diện mạng và địa chỉ IP của máy ảo VM2.

Mở Terminal trên Ubuntu Server và thực hiện lệnh:

```bash
ip -br a
```

Lệnh này hiển thị danh sách các giao diện mạng cùng trạng thái và địa chỉ IP tương ứng.

Kết quả cần kiểm tra:

- Giao diện `enp0s3` sử dụng địa chỉ IP NAT `10.0.2.15/24`.
- Giao diện `enp0s8` sử dụng địa chỉ IP Host-only `192.168.56.20/24`.
- Giao diện mạng cần ở trạng thái hoạt động.

Địa chỉ IP Host-only `192.168.56.20` được sử dụng để VM1 và máy tính cá nhân truy cập các dịch vụ trên VM2 trong mạng Host-only.

### 4.2. Cập nhật danh sách gói phần mềm

Trước khi cài đặt Nginx, tiến hành cập nhật danh sách các gói phần mềm từ kho lưu trữ Ubuntu.

Thực hiện lệnh:

```bash
sudo apt update
```

Lệnh `apt update` giúp hệ thống cập nhật thông tin các gói phần mềm và phiên bản hiện có từ các kho lưu trữ.

### 4.3. Cài đặt Nginx

Tiến hành cài đặt Nginx bằng lệnh:

```bash
sudo apt install nginx -y
```

Trong đó:

- `sudo`: Thực hiện lệnh với quyền quản trị.
- `apt install`: Cài đặt phần mềm.
- `nginx`: Tên gói Web Server cần cài đặt.
- `-y`: Tự động xác nhận quá trình cài đặt.

Sau khi hoàn tất, Nginx được cài đặt trên hệ điều hành Ubuntu Server.

### 4.4. Khởi động và thiết lập Nginx tự động chạy

Thực hiện lệnh:

```bash
sudo systemctl enable --now nginx
```

Ý nghĩa:

- `systemctl`: Công cụ quản lý các dịch vụ trên Linux.
- `enable`: Thiết lập dịch vụ tự động khởi động cùng hệ thống.
- `--now`: Đồng thời khởi động dịch vụ ngay lập tức.
- `nginx`: Tên dịch vụ cần quản lý.

### 4.5. Kiểm tra trạng thái hoạt động của Nginx

Sử dụng lệnh:

```bash
sudo systemctl status nginx
```

Kết quả kiểm tra cần hiển thị:

```text
Active: active (running)
```

Ý nghĩa:

- `active`: Dịch vụ đang hoạt động.
- `running`: Tiến trình Nginx đang chạy.
- `enabled`: Dịch vụ đã được thiết lập tự động khởi động cùng hệ thống.

Kết quả thực tế trên VM2 cho thấy dịch vụ `nginx.service` đang ở trạng thái `active (running)` và đã được thiết lập `enabled`.

### 4.6. Kiểm tra hoạt động của Nginx bằng Terminal
Sau khi khởi động Nginx, tiến hành kiểm tra khả năng phản hồi của Web Server bằng lệnh:

```bash
curl http://localhost
```

Lệnh `curl` gửi yêu cầu HTTP đến địa chỉ localhost, tức là máy chủ VM2 hiện tại.

Nếu Nginx hoạt động bình thường, hệ thống sẽ trả về nội dung HTML của trang Web mặc định.

Kết quả thực tế hiển thị nội dung:

```html
<h1>Welcome to nginx!</h1>
```

Điều này xác nhận Nginx đã được cài đặt và có khả năng phản hồi yêu cầu HTTP trên chính VM2.

### 4.7. Kiểm tra Nginx bằng trình duyệt Web

Mở trình duyệt Google Chrome trên máy tính cá nhân.

Nhập địa chỉ:

```text
http://192.168.56.20
```

Nếu trình duyệt hiển thị trang:

**Welcome to nginx!**

thì Web Server đã hoạt động và có thể được truy cập thông qua địa chỉ IP Host-only của VM2.

Kết quả này xác nhận dịch vụ Nginx đã được triển khai thành công.

## 5. Cài đặt và cấu hình Prometheus Node Exporter trên VM2

### 5.1. Giới thiệu Node Exporter

Prometheus Node Exporter là công cụ hỗ trợ thu thập các thông số hoạt động của hệ điều hành Linux.

Node Exporter cung cấp các Metrics liên quan đến:

- CPU: Thông tin về hoạt động và mức sử dụng bộ xử lý.
- RAM: Thông tin về bộ nhớ hệ thống.
- Disk: Dung lượng và tình trạng sử dụng ổ đĩa.
- Network: Thông tin lưu lượng và hoạt động mạng.
- System: Các thông số hoạt động chung của hệ điều hành.

Các dữ liệu này được cung cấp thông qua HTTP endpoint tại cổng mặc định TCP 9100.

### 5.2. Cài đặt Node Exporter

Trên Terminal của VM2, thực hiện cập nhật danh sách gói:

```bash
sudo apt update
```

Sau đó cài đặt Node Exporter bằng lệnh:

```bash
sudo apt install prometheus-node-exporter -y
```

Hệ thống sẽ tải xuống và cài đặt gói `prometheus-node-exporter` cùng các thành phần phụ thuộc cần thiết.

Sau khi hoàn tất, dịch vụ Node Exporter được đăng ký với systemd để quản lý quá trình hoạt động.

### 5.3. Khởi động và thiết lập Node Exporter tự động chạy

Thực hiện lệnh:

```bash
sudo systemctl enable --now prometheus-node-exporter
```

Lệnh này thực hiện hai thao tác:

- Khởi động Node Exporter ngay lập tức.
- Thiết lập Node Exporter tự động khởi động khi Ubuntu Server khởi động lại.

### 5.4. Kiểm tra trạng thái Node Exporter

Sử dụng lệnh:

```bash
sudo systemctl status prometheus-node-exporter
```

Kết quả mong đợi:

```text
Active: active (running)
```

Trong kết quả thực tế, dịch vụ `prometheus-node-exporter.service` hiển thị:

- Trạng thái: `active (running)`.
- Khởi động tự động: `enabled`. 
- Tiến trình chính: `/usr/bin/prometheus-node-exporter`.

Điều này xác nhận Node Exporter đã được cài đặt và hoạt động thành công trên VM2.

### 5.5. Kiểm tra cổng hoạt động của Node Exporter

Để kiểm tra Node Exporter có đang lắng nghe trên cổng 9100 hay không, thực hiện lệnh:

```bash
sudo ss -tulnp | grep 9100
```

Trong đó:

- `ss`: Công cụ kiểm tra các kết nối mạng và socket.
- `-t`: Hiển thị kết nối TCP.
- `-u`: Hiển thị kết nối UDP.
- `-l`: Chỉ hiển thị các cổng đang lắng nghe.
- `-n`: Hiển thị địa chỉ và cổng dưới dạng số.
- `-p`: Hiển thị tiến trình sử dụng cổng.
- `grep 9100`: Lọc kết quả liên quan đến cổng 9100.

Kết quả thực tế ghi nhận:

```text
tcp LISTEN ... *:9100
```

Tiến trình `prometheus-node` đang lắng nghe trên cổng TCP 9100.

Điều này xác nhận Node Exporter đã mở cổng dịch vụ để tiếp nhận các yêu cầu truy cập dữ liệu Metrics.

### 5.6. Kiểm tra dữ liệu Metrics

Sau khi xác nhận cổng 9100 hoạt động, tiến hành kiểm tra dữ liệu do Node Exporter cung cấp.

Thực hiện lệnh:

```bash
curl http://localhost:9100/metrics
```

Địa chỉ `localhost:9100/metrics` là endpoint cung cấp dữ liệu Metrics của Node Exporter.

Khi truy cập thành công, hệ thống trả về nhiều dòng dữ liệu dạng văn bản, bao gồm các thông tin về CPU, RAM, ổ đĩa, mạng và các thành phần khác của hệ điều hành.

Để hiển thị một số dòng đầu tiên thay vì toàn bộ dữ liệu, có thể sử dụng:

```bash
curl http://localhost:9100/metrics | head
```

Kết quả trả về các dòng Metrics xác nhận Node Exporter đang cung cấp dữ liệu của hệ thống.

## 6. Kiểm tra các dịch vụ trên VM2

Sau khi hoàn thành cài đặt, tiến hành kiểm tra tổng thể các dịch vụ đang hoạt động trên VM2.

### 6.1. Kiểm tra địa chỉ IP

```bash
ip -br a
```

Xác nhận địa chỉ IP Host-only của VM2 là:

```text
192.168.56.20
```

### 6.2. Kiểm tra trạng thái Nginx

```bash
sudo systemctl status nginx
```

Kết quả cần có:

```text
Active: active (running)
```

### 6.3. Kiểm tra trạng thái Node Exporter

```bash
sudo systemctl status prometheus-node-exporter
```

Kết quả cần có:

```text
Active: active (running)
```

### 6.4. Kiểm tra hai cổng dịch vụ

```bash
sudo ss -tulnp | grep -E ':80|:9100'
```

Lệnh này lọc các cổng liên quan đến Nginx và Node Exporter.

Các cổng cần kiểm tra:

| Dịch vụ | Cổng | Chức năng |
|---|---|---|
| Nginx | 80 | Cung cấp dịch vụ Web HTTP |
| Node Exporter | 9100 | Cung cấp dữ liệu Metrics |

## 7. Kiểm tra kết nối từ VM1 đến VM2

### 7.1. Mục đích
Sau khi triển khai Nginx và Node Exporter trên VM2, cần kiểm tra khả năng kết nối từ VM1 – Monitoring Server đến VM2 – Web Server.

Việc kiểm tra nhằm xác nhận VM1 có thể truy cập các dịch vụ được cung cấp trên VM2 thông qua địa chỉ IP và cổng tương ứng.

### 7.2. Kiểm tra kết nối mạng giữa VM1 và VM2

Trên Terminal của VM1, thực hiện lệnh:

```bash
ping -c 4 192.168.56.20
```

Lệnh này gửi 4 gói tin ICMP đến địa chỉ IP Host-only của VM2.

Nếu nhận được phản hồi từ VM2, kết nối mạng giữa hai máy ảo đang hoạt động.

### 7.3. Kiểm tra khả năng truy cập Nginx từ VM1

Trên VM1, thực hiện:

```bash
curl -I http://192.168.56.20
```

Lệnh trên gửi yêu cầu HTTP đến Nginx đang chạy trên VM2 thông qua cổng 80.

Nếu nhận được phản hồi:

```text
HTTP/1.1 200 OK
```

thì VM1 đã truy cập thành công Web Server trên VM2.

### 7.4. Kiểm tra khả năng truy cập Node Exporter từ VM1

Trên VM1, thực hiện:

```bash
curl http://192.168.56.20:9100/metrics | head
```

Lệnh này gửi yêu cầu đến endpoint Metrics của Node Exporter trên VM2 thông qua cổng 9100.

Nếu nhận được các dòng dữ liệu Metrics, VM1 đã có thể truy cập Node Exporter trên VM2.

**Lưu ý:** Các bước 7.2, 7.3 và 7.4 là nội dung kiểm tra cần có minh chứng kết quả thực tế từ VM1 trước khi xác nhận hoàn thành.

## 8. Kết quả thực hiện

Sau quá trình triển khai trên VM2, ghi nhận các kết quả sau:

- Đã kiểm tra và xác nhận địa chỉ IP của VM2.
- Đã cài đặt Nginx Web Server trên Ubuntu Server.
- Đã thiết lập Nginx tự động khởi động cùng hệ thống.
- Dịch vụ Nginx hoạt động với trạng thái `active (running)`.
- Đã kiểm tra phản hồi của Nginx bằng lệnh curl.
- Truy cập thành công trang Welcome to nginx thông qua trình duyệt tại địa chỉ `192.168.56.20`.
- Đã cài đặt Prometheus Node Exporter trên VM2.
- Đã thiết lập Node Exporter tự động khởi động cùng hệ thống.
- Dịch vụ Node Exporter hoạt động với trạng thái `active (running)`.
- Đã xác nhận Node Exporter lắng nghe trên cổng TCP 9100.
- Đã kiểm tra endpoint `/metrics` và nhận được dữ liệu Metrics của hệ thống.

Phần kiểm tra truy cập từ VM1 cần được đối chiếu với kết quả thực tế và bổ sung hình ảnh minh chứng tương ứng.

## 9. Danh mục hình ảnh minh chứng

Các hình ảnh được lưu tại thư mục:

```text
monitoring/evidence/vm2-week-04/
```

| STT | Tên hình ảnh | Nội dung |
|---|---|---|
| 01 | 01-vm2-check-ip-address.png | Kiểm tra địa chỉ IP VM2 |
| 02 | 02-vm2-nginx-service-status.png | Kiểm tra trạng thái Nginx |
| 03 | 03-vm2-nginx-web.png | Truy cập trang Welcome to nginx |
| 04 | 04-vm2-node-exporter-service-status.png| Quá trình cài đặt Node Exporter |
| 05 | 05-vm2-node-exporter-port-9100.png| Kiểm tra trạng thái Node Exporter |
| 06 | 06-vm2-node-exporter-metrics.png | Kiểm tra dữ liệu Metrics |

Các ảnh trên là tên file đề xuất. Cần kiểm tra nội dung thực tế của từng ảnh trước khi đưa vào repository. Nếu chưa có ảnh kiểm tra kết nối từ VM1, cần chụp bổ sung.

## 10. Kết luận

Trong tuần 4, nhiệm vụ triển khai VM2 – Web Server đã tập trung vào việc cài đặt và cấu hình Nginx Web Server cùng Prometheus Node Exporter trên Ubuntu Server.

Nginx đã được khởi động thành công, hoạt động ở trạng thái `active (running)` và cung cấp trang Web mặc định Welcome to nginx. Node Exporter cũng đã được cài đặt, thiết lập tự động khởi động, lắng nghe trên cổng TCP 9100 và cung cấp dữ liệu Metrics của hệ thống.

Các kết quả trên là cơ sở để VM1 – Monitoring Server thực hiện truy cập và thu thập dữ liệu từ VM2 trong hệ thống giám sát máy chủ.

Trong các giai đoạn tiếp theo, tiếp tục phối hợp với thành viên phụ trách VM1 để kiểm tra quá trình thu thập Metrics và hoàn thiện hệ thống giám sát tổng thể.