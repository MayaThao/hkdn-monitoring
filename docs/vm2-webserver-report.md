# SCRUM-15 – TRIỂN KHAI VM2 WEB SERVER

## 1. Mục tiêu

Tạo và cấu hình máy ảo VM2 sử dụng Ubuntu Server trên nền tảng VirtualBox, thiết lập môi trường mạng và đảm bảo khả năng kết nối giữa VM2 với VM1 – Monitoring Server.

Thực hiện cài đặt và kiểm tra dịch vụ SSH nhằm hỗ trợ quản trị máy chủ từ xa. Đồng thời, cài đặt và đăng nhập Tailscale để hỗ trợ kết nối giữa các thiết bị trong hệ thống.

Bên cạnh đó, xây dựng tài liệu hướng dẫn dựng máy và cấu hình VM2 để các thành viên trong nhóm có thể tham khảo và thực hiện lại khi cần thiết.

## 2. Thông tin cấu hình VM2

| Thành phần | Thông tin |
|---|---|
| Tên máy ảo | VM2-Webserver |
| Hệ điều hành | Ubuntu Server |
| Nền tảng ảo hóa | VirtualBox |
| Adapter 1 | NAT |
| Adapter 2 | Host-only |
| Giao diện mạng 1 | enp0s3 |
| Địa chỉ IP NAT | 10.0.2.15/24 |
| Giao diện mạng 2 | enp0s8 |
| Địa chỉ IP Host-only | 192.168.56.20/24 |
| Gateway NAT | 10.0.2.2 |
| DNS | 8.8.8.8 và 8.8.4.4 |

VM2 sử dụng hai card mạng với mục đích:

- NAT: Cung cấp kết nối Internet cho máy ảo.
- Host-only: Tạo kết nối mạng nội bộ giữa VM1 và VM2.

## 3. Nội dung thực hiện

### 3.1. Tạo máy ảo VM2 trên VirtualBox

**Bước 1: Tạo máy ảo**

- Mở Oracle VirtualBox.
- Chọn New để tạo máy ảo mới.
- Đặt tên máy ảo là VM2-Webserver.
- Chọn file ISO Ubuntu Server.
- Thiết lập RAM, CPU và dung lượng ổ cứng phù hợp.
- Tiến hành cài đặt Ubuntu Server.

**Bước 2: Cài đặt Ubuntu Server**

- Thiết lập tên máy chủ.
- Tạo tài khoản người dùng và mật khẩu.
- Hoàn tất quá trình cài đặt hệ điều hành.
- Khởi động lại máy ảo và đăng nhập vào Ubuntu Server.

### 3.2. Cấu hình mạng cho VM2

VM2 được cấu hình hai card mạng NAT và Host-only để đảm bảo kết nối Internet và giao tiếp với VM1.

**Bước 1: Cấu hình trên VirtualBox**

Mở Settings → Network của VM2.

Adapter 1:
- Enable Network Adapter.
- Attached to: NAT.

Adapter 2:
- Enable Network Adapter.
- Attached to: Host-only Adapter.
- Chọn mạng Host-only tương ứng với VM1.

**Bước 2: Kiểm tra giao diện mạng**

Mở Terminal trên Ubuntu và nhập:

```bash
ip -br a
```

Kiểm tra hai giao diện mạng:
- enp0s3: NAT.
- enp0s8: Host-only.

**Bước 3: Cấu hình IP tĩnh bằng Netplan**

Mở file cấu hình:

```bash
sudo nano /etc/netplan/00-installer-config.yaml
```

Nội dung cấu hình:

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

Áp dụng cấu hình:

```bash
sudo netplan apply
```

Kiểm tra lại địa chỉ IP:

```bash
ip -br a
```

Kết quả mong muốn:

- enp0s3: 10.0.2.15/24.
- enp0s8: 192.168.56.20/24.

### 3.3. Kiểm tra kết nối giữa VM1 và VM2

Sau khi cấu hình địa chỉ IP, tiến hành kiểm tra khả năng giao tiếp giữa hai máy.

**Bước 1: Kiểm tra kết nối từ VM2 đến VM1**

Trên VM2, nhập:

```bash
ping -c 4 192.168.56.10
```

**Bước 2: Kiểm tra kết nối từ VM1 đến VM2**

Trên VM1, nhập:

```bash
ping -c 4 192.168.56.20
```

Nếu nhận được phản hồi từ địa chỉ IP của máy đích thì hai máy đã có thể giao tiếp qua mạng Host-only.

### 3.4. Cài đặt và cấu hình SSH

SSH (Secure Shell) là giao thức cho phép quản trị viên truy cập và điều khiển máy chủ từ xa thông qua kết nối mạng.

**Bước 1: Cập nhật hệ thống**

```bash
sudo apt update
```

**Bước 2: Cài đặt OpenSSH Server**

```bash
sudo apt install openssh-server -y
```

**Bước 3: Khởi động và kích hoạt SSH**

```bash
sudo systemctl enable --now ssh
```

**Bước 4: Kiểm tra trạng thái dịch vụ**

```bash
sudo systemctl status ssh
```

Nếu xuất hiện:

```text
Active: active (running)
```

thì dịch vụ SSH đang hoạt động.

**Bước 5: Kiểm tra cổng SSH**

```bash
sudo ss -tlnp | grep :22
```

SSH sử dụng cổng TCP 22.

**Bước 6: Kiểm tra kết nối SSH từ VM1**

Trên VM1, nhập:

```bash
ssh <username>@192.168.56.20
```

Thay `<username>` bằng tên tài khoản Ubuntu trên VM2.

Nếu đăng nhập thành công thì VM1 có thể truy cập VM2 thông qua SSH.

### 3.5. Cài đặt và đăng nhập Tailscale

Tailscale là giải pháp mạng riêng hỗ trợ kết nối các thiết bị thông qua mạng riêng ảo.

**Bước 1: Kiểm tra dịch vụ Tailscale**

```bash
sudo systemctl status tailscaled
```

**Bước 2: Đăng nhập Tailscale**

```bash
sudo tailscale up
```

Mở đường dẫn đăng nhập được cung cấp trên Terminal và xác thực bằng tài khoản Tailscale của nhóm.

**Bước 3: Kiểm tra trạng thái kết nối**

```bash
sudo tailscale status
```

**Bước 4: Kiểm tra địa chỉ IP Tailscale**

```bash
sudo tailscale ip -4
```

Nếu thiết bị hiển thị trạng thái kết nối và có địa chỉ IP Tailscale thì quá trình đăng nhập đã thành công.

## 4. Kết quả thực hiện

Sau quá trình triển khai, VM2 đã đạt được các kết quả sau:

- Đã tạo và cài đặt máy ảo Ubuntu Server trên VirtualBox.
- Đã cấu hình hai card mạng NAT và Host-only.
- Đã thiết lập địa chỉ IP tĩnh cho VM2.
- Đã kiểm tra kết nối mạng giữa VM1 và VM2.
- Đã cài đặt và kích hoạt dịch vụ SSH.
- Đã kiểm tra khả năng kết nối SSH giữa VM1 và VM2.
- Đã cài đặt và đăng nhập Tailscale để hỗ trợ kết nối máy chủ.

Các công việc triển khai Nginx Web Server và Node Exporter chưa thuộc phạm vi hoàn thành của giai đoạn này, được chuyển sang kế hoạch thực hiện ở tuần tiếp theo.

## 5. Minh chứng

Hình ảnh minh chứng được lưu trữ tại thư mục:

```text
monitoring/evidence/
```

Danh sách hình ảnh minh chứng cho tuần 3:

| Tên hình ảnh | Nội dung minh chứng |
|---|---|
| `vm2-summary.png` | Cấu hình máy ảo VM2 trên VirtualBox |
| `vm2-ubuntu-login.png` | Đăng nhập Ubuntu Server |
| `vm2-network-config.png` | Cấu hình mạng cho VM2 |
| `vm2-ip-check.png` | Kiểm tra địa chỉ IP |
| `vm1-vm2-ping.png` | Kiểm tra kết nối VM1 và VM2 |
| `vm2-ssh-status.png` | Kiểm tra trạng thái dịch vụ SSH |
| `vm2-tailscale.png` | Trạng thái kết nối Tailscale |

Các hình ảnh liên quan đến Nginx và Node Exporter sẽ được bổ sung vào phần minh chứng của giai đoạn triển khai tiếp theo khi các dịch vụ được cài đặt và kiểm tra thực tế.

## 6. Công việc tiếp theo

Trong tuần 4, tiếp tục thực hiện các công việc:

- Cài đặt và cấu hình Nginx Web Server trên VM2.
- Kiểm tra trạng thái hoạt động của Nginx.
- Kiểm tra khả năng truy cập Web Server từ VM1 và máy tính cá nhân.
- Cài đặt và cấu hình Node Exporter trên VM2.
- Kiểm tra cổng 9100 và khả năng truy cập các chỉ số giám sát.
- Phối hợp với VM1 để cấu hình Prometheus thu thập dữ liệu từ Node Exporter trên VM2.

## 7. Kết luận

Đã thực hiện các công việc triển khai cơ bản cho VM2 – Web Server theo nhiệm vụ SCRUM-15 trong tuần 3.

Máy ảo Ubuntu Server đã được cài đặt và cấu hình mạng với địa chỉ IP tĩnh. Kết nối giữa VM1 và VM2 đã được kiểm tra, dịch vụ SSH được triển khai nhằm hỗ trợ quản trị từ xa và Tailscale được cài đặt để hỗ trợ kết nối máy chủ.

Các công việc triển khai Nginx Web Server và Node Exporter được đưa vào kế hoạch tuần 4 nhằm tiếp tục hoàn thiện VM2 và tích hợp với hệ thống giám sát Prometheus trên VM1.

