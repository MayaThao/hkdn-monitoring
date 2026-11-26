# Khung Test Plan Tuần 4

N4.7  |  Hệ thống giám sát máy chủ, Cloud và trung tâm dữ liệu

Kế hoạch kiểm thử prototype Monitoring trên 3 VM. Tài liệu liên kết yêu cầu FR/NFR, tình huống AS và tiêu chí AC; xác định cách chạy, bằng chứng và điều kiện đạt. Đây là khung lập kế hoạch, chưa phải biên bản kết quả chạy. Mọi ngưỡng và thời gian đo lấy từ `baseline.md` (BL-xx), không đặt lại trong tài liệu này.

## 1. Thông tin và mục tiêu

| Mục | Nội dung |
| --- | --- |
| Dự án / mã yêu cầu | N4.7 Monitoring / SCRUM-46; Test Plan Nhóm 4 |
| Mốc | Tuần 4 – hoàn thiện khung kiểm thử |
| Mục tiêu | Xác định coverage và phương pháp kiểm chứng yêu cầu FR-01–FR-28, NFR-01–NFR-16 và AS-01–AS-10 trong phạm vi prototype. |
| Phạm vi hạ tầng | 3 VM: VM1 Monitoring (Prometheus, Grafana, Alertmanager, Blackbox Exporter, Node Exporter); VM2 Web (Nginx, Node Exporter); VM3 Database (MySQL, mysqld_exporter, Node Exporter). |
| Kênh cảnh báo | Telegram, 1 receiver chính; không ghi token hoặc bí mật trong tài liệu. |
| Phiên bản / trạng thái | 0.2 – cập nhật theo requirements-fr-nfr; kế hoạch. Trạng thái test case mặc định: Not Run. |
| Người chạy / ngày / commit | Điền tại mỗi phiên thực hiện. |

## 2. Quy ước, phạm vi và giới hạn

| Quy ước | Áp dụng trong kế hoạch |
| --- | --- |
| Phạm vi P | Prototype – triển khai và kiểm thử thật trên 3 VM. |
| Phạm vi M | Mô phỏng logic trên chính 3 VM, dùng nhãn `environment` và kịch bản sự cố có kiểm soát; không thêm hạ tầng. |
| Phạm vi K | Khảo sát; không triển khai và không nghiệm thu. |
| Nhãn | `environment` chỉ nhận `Server`, `Cloud Simulation`, `Data Center Simulation`; mọi target có `host`; thành phần Monitoring dùng `role="monitoring"`. |
| Cloud / Data Center | Dùng đúng thuật ngữ `Cloud Simulation` / `Data Center Simulation`. Nền tảng Cloud thực tế, phần cứng Data Center thực tế và các hạng mục ngoài 3 VM không thuộc prototype. |
| Baseline | `baseline.md` là nguồn duy nhất cho BL-xx, gồm Y/F/X/W/N/T/R và tham số cấu hình. Nếu chưa có/chưa được duyệt, test case tương ứng Blocked hoặc ghi giá trị Draft theo baseline. |
| Tiêu chí nghiệm thu | Tham chiếu mã AC trong `acceptance_criteria_0.3.md`; không tự suy diễn nội dung AC khi nguồn tiêu chí chi tiết chưa nằm trong tài liệu đầu vào. |
| Ưu tiên | MoSCoW: Must bắt buộc; Should thực hiện khi đủ điều kiện; Could mở rộng. Ghi riêng Phạm vi P/M/K. |

Ngoài phạm vi K: API/autoscaling hoặc dịch vụ thương mại trên nền tảng Cloud thực tế; thiết bị vật lý, IPMI/BMC/RAID, UPS, điện, làm mát, rack, thiết bị mạng SNMP chuyên dụng; nhiều site/cụm; Kubernetes quy mô lớn; tự động khắc phục và giám sát bảo mật chuyên sâu.

## 3. Điều kiện vào, ra và nguyên tắc an toàn

| Điều kiện vào | Điều kiện ra |
| --- | --- |
| Topology 3 VM và target thực tế được ghi nhận; thời gian các VM và máy đo đồng bộ sai lệch ≤ 1 giây theo NFR-12. | Mỗi ca có Pass/Fail/Blocked/Not Run, dấu thời gian, commit/phiên bản và bằng chứng. |
| Các BL cần cho ca đã có trong baseline; khi thiếu baseline value thì không tự đặt ngưỡng để kết luận. | Must trong phạm vi và điều kiện đủ đã chạy; defect và phần phụ thuộc còn mở được ghi rõ. |
| Có quyền thực hiện sự cố kiểm soát được và kế hoạch khôi phục; dùng môi trường test. | Cấu hình/dịch vụ được khôi phục; rule test được dọn; không còn tác động ngoài dự kiến. |
| Rule/config qua `promtool check config`, `promtool check rules`, `amtool check-config` theo loại file. | Báo cáo không tuyên bố đạt nếu chỉ có thiết kế hoặc metric chưa xác minh. |

- Không dừng VM1 để kiểm thử AS-04: Monitoring không thể tự cảnh báo khi chính VM1, Prometheus hoặc Alertmanager ngừng hoạt động (NFR-13).

- AS-04 phải dùng probe kết nối ICMP hoặc TCP độc lập Node Exporter; `up == 0` chỉ dùng cho AS-09, không đủ để kết luận Host Down.

- Chỉ bật inhibition AS-04 → AS-05/AS-07/AS-09 sau khi probe Host Down đã được xác minh tin cậy. AS-09 của role monitoring không bị inhibition.

- Không chạy tải đồng thời; giới hạn stress-ng và thao tác disk; không gây sự cố trên dịch vụ production.

## 4. Ma trận kiểm thử chức năng theo Alert Scenario

Các mã FR/NFR/AC dưới đây là truy vết từ đặc tả. Metric/target ở VM3 hoặc Blackbox chỉ được đánh dấu đạt sau khi kiểm chứng trên môi trường thật. Với AC chỉ mới đề xuất, ghi rõ trạng thái đề xuất; không xem là tiêu chí đã duyệt.

| ID / AS | Tên | Đối tượng / metric | Trace FR / NFR | Trace AC | Phương pháp | Kết quả mong đợi | Ưu tiên / phạm vi |
| --- | --- | --- | --- | --- | --- | --- | --- |
| TC-F01 / AS-01 | CPU Usage High | 3 VM; Node Exporter; `node_cpu_seconds_total` | FR-01,16,21–23,27; NFR-01–03 | AC04,09,10,15 | Tạo CPU load giới hạn trên từng VM theo phạm vi test; đo sự cố→Telegram và khắc phục→Resolved. | Vượt Y_CPU đủ F_CPU mới firing; nhãn severity/host/environment đúng; Telegram nhận firing/resolved; hồi phục đúng BL. | Must / P |
| TC-F02 / AS-02 | Memory Available Low | 3 VM; Node Exporter; MemAvailable và MemTotal/Usage metric | FR-01,16,21–23,27; NFR-01–03 | AC05,09,10,15 | Tạo áp lực RAM giới hạn; sử dụng duy nhất phương pháp đo đã chốt trong baseline. | Vượt Y_RAM đủ F_RAM mới firing; thông báo và resolved đúng; không báo spike ngắn. | Must / P |
| TC-F03 / AS-03 | Disk Usage High | 3 VM; filesystem thuộc phạm vi; avail/size metric | FR-01,16,21–23,27; NFR-01–03 | AC06,09,10,15 | Ghi dữ liệu thử có giới hạn lên filesystem test, xác nhận mount được chọn; xóa dữ liệu sau test. | Vượt Y_DISK đủ F_DISK mới firing; không báo filesystem ngoài phạm vi; khôi phục và resolved. | Must / P |
| TC-F04 / AS-04 | Host Down | VM2, VM3; ICMP hoặc TCP probe độc lập exporter; nhãn `Cloud Simulation`, `host` | FR-02,17,21–24,27; NFR-01–03,12 | AC03,09,10,11,15 | Ngắt probe tới host test theo kịch bản. Không dùng VM1 làm đối tượng tự cảnh báo. | Probe thất bại đủ F_HOST; alert có nhãn đúng; inhibition chỉ hoạt động sau khi probe tin cậy; phát hiện/notification đúng BL. | Must / P+M; ICMP phụ thuộc GĐ-08 |
| TC-F05 / AS-05 | Web Service Down | VM2; HTTP Blackbox probe; `probe_success`, mã HTTP | FR-03,18,21–24,27; NFR-01–03 | AC07,09,10,11,15 | Dừng Nginx hoặc tạo endpoint HTTP lỗi trên VM2 trong khi VM vẫn hoạt động. | HTTP probe thất bại đủ F_WEB_DOWN; phân biệt service down với host down; HTTP status và notification đúng. | Must / P+M; module/mã được cấu hình tường minh |
| TC-F06 / AS-06 | Web Response Time High | VM2; `probe_duration_seconds` và trạng thái HTTP probe | FR-03,18,21–23,27; NFR-02 | AC20 (đề xuất trong đặc tả) | Tạo độ trễ kiểm soát khi probe vẫn thành công. Y_WEB_TIME phải nhỏ hơn probe timeout. | Firing khi thời gian > Y_WEB_TIME đủ F_WEB_TIME và probe success; không firing nếu probe lỗi hoặc timeout không phù hợp. | Should / P+M; AC đề xuất |
| TC-F07 / AS-07 | Database Unreachable | VM3 MySQL TCP 3306; mysqld_exporter bổ trợ | FR-04,05,19,21–24,27; NFR-01–03 | AC08,09,10,11,15 | Chặn TCP 3306 hoặc dừng MySQL test; exporter metric/credential kiểm chứng riêng. | TCP probe thất bại đủ F_DB; báo DB unreachable; khôi phục thì Resolved. Không coi scrape exporter thành công là DB sẵn sàng. | Must / P+M; SQL Availability FR-06 là Could |
| TC-F08 / AS-08 | Database Connections High | VM3; mysqld_exporter connection/current limit metrics | FR-05,19,21–23,27; NFR-02 | AC21 (đề xuất trong đặc tả) | Sinh kết nối kiểm soát trên MySQL test; trước đó xác minh tên metric ở `/metrics`. | Vượt Y_DB_CONN đủ F_DB_CONN mới firing; đúng host/severity; dọn các session; phục hồi đúng W. | Should / P; metric chưa xác minh |
| TC-F09 / AS-09 | Prometheus Scrape Target Failure | Mọi target; `up`, scrape duration/samples; `role="monitoring"` | FR-07,20–24,27; NFR-01,03,04,13 | AC19 (bắt buộc) | Dừng exporter test hoặc chặn scrape tạm thời; kiểm tra target down và khôi phục. | `up=0` đủ F_SCRAPE tạo alert; sau khôi phục `up=1`, alert resolved; chạy lặp theo NFR-03. | Must / P; không áp dụng inhibition lên role monitoring |
| TC-F10 / AS-10 | Alertmanager Notification Failure | Alertmanager metrics: `alertmanager_notifications_failed_total`; dashboard/log | FR-08,20–22,27; NFR-13 | AC22 (đề xuất trong đặc tả) | Tạo lỗi gửi có kiểm soát trong receiver test; xác minh series tồn tại ở giá trị 0 trước khi mô phỏng lỗi. | Metric tăng trong cửa sổ BL-12.1; dashboard nhận diện lỗi. Không yêu cầu Telegram gửi cảnh báo qua chính receiver đang lỗi. | Should / P; AC đề xuất; giới hạn tự giám sát phải nêu |
| TC-F11 / INT | Tích hợp và thông báo | Prometheus → Alertmanager → Telegram | FR-21–25; NFR-14 | AC09, AC10 | Dùng alert test: kiểm tra grouping, tiêu đề/nội dung, severity, host, environment; theo dõi firing và resolved. | Notification đọc được trên điện thoại; có tên alert, severity, host, thời điểm; resolved gửi khi điều kiện hết; hạn chế gửi lặp theo cấu hình. | Must / P; Telegram một receiver |
| TC-F12 / CFG | Cấu hình, provisioning, cleanup | Prometheus, rule, Alertmanager, Blackbox, Grafana files trong Git | FR-15,25,26; NFR-08,10,11 | AC12,13,17 | Chạy validator phù hợp; rà soát file rule, nhãn, secrets, địa chỉ IP và provisioning. | Validator pass; config/dashboard từ Git; không hard-code IP trong rule; không có secrets; labels có cardinality hữu hạn; test rule được xóa. | Must / P |

## 5. Kiểm thử phi chức năng

| Mã | Yêu cầu | Cách kiểm chứng / tiêu chí |
| --- | --- | --- |
| NFR-01 | Notification Time | AS tương ứng; đo từ mốc bắt đầu sự cố đến nhận Telegram; báo riêng Detection Time và Notification Time. Đối chiếu X_* trong BL-13.x. |
| NFR-02 | Recovery Time | Đo từ mốc khắc phục đến notification Resolved; so với W tại BL-13.10. |
| NFR-03 | Độ tin cậy cảnh báo | AS-01–AS-05, AS-07, AS-09: 10–20 lượt; tỷ lệ phát hiện đúng 100%; báo min/max/median; kiểm tra không false alert khi không có sự cố trong phiên. AS-09 có khuyến nghị 10 lần nếu thiếu thời gian theo ghi chú P-21. |
| NFR-04 | Ổn định | Soak test liên tục 24–48 giờ; quan sát `up`, `ALERTS`, target ngoài dự kiến. |
| NFR-05 | Tài nguyên | Trong soak test đo tài nguyên Prometheus và tải exporter trên cả 3 VM; đối chiếu R và BL-15.1–15.4. Không chạy stress case đồng thời. |
| NFR-06 | Lưu trữ | Kiểm tra retention theo BL-14 và dung lượng TSDB; bảo đảm không làm Disk VM1 vượt Y_DISK. |
| NFR-07 | Tái tạo | Thành viên khác dựng theo tài liệu trong ≤ T giờ và đạt AC01, AC02. |
| NFR-08 | Bảo trì | Rà soát cấu hình theo lớp Server/dịch vụ/Monitoring, file rule tách theo AS, không hard-code IP trong rule. |
| NFR-09 | Mở rộng | Đánh giá FR-28 (Could): thêm target/nhãn/nguồn không đổi thành phần lõi; chỉ thực hiện khi có nguồn lực. |
| NFR-10 | Bảo mật cơ bản | Rà Git và firewall: không commit token Telegram, mật khẩu DB/Grafana; đổi Grafana default; exporter chỉ cho VM1 truy cập; DB exporter dùng quyền đọc thống kê. AC24 mới là đề xuất. |
| NFR-11 | Cardinality | Rà relabel; không dùng nhãn biến đổi liên tục; tập `environment`, `host`, `role` hữu hạn và được liệt kê. |
| NFR-12 | Đồng bộ giờ | Trước mỗi phiên đo kiểm tra NTP/chrony trên 3 VM và máy đo; sai lệch ≤ 1 giây. |
| NFR-13 | Giới hạn tự giám sát | Rà tài liệu: không tự phát hiện VM1/Prometheus/Alertmanager down hoặc Telegram lỗi qua chính kênh lỗi. Heartbeat ngoài là Could. |
| NFR-14 | Usability | Rà notification trên điện thoại: dòng tiêu đề có severity, alert name, host; dashboard threshold khớp Y_*. |
| NFR-15 | Thuật ngữ/tài liệu | Rà đúng nhãn environment, thuật ngữ Cloud Simulation/Data Center Simulation, mã truy vết, phạm vi P/M/K. |
| NFR-16 | Bền vững qua restart | Ghi số series/khoảng lịch sử; restart dịch vụ rồi restart VM1; xác nhận dữ liệu, Grafana dashboard/datasource, Alertmanager silence/log còn; không gửi notification trùng. Liên quan AC12/14 gián tiếp, chưa có AC trực tiếp. |

## 6. Truy vết và tình trạng điểm cần chốt

| Nhóm coverage | Liên kết chính | Ghi chú kiểm soát |
| --- | --- | --- |
| AS-01–AS-03 | FR-01, FR-16, FR-21–23, FR-27; NFR-01–03; AC04–06, 09, 10, 15 | Ngưỡng Y_* và F_* chỉ lấy baseline; thống nhất phương pháp RAM; F_DISK cần có trong baseline/AC bản cập nhật. |
| AS-04 | FR-02, FR-17, FR-21–24, FR-27; NFR-01–03,12; AC03,09–11,15 | ICMP phụ thuộc mạng/GĐ-08; dùng TCP probe dự phòng nếu ICMP không khả dụng; phân biệt Host Down và scrape. |
| AS-05–AS-06 | FR-03, FR-18, FR-21–23, FR-27; AC07, AC20 đề xuất | Kiểm thử âm: dừng Nginx khi VM2 vẫn chạy phải phát hiện AS-05; response time chỉ đánh giá khi probe thành công. |
| AS-07–AS-08 | FR-04, FR-05, FR-19; AC08, AC21 đề xuất | MySQL/port 3306 đã chốt; metric mysqld_exporter phải kiểm chứng trên `/metrics`; SQL check FR-06 là Could. |
| AS-09–AS-10 | FR-07, FR-08, FR-20–24; NFR-13; AC19 bắt buộc, AC22 đề xuất | AS-10 chỉ phát hiện qua metric/dashboard; Telegram lỗi có thể khiến chính alert không được gửi. |
| Dashboard/provisioning/security | FR-11–15, FR-26; NFR-08,10,11,14; AC12,13,17 | AC23 (lọc environment/host) và AC24 (secrets/password) là đề xuất bổ sung, chưa phải AC đã phê duyệt. |
| Vận hành dài hạn | FR-10; NFR-04–07,12,16; AC01,02,12,14 | Tách soak, đo tài nguyên, retention, tái tạo môi trường và restart persistence thành các phiên riêng. |

## 7. Quy trình thực hiện và mẫu ghi nhận

1. Ghi phiên bản cấu hình, branch/commit, phiên bản dịch vụ, VM/target, giờ hệ thống và BL áp dụng.

1. Kiểm tra điều kiện vào, metric nền và target health; lưu truy vấn hoặc ảnh trước khi gây sự cố.

1. Sao lưu config; áp dụng đúng một kịch bản sự cố có kiểm soát; ghi các mốc T0 sự cố, T1 detection, T2 Telegram, T3 khắc phục, T4 Resolved.

1. Đối chiếu điều kiện alert, labels, Dashboard, notification, thời gian và trạng thái khôi phục với tiêu chí tương ứng.

1. Khôi phục dịch vụ/tài nguyên; xác nhận metrics bình thường và resolved; xóa alert rule/kịch bản tạm; xác nhận cấu hình sạch.

1. Đặt trạng thái ca; lưu bằng chứng theo ID test case; tạo defect nếu sai khác; không ghi secrets trong ảnh hoặc log.

| Test Case ID | Run # | Trạng thái | T0–T4 / đo được | Bằng chứng | Defect / ghi chú |
| --- | --- | --- | --- | --- | --- |
| Điền mã | 01 | Not Run | TBD | TBD | TBD |

| Trạng thái | Quy tắc |
| --- | --- |
| Pass | Kết quả khớp tiêu chí đã duyệt và có bằng chứng. |
| Fail | Sai khác tái hiện được; ghi bước, dấu thời gian, log/ảnh và defect. |
| Blocked | Thiếu metric, target, baseline, quyết định hoặc quyền thao tác; nêu phụ thuộc. |
| Not Run | Chưa thực hiện; không tính là đạt. |

## 8. Checklist đóng khung tuần 4

- [ ] Xác nhận topology và target trên đủ 3 VM; Node Exporter hiện diện cả VM1/VM2/VM3 theo FR-01.

- [ ] Chốt ngưỡng/phương pháp/for và liên kết giá trị BL từ baseline.md; không chép ngưỡng riêng vào test plan.

- [ ] Xác minh Blackbox ICMP/TCP, HTTP probe và MySQL TCP 3306; xác minh metric mysqld_exporter trên VM3.

- [ ] Xác nhận tiêu chí AC nguồn; đánh dấu rõ AC20/21/22/23/24 nếu còn là đề xuất.

- [ ] Chuẩn bị kịch bản test an toàn, bằng chứng, khôi phục và cleanup cho từng case.

- [ ] Đăng ký các ca NFR-01–16 theo môi trường và lịch của Nhóm 4; NFR-03 cần thời lượng lặp và NFR-04 cần 24–48 giờ.
