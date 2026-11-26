&#x20;SCRUM-15 – TRIỂN KHAI VM2 WEB SERVER



&#x20;1. Mục tiêu



Tạo và cấu hình máy ảo VM2 sử dụng Ubuntu Server, triển khai dịch vụ SSH và Nginx Web Server, đảm bảo kết nối với VM1 theo yêu cầu dự án.



&#x20;2. Nội dung thực hiện



\- Tạo máy ảo VM2 trên VirtualBox và cài đặt Ubuntu Server.

\- Cấu hình địa chỉ IP tĩnh cho VM2.

\- Cài đặt và kiểm tra dịch vụ SSH.

\- Cài đặt và cấu hình Nginx Web Server.

\- Kiểm tra kết nối giữa VM1 và VM2.

\- Cài đặt và đăng nhập Tailscale hỗ trợ kết nối máy chủ.



3\. Kết quả thực hiện



\- Đã cài đặt Ubuntu Server trên VM2.

\- Đã cấu hình địa chỉ IP tĩnh.

\- Đã kiểm tra kết nối giữa VM1 và VM2.

\- Đã cài đặt và kích hoạt dịch vụ SSH.

\- Đã cài đặt và kích hoạt Nginx.

\- Đã cài đặt và đăng nhập Tailscale.

&#x20;4. Minh chứng



Hình ảnh minh chứng được lưu tại thư mục `monitoring/evidence/`.



Các ảnh dự kiến bao gồm:



\- `vm2-summary.png`: Cấu hình máy ảo VirtualBox.

\- `vm2-ubuntu-login.png`: Đăng nhập Ubuntu Server.

\- `vm2-network-config.png`: Cấu hình mạng.

\- `vm2-ip-check.png`: Kiểm tra địa chỉ IP.

\- `vm1-vm2-ping.png`: Kiểm tra kết nối VM1 và VM2.

\- `vm2-ssh-status.png`: Kiểm tra dịch vụ SSH.

\- `vm2-nginx-status.png`: Kiểm tra trạng thái Nginx.

\- `vm2-tailscale.png`: Trạng thái Tailscale.

&#x20;5. Công việc tiếp theo



\- Kiểm tra truy cập giao diện Web Server từ máy tính cá nhân.

\- Phối hợp với VM1 để hoàn thiện hệ thống giám sát.

\- Triển khai Node Exporter trong giai đoạn tiếp theo.

&#x20;6. Kết luận



Đã thực hiện các công việc triển khai cơ bản cho VM2 – Web Server theo nhiệm vụ SCRUM-15. Báo cáo và hình ảnh minh chứng được lưu trữ trên GitHub để phục vụ kiểm tra và đánh giá.

