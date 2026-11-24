# Acceptance Criteria – Tiêu chí nghiệm thu

**Dự án:** N4.7 – Xây dựng hệ thống giám sát máy chủ, Cloud và trung tâm dữ liệu  
**Nhóm phụ trách:** Nhóm 1 – Phân tích & Thiết kế  
**Người thực hiện:** Ngô Thảo My  
**Ngày tạo:** 21/11/2026  
**Ngày cập nhật:** 21/11/2026  
**Người review:** Chờ review  
**Trạng thái:** Draft – Phiên bản 0.2

---

## 1. Mục đích

Tài liệu xác định các tiêu chí nghiệm thu đối với hệ thống giám sát được xây dựng trong dự án N4.7.

Các tiêu chí này được sử dụng để:

- Xác định những chức năng và yêu cầu hệ thống cần đáp ứng.
- Làm căn cứ xây dựng Test Plan và Test Case.
- Đánh giá kết quả kiểm thử Prototype.
- Đảm bảo các nhóm có cùng cách hiểu về phạm vi và kết quả cần đạt.

Lưu ý:

- Các tiêu chí hiện tại là bản dự thảo.
- Những thông số chưa được xác định sẽ được nhóm thống nhất trong giai đoạn Baseline và thiết kế chi tiết.

## 2. Cấu hình tham chiếu và nguyên tắc đo lường

### 2.1. Các thông số cấu hình

| Thông số                            | Ký hiệu  | Giá trị dự kiến | Ghi chú                                                                |
| ----------------------------------- | -------- | --------------- | ---------------------------------------------------------------------- |
| Prometheus scrape interval          | `S`      | Chưa xác định   | Chu kỳ thu thập Metrics                                                |
| Prometheus rule evaluation interval | `E`      | Chưa xác định   | Chu kỳ đánh giá Alert Rules                                            |
| Alert rule duration                 | `F`      | Theo từng rule  | Thời gian điều kiện phải duy trì trước khi cảnh báo chuyển sang Firing |
| Alertmanager `group_wait`           | `G`      | Chưa xác định   | Thời gian chờ trước khi gửi nhóm cảnh báo đầu tiên                     |
| Số lượng VM tối thiểu               | `N`      | Chưa xác định   | Số VM cần giám sát trong Prototype                                     |
| Ngưỡng CPU                          | `Y_CPU`  | Chưa xác định   | Phần trăm CPU sử dụng                                                  |
| Ngưỡng RAM                          | `Y_RAM`  | Chưa xác định   | Phần trăm RAM sử dụng                                                  |
| Ngưỡng Disk                         | `Y_DISK` | Chưa xác định   | Phần trăm Disk sử dụng                                                 |
| Thời gian phục hồi tối đa           | `W`      | Chưa xác định   | Thời gian nhận thông báo phục hồi                                      |
| Thời gian triển khai tối đa         | `T`      | Chưa xác định   | Thời gian thành viên khác dựng lại môi trường                          |
| Giới hạn tài nguyên Prometheus      | `R`      | Chưa xác định   | Mức sử dụng tài nguyên cho phép                                        |

### 2.2. Nguyên tắc đo thời gian cảnh báo

Thời gian cảnh báo được tính từ thời điểm bắt đầu tạo ra sự cố đến thời điểm hệ thống gửi thông báo đến kênh nhận cảnh báo.

Thời gian này có thể bao gồm:

- Thời gian chờ đến lần scrape tiếp theo.
- Thời gian đánh giá Alert Rule.
- Thời gian duy trì điều kiện cảnh báo (`for`).
- Thời gian chờ nhóm cảnh báo (`group_wait`).
- Thời gian xử lý và gửi thông báo.

Công thức ước lượng:

`Alert Latency ≈ Scrape Delay + Evaluation Delay + Rule Duration + Group Wait + Notification Delay`

Lưu ý:

- Đây là công thức ước lượng, không phải cam kết rằng các thành phần luôn cộng tuyến tính trong mọi trường hợp.
- Thời gian thực tế sẽ được đo bằng kiểm thử và báo cáo bởi Nhóm 4.

Cần phân biệt:

- **Detection Time:** Thời gian từ khi sự cố bắt đầu đến khi Alert Rule chuyển sang trạng thái Firing.
- **Notification Time:** Thời gian từ khi sự cố bắt đầu đến khi thông báo được nhận tại Telegram.
- **Recovery Time:** Thời gian từ khi khắc phục sự cố đến khi nhận được thông báo Resolved.

## 3. Tiêu chí nghiệm thu chức năng

### 3.1. Quy ước mức độ

| Mức độ       | Ý nghĩa                                                  |
| ------------ | -------------------------------------------------------- |
| B – Bắt buộc | Tiêu chí cần đạt để Prototype được nghiệm thu.           |
| N – Nên có   | Tiêu chí nên đạt nếu đủ thời gian và điều kiện kỹ thuật. |
| T – Tùy chọn | Tiêu chí mở rộng, thực hiện nếu còn nguồn lực.           |

### 3.2. Bảng tiêu chí

| ID   | Tiêu chí                                   | Mức độ       | Điều kiện nghiệm thu                                                                                                                                                                               | Phương pháp kiểm thử                                                                       | Test Case |
| ---- | ------------------------------------------ | ------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------ | --------- |
| AC01 | Thu thập Metrics từ các máy chủ            | B – Bắt buộc | Prometheus thu thập được Metrics từ tối thiểu `N` VM đã cấu hình. Các target hoạt động bình thường phải có trạng thái `UP`.                                                                        | Khởi động môi trường, kiểm tra trang Targets của Prometheus.                               | TC01      |
| AC02 | Hiển thị thông tin giám sát trên Dashboard | B – Bắt buộc | Grafana hiển thị được CPU, RAM, Disk, Network và trạng thái máy chủ cho các VM đã cấu hình.                                                                                                        | Truy cập Dashboard và đối chiếu dữ liệu với nguồn Metrics.                                 | TC02      |
| AC03 | Phát hiện Host Down                        | B – Bắt buộc | Khi một VM bị tắt hoặc mất kết nối, hệ thống phát hiện được sự cố và gửi cảnh báo trong thời gian không quá `X` phút.                                                                              | Tắt VM hoặc ngắt kết nối có kiểm soát, ghi nhận thời điểm và thời gian nhận cảnh báo.      | TC03      |
| AC04 | Phát hiện CPU Usage cao                    | B – Bắt buộc | Khi CPU Usage vượt `Y_CPU`% liên tục trong `F_CPU` phút, hệ thống phát sinh cảnh báo và gửi thông báo trong thời gian không quá `X_CPU` phút kể từ khi điều kiện bắt đầu.                          | Sử dụng `stress-ng` tạo tải CPU có kiểm soát, ghi nhận thời điểm bắt đầu và nhận cảnh báo. | TC04      |
| AC05 | Phát hiện Memory Usage cao                 | B – Bắt buộc | Khi Memory Usage vượt `Y_RAM`% liên tục trong `F_RAM` phút, hệ thống phát sinh cảnh báo và gửi thông báo trong thời gian không quá `X_RAM` phút kể từ khi điều kiện bắt đầu.                       | Tạo tải bộ nhớ có kiểm soát, ghi nhận thời điểm bắt đầu và nhận cảnh báo.                  | TC05      |
| AC06 | Phát hiện Disk Usage cao                   | B – Bắt buộc | Khi Disk Usage vượt `Y_DISK`%, hệ thống phát sinh cảnh báo và gửi thông báo trong thời gian không quá `X_DISK` phút kể từ khi điều kiện bắt đầu.                                                   | Tạo file dung lượng lớn có kiểm soát để tăng mức sử dụng Disk.                             | TC06      |
| AC07 | Phát hiện Web Service Down                 | B – Bắt buộc | Khi dịch vụ Nginx ngừng hoạt động hoặc không thể truy cập qua HTTP, hệ thống phát hiện được sự cố và gửi cảnh báo trong thời gian không quá `X_WEB` phút.                                          | Dừng Nginx hoặc làm dịch vụ không thể truy cập, kiểm tra cảnh báo.                         | TC07      |
| AC08 | Phát hiện Database Unreachable             | B – Bắt buộc | Khi Database không thể truy cập qua phương thức kiểm tra kết nối đã thống nhất, hệ thống phát hiện được sự cố và gửi cảnh báo trong thời gian không quá `X_DB` phút.                               | Dừng Database hoặc chặn kết nối đến cổng dịch vụ, kiểm tra cảnh báo.                       | TC08      |
| AC09 | Nội dung thông báo cảnh báo                | B – Bắt buộc | Thông báo Telegram phải có tối thiểu hostname/instance, tên cảnh báo, mức độ nghiêm trọng và thời điểm phát sinh.                                                                                  | Kích hoạt một cảnh báo và kiểm tra nội dung thông báo nhận được.                           | TC09      |
| AC10 | Thông báo phục hồi                         | B – Bắt buộc | Khi điều kiện gây cảnh báo không còn tồn tại và Alert Rule chuyển sang trạng thái Resolved, hệ thống gửi thông báo phục hồi trong thời gian không quá `W` phút kể từ khi điều kiện được khắc phục. | Khắc phục sự cố đang ở trạng thái Firing, ghi nhận thời gian nhận thông báo Resolved.      | TC10      |
| AC11 | Hạn chế cảnh báo trùng lặp do sự cố Host   | N – Nên có   | Khi một VM ngừng hoạt động, hệ thống ưu tiên cảnh báo Host Down và hạn chế gửi các cảnh báo dịch vụ phụ thuộc trên cùng VM do cùng nguyên nhân mất kết nối.                                        | Tắt một VM đang chạy Web và Database, kiểm tra các cảnh báo phát sinh.                     | TC11      |

## 4. Tiêu chí nghiệm thu kỹ thuật và vận hành

| ID   | Tiêu chí                              | Mức độ       | Điều kiện nghiệm thu                                                                                                                                                                                                                             | Phương pháp kiểm thử                                                               | Test Case |
| ---- | ------------------------------------- | ------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ---------------------------------------------------------------------------------- | --------- |
| AC12 | Khả năng tái tạo môi trường           | B – Bắt buộc | Một thành viên khác có thể dựa trên tài liệu hướng dẫn để triển khai lại môi trường trong thời gian không quá `T` giờ và đạt được kết quả AC01, AC02.                                                                                            | Thành viên không trực tiếp xây dựng môi trường thực hiện triển khai theo tài liệu. | TC12      |
| AC13 | Quản lý cấu hình                      | B – Bắt buộc | Các cấu hình Prometheus, Alert Rules và các cấu hình liên quan được quản lý trong Git. Các file cấu hình Prometheus và Alert Rules phải vượt qua kiểm tra cú pháp bằng công cụ phù hợp, ví dụ `promtool check config` và `promtool check rules`. | Kiểm tra repository và chạy các lệnh kiểm tra cấu hình.                            | TC13      |
| AC14 | Kiểm thử ổn định                      | N – Nên có   | Hệ thống chạy liên tục trong khoảng 24–48 giờ mà không xuất hiện tình trạng mất target ngoài dự kiến. Mức sử dụng tài nguyên của Prometheus không vượt quá `R`.                                                                                  | Thực hiện soak test, ghi nhận trạng thái target và mức sử dụng tài nguyên.         | TC14      |
| AC15 | Kiểm thử lặp lại                      | B – Bắt buộc | Mỗi tình huống thuộc AC03–AC08 được kiểm thử từ 10–20 lần. Báo cáo phải có thời gian nhỏ nhất, lớn nhất và trung vị của các lần đo.                                                                                                              | Chạy lại từng kịch bản sự cố và tổng hợp kết quả.                                  | TC15      |
| AC16 | Tài liệu giới hạn và hướng phát triển | B – Bắt buộc | Tài liệu phải nêu rõ các giới hạn của Prototype, các chức năng chưa triển khai và hướng phát triển trong tương lai.                                                                                                                              | Rà soát báo cáo kỹ thuật và tài liệu thiết kế.                                     | TC16      |
| AC17 | Khả năng mở rộng thêm máy chủ         | T – Tùy chọn | Khi thêm một máy chủ mới, người triển khai chỉ cần thực hiện một thao tác cấu hình tối thiểu theo thiết kế; Dashboard có thể hiển thị máy chủ mới mà không cần xây dựng lại toàn bộ hệ thống.                                                    | Thêm một target mới và kiểm tra dữ liệu trên Dashboard.                            | TC17      |
| AC18 | Tài liệu và trách nhiệm nhóm          | B – Bắt buộc | Mỗi nhóm hoàn thiện tài liệu thuộc phạm vi phụ trách. Team Leader tổng hợp và kiểm tra tính nhất quán giữa các tài liệu trước khi bàn giao.                                                                                                      | Rà soát tài liệu của các nhóm và kiểm tra tính nhất quán.                          | TC18      |

## 5. Tiêu chí bổ sung cho các tình huống cảnh báo

Các tiêu chí dưới đây được đề xuất để hoàn thiện phạm vi kiểm thử cho các tình huống đã xác định trong Alert Scenarios. Chúng chưa được xem là cam kết nghiệm thu chính thức cho đến khi nhóm thống nhất.

| ID   | Tiêu chí                                   | Mức độ đề xuất       | Điều kiện nghiệm thu                                                                                                                                                          | Phương pháp kiểm thử                                                                                                     | Test Case |
| ---- | ------------------------------------------ | -------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------ | --------- |
| AC19 | Phát hiện Prometheus Scrape Target Failure | B – Bắt buộc đề xuất | Khi một exporter hoặc target không thể được Prometheus scrape, hệ thống phát hiện trạng thái scrape thất bại và phát sinh cảnh báo trong thời gian không quá `X_SCRAPE` phút. | Dừng exporter hoặc chặn kết nối đến exporter, kiểm tra trạng thái target và cảnh báo.                                    | TC19      |
| AC20 | Phát hiện Web Response Time cao            | N – Nên có           | Khi thời gian phản hồi HTTP vượt ngưỡng `Y_WEB_TIME` trong khoảng thời gian `F_WEB_TIME`, hệ thống phát sinh cảnh báo. Cần bảo đảm ngưỡng cảnh báo thấp hơn probe timeout.    | Tạo độ trễ phản hồi có kiểm soát và kiểm tra cảnh báo.                                                                   | TC20      |
| AC21 | Phát hiện Database Connections cao         | N – Nên có           | Khi số lượng kết nối Database vượt ngưỡng `Y_DB_CONN` trong khoảng thời gian `F_DB_CONN`, hệ thống phát sinh cảnh báo.                                                        | Tạo các kết nối Database có kiểm soát và kiểm tra cảnh báo.                                                              | TC21      |
| AC22 | Phát hiện lỗi gửi Notification             | N – Nên có           | Hệ thống có khả năng phát hiện lỗi gửi thông báo từ Alertmanager đến receiver và cung cấp thông tin phục vụ việc giám sát lỗi gửi cảnh báo.                                   | Mô phỏng lỗi kết nối đến receiver hoặc cấu hình gửi thông báo không thành công, kiểm tra Metrics và trạng thái cảnh báo. | TC22      |

Lưu ý:

- AC19 kiểm tra khả năng phát hiện scrape thất bại khi Prometheus vẫn hoạt động.
- Trường hợp chính Prometheus ngừng hoạt động cần có cơ chế giám sát độc lập nếu muốn bảo đảm phát hiện được sự cố này.

## 6. Quy tắc Alert Inhibition

Hệ thống nên hạn chế các cảnh báo thứ cấp khi đã xác định được sự cố gốc có khả năng gây ra chúng.

### 6.1. Các quan hệ inhibition đề xuất

| Cảnh báo gốc    | Cảnh báo có thể bị hạn chế  | Điều kiện                                                                         |
| --------------- | --------------------------- | --------------------------------------------------------------------------------- |
| AS-04 Host Down | AS-05 Web Service Down      | Cùng một instance và xác định được Host Down là nguyên nhân gốc.                  |
| AS-04 Host Down | AS-07 Database Unreachable  | Cùng một instance và xác định được Host Down là nguyên nhân gốc.                  |
| AS-04 Host Down | AS-09 Scrape Target Failure | Cùng một instance và có đủ căn cứ xác định target không scrape được do Host Down. |

### 6.2. Nguyên tắc bổ sung

- Không nên mặc định mọi cảnh báo Scrape Failure đều do Host Down. Exporter có thể ngừng hoạt động trong khi máy chủ vẫn hoạt động bình thường.
- Các cảnh báo liên quan đến chính Prometheus hoặc Alertmanager không nên bị hạn chế chỉ vì một máy chủ đích gặp sự cố.

## 7. Phạm vi kiểm thử và giới hạn

- Các ngưỡng CPU, RAM, Disk, Web Response Time và Database Connections sẽ được thống nhất trong giai đoạn Baseline.
- Thời gian cảnh báo và phục hồi phải được đo thực tế, không chỉ suy ra từ cấu hình.
- Các phép thử gây tải phải được thực hiện có kiểm soát, tránh làm ảnh hưởng đến máy chủ đang sử dụng cho công việc khác.
- Kiểm tra Database Unreachable ở phạm vi tối thiểu có thể sử dụng TCP probe. Điều này chỉ chứng minh khả năng kết nối đến cổng dịch vụ, không chứng minh truy vấn SQL thành công.
- Nếu cần xác nhận Database thực sự xử lý được truy vấn, nhóm cần bổ sung SQL Query Check.
- Kiểm tra Web bằng HTTP probe không đảm bảo toàn bộ chức năng nghiệp vụ của ứng dụng hoạt động bình thường.
- AC19 không chứng minh Prometheus có thể tự phát hiện trường hợp chính nó ngừng hoạt động.
- AC20–AC22 cần được nhóm xác nhận trước khi đưa vào phạm vi nghiệm thu chính thức.

## 8. Ma trận truy vết Problem Survey – Acceptance Criteria

| Mã tình huống | Tình huống                        | Vấn đề liên quan | Tiêu chí nghiệm thu          | Ghi chú                                |
| ------------- | --------------------------------- | ---------------- | ---------------------------- | -------------------------------------- |
| S1            | Host Down                         | PRB04            | AC03, AC09, AC10, AC11, AC15 | Host không thể truy cập                |
| S2            | CPU Usage High                    | PRB01            | AC04, AC09, AC10, AC15       | CPU sử dụng cao kéo dài                |
| S3            | Memory Usage High                 | PRB02            | AC05, AC09, AC10, AC15       | Bộ nhớ khả dụng thấp                   |
| S4            | Disk Usage High                   | PRB03            | AC06, AC09, AC10, AC15       | Dung lượng Disk khả dụng thấp          |
| S5            | Web Service Down                  | PRB05            | AC07, AC09, AC10, AC11, AC15 | Web không thể truy cập                 |
| –             | Web Response Time High            | PRB06            | AC20 (đề xuất)               | Web Response Time cao                  |
| S6            | Database Unreachable              | PRB07            | AC08, AC09, AC10, AC11, AC15 | Database không thể truy cập            |
| –             | Database Connections High         | PRB08            | AC21 (đề xuất)               | Database Connections cao               |
| –             | Prometheus Scrape Target Failure  | PRB09            | AC19                         | Prometheus không scrape được target    |
| –             | Alertmanager Notification Failure | PRB10            | AC22 (đề xuất)               | Alertmanager gửi notification thất bại |

Tiêu chí dùng chung:

- **AC09:** Áp dụng cho nội dung các cảnh báo được gửi đến Telegram.
- **AC10:** Áp dụng cho thông báo phục hồi của các cảnh báo có hỗ trợ trạng thái Resolved.
- **AC11:** Áp dụng cho quan hệ giữa cảnh báo Host Down và các cảnh báo dịch vụ phụ thuộc.
- **AC15:** Áp dụng cho các kịch bản kiểm thử AC03–AC08, không mặc định áp dụng cho tất cả các tình huống AS-01–AS-10.

## 9. Trạng thái xác nhận

| Nội dung                | Trạng thái                                                  |
| ----------------------- | ----------------------------------------------------------- |
| AC01–AC18               | Draft – Chờ rà soát                                         |
| AC19                    | Đề xuất bổ sung – Cần xác nhận                              |
| AC20–AC22               | Đề xuất mở rộng – Cần xác nhận phạm vi                      |
| Các ngưỡng và thời gian | Chưa xác định                                               |
| Ma trận truy vết        | Draft – Cần đối chiếu với Problem Survey và Alert Scenarios |
| Phê duyệt cuối cùng     | Pending                                                     |

Ghi chú:

- Tài liệu sẽ được rà soát và chốt Baseline trong Tuần 6 (06–12/12/2026) sau khi thống nhất phạm vi, thông số cấu hình và khả năng triển khai Prototype.

---

## 10. Lịch sử cập nhật

| Ngày       | Phiên bản | Nội dung                                                                                                                                                    |
| ---------- | --------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 21/11/2026 | 0.1       | Tạo bản nháp Acceptance Criteria ban đầu: AC01–AC18, thông số tham chiếu, ma trận truy vết S1–S6.                                                           |
| 21/11/2026 | 0.2       | Làm rõ nguyên tắc đo thời gian, sửa cách diễn đạt các tiêu chí AC03–AC08, bổ sung AC19 và đề xuất AC20–AC22, cập nhật ma trận truy vết và Alert Inhibition. |

---

**Tài liệu liên quan:**

- Jira Task: SCRUM-6 – Khảo sát bài toán giám sát hệ thống.
- Jira Task: SCRUM-8 – Liệt kê và phân loại Metrics.
- Tài liệu: `problem-survey.md`.
- Tài liệu: `metrics-inventory.md`.
- Tài liệu: `alert-scenarios.md`.
- Tài liệu tiếp theo: Functional Requirements và Non-functional Requirements.
