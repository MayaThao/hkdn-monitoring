## Xây dựng khung Test Plan cho hệ thống giám sát

**Đề tài:** Xây dựng hệ thống giám sát máy chủ, Cloud và trung tâm dữ liệu  
**Nhóm thực hiện:** Nguyễn Ngọc Cẩm Ngò, Phan Khánh Du  
**Tuần thực hiện:** Tuần 3  
**Bộ phận:** Kiểm thử (Testing)

---

## 1. Mục tiêu công việc trong tuần

Tìm hiểu những kiến thức nền tảng về kiểm thử phần mềm và xây dựng bố cục ban đầu cho tài liệu Test Plan của đề tài.
Các mục tiêu cụ thể:

- Tìm hiểu khái niệm, mục đích và vai trò của kiểm thử phần mềm.
- Tìm hiểu các mức kiểm thử, loại kiểm thử và quy trình kiểm thử cơ bản.
- Xem xét các thành phần chính của hệ thống giám sát để xác định phạm vi kiểm thử dự kiến.
- Xây dựng khung Test Plan gồm các mục cần thiết, làm cơ sở để bổ sung nội dung chi tiết trong tuần 4.

## 2. Công việc được phân công

| Thành viên          | Công việc được phân công                                                                     |
| ------------------- | -------------------------------------------------------------------------------------------- |
| Nguyễn Ngọc Cẩm Ngò | Tìm hiểu và xác định mục tiêu kiểm thử, phạm vi kiểm thử, đối tượng kiểm thử                 |
| Phan Khánh Du       | Tìm hiểu và xác định chiến lược kiểm thử, môi trường kiểm thử và các công cụ dự kiến sử dụng |
| Cả nhóm             | Tìm hiểu kiến thức kiểm thử phần mềm, trao đổi và thống nhất bố cục Test Plan                |

## 3. Công việc đã thực hiện

### 3.1. Tìm hiểu kiến thức kiểm thử phần mềm

Nhóm đã tìm hiểu khái niệm kiểm thử phần mềm, mục đích của hoạt động kiểm thử và một số thuật ngữ cơ bản. Qua đó, nhóm hiểu rằng kiểm thử không chỉ là chạy thử chương trình mà còn là quá trình đối chiếu kết quả thực tế với yêu cầu hoặc kết quả mong đợi.

Một số nội dung đã tìm hiểu:

- Vai trò của kiểm thử trong việc phát hiện sai sót và cung cấp thông tin về chất lượng sản phẩm.
- Sự khác nhau giữa Test Plan, Test Scenario và Test Case.
- Ý nghĩa của dữ liệu kiểm thử và môi trường kiểm thử.
- Mục đích của kiểm thử lại (Retesting) và kiểm thử hồi quy (Regression Testing).
- Các mức và kỹ thuật kiểm thử có thể áp dụng cho hệ thống.

### 3.2. Tìm hiểu các thành phần của hệ thống cần kiểm thử

Dựa trên phạm vi đề tài, nhóm đã bước đầu liệt kê các thành phần có liên quan đến hoạt động giám sát, bao gồm:

- **Prometheus:** thành phần thu thập và lưu trữ dữ liệu metric.
- **Node Exporter:** cung cấp các metric liên quan đến tài nguyên máy chủ.
- **Grafana:** hiển thị dữ liệu giám sát dưới dạng dashboard.
- **Alertmanager:** tiếp nhận và xử lý các cảnh báo do Prometheus gửi đến.
- **Blackbox Exporter:** dự kiến dùng để kiểm tra khả năng truy cập của các dịch vụ hoặc endpoint.
- **Cloud Monitoring:** nội dung giám sát trên môi trường Cloud theo phạm vi triển khai thực tế của dự án.
- **API và kết nối giữa các thành phần:** các điểm cần kiểm tra để xác nhận dữ liệu có thể được thu thập và truy xuất.

Danh sách trên là phạm vi dự kiến trong khung Test Plan. Các nội dung sẽ được rà soát và điều chỉnh theo cấu hình triển khai thực tế của nhóm Hạ tầng và nhóm phát triển.

### 3.3. Xây dựng bố cục Test Plan

Nhóm đã thống nhất khung Test Plan ban đầu gồm 12 mục. Mỗi mục được xác định nội dung chính để thuận tiện cho việc phân công và hoàn thiện ở tuần tiếp theo.

| STT | Hạng mục              | Nội dung dự kiến                                                                                                              |
| --: | --------------------- | ----------------------------------------------------------------------------------------------------------------------------- |
|   1 | Thông tin chung       | Tên đề tài, thành viên, loại kiểm thử, phương pháp, môi trường và công cụ                                                     |
|   2 | Mục tiêu kiểm thử     | Xác định những khía cạnh cần đánh giá như hoạt động hệ thống, thu thập dữ liệu, API, giao diện, cảnh báo và hiệu năng         |
|   3 | Phạm vi kiểm thử      | Các thành phần dự kiến kiểm tra: Prometheus, Node Exporter, Grafana, Alertmanager, Blackbox Exporter, Cloud Monitoring và API |
|   4 | Đối tượng kiểm thử    | VM1 (Monitoring Server), VM2 (Web Server), Prometheus API, dashboard, Alertmanager và kết nối giữa các máy ảo                 |
|   5 | Chiến lược kiểm thử   | Các hoạt động kiểm thử hệ thống, tích hợp, API, giao diện, hiệu năng, độ ổn định và cảnh báo                                  |
|   6 | Môi trường kiểm thử   | Máy ảo Ubuntu Server, máy cá nhân Windows, mạng kết nối và danh sách công cụ                                                  |
|   7 | Dữ liệu kiểm thử      | Địa chỉ IP, URL dịch vụ, truy vấn PromQL, dữ liệu metric và luật cảnh báo                                                     |
|   8 | Điều kiện bắt đầu     | Máy ảo, công cụ, target, địa chỉ IP và cổng dịch vụ đã sẵn sàng                                                               |
|   9 | Điều kiện kết thúc    | Test Case đã được thực hiện theo kế hoạch, kết quả được ghi nhận và báo cáo được cập nhật                                     |
|  10 | Tiêu chí Pass/Fail    | Quy định cách đánh giá PASS, FAIL, BLOCKED và NOT RUN                                                                         |
|  11 | Kế hoạch và phân công | Tiến độ thực hiện, công việc và trách nhiệm của hai thành viên theo từng tuần                                                 |
|  12 | Rủi ro và biện pháp   | Các rủi ro như máy ảo chậm, mất kết nối Exporter, dashboard không có dữ liệu hoặc thiếu môi trường Cloud thực tế              |

### 3.4. Xác định một số nội dung cần lưu ý trong Test Plan

Trong quá trình xây dựng khung, nhóm xác định cần mô tả rõ điều kiện môi trường trước khi bắt đầu kiểm thử. Ví dụ, để kiểm tra dữ liệu từ Node Exporter trên Prometheus, máy chủ liên quan cần hoạt động, kết nối mạng phải thông suốt và target phải được cấu hình phù hợp.

Nhóm cũng dự kiến sử dụng các trạng thái kết quả để tránh đánh giá sai tình hình:

- **PASS:** kết quả thực tế đáp ứng kết quả mong đợi.
- **FAIL:** đã thực hiện kiểm thử nhưng kết quả không đáp ứng yêu cầu.
- **BLOCKED:** chưa thể thực hiện hoặc hoàn tất kiểm thử do phụ thuộc môi trường, quyền truy cập hoặc điều kiện bên ngoài.
- **NOT RUN:** chưa tiến hành kiểm thử.

Việc phân biệt các trạng thái này giúp báo cáo phản ánh đúng tình trạng kiểm thử, đặc biệt khi môi trường máy ảo hoặc dịch vụ phụ thuộc chưa sẵn sàng.

## 4. Kết quả đạt được

Sau các công việc trong tuần, nhóm đạt được những kết quả ban đầu sau:

1. Đã tìm hiểu các khái niệm và thuật ngữ nền tảng của kiểm thử phần mềm.
2. Đã nhận diện các thành phần chính của hệ thống giám sát có liên quan đến phạm vi kiểm thử.
3. Đã bước đầu xác định mục tiêu, phạm vi, đối tượng, chiến lược và môi trường kiểm thử dự kiến.
4. Đã thống nhất một số trạng thái đánh giá kết quả kiểm thử để sử dụng trong quá trình thực hiện.
5. Đã có cơ sở để tiếp tục bổ sung nội dung chi tiết cho Test Plan trong tuần 4.

**Sản phẩm/kết quả của tuần:**

- Khung Test Plan ban đầu.
- Nội dung ghi chú về kiến thức kiểm thử phần mềm.
- Danh sách thành phần hệ thống dự kiến đưa vào phạm vi kiểm thử.

## 5. Kế hoạch công việc tuần 4

| Thành viên          | Công việc dự kiến                                                            |
| ------------------- | ---------------------------------------------------------------------------- |
| Nguyễn Ngọc Cẩm Ngò | Bổ sung chi tiết mục tiêu, phạm vi, đối tượng và chiến lược kiểm thử         |
| Phan Khánh Du       | Bổ sung chi tiết môi trường, dữ liệu, tiêu chí Pass/Fail, kế hoạch và rủi ro |
| Cả nhóm             | Rà soát nội dung, thống nhất thuật ngữ và hoàn thiện Test Plan               |
