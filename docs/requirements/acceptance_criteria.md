# Acceptance Criteria – Tiêu chí nghiệm thu

**Dự án:** N4.7 – Hệ thống Monitoring cho Server, Cloud Simulation và Data Center Simulation  
**Nhóm phụ trách:** Nhóm 1 – Phân tích & Thiết kế  
**Mã Jira:** SCRUM-26  
**Người thực hiện:** Ngô Thảo My  
**Ngày tạo:** 21/11/2026  
**Ngày cập nhật:** 24/11/2026  
**Người review:** Chờ review  
**Trạng thái:** Draft – Phiên bản 0.3

---

## 1. Mục đích

Tài liệu xác định các tiêu chí nghiệm thu đối với hệ thống Monitoring được xây dựng trong dự án N4.7 cho các đối tượng thuộc nhóm Server, Cloud Simulation và Data Center Simulation.

Các tiêu chí này được sử dụng để:

- Xác định những chức năng và yêu cầu hệ thống cần đáp ứng.
- Làm căn cứ xây dựng Test Plan và Test Case.
- Đánh giá kết quả kiểm thử Prototype.
- Đảm bảo các nhóm có cùng cách hiểu về phạm vi và kết quả cần đạt.

Lưu ý:

- Các tiêu chí hiện tại là bản dự thảo.
- Những thông số chưa được xác định sẽ được nhóm thống nhất trong giai đoạn Baseline và thiết kế chi tiết.
- Thuật ngữ trong tài liệu tuân thủ `docs/requirements/01_Pham_Vi_Mo_Phong_Va_Nguyen_Tac.md`, mục 1: **Server**, **Cloud Simulation**, **Data Center Simulation**, **Monitoring**.
- Cloud Simulation và Data Center Simulation là mô phỏng ở mức logic trên các VM của Prototype, không phải triển khai trên hạ tầng Cloud hoặc Data Center thực tế.

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

Ghi chú:

- Giá trị Draft của các thông số trên được quản lý tại `docs/requirements/baseline.md` (xem mục 2.3).
- Cột "Giá trị dự kiến" ở bảng này không được cập nhật song song để tránh hai nguồn lệch nhau.

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

### 2.3. Bảng quy ước tham số nghiệm thu (Variables Reference)

Bảng dưới liệt kê toàn bộ biến số xuất hiện trong các tiêu chí của tài liệu này. Giá trị của các biến **không** được ghi tại đây; nguồn duy nhất là `docs/requirements/baseline.md` (cột "Mã Baseline"). Khi có khác biệt giữa tài liệu này và `docs/requirements/baseline.md`, `docs/requirements/baseline.md` là nguồn quyết định.

Phân biệt bắt buộc giữa `F_*` và `X_*` (chi tiết: `docs/requirements/baseline.md` mục 2.1):

| Tiêu chí so sánh | `F_*` – Thời gian duy trì trong rule                                                    | `X_*` – Giới hạn thời gian phát hiện + gửi thông báo                                                                               |
| ---------------- | --------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------- |
| Bản chất         | Tham số cấu hình của Alert Rule (trường `for`)                                          | Giới hạn nghiệm thu trong Acceptance Criteria                                                                                      |
| Đo từ → đến      | Từ lần evaluation đầu tiên thấy điều kiện đúng (Pending) → lần evaluation chuyển Firing | Từ thời điểm sự cố thực sự bắt đầu (`t0`, `docs/requirements/baseline.md` mục 2.2) → thời điểm notification được nhận tại Telegram |
| Bao gồm          | Chỉ thời gian duy trì điều kiện                                                         | Chờ scrape + thời gian scrape/probe + trễ cửa sổ `rate()` (nếu có) + chờ evaluation + `F_*` + `group_wait` + trễ giao Telegram     |
| Quan hệ          | `F_*` là một thành phần của `X_*`                                                       | `X_*` luôn lớn hơn `F_*` tương ứng                                                                                                 |

| Ký hiệu      | Loại                                            | Ý nghĩa                                                                                                                                              | Dùng tại       | Mã Baseline               |
| ------------ | ----------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------- | -------------- | ------------------------- |
| `N`          | Giới hạn nghiệm thu                             | Số lượng VM tối thiểu mà Prometheus phải thu thập được Metrics với target ở trạng thái `UP`                                                          | AC01           | BL-16.1                   |
| `Y_CPU`      | Ngưỡng kích hoạt (cấu hình rule)                | Ngưỡng CPU Usage (%)                                                                                                                                 | AC04           | BL-04.1                   |
| `Y_RAM`      | Ngưỡng kích hoạt (cấu hình rule)                | Ngưỡng RAM Usage (%) tính từ MemAvailable                                                                                                            | AC05           | BL-05.1                   |
| `Y_DISK`     | Ngưỡng kích hoạt (cấu hình rule)                | Ngưỡng Disk Usage (%) trên filesystem thuộc phạm vi giám sát                                                                                         | AC06           | BL-06.1                   |
| `Y_WEB_TIME` | Ngưỡng kích hoạt (cấu hình rule)                | Ngưỡng thời gian phản hồi HTTP; phải nhỏ hơn probe timeout                                                                                           | AC20 (đề xuất) | BL-09.1                   |
| `Y_DB_CONN`  | Ngưỡng kích hoạt (cấu hình rule)                | Ngưỡng số kết nối Database hoặc Connection Usage (%)                                                                                                 | AC21 (đề xuất) | BL-11.1                   |
| `F_CPU`      | Thời gian duy trì trong rule (`for`)            | Thời gian CPU Usage phải liên tục vượt `Y_CPU` trước khi Alert chuyển Firing                                                                         | AC04           | BL-04.2                   |
| `F_RAM`      | Thời gian duy trì trong rule (`for`)            | Thời gian RAM Usage phải liên tục vượt `Y_RAM` trước khi Alert chuyển Firing                                                                         | AC05           | BL-05.2                   |
| `F_DISK`     | Thời gian duy trì trong rule (`for`)            | Thời gian Disk Usage phải liên tục vượt `Y_DISK` trước khi Alert chuyển Firing                                                                       | AC06           | BL-06.2                   |
| `F_WEB_TIME` | Thời gian duy trì trong rule (`for`)            | Thời gian phản hồi HTTP phải liên tục vượt `Y_WEB_TIME` khi probe vẫn thành công                                                                     | AC20 (đề xuất) | BL-09.2                   |
| `F_DB_CONN`  | Thời gian duy trì trong rule (`for`)            | Thời gian số kết nối phải liên tục vượt `Y_DB_CONN`                                                                                                  | AC21 (đề xuất) | BL-11.2                   |
| `X_HOST`     | Giới hạn nghiệm thu (phát hiện + gửi thông báo) | Thời gian tối đa từ `t0` đến khi nhận thông báo Host Down                                                                                            | AC03           | BL-13.1                   |
| `X_CPU`      | Giới hạn nghiệm thu (phát hiện + gửi thông báo) | Thời gian tối đa từ `t0` đến khi nhận thông báo CPU cao                                                                                              | AC04           | BL-13.2                   |
| `X_RAM`      | Giới hạn nghiệm thu (phát hiện + gửi thông báo) | Thời gian tối đa từ `t0` đến khi nhận thông báo RAM cao                                                                                              | AC05           | BL-13.3                   |
| `X_DISK`     | Giới hạn nghiệm thu (phát hiện + gửi thông báo) | Thời gian tối đa từ `t0` đến khi nhận thông báo Disk cao                                                                                             | AC06           | BL-13.4                   |
| `X_WEB`      | Giới hạn nghiệm thu (phát hiện + gửi thông báo) | Thời gian tối đa từ `t0` đến khi nhận thông báo Web Service Down                                                                                     | AC07           | BL-13.5                   |
| `X_DB`       | Giới hạn nghiệm thu (phát hiện + gửi thông báo) | Thời gian tối đa từ `t0` đến khi nhận thông báo Database Unreachable                                                                                 | AC08           | BL-13.6                   |
| `X_SCRAPE`   | Giới hạn nghiệm thu (phát hiện + gửi thông báo) | Thời gian tối đa từ `t0` đến khi nhận thông báo Scrape Target Failure                                                                                | AC19           | BL-13.7                   |
| `W`          | Giới hạn nghiệm thu (phục hồi)                  | Thời gian tối đa từ khi điều kiện được khắc phục đến khi nhận thông báo Resolved. Không chứa `F_*` và `group_wait`, nhưng phụ thuộc `group_interval` | AC10           | BL-13.10, BL-17           |
| `T`          | Giới hạn nghiệm thu (vận hành)                  | Thời gian tối đa (giờ) để thành viên khác dựng lại môi trường theo tài liệu và đạt AC01, AC02                                                        | AC12           | BL-16.2                   |
| `R`          | Giới hạn nghiệm thu (vận hành)                  | Mức sử dụng tài nguyên cho phép của Prometheus; gồm ba thành phần `R_MEM`, `R_CPU`, `R_DISK`                                                         | AC14           | BL-15.1, BL-15.2, BL-15.3 |

Ghi chú:

- `F_HOST`, `F_WEB_DOWN`, `F_DB`, `F_SCRAPE` (BL-07, BL-08, BL-10, BL-12) tồn tại trong `docs/requirements/baseline.md` nhưng không được ghi tường minh trong điều kiện của AC03, AC07, AC08, AC19 vì các tình huống này dùng điều kiện trạng thái (probe/scrape thất bại). Chúng vẫn là một thành phần của `X_*` tương ứng.
- `S`, `E`, `G` ở mục 2.1 là tham số cấu hình, không phải giới hạn nghiệm thu; giá trị tại BL-01, BL-02, BL-03.
- Thay đổi bất kỳ `F_*`, `S`, `E`, `G` hoặc cửa sổ `rate()` đều làm thay đổi giá trị tối thiểu hợp lệ của `X_*` – phải tính lại theo `docs/requirements/baseline.md` mục 5.2.

## 3. Tiêu chí nghiệm thu chức năng

### 3.1. Quy ước mức độ

| Mức độ       | Ý nghĩa                                                  |
| ------------ | -------------------------------------------------------- |
| B – Bắt buộc | Tiêu chí cần đạt để Prototype được nghiệm thu.           |
| N – Nên có   | Tiêu chí nên đạt nếu đủ thời gian và điều kiện kỹ thuật. |
| T – Tùy chọn | Tiêu chí mở rộng, thực hiện nếu còn nguồn lực.           |

### 3.2. Bảng tiêu chí

| ID   | Tiêu chí                                     | Mức độ       | Điều kiện nghiệm thu                                                                                                                                                                                                                                                | Phương pháp kiểm thử                                                                                                                                                                                                                                                                                                                                                                | Test Case |
| ---- | -------------------------------------------- | ------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------- |
| AC01 | Thu thập Metrics từ các Server               | B – Bắt buộc | Prometheus thu thập được Metrics từ tối thiểu `N` VM đã cấu hình. Các target hoạt động bình thường phải có trạng thái `UP`.                                                                                                                                         | Khởi động môi trường, kiểm tra trang Targets của Prometheus.                                                                                                                                                                                                                                                                                                                        | TC01      |
| AC02 | Hiển thị thông tin Monitoring trên Dashboard | B – Bắt buộc | Grafana hiển thị được CPU, RAM, Disk, Network và trạng thái Server cho các VM đã cấu hình.                                                                                                                                                                          | Truy cập Dashboard và đối chiếu dữ liệu với nguồn Metrics.                                                                                                                                                                                                                                                                                                                          | TC02      |
| AC03 | Phát hiện Host Down                          | B – Bắt buộc | Khi một VM bị tắt hoặc mất kết nối, hệ thống phát hiện được sự cố và gửi cảnh báo trong thời gian không quá `X_HOST` phút.                                                                                                                                          | Tắt VM hoặc ngắt kết nối có kiểm soát, ghi nhận thời điểm và thời gian nhận cảnh báo.                                                                                                                                                                                                                                                                                               | TC03      |
| AC04 | Phát hiện CPU Usage cao                      | B – Bắt buộc | Khi CPU Usage vượt `Y_CPU`% liên tục trong `F_CPU` phút, hệ thống phát sinh cảnh báo và gửi thông báo trong thời gian không quá `X_CPU` phút kể từ khi điều kiện bắt đầu.                                                                                           | Sử dụng `stress-ng` tạo tải CPU có kiểm soát, ghi nhận thời điểm bắt đầu và nhận cảnh báo.                                                                                                                                                                                                                                                                                          | TC04      |
| AC05 | Phát hiện Memory Usage cao                   | B – Bắt buộc | Khi Memory Usage vượt `Y_RAM`% liên tục trong `F_RAM` phút, hệ thống phát sinh cảnh báo và gửi thông báo trong thời gian không quá `X_RAM` phút kể từ khi điều kiện bắt đầu.                                                                                        | Tạo tải bộ nhớ có kiểm soát, ghi nhận thời điểm bắt đầu và nhận cảnh báo.                                                                                                                                                                                                                                                                                                           | TC05      |
| AC06 | Phát hiện Disk Usage cao                     | B – Bắt buộc | Khi Disk Usage vượt `Y_DISK`% liên tục trong `F_DISK` phút, hệ thống phát sinh cảnh báo và gửi thông báo trong thời gian không quá `X_DISK` phút kể từ khi điều kiện bắt đầu.                                                                                       | Tạo file dung lượng lớn có kiểm soát trên filesystem thử nghiệm để tăng mức sử dụng Disk.                                                                                                                                                                                                                                                                                           | TC06      |
| AC07 | Phát hiện Web Service Down                   | B – Bắt buộc | Khi dịch vụ Nginx ngừng hoạt động hoặc không thể truy cập qua HTTP, hệ thống phát hiện được sự cố và gửi cảnh báo trong thời gian không quá `X_WEB` phút.                                                                                                           | Dừng Nginx hoặc làm dịch vụ không thể truy cập, kiểm tra cảnh báo.                                                                                                                                                                                                                                                                                                                  | TC07      |
| AC08 | Phát hiện Database Unreachable               | B – Bắt buộc | Khi Database không thể truy cập qua phương thức kiểm tra kết nối đã thống nhất, hệ thống phát hiện được sự cố và gửi cảnh báo trong thời gian không quá `X_DB` phút.                                                                                                | Dừng Database hoặc chặn kết nối đến cổng dịch vụ, kiểm tra cảnh báo.                                                                                                                                                                                                                                                                                                                | TC08      |
| AC19 | Phát hiện Prometheus Scrape Target Failure   | B – Bắt buộc | Khi một exporter hoặc target không thể được Prometheus scrape, hệ thống phát hiện trạng thái scrape thất bại và phát sinh cảnh báo trong thời gian không quá `X_SCRAPE` phút.                                                                                       | Dừng exporter hoặc chặn kết nối đến exporter trong khi Server chứa exporter vẫn hoạt động, kiểm tra trạng thái target và cảnh báo.                                                                                                                                                                                                                                                  | TC19      |
| AC09 | Nội dung thông báo cảnh báo                  | B – Bắt buộc | Thông báo Telegram phải có tối thiểu hostname/instance, tên cảnh báo, mức độ nghiêm trọng và thời điểm phát sinh.                                                                                                                                                   | Kích hoạt một cảnh báo và kiểm tra nội dung thông báo nhận được.                                                                                                                                                                                                                                                                                                                    | TC09      |
| AC10 | Thông báo phục hồi                           | B – Bắt buộc | Khi điều kiện gây cảnh báo không còn tồn tại và Alert Rule chuyển sang trạng thái Resolved, hệ thống gửi thông báo phục hồi trong thời gian không quá `W` phút kể từ khi điều kiện được khắc phục.                                                                  | Khắc phục sự cố đang ở trạng thái Firing, ghi nhận thời gian nhận thông báo Resolved.                                                                                                                                                                                                                                                                                               | TC10      |
| AC11 | Hạn chế cảnh báo trùng lặp do sự cố Host     | N – Nên có   | Khi một VM ngừng hoạt động, hệ thống chỉ gửi cảnh báo Host Down (AS-04) và hạn chế các cảnh báo phụ thuộc có cùng nhãn `host` (AS-05 hoặc AS-07, và AS-09 của các exporter trên VM đó). Khi dịch vụ lỗi nhưng VM vẫn hoạt động, cảnh báo dịch vụ vẫn phải được gửi. | Ca 1: ngắt đột ngột VM Web (`VBoxManage controlvm <vm> poweroff` hoặc ngắt card mạng) → chỉ nhận AS-04; AS-05 và AS-09 của VM Web bị hạn chế. Ca 2: ngắt đột ngột VM Database → chỉ nhận AS-04; AS-07 và AS-09 của VM Database bị hạn chế. Ca âm 1: chỉ dừng Nginx khi VM Web vẫn chạy → AS-05 vẫn được gửi. Ca âm 2: chỉ dừng MySQL khi VM Database vẫn chạy → AS-07 vẫn được gửi. | TC11      |

Ghi chú về AC19:

- AC19 được chuyển từ nhóm tiêu chí bổ sung lên nhóm tiêu chí bắt buộc chính thức vì vấn đề gốc PRB09 được phân loại **Bắt buộc** trong `docs/requirements/problem-survey.md` mục 5 và AS-09 được phân loại **Must** trong `docs/requirements/alert-scenarios.md` mục 9.2.
- Mã AC19 và TC19 được giữ nguyên (không đánh số lại) để bảo toàn truy vết với `docs/requirements/alert-scenarios.md`, `docs/requirements/requirements-fr-nfr.md` (FR-07, FR-14, FR-20, NFR-01, NFR-13) và `docs/requirements/baseline.md` (BL-12, BL-13.7).
- AC19 kiểm tra khả năng phát hiện scrape thất bại khi Prometheus vẫn hoạt động. Trường hợp chính Prometheus ngừng hoạt động cần có cơ chế giám sát độc lập nếu muốn bảo đảm phát hiện được sự cố này.
- Phép thử AC19 thực hiện khi Server chứa exporter vẫn hoạt động, để cảnh báo Scrape Target Failure không bị hạn chế bởi quan hệ inhibition AS-04 → AS-09 (mục 6).

Ghi chú về AC11:

- Không dùng lệnh `shutdown` để tắt VM: systemd dừng Nginx/MySQL trước khi mạng mất, khiến HTTP/TCP probe thất bại trước ICMP probe và AS-05/AS-07 có thể chuyển Firing trước AS-04.
- `F_HOST`, `F_WEB_DOWN`, `F_DB` hiện có cùng giá trị Draft (`docs/requirements/baseline.md` BL-07, BL-08, BL-10). Khi kiểm thử cần ghi lại thời điểm Firing của AS-04 và của cảnh báo phụ thuộc để xác nhận AS-04 đã Firing trước khi notification của cảnh báo phụ thuộc được gửi.
- Inhibition chỉ được bật sau khi ICMP probe được xác minh tin cậy trong môi trường thử nghiệm (`docs/requirements/requirements-fr-nfr.md` FR-24).

## 4. Tiêu chí nghiệm thu kỹ thuật và vận hành

| ID   | Tiêu chí                              | Mức độ       | Điều kiện nghiệm thu                                                                                                                                                                                                                             | Phương pháp kiểm thử                                                               | Test Case |
| ---- | ------------------------------------- | ------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ---------------------------------------------------------------------------------- | --------- |
| AC12 | Khả năng tái tạo môi trường           | B – Bắt buộc | Một thành viên khác có thể dựa trên tài liệu hướng dẫn để triển khai lại môi trường trong thời gian không quá `T` giờ và đạt được kết quả AC01, AC02.                                                                                            | Thành viên không trực tiếp xây dựng môi trường thực hiện triển khai theo tài liệu. | TC12      |
| AC13 | Quản lý cấu hình                      | B – Bắt buộc | Các cấu hình Prometheus, Alert Rules và các cấu hình liên quan được quản lý trong Git. Các file cấu hình Prometheus và Alert Rules phải vượt qua kiểm tra cú pháp bằng công cụ phù hợp, ví dụ `promtool check config` và `promtool check rules`. | Kiểm tra repository và chạy các lệnh kiểm tra cấu hình.                            | TC13      |
| AC14 | Kiểm thử ổn định                      | N – Nên có   | Hệ thống chạy liên tục trong khoảng 24–48 giờ mà không xuất hiện tình trạng mất target ngoài dự kiến. Mức sử dụng tài nguyên của Prometheus không vượt quá `R`.                                                                                  | Thực hiện soak test, ghi nhận trạng thái target và mức sử dụng tài nguyên.         | TC14      |
| AC15 | Kiểm thử lặp lại                      | B – Bắt buộc | Mỗi tình huống thuộc AC03–AC08 và AC19 được kiểm thử từ 10–20 lần. Báo cáo phải có thời gian nhỏ nhất, lớn nhất và trung vị của các lần đo.                                                                                                      | Chạy lại từng kịch bản sự cố và tổng hợp kết quả.                                  | TC15      |
| AC16 | Tài liệu giới hạn và hướng phát triển | B – Bắt buộc | Tài liệu phải nêu rõ các giới hạn của Prototype, các chức năng chưa triển khai và hướng phát triển trong tương lai.                                                                                                                              | Rà soát báo cáo kỹ thuật và tài liệu thiết kế.                                     | TC16      |
| AC17 | Khả năng mở rộng thêm Server          | T – Tùy chọn | Khi thêm một Server mới, người triển khai chỉ cần thực hiện một thao tác cấu hình tối thiểu theo thiết kế; Dashboard có thể hiển thị Server mới mà không cần xây dựng lại toàn bộ hệ thống.                                                      | Thêm một target mới và kiểm tra dữ liệu trên Dashboard.                            | TC17      |
| AC18 | Tài liệu và trách nhiệm nhóm          | B – Bắt buộc | Mỗi nhóm hoàn thiện tài liệu thuộc phạm vi phụ trách. Team Leader tổng hợp và kiểm tra tính nhất quán giữa các tài liệu trước khi bàn giao.                                                                                                      | Rà soát tài liệu của các nhóm và kiểm tra tính nhất quán.                          | TC18      |

## 5. Tiêu chí đề xuất mở rộng (chờ chốt phạm vi)

Các tiêu chí dưới đây được đề xuất để hoàn thiện phạm vi kiểm thử cho các tình huống trong Alert Scenarios có mức ưu tiên **Nên có / Should** (PRB06, PRB08, PRB10). Chúng chưa được xem là cam kết nghiệm thu chính thức cho đến khi nhóm thống nhất phạm vi.

| ID   | Tiêu chí                           | Mức độ đề xuất | Điều kiện nghiệm thu                                                                                                                                                       | Phương pháp kiểm thử                                                                                                     | Test Case |
| ---- | ---------------------------------- | -------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------ | --------- |
| AC20 | Phát hiện Web Response Time cao    | N – Nên có     | Khi thời gian phản hồi HTTP vượt ngưỡng `Y_WEB_TIME` trong khoảng thời gian `F_WEB_TIME`, hệ thống phát sinh cảnh báo. Cần bảo đảm ngưỡng cảnh báo thấp hơn probe timeout. | Tạo độ trễ phản hồi có kiểm soát và kiểm tra cảnh báo.                                                                   | TC20      |
| AC21 | Phát hiện Database Connections cao | N – Nên có     | Khi số lượng kết nối Database vượt ngưỡng `Y_DB_CONN` trong khoảng thời gian `F_DB_CONN`, hệ thống phát sinh cảnh báo.                                                     | Tạo các kết nối Database có kiểm soát và kiểm tra cảnh báo.                                                              | TC21      |
| AC22 | Phát hiện lỗi gửi Notification     | N – Nên có     | Hệ thống có khả năng phát hiện lỗi gửi thông báo từ Alertmanager đến receiver và cung cấp thông tin phục vụ việc giám sát lỗi gửi cảnh báo.                                | Mô phỏng lỗi kết nối đến receiver hoặc cấu hình gửi thông báo không thành công, kiểm tra Metrics và trạng thái cảnh báo. | TC22      |

## 6. Quy tắc Alert Inhibition

Hệ thống nên hạn chế các cảnh báo thứ cấp khi đã xác định được sự cố gốc có khả năng gây ra chúng.

### 6.1. Các quan hệ inhibition đề xuất

| Cảnh báo gốc    | Cảnh báo có thể bị hạn chế  | Điều kiện                                                                        |
| --------------- | --------------------------- | -------------------------------------------------------------------------------- |
| AS-04 Host Down | AS-05 Web Service Down      | Cùng nhãn `host` và xác định được Host Down là nguyên nhân gốc.                  |
| AS-04 Host Down | AS-07 Database Unreachable  | Cùng nhãn `host` và xác định được Host Down là nguyên nhân gốc.                  |
| AS-04 Host Down | AS-09 Scrape Target Failure | Cùng nhãn `host` và có đủ căn cứ xác định target không scrape được do Host Down. |

### 6.2. Nguyên tắc bổ sung

- Ghép cảnh báo gốc và cảnh báo phụ thuộc theo nhãn `host` (định danh VM), không theo nhãn `instance`. ICMP probe, HTTP probe, TCP probe và exporter trên cùng một VM có giá trị `instance` khác nhau (địa chỉ, cổng hoặc URL khác nhau), nên ghép theo `instance` sẽ không hạn chế được cảnh báo nào.
- Nhãn `host` phải được gắn nhất quán trên mọi target liên quan (`docs/requirements/requirements-fr-nfr.md` FR-09, FR-24; `docs/requirements/alert-scenarios.md` mục 8.2).
- Không nên mặc định mọi cảnh báo Scrape Failure đều do Host Down. Exporter có thể ngừng hoạt động trong khi Server vẫn hoạt động bình thường.
- Các cảnh báo liên quan đến chính Prometheus hoặc Alertmanager không nên bị hạn chế chỉ vì một Server đích gặp sự cố.

## 7. Phạm vi kiểm thử và giới hạn

- Các ngưỡng CPU, RAM, Disk, Web Response Time và Database Connections sẽ được thống nhất trong giai đoạn Baseline.
- Thời gian cảnh báo và phục hồi phải được đo thực tế, không chỉ suy ra từ cấu hình.
- Các phép thử gây tải phải được thực hiện có kiểm soát, tránh làm ảnh hưởng đến Server hoặc máy host đang sử dụng cho công việc khác.
- Kiểm tra Database Unreachable ở phạm vi tối thiểu có thể sử dụng TCP probe. Điều này chỉ chứng minh khả năng kết nối đến cổng dịch vụ, không chứng minh truy vấn SQL thành công.
- Nếu cần xác nhận Database thực sự xử lý được truy vấn, nhóm cần bổ sung SQL Query Check.
- Kiểm tra Web bằng HTTP probe không đảm bảo toàn bộ chức năng nghiệp vụ của ứng dụng hoạt động bình thường.
- AC19 không chứng minh Prometheus có thể tự phát hiện trường hợp chính nó ngừng hoạt động.
- AC20–AC22 cần được nhóm xác nhận trước khi đưa vào phạm vi nghiệm thu chính thức.
- Cloud Simulation và Data Center Simulation được kiểm thử thông qua các target có thật trên 3 VM của Prototype (phân biệt bằng nhãn `environment`); các tiêu chí trong tài liệu không nghiệm thu hạ tầng Cloud hoặc Data Center thực tế.

## 8. Ma trận truy vết Problem – Alert – Yêu cầu – Acceptance Criteria – Test Case

Nguồn đối chiếu:

- `docs/requirements/problem-survey.md` – PRB01–PRB10.
- `docs/requirements/alert-scenarios.md` – AS-01–AS-10.
- `docs/requirements/requirements-fr-nfr.md` – FR-01–FR-28, NFR-01–NFR-16 (mục 8).
- Tài liệu này – AC01–AC22.

Mã tình huống S1–S6 của `docs/requirements/problem-survey.md` mục 5.1 được thay bằng mã AS-xx để dùng một hệ mã tình huống duy nhất.

### 8.1. Truy vết theo vấn đề (PRB ↔ AS ↔ FR/NFR ↔ AC ↔ TC)

| Problem ID                                               | Ưu tiên (Survey) | Alert ID                                | FR                                                    | NFR                            | AC trực tiếp            | AC dùng chung / liên quan                                     | Test Case                                |
| -------------------------------------------------------- | ---------------- | --------------------------------------- | ----------------------------------------------------- | ------------------------------ | ----------------------- | ------------------------------------------------------------- | ---------------------------------------- |
| PRB01 – CPU sử dụng quá cao                              | Bắt buộc         | AS-01 CPU Usage High                    | FR-01, FR-11, FR-16, FR-21–FR-23, FR-27               | NFR-01–NFR-03                  | AC04                    | AC09, AC10, AC15                                              | TC04; TC09, TC10, TC15                   |
| PRB02 – RAM sử dụng gần hết                              | Bắt buộc         | AS-02 Memory Available Low              | FR-01, FR-11, FR-16, FR-21–FR-23, FR-27               | NFR-01–NFR-03                  | AC05                    | AC09, AC10, AC15                                              | TC05; TC09, TC10, TC15                   |
| PRB03 – Dung lượng ổ đĩa gần đầy                         | Bắt buộc         | AS-03 Disk Usage High                   | FR-01, FR-11, FR-16, FR-21–FR-23, FR-27               | NFR-01–NFR-03, NFR-06          | AC06                    | AC09, AC10, AC15                                              | TC06; TC09, TC10, TC15                   |
| PRB04 – Server mất kết nối hoặc ngừng hoạt động          | Bắt buộc         | AS-04 Host Down                         | FR-02, FR-09, FR-11, FR-17, FR-21–FR-24, FR-27        | NFR-01–NFR-03, NFR-12          | AC03                    | AC09, AC10, AC11, AC15                                        | TC03; TC09, TC10, TC11, TC15             |
| PRB05 – Dịch vụ Web ngừng hoạt động                      | Bắt buộc         | AS-05 Web Service Down                  | FR-03, FR-12, FR-18, FR-21–FR-24, FR-27               | NFR-01–NFR-03                  | AC07                    | AC09, AC10, AC11, AC15                                        | TC07; TC09, TC10, TC11, TC15             |
| PRB06 – Thời gian phản hồi Web tăng bất thường           | Nên có           | AS-06 Web Response Time High            | FR-03, FR-12, FR-18, FR-21–FR-23, FR-27               | NFR-02                         | AC20 (đề xuất)          | AC09, AC10 (khi AC20 được chấp nhận)                          | TC20                                     |
| PRB07 – Database không thể truy cập                      | Bắt buộc         | AS-07 Database Unreachable              | FR-04, FR-05, FR-06, FR-12, FR-19, FR-21–FR-24, FR-27 | NFR-01–NFR-03                  | AC08                    | AC09, AC10, AC11, AC15                                        | TC08; TC09, TC10, TC11, TC15             |
| PRB08 – Số lượng kết nối Database tăng cao               | Nên có           | AS-08 Database Connections High         | FR-05, FR-12, FR-19, FR-21–FR-23, FR-27               | NFR-02                         | AC21 (đề xuất)          | AC09, AC10 (khi AC21 được chấp nhận)                          | TC21                                     |
| PRB09 – Prometheus không thu thập được dữ liệu từ Target | Bắt buộc         | AS-09 Prometheus Scrape Target Failure  | FR-07, FR-09, FR-14, FR-20–FR-24, FR-27               | NFR-01, NFR-02, NFR-04, NFR-13 | AC19 (Bắt buộc từ v0.3) | AC01, AC09, AC10, AC11 (inhibition AS-04 → AS-09), AC14, AC15 | TC19; TC01, TC09, TC10, TC11, TC14, TC15 |
| PRB10 – Alertmanager không gửi được thông báo            | Nên có           | AS-10 Alertmanager Notification Failure | FR-08, FR-14, FR-20, FR-22, FR-27                     | NFR-13                         | AC22 (đề xuất)          | AC16 (giới hạn tự giám sát – NFR-13)                          | TC22; TC16                               |

### 8.2. Truy vết các tiêu chí nền tảng, dùng chung và vận hành (AC ↔ FR/NFR ↔ PRB/AS ↔ TC)

| AC   | Tiêu chí                                     | Mức độ | FR                  | NFR                                          | Problem / Alert liên quan                               | Test Case |
| ---- | -------------------------------------------- | ------ | ------------------- | -------------------------------------------- | ------------------------------------------------------- | --------- |
| AC01 | Thu thập Metrics từ các Server               | B      | FR-01, FR-07        | NFR-07 (AC01 là điều kiện kết thúc của AC12) | Nền dữ liệu cho PRB01–PRB04, PRB09 / AS-01–AS-04, AS-09 | TC01      |
| AC02 | Hiển thị thông tin Monitoring trên Dashboard | B      | FR-10, FR-11, FR-12 | NFR-07, NFR-14                               | PRB01–PRB08 / AS-01–AS-08                               | TC02      |
| AC09 | Nội dung thông báo cảnh báo                  | B      | FR-21, FR-22, FR-25 | NFR-14                                       | PRB01–PRB09 / AS-01–AS-09                               | TC09      |
| AC10 | Thông báo phục hồi                           | B      | FR-23, FR-25        | NFR-02                                       | PRB01–PRB09 / AS-01–AS-09                               | TC10      |
| AC11 | Hạn chế cảnh báo trùng lặp do sự cố Host     | N      | FR-09, FR-24        | –                                            | PRB04, PRB05, PRB07, PRB09 / AS-04, AS-05, AS-07, AS-09 | TC11      |
| AC12 | Khả năng tái tạo môi trường                  | B      | FR-15               | NFR-07, NFR-16 (gián tiếp)                   | –                                                       | TC12      |
| AC13 | Quản lý cấu hình                             | B      | FR-15, FR-26        | NFR-08, NFR-11                               | AS-01–AS-10 (file Alert Rules)                          | TC13      |
| AC14 | Kiểm thử ổn định                             | N      | FR-10               | NFR-04, NFR-05, NFR-06, NFR-16 (gián tiếp)   | PRB09 / AS-09                                           | TC14      |
| AC15 | Kiểm thử lặp lại                             | B      | FR-27               | NFR-03, NFR-12 (điều kiện tiên quyết)        | PRB01–PRB05, PRB07, PRB09 / AS-01–AS-05, AS-07, AS-09   | TC15      |
| AC16 | Tài liệu giới hạn và hướng phát triển        | B      | –                   | NFR-13, NFR-15                               | PRB09, PRB10 (giới hạn tự giám sát)                     | TC16      |
| AC17 | Khả năng mở rộng thêm Server                 | T      | FR-09, FR-15, FR-28 | NFR-08, NFR-09                               | –                                                       | TC17      |
| AC18 | Tài liệu và trách nhiệm nhóm                 | B      | –                   | NFR-15                                       | –                                                       | TC18      |

### 8.3. Kiểm tra độ phủ

| Chiều truy vết                                 | Độ phủ                          | Ghi chú                                                     |
| ---------------------------------------------- | ------------------------------- | ----------------------------------------------------------- |
| Problem ID                                     | 10/10 (PRB01–PRB10)             | Mỗi PRB có ít nhất một AS, một FR, một NFR và một AC        |
| Alert ID                                       | 10/10 (AS-01–AS-10)             | AS-06, AS-08, AS-10 chỉ có AC ở mức đề xuất (AC20–AC22)     |
| Acceptance Criteria                            | 22/22 (AC01–AC22)               | AC03–AC08, AC19–AC22 tại 8.1; AC01, AC02, AC09–AC18 tại 8.2 |
| Test Case                                      | 22/22 (TC01–TC22)               | Ánh xạ 1:1 với AC cùng số thứ tự                            |
| PRB "Bắt buộc" có AC bắt buộc trực tiếp        | 7/7 (PRB01–PRB05, PRB07, PRB09) | Đạt sau khi AC19 được chuyển lên nhóm bắt buộc              |
| PRB "Bắt buộc" thuộc phạm vi kiểm thử lặp AC15 | 7/7                             | Đạt sau khi AC19 được đưa vào phạm vi AC15                  |

Tiêu chí dùng chung:

- **AC09:** Áp dụng cho nội dung các cảnh báo được gửi đến Telegram.
- **AC10:** Áp dụng cho thông báo phục hồi của các cảnh báo có hỗ trợ trạng thái Resolved.
- **AC11:** Áp dụng cho quan hệ giữa cảnh báo Host Down và các cảnh báo dịch vụ, scrape phụ thuộc trên cùng `host`.
- **AC15:** Áp dụng cho các kịch bản kiểm thử AC03–AC08 và AC19, không mặc định áp dụng cho tất cả các tình huống AS-01–AS-10.

Khoảng trống truy vết đã ghi nhận (chưa xử lý trong v0.3):

- FR-13 (lọc Dashboard theo `environment`), NFR-10 (bảo mật cơ bản), NFR-16 (bền vững dữ liệu qua khởi động lại) chưa có AC trực tiếp; `docs/requirements/requirements-fr-nfr.md` mục 8.3 đề xuất AC23, AC24.
- NFR-03 trong `docs/requirements/requirements-fr-nfr.md` vẫn giới hạn kiểm thử lặp ở AS-01–AS-05, AS-07, chưa gồm AS-09 như AC15 bản 0.3.

## 9. Trạng thái xác nhận

| Nội dung                       | Trạng thái                                                                                                         |
| ------------------------------ | ------------------------------------------------------------------------------------------------------------------ |
| AC01–AC18                      | Draft – Chờ rà soát                                                                                                |
| AC19                           | Bắt buộc – Đã chuyển vào Mục 3 từ v0.3 (căn cứ PRB09 "Bắt buộc", AS-09 "Must"); Draft – Chờ rà soát cùng AC01–AC18 |
| AC20–AC22                      | Đề xuất mở rộng – Cần xác nhận phạm vi                                                                             |
| Bảng quy ước tham số (mục 2.3) | Draft – Tham chiếu `docs/requirements/baseline.md`                                                                 |
| Các ngưỡng và thời gian        | Có giá trị Draft Tuần 4 tại `docs/requirements/baseline.md`; chưa phải giá trị nghiệm thu – chốt Tuần 6            |
| Ma trận truy vết               | Draft – Đã đối chiếu 4 chiều với Problem Survey, Alert Scenarios và FR/NFR (24/11/2026)                            |
| Phê duyệt cuối cùng            | Pending                                                                                                            |

Ghi chú:

- Tài liệu sẽ được rà soát và chốt Baseline trong Tuần 6 (06–12/12/2026) sau khi thống nhất phạm vi, thông số cấu hình và khả năng triển khai Prototype.

---

## 10. Lịch sử cập nhật

| Ngày       | Phiên bản | Nội dung                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           |
| ---------- | --------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 21/11/2026 | 0.1       | Tạo bản nháp Acceptance Criteria ban đầu: AC01–AC18, thông số tham chiếu, ma trận truy vết S1–S6.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
| 21/11/2026 | 0.2       | Làm rõ nguyên tắc đo thời gian, sửa cách diễn đạt các tiêu chí AC03–AC08, bổ sung AC19 và đề xuất AC20–AC22, cập nhật ma trận truy vết và Alert Inhibition.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        |
| 24/11/2026 | 0.3       | Chuyển AC19 lên nhóm tiêu chí bắt buộc (sau AC08) theo PRB09 "Bắt buộc" và đưa AC19 vào phạm vi kiểm thử lặp AC15; Mục 5 chỉ còn AC20–AC22. Bổ sung mục 2.3 Bảng quy ước tham số nghiệm thu, phân biệt `F_*` và `X_*`, tham chiếu `docs/requirements/baseline.md`. Đổi `X` → `X_HOST` (AC03), bổ sung `F_DISK` (AC06). Sửa AC11 theo topology 3 VM (2 ca chính, 2 ca âm, ngắt VM đột ngột); Mục 6 ghép inhibition theo nhãn `host` thay cho `instance`. Mở rộng Mục 8 thành ma trận truy vết PRB ↔ AS ↔ FR/NFR ↔ AC ↔ TC, thay mã S1–S6 bằng AS-xx, bổ sung kiểm tra độ phủ. Chuẩn hóa thuật ngữ Server, Cloud Simulation, Data Center Simulation, Monitoring. Chuyển định dạng tài liệu theo khuôn chung của các tài liệu Nhóm 1. |

---

**Tài liệu liên quan:**

- Jira Task: SCRUM-26.
- Jira Task: SCRUM-6 – Khảo sát bài toán giám sát hệ thống.
- Jira Task: SCRUM-8 – Liệt kê và phân loại Metrics.
- Tài liệu: `docs/requirements/problem-survey.md`.
- Tài liệu: `docs/requirements/metrics-inventory.md`.
- Tài liệu: `docs/requirements/alert-scenarios.md`.
- Tài liệu: `docs/requirements/requirements-fr-nfr.md`.
- Tài liệu: `docs/requirements/baseline.md` – nguồn duy nhất của BL-xx.
- Tài liệu tiếp theo: Test Plan (Nhóm 4); Đặc tả cảnh báo chốt (Tuần 6).
