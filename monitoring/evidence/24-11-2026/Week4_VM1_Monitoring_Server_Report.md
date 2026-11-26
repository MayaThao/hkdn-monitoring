BÁO CÁO CÔNG VIỆC TUẦN 4
VM1 – MÁY CHỦ GIÁM SÁT (MONITORING SERVER)
1. Thông tin chung
•	Tên dự án: N4.7 – Xây dựng hệ thống giám sát máy chủ, Cloud và trung tâm dữ liệu.
•	Nhóm: Nhóm 2 – Xây dựng hạ tầng và môi trường thử nghiệm.
•	Thành viên thực hiện: Chung Tiểu Phi.
•	Máy chủ phụ trách: VM1 – Monitoring Server.
•	Thời gian thực hiện: Tuần 4 (22/11/2026 – 28/11/2026).
2. Mục tiêu công việc
Trong tuần 4, nhiệm vụ trọng tâm là kiểm tra khả năng kết nối và trao đổi dữ liệu giữa VM1 (máy chủ giám sát) và VM2 (máy chủ Web) thông qua mạng Tailscale.
Bên cạnh đó, tiến hành kiểm tra khả năng truy cập các dịch vụ đang hoạt động trên VM2, bao gồm Nginx và Node Exporter. Qua đó, đánh giá khả năng kết nối giữa hai máy chủ và đảm bảo VM1 có thể truy cập dữ liệu phục vụ cho hệ thống giám sát.
3. Thông tin cấu hình máy chủ
Thông tin	VM1	VM2
Tên máy	vm1-monitoring	vm2-webserver
Vai trò	Máy chủ giám sát	Máy chủ Web
Hệ điều hành	Ubuntu Server	Ubuntu Server
IP Tailscale	100.88.182.70	100.96.202.53
4. Nội dung công việc thực hiện
4.1. Kiểm tra trạng thái kết nối Tailscale
Sử dụng lệnh sau trên VM1:
tailscale status
Mục đích:
•	Kiểm tra trạng thái hoạt động của Tailscale trên VM1.
•	Xác định VM2 có xuất hiện trong danh sách thiết bị thuộc cùng mạng hay không.
•	Đánh giá khả năng kết nối giữa hai máy chủ thông qua mạng Tailscale.
4.2. Kiểm tra kết nối mạng giữa VM1 và VM2
Thực hiện lệnh:
ping -c 4 100.96.202.53
Mục đích:
•	Kiểm tra khả năng gửi và nhận gói tin từ VM1 đến VM2.
•	Đánh giá tình trạng kết nối mạng giữa hai máy chủ.
Kết quả: Đã tiến hành kiểm tra kết nối giữa VM1 và VM2.
4.3. Kiểm tra dịch vụ Nginx trên VM2
Thực hiện lệnh trên VM1:
curl http://100.96.202.53
Kết quả: VM1 nhận được nội dung trang mặc định Welcome to Nginx.
Kết quả kiểm tra cho thấy:
•	Dịch vụ Nginx trên VM2 đang hoạt động.
•	VM1 truy cập thành công máy chủ Web VM2 thông qua địa chỉ IP Tailscale.
•	Dịch vụ Web có thể được truy cập thông qua cổng 80.
4.4. Kiểm tra dịch vụ Node Exporter trên VM2
Thực hiện lệnh:
curl -s http://100.96.202.53:9100/metrics | head -n 20
Mục đích:
•	Kiểm tra khả năng truy cập Node Exporter từ VM1.
•	Kiểm tra dữ liệu chỉ số hệ thống được cung cấp từ VM2.
•	Đánh giá khả năng cung cấp dữ liệu phục vụ hoạt động giám sát.
Kết quả: Cập nhật sau khi kiểm tra thực tế.
4.5. Kiểm tra các cổng dịch vụ
Thực hiện hai lệnh:
nc -zv 100.96.202.53 80
nc -zv 100.96.202.53 9100
Mục đích:
•	Kiểm tra khả năng truy cập cổng 80 của dịch vụ Nginx.
•	Kiểm tra khả năng truy cập cổng 9100 của dịch vụ Node Exporter.
•	Xác định khả năng giao tiếp giữa VM1 và các dịch vụ trên VM2.
Kết quả: Cập nhật sau khi kiểm tra thực tế.
5. Hình ảnh minh chứng
Các hình ảnh minh chứng cho quá trình triển khai và kiểm tra bao gồm:
1.	Tailscale_Status.png – Kiểm tra trạng thái Tailscale.
2.	VM2_Connectivity.png – Kiểm tra kết nối mạng giữa VM1 và VM2.
3.	Nginx_Access.png – Kiểm tra truy cập Nginx trên VM2.
4.	VM1_Node_Exporter_Metrics.png – Kiểm tra dữ liệu Node Exporter.
5.	VM1_Service_Port_Check.png – Kiểm tra các cổng dịch vụ.
6. Kết quả đạt được
Trong tuần 4, đã tiến hành kiểm tra kết nối giữa VM1 và VM2 thông qua mạng Tailscale. Đặc biệt, VM1 đã truy cập thành công trang mặc định của Nginx trên VM2 thông qua cổng 80.
Các nội dung kiểm tra Node Exporter và trạng thái các cổng dịch vụ sẽ tiếp tục được hoàn thiện, ghi nhận kết quả và bổ sung hình ảnh minh chứng.
7. Kết luận
Qua quá trình triển khai và kiểm tra, khả năng kết nối giữa máy chủ giám sát VM1 và máy chủ Web VM2 đã được xác nhận thông qua việc truy cập thành công dịch vụ Nginx.
Kết quả này là cơ sở để tiếp tục kiểm tra khả năng thu thập dữ liệu hệ thống từ VM2, góp phần hoàn thiện quá trình xây dựng hệ thống giám sát tập trung bằng Prometheus và Grafana.

