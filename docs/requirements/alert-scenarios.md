# Alert Scenarios – Danh mục tình huống cảnh báo

**Dự án:** N4.7 – Xây dựng hệ thống giám sát máy chủ, Cloud và trung tâm dữ liệu  
**Nhóm phụ trách:** Nhóm 1 – Phân tích & Thiết kế  
**Mã Jira:** Chưa cập nhật  
**Người thực hiện:** Ngô Thảo My  
**Ngày tạo:** 21/11/2026  
**Ngày cập nhật:** 21/11/2026  
**Người review:** Chờ review  
**Trạng thái:** Draft

---

## 1. Mục đích

Tài liệu này xác định các tình huống cảnh báo dự kiến cho Prototype N4.7, bao gồm điều kiện phát sinh cảnh báo, nguồn Metrics, mức độ nghiêm trọng, kết quả mong đợi, phương pháp kiểm thử và điều kiện phục hồi.

Alert Scenarios là đầu vào cho:

- Xây dựng Alert Rules trong Prometheus.
- Thiết kế cấu hình Alertmanager và cơ chế gửi thông báo.
- Xây dựng Dashboard theo dõi trạng thái cảnh báo.
- Xây dựng Test Plan và Test Case cho Nhóm 4.
- Xác định mối quan hệ giữa các cảnh báo và hạn chế cảnh báo trùng lặp.

Tài liệu này **không phải danh sách Alert Rules hoàn chỉnh**. Các ngưỡng, thời gian duy trì, thời gian phát hiện và thời gian gửi thông báo sẽ được xác định trong giai đoạn thiết kế và Baseline.

## 2. Phạm vi và giả định

### 2.1. Phạm vi tình huống cảnh báo

| Nhóm       | Nội dung cảnh báo                                                           | Nguồn Metrics dự kiến                        |
| ---------- | --------------------------------------------------------------------------- | -------------------------------------------- |
| Host       | CPU Usage cao, RAM khả dụng thấp, Disk Usage cao, Host Down                 | Node Exporter, Prometheus, Blackbox Exporter |
| Web        | Web Service không truy cập được, Web Response Time cao                      | Blackbox Exporter                            |
| Database   | Database không thể kết nối, số lượng kết nối cao                            | Blackbox Exporter, Database Exporter         |
| Monitoring | Prometheus không scrape được target, Alertmanager gửi notification thất bại | Prometheus, Alertmanager                     |

### 2.2. Giả định và giới hạn

- Prototype dự kiến sử dụng Ubuntu Server làm môi trường máy chủ.
- Prometheus thu thập Metrics và đánh giá Alert Rules.
- Alertmanager tiếp nhận Alert từ Prometheus, thực hiện group, route, inhibition và gửi notification.
- Node Exporter cung cấp Metrics cấp hệ điều hành Linux.
- Blackbox Exporter thực hiện các probe HTTP, TCP hoặc ICMP.
- Database đang chờ nhóm thống nhất MySQL hay PostgreSQL.
- Kênh thông báo dự kiến là Telegram, nhưng cần xác nhận trước khi chốt cấu hình.
- Các ngưỡng cảnh báo và thời gian duy trì chưa được xác định tại giai đoạn này.
- Các phương pháp kiểm thử trong tài liệu là đề xuất, chưa có nghĩa đã được thực hiện trên môi trường thực tế.

## 3. Nguyên tắc xây dựng Alert

### 3.1. Phân biệt điều kiện cảnh báo và Alert Policy

Cần phân biệt:

- **Trigger Condition:** Điều kiện Metrics khiến tình huống cảnh báo được xem là xảy ra.
- **Alert Policy:** Quy định về ngưỡng, thời gian duy trì, mức độ nghiêm trọng và cách xử lý cảnh báo.
- **Notification:** Thông báo được Alertmanager gửi đến kênh nhận đã cấu hình.
- **Recovery:** Trạng thái cảnh báo được chuyển về Resolved khi điều kiện gây cảnh báo không còn tồn tại.

Một Metric vượt ngưỡng trong thời gian ngắn không nhất thiết phải tạo cảnh báo ngay lập tức. Với những tình huống cần loại bỏ biến động nhất thời, cần quy định thời gian duy trì điều kiện.

### 3.2. Các trạng thái cảnh báo

| Trạng thái | Ý nghĩa                                                                        |
| ---------- | ------------------------------------------------------------------------------ |
| Inactive   | Điều kiện cảnh báo chưa được thỏa mãn                                          |
| Pending    | Điều kiện đã được thỏa mãn nhưng chưa đủ thời gian duy trì theo cấu hình `for` |
| Firing     | Điều kiện cảnh báo đã thỏa mãn và đủ thời gian duy trì                         |
| Resolved   | Điều kiện cảnh báo không còn thỏa mãn và cảnh báo đã được giải quyết           |

Lưu ý:

- Pending và Firing là các trạng thái được sử dụng trong quá trình đánh giá Alert Rule.
- Alertmanager tiếp nhận các Alert từ Prometheus để xử lý và gửi notification.
- Alert chuyển sang Firing không đồng nghĩa notification đã được gửi thành công.
- Notification Resolved phụ thuộc cấu hình gửi thông báo và chính sách xử lý của Alertmanager.

### 3.3. Mức độ ưu tiên

| Mức độ   | Ý nghĩa                                                                                             | Cách sử dụng dự kiến                                 |
| -------- | --------------------------------------------------------------------------------------------------- | ---------------------------------------------------- |
| Critical | Sự cố nghiêm trọng, ảnh hưởng trực tiếp đến khả năng hoạt động của hệ thống hoặc dịch vụ quan trọng | Host Down hoặc dịch vụ quan trọng không thể truy cập |
| Warning  | Tình trạng bất thường cần theo dõi hoặc xử lý trước khi trở thành sự cố nghiêm trọng                | CPU, RAM, Disk hoặc Connection vượt ngưỡng           |

Mức độ cụ thể của từng Alert sẽ được xác nhận khi thiết kế Alert Rules.

### 3.4. Nguyên tắc xác định thời gian cảnh báo

Thời gian cảnh báo có thể bao gồm:

- Thời gian chờ đến lần scrape tiếp theo.
- Thời gian chờ đến lần đánh giá Alert Rule tiếp theo.
- Thời gian duy trì điều kiện cảnh báo (`for`).
- Thời gian chờ nhóm notification (`group_wait`).
- Thời gian xử lý và gửi notification.

Công thức ước lượng:

`Alert Latency ≈ Scrape Delay + Evaluation Delay + Rule Duration + Group Wait + Notification Delay`

Đây là công thức ước lượng, không phải cam kết các thành phần luôn cộng tuyến tính. Thời gian thực tế cần được đo trong quá trình kiểm thử.

Cần phân biệt:

- **Detection Time:** Thời gian từ khi sự cố bắt đầu đến khi Alert chuyển sang Firing.
- **Notification Time:** Thời gian từ khi sự cố bắt đầu đến khi thông báo được nhận tại kênh nhận.
- **Recovery Time:** Thời gian từ khi khắc phục sự cố đến khi nhận được thông báo Resolved.

## 4. Host Alert Scenarios

### 4.1. AS-01 – CPU Usage High

**Mục đích:** Phát hiện tình trạng CPU sử dụng cao kéo dài trên máy chủ.

| Thuộc tính         | Nội dung                                                                                                                              |
| ------------------ | ------------------------------------------------------------------------------------------------------------------------------------- |
| Alert ID           | AS-01                                                                                                                                 |
| Tên tình huống     | CPU Usage High                                                                                                                        |
| Mô tả              | CPU Usage vượt ngưỡng trong một khoảng thời gian liên tục, có thể ảnh hưởng đến khả năng xử lý của hệ thống và các dịch vụ đang chạy. |
| Metric chính       | CPU Usage (%) – Derived từ `node_cpu_seconds_total`                                                                                   |
| Metric hỗ trợ      | `node_load1`, `node_load5`, `node_load15`                                                                                             |
| Trigger Condition  | CPU Usage vượt ngưỡng Y_CPU% liên tục trong F_CPU phút.                                                                               |
| Severity           | Warning                                                                                                                               |
| Expected Result    | Prometheus chuyển Alert sang Firing và Alertmanager gửi thông báo đến kênh nhận đã cấu hình.                                          |
| Test Method        | Sử dụng `stress-ng` tạo tải CPU có kiểm soát, ghi nhận thời điểm bắt đầu và thời điểm nhận cảnh báo.                                  |
| Recovery Condition | CPU Usage giảm xuống dưới ngưỡng phục hồi đã thống nhất và Alert chuyển sang Resolved.                                                |
| Related Problem    | PRB01 – CPU utilization cao                                                                                                           |

Lưu ý:

- Không nên cảnh báo chỉ vì CPU tăng cao trong một thời điểm ngắn.
- Cần sử dụng thời gian duy trì để hạn chế cảnh báo do spike nhất thời.
- CPU Usage và Load Average là hai chỉ số khác nhau, không nên thay thế trực tiếp cho nhau.
- `keep_firing_for` có thể giữ Alert ở trạng thái Firing thêm một khoảng thời gian sau khi điều kiện không còn đúng; đây không phải cơ chế hysteresis.

### 4.2. AS-02 – Memory Available Low

**Mục đích:** Phát hiện tình trạng bộ nhớ khả dụng thấp trên máy chủ.

| Thuộc tính         | Nội dung                                                                                                             |
| ------------------ | -------------------------------------------------------------------------------------------------------------------- |
| Alert ID           | AS-02                                                                                                                |
| Tên tình huống     | Memory Available Low                                                                                                 |
| Mô tả              | Lượng RAM khả dụng giảm xuống dưới ngưỡng, có thể khiến hệ thống tăng sử dụng Swap hoặc gặp tình trạng thiếu bộ nhớ. |
| Metric chính       | `node_memory_MemAvailable_bytes` hoặc RAM Usage (%)                                                                  |
| Metric hỗ trợ      | `node_memory_SwapFree_bytes`, `node_memory_SwapTotal_bytes`                                                          |
| Trigger Condition  | RAM Usage vượt ngưỡng Y_RAM% hoặc MemAvailable giảm dưới ngưỡng đã xác định trong F_RAM phút.                        |
| Severity           | Warning                                                                                                              |
| Expected Result    | Prometheus phát sinh Alert và Alertmanager gửi thông báo về tình trạng RAM khả dụng thấp.                            |
| Test Method        | Sử dụng công cụ tạo tải bộ nhớ có kiểm soát, theo dõi MemAvailable và trạng thái cảnh báo.                           |
| Recovery Condition | MemAvailable tăng trở lại hoặc RAM Usage giảm xuống dưới ngưỡng phục hồi đã thống nhất.                              |
| Related Problem    | PRB02 – RAM utilization cao                                                                                          |

Lưu ý:

- RAM Usage cao không tự động đồng nghĩa hệ thống sẽ bị OOM Killer.
- Cần xem xét MemAvailable, Swap và xu hướng bộ nhớ theo thời gian.
- `MemAvailable` phù hợp hơn `MemFree` khi đánh giá khả năng cấp phát bộ nhớ trên Linux.

### 4.3. AS-03 – Disk Usage High

**Mục đích:** Phát hiện filesystem có dung lượng khả dụng thấp.

| Thuộc tính         | Nội dung                                                                                                                                 |
| ------------------ | ---------------------------------------------------------------------------------------------------------------------------------------- |
| Alert ID           | AS-03                                                                                                                                    |
| Tên tình huống     | Disk Usage High                                                                                                                          |
| Mô tả              | Dung lượng filesystem sử dụng vượt ngưỡng, có thể khiến Database không ghi được dữ liệu hoặc dịch vụ không thể tạo file log và file tạm. |
| Metric chính       | Disk Usage (%) – Derived từ `node_filesystem_size_bytes` và `node_filesystem_avail_bytes`                                                |
| Metric hỗ trợ      | `node_filesystem_avail_bytes`, `node_filesystem_free_bytes`                                                                              |
| Trigger Condition  | Disk Usage vượt ngưỡng Y_DISK% trên filesystem thuộc phạm vi giám sát.                                                                   |
| Severity           | Warning                                                                                                                                  |
| Expected Result    | Prometheus phát sinh Alert và Alertmanager gửi thông báo về filesystem có dung lượng sử dụng cao.                                        |
| Test Method        | Tạo file có dung lượng lớn trong filesystem thử nghiệm để tăng mức sử dụng Disk có kiểm soát.                                            |
| Recovery Condition | Disk Usage giảm xuống dưới ngưỡng phục hồi đã thống nhất sau khi giải phóng dung lượng.                                                  |
| Related Problem    | PRB03 – Disk utilization cao                                                                                                             |

Lưu ý:

- Cần xác định filesystem nào thuộc phạm vi giám sát.
- Không nên mặc định mọi filesystem đều cần tạo cảnh báo.
- Không thực hiện phép thử làm đầy filesystem hệ điều hành hoặc filesystem chứa dữ liệu quan trọng.
- Disk đầy có thể ảnh hưởng đến việc ghi dữ liệu hoặc log nhưng không có nghĩa hệ điều hành sẽ lập tức dừng hoạt động.

### 4.4. AS-04 – Host Down

**Mục đích:** Phát hiện máy chủ không còn khả năng phản hồi kiểm tra kết nối từ vị trí giám sát.

| Thuộc tính         | Nội dung                                                                                                               |
| ------------------ | ---------------------------------------------------------------------------------------------------------------------- |
| Alert ID           | AS-04                                                                                                                  |
| Tên tình huống     | Host Down                                                                                                              |
| Mô tả              | Máy chủ không phản hồi kiểm tra kết nối, có thể do máy chủ tắt, mất mạng hoặc không thể truy cập từ hệ thống giám sát. |
| Metric chính       | `probe_success` (ICMP)                                                                                                 |
| Metric hỗ trợ      | `up` của Node Exporter                                                                                                 |
| Trigger Condition  | ICMP probe thất bại liên tục trong khoảng thời gian F_HOST.                                                            |
| Severity           | Critical                                                                                                               |
| Expected Result    | Hệ thống phát hiện Host không phản hồi và gửi cảnh báo Host Down.                                                      |
| Test Method        | Tắt VM được giám sát hoặc ngắt kết nối mạng có kiểm soát, sau đó kiểm tra kết quả probe và thời gian nhận cảnh báo.    |
| Recovery Condition | Host phản hồi lại ICMP probe và trạng thái cảnh báo chuyển sang Resolved.                                              |
| Related Problem    | PRB04 – Host down                                                                                                      |

Lưu ý:

- `up = 0` chỉ chứng minh Prometheus không scrape được target, không đủ để kết luận Host đã tắt.
- ICMP probe cung cấp tín hiệu kiểm tra độc lập với Node Exporter.
- ICMP có thể bị chặn bởi firewall hoặc chính sách mạng, vì vậy cần xác nhận môi trường cho phép probe.
- Blackbox Exporter có thể cần quyền phù hợp như `CAP_NET_RAW` hoặc cấu hình quyền ICMP tương ứng.
- AC03 dự kiến áp dụng cho các VM được giám sát, không mặc định áp dụng cho chính VM chạy Prometheus nếu không có cơ chế giám sát độc lập.

## 5. Web Alert Scenarios

### 5.1. AS-05 – Web Service Down

**Mục đích:** Phát hiện Web Service không thể truy cập qua HTTP/HTTPS.

| Thuộc tính         | Nội dung                                                                                            |
| ------------------ | --------------------------------------------------------------------------------------------------- |
| Alert ID           | AS-05                                                                                               |
| Tên tình huống     | Web Service Down                                                                                    |
| Mô tả              | Web Service không phản hồi hoặc không trả về mã HTTP được chấp nhận theo cấu hình probe.            |
| Metric chính       | `probe_success` (HTTP)                                                                              |
| Metric hỗ trợ      | `probe_http_status_code`, `up` của Blackbox Exporter                                                |
| Trigger Condition  | HTTP probe thất bại liên tục trong khoảng thời gian F_WEB_DOWN.                                     |
| Severity           | Critical                                                                                            |
| Expected Result    | Hệ thống phát hiện Web Service không thể truy cập và gửi cảnh báo.                                  |
| Test Method        | Dừng Nginx hoặc làm dịch vụ không thể truy cập qua HTTP, sau đó kiểm tra kết quả probe và cảnh báo. |
| Recovery Condition | HTTP probe thành công trở lại và Alert chuyển sang Resolved.                                        |
| Related Problem    | PRB05 – Web service down                                                                            |

Lưu ý:

- `probe_success` phụ thuộc vào module HTTP probe và các mã trạng thái được chấp nhận.
- HTTP 200 không đảm bảo toàn bộ chức năng nghiệp vụ của ứng dụng hoạt động bình thường.
- `up` của Blackbox Exporter thể hiện Prometheus scrape được exporter, không chứng minh HTTP probe thành công.
- Cần phân biệt lỗi Web Service với lỗi bản thân Blackbox Exporter.

### 5.2. AS-06 – Web Response Time High

**Mục đích:** Phát hiện Web Service phản hồi chậm kéo dài dù vẫn có thể truy cập.

| Thuộc tính         | Nội dung                                                                                                         |
| ------------------ | ---------------------------------------------------------------------------------------------------------------- |
| Alert ID           | AS-06                                                                                                            |
| Tên tình huống     | Web Response Time High                                                                                           |
| Mô tả              | Web Service vẫn phản hồi HTTP nhưng thời gian phản hồi vượt ngưỡng, có thể ảnh hưởng đến trải nghiệm người dùng. |
| Metric chính       | `probe_http_duration_seconds` hoặc `probe_duration_seconds`                                                      |
| Metric hỗ trợ      | `probe_http_status_code`, `probe_success`                                                                        |
| Trigger Condition  | Thời gian phản hồi vượt ngưỡng Y_WEB_TIME trong F_WEB_TIME phút và probe vẫn thành công.                         |
| Severity           | Warning                                                                                                          |
| Expected Result    | Hệ thống phát hiện tình trạng Web phản hồi chậm và gửi cảnh báo.                                                 |
| Test Method        | Tạo độ trễ phản hồi có kiểm soát trong môi trường thử nghiệm; kiểm tra thời gian probe và trạng thái Alert.      |
| Recovery Condition | Thời gian phản hồi giảm xuống dưới ngưỡng phục hồi đã thống nhất.                                                |
| Related Problem    | PRB06 – Web response time cao                                                                                    |

Lưu ý:

- Cần phân biệt Web Response Time High với Web Service Down.
- Ngưỡng thời gian phản hồi phải thấp hơn probe timeout.
- Nếu probe timeout xảy ra, tình huống có thể chuyển thành probe failure và cần được phân tích cùng AS-05.
- Không nên sử dụng thời gian phản hồi của một lần probe đơn lẻ để kết luận dịch vụ chậm kéo dài.
- Phương pháp tạo độ trễ cần được đánh giá về khả năng thực hiện và mức độ an toàn trước khi đưa vào Test Plan chính thức.

## 6. Database Alert Scenarios

### 6.1. AS-07 – Database Unreachable

**Mục đích:** Phát hiện Database không thể truy cập từ vị trí giám sát.

| Thuộc tính         | Nội dung                                                                                                              |
| ------------------ | --------------------------------------------------------------------------------------------------------------------- |
| Alert ID           | AS-07                                                                                                                 |
| Tên tình huống     | Database Unreachable                                                                                                  |
| Mô tả              | Không thể thiết lập kết nối đến cổng dịch vụ Database hoặc Database không thể cung cấp dữ liệu cho exporter.          |
| Metric chính       | `probe_success` (TCP)                                                                                                 |
| Metric hỗ trợ      | `up` của Database Exporter; SQL Availability Check nếu được triển khai                                                |
| Trigger Condition  | TCP probe đến cổng Database thất bại liên tục trong khoảng thời gian F_DB.                                            |
| Severity           | Critical                                                                                                              |
| Expected Result    | Hệ thống phát hiện Database không thể kết nối và gửi cảnh báo.                                                        |
| Test Method        | Dừng Database hoặc chặn kết nối đến cổng dịch vụ trong môi trường thử nghiệm; kiểm tra kết quả TCP probe và cảnh báo. |
| Recovery Condition | TCP probe thành công trở lại và Alert chuyển sang Resolved.                                                           |
| Related Problem    | PRB07 – Database unreachable                                                                                          |

Lưu ý:

- Phạm vi tối thiểu của tình huống này là kiểm tra TCP đến cổng Database.
- TCP probe thành công không chứng minh Database đăng nhập hoặc thực hiện truy vấn SQL thành công.
- `up = 0` của Database Exporter chỉ thể hiện Prometheus không scrape được exporter.
- Nếu cần xác nhận Database thực sự xử lý được truy vấn, cần bổ sung SQL Availability Check.
- Không bắt buộc SQL Availability Check trong phạm vi tối thiểu của tình huống nếu nhóm chưa thống nhất triển khai.

### 6.2. AS-08 – Database Connections High

**Mục đích:** Phát hiện số lượng kết nối Database tăng cao so với giới hạn hoặc khả năng xử lý.

| Thuộc tính         | Nội dung                                                                                                       |
| ------------------ | -------------------------------------------------------------------------------------------------------------- |
| Alert ID           | AS-08                                                                                                          |
| Tên tình huống     | Database Connections High                                                                                      |
| Mô tả              | Số lượng kết nối Database vượt ngưỡng, có thể khiến các kết nối mới phải chờ hoặc không thể thiết lập kết nối. |
| Metric chính       | Active Connections từ Database Exporter                                                                        |
| Metric hỗ trợ      | Maximum Connections; Connection Usage (%)                                                                      |
| Trigger Condition  | Số lượng kết nối hoặc Connection Usage vượt ngưỡng Y_DB_CONN trong F_DB_CONN phút.                             |
| Severity           | Warning                                                                                                        |
| Expected Result    | Hệ thống phát hiện số lượng kết nối Database cao và gửi cảnh báo.                                              |
| Test Method        | Tạo nhiều kết nối Database có kiểm soát, theo dõi số lượng kết nối và trạng thái Alert.                        |
| Recovery Condition | Số lượng kết nối giảm xuống dưới ngưỡng phục hồi đã thống nhất.                                                |
| Related Problem    | PRB08 – Database connection count cao                                                                          |

Lưu ý:

- Số lượng kết nối cao không đồng nghĩa tất cả kết nối đều đang thực hiện transaction.
- Có thể tồn tại các kết nối Idle.
- Cần phân biệt số lượng kết nối hiện tại với số transaction đang xử lý.
- Tên Metric và cách tính Connection Usage phụ thuộc loại Database và exporter được lựa chọn.
- Không nên tạo tải kết nối vượt quá giới hạn an toàn của môi trường thử nghiệm.

## 7. Monitoring Alert Scenarios

### 7.1. AS-09 – Prometheus Scrape Target Failure

**Mục đích:** Phát hiện Prometheus không thể thu thập Metrics từ một scrape target đã cấu hình.

| Thuộc tính         | Nội dung                                                                                                     |
| ------------------ | ------------------------------------------------------------------------------------------------------------ |
| Alert ID           | AS-09                                                                                                        |
| Tên tình huống     | Prometheus Scrape Target Failure                                                                             |
| Mô tả              | Prometheus không thể scrape Metrics từ target, khiến dữ liệu giám sát của target đó không được cập nhật.     |
| Metric chính       | `up`                                                                                                         |
| Metric hỗ trợ      | `scrape_duration_seconds`, `scrape_samples_scraped`                                                          |
| Trigger Condition  | `up = 0` liên tục trong khoảng thời gian F_SCRAPE đối với target thuộc phạm vi giám sát.                     |
| Severity           | Critical hoặc Warning tùy loại target                                                                        |
| Expected Result    | Prometheus phát hiện scrape thất bại và phát sinh Alert cho target tương ứng.                                |
| Test Method        | Dừng exporter hoặc chặn kết nối đến exporter trong môi trường thử nghiệm; kiểm tra `up` và trạng thái Alert. |
| Recovery Condition | Prometheus scrape target thành công trở lại và Alert chuyển sang Resolved.                                   |
| Related Problem    | PRB09 – Prometheus scrape target fail                                                                        |

Lưu ý:

- `up = 0` chỉ cho biết lần scrape gần nhất thất bại.
- Không được mặc định mọi scrape failure đều là Host Down.
- Nguyên nhân có thể do exporter dừng, lỗi mạng, cấu hình sai hoặc target không phản hồi.
- Nếu chính Prometheus ngừng hoạt động, Prometheus không thể tự phát cảnh báo về sự cố của chính nó.
- Cần có cơ chế giám sát độc lập nếu muốn phát hiện trường hợp toàn bộ Monitoring Server ngừng hoạt động.

### 7.2. AS-10 – Alertmanager Notification Failure

**Mục đích:** Phát hiện lỗi xảy ra trong quá trình gửi notification từ Alertmanager đến receiver.

| Thuộc tính         | Nội dung                                                                                                                          |
| ------------------ | --------------------------------------------------------------------------------------------------------------------------------- |
| Alert ID           | AS-10                                                                                                                             |
| Tên tình huống     | Alertmanager Notification Failure                                                                                                 |
| Mô tả              | Prometheus đã phát sinh Alert nhưng Alertmanager gặp lỗi trong quá trình gửi notification đến receiver.                           |
| Metric chính       | `alertmanager_notifications_failed_total`                                                                                         |
| Metric hỗ trợ      | `alertmanager_notifications_total`                                                                                                |
| Trigger Condition  | Tốc độ tăng của Counter notification thất bại vượt điều kiện đã thống nhất trong khoảng thời gian theo dõi.                       |
| Severity           | Critical hoặc Warning tùy mức độ ảnh hưởng                                                                                        |
| Expected Result    | Hệ thống phát hiện lỗi gửi notification và cung cấp thông tin để người vận hành nhận biết.                                        |
| Test Method        | Mô phỏng lỗi kết nối đến receiver hoặc cấu hình receiver thử nghiệm không gửi được thông báo; kiểm tra Metrics và trạng thái lỗi. |
| Recovery Condition | Alertmanager gửi notification thành công trở lại và tình trạng lỗi không còn xuất hiện theo điều kiện đã thống nhất.              |
| Related Problem    | PRB10 – Alertmanager notification fail                                                                                            |

Lưu ý:

- Cần phân biệt lỗi phát hiện Alert với lỗi gửi notification.
- Prometheus có thể đã chuyển Alert sang Firing nhưng Alertmanager không gửi được thông báo.
- Counter notification thất bại là dữ liệu tích lũy, cần sử dụng `rate()` hoặc `increase()` để phân tích trong một khoảng thời gian.
- Việc gửi notification thành công không chứng minh người nhận cuối cùng đã đọc thông báo.
- Cần kiểm thử end-to-end nếu muốn xác nhận notification thực sự đến kênh nhận.

## 8. Quy tắc Alert Inhibition

Alert Inhibition được sử dụng để hạn chế các cảnh báo thứ cấp khi đã xác định được cảnh báo gốc có khả năng gây ra chúng.

### 8.1. Các quan hệ inhibition dự kiến

| Cảnh báo gốc    | Cảnh báo có thể bị hạn chế  | Điều kiện                                                                             |
| --------------- | --------------------------- | ------------------------------------------------------------------------------------- |
| AS-04 Host Down | AS-05 Web Service Down      | Cùng một máy chủ và có đủ căn cứ xác định Host Down là nguyên nhân gốc.               |
| AS-04 Host Down | AS-07 Database Unreachable  | Cùng một máy chủ và có đủ căn cứ xác định Host Down là nguyên nhân gốc.               |
| AS-04 Host Down | AS-09 Scrape Target Failure | Target scrape thuộc cùng máy chủ và lỗi scrape được xác định là hệ quả của Host Down. |

### 8.2. Nguyên tắc cấu hình

- Cần có một label chung để xác định các target thuộc cùng một máy chủ, ví dụ `host` hoặc `vm`.
- Không nên chỉ dựa vào label `instance` nếu các exporter hoặc probe sử dụng địa chỉ và cổng khác nhau.
- Label dùng cho inhibition phải được gắn nhất quán giữa các Alert liên quan.
- Không nên mặc định mọi Scrape Failure đều do Host Down.
- Các cảnh báo liên quan đến chính Prometheus hoặc Alertmanager không nên bị hạn chế chỉ vì một máy chủ đích gặp sự cố.

Lưu ý:

- Các quan hệ inhibition trên là thiết kế dự kiến, chưa phải cấu hình Alertmanager đã triển khai.
- Cần xác nhận cách gắn label trong cấu hình Prometheus và Blackbox Exporter trước khi hiện thực.

## 9. Bảng tổng hợp Alert Scenarios

### 9.1. Quy ước mức độ ưu tiên

| Mức độ | Ý nghĩa                                                      |
| ------ | ------------------------------------------------------------ |
| Must   | Tình huống bắt buộc cần được hỗ trợ trong phạm vi Prototype. |
| Should | Tình huống nên có nếu đủ thời gian và điều kiện kỹ thuật.    |
| Could  | Tình huống mở rộng, có thể triển khai nếu còn nguồn lực.     |

### 9.2. Bảng tổng hợp

| Alert ID | Tình huống                        | Metric chính                              | PRB liên quan | Priority | Severity dự kiến | Trạng thái |
| -------- | --------------------------------- | ----------------------------------------- | ------------- | -------- | ---------------- | ---------- |
| AS-01    | CPU Usage High                    | CPU Usage (%)                             | PRB01         | Must     | Warning          | Draft      |
| AS-02    | Memory Available Low              | `node_memory_MemAvailable_bytes`          | PRB02         | Must     | Warning          | Draft      |
| AS-03    | Disk Usage High                   | Disk Usage (%)                            | PRB03         | Must     | Warning          | Draft      |
| AS-04    | Host Down                         | `probe_success` (ICMP)                    | PRB04         | Must     | Critical         | Draft      |
| AS-05    | Web Service Down                  | `probe_success` (HTTP)                    | PRB05         | Must     | Critical         | Draft      |
| AS-06    | Web Response Time High            | `probe_http_duration_seconds`             | PRB06         | Should   | Warning          | Draft      |
| AS-07    | Database Unreachable              | `probe_success` (TCP)                     | PRB07         | Must     | Critical         | Draft      |
| AS-08    | Database Connections High         | Active Connections                        | PRB08         | Should   | Warning          | Draft      |
| AS-09    | Prometheus Scrape Target Failure  | `up`                                      | PRB09         | Must     | Critical/Warning | Draft      |
| AS-10    | Alertmanager Notification Failure | `alertmanager_notifications_failed_total` | PRB10         | Should   | Critical/Warning | Draft      |

Ghi chú:

- Priority được kế thừa từ mức ưu tiên của Problem Survey.
- Severity là mức độ nghiêm trọng kỹ thuật dự kiến, cần được xác nhận trong giai đoạn thiết kế.
- Không nên đồng nhất Priority của yêu cầu với Severity của Alert.
- Tên Metric DB cần được xác nhận sau khi chọn Database và exporter.
- `probe_success` được sử dụng cho nhiều loại probe; cần phân biệt bằng `job`, `instance` và các Labels phù hợp.

## 10. Những điểm cần xác nhận

| Nội dung                                    | Trạng thái    | Hướng xử lý                                             |
| ------------------------------------------- | ------------- | ------------------------------------------------------- |
| Ngưỡng CPU Usage và thời gian duy trì       | Chưa chốt     | Xác định trong giai đoạn Baseline                       |
| Ngưỡng RAM Usage và thời gian duy trì       | Chưa chốt     | Xác định trong giai đoạn Baseline                       |
| Ngưỡng Disk Usage                           | Chưa chốt     | Xác định filesystem và ngưỡng phù hợp                   |
| Thời gian phát hiện Host Down               | Chưa chốt     | Thống nhất probe interval, timeout và thời gian duy trì |
| Phương pháp ICMP probe                      | Chưa xác minh | Kiểm tra quyền và cấu hình mạng                         |
| HTTP module và mã trạng thái được chấp nhận | Chưa chốt     | Xác định trong cấu hình Blackbox Exporter               |
| Ngưỡng Web Response Time                    | Chưa chốt     | Xác định thấp hơn probe timeout                         |
| Chọn MySQL hay PostgreSQL                   | Chưa chốt     | Phối hợp Nhóm 2 và PM                                   |
| Metric Database Connections                 | Chưa xác minh | Kiểm tra sau khi chọn DB và exporter                    |
| Phương pháp SQL Availability Check          | Tùy chọn      | Xác nhận có đưa vào Prototype hay không                 |
| Kênh gửi notification                       | Chưa chốt     | Telegram dự kiến, cần xác nhận                          |
| Metric Alertmanager                         | Chưa xác minh | Cấu hình scrape job và kiểm tra endpoint `/metrics`     |
| Label chung phục vụ Alert Inhibition        | Chưa chốt     | Thống nhất label `host` hoặc `vm`                       |
| Phạm vi giám sát Monitoring Server          | Chưa chốt     | Xem xét cơ chế giám sát độc lập                         |

## 11. Tài liệu tham khảo

1. Prometheus – Alerting Rules: https://prometheus.io/docs/prometheus/latest/configuration/alerting_rules/
2. Prometheus – Alerting Overview: https://prometheus.io/docs/alerting/latest/overview/
3. Prometheus – Query Functions: https://prometheus.io/docs/prometheus/latest/querying/functions/
4. Prometheus – Jobs and Instances: https://prometheus.io/docs/concepts/jobs_instances/
5. Alertmanager Documentation: https://prometheus.io/docs/alerting/latest/alertmanager/
6. Alertmanager Configuration: https://prometheus.io/docs/alerting/latest/configuration/
7. Blackbox Exporter Repository: https://github.com/prometheus/blackbox_exporter
8. Node Exporter Repository: https://github.com/prometheus/node_exporter
9. Prometheus MySQL Exporter: https://github.com/prometheus/mysqld_exporter
10. Prometheus PostgreSQL Exporter: https://github.com/prometheus-community/postgres_exporter

Ghi chú:

- Các tài liệu cần được đối chiếu với phiên bản công cụ mà nhóm thực tế sử dụng.
- Các điều kiện và Metric trong tài liệu là đề xuất phân tích, chưa đồng nghĩa đã được triển khai và xác minh.
- Cần bổ sung cấu hình và kết quả kiểm thử thực tế khi chuyển sang giai đoạn Prototype.

---

## 12. Lịch sử cập nhật

| Ngày       | Nội dung                                                                                                                                                                                                                   |
| ---------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 21/11/2026 | Tạo bản nháp Alert Scenarios, xác định 10 tình huống cảnh báo thuộc nhóm Host, Web, Database và Monitoring.                                                                                                                |
| 21/11/2026 | Chuẩn hóa cấu trúc tài liệu theo Metrics Inventory; bổ sung nguyên tắc xây dựng Alert, phân biệt Detection Time và Notification Time, làm rõ TCP/SQL, Host Down/Scrape Failure, Alert Inhibition và các điểm cần xác nhận. |

---

**Tài liệu liên quan:**

- Jira Task: Chưa cập nhật – Xây dựng tình huống cảnh báo.
- Jira Task: SCRUM-6 – Khảo sát bài toán giám sát hệ thống.
- Jira Task: SCRUM-8 – Liệt kê và phân loại Metrics.
- Tài liệu: `problem-survey.md`.
- Tài liệu: `metrics-inventory.md`.
- Tài liệu tiếp theo: Functional Requirements và Non-functional Requirements.
