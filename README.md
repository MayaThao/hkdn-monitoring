# Xây dựng hệ thống giám sát máy chủ, Cloud và trung tâm dữ liệu

**Chương trình:** Học kỳ doanh nghiệp UTH – VNPT NET  
**Đề tài:** N4.7  
**Mã nhóm chương trình:** [Điền mã nhóm chính thức]  
**Thời gian thực hiện:** 01/11/2026 – 06/03/2027

## 1. Giới thiệu

Dự án hướng đến việc nghiên cứu, phân tích, thiết kế và xây dựng prototype hệ thống giám sát máy chủ, Cloud và trung tâm dữ liệu.

Hệ thống dự kiến sử dụng các công cụ mã nguồn mở để thu thập, lưu trữ, trực quan hóa dữ liệu giám sát và phát hiện, cảnh báo các sự cố trong hạ tầng.

Trong giai đoạn đầu, nhóm định hướng xây dựng môi trường thử nghiệm trên các máy ảo Ubuntu Server, sử dụng Prometheus, Grafana, Alertmanager và các Exporter để giám sát tài nguyên máy chủ cũng như trạng thái của một số dịch vụ tiêu biểu như Web và Database.

Phạm vi mô phỏng Cloud và trung tâm dữ liệu sẽ được xác định trong quá trình phân tích, thiết kế dựa trên yêu cầu của đề tài và ý kiến định hướng từ Mentor.

## 2. Mục tiêu dự án

- Khảo sát bài toán và xác định yêu cầu chức năng, phi chức năng của hệ thống.
- Phân tích, thiết kế kiến trúc tổng thể và các thành phần của hệ thống giám sát.
- Xây dựng môi trường thử nghiệm trên máy ảo với các dịch vụ mô phỏng thực tế.
- Thu thập và trực quan hóa các chỉ số tài nguyên máy chủ, trạng thái dịch vụ.
- Xây dựng cơ chế phát hiện sự cố và gửi cảnh báo.
- Kiểm thử, đánh giá prototype và ghi nhận các hạn chế.
- Hoàn thiện báo cáo kỹ thuật, tài liệu triển khai và bàn giao sản phẩm.

## 3. Công nghệ dự kiến

| Thành phần          | Công nghệ                               | Mục đích                                 |
| ------------------- | --------------------------------------- | ---------------------------------------- |
| Hệ điều hành        | Ubuntu Server                           | Môi trường máy chủ thử nghiệm            |
| Ảo hóa              | VirtualBox                              | Tạo và quản lý máy ảo                    |
| Monitoring          | Prometheus                              | Thu thập và lưu trữ metrics              |
| Visualization       | Grafana                                 | Trực quan hóa dữ liệu giám sát           |
| Alert Management    | Alertmanager                            | Quản lý, nhóm và định tuyến cảnh báo     |
| Notification        | Telegram                                | Kênh gửi thông báo cảnh báo              |
| Host Monitoring     | Node Exporter                           | Thu thập chỉ số tài nguyên máy chủ Linux |
| Service Monitoring  | Blackbox Exporter                       | Kiểm tra trạng thái HTTP/HTTPS, TCP      |
| Database Monitoring | MySQL Exporter hoặc PostgreSQL Exporter | Thu thập chỉ số hoạt động của Database   |

Các công nghệ bổ trợ như Docker, cAdvisor, Vagrant hoặc Ansible có thể được xem xét tùy theo phạm vi triển khai và tiến độ thực hiện. Việc sử dụng các công nghệ này sẽ được quyết định sau khi nhóm hoàn thiện phân tích và thiết kế.

## 4. Cơ cấu nhóm

Dự án gồm 8 thành viên, được chia thành 4 nhóm chuyên môn:

| Nhóm   | Số lượng | Nhiệm vụ chính                                    |
| ------ | -------: | ------------------------------------------------- |
| Nhóm 1 |        1 | Phân tích yêu cầu, thiết kế hệ thống và điều phối |
| Nhóm 2 |        2 | Xây dựng hạ tầng và môi trường thử nghiệm         |
| Nhóm 3 |        3 | Phát triển hệ thống Monitoring và Alerting        |
| Nhóm 4 |        2 | Kiểm thử và đánh giá hệ thống                     |

_Lưu ý: Nhóm 1, 2, 3, 4 là cách phân chia nhóm chuyên môn trong nội bộ dự án, không phải mã nhóm chính thức của chương trình._

## 5. Cấu trúc Repository

```text
N4.7/
├── README.md
├── CONTRIBUTING.md
│
├── docs/
│   ├── requirements/       # Tài liệu phân tích yêu cầu
│   ├── design/             # Tài liệu thiết kế hệ thống
│   ├── meeting-minutes/    # Biên bản họp
│   ├── cross-evaluation/   # Đánh giá chéo
│   ├── contributions/      # Tổng hợp đóng góp
│   └── presentations/     # Slide thuyết trình
│
├── infra/                  # Cấu hình và tài liệu hạ tầng
├── monitoring/             # Cấu hình Prometheus, Grafana, Alertmanager
├── tests/                  # Kịch bản và kết quả kiểm thử
└── reports/                # Báo cáo định kỳ và báo cáo kỹ thuật
```

_Cấu trúc thư mục sẽ được bổ sung dần theo tiến độ và nhu cầu thực tế của dự án._

## 6. Quản lý và phối hợp dự án

| Công cụ       | Mục đích sử dụng                                                |
| ------------- | --------------------------------------------------------------- |
| GitHub        | Quản lý mã nguồn, tài liệu, cấu hình và lịch sử thay đổi        |
| Jira          | Quản lý nhiệm vụ, phân công công việc và theo dõi tiến độ dự án |
| Google Sheets | Theo dõi tiến độ học tập và tổng hợp đóng góp                   |
| Zoom          | Họp nhóm và trao đổi trực tuyến                                 |

Các thành viên cần cập nhật tiến độ công việc trên Jira và tuân thủ quy trình đóng góp được mô tả trong [CONTRIBUTING.md](CONTRIBUTING.md).

---

**Đơn vị thực hiện:** UTH – VNPT NET
