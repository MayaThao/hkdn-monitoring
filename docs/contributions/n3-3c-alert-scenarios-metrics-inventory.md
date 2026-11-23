# SCRUM-34 -- Phân tích Alert Scenarios và Metrics Inventory

## 1. Thông tin công việc

-   **Jira:** SCRUM-34
-   **Tên task:** \[N3-3C\] task-1: Phân tích Alert Scenarios và Metrics
    Inventory
-   **Người thực hiện:** N3-3C
-   **Mục tiêu:** Xây dựng bảng mapping giữa tình huống cảnh báo,
    metric, điều kiện kích hoạt, mức độ ưu tiên và phương pháp kiểm thử.
    Tài liệu này làm cơ sở cho các task triển khai Alertmanager,
    Prometheus Alert Rules và thông báo Telegram.

> **Phạm vi:** Đây là tài liệu phân tích và đề xuất. Các ngưỡng cảnh
> báo, thời gian duy trì và severity cần được nhóm thống nhất trước khi
> đưa vào cấu hình chính thức. Những metric chưa được triển khai được
> ghi nhận rõ ràng, không xem là lỗi của hệ thống hiện tại.

## 2. Môi trường và phạm vi xác minh

-   Prometheus: `http://100.93.18.76:9090`
-   Prometheus target VM2 Node Exporter: `100.96.202.53:9100`
-   Job: `vm2-webserver`
-   Máy chủ Prometheus: Ubuntu Server dùng chung của nhóm.
-   Database dự kiến: MySQL (chưa triển khai tại thời điểm kiểm tra).
-   Blackbox Exporter: Chưa xác minh được metric probe; `probe_success`
    và `probe_duration_seconds` hiện không có dữ liệu.
-   Alertmanager: Chưa triển khai tại thời điểm kiểm tra.

## 3. Metrics Inventory -- Kết quả kiểm tra thực tế

Các truy vấn được thực hiện trên Prometheus Graph. Kết quả dưới đây phản
ánh trạng thái tại thời điểm kiểm tra ngày 23/11/2026.

  -------------------------------------------------------------------------------------------------------
  Nhóm              Metric                                      Kết quả kiểm tra        Nhận xét
  ----------------- ------------------------------------------- ----------------------- -----------------
  CPU               `node_cpu_seconds_total`                    Có series từ            Đã xác minh
                                                                `100.96.202.53:9100`,   
                                                                job `vm2-webserver`; có 
                                                                các mode CPU            

  RAM               `node_memory_MemAvailable_bytes`            Có series từ VM2        Đã xác minh

  RAM               `node_memory_MemTotal_bytes`                Có series từ VM2        Đã xác minh; có
                                                                                        thể kết hợp với
                                                                                        MemAvailable

  Disk              `node_filesystem_avail_bytes`               Có series cho `/`,      Đã xác minh
                                                                `/boot`, `/tmp`         

  Disk              `node_filesystem_size_bytes`                Có series cho `/`,      Đã xác minh; có
                                                                `/boot`, `/tmp`         thể kết hợp với
                                                                                        filesystem avail

  Web               `probe_success`                             Empty query result      Chưa có dữ liệu
                                                                                        probe; cần kiểm
                                                                                        tra Blackbox
                                                                                        Exporter/target

  Web performance   `probe_duration_seconds`                    Empty query result      Chưa có dữ liệu
                                                                                        probe; cần kiểm
                                                                                        tra Blackbox
                                                                                        Exporter/target

  Database          `mysql_up`                                  Chưa kiểm tra được do   Chưa khả dụng ở
                                                                MySQL/Exporter chưa     thời điểm kiểm
                                                                triển khai              tra

  Database          `mysql_global_status_threads_connected`     Chưa kiểm tra được do   Chưa khả dụng ở
                                                                MySQL/Exporter chưa     thời điểm kiểm
                                                                triển khai              tra

  Monitoring        `up{job="vm2-webserver"}`                   Có series, giá trị trả  Prometheus scrape
                                                                về `1`                  VM2 Node Exporter
                                                                                        thành công tại
                                                                                        thời điểm kiểm
                                                                                        tra

  Alertmanager      `alertmanager_notifications_failed_total`   Alertmanager chưa triển Chưa khả dụng ở
                                                                khai                    thời điểm kiểm
                                                                                        tra
  -------------------------------------------------------------------------------------------------------

### 3.1. Chi tiết các metric đã xác minh

**CPU**

Metric `node_cpu_seconds_total` có dữ liệu với: -
`instance="100.96.202.53:9100"` - `job="vm2-webserver"` - CPU `0` và
`1` - Các mode gồm `idle`, `iowait`, `irq`, `nice`, `softirq`, `steal`,
`system`, `user`.

PromQL đề xuất để tính CPU busy percentage:

``` promql
100 * (1 - avg by (instance) (
  rate(node_cpu_seconds_total{mode="idle"}[5m])
))
```

**RAM**

Hai metric `node_memory_MemAvailable_bytes` và
`node_memory_MemTotal_bytes` đều có series từ VM2.

PromQL đề xuất để tính phần trăm RAM khả dụng:

``` promql
100 * (
  node_memory_MemAvailable_bytes
  /
  node_memory_MemTotal_bytes
)
```

**Disk**

Hai metric `node_filesystem_avail_bytes` và `node_filesystem_size_bytes`
có dữ liệu cho: - `/` -- `/dev/mapper/ubuntu--vg-ubuntu--lv`, `ext4` -
`/boot` -- `/dev/sda2`, `ext4` - `/tmp` -- `tmpfs`

Đề xuất ban đầu là giám sát phân vùng gốc `/`. Cần thống nhất phạm vi
mountpoint và ngưỡng với nhóm trước khi cấu hình chính thức.

PromQL đề xuất để tính phần trăm dung lượng còn trống của `/`:

``` promql
100 * (
  node_filesystem_avail_bytes{mountpoint="/", fstype="ext4"}
  /
  node_filesystem_size_bytes{mountpoint="/", fstype="ext4"}
)
```

**Scrape status**

Truy vấn:

``` promql
up{job="vm2-webserver"}
```

trả về giá trị `1`. Điều này xác nhận Prometheus scrape target Node
Exporter của VM2 thành công tại thời điểm kiểm tra.

Lưu ý: `up == 0` thể hiện Prometheus không scrape được target tương ứng;
không nên mặc định diễn giải là toàn bộ host đã mất kết nối. Muốn xác
định host unreachable độc lập, cần cân nhắc kiểm tra ICMP bằng Blackbox
Exporter hoặc phương pháp giám sát reachability khác.

### 3.2. Các metric chưa có dữ liệu

-   `probe_success` và `probe_duration_seconds`: truy vấn trả về
    `Empty query result`. Chưa có dữ liệu probe trong Prometheus. Cần
    kiểm tra Blackbox Exporter và cấu hình scrape/probe ở giai đoạn
    triển khai phù hợp.
-   MySQL metrics: nhóm dự kiến sử dụng MySQL nhưng MySQL và MySQL
    Exporter chưa triển khai. Các metric ví dụ `mysql_up` và
    `mysql_global_status_threads_connected` chỉ có thể xác minh sau khi
    triển khai exporter tương ứng.
-   `alertmanager_notifications_failed_total`: Alertmanager chưa được
    triển khai nên chưa thể xác minh metric này.

Truy vấn `{__name__=~".*_up"}` đã trả về `node_network_up` cho các
interface `enp0s3`, `enp0s8`, `lo`, `tailscale0`. Đây là metric trạng
thái network interface, không thay thế cho metric kiểm tra MySQL hoặc
Alertmanager.

## 4. Alert Scenarios Mapping

Bảng dưới đây là mapping đề xuất ban đầu. Các ngưỡng và severity đều cần
được nhóm xác nhận trước khi triển khai.

  ---------------------------------------------------------------------------------------------------------------------------------------
  Mã          Scenario       Metric đề xuất                              Điều kiện cảnh báo đề xuất       Severity đề xuất   Cách kiểm
                                                                                                                             thử
  ----------- -------------- ------------------------------------------- -------------------------------- ------------------ ------------
  AS-01       CPU usage cao  `node_cpu_seconds_total`                    CPU busy percentage vượt ngưỡng  TBD -- đề xuất     Tạo tải CPU
              kéo dài                                                    thống nhất trong một khoảng thời Warning/Critical   có kiểm soát
                                                                         gian liên tục. PromQL tính CPU   theo ngưỡng        trên máy thử
                                                                         busy được trình bày tại mục 3.1.                    nghiệm; quan
                                                                                                                             sát giá trị
                                                                                                                             CPU và trạng
                                                                                                                             thái alert

  AS-02       Available RAM  `node_memory_MemAvailable_bytes`,           Tỷ lệ RAM khả dụng thấp hơn      TBD -- đề xuất     Tạo tải bộ
              thấp           `node_memory_MemTotal_bytes`                ngưỡng thống nhất trong một      Warning/Critical   nhớ có kiểm
                                                                         khoảng thời gian liên tục                           soát trong
                                                                                                                             môi trường
                                                                                                                             thử nghiệm;
                                                                                                                             theo dõi tỷ
                                                                                                                             lệ RAM khả
                                                                                                                             dụng

  AS-03       Available disk `node_filesystem_avail_bytes`,              Tỷ lệ dung lượng còn trống của   TBD -- đề xuất     Tạo file dữ
              thấp           `node_filesystem_size_bytes`                mountpoint được giám sát thấp    Warning/Critical   liệu thử
                                                                         hơn ngưỡng thống nhất                               nghiệm trên
                                                                                                                             phân vùng
                                                                                                                             được giám
                                                                                                                             sát; theo
                                                                                                                             dõi dung
                                                                                                                             lượng còn
                                                                                                                             trống; dọn
                                                                                                                             dữ liệu sau
                                                                                                                             kiểm thử

  AS-04       Host           Có thể dùng ICMP probe (`probe_success` với Probe/reachability thất bại liên TBD -- đề xuất     Ngắt kết nối
              unreachable    module ICMP) hoặc cơ chế kiểm tra           tục trong khoảng thời gian thống Critical           hoặc chặn
                             reachability độc lập                        nhất. `up == 0` chỉ phản ánh                        ICMP trên
                                                                         scrape target thất bại, không đủ                    máy thử
                                                                         để kết luận host unreachable                        nghiệm theo
                                                                         trong mọi trường hợp                                kế hoạch;
                                                                                                                             xác nhận
                                                                                                                             probe thất
                                                                                                                             bại; khôi
                                                                                                                             phục sau
                                                                                                                             kiểm thử

  AS-05       Web service    `probe_success` (Blackbox Exporter, HTTP    `probe_success == 0` liên tục    TBD -- đề xuất     Dừng Web
              unavailable    probe)                                      trong khoảng thời gian thống     Critical           service thử
                                                                         nhất                                                nghiệm hoặc
                                                                                                                             làm endpoint
                                                                                                                             không truy
                                                                                                                             cập được;
                                                                                                                             xác nhận
                                                                                                                             probe trả về
                                                                                                                             thất bại

  AS-06       Web response   `probe_duration_seconds`                    Thời gian probe vượt ngưỡng      TBD -- đề xuất     Tạo độ trễ
              time cao                                                   thống nhất trong khoảng thời     Warning/Critical   có kiểm soát
                                                                         gian liên tục                                       ở môi trường
                                                                                                                             thử nghiệm;
                                                                                                                             quan sát
                                                                                                                             thời gian
                                                                                                                             probe

  AS-07       Database       `mysql_up` (nếu sử dụng Prometheus MySQL    `mysql_up == 0` liên tục trong   TBD -- đề xuất     Sau khi
              unreachable    Exporter)                                   khoảng thời gian thống nhất      Critical           triển khai
                                                                                                                             MySQL
                                                                                                                             Exporter,
                                                                                                                             dừng MySQL
                                                                                                                             thử nghiệm
                                                                                                                             hoặc làm mất
                                                                                                                             kết nối
                                                                                                                             exporter tới
                                                                                                                             DB; xác nhận
                                                                                                                             metric

  AS-08       Database       `mysql_global_status_threads_connected`     Số kết nối hiện tại vượt ngưỡng  TBD -- đề xuất     Tạo số lượng
              connections    (nếu sử dụng MySQL Exporter)                thống nhất trong khoảng thời     Warning/Critical   kết nối
              cao                                                        gian liên tục                                       MySQL có
                                                                                                                             kiểm soát;
                                                                                                                             theo dõi
                                                                                                                             metric; đóng
                                                                                                                             các kết nối
                                                                                                                             sau kiểm thử

  AS-09       Prometheus     `up`                                        `up{job="vm2-webserver"} == 0`   TBD -- đề xuất     Dừng Node
              scrape target                                              kéo dài trong khoảng thời gian   Critical           Exporter
              failure                                                    thống nhất                                          trên VM2
                                                                                                                             trong môi
                                                                                                                             trường được
                                                                                                                             phép; xác
                                                                                                                             nhận `up`
                                                                                                                             chuyển thành
                                                                                                                             `0`; khởi
                                                                                                                             động lại sau
                                                                                                                             kiểm thử

  AS-10       Alertmanager   `alertmanager_notifications_failed_total`   Số notification lỗi tăng trong   TBD -- đề xuất     Cấu hình
              notification   (nếu metric có trong phiên bản triển khai)  khoảng thời gian quan sát; cần   Critical           receiver thử
              failure        và log/trạng thái Alertmanager              xác minh metric và cách giám sát                    nghiệm không
                                                                         bổ sung theo phiên bản                              hợp lệ hoặc
                                                                                                                             mô phỏng lỗi
                                                                                                                             gửi thông
                                                                                                                             báo có kiểm
                                                                                                                             soát; xác
                                                                                                                             nhận lỗi qua
                                                                                                                             metric/log
  ---------------------------------------------------------------------------------------------------------------------------------------

## 5. Lưu ý về điều kiện cảnh báo và severity

1.  Không có ngưỡng CPU, RAM, Disk, response time hoặc số kết nối MySQL
    nào được xác nhận là ngưỡng chính thức trong kết quả kiểm tra hiện
    tại.
2.  Các giá trị threshold và `for` duration cần được nhóm thống nhất dựa
    trên yêu cầu hệ thống và baseline thực tế.
3.  Severity `warning`/`critical` trong bảng là gợi ý phân loại, chưa
    phải quyết định cuối cùng.
4.  `up == 0` là dấu hiệu scrape thất bại của target. Đối với AS-04
    (host unreachable), nên dùng phép kiểm tra reachability độc lập nếu
    yêu cầu cần phân biệt host down với exporter/service down.
5.  Tên metric MySQL phụ thuộc exporter và phiên bản. Cần xác minh
    metric thực tế sau khi MySQL Exporter được triển khai.
6.  Metric Alertmanager cần được kiểm tra lại theo phiên bản đang cài
    đặt. Khi Alertmanager chưa chạy, không thể xác minh metric runtime
    của nó.
7.  Không thực hiện các bài kiểm thử có thể gây gián đoạn dịch vụ trên
    máy chủ dùng chung nếu chưa được nhóm cho phép.

## 6. Các hạng mục cần phối hợp hoặc xác minh ở task tiếp theo

  --------------------------------------------------------------------------
  Hạng mục                Việc cần làm               Phụ thuộc
  ----------------------- -------------------------- -----------------------
  Web probing             Triển khai/cấu hình        Người phụ trách
                          Blackbox Exporter và probe Prometheus/Exporter và
                          endpoint cần giám sát; xác Web
                          minh `probe_success`,      
                          `probe_duration_seconds`   

  MySQL monitoring        Triển khai MySQL và MySQL  Người phụ trách
                          Exporter; xác minh metric  Database/Exporter
                          trạng thái DB và số kết    
                          nối                        

  Alertmanager monitoring Cài đặt Alertmanager; kiểm SCRUM-36 và các task
                          tra metric và log phù hợp  liên quan
                          với phiên bản              

  Threshold & severity    Thống nhất ngưỡng, thời    Nhóm dự án
                          gian duy trì và mức độ ưu  
                          tiên cho từng scenario     

  Alert rules             Chuyển mapping đã thống    SCRUM-38 và các task
                          nhất thành Prometheus      liên quan
                          alert rules                

  Notification pipeline   Kết nối Prometheus --      SCRUM-36, SCRUM-37
                          Alertmanager -- Telegram   
                          và kiểm thử end-to-end     
  --------------------------------------------------------------------------

## 7. Kết luận

Tại thời điểm kiểm tra ngày 23/11/2026:

-   Đã xác minh các metric cơ bản cho CPU, RAM và Disk trên VM2.
-   Đã xác nhận `up{job="vm2-webserver"} = 1`, nghĩa là Prometheus
    scrape VM2 Node Exporter thành công tại thời điểm kiểm tra.
-   Chưa có dữ liệu `probe_success` và `probe_duration_seconds`; cần
    triển khai/xác minh Blackbox Exporter và probe.
-   MySQL và MySQL Exporter chưa triển khai; các metric Database đang
    chờ xác minh.
-   Alertmanager chưa triển khai; metric theo dõi notification failure
    đang chờ xác minh.
-   Đã xây dựng mapping đề xuất cho đủ 10 Alert Scenarios. Ngưỡng cảnh
    báo và severity vẫn cần nhóm thống nhất trước khi cấu hình chính
    thức.

**Kết quả bàn giao của SCRUM-34:** Tài liệu mapping Scenario -- Metric
-- Alert Condition -- Severity/Priority -- Test Method, kèm trạng thái
xác minh Metrics Inventory và các phụ thuộc cần triển khai ở những task
tiếp theo.
