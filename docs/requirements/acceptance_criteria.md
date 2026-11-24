# Acceptance Criteria – Tiêu chí nghiệm thu

**Dự án:** N4.7 – Xây dựng hệ thống giám sát máy chủ, Cloud và trung tâm dữ liệu  
**Nhóm phụ trách:** Nhóm 1 – Phân tích & Thiết kế  
**Người thực hiện:** Ngô Thảo My  
**Ngày tạo:** 21/11/2026  
**Ngày cập nhật:** 21/11/2026  
**Người review:** Chờ review  
**Trạng thái:** Draft – Phiên bản 0.1

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

## 2. Các thông số tham chiếu

| Thông số                       | Ký hiệu  | Giá trị dự kiến | Ghi chú                                             |
| ------------------------------ | -------- | --------------- | --------------------------------------------------- |
| Số lượng VM tối thiểu          | `N`      | Chưa xác định   | Số VM cần giám sát trong Prototype                  |
| Thời gian cảnh báo tối đa      | `X`      | Chưa xác định   | Thời gian từ khi xảy ra sự cố đến khi nhận cảnh báo |
| Ngưỡng CPU                     | `Y_CPU`  | Chưa xác định   | Phần trăm CPU sử dụng                               |
| Ngưỡng RAM                     | `Y_RAM`  | Chưa xác định   | Phần trăm RAM sử dụng                               |
| Ngưỡng Disk                    | `Y_DISK` | Chưa xác định   | Phần trăm Disk sử dụng                              |
| Thời gian phục hồi tối đa      | `W`      | Chưa xác định   | Thời gian nhận thông báo phục hồi                   |
| Thời gian triển khai tối đa    | `T`      | Chưa xác định   | Thời gian thành viên khác dựng lại môi trường       |
| Giới hạn tài nguyên Prometheus | `R`      | Chưa xác định   | Mức sử dụng tài nguyên cho phép                     |

## 3. Tiêu chí nghiệm thu chức năng

### 3.1. Quy ước mức độ

| Mức độ       | Ý nghĩa                                                  |
| ------------ | -------------------------------------------------------- |
| B – Bắt buộc | Tiêu chí cần đạt để Prototype được nghiệm thu.           |
| N – Nên có   | Tiêu chí nên đạt nếu đủ thời gian và điều kiện kỹ thuật. |
| T – Tùy chọn | Tiêu chí mở rộng, thực hiện nếu còn nguồn lực.           |

### 3.2. Bảng tiêu chí

| ID   | Tiêu chí                                   | Mức độ       | Điều kiện nghiệm thu                                                                                                        | Phương pháp kiểm thử                                                     | Test Case |
| ---- | ------------------------------------------ | ------------ | --------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------ | --------- |
| AC01 | Thu thập Metrics từ các máy chủ            | B – Bắt buộc | Prometheus thu thập được Metrics từ tối thiểu `N` VM đã cấu hình. Các target hoạt động bình thường phải có trạng thái `UP`. | Khởi động môi trường, kiểm tra trang Targets của Prometheus.             | TC01      |
| AC02 | Hiển thị thông tin giám sát trên Dashboard | B – Bắt buộc | Grafana hiển thị được CPU, RAM, Disk, Network và trạng thái máy chủ cho các VM đã cấu hình.                                 | Truy cập Dashboard và đối chiếu dữ liệu với nguồn Metrics.               | TC02      |
| AC03 | Phát hiện Host Down                        | B – Bắt buộc | Khi một VM bị tắt hoặc mất kết nối, hệ thống gửi cảnh báo trong vòng `X` phút.                                              | Tắt VM hoặc ngắt kết nối có kiểm soát, ghi nhận thời gian nhận cảnh báo. | TC03      |
| AC04 | Phát hiện CPU Usage cao                    | B – Bắt buộc | Khi CPU Usage vượt `Y_CPU`%, hệ thống gửi cảnh báo trong vòng `X` phút.                                                     | Sử dụng `stress-ng` tạo tải CPU, ghi nhận thời gian nhận cảnh báo.       | TC04      |
| AC05 | Phát hiện Memory Usage cao                 | B – Bắt buộc | Khi Memory Usage vượt `Y_RAM`%, hệ thống gửi cảnh báo trong vòng `X` phút.                                                  | Tạo tải bộ nhớ, ghi nhận thời gian nhận cảnh báo.                        | TC05      |
| AC06 | Phát hiện Disk Usage cao                   | B – Bắt buộc | Khi Disk Usage vượt `Y_DISK`%, hệ thống gửi cảnh báo trong vòng `X` phút.                                                   | Tạo file dung lượng lớn để tăng mức sử dụng Disk.                        | TC06      |
| AC07 | Phát hiện Web Service Down                 | B – Bắt buộc | Khi dịch vụ Nginx ngừng hoạt động, hệ thống gửi cảnh báo trong vòng `X` phút.                                               | Dừng Nginx, kiểm tra cảnh báo.                                           | TC07      |
| AC08 | Phát hiện Database Down                    | B – Bắt buộc | Khi Database ngừng hoạt động, hệ thống gửi cảnh báo trong vòng `X` phút.                                                    | Dừng Database, kiểm tra cảnh báo.                                        | TC08      |
| AC09 | Nội dung thông báo cảnh báo                | B – Bắt buộc | Thông báo Telegram phải có tối thiểu hostname/instance, tên cảnh báo, mức độ nghiêm trọng và thời điểm phát sinh.           | Kích hoạt một cảnh báo và kiểm tra nội dung thông báo nhận được.         | TC09      |
| AC10 | Thông báo phục hồi                         | B – Bắt buộc | Khi sự cố được khắc phục, hệ thống gửi thông báo phục hồi trong vòng `W` phút.                                              | Khắc phục sự cố, ghi nhận thời gian nhận thông báo Resolved.             | TC10      |
| AC11 | Hạn chế cảnh báo trùng lặp do sự cố Host   | N – Nên có   | Khi một VM ngừng hoạt động, hệ thống ưu tiên cảnh báo Host Down và hạn chế gửi các cảnh báo dịch vụ trên cùng VM.           | Tắt một VM đang chạy Web và Database, kiểm tra các cảnh báo phát sinh.   | TC11      |

## 4. Tiêu chí nghiệm thu kỹ thuật và vận hành

| ID   | Tiêu chí                              | Mức độ       | Điều kiện nghiệm thu                                                                                                                                                                              | Phương pháp kiểm thử                                                               | Test Case |
| ---- | ------------------------------------- | ------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------- | --------- |
| AC12 | Khả năng tái tạo môi trường           | B – Bắt buộc | Một thành viên khác có thể dựa trên tài liệu hướng dẫn để triển khai lại môi trường trong thời gian không quá `T` giờ và đạt được kết quả AC01, AC02.                                             | Thành viên không trực tiếp xây dựng môi trường thực hiện triển khai theo tài liệu. | TC12      |
| AC13 | Quản lý cấu hình                      | B – Bắt buộc | Các cấu hình Prometheus, Alert Rules và các cấu hình liên quan được quản lý trong Git. Các file cấu hình phải vượt qua kiểm tra cú pháp, ví dụ `promtool check config` và `promtool check rules`. | Kiểm tra repository và chạy các lệnh kiểm tra cấu hình.                            | TC13      |
| AC14 | Kiểm thử ổn định                      | N – Nên có   | Hệ thống chạy liên tục trong khoảng 24–48 giờ mà không xuất hiện tình trạng mất target ngoài dự kiến. Mức sử dụng tài nguyên của Prometheus không vượt quá `R`.                                   | Thực hiện soak test, ghi nhận trạng thái target và mức sử dụng tài nguyên.         | TC14      |
| AC15 | Kiểm thử lặp lại                      | B – Bắt buộc | Mỗi tình huống thuộc AC03–AC08 được kiểm thử từ 10–20 lần. Báo cáo phải có thời gian nhỏ nhất, lớn nhất và trung vị của các lần đo.                                                               | Chạy lại từng kịch bản sự cố và tổng hợp kết quả.                                  | TC15      |
| AC16 | Tài liệu giới hạn và hướng phát triển | B – Bắt buộc | Tài liệu phải nêu rõ các giới hạn của Prototype, các chức năng chưa triển khai và hướng phát triển trong tương lai.                                                                               | Rà soát báo cáo kỹ thuật và tài liệu thiết kế.                                     | TC16      |
| AC17 | Khả năng mở rộng thêm máy chủ         | T – Tùy chọn | Khi thêm một máy chủ mới, người triển khai chỉ cần thực hiện một thao tác cấu hình tối thiểu theo thiết kế; Dashboard có thể hiển thị máy chủ mới mà không cần xây dựng lại toàn bộ hệ thống.     | Thêm một target mới và kiểm tra dữ liệu trên Dashboard.                            | TC17      |
| AC18 | Tài liệu và trách nhiệm nhóm          | B – Bắt buộc | Mỗi nhóm hoàn thiện tài liệu thuộc phạm vi phụ trách. Team Leader tổng hợp và kiểm tra tính nhất quán giữa các tài liệu trước khi bàn giao.                                                       | Rà soát tài liệu của các nhóm và kiểm tra tính nhất quán.                          | TC18      |

## 5. Phạm vi kiểm thử và giới hạn

- Các ngưỡng CPU, RAM, Disk và thời gian cảnh báo sẽ được thống nhất trong giai đoạn Baseline.
- Thời gian cảnh báo và phục hồi phải được đo thực tế, không chỉ suy ra từ cấu hình.
- Các phép thử gây tải phải được thực hiện có kiểm soát, tránh làm ảnh hưởng đến máy chủ đang sử dụng cho công việc khác.
- Phương thức kiểm tra Database (TCP hoặc truy vấn SQL) sẽ được thống nhất trong giai đoạn thiết kế.

## 6. Ma trận truy vết Problem Survey – Acceptance Criteria

| Mã tình huống | Tình huống                               | Vấn đề liên quan | Tiêu chí nghiệm thu |
| ------------- | ---------------------------------------- | ---------------- | ------------------- |
| S1            | Máy chủ mất kết nối (Host Down)          | PRB04            | AC03                |
| S2            | CPU vượt ngưỡng (CPU High)               | PRB01            | AC04                |
| S3            | RAM vượt ngưỡng (Memory High)            | PRB02            | AC05                |
| S4            | Disk gần đầy (Disk Usage High)           | PRB03            | AC06                |
| S5            | Nginx ngừng hoạt động (Web Service Down) | PRB05            | AC07                |
| S6            | Database không hoạt động (Database Down) | PRB07            | AC08                |

Ghi chú:

- Mã tình huống S1–S6 kế thừa từ `problem-survey.md` mục 5.1.
- PRB06, PRB08, PRB09 và PRB10 chưa có tiêu chí nghiệm thu trực tiếp; sẽ được xem xét sau khi hoàn thành tài liệu Alert Scenarios.

## 7. Trạng thái xác nhận

| Nội dung                | Trạng thái          |
| ----------------------- | ------------------- |
| AC01–AC18               | Draft – Chờ rà soát |
| Các ngưỡng và thời gian | Chưa xác định       |
| Ma trận truy vết        | Draft               |
| Phê duyệt cuối cùng     | Pending             |

Ghi chú:

- Tài liệu sẽ được rà soát và chốt Baseline trong Tuần 6 (06–12/12/2026) sau khi thống nhất phạm vi, thông số cấu hình và khả năng triển khai Prototype.

---

## 8. Lịch sử cập nhật

| Ngày       | Phiên bản | Nội dung                                                                                          |
| ---------- | --------- | ------------------------------------------------------------------------------------------------- |
| 21/11/2026 | 0.1       | Tạo bản nháp Acceptance Criteria ban đầu: AC01–AC18, thông số tham chiếu, ma trận truy vết S1–S6. |

---

**Tài liệu liên quan:**

- Jira Task: SCRUM-6 – Khảo sát bài toán giám sát hệ thống.
- Jira Task: SCRUM-8 – Liệt kê và phân loại Metrics.
- Tài liệu: `problem-survey.md`.
- Tài liệu: `metrics-inventory.md`.
- Tài liệu tiếp theo: Alert Scenarios – Xây dựng tình huống cảnh báo.
