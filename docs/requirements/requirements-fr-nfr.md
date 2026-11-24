# Đặc tả Yêu cầu chức năng (FR) và Yêu cầu phi chức năng (NFR)

**Dự án:** N4.7 – Xây dựng hệ thống giám sát máy chủ, Cloud và trung tâm dữ liệu  
**Nhóm phụ trách:** Nhóm 1 – Phân tích & Thiết kế  
**Mã Jira:** SCRUM-23  
**Người thực hiện:** Ngô Thảo My  
**Ngày tạo:** 24/11/2026  
**Ngày cập nhật:** 24/11/2026  
**Người review:** Chờ review  
**Trạng thái:** Draft

---

## 1. Mục đích

Tài liệu đặc tả các yêu cầu chức năng (FR-xx) và phi chức năng (NFR-xx) của hệ thống Monitoring N4.7, được suy ra từ:

| Tài liệu nguồn               | Nội dung kế thừa                                                                |
| ---------------------------- | ------------------------------------------------------------------------------- |
| `problem-survey.md`          | Đối tượng OBJ01–OBJ06, vấn đề PRB01–PRB10, mức ưu tiên                          |
| `metrics-inventory.md`       | Metrics MET-xx, nguồn dữ liệu, giới hạn diễn giải                               |
| `alert-scenarios.md`         | Tình huống cảnh báo AS-01–AS-10, tham số `Y_*`, `F_*`, `X_*`, `W_*`, inhibition |
| `acceptance_criteria_0.2.md` | Tiêu chí nghiệm thu AC01–AC22                                                   |

Tài liệu này là đầu vào cho: thiết kế kiến trúc (Tuần 5), Baseline BL-xx và đặc tả cảnh báo (Tuần 6), Test Plan của Nhóm 4 và ma trận truy vết (Tuần 10).

## 2. Quy ước

### 2.1. Thuật ngữ bắt buộc

| Thuật ngữ                  | Nghĩa dùng trong tài liệu này                                                                                                |
| -------------------------- | ---------------------------------------------------------------------------------------------------------------------------- |
| **Server**                 | Máy chủ Linux (Ubuntu Server trên VM) với các tài nguyên CPU, RAM, Disk, Network                                             |
| **Cloud Simulation**       | VM đóng vai trò đại diện cho Cloud Instance; mô phỏng ở mức logic, không phải nền tảng Cloud thực tế                         |
| **Data Center Simulation** | Mô phỏng máy chủ, kết nối mạng, Web Server và Database bằng các VM; không có phần cứng Data Center thực tế                   |
| **Monitoring**             | Hệ thống thu thập Metrics, Dashboard, phát hiện bất thường và gửi cảnh báo (Prometheus, Grafana, Alertmanager, các exporter) |

Quy tắc:

- **Không** dùng cụm từ "Cloud Monitoring" hay "Data Center Monitoring". Khi nói về hoạt động giám sát các nhóm mô phỏng, viết "Monitoring cho Cloud Simulation" / "Monitoring cho Data Center Simulation".
- Các từ "Cloud" hoặc "Data Center" đứng riêng chỉ xuất hiện kèm chữ "thực tế" để mô tả nội dung **ngoài phạm vi** (mục 3.3), hoặc trong tên đề tài chính thức.
- Giá trị nhãn `environment` dùng đúng ba thuật ngữ: `Server`, `Cloud Simulation`, `Data Center Simulation`.

### 2.2. Mã định danh

| Tiền tố              | Ý nghĩa                                                   | Nguồn                                                                                           |
| -------------------- | --------------------------------------------------------- | ----------------------------------------------------------------------------------------------- |
| FR-xx                | Yêu cầu chức năng                                         | Tài liệu này                                                                                    |
| NFR-xx               | Yêu cầu phi chức năng                                     | Tài liệu này                                                                                    |
| GĐ-xx                | Giả định đang áp dụng khi PM/Mentor chưa xác nhận phạm vi | Tài liệu này                                                                                    |
| BL-xx                | Tham số Baseline (ngưỡng, thời gian) – chốt Tuần 6        | Tài liệu này đề xuất; chốt ở tài liệu Baseline                                                  |
| OBJxx, PRBxx, MET-xx | Đối tượng, vấn đề, Metric                                 | `problem-survey.md`, `metrics-inventory.md`                                                     |
| AS-xx                | Tình huống cảnh báo                                       | `alert-scenarios.md`                                                                            |
| ACxx                 | Tiêu chí nghiệm thu                                       | `acceptance_criteria_0.2.md` (giữ nguyên dạng `ACxx` như tài liệu nguồn – xem mục 9, điểm P-10) |

### 2.3. Mức ưu tiên (MoSCoW, kế thừa `alert-scenarios.md` mục 9.1)

- **Must:** bắt buộc trong Prototype.
- **Should:** nên có nếu đủ thời gian và điều kiện kỹ thuật.
- **Could:** mở rộng, chỉ làm khi còn nguồn lực.

### 2.4. Cột "Phạm vi"

| Mã    | Ý nghĩa                                                                                                                |
| ----- | ---------------------------------------------------------------------------------------------------------------------- |
| **P** | Prototype – triển khai và kiểm thử thật trên 3 VM                                                                      |
| **M** | Mô phỏng mức logic trên chính 3 VM của Prototype (nhãn `environment`, kịch bản sự cố có kiểm soát); không thêm hạ tầng |
| **K** | Chỉ dừng ở mức khảo sát – không triển khai, không nghiệm thu                                                           |

## 3. Phạm vi hệ thống

### 3.1. Phạm vi Prototype – 3 VM

| VM                   | Vai trò           | Thành phần                                                                     | Đối tượng giám sát                     | Ghi chú                                                     |
| -------------------- | ----------------- | ------------------------------------------------------------------------------ | -------------------------------------- | ----------------------------------------------------------- |
| VM1 – **Monitoring** | Monitoring Server | Prometheus, Grafana, Alertmanager, Blackbox Exporter; Node Exporter (tùy chọn) | OBJ04 (và OBJ01 nếu cài Node Exporter) | Không thể tự phát hiện khi chính VM1 ngừng hoạt động (P-03) |
| VM2 – **Web**        | Web Server        | Nginx, Node Exporter                                                           | OBJ01, OBJ02                           |                                                             |
| VM3 – **Database**   | Database Server   | MySQL hoặc PostgreSQL (chưa chốt), Node Exporter, Database Exporter            | OBJ01, OBJ03                           | Tên Metric DB chờ chốt DB (GĐ-04)                           |

Kênh nhận cảnh báo: Telegram .

### 3.2. Phân lớp đối tượng giám sát và nhãn `environment`

Áp dụng **GĐ-03** (mục 4): nhãn `environment` gắn theo **góc nhìn của target**, không gắn 1:1 theo VM, để cả ba nhóm đều có dữ liệu trên đúng 3 VM hiện có (nguyên tắc tiết kiệm tài nguyên).

| Lớp                     | Giá trị `environment`                                                | Target / nguồn dữ liệu                                          | Đối tượng           | Tình huống cảnh báo        | Phạm vi |
| ----------------------- | -------------------------------------------------------------------- | --------------------------------------------------------------- | ------------------- | -------------------------- | ------- |
| L1 – Tài nguyên Server  | `Server`                                                             | Node Exporter trên VM2, VM3 (và VM1 nếu có)                     | OBJ01               | AS-01, AS-02, AS-03        | P       |
| L2 – Instance ảo hóa    | `Cloud Simulation`                                                   | ICMP/TCP probe khả năng kết nối từng VM (VM như Cloud Instance) | OBJ01, OBJ05        | AS-04                      | P + M   |
| L3 – Dịch vụ & kết nối  | `Data Center Simulation`                                             | HTTP probe Nginx, TCP probe cổng DB, Database Exporter          | OBJ02, OBJ03, OBJ06 | AS-05, AS-06, AS-07, AS-08 | P + M   |
| L4 – Monitoring tự thân | Không thuộc ba giá trị trên; phân biệt bằng nhãn `role="monitoring"` | `up` của mọi target, Metrics Prometheus/Alertmanager            | OBJ04               | AS-09, AS-10               | P       |

Ghi chú:

- OBJ05 và OBJ06 **không** là đối tượng giám sát độc lập được triển khai (đúng như `problem-survey.md` mục 4.5–4.6). Chúng chỉ được thể hiện qua nhãn `Cloud Simulation` / `Data Center Simulation` trên các target có thật của OBJ01–OBJ03.
- Nhãn `host` (định danh VM, ví dụ `vm-web`, `vm-db`) phải có trên mọi target để phục vụ inhibition (`alert-scenarios.md` mục 8.2), độc lập với `environment`.

### 3.3. Nội dung chỉ dừng ở mức khảo sát (Phạm vi K)

Các nội dung dưới đây **không** có FR/NFR triển khai, **không** có AC nghiệm thu, và phải được nêu trong tài liệu giới hạn Prototype (AC16):

| Hạng mục                                                                                 | Liên quan    | Lý do                                                                      |
| ---------------------------------------------------------------------------------------- | ------------ | -------------------------------------------------------------------------- |
| Tích hợp API quản lý của nền tảng Cloud thực tế (tự cấp phát, autoscaling, multi-tenant) | OBJ05        | Không có nền tảng Cloud thực tế; chờ Mentor xác nhận (Survey mục 9, câu 1) |
| Dịch vụ thương mại, đa nhà cung cấp trên nền tảng Cloud thực tế                          | OBJ05        | Ngoài phạm vi đã xác nhận                                                  |
| Phần cứng máy chủ vật lý (nhiệt độ, IPMI/BMC, RAID)                                      | OBJ06        | Không có thiết bị                                                          |
| UPS, nguồn điện, làm mát, cảm biến môi trường, rack                                      | OBJ06        | Không có thiết bị                                                          |
| Thiết bị mạng chuyên dụng (Switch/Router qua SNMP)                                       | OBJ06        | Không có thiết bị; chưa có nguồn tham khảo chuyên biệt                     |
| Nhiều site / nhiều cụm độc lập bằng hạ tầng riêng                                        | OBJ05, OBJ06 | Chờ Mentor (Survey mục 9, câu 3); chỉ cho phép mức nhãn trên 3 VM          |
| Kubernetes, container quy mô lớn                                                         | OBJ05        | Survey mục 8.2                                                             |
| Tự động khắc phục sự cố, giám sát bảo mật chuyên sâu                                     | –            | Survey mục 8.2                                                             |

## 4. Giả định đang áp dụng (do chưa có xác nhận từ PM/Mentor)

| Mã    | Giả định                                                                                                             | Căn cứ / lý do                                 | Ảnh hưởng nếu sai                                                                                            | Cần xác nhận với     | Hạn                                               |
| ----- | -------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------- | ------------------------------------------------------------------------------------------------------------ | -------------------- | ------------------------------------------------- |
| GĐ-01 | Không bắt buộc Monitoring trên nền tảng Cloud thực tế; Cloud Simulation bằng VM là đủ                                | Survey mục 3.2, mục 9 câu 1; tài liệu 01 mục 2 | Phải bổ sung FR cho API của nền tảng Cloud thực tế, đổi kiến trúc                                            | Mentor / PM          | Hỏi trong Tuần 4, chốt Tuần 6                     |
| GĐ-02 | Data Center Simulation chỉ gồm máy chủ, kết nối mạng, Web Server, Database trên 3 VM; không mô phỏng điện/làm mát    | Tài liệu 01 mục 2; Survey mục 9 câu 2          | Phải thêm nguồn dữ liệu giả lập (exporter mock)                                                              | Mentor / PM          | Tuần 6                                            |
| GĐ-03 | Nhãn `environment` gắn theo góc nhìn target (mục 3.2), không tạo thêm VM                                             | Tài liệu 01 mục 3, nguyên tắc 1–2; chỉ có 3 VM | Nếu PM muốn 1 VM = 1 environment: mỗi nhóm chỉ có 1 VM, VM1 phải được tính là `Server`; cần sửa FR-09, FR-13 | PM                   | Tuần 5 (trước thiết kế kiến trúc)                 |
| GĐ-04 | Database chưa chốt; FR về Metric DB viết theo nhóm dữ liệu, không theo tên Metric                                    | Survey mục 9 câu 4; Metrics mục 6              | Trì hoãn FR-05, AS-08, AC21                                                                                  | Nhóm 2 / Nhóm 3      | Trước khi dựng VM3 (Tuần 5)                       |
| GĐ-05 | Kênh thông báo là Telegram, 1 receiver chính                                                                         | Alert Scenarios mục 10                         | Đổi receiver và template FR-22                                                                               | PM / Mentor / Nhóm 3 | 28/11/2026                                        |
| GĐ-06 | Số VM tối thiểu khi nghiệm thu N = 3 (cả 3 VM của Prototype)                                                         | Survey mục 3.1; AC01 chưa có giá trị N         | AC01, AC17 thay đổi                                                                                          | Mentor               | Tuần 6                                            |
| GĐ-07 | SQL Availability Check là Could, không thuộc phạm vi tối thiểu của AS-07                                             | Alert Scenarios mục 6.1; AC mục 7              | Nếu bắt buộc: FR-06 lên Must, thêm script/exporter                                                           | Team Leader / Mentor | Tuần 6                                            |
| GĐ-08 | Mạng VirtualBox dùng chế độ cho phép VM1 truy cập VM2/VM3 trực tiếp (Host-only hoặc NAT Network), ICMP không bị chặn | Alert Scenarios mục 10 (ICMP chưa xác minh)    | AS-04 phải chuyển sang TCP probe (ví dụ cổng SSH)                                                            | Nhóm 2               | Tuần 5 – kiểm chứng tại `docs/design/validation/` |

## 5. Yêu cầu chức năng (FR)

### 5.1. Nhóm A – Thu thập dữ liệu

| Mã    | Yêu cầu                                                                                                                                                                                         | Đối tượng    | Vấn đề                | Tình huống                                     | AC         | Ưu tiên | Phạm vi |
| ----- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------ | --------------------- | ---------------------------------------------- | ---------- | ------- | ------- |
| FR-01 | Hệ thống thu thập định kỳ Metrics tài nguyên Server (CPU, RAM, Swap, Filesystem, Network, Boot time) từ Node Exporter trên VM Web và VM Database, chu kỳ theo BL-01.                            | OBJ01        | PRB01, PRB02, PRB03   | AS-01, AS-02, AS-03                            | AC01, AC02 | Must    | P       |
| FR-02 | Hệ thống kiểm tra khả năng kết nối của từng VM được giám sát từ VM Monitoring bằng ICMP probe (hoặc TCP probe thay thế theo GĐ-08), **độc lập với Node Exporter**.                              | OBJ01, OBJ05 | PRB04                 | AS-04                                          | AC03       | Must    | P + M   |
| FR-03 | Hệ thống kiểm tra Web Service trên VM Web qua HTTP probe, ghi nhận kết quả thành công/thất bại, mã HTTP và thời gian phản hồi theo phase. Module và mã HTTP chấp nhận được cấu hình tường minh. | OBJ02, OBJ06 | PRB05, PRB06          | AS-05, AS-06                                   | AC07, AC20 | Must    | P + M   |
| FR-04 | Hệ thống kiểm tra kết nối TCP đến cổng dịch vụ Database trên VM Database.                                                                                                                       | OBJ03, OBJ06 | PRB07                 | AS-07                                          | AC08       | Must    | P + M   |
| FR-05 | Hệ thống thu thập Metrics chuyên biệt của Database qua Database Exporter, tối thiểu: số kết nối hiện tại và giới hạn kết nối tối đa. Exporter dùng tài khoản DB quyền tối thiểu.                | OBJ03        | PRB07 (hỗ trợ), PRB08 | AS-07 (hỗ trợ), AS-08                          | AC21       | Should  | P       |
| FR-06 | Hệ thống có thể thực hiện truy vấn kiểm tra đơn giản (ví dụ `SELECT 1`) để xác nhận Database xử lý được truy vấn.                                                                               | OBJ03        | PRB07                 | AS-07                                          | –          | Could   | P       |
| FR-07 | Hệ thống theo dõi trạng thái scrape của mọi target đã cấu hình (`up`, `scrape_duration_seconds`, `scrape_samples_scraped`).                                                                     | OBJ04        | PRB09                 | AS-09                                          | AC01, AC19 | Must    | P       |
| FR-08 | Prometheus scrape Metrics của chính Alertmanager (tổng notification và notification thất bại).                                                                                                  | OBJ04        | PRB10                 | AS-10                                          | AC22       | Should  | P       |
| FR-09 | Mọi target phải mang nhãn `environment` (theo mục 3.2) và nhãn `host` thống nhất; target của thành phần Monitoring mang nhãn `role="monitoring"`.                                               | OBJ01–OBJ06  | Hỗ trợ PRB04, PRB09   | Hỗ trợ AS-04, AS-05, AS-07, AS-09 (inhibition) | AC11, AC17 | Must    | M       |
| FR-10 | Hệ thống lưu trữ dữ liệu chuỗi thời gian trong khoảng thời gian tối thiểu theo NFR-06 và cho phép truy vấn dữ liệu hiện tại và lịch sử.                                                         | OBJ04        | Hỗ trợ PRB01–PRB10    | Tất cả                                         | AC02, AC14 | Must    | P       |

### 5.2. Nhóm B – Hiển thị và theo dõi

| Mã    | Yêu cầu                                                                                                                                                                                      | Đối tượng                 | Vấn đề       | Tình huống   | AC                                  | Ưu tiên                                                  | Phạm vi |
| ----- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------- | ------------ | ------------ | ----------------------------------- | -------------------------------------------------------- | ------- |
| FR-11 | Grafana cung cấp Dashboard tài nguyên Server: CPU Usage (%), RAM Usage (%) / MemAvailable, Disk Usage (%) và dung lượng còn lại, Network throughput, Uptime, trạng thái kết nối cho từng VM. | OBJ01                     | PRB01–PRB04  | AS-01–AS-04  | AC02                                | Must                                                     | P       |
| FR-12 | Grafana cung cấp Dashboard dịch vụ: trạng thái HTTP probe và thời gian phản hồi của Web; trạng thái TCP probe và số kết nối của Database.                                                    | OBJ02, OBJ03              | PRB05–PRB08  | AS-05–AS-08  | AC02 (mở rộng – đề xuất)            | Must (trạng thái) / Should (thời gian phản hồi, kết nối) | P       |
| FR-13 | Dashboard cho phép lọc và nhóm theo `environment` (`Server`, `Cloud Simulation`, `Data Center Simulation`) và theo `host`.                                                                   | OBJ01–OBJ03, OBJ05, OBJ06 | –            | –            | Chưa có AC (đề xuất bổ sung – P-09) | Must                                                     | M       |
| FR-14 | Dashboard Monitoring hiển thị trạng thái các target, các Alert đang Pending/Firing (`ALERTS`) và số notification thất bại.                                                                   | OBJ04                     | PRB09, PRB10 | AS-09, AS-10 | AC19, AC22                          | Should                                                   | P       |
| FR-15 | Dashboard và datasource được cung cấp dưới dạng provisioning (file JSON/YAML trong Git), không phụ thuộc thao tác tay trên giao diện.                                                        | OBJ04                     | –            | –            | AC12, AC13, AC17                    | Must                                                     | P       |

### 5.3. Nhóm C – Phát hiện và cảnh báo

| Mã    | Yêu cầu                                                                                                                                                                                                                                                          | Đối tượng    | Vấn đề                     | Tình huống                 | AC                     | Ưu tiên                       | Phạm vi |
| ----- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------ | -------------------------- | -------------------------- | ---------------------- | ----------------------------- | ------- |
| FR-16 | Hệ thống có Alert Rules cho tài nguyên Server: CPU Usage vượt `Y_CPU` trong `F_CPU`; RAM vượt `Y_RAM` (hoặc MemAvailable dưới ngưỡng – một phương pháp duy nhất, xem P-07) trong `F_RAM`; Disk Usage vượt `Y_DISK` trên filesystem thuộc phạm vi trong `F_DISK`. | OBJ01        | PRB01, PRB02, PRB03        | AS-01, AS-02, AS-03        | AC04, AC05, AC06       | Must                          | P       |
| FR-17 | Hệ thống có Alert Rule Host Down dựa trên probe kết nối (FR-02) thất bại liên tục trong `F_HOST`; **không** dùng riêng `up = 0` làm điều kiện Host Down.                                                                                                         | OBJ01, OBJ05 | PRB04                      | AS-04                      | AC03                   | Must                          | P + M   |
| FR-18 | Hệ thống có Alert Rule Web Service Down (HTTP probe thất bại trong `F_WEB_DOWN`) và Web Response Time High (thời gian phản hồi vượt `Y_WEB_TIME` trong `F_WEB_TIME` khi probe vẫn thành công; `Y_WEB_TIME` < probe timeout).                                     | OBJ02        | PRB05, PRB06               | AS-05, AS-06               | AC07, AC20             | Must (AS-05) / Should (AS-06) | P       |
| FR-19 | Hệ thống có Alert Rule Database Unreachable (TCP probe thất bại trong `F_DB`) và Database Connections High (kết nối hoặc Connection Usage vượt `Y_DB_CONN` trong `F_DB_CONN`).                                                                                   | OBJ03        | PRB07, PRB08               | AS-07, AS-08               | AC08, AC21             | Must (AS-07) / Should (AS-08) | P       |
| FR-20 | Hệ thống có Alert Rule Scrape Target Failure (`up = 0` trong `F_SCRAPE`) và Notification Failure (tốc độ tăng của `alertmanager_notifications_failed_total` vượt điều kiện thống nhất).                                                                          | OBJ04        | PRB09, PRB10               | AS-09, AS-10               | AC19, AC22             | Must (AS-09) / Should (AS-10) | P       |
| FR-21 | Mỗi Alert mang nhãn `severity` (`critical` / `warning` theo `alert-scenarios.md` mục 9.2) cùng các nhãn `host`, `environment` kế thừa từ target.                                                                                                                 | OBJ01–OBJ04  | PRB01–PRB10                | AS-01–AS-10                | AC09                   | Must                          | P       |
| FR-22 | Alertmanager gửi notification đến Telegram; nội dung tối thiểu: hostname/instance, tên cảnh báo, severity, thời điểm phát sinh; nên kèm `environment` và đường dẫn Dashboard.                                                                                    | OBJ04        | PRB10                      | AS-01–AS-10                | AC09                   | Must                          | P       |
| FR-23 | Alertmanager gửi notification `Resolved` khi điều kiện cảnh báo không còn thỏa mãn.                                                                                                                                                                              | OBJ04        | PRB01–PRB09                | AS-01–AS-09                | AC10                   | Must                          | P       |
| FR-24 | Alertmanager áp dụng inhibition: AS-04 trên một `host` hạn chế AS-05 (VM Web), AS-07 (VM Database) và AS-09 của target cùng `host`; không hạn chế cảnh báo có `role="monitoring"`. Chỉ bật sau khi probe Host Down được xác minh tin cậy.                        | OBJ01–OBJ04  | PRB04, PRB05, PRB07, PRB09 | AS-04, AS-05, AS-07, AS-09 | AC11                   | Should                        | P       |
| FR-25 | Alertmanager cấu hình grouping (`group_by`, `group_wait`, `group_interval`, `repeat_interval`) để hạn chế gửi lặp.                                                                                                                                               | OBJ04        | –                          | AS-01–AS-10                | AC09, AC10 (gián tiếp) | Should                        | P       |

### 5.4. Nhóm D – Quản lý cấu hình, mô phỏng sự cố và mở rộng

| Mã    | Yêu cầu                                                                                                                                                                                                                                                                                                                                 | Đối tượng    | Vấn đề      | Tình huống  | AC                         | Ưu tiên                           | Phạm vi |
| ----- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------ | ----------- | ----------- | -------------------------- | --------------------------------- | ------- |
| FR-26 | Toàn bộ cấu hình Prometheus, Alert Rules, Alertmanager, Blackbox, Dashboard được lưu trong Git và vượt qua `promtool check config` / `promtool check rules` (và `amtool check-config` cho Alertmanager).                                                                                                                                | OBJ04        | –           | AS-01–AS-10 | AC13                       | Must                              | P       |
| FR-27 | Cung cấp bộ kịch bản tạo sự cố có kiểm soát, có thể chạy lặp và có bước khôi phục, cho từng tình huống: tải CPU/RAM (`stress-ng` có giới hạn), làm đầy filesystem thử nghiệm, tắt VM/ngắt mạng, dừng Nginx, dừng/chặn cổng Database, dừng exporter, làm hỏng receiver thử nghiệm. Mỗi kịch bản ghi lại mốc thời gian bắt đầu/khắc phục. | OBJ01–OBJ06  | PRB01–PRB10 | AS-01–AS-10 | AC03–AC08, AC15, AC19–AC22 | Must (AS Must) / Should (còn lại) | P + M   |
| FR-28 | Thêm một Server mới vào phạm vi giám sát chỉ bằng một thao tác cấu hình (ví dụ thêm một mục `file_sd`/target kèm nhãn `host`, `environment`); Dashboard tự hiển thị qua biến template.                                                                                                                                                  | OBJ01, OBJ05 | –           | –           | AC17                       | Could                             | P       |

## 6. Yêu cầu phi chức năng (NFR)

| Mã     | Loại                            | Yêu cầu                                                                                                                                                                                                                                                        | Đo lường / kiểm chứng                                                                                    | Đối tượng           | Vấn đề                    | Tình huống                | AC                          | Ưu tiên                          | Phạm vi |
| ------ | ------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------- | ------------------- | ------------------------- | ------------------------- | --------------------------- | -------------------------------- | ------- |
| NFR-01 | Hiệu năng – thời gian thông báo | Notification Time của mỗi tình huống không vượt `X_*` tương ứng (`X` Host Down, `X_CPU`, `X_RAM`, `X_DISK`, `X_WEB`, `X_DB`, `X_SCRAPE`).                                                                                                                      | Đo từ mốc bắt đầu sự cố (FR-27) đến khi nhận Telegram; báo cáo riêng Detection Time và Notification Time | OBJ01–OBJ04         | PRB01–PRB05, PRB07, PRB09 | AS-01–AS-05, AS-07, AS-09 | AC03–AC08, AC19             | Must                             | P       |
| NFR-02 | Hiệu năng – thời gian phục hồi  | Recovery Time không vượt `W`.                                                                                                                                                                                                                                  | Đo từ mốc khắc phục đến khi nhận `Resolved`                                                              | OBJ04               | PRB01–PRB09               | AS-01–AS-09               | AC10                        | Must                             | P       |
| NFR-03 | Độ tin cậy cảnh báo             | Mỗi tình huống AS-01–AS-05, AS-07 được kiểm thử 10–20 lần; tỷ lệ phát hiện đúng 100%; báo cáo min/max/trung vị; không phát sinh cảnh báo khi không có sự cố trong cùng phiên thử (dùng `for` để loại spike).                                                   | Bảng kết quả lặp của Nhóm 4                                                                              | OBJ01–OBJ03         | PRB01–PRB05, PRB07        | AS-01–AS-05, AS-07        | AC15                        | Must                             | P       |
| NFR-04 | Ổn định                         | Hệ thống chạy liên tục 24–48 giờ không mất target ngoài dự kiến.                                                                                                                                                                                               | Soak test; theo dõi `up` và `ALERTS`                                                                     | OBJ04               | PRB09                     | AS-09                     | AC14                        | Should                           | P       |
| NFR-05 | Tài nguyên                      | Prometheus không vượt mức tài nguyên `R`; exporter trên VM Web/Database không làm thay đổi đáng kể tải nền (đề xuất < 5% CPU, < 100 MB RAM mỗi exporter – BL-15).                                                                                              | Đo trong soak test                                                                                       | OBJ04, OBJ01        | –                         | –                         | AC14                        | Should                           | P       |
| NFR-06 | Lưu trữ                         | Thời gian lưu dữ liệu tối thiểu đủ bao phủ soak test và giai đoạn kiểm thử lặp (đề xuất ≥ 15 ngày – BL-14); dung lượng TSDB không làm Disk VM Monitoring vượt `Y_DISK`.                                                                                        | Kiểm tra cấu hình retention và dung lượng thực tế                                                        | OBJ04               | PRB03 (trên VM1)          | AS-03                     | AC14                        | Must                             | P       |
| NFR-07 | Khả năng tái tạo                | Thành viên khác dựng lại môi trường theo tài liệu trong ≤ `T` giờ và đạt AC01, AC02.                                                                                                                                                                           | Thực hiện bởi thành viên không tham gia dựng                                                             | OBJ04               | –                         | –                         | AC12                        | Must                             | P       |
| NFR-08 | Bảo trì                         | Cấu hình mô-đun theo lớp (Server / dịch vụ / Monitoring), tách file rule theo nhóm AS; không hard-code địa chỉ IP trong rule.                                                                                                                                  | Rà soát repository                                                                                       | OBJ04               | –                         | AS-01–AS-10               | AC13, AC17                  | Must                             | P       |
| NFR-09 | Mở rộng                         | Kiến trúc cho phép thêm target, thêm giá trị `environment` hoặc thêm nguồn dữ liệu (ví dụ khi có yêu cầu cụ thể hơn từ VNPT) mà không thay đổi thành phần lõi.                                                                                                 | Thực hiện FR-28                                                                                          | OBJ01, OBJ05, OBJ06 | –                         | –                         | AC17                        | Could                            | M       |
| NFR-10 | Bảo mật cơ bản                  | Không commit Telegram bot token, mật khẩu DB/Grafana vào Git (dùng biến môi trường/file bị ignore); đổi mật khẩu mặc định Grafana; cổng exporter chỉ cho VM Monitoring truy cập; tài khoản Database Exporter chỉ có quyền đọc thống kê.                        | Rà soát repository và firewall                                                                           | OBJ02–OBJ04         | –                         | –                         | Chưa có AC (đề xuất – P-09) | Must                             | P       |
| NFR-11 | Kiểm soát cardinality           | Không dùng nhãn có giá trị thay đổi liên tục (request ID, user ID); tập giá trị `environment`, `host`, `role` cố định và được liệt kê trong tài liệu thiết kế.                                                                                                 | Rà soát cấu hình relabel                                                                                 | OBJ04               | –                         | –                         | AC13                        | Must                             | P       |
| NFR-12 | Đồng bộ thời gian               | Ba VM và máy dùng để đo đồng bộ thời gian (NTP/chrony), sai lệch ≤ 1 giây, để số đo NFR-01/02 có giá trị.                                                                                                                                                      | Kiểm tra `timedatectl` trước mỗi phiên đo                                                                | OBJ01, OBJ04        | –                         | AS-01–AS-10               | AC15                        | Must                             | P       |
| NFR-13 | Giới hạn tự giám sát            | Tài liệu nêu rõ hệ thống không tự phát hiện khi VM Monitoring, Prometheus hoặc Alertmanager ngừng hoạt động, hoặc khi kênh Telegram lỗi (AS-10 có thể không gửi được qua chính receiver lỗi). Cơ chế giám sát độc lập (heartbeat/watchdog bên ngoài) là Could. | Rà soát tài liệu giới hạn                                                                                | OBJ04               | PRB09, PRB10              | AS-09, AS-10              | AC16, AC19                  | Must (tài liệu) / Could (cơ chế) | P       |
| NFR-14 | Khả dụng (usability)            | Notification đọc được trên điện thoại, một dòng tiêu đề nêu `severity`, tên cảnh báo, `host`; Dashboard có ngưỡng hiển thị trùng với `Y_*` của Alert Rules.                                                                                                    | Rà soát với Nhóm 4                                                                                       | OBJ04               | –                         | AS-01–AS-10               | AC09                        | Should                           | P       |
| NFR-15 | Nhất quán tài liệu và thuật ngữ | Mọi tài liệu dùng đúng thuật ngữ mục 2.1 và mã truy vết thống nhất; tài liệu giới hạn nêu rõ phạm vi P / M / K.                                                                                                                                                | Leader rà soát trước mỗi báo cáo tháng và Tuần 18                                                        | OBJ05, OBJ06        | –                         | –                         | AC16, AC18                  | Must                             | P       |

## 7. Tham số Baseline đề xuất (chốt Tuần 6)

Giá trị dưới đây là **đề xuất khởi điểm** để kiểm chứng trong `docs/design/validation/` (Tuần 5), **chưa phải giá trị nghiệm thu**.

| Mã    | Tham số                                   | Ký hiệu                     | Đề xuất khởi điểm                                   | Dùng bởi            |
| ----- | ----------------------------------------- | --------------------------- | --------------------------------------------------- | ------------------- |
| BL-01 | Scrape interval                           | S                           | 15 s                                                | FR-01–FR-08, NFR-01 |
| BL-02 | Rule evaluation interval                  | E                           | 15 s                                                | FR-16–FR-20, NFR-01 |
| BL-03 | `group_wait`                              | G                           | 30 s                                                | FR-25, NFR-01       |
| BL-04 | Ngưỡng / duy trì CPU                      | `Y_CPU` / `F_CPU`           | 80 % / 5 phút                                       | FR-16               |
| BL-05 | Ngưỡng / duy trì RAM                      | `Y_RAM` / `F_RAM`           | 85 % / 5 phút                                       | FR-16               |
| BL-06 | Ngưỡng / duy trì Disk                     | `Y_DISK` / `F_DISK`         | 85 % / 2 phút                                       | FR-16               |
| BL-07 | Duy trì Host Down                         | `F_HOST`                    | 1 phút                                              | FR-17               |
| BL-08 | Duy trì Web Down                          | `F_WEB_DOWN`                | 1 phút                                              | FR-18               |
| BL-09 | Ngưỡng / duy trì Web Response Time        | `Y_WEB_TIME` / `F_WEB_TIME` | 1 s (probe timeout 5 s) / 5 phút                    | FR-18               |
| BL-10 | Duy trì Database Unreachable              | `F_DB`                      | 1 phút                                              | FR-19               |
| BL-11 | Ngưỡng / duy trì DB Connections           | `Y_DB_CONN` / `F_DB_CONN`   | 80 % max connections / 5 phút                       | FR-19               |
| BL-12 | Duy trì Scrape Failure                    | `F_SCRAPE`                  | 2 phút                                              | FR-20               |
| BL-13 | Thời gian tối đa thông báo / phục hồi     | `X_*` / `W`                 | Xác định từ kết quả đo validation (không đặt trước) | NFR-01, NFR-02      |
| BL-14 | Retention                                 | –                           | 15 ngày                                             | NFR-06              |
| BL-15 | Giới hạn tài nguyên Prometheus / exporter | R                           | Xác định sau soak test                              | NFR-05              |
| BL-16 | Số VM tối thiểu / thời gian tái tạo       | N / T                       | 3 VM / chờ xác nhận                                 | AC01, NFR-07        |

## 8. Ma trận truy vết

### 8.1. Theo đối tượng (OBJ → FR/NFR)

| Đối tượng                                      | FR                                                                          | NFR                                   | Phạm vi                      |
| ---------------------------------------------- | --------------------------------------------------------------------------- | ------------------------------------- | ---------------------------- |
| OBJ01 – Máy chủ và hệ điều hành (Server)       | FR-01, FR-02, FR-09, FR-11, FR-13, FR-16, FR-17, FR-21, FR-24, FR-27, FR-28 | NFR-01–NFR-03, NFR-05, NFR-09, NFR-12 | P                            |
| OBJ02 – Dịch vụ Web                            | FR-03, FR-12, FR-18, FR-24, FR-27                                           | NFR-01–NFR-03, NFR-10                 | P                            |
| OBJ03 – Cơ sở dữ liệu                          | FR-04, FR-05, FR-06, FR-12, FR-19, FR-24, FR-27                             | NFR-01–NFR-03, NFR-10                 | P                            |
| OBJ04 – Hệ thống Monitoring                    | FR-07, FR-08, FR-10, FR-14, FR-15, FR-20–FR-23, FR-25, FR-26                | NFR-04–NFR-08, NFR-11, NFR-13, NFR-14 | P                            |
| OBJ05 – Bối cảnh ảo hóa → **Cloud Simulation** | FR-02, FR-09, FR-13, FR-17, FR-27, FR-28 (chỉ qua nhãn trên target OBJ01)   | NFR-09, NFR-15                        | M; phần nền tảng thực tế: K  |
| OBJ06 – Hạ tầng → **Data Center Simulation**   | FR-03, FR-04, FR-09, FR-13, FR-27 (chỉ qua nhãn trên target OBJ02, OBJ03)   | NFR-09, NFR-15                        | M; phần phần cứng thực tế: K |

### 8.2. Theo vấn đề (PRB → FR/NFR)

| Vấn đề                               | Ưu tiên (Survey) | FR                                              | NFR                            | Tình huống |
| ------------------------------------ | ---------------- | ----------------------------------------------- | ------------------------------ | ---------- |
| PRB01 – CPU cao                      | Bắt buộc         | FR-01, FR-11, FR-16, FR-27                      | NFR-01, NFR-02, NFR-03         | AS-01      |
| PRB02 – RAM gần hết                  | Bắt buộc         | FR-01, FR-11, FR-16, FR-27                      | NFR-01, NFR-02, NFR-03         | AS-02      |
| PRB03 – Disk gần đầy                 | Bắt buộc         | FR-01, FR-11, FR-16, FR-27                      | NFR-01–NFR-03, NFR-06          | AS-03      |
| PRB04 – Server mất kết nối           | Bắt buộc         | FR-02, FR-09, FR-11, FR-17, FR-24, FR-27        | NFR-01–NFR-03                  | AS-04      |
| PRB05 – Web ngừng hoạt động          | Bắt buộc         | FR-03, FR-12, FR-18, FR-24, FR-27               | NFR-01–NFR-03                  | AS-05      |
| PRB06 – Web phản hồi chậm            | Nên có           | FR-03, FR-12, FR-18, FR-27                      | NFR-02                         | AS-06      |
| PRB07 – Database không truy cập được | Bắt buộc         | FR-04, FR-05, FR-06, FR-12, FR-19, FR-24, FR-27 | NFR-01–NFR-03                  | AS-07      |
| PRB08 – Kết nối Database cao         | Nên có           | FR-05, FR-12, FR-19, FR-27                      | NFR-02                         | AS-08      |
| PRB09 – Scrape target thất bại       | Bắt buộc         | FR-07, FR-09, FR-14, FR-20, FR-24, FR-27        | NFR-01, NFR-02, NFR-04, NFR-13 | AS-09      |
| PRB10 – Alertmanager gửi thất bại    | Nên có           | FR-08, FR-14, FR-20, FR-22, FR-27               | NFR-13                         | AS-10      |

### 8.3. Theo tình huống cảnh báo (AS → FR/NFR/AC)

| Tình huống | Tên                               | Lớp / `environment`           | FR                                | NFR                    | AC (theo `acceptance_criteria_0.2.md`) |
| ---------- | --------------------------------- | ----------------------------- | --------------------------------- | ---------------------- | -------------------------------------- |
| AS-01      | CPU Usage High                    | L1 / `Server`                 | FR-01, FR-16, FR-21–FR-23, FR-27  | NFR-01–NFR-03          | AC04, AC09, AC10, AC15                 |
| AS-02      | Memory Available Low              | L1 / `Server`                 | FR-01, FR-16, FR-21–FR-23, FR-27  | NFR-01–NFR-03          | AC05, AC09, AC10, AC15                 |
| AS-03      | Disk Usage High                   | L1 / `Server`                 | FR-01, FR-16, FR-21–FR-23, FR-27  | NFR-01–NFR-03          | AC06, AC09, AC10, AC15                 |
| AS-04      | Host Down                         | L2 / `Cloud Simulation`       | FR-02, FR-17, FR-21–FR-24, FR-27  | NFR-01–NFR-03, NFR-12  | AC03, AC09, AC10, AC11, AC15           |
| AS-05      | Web Service Down                  | L3 / `Data Center Simulation` | FR-03, FR-18, FR-21–FR-24, FR-27  | NFR-01–NFR-03          | AC07, AC09, AC10, AC11, AC15           |
| AS-06      | Web Response Time High            | L3 / `Data Center Simulation` | FR-03, FR-18, FR-21–FR-23, FR-27  | NFR-02                 | AC20 (đề xuất)                         |
| AS-07      | Database Unreachable              | L3 / `Data Center Simulation` | FR-04, FR-19, FR-21–FR-24, FR-27  | NFR-01–NFR-03          | AC08, AC09, AC10, AC11, AC15           |
| AS-08      | Database Connections High         | L3 / `Data Center Simulation` | FR-05, FR-19, FR-21–FR-23, FR-27  | NFR-02                 | AC21 (đề xuất)                         |
| AS-09      | Prometheus Scrape Target Failure  | L4 / `role="monitoring"`      | FR-07, FR-20–FR-24, FR-27         | NFR-01, NFR-04, NFR-13 | AC19                                   |
| AS-10      | Alertmanager Notification Failure | L4 / `role="monitoring"`      | FR-08, FR-20, FR-21, FR-22, FR-27 | NFR-13                 | AC22 (đề xuất)                         |

**Kiểm tra độ phủ:** 10/10 PRB và 10/10 AS đều có ít nhất một FR và một NFR. FR-13 và NFR-10 chưa có AC tương ứng (xem P-09).

## 9. Phản biện điểm nghẽn và mâu thuẫn giữa các tài liệu

| Mã   | Vấn đề                                                                                                                                                                              | Tài liệu liên quan                      | Đề xuất xử lý                                                                                                                                                                              | Người xử lý     |
| ---- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | --------------- |
| P-01 | **3 VM không đủ để tách 1:1 thành 3 nhóm `environment` có ý nghĩa.** Nếu gắn theo VM, mỗi nhóm chỉ có 1 VM và VM Monitoring bị xếp vào `Server` một cách gượng ép.                  | Tài liệu 01 mục 3; Survey mục 3.1       | Áp dụng GĐ-03 (gắn theo góc nhìn target); trình PM xác nhận Tuần 5. Nếu PM yêu cầu 1:1, cân nhắc thêm VM thứ 4 hoặc chấp nhận mỗi nhóm 1 VM.                                               | Leader / PM     |
| P-02 | **Phương pháp kiểm thử AC11 mâu thuẫn với topology.** AC11 viết "Tắt một VM đang chạy Web và Database", nhưng Web và Database nằm trên 2 VM khác nhau.                              | `acceptance_criteria_0.2.md` AC11       | Sửa AC11 thành hai ca: tắt VM Web → chỉ còn AS-04 (AS-05 bị hạn chế); tắt VM Database → chỉ còn AS-04 (AS-07 bị hạn chế). Thêm ca âm: dừng Nginx khi VM Web vẫn chạy → AS-05 vẫn phải gửi. | Nhóm 1          |
| P-03 | **VM Monitoring là điểm lỗi đơn.** Prometheus, Alertmanager và Blackbox cùng trên VM1; AS-04 không áp dụng cho VM1; khi VM1 tắt không có cảnh báo nào.                              | Alert Scenarios AS-04, AS-09; AC19      | Ghi rõ giới hạn trong NFR-13/AC16; nếu Mentor yêu cầu, bổ sung heartbeat (Alert luôn Firing gửi đến dịch vụ dead-man-switch bên ngoài) mức Could.                                          | Nhóm 1 / Mentor |
| P-04 | **AS-10 phụ thuộc chính receiver đang lỗi.** Khi Telegram lỗi, cảnh báo AS-10 cũng gửi qua Telegram.                                                                                | Alert Scenarios mục 7.2                 | AC22 chỉ yêu cầu phát hiện (Metric + Dashboard FR-14), không yêu cầu gửi thông báo; cần ghi rõ để không bị đánh giá trượt.                                                                 | Nhóm 1 / Nhóm 4 |
| P-05 | **ICMP trong VirtualBox chưa xác minh.** Chế độ NAT mặc định không cho VM1 thấy VM2/VM3; Blackbox cần `CAP_NET_RAW`.                                                                | Alert Scenarios mục 10; GĐ-08           | Kiểm chứng tại `docs/design/validation/` Tuần 5; phương án dự phòng là TCP probe cổng SSH (22).                                                                                            | Nhóm 2 / Nhóm 3 |
| P-06 | **Stress test có thể làm nhiễu VM khác** do 3 VM cùng chạy trên một máy host (noisy neighbor), làm sai lệch số đo NFR-01.                                                           | AC15; tài liệu 01 nguyên tắc 3          | Giới hạn `stress-ng` theo số core và thời gian; ghi tài nguyên máy host trong báo cáo đo; không chạy hai kịch bản tải đồng thời.                                                           | Nhóm 4          |
| P-07 | **AS-02 cho phép hai phương pháp đo RAM** (RAM Usage % hoặc MemAvailable), trong khi AC05 chỉ nêu Memory Usage %.                                                                   | Alert Scenarios AS-02; AC05             | Chốt một phương pháp ở Baseline (đề xuất RAM Usage % tính từ MemAvailable – đồng nhất với MET-MEM-03 và AC05).                                                                             | Nhóm 1          |
| P-08 | **AC06 thiếu `F_DISK`** trong khi AS-03 có thời gian duy trì `F_DISK`.                                                                                                              | AC06; AS-03                             | Bổ sung `F_DISK` vào AC06 bản 0.3.                                                                                                                                                         | Nhóm 1          |
| P-09 | **Yêu cầu chưa có AC:** FR-13 (lọc theo `environment`) – yêu cầu đã chốt trong tài liệu 01 nhưng không có tiêu chí nghiệm thu; NFR-10 (bảo mật cơ bản); NFR-12 (đồng bộ thời gian). | AC 0.2                                  | Đề xuất AC23 (Dashboard lọc theo `environment`), AC24 (không lộ secret trong Git) trong bản AC 0.3. NFR-12 xử lý như điều kiện tiên quyết của AC15.                                        | Nhóm 1          |
| P-10 | **Lệch quy ước mã.** Project quy ước `AC-xx`, nhưng `acceptance_criteria_0.2.md` dùng `ACxx`; Survey dùng S1–S6 với thứ tự khác AS-01–AS-10 (S1 = Host Down nhưng AS-01 = CPU).     | Survey mục 5.1; AC 0.2; Alert Scenarios | Chốt dùng AS-xx làm mã tình huống duy nhất, bỏ S1–S6 khi cập nhật Survey; thống nhất `AC-xx` hoặc `ACxx` một lần ở bản AC 0.3 và cập nhật toàn bộ tham chiếu.                              | Leader          |
| P-11 | **AC11 dùng nhãn `instance` cho inhibition**, trong khi Alert Scenarios mục 8.2 khuyến cáo không dựa vào `instance` (probe và exporter có địa chỉ/cổng khác nhau).                  | AC mục 6; Alert Scenarios mục 8.2       | Dùng nhãn `host` (FR-09, FR-24); sửa câu chữ AC mục 6.                                                                                                                                     | Nhóm 1          |
| P-12 | **Khối lượng kiểm thử lặp AC15 lớn.** 6 tình huống × 10–20 lần × (phát hiện + phục hồi, ước tính 5–10 phút/lần) ≈ 5–20 giờ đo thuần, chưa tính thời gian chuẩn bị.                  | AC15; Kế hoạch 18 tuần                  | Tự động hóa FR-27 (script ghi mốc thời gian, đọc API Alertmanager/Telegram); phân bổ từ Tuần 9–11.                                                                                         | Nhóm 4 / Leader |
| P-13 | **Phụ thuộc lựa chọn Database** chặn FR-05, AS-08, AC21 và tên Metric trong FR-12.                                                                                                  | Survey mục 9 câu 4                      | Chốt trước khi dựng VM3 (Tuần 5); cập nhật tài liệu này ngay sau khi chốt.                                                                                                                 | Nhóm 2 / Nhóm 3 |

## 10. Những điểm cần xác nhận

| Nội dung                                                                                           | Hỏi ai                | Hạn                           | Trạng thái     |
| -------------------------------------------------------------------------------------------------- | --------------------- | ----------------------------- | -------------- |
| GĐ-01, GĐ-02: phạm vi Cloud Simulation và Data Center Simulation chỉ dừng ở mức mô phỏng trên 3 VM | PM / Mentor           | Gửi Tuần 4, chốt Tuần 6       | Chưa gửi       |
| GĐ-03: cách gắn nhãn `environment`                                                                 | PM                    | Tuần 5                        | Chưa gửi       |
| GĐ-06: N = 3 VM khi nghiệm thu                                                                     | Mentor                | Tuần 6                        | Chưa gửi       |
| GĐ-07: SQL Availability Check có bắt buộc không                                                    | Mentor                | Tuần 6                        | Chưa gửi       |
| Bổ sung AC23, AC24 và sửa AC06, AC11 (P-02, P-08, P-09, P-11)                                      | Nhóm 1 nội bộ, Nhóm 4 | AC bản 0.3 – trước 28/11/2026 | Chưa thực hiện |
| Heartbeat ra ngoài cho VM Monitoring (P-03)                                                        | Mentor                | Tuần 6                        | Chưa gửi       |

## 11. Lịch sử cập nhật

| Ngày       | Nội dung                                                                                                                                                                            |
| ---------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 24/11/2026 | Tạo bản nháp FR-01–FR-28, NFR-01–NFR-15; phân lớp đối tượng theo `environment`; phân tách phạm vi P / M / K; ma trận truy vết OBJ/PRB/AS; đề xuất BL-01–BL-16; phản biện P-01–P-13. |

---

**Tài liệu liên quan:**

- `problem-survey.md` (SCRUM-6)
- `metrics-inventory.md` (SCRUM-8)
- `alert-scenarios.md`
- `acceptance_criteria_0.2.md`
- Tài liệu tiếp theo: Kiến trúc hệ thống, luồng dữ liệu và luồng cảnh báo (Tuần 5); Baseline và đặc tả cảnh báo (Tuần 6).
