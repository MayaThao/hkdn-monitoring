**Đề tài:** Xây dựng hệ thống giám sát máy chủ, Cloud và trung tâm dữ liệu  
**Nhóm thực hiện:** Nguyễn Ngọc Cẩm Ngò, Phan Khánh Du  
**Bộ phận:** Kiểm thử (Testing)

---

## 1. Tổng quan về kiểm thử phần mềm

### 1.1. Kiểm thử phần mềm là gì?

**Kiểm thử phần mềm (Software Testing)** là hoạt động đánh giá phần mềm hoặc hệ thống nhằm xem xét sản phẩm có đáp ứng các yêu cầu đã đặt ra hay không và phát hiện những sai lệch có thể xảy ra.

Ở góc độ nhóm kiểm thử, công việc không chỉ là chạy thử hệ thống. Nhóm cần tìm hiểu yêu cầu, xác định phạm vi cần kiểm tra, chuẩn bị kế hoạch, theo dõi kết quả và ghi nhận những vấn đề phát hiện được.

### 1.2. Mục đích của kiểm thử

- Phát hiện sai sót hoặc những điểm chưa phù hợp với yêu cầu.
- Kiểm tra xem hệ thống có đáp ứng mục tiêu đã đề ra hay không.
- Cung cấp thông tin về chất lượng và tình trạng hoạt động của hệ thống.
- Hỗ trợ nhóm dự án nhận biết rủi ro trước khi nghiệm thu hoặc trình diễn.
- Tạo cơ sở để theo dõi, trao đổi và xử lý các vấn đề phát sinh.

### 1.3. Kiểm thử và gỡ lỗi

| Nội dung            | Kiểm thử (Testing)                                          | Gỡ lỗi (Debugging)                                     |
| ------------------- | ----------------------------------------------------------- | ------------------------------------------------------ |
| Mục đích            | Phát hiện và ghi nhận sai lệch                              | Tìm nguyên nhân và khắc phục lỗi                       |
| Công việc chính     | Đối chiếu kết quả thực tế với yêu cầu hoặc kết quả mong đợi | Phân tích mã nguồn, cấu hình hoặc thành phần liên quan |
| Kết quả             | Kết quả kiểm thử và thông tin vấn đề                        | Nguyên nhân và phần đã được sửa                        |
| Vai trò trong dự án | Nhóm kiểm thử kiểm tra, mô tả và báo cáo vấn đề             | Nhóm phụ trách kỹ thuật phân tích và sửa chữa          |

## 2. Một số thuật ngữ kiểm thử cơ bản

| Thuật ngữ          | Ý nghĩa                                                                                                    |
| ------------------ | ---------------------------------------------------------------------------------------------------------- |
| Software Testing   | Hoạt động đánh giá phần mềm/hệ thống để tìm sai lệch và xem xét mức độ đáp ứng yêu cầu                     |
| Defect / Bug       | Sai sót khiến kết quả hoặc hoạt động thực tế khác với yêu cầu                                              |
| Test Plan          | Tài liệu kế hoạch kiểm thử, xác định mục tiêu, phạm vi, chiến lược, môi trường, dữ liệu, tiến độ và rủi ro |
| Test Scenario (TS) | Kịch bản kiểm thử mô tả tình huống cần kiểm tra ở mức tổng quát                                            |
| Test Case (TC)     | Ca kiểm thử mô tả điều kiện, dữ liệu, các bước thực hiện và kết quả mong đợi cụ thể                        |
| Test Data          | Dữ liệu được chuẩn bị hoặc sử dụng cho hoạt động kiểm thử                                                  |
| Test Environment   | Môi trường phần cứng, phần mềm, hệ điều hành, mạng và cấu hình phục vụ kiểm thử                            |
| Expected Result    | Kết quả mong đợi theo yêu cầu                                                                              |
| Actual Result      | Kết quả thực tế thu được khi thực hiện kiểm thử                                                            |
| Entry Criteria     | Điều kiện cần đáp ứng trước khi bắt đầu một hoạt động kiểm thử                                             |
| Exit Criteria      | Điều kiện dùng để xác định khi nào có thể kết thúc hoạt động kiểm thử                                      |
| Retesting          | Kiểm tra lại nội dung đã được sửa để xác nhận vấn đề trước đó đã được khắc phục                            |
| Regression Testing | Kiểm tra những chức năng liên quan để xem thay đổi có gây ảnh hưởng ngoài dự kiến hay không                |

### 2.1. Phân biệt Test Plan, Test Scenario và Test Case

- **Test Plan:** xác định định hướng và cách tổ chức hoạt động kiểm thử: kiểm thử nội dung gì, trong phạm vi nào, sử dụng môi trường và công cụ nào, ai phụ trách và thực hiện theo tiến độ nào.
- **Test Scenario:** mô tả một tình huống hoặc luồng cần kiểm tra ở mức tổng quát.
- **Test Case:** cụ thể hóa tình huống thành các điều kiện, dữ liệu, bước thực hiện và kết quả mong đợi.

## 3. Bảy nguyên tắc kiểm thử

1. **Kiểm thử cho thấy sự hiện diện của lỗi:** kiểm thử có thể phát hiện lỗi nhưng không thể chứng minh chắc chắn hệ thống hoàn toàn không còn lỗi.
2. **Không thể kiểm thử toàn diện mọi trường hợp:** số lượng tổ hợp dữ liệu và tình huống có thể rất lớn.
3. **Kiểm thử sớm giúp tiết kiệm thời gian và chi phí:** phát hiện vấn đề từ sớm thường giúp việc xử lý thuận lợi hơn.
4. **Lỗi thường tập trung ở một số khu vực:** những thành phần phức tạp hoặc thường xuyên thay đổi có thể cần được chú ý nhiều hơn.
5. **Lặp lại cùng một bộ kiểm thử có thể giảm hiệu quả:** cần xem xét cập nhật nội dung kiểm thử khi hệ thống thay đổi.
6. **Kiểm thử phụ thuộc vào bối cảnh:** phương pháp kiểm thử cần phù hợp với loại hệ thống và mục tiêu dự án.
7. **Không có lỗi được phát hiện không đồng nghĩa sản phẩm đáp ứng mọi nhu cầu:** hệ thống vẫn cần được đánh giá dựa trên yêu cầu thực tế.

## 4. Các mức kiểm thử

| Mức kiểm thử             | Nội dung khái quát                                        | Liên hệ với đề tài                                                                        |
| ------------------------ | --------------------------------------------------------- | ----------------------------------------------------------------------------------------- |
| Unit / Component Testing | Kiểm tra một đơn vị hoặc thành phần riêng lẻ              | Có thể xem xét từng thành phần giám sát khi phạm vi và trách nhiệm kiểm thử được xác định |
| Integration Testing      | Kiểm tra sự kết nối và phối hợp giữa các thành phần       | Xem xét luồng trao đổi dữ liệu giữa Exporter, Prometheus, Grafana và Alertmanager         |
| System Testing           | Đánh giá hệ thống tổng thể theo yêu cầu                   | Xem xét hoạt động chung của hệ thống giám sát                                             |
| Acceptance Testing       | Đánh giá hệ thống có đáp ứng tiêu chí chấp nhận hay không | Đối chiếu kết quả hệ thống với yêu cầu đã thống nhất trước khi nghiệm thu hoặc trình diễn |

## 5. Các kỹ thuật và loại kiểm thử

### 5.1. Kỹ thuật kiểm thử theo mức độ hiểu biết về bên trong hệ thống

| Kỹ thuật          | Nội dung                                                                       |
| ----------------- | ------------------------------------------------------------------------------ |
| Black-box Testing | Kiểm thử dựa trên đầu vào và đầu ra, không cần xem cấu trúc mã nguồn bên trong |
| White-box Testing | Kiểm thử dựa trên cấu trúc, logic hoặc mã nguồn bên trong                      |
| Grey-box Testing  | Kết hợp kiểm tra đầu vào/đầu ra với một phần hiểu biết về cấu trúc bên trong   |

### 5.2. Một số loại kiểm thử thường gặp

| Loại kiểm thử            | Nội dung khái quát                                                     |
| ------------------------ | ---------------------------------------------------------------------- |
| Functional Testing       | Kiểm tra chức năng có hoạt động theo yêu cầu hay không                 |
| Non-functional Testing   | Đánh giá các đặc tính chất lượng như hiệu năng, độ ổn định và khả dụng |
| API Testing              | Kiểm tra khả năng tiếp nhận và phản hồi yêu cầu của API                |
| Performance Testing      | Đánh giá thời gian phản hồi và khả năng xử lý tải                      |
| Stability / Soak Testing | Theo dõi hệ thống trong một khoảng thời gian để xem xét độ ổn định     |
| Alert Testing            | Kiểm tra hoạt động cảnh báo theo điều kiện đã được cấu hình            |

## 6. Khái quát về quy trình kiểm thử

Một quy trình kiểm thử tổng quát có thể gồm các hoạt động sau:

```text
Tìm hiểu và phân tích yêu cầu
             ↓
Xây dựng Test Plan
             ↓
Thiết kế Test Scenario và Test Case
             ↓
Chuẩn bị môi trường và dữ liệu
             ↓
Thực hiện kiểm thử
             ↓
Ghi nhận và báo cáo kết quả
             ↓
Kiểm thử lại / kiểm thử hồi quy khi cần
             ↓
Tổng hợp và kết thúc đợt kiểm thử
```

## 7. Kiến thức nền về hệ thống giám sát

Để xây dựng khung Test Plan phù hợp với đề tài, cần hiểu sơ bộ vai trò của những thành phần chính trong hệ thống giám sát.

| Thuật ngữ / Thành phần | Ý nghĩa khái quát                                                          |
| ---------------------- | -------------------------------------------------------------------------- |
| Metric                 | Số liệu đo lường theo thời gian, ví dụ CPU, RAM, Disk, Network hoặc Uptime |
| Exporter               | Thành phần cung cấp metric để Prometheus thu thập                          |
| Scrape                 | Quá trình Prometheus định kỳ lấy dữ liệu từ một target                     |
| Target                 | Đối tượng hoặc endpoint được Prometheus cấu hình để thu thập dữ liệu       |
| PromQL                 | Ngôn ngữ truy vấn dữ liệu của Prometheus                                   |
| Alert Rule             | Điều kiện được cấu hình để phát sinh cảnh báo                              |
| Alertmanager           | Thành phần tiếp nhận và xử lý thông báo cảnh báo                           |
| Dashboard              | Giao diện trực quan hóa dữ liệu giám sát, ví dụ trên Grafana               |
| Cloud Monitoring       | Nhóm dịch vụ hoặc chức năng giám sát tài nguyên trên nền tảng Cloud        |

### 7.1. Vai trò tổng quát của các thành phần trong đề tài

| Thành phần        | Vai trò                                                                           |
| ----------------- | --------------------------------------------------------------------------------- |
| Prometheus        | Thu thập, lưu trữ và hỗ trợ truy vấn metric                                       |
| Node Exporter     | Cung cấp metric liên quan đến máy chủ                                             |
| Grafana           | Hiển thị dữ liệu giám sát dưới dạng dashboard                                     |
| Alertmanager      | Tiếp nhận và xử lý thông báo cảnh báo                                             |
| Blackbox Exporter | Hỗ trợ kiểm tra khả năng truy cập endpoint hoặc dịch vụ theo cấu hình             |
| Cloud Monitoring  | Phục vụ giám sát tài nguyên trên môi trường Cloud theo phạm vi triển khai thực tế |

## 8. Các nội dung cần có trong khung Test Plan

| STT | Hạng mục              | Nội dung cần phác thảo                                                                                   |
| --: | --------------------- | -------------------------------------------------------------------------------------------------------- |
|   1 | Thông tin chung       | Tên đề tài, thành viên, thời gian và thông tin tài liệu                                                  |
|   2 | Mục tiêu kiểm thử     | Nêu mục đích và những khía cạnh chất lượng cần xem xét                                                   |
|   3 | Phạm vi kiểm thử      | Xác định thành phần hoặc nội dung dự kiến nằm trong và ngoài phạm vi                                     |
|   4 | Đối tượng kiểm thử    | Liệt kê hệ thống, máy chủ, dịch vụ và thành phần liên quan                                               |
|   5 | Chiến lược kiểm thử   | Nêu định hướng, mức và loại kiểm thử dự kiến                                                             |
|   6 | Test Environment      | Mô tả máy tính, máy ảo, hệ điều hành, mạng, phần mềm và công cụ dự kiến sử dụng                          |
|   7 | Test Data             | Nêu các nhóm dữ liệu dự kiến cần chuẩn bị, chẳng hạn địa chỉ IP, URL dịch vụ, metric và dữ liệu cấu hình |
|   8 | Entry Criteria        | Nêu điều kiện cần có trước khi bắt đầu hoạt động kiểm thử                                                |
|   9 | Exit Criteria         | Nêu điều kiện dự kiến để kết thúc hoạt động kiểm thử                                                     |
|  10 | Tiêu chí Pass/Fail    | Xác định nguyên tắc đánh giá kết quả kiểm thử                                                            |
|  11 | Kế hoạch và phân công | Phân chia công việc và tiến độ theo từng tuần                                                            |
|  12 | Rủi ro và biện pháp   | Nhận diện những yếu tố có thể ảnh hưởng đến tiến độ hoặc khả năng kiểm thử                               |
