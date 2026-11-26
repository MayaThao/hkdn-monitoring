# Metrics Inventory – Danh mục chỉ số giám sát

**Dự án:** N4.7 – Xây dựng hệ thống giám sát máy chủ, Cloud và trung tâm dữ liệu  
**Nhóm phụ trách:** Nhóm 1 – Phân tích & Thiết kế  
**Mã Jira:** SCRUM-8  
**Người thực hiện:** Ngô Thảo My  
**Ngày tạo:** 20/11/2026  
**Ngày cập nhật:** 20/11/2026  
**Người review:** Chờ review  
**Trạng thái:** Draft

---

## 1. Mục đích

Tài liệu này xác định các Metrics dự kiến cần thu thập cho prototype N4.7, bao gồm nguồn thu thập, ý nghĩa, loại dữ liệu và các vấn đề mà chúng hỗ trợ phát hiện.

Metrics Inventory là đầu vào cho:

- Thiết kế yêu cầu chức năng và phi chức năng.
- Thiết kế các tình huống cảnh báo (Alert Scenarios).
- Xây dựng cấu hình thu thập Metrics và Dashboard.
- Xây dựng khung kiểm thử của Nhóm 4.

Tài liệu này **không phải danh sách Alert Rules hoàn chỉnh**. Ngưỡng cảnh báo, thời gian duy trì, mức độ nghiêm trọng và kênh thông báo sẽ được xác định trong công việc thiết kế cảnh báo.

## 2. Phạm vi và giả định

### 2.1. Phạm vi Metrics dự kiến

| Nhóm       | Nội dung giám sát                                                        | Nguồn dự kiến                        |
| ---------- | ------------------------------------------------------------------------ | ------------------------------------ |
| Host       | CPU, RAM, filesystem, network, uptime và trạng thái scrape của exporter  | Node Exporter, Prometheus            |
| Web        | Khả năng truy cập HTTP/HTTPS, mã trạng thái và thời gian phản hồi        | Blackbox Exporter                    |
| Database   | Khả năng kết nối, trạng thái exporter và các chỉ số DB cơ bản            | Blackbox Exporter, Database Exporter |
| Monitoring | Tình trạng scrape target, trạng thái cảnh báo và hoạt động gửi thông báo | Prometheus, Alertmanager             |

### 2.2. Giả định và giới hạn

- Prototype dự kiến sử dụng Ubuntu Server làm môi trường máy chủ.
- Prometheus là thành phần thu thập và lưu trữ Metrics; Grafana dùng để truy vấn và trực quan hóa.
- Node Exporter cung cấp Metrics cấp hệ điều hành Linux.
- Blackbox Exporter kiểm tra dịch vụ từ bên ngoài thông qua các probe như HTTP, TCP hoặc ICMP.
- Database đang chờ nhóm thống nhất MySQL hay PostgreSQL. Vì vậy, tên Metrics DB cụ thể chưa được chốt trong tài liệu này.
- Tên Metric và hành vi thực tế cần được xác nhận với phiên bản exporter, cấu hình và môi trường triển khai mà nhóm sử dụng.
- Các Metrics trong tài liệu là danh sách đề xuất ở giai đoạn phân tích, chưa có nghĩa tất cả đã được triển khai và xác minh trên môi trường thực tế.

## 3. Nguyên tắc lựa chọn và đọc Metrics

### 3.1. Metric gốc và chỉ số dẫn xuất

- **Metric gốc (Raw Metric):** dữ liệu được exporter hoặc hệ thống giám sát cung cấp, ví dụ `node_cpu_seconds_total`.
- **Chỉ số dẫn xuất (Derived Indicator):** giá trị được tính từ một hoặc nhiều Metrics gốc, ví dụ CPU Usage (%).

Không nên nhầm tên Metric gốc với chỉ số hiển thị trên Dashboard.

### 3.2. Các loại Metric thường gặp

| Loại      | Ý nghĩa                                                                       | Ví dụ                                                    |
| --------- | ----------------------------------------------------------------------------- | -------------------------------------------------------- |
| Gauge     | Giá trị có thể tăng hoặc giảm theo thời gian                                  | RAM khả dụng                                             |
| Counter   | Bộ đếm tích lũy, thường chỉ tăng và có thể reset khi tiến trình khởi động lại | Tổng byte nhận qua mạng                                  |
| Histogram | Phân phối các giá trị quan sát được theo bucket                               | HTTP request duration của ứng dụng có instrument phù hợp |
| Summary   | Tóm tắt phân phối các giá trị quan sát; quantile thường được tính tại client  | Một số Metric độ trễ từ ứng dụng                         |

Với Counter, thường dùng `rate()` hoặc `increase()` để phân tích tốc độ tăng trong một khoảng thời gian.

Không diễn giải trực tiếp giá trị Counter tích lũy thành tốc độ hoặc phần trăm.

### 3.3. Labels

Labels là các cặp khóa–giá trị gắn với một chuỗi thời gian để phân biệt đối tượng hoặc trạng thái, ví dụ:

- `instance`: địa chỉ hoặc định danh của target.
- `job`: nhóm scrape target.
- `mode`: trạng thái CPU.
- `device`: thiết bị mạng hoặc filesystem.

Labels giúp lọc và nhóm dữ liệu trong PromQL.

Cần tránh tạo Labels có quá nhiều giá trị thay đổi liên tục (High Cardinality), chẳng hạn request ID hoặc user ID riêng lẻ.

### 3.4. Nguyên tắc xác định nguồn dữ liệu

Cần phân biệt ba nguồn dữ liệu chính:

- **Node Exporter:** cung cấp thông tin tài nguyên và trạng thái cấp hệ điều hành Linux.
- **Blackbox Exporter:** kiểm tra khả năng kết nối hoặc phản hồi của dịch vụ từ góc nhìn bên ngoài.
- **Prometheus:** thu thập, lưu trữ dữ liệu và tự tạo một số Metrics phục vụ theo dõi quá trình scrape.

Grafana chỉ truy vấn và trực quan hóa dữ liệu từ Data Source, không trực tiếp thay thế các thành phần thu thập Metrics.

## 4. Host Metrics

Host Metrics giúp theo dõi tình trạng tài nguyên và khả năng hoạt động của máy chủ Ubuntu. Nguồn dự kiến là Node Exporter.

### 4.1. CPU

CPU thực hiện các lệnh và xử lý công việc của hệ điều hành, Web Server, Database và các tiến trình khác.

CPU bận kéo dài có thể làm tăng thời gian xử lý, khiến dịch vụ phản hồi chậm hoặc không đáp ứng kịp yêu cầu.

| Metric gốc               | Loại    | Đơn vị               | Ý nghĩa                                                      |
| ------------------------ | ------- | -------------------- | ------------------------------------------------------------ |
| `node_cpu_seconds_total` | Counter | seconds              | Thời gian CPU tích lũy theo từng core và trạng thái (`mode`) |
| `node_load1`             | Gauge   | Giá trị Load Average | Mức tải trung bình của hệ thống trong 1 phút                 |
| `node_load5`             | Gauge   | Giá trị Load Average | Mức tải trung bình của hệ thống trong 5 phút                 |
| `node_load15`            | Gauge   | Giá trị Load Average | Mức tải trung bình của hệ thống trong 15 phút                |

**Chỉ số dẫn xuất: CPU Usage (%)**

Có thể ước tính bằng phần thời gian CPU không ở trạng thái `idle`.

PromQL tham khảo:

```promql
100 * (1 - avg by (instance) (
  rate(node_cpu_seconds_total{mode="idle"}[5m])
))
```

Giải thích:

- `rate(...[5m])` tính tốc độ tăng trung bình của Counter trong 5 phút.
- Chọn `mode="idle"` để tính phần thời gian CPU nhàn rỗi.
- Lấy `1 - idle rate` để ước tính tỷ lệ CPU không nhàn rỗi.
- Nhân 100 để chuyển thành phần trăm.

Lưu ý:

- Đây là cách tính mức CPU không idle trung bình trên các core.
- CPU Usage cao không đồng nghĩa toàn bộ tài nguyên đang được sử dụng cho công việc hữu ích của ứng dụng.
- Load Average không giống CPU Usage. Load Average phản ánh số lượng tiến trình đang chạy hoặc chờ tài nguyên CPU và một số trạng thái chờ I/O trên Linux.
- Cần xem xét thời gian duy trì, tình trạng dịch vụ và các trạng thái CPU khi phân tích sự cố.

Liên quan: `PRB01 – CPU utilization cao`.

### 4.2. RAM

RAM lưu dữ liệu mà hệ điều hành và ứng dụng đang cần truy cập nhanh.

Khi bộ nhớ khả dụng thấp, máy chủ có thể tăng sử dụng Swap, giảm hiệu năng hoặc gặp tình trạng OOM (Out Of Memory).

| Metric gốc                       | Loại  | Đơn vị | Ý nghĩa                                              |
| -------------------------------- | ----- | ------ | ---------------------------------------------------- |
| `node_memory_MemTotal_bytes`     | Gauge | bytes  | Tổng dung lượng RAM                                  |
| `node_memory_MemAvailable_bytes` | Gauge | bytes  | Ước tính lượng RAM có thể cấp thêm mà không cần swap |
| `node_memory_MemFree_bytes`      | Gauge | bytes  | Lượng RAM hoàn toàn chưa được sử dụng                |
| `node_memory_SwapTotal_bytes`    | Gauge | bytes  | Tổng dung lượng Swap                                 |
| `node_memory_SwapFree_bytes`     | Gauge | bytes  | Dung lượng Swap còn trống                            |

**Chỉ số dẫn xuất: RAM Usage ước tính (%)**

```promql
100 * (
  1 -
  node_memory_MemAvailable_bytes
  /
  node_memory_MemTotal_bytes
)
```

`MemAvailable` thường hữu ích hơn `MemFree` để đánh giá nguy cơ thiếu RAM trên Linux, vì Linux có thể sử dụng bộ nhớ cho Cache và thu hồi một phần khi ứng dụng cần.

Lưu ý:

- RAM Usage cao không tự động có nghĩa là hệ thống lỗi hoặc OOM Killer sẽ được kích hoạt.
- Cần xem thêm `MemAvailable`, Swap, xu hướng theo thời gian và tình trạng dịch vụ.
- Không nên chỉ dựa vào `MemFree` để kết luận máy chủ đang thiếu RAM.

Liên quan: `PRB02 – RAM utilization cao`.

### 4.3. Filesystem / Disk

Filesystem lưu hệ điều hành, ứng dụng, dữ liệu Database, log và file tạm.

Filesystem gần đầy có thể khiến Database không ghi được dữ liệu, dịch vụ không ghi được log hoặc hệ điều hành gặp lỗi khi tạo file.

| Metric gốc                    | Loại  | Đơn vị | Ý nghĩa                                                                  |
| ----------------------------- | ----- | ------ | ------------------------------------------------------------------------ |
| `node_filesystem_size_bytes`  | Gauge | bytes  | Tổng dung lượng filesystem                                               |
| `node_filesystem_avail_bytes` | Gauge | bytes  | Dung lượng còn khả dụng cho người dùng không có quyền đặc biệt           |
| `node_filesystem_free_bytes`  | Gauge | bytes  | Tổng dung lượng block còn trống, có thể bao gồm phần dành riêng cho root |

**Chỉ số dẫn xuất: Disk Usage ước tính (%)**

```promql
100 * (
  1 -
  node_filesystem_avail_bytes
  /
  node_filesystem_size_bytes
)
```

Nên theo dõi cả:

- Disk Usage (%): mức sử dụng tương đối.
- Disk Available (bytes/GB): dung lượng thực tế còn khả dụng.

Lưu ý:

- Cần lọc các filesystem thực sự cần giám sát, ví dụ filesystem chứa `/`, `/var` hoặc nơi lưu dữ liệu DB.
- Không nên mặc định mọi filesystem được exporter báo cáo đều là ổ đĩa cần cảnh báo.
- Cần loại trừ filesystem ảo hoặc tạm thời phù hợp với môi trường.
- `avail_bytes` có thể khác `free_bytes` do phần dung lượng dành riêng cho người dùng đặc biệt hoặc root.
- Disk Usage cao nhưng dung lượng tuyệt đối còn lại lớn có thể ít cấp bách hơn filesystem nhỏ sắp đầy.

Liên quan: `PRB03 – Disk utilization cao`.

### 4.4. Network

Network Metrics giúp theo dõi lưu lượng dữ liệu nhận và gửi qua các network interface.

Có thể dùng để quan sát xu hướng lưu lượng và hỗ trợ điều tra bất thường về kết nối hoặc tải mạng.

| Metric gốc                          | Loại    | Đơn vị  | Ý nghĩa                             |
| ----------------------------------- | ------- | ------- | ----------------------------------- |
| `node_network_receive_bytes_total`  | Counter | bytes   | Tổng số byte đã nhận trên interface |
| `node_network_transmit_bytes_total` | Counter | bytes   | Tổng số byte đã gửi trên interface  |
| `node_network_receive_drop_total`   | Counter | packets | Tổng số packet nhận bị drop         |
| `node_network_transmit_drop_total`  | Counter | packets | Tổng số packet gửi bị drop          |

**Chỉ số dẫn xuất: tốc độ nhận/gửi (bytes/second)**

Tốc độ nhận:

```promql
rate(node_network_receive_bytes_total[5m])
```

Tốc độ gửi:

```promql
rate(node_network_transmit_bytes_total[5m])
```

Lưu ý:

- Cần lọc interface phù hợp, tránh tính cả interface ảo hoặc loopback nếu không thuộc phạm vi.
- Đây là lưu lượng byte, không tự nó cho biết chất lượng kết nối, packet loss hay độ trễ mạng.
- `rate()` trên Counter drop có thể hỗ trợ theo dõi tốc độ packet bị drop.
- Network Utilization (%) chỉ tính được khi biết băng thông của interface hoặc đường truyền tương ứng.
- Nếu cần kiểm tra khả năng kết nối dịch vụ, dùng probe phù hợp của Blackbox Exporter.

### 4.5. Uptime

Uptime thể hiện khoảng thời gian máy chủ đã hoạt động kể từ lần khởi động gần nhất.

| Metric gốc               | Loại  | Đơn vị                   | Ý nghĩa                               |
| ------------------------ | ----- | ------------------------ | ------------------------------------- |
| `node_boot_time_seconds` | Gauge | Unix timestamp (seconds) | Thời điểm hệ thống khởi động gần nhất |

**Chỉ số dẫn xuất: Uptime (seconds)**

```promql
time() - node_boot_time_seconds
```

Lưu ý:

- Uptime được tính từ thời điểm khởi động hệ điều hành.
- Uptime thấp có thể cho thấy máy chủ vừa khởi động lại, nhưng không tự chứng minh nguyên nhân restart.
- Cần kết hợp với log hệ thống hoặc thông tin sự kiện nếu cần xác định lý do khởi động lại.

Uptime là chỉ số hỗ trợ đánh giá trạng thái Host, không thay thế kiểm tra khả năng truy cập máy chủ.

### 4.6. Host / Exporter Availability

Prometheus tự tạo Metric `up` cho mỗi scrape target:

- `up = 1`: lần scrape gần nhất thành công.
- `up = 0`: lần scrape gần nhất thất bại.

`up` không phải Metric do Node Exporter cung cấp. Đây là Metric do Prometheus tạo ra dựa trên kết quả scrape.

Lưu ý:

- `up = 0` không đủ để kết luận máy chủ vật lý hoặc máy ảo đã tắt.
- Nguyên nhân có thể là exporter dừng, lỗi mạng, sai cấu hình hoặc Prometheus không truy cập được target.
- Cần phân biệt trạng thái scrape của Node Exporter với khả năng truy cập thực tế của máy chủ.
- Có thể kết hợp thêm ICMP hoặc TCP probe bằng Blackbox Exporter để có tín hiệu độc lập về khả năng kết nối.

Liên quan:

- `PRB04 – Host down`.
- `PRB09 – Prometheus scrape target fail`.

Cần kết hợp nhiều tín hiệu để phân biệt Host Down với Scrape Failure.

## 5. Web Service Metrics

Web Metrics giúp kiểm tra dịch vụ HTTP/HTTPS từ góc nhìn bên ngoài, thay vì chỉ biết máy chủ còn hoạt động.

Nguồn dự kiến: Blackbox Exporter với HTTP probe.

| Metric                        | Loại  | Đơn vị           | Ý nghĩa                                  |
| ----------------------------- | ----- | ---------------- | ---------------------------------------- |
| `probe_success`               | Gauge | 0/1              | Probe thành công hay thất bại            |
| `probe_duration_seconds`      | Gauge | seconds          | Tổng thời gian thực hiện probe           |
| `probe_http_status_code`      | Gauge | HTTP status code | Mã trạng thái HTTP nhận được             |
| `probe_http_duration_seconds` | Gauge | seconds          | Thời gian theo từng phase của HTTP probe |

Giải thích:

- `probe_success = 1`: probe đạt điều kiện thành công theo module đã cấu hình.
- `probe_success = 0`: probe thất bại.
- `probe_http_status_code`: hỗ trợ xác định server trả về mã HTTP nào.
- `probe_http_duration_seconds` có label `phase`, giúp xem thời gian ở các giai đoạn như resolve, connect, TLS, processing và transfer tùy phiên bản hoặc cấu hình.

Lưu ý:

- Điều kiện để `probe_success = 1` phụ thuộc vào cấu hình module, chẳng hạn các mã HTTP được chấp nhận.
- HTTP 200 không nhất thiết chứng minh mọi chức năng nghiệp vụ của ứng dụng đều hoạt động đúng.
- Nếu cần kiểm tra nội dung hoặc luồng nghiệp vụ, cần thiết kế health endpoint hoặc kiểm thử ứng dụng phù hợp.
- Khi probe thất bại, các Metric về thời gian phản hồi có thể không có giá trị hữu ích để phân tích độ trễ.

Liên quan:

- `PRB05 – Web service down`.
- `PRB06 – Web response time cao`.

## 6. Database Metrics

Database cụ thể (MySQL hoặc PostgreSQL) chưa được nhóm chốt. Vì vậy, phần này xác định loại dữ liệu cần giám sát trước; tên Metric chính xác sẽ bổ sung sau khi chọn DB và exporter.

### 6.1. Nhóm dữ liệu cần giám sát

| Nhóm dữ liệu                         | Cách thu thập dự kiến                                      | Mục đích                                        |
| ------------------------------------ | ---------------------------------------------------------- | ----------------------------------------------- |
| Khả năng kết nối TCP                 | Blackbox Exporter TCP probe                                | Kiểm tra cổng DB có thể kết nối từ vị trí probe |
| Trạng thái exporter / DB metrics     | Database Exporter và scrape qua Prometheus                 | Xác nhận exporter lấy được dữ liệu DB           |
| Số lượng kết nối                     | Metric do exporter DB cung cấp                             | Theo dõi mức sử dụng connection                 |
| Mức sử dụng connection               | Chỉ số dẫn xuất từ số kết nối hiện tại và giới hạn kết nối | Đánh giá mức độ sử dụng connection              |
| Hoạt động truy vấn                   | Metric do exporter DB cung cấp, tùy DB và collector        | Theo dõi hoạt động của Database                 |
| Dung lượng Database                  | Metric phù hợp từ exporter hoặc truy vấn DB                | Theo dõi xu hướng tăng dung lượng               |
| Truy vấn kiểm tra đơn giản (nếu cần) | Health check hoặc SQL query phù hợp                        | Xác nhận DB có thể thực hiện thao tác truy vấn  |

### 6.2. Phân biệt các mức kiểm tra Database

Cần phân biệt ba mức kiểm tra:

1. **TCP probe:** xác nhận có thể thiết lập kết nối TCP đến cổng DB; không chứng minh đăng nhập hoặc truy vấn thành công.
2. **Database Exporter:** exporter kết nối DB để đọc số liệu; scrape thành công cho thấy exporter cung cấp được Metrics, nhưng không thay thế toàn bộ kiểm thử nghiệp vụ.
3. **Query / Health Check:** thực hiện truy vấn hoặc kiểm tra ứng dụng cụ thể để xác nhận khả năng xử lý yêu cầu.

Ví dụ:

- MySQL thường sử dụng TCP port `3306`.
- PostgreSQL thường sử dụng TCP port `5432`.

### 6.3. Các chỉ số dự kiến

| Nhóm chỉ số                    | Ý nghĩa                                       | Nguồn dự kiến                    | Trạng thái   |
| ------------------------------ | --------------------------------------------- | -------------------------------- | ------------ |
| Database TCP Availability      | Khả năng kết nối đến cổng DB                  | Blackbox Exporter                | Dự kiến      |
| Database Exporter Availability | Trạng thái scrape của DB Exporter             | Prometheus `up`                  | Dự kiến      |
| Active Connections             | Số lượng kết nối DB đang hoạt động            | Database Exporter                | Chờ xác minh |
| Connection Usage (%)           | Tỷ lệ kết nối đang sử dụng so với giới hạn    | Chỉ số dẫn xuất                  | Chờ xác minh |
| Query Activity                 | Hoạt động truy vấn của DB                     | Database Exporter                | Chờ xác minh |
| Query / Transaction Duration   | Thời gian thực hiện truy vấn hoặc transaction | Exporter hoặc công cụ bổ sung    | Chờ xác minh |
| Database Size                  | Dung lượng dữ liệu Database                   | Exporter hoặc truy vấn DB        | Chờ xác minh |
| SQL Availability Check         | Kết quả truy vấn kiểm tra đơn giản            | Script hoặc công cụ kiểm tra SQL | Tùy chọn     |

Lưu ý:

- Tên Metric cụ thể, cách xác thực và quyền truy cập exporter sẽ được cập nhật sau khi nhóm quyết định MySQL hoặc PostgreSQL.
- Không giả định tất cả Database Exporter đều cung cấp đầy đủ các chỉ số kể trên theo cấu hình mặc định.
- Một số collector có thể cần được bật thêm hoặc cần quyền truy cập phù hợp.
- Database Size và Disk Usage là hai khái niệm khác nhau. Database Size thể hiện dung lượng dữ liệu DB, còn Disk Usage thể hiện mức sử dụng filesystem chứa dữ liệu đó.
- SQL Availability Check cần thực hiện truy vấn thực tế; TCP probe không thể thay thế kiểm tra này.

Liên quan:

- `PRB07 – Database unreachable`.
- `PRB08 – Database connection count cao`.

## 7. Monitoring System Metrics

Bản thân hệ thống giám sát cũng cần được theo dõi để phát hiện trường hợp Prometheus không scrape được target, cảnh báo không hoạt động hoặc Alertmanager gặp lỗi gửi thông báo.

### 7.1. Prometheus Metrics

| Metric                    | Loại  | Đơn vị / Giá trị                  | Ý nghĩa                                       |
| ------------------------- | ----- | --------------------------------- | --------------------------------------------- |
| `up`                      | Gauge | 0/1                               | Trạng thái scrape gần nhất của từng target    |
| `scrape_duration_seconds` | Gauge | seconds                           | Thời gian thực hiện scrape                    |
| `scrape_samples_scraped`  | Gauge | samples                           | Số samples thu thập trong lần scrape          |
| `ALERTS`                  | Gauge | 1 khi chuỗi cảnh báo đang tồn tại | Trạng thái các Alert đang Pending hoặc Firing |

Lưu ý:

- `up` được Prometheus tự tạo cho từng scrape target.
- `scrape_duration_seconds` và `scrape_samples_scraped` hỗ trợ theo dõi quá trình thu thập dữ liệu.
- `ALERTS` là chuỗi thời gian do Prometheus tạo để thể hiện trạng thái Alert.
- Khi Alert đang Pending hoặc Firing, giá trị của chuỗi `ALERTS` tương ứng là `1`.
- Khi Alert không còn ở trạng thái hoạt động, chuỗi thời gian tương ứng sẽ biến mất hoặc trở thành stale, không nên hiểu rằng nó luôn chuyển về `0`.
- Cần phân biệt trạng thái Alert với trạng thái gửi thông báo. Alert Firing không đồng nghĩa thông báo đã được gửi thành công.

### 7.2. Alertmanager Metrics

| Metric                                    | Loại    | Đơn vị        | Ý nghĩa                                                                |
| ----------------------------------------- | ------- | ------------- | ---------------------------------------------------------------------- |
| `alertmanager_notifications_total`        | Counter | notifications | Tổng số notification được xử lý hoặc gửi theo định nghĩa của phiên bản |
| `alertmanager_notifications_failed_total` | Counter | notifications | Tổng số notification gửi thất bại theo định nghĩa của phiên bản        |

Lưu ý:

- Prometheus cần được cấu hình scrape Alertmanager để thu thập các Metrics này.
- Có thể dùng `rate()` hoặc `increase()` để theo dõi số lượng notification thất bại trong một khoảng thời gian.
- Counter lỗi tăng cho thấy có notification gửi thất bại, không đồng nghĩa Prometheus không phát hiện được Alert.
- Các Metrics này không chứng minh người nhận cuối cùng đã nhận và đọc thông báo.
- Việc xác nhận thông báo đến người nhận cuối cùng vẫn cần kiểm thử end-to-end.

Liên quan:

- `PRB09 – Prometheus scrape target fail`.
- `PRB10 – Alertmanager notification fail`.

## 8. Bảng tổng hợp Metrics và vấn đề liên quan

### 8.1. Quy ước phân loại

- **Core:** Metrics cần thiết để hỗ trợ các tình huống và tiêu chí nghiệm thu bắt buộc của prototype.
- **Supporting:** Metrics hỗ trợ chẩn đoán, cung cấp thêm thông tin hoặc phục vụ các tình huống Should Have.
- **Optional:** Metrics mở rộng, chỉ triển khai nếu có đủ thời gian và điều kiện kỹ thuật.

Trạng thái xác minh:

- **Chưa xác minh trên môi trường:** mới được đề xuất trong giai đoạn phân tích.
- **Đã xác minh trên môi trường:** đã kiểm tra endpoint `/metrics`, tên Metric và hành vi thực tế; cần ghi ngày và phiên bản tương ứng.

### 8.2. Bảng tổng hợp

| MET ID      | OBJ ID       | Metric / Chỉ số                           | Loại      | Đơn vị / Giá trị    | Ý nghĩa                                        | Nguồn                      | Ưu tiên    | PRB liên quan         | Trạng thái xác minh |
| ----------- | ------------ | ----------------------------------------- | --------- | ------------------- | ---------------------------------------------- | -------------------------- | ---------- | --------------------- | ------------------- |
| MET-CPU-01  | OBJ01        | `node_cpu_seconds_total`                  | Counter   | seconds             | Thời gian CPU tích lũy theo core và mode       | Node Exporter              | Core       | PRB01                 | Chưa xác minh       |
| MET-CPU-02  | OBJ01        | CPU Usage (%)                             | Derived   | %                   | Tỷ lệ CPU không idle                           | Prometheus / PromQL        | Core       | PRB01                 | Chưa xác minh       |
| MET-CPU-03  | OBJ01        | `node_load1`                              | Gauge     | Load Average        | Tải trung bình trong 1 phút                    | Node Exporter              | Supporting | PRB01                 | Chưa xác minh       |
| MET-CPU-04  | OBJ01        | `node_load5`                              | Gauge     | Load Average        | Tải trung bình trong 5 phút                    | Node Exporter              | Supporting | PRB01                 | Chưa xác minh       |
| MET-CPU-05  | OBJ01        | `node_load15`                             | Gauge     | Load Average        | Tải trung bình trong 15 phút                   | Node Exporter              | Supporting | PRB01                 | Chưa xác minh       |
| MET-MEM-01  | OBJ01        | `node_memory_MemTotal_bytes`              | Gauge     | bytes               | Tổng dung lượng RAM                            | Node Exporter              | Core       | PRB02                 | Chưa xác minh       |
| MET-MEM-02  | OBJ01        | `node_memory_MemAvailable_bytes`          | Gauge     | bytes               | RAM ước tính có thể cấp thêm mà không cần swap | Node Exporter              | Core       | PRB02                 | Chưa xác minh       |
| MET-MEM-03  | OBJ01        | RAM Usage (%)                             | Derived   | %                   | Tỷ lệ RAM sử dụng ước tính                     | Prometheus / PromQL        | Core       | PRB02                 | Chưa xác minh       |
| MET-MEM-04  | OBJ01        | `node_memory_MemFree_bytes`               | Gauge     | bytes               | RAM hoàn toàn chưa sử dụng                     | Node Exporter              | Supporting | PRB02                 | Chưa xác minh       |
| MET-MEM-05  | OBJ01        | `node_memory_SwapTotal_bytes`             | Gauge     | bytes               | Tổng dung lượng Swap                           | Node Exporter              | Supporting | PRB02                 | Chưa xác minh       |
| MET-MEM-06  | OBJ01        | `node_memory_SwapFree_bytes`              | Gauge     | bytes               | Dung lượng Swap còn trống                      | Node Exporter              | Supporting | PRB02                 | Chưa xác minh       |
| MET-DISK-01 | OBJ01        | `node_filesystem_size_bytes`              | Gauge     | bytes               | Tổng dung lượng filesystem                     | Node Exporter              | Core       | PRB03                 | Chưa xác minh       |
| MET-DISK-02 | OBJ01        | `node_filesystem_avail_bytes`             | Gauge     | bytes               | Dung lượng filesystem còn khả dụng             | Node Exporter              | Core       | PRB03                 | Chưa xác minh       |
| MET-DISK-03 | OBJ01        | Disk Usage (%)                            | Derived   | %                   | Tỷ lệ dung lượng filesystem đã sử dụng         | Prometheus / PromQL        | Core       | PRB03                 | Chưa xác minh       |
| MET-DISK-04 | OBJ01        | `node_filesystem_free_bytes`              | Gauge     | bytes               | Dung lượng block còn trống                     | Node Exporter              | Supporting | PRB03                 | Chưa xác minh       |
| MET-NET-01  | OBJ01        | `node_network_receive_bytes_total`        | Counter   | bytes               | Tổng số byte nhận                              | Node Exporter              | Core       | Hỗ trợ giám sát Host  | Chưa xác minh       |
| MET-NET-02  | OBJ01        | `node_network_transmit_bytes_total`       | Counter   | bytes               | Tổng số byte gửi                               | Node Exporter              | Core       | Hỗ trợ giám sát Host  | Chưa xác minh       |
| MET-NET-03  | OBJ01        | Receive Throughput                        | Derived   | bytes/second        | Tốc độ nhận dữ liệu                            | Prometheus / PromQL        | Core       | Hỗ trợ giám sát Host  | Chưa xác minh       |
| MET-NET-04  | OBJ01        | Transmit Throughput                       | Derived   | bytes/second        | Tốc độ gửi dữ liệu                             | Prometheus / PromQL        | Core       | Hỗ trợ giám sát Host  | Chưa xác minh       |
| MET-NET-05  | OBJ01        | `node_network_receive_drop_total`         | Counter   | packets             | Tổng số packet nhận bị drop                    | Node Exporter              | Supporting | Hỗ trợ giám sát Host  | Chưa xác minh       |
| MET-NET-06  | OBJ01        | `node_network_transmit_drop_total`        | Counter   | packets             | Tổng số packet gửi bị drop                     | Node Exporter              | Supporting | Hỗ trợ giám sát Host  | Chưa xác minh       |
| MET-AVL-01  | OBJ01        | `node_boot_time_seconds`                  | Gauge     | Unix timestamp      | Thời điểm hệ thống khởi động gần nhất          | Node Exporter              | Supporting | Hỗ trợ giám sát Host  | Chưa xác minh       |
| MET-AVL-02  | OBJ01        | Uptime                                    | Derived   | seconds             | Thời gian từ lần khởi động gần nhất            | Prometheus / PromQL        | Supporting | Hỗ trợ giám sát Host  | Chưa xác minh       |
| MET-AVL-03  | OBJ01        | `probe_success` (ICMP/TCP)                | Gauge     | 0/1                 | Kết quả kiểm tra khả năng kết nối Host         | Blackbox Exporter          | Core       | PRB04                 | Chưa xác minh       |
| MET-AVL-04  | OBJ01, OBJ04 | `up`                                      | Gauge     | 0/1                 | Trạng thái scrape gần nhất của target          | Prometheus                 | Core       | PRB09; hỗ trợ PRB04   | Chưa xác minh       |
| MET-WEB-01  | OBJ02        | `probe_success` (HTTP)                    | Gauge     | 0/1                 | Kết quả HTTP probe                             | Blackbox Exporter          | Core       | PRB05                 | Chưa xác minh       |
| MET-WEB-02  | OBJ02        | `probe_http_status_code`                  | Gauge     | HTTP status code    | Mã trạng thái HTTP nhận được                   | Blackbox Exporter          | Supporting | PRB05                 | Chưa xác minh       |
| MET-WEB-03  | OBJ02        | `probe_duration_seconds`                  | Gauge     | seconds             | Tổng thời gian thực hiện probe                 | Blackbox Exporter          | Supporting | PRB06                 | Chưa xác minh       |
| MET-WEB-04  | OBJ02        | `probe_http_duration_seconds`             | Gauge     | seconds             | Thời gian theo từng phase HTTP probe           | Blackbox Exporter          | Supporting | PRB06                 | Chưa xác minh       |
| MET-DB-01   | OBJ03        | `probe_success` (TCP)                     | Gauge     | 0/1                 | Kết quả TCP probe đến cổng DB                  | Blackbox Exporter          | Core       | PRB07                 | Chưa xác minh       |
| MET-DB-02   | OBJ03        | `up` (Database Exporter)                  | Gauge     | 0/1                 | Trạng thái scrape Database Exporter            | Prometheus                 | Supporting | PRB07                 | Chưa xác minh       |
| MET-DB-03   | OBJ03        | SQL Availability Check                    | Gauge     | 0/1                 | Kết quả truy vấn SQL kiểm tra đơn giản         | Script / SQL Check         | Optional   | PRB07                 | Chưa xác minh       |
| MET-DB-04   | OBJ03        | Active Connections                        | To Verify | connections         | Số lượng kết nối DB đang hoạt động             | Database Exporter          | Supporting | PRB08                 | Chưa xác minh       |
| MET-DB-05   | OBJ03        | Connection Usage (%)                      | Derived   | %                   | Tỷ lệ kết nối đang sử dụng so với giới hạn     | Prometheus / PromQL        | Supporting | PRB08                 | Chưa xác minh       |
| MET-DB-06   | OBJ03        | Query Activity                            | To Verify | Theo Metric thực tế | Hoạt động truy vấn DB                          | Database Exporter          | Supporting | Hỗ trợ giám sát DB    | Chưa xác minh       |
| MET-DB-07   | OBJ03        | Query / Transaction Duration              | To Verify | seconds             | Thời gian truy vấn hoặc transaction            | Exporter / Công cụ bổ sung | Optional   | Hỗ trợ giám sát DB    | Chưa xác minh       |
| MET-DB-08   | OBJ03        | Database Size                             | To Verify | bytes               | Dung lượng dữ liệu Database                    | Exporter / SQL Query       | Supporting | Hỗ trợ theo dõi PRB03 | Chưa xác minh       |
| MET-MON-01  | OBJ04        | `scrape_duration_seconds`                 | Gauge     | seconds             | Thời gian thực hiện scrape                     | Prometheus                 | Supporting | PRB09                 | Chưa xác minh       |
| MET-MON-02  | OBJ04        | `scrape_samples_scraped`                  | Gauge     | samples             | Số samples thu thập trong lần scrape           | Prometheus                 | Supporting | PRB09                 | Chưa xác minh       |
| MET-MON-03  | OBJ04        | `alertmanager_notifications_total`        | Counter   | notifications       | Tổng số notification được xử lý hoặc gửi       | Alertmanager               | Supporting | PRB10                 | Chưa xác minh       |
| MET-MON-04  | OBJ04        | `ALERTS`                                  | Gauge     | 1 khi active        | Trạng thái Alert Pending/Firing                | Prometheus                 | Supporting | Hỗ trợ theo dõi Alert | Chưa xác minh       |
| MET-MON-05  | OBJ04        | `alertmanager_notifications_failed_total` | Counter   | notifications       | Tổng số notification gửi thất bại              | Alertmanager               | Supporting | PRB10                 | Chưa xác minh       |

Ghi chú:

- `up` được dùng để đánh giá trạng thái scrape target, không được xem là bằng chứng duy nhất chứng minh Host đã tắt.
- `probe_success` với ICMP/TCP hỗ trợ kiểm tra khả năng kết nối độc lập với Node Exporter.
- `probe_success` của HTTP và TCP có cùng tên Metric nhưng thuộc các target/job và module khác nhau; cần phân biệt bằng Labels.
- Các Metric Database có trạng thái `To Verify` cần được xác nhận sau khi nhóm chọn DB và exporter.
- Database Size không thay thế Disk Usage. Disk Usage vẫn là chỉ số trực tiếp để theo dõi dung lượng filesystem.
- `ALERTS` có giá trị `1` khi chuỗi Alert tương ứng đang hoạt động; khi không còn hoạt động, chuỗi thời gian sẽ biến mất hoặc stale.
- Các Metric Network dạng Counter cần sử dụng `rate()` hoặc `increase()` khi muốn phân tích tốc độ hoặc mức tăng trong khoảng thời gian.

## 9. Những điểm cần xác nhận

| Nội dung                               | Trạng thái                 | Hướng xử lý                                                  |
| -------------------------------------- | -------------------------- | ------------------------------------------------------------ |
| Chọn MySQL hay PostgreSQL              | Chưa chốt                  | Phối hợp Nhóm 2 và PM trước khi hoàn thiện tên Metric DB     |
| Phiên bản Node Exporter                | Chưa chốt                  | Ghi nhận khi dựng môi trường và kiểm tra endpoint `/metrics` |
| Phiên bản Blackbox Exporter            | Chưa chốt                  | Kiểm tra Metric và Labels theo phiên bản triển khai          |
| Phiên bản Prometheus và Alertmanager   | Chưa chốt                  | Ghi nhận khi dựng môi trường                                 |
| Filesystem nào thuộc phạm vi           | Chưa chốt                  | Xác định theo cấu hình VM thực tế                            |
| Network interface nào thuộc phạm vi    | Chưa chốt                  | Xác định theo cấu hình VM thực tế                            |
| Số lượng Host/Service target tối thiểu | Chưa chốt                  | Thống nhất trong yêu cầu và thiết kế                         |
| Ngưỡng cảnh báo và thời gian duy trì   | Ngoài phạm vi tài liệu này | Xác định trong Alert Scenarios / Alert Rules                 |
| Metric DB chi tiết và quyền exporter   | Chưa chốt                  | Cập nhật sau khi chọn DB                                     |
| Khả năng sử dụng ICMP probe            | Chưa xác minh              | Kiểm tra quyền và cấu hình mạng của Blackbox Exporter        |
| Các Metric Alertmanager                | Chưa xác minh              | Cấu hình scrape job và kiểm tra endpoint `/metrics`          |

## 10. Tài liệu tham khảo

Các đường dẫn dưới đây là tài liệu chính thức hoặc repository của dự án tương ứng. Khi chốt phiên bản triển khai, cần đối chiếu lại nội dung với đúng phiên bản sử dụng.

1. Prometheus – Metric types: https://prometheus.io/docs/concepts/metric_types/
2. Prometheus – Query functions (`rate`, `increase`): https://prometheus.io/docs/prometheus/latest/querying/functions/
3. Prometheus – Jobs and instances / scraping concepts: https://prometheus.io/docs/concepts/jobs_instances/
4. Prometheus – Instrumentation practices: https://prometheus.io/docs/practices/instrumentation/
5. Prometheus – Node Exporter guide: https://prometheus.io/docs/guides/node-exporter/
6. Node Exporter repository: https://github.com/prometheus/node_exporter
7. Blackbox Exporter repository: https://github.com/prometheus/blackbox_exporter
8. Prometheus – Alerting rules: https://prometheus.io/docs/prometheus/latest/configuration/alerting_rules/
9. Alertmanager documentation: https://prometheus.io/docs/alerting/latest/alertmanager/
10. Prometheus MySQL Exporter: https://github.com/prometheus/mysqld_exporter
11. Prometheus PostgreSQL Exporter: https://github.com/prometheus-community/postgres_exporter

Ghi chú:

- Các tài liệu cần được đối chiếu với phiên bản công cụ mà nhóm thực tế sử dụng trong giai đoạn triển khai.
- Tên Metric cụ thể của Database cần được kiểm tra trên endpoint `/metrics` sau khi chọn DB và exporter.
- Các Metric được liệt kê trong tài liệu là đề xuất phân tích, không đồng nghĩa tất cả đã được xác minh trong môi trường thực tế.

---

## 11. Lịch sử cập nhật

| Ngày       | Nội dung                                                                                                                                                                                     |
| ---------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 19/11/2026 | Tạo bản nháp Metrics Inventory, xác định các nhóm Host, Web, Database và Monitoring                                                                                                          |
| 20/11/2026 | Rà soát và chuẩn hóa phân loại Metrics; bổ sung CPU Load, Uptime, Alert State; làm rõ sự khác nhau giữa Host Down và Scrape Failure; cập nhật bảng tổng hợp Metrics và các điểm cần xác minh |

---

**Tài liệu liên quan:**

- Jira Task: SCRUM-8 – Liệt kê và phân loại Metrics.
- Jira Task: SCRUM-6 – Khảo sát bài toán giám sát hệ thống.
- Tài liệu: `problem-survey.md`.
- Tài liệu tiếp theo: Alert Scenarios – Xây dựng tình huống cảnh báo.
- Tài liệu yêu cầu chức năng, phi chức năng và kế hoạch kiểm thử của dự án N4.7.
