# HƯỚNG DẪN DỰNG VÀ TRIỂN KHAI VM2 – WEB SERVER

## 1. Giới thiệu

Tài liệu hướng dẫn quá trình tạo, cấu hình và triển khai máy ảo VM2 – Web Server sử dụng Ubuntu Server trên VirtualBox.

VM2 đảm nhiệm vai trò máy chủ Web, cung cấp dịch vụ Nginx và Node Exporter để VM1 – Monitoring Server có thể truy cập, thu thập dữ liệu và giám sát tài nguyên hệ thống.

### 1.1. Mục tiêu

- Tạo máy ảo VM2 sử dụng Ubuntu Server.
- Cấu hình mạng NAT và Host-only.
- Thiết lập địa chỉ IP tĩnh cho VM2.
- Cài đặt và cấu hình SSH.
- Cài đặt Nginx Web Server.
- Cài đặt Node Exporter.
- Thiết lập Tailscale để hỗ trợ kết nối từ xa.
- Kiểm tra khả năng truy cập các dịch vụ từ VM1.

### 1.2. Thông tin VM2

| Thành phần | Cấu hình |
|---|---|
| Tên máy | VM2 – Web Server |
| Hệ điều hành | Ubuntu Server |
| Nền tảng ảo hóa | VirtualBox |
| Card mạng 1 | NAT |
| Card mạng 2 | Host-only |
| Giao diện NAT | enp0s3 |
| IP NAT | 10.0.2.15/24 |
| Giao diện Host-only | enp0s8 |
| IP Host-only | 192.168.56.20/24 |
| Gateway NAT | 10.0.2.2 |
| DNS | 8.8.8.8 và 8.8.4.4 |

## 2. Chuẩn bị môi trường

### 2.1. Phần mềm cần thiết

- Oracle VirtualBox.
- File ISO Ubuntu Server.
- Máy tính có kết nối Internet.

### 2.2. Tạo máy ảo VM2

1. Mở VirtualBox.
2. Chọn New để tạo máy ảo mới.
3. Đặt tên máy là VM2-Webserver.
4. Chọn file ISO Ubuntu Server.
5. Thiết lập bộ nhớ RAM, CPU và dung lượng ổ cứng phù hợp với tài nguyên máy tính.
6. Tiến hành cài đặt Ubuntu Server.
7. Tạo tài khoản đăng nhập và mật khẩu.
8. Hoàn tất quá trình cài đặt và khởi động máy ảo.

Lưu ý: Tài liệu này không cố định dung lượng RAM, CPU và ổ cứng; cần ghi lại thông số thực tế đã sử dụng khi dựng máy.

## 3. Cấu hình mạng VM2

VM2 sử dụng hai card mạng để vừa kết nối Internet vừa giao tiếp với VM1.

### 3.1. Cấu hình VirtualBox

Mở Settings của máy ảo VM2.

**Adapter 1:**
- Enable Network Adapter.
- Attached to: NAT.

**Adapter 2:**
- Enable Network Adapter.
- Attached to: Host-only Adapter.
- Chọn Host-only Network tương ứng với VM1.

### 3.2. Kiểm tra card mạng

Sau khi khởi động Ubuntu, mở Terminal:

```bash
ip -br a
```

Kiểm tra hai giao diện mạng:
- enp0s3: NAT.
- enp0s8: Host-only.

### 3.3. Cấu hình IP tĩnh

Mở file cấu hình Netplan:

```bash
sudo nano /etc/netplan/00-installer-config.yaml
```

Cấu hình tham khảo theo địa chỉ mạng đã sử dụng:

```yaml
network:
  version: 2
  ethernets:
    enp0s3:
      dhcp4: false
      dhcp6: false
      addresses:
        - 10.0.2.15/24
      routes:
        - to: default
          via: 10.0.2.2
      nameservers:
        addresses:
          - 8.8.8.8
          - 8.8.4.4

    enp0s8:
      dhcp4: false
      dhcp6: false
      addresses:
        - 192.168.56.20/24
```

Lưu file bằng Ctrl + O, Enter và Ctrl + X.

Kiểm tra cấu hình:

```bash
sudo netplan generate
```

Áp dụng:

```bash
sudo netplan apply
```

Kiểm tra lại:

```bash
ip -br a
```

Kết quả mong muốn:

- enp0s3: 10.0.2.15/24.
- enp0s8: 192.168.56.20/24.

Kiểm tra kết nối Internet:

```bash
ping -c 4 8.8.8.8
```

## 4. Cài đặt và cấu hình SSH

SSH cho phép quản trị viên truy cập VM2 từ xa thông qua giao thức Secure Shell.

### 4.1. Cài đặt OpenSSH Server

```bash
sudo apt update
sudo apt install openssh-server -y
```

### 4.2. Khởi động SSH

```bash
sudo systemctl enable --now ssh
```

### 4.3. Kiểm tra trạng thái SSH

```bash
sudo systemctl status ssh
```

Kết quả mong muốn:

```text
Active: active (running)
```

### 4.4. Kiểm tra cổng SSH

```bash
sudo ss -tlnp | grep :22
```

SSH sử dụng cổng TCP 22.

### 4.5. Kiểm tra kết nối từ VM1

Từ VM1, thực hiện:

```bash
ssh <username>@192.168.56.20
```

Thay `<username>` bằng tài khoản Ubuntu thực tế trên VM2.

Nếu xuất hiện yêu cầu nhập mật khẩu và đăng nhập được vào VM2 thì kết nối SSH thành công.

## 5. Cài đặt Nginx Web Server

Nginx là dịch vụ Web Server có nhiệm vụ tiếp nhận và xử lý yêu cầu HTTP từ các máy khách.

### 5.1. Cài đặt Nginx

```bash
sudo apt update
sudo apt install nginx -y
```

### 5.2. Khởi động dịch vụ

```bash
sudo systemctl enable --now nginx
```

### 5.3. Kiểm tra trạng thái

```bash
sudo systemctl status nginx
```

Kết quả mong muốn:

```text
Active: active (running)
```

### 5.4. Kiểm tra Nginx trên VM2

```bash
curl -I http://localhost
```

Kết quả mong muốn:

```text
HTTP/1.1 200 OK
Server: nginx
```

### 5.5. Truy cập trang Web

Mở trình duyệt và nhập:

```text
http://192.168.56.20
```

Nếu xuất hiện trang Welcome to nginx! thì Nginx đã được triển khai thành công.

## 6. Cài đặt Node Exporter

Node Exporter là công cụ thu thập thông số tài nguyên hệ thống Linux như CPU, RAM, ổ đĩa và mạng.

Các dữ liệu này có thể được Prometheus trên VM1 thu thập để phục vụ việc giám sát.

### 6.1. Cài đặt Node Exporter

```bash
sudo apt update
sudo apt install prometheus-node-exporter -y
```

### 6.2. Khởi động dịch vụ

```bash
sudo systemctl enable --now prometheus-node-exporter
```

### 6.3. Kiểm tra trạng thái

```bash
sudo systemctl status prometheus-node-exporter
```

Kết quả mong muốn:

```text
Active: active (running)
```

### 6.4. Kiểm tra dữ liệu Metrics

```bash
curl http://localhost:9100/metrics
```

Nếu xuất hiện các thông số như:

```text
node_cpu_seconds_total
node_memory_MemTotal_bytes
node_filesystem_size_bytes
```

thì Node Exporter đang hoạt động.

### 6.5. Kiểm tra cổng dịch vụ

```bash
sudo ss -tulnp | grep -E ':80|:9100'
```

Hai cổng cần kiểm tra:

| Cổng | Dịch vụ |
|---|---|
| TCP 80 | Nginx |
| TCP 9100 | Node Exporter |

## 7. Cài đặt và kết nối Tailscale

Tailscale được sử dụng để hỗ trợ kết nối các máy trong mạng riêng, kể cả khi không cùng mạng LAN.

### 7.1. Kiểm tra dịch vụ

```bash
sudo systemctl status tailscaled
```

### 7.2. Kết nối tài khoản

```bash
sudo tailscale up
```

Mở đường dẫn đăng nhập được cung cấp và xác thực bằng tài khoản Tailscale của nhóm.

### 7.3. Kiểm tra trạng thái

```bash
sudo tailscale status
```

Kiểm tra địa chỉ IP Tailscale:

```bash
sudo tailscale ip -4
```

Nếu hiển thị trạng thái Connected và có địa chỉ IP 100.x.x.x thì máy đã kết nối Tailscale.

## 8. Kiểm tra kết nối VM1 – VM2

Sau khi hoàn tất các dịch vụ, cần kiểm tra khả năng truy cập từ VM1 – Monitoring Server đến VM2 – Web Server.

### 8.1. Kiểm tra kết nối mạng

Trên VM1:

```bash
ping -c 4 192.168.56.20
```

Nếu nhận được phản hồi từ địa chỉ 192.168.56.20 thì hai máy có thể giao tiếp qua Host-only.

### 8.2. Kiểm tra Nginx từ VM1

```bash
curl -I http://192.168.56.20
```

Kết quả mong muốn:

```text
HTTP/1.1 200 OK
```

### 8.3. Kiểm tra Node Exporter từ VM1

```bash
curl http://192.168.56.20:9100/metrics
```

Nếu trả về dữ liệu Metrics thì VM1 đã truy cập được Node Exporter trên VM2.

### 8.4. Kiểm tra SSH từ VM1

```bash
ssh <username>@192.168.56.20
```

Đăng nhập thành công chứng minh SSH trên VM2 có thể được truy cập từ VM1.

## 9. Kiểm tra tổng thể VM2

Chạy các lệnh:

```bash
sudo systemctl status ssh
sudo systemctl status nginx
sudo systemctl status prometheus-node-exporter
sudo systemctl status tailscaled
```

Kiểm tra địa chỉ IP:

```bash
ip -br a
```

Kiểm tra các cổng:

```bash
sudo ss -tulnp | grep -E ':22|:80|:9100'
```

Các dịch vụ cần hoạt động:

| Dịch vụ | Cổng | Trạng thái mong muốn |
|---|---:|---|
| SSH | 22 | Active |
| Nginx | 80 | Active |
| Node Exporter | 9100 | Active |
| Tailscale | Thay đổi theo cấu hình | Connected |

## 10. Kết quả đạt được

Sau quá trình triển khai, VM2 – Web Server đã được cài đặt và cấu hình các dịch vụ cần thiết.

Các kết quả chính:

- Hoàn thành tạo máy ảo Ubuntu Server trên VirtualBox.
- Cấu hình NAT và Host-only.
- Thiết lập địa chỉ IP tĩnh 10.0.2.15 và 192.168.56.20.
- Cài đặt và kiểm tra dịch vụ SSH.
- Cài đặt Nginx và kiểm tra trang Web bằng HTTP.
- Cài đặt Node Exporter và kiểm tra dữ liệu Metrics tại cổng 9100.
- Kết nối Tailscale.
- Kiểm tra khả năng truy cập dịch vụ VM2 từ VM1.

## 11. Danh sách hình ảnh minh chứng

Các ảnh minh chứng được lưu trong thư mục `monitoring/evidence/`.

1. Giao diện cấu hình máy ảo VM2 trên VirtualBox.
2. Kiểm tra hostname và tài khoản Ubuntu.
3. Kiểm tra địa chỉ IP bằng lệnh `ip -br a`.
4. Cấu hình Netplan.
5. Kiểm tra trạng thái SSH.
6. Kiểm tra kết nối VM1 – VM2.
7. Kiểm tra trạng thái Nginx.
8. Truy cập trang Welcome to nginx.
9. Kiểm tra trạng thái Node Exporter.
10. Kiểm tra dữ liệu Metrics.
11. Kiểm tra hai cổng 80 và 9100.
12. Kiểm tra kết nối Tailscale.
13. Kiểm tra VM1 truy cập Nginx và Node Exporter.

## 12. Kết luận

VM2 – Web Server đã được triển khai trên nền tảng Ubuntu Server bằng VirtualBox. Các dịch vụ SSH, Nginx và Node Exporter được cài đặt nhằm phục vụ quản trị, cung cấp dịch vụ Web và thu thập dữ liệu tài nguyên hệ thống.

Việc kết nối VM1 và VM2 qua mạng Host-only cùng với Tailscale giúp nhóm có thể kiểm tra và quản lý các máy chủ trong môi trường thực nghiệm. Đây là cơ sở để tiếp tục triển khai và hoàn thiện hệ thống giám sát máy chủ bằng Prometheus và Grafana.