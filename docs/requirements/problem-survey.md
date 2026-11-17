# Khảo sát bài toán giám sát hệ thống

**Dự án:** N4.7 – Xây dựng hệ thống giám sát máy chủ, Cloud và trung tâm dữ liệu  
**Nhóm phụ trách:** Nhóm 1 – Phân tích và Thiết kế  
**Mã Jira:** SCRUM-6  
**Người thực hiện:** Nhóm 1  
**Ngày tạo:** 17/11/2026  
**Ngày cập nhật:** 17/11/2026  
**Người review:** Chờ review  
**Trạng thái:** Draft

---

## 1. Tổng quan bài toán

Trong quá trình vận hành hệ thống công nghệ thông tin, máy chủ, dịch vụ Web, cơ sở dữ liệu và hạ tầng mạng có thể gặp nhiều vấn đề như quá tải tài nguyên, mất kết nối, dịch vụ ngừng hoạt động hoặc suy giảm hiệu năng.

Đối với các hệ thống Cloud và trung tâm dữ liệu (Data Center), số lượng thành phần cần quản lý có thể lớn và đa dạng hơn, bao gồm máy chủ vật lý, máy chủ ảo, thiết bị mạng, hệ thống lưu trữ, dịch vụ Cloud và các thành phần hạ tầng liên quan.

Nếu không có cơ chế giám sát phù hợp, người quản trị có thể không phát hiện kịp thời các sự cố. Điều này dẫn đến thời gian xử lý kéo dài, ảnh hưởng đến tính sẵn sàng và chất lượng hoạt động của hệ thống.

Vì vậy, dự án N4.7 hướng đến việc xây dựng một hệ thống giám sát tập trung, có khả năng thu thập dữ liệu hoạt động, hiển thị trạng thái, theo dõi lịch sử và phát hiện những dấu hiệu bất thường để gửi cảnh báo cho người quản trị.

Trong phạm vi prototype ban đầu, nhóm định hướng triển khai trên môi trường máy ảo nhằm mô phỏng một hệ thống gồm máy chủ giám sát, máy chủ Web và máy chủ cơ sở dữ liệu.

## 2. Mục tiêu khảo sát

- Tìm hiểu tổng quan về bài toán giám sát máy chủ, Cloud và Data Center.
- Xác định các đối tượng cần được theo dõi trong hệ thống.
- Nhận diện những vấn đề và sự cố có thể xảy ra trong quá trình vận hành.
- Xác định nhu cầu thu thập dữ liệu, hiển thị trạng thái và thông báo cảnh báo.
- Phân biệt các đối tượng có thể mô phỏng trên môi trường máy ảo và các đối tượng nằm ngoài phạm vi prototype ban đầu.
- Làm cơ sở để xác định Metrics, yêu cầu chức năng và thiết kế kiến trúc hệ thống ở các giai đoạn tiếp theo.

## 3. Phạm vi và môi trường khảo sát

### 3.1. Môi trường triển khai dự kiến

Nhóm định hướng sử dụng 3 máy ảo để mô phỏng môi trường hoạt động của hệ thống.

| Máy ảo | Vai trò           | Thành phần dự kiến                                                               |
| ------ | ----------------- | -------------------------------------------------------------------------------- |
| VM1    | Monitoring Server | Ubuntu Server, Prometheus, Grafana, Alertmanager, Blackbox Exporter              |
| VM2    | Web Server        | Ubuntu Server, Nginx, Node Exporter                                              |
| VM3    | Database Server   | Ubuntu Server, MySQL hoặc PostgreSQL, Node Exporter, Database Exporter tương ứng |

Ghi chú:

- Node Exporter được triển khai trên các máy chủ Linux cần thu thập thông tin tài nguyên hệ điều hành, bao gồm VM2 và VM3. Có thể bổ sung trên VM1 để giám sát chính máy chủ Monitoring.
- Blackbox Exporter được dự kiến đặt trên VM1 để kiểm tra khả năng truy cập các dịch vụ từ góc nhìn bên ngoài.
- Database Exporter được lựa chọn theo hệ quản trị cơ sở dữ liệu mà nhóm quyết định sử dụng.
- Cấu hình tài nguyên và phương án kết nối giữa các VM sẽ được xác định trong giai đoạn thiết kế.
- Cơ sở dữ liệu chưa được lựa chọn chính thức.

### 3.2. Tổng quan về giám sát Cloud

Cloud Computing cung cấp tài nguyên và dịch vụ công nghệ thông tin thông qua mạng, thường bao gồm khả năng cung cấp tài nguyên theo nhu cầu, mở rộng linh hoạt và quản lý tài nguyên tập trung.

Các đối tượng thường được quan tâm khi giám sát môi trường Cloud:

| Nhóm đối tượng           | Nội dung cần quan tâm                                              |
| ------------------------ | ------------------------------------------------------------------ |
| Máy ảo (Virtual Machine) | CPU, RAM, Disk, Network, trạng thái hoạt động                      |
| Hạ tầng mạng Cloud       | Kết nối, lưu lượng, độ trễ, trạng thái các thành phần mạng         |
| Dịch vụ Cloud            | Tình trạng hoạt động, khả năng truy cập, hiệu năng                 |
| Container                | Trạng thái container, mức sử dụng tài nguyên, tình trạng hoạt động |
| Tài nguyên lưu trữ       | Dung lượng, khả năng truy cập, hiệu năng lưu trữ                   |

Trong prototype ban đầu, nhóm có thể mô phỏng một số khía cạnh của môi trường Cloud thông qua các máy ảo Ubuntu Server, dịch vụ Web, Database và hệ thống giám sát tập trung.

Tuy nhiên, mô hình VM tự triển khai trên VirtualBox không đồng nghĩa với việc đã triển khai hoặc giám sát một nền tảng Cloud thực tế. Các thành phần như dịch vụ Cloud thương mại, API quản lý Cloud và tài nguyên Cloud chuyên biệt chưa nằm trong phạm vi đã xác nhận.

### 3.3. Tổng quan về giám sát Data Center

Data Center là môi trường tập trung nhiều thành phần hạ tầng công nghệ thông tin để cung cấp dịch vụ và lưu trữ, xử lý dữ liệu.

Các nhóm đối tượng thường được quan tâm khi giám sát:

| Nhóm đối tượng   | Nội dung cần quan tâm                              |
| ---------------- | -------------------------------------------------- |
| Máy chủ vật lý   | CPU, RAM, Disk, trạng thái phần cứng, nhiệt độ     |
| Hạ tầng mạng     | Switch, Router, kết nối mạng, lưu lượng            |
| Hệ thống lưu trữ | Dung lượng, trạng thái thiết bị, khả năng truy cập |
| Máy chủ ảo hóa   | Máy chủ vật lý, máy ảo, tài nguyên được cấp phát   |
| Hệ thống điện    | Nguồn điện, UPS, tình trạng cấp điện               |
| Hệ thống làm mát | Nhiệt độ, độ ẩm, điều hòa và môi trường phòng máy  |

Trong prototype ban đầu, nhóm có thể mô phỏng một phần hoạt động của hạ tầng máy chủ và dịch vụ bằng các VM, bao gồm giám sát tài nguyên, trạng thái dịch vụ, kết nối mạng và khả năng gửi cảnh báo.

Các thành phần như máy chủ vật lý, UPS, hệ thống làm mát, rack, thiết bị mạng chuyên dụng và cảm biến môi trường chưa được mô phỏng bằng thiết bị thực tế.

Việc có cần mô phỏng thêm nhiều site, nhiều cụm máy chủ hoặc các thành phần đặc trưng của Data Center hay không cần được xác nhận với mentor trước khi mở rộng phạm vi.

### 3.4. Phạm vi khảo sát và triển khai ban đầu

Nhóm chia phạm vi thành hai mức:

**Mức 1 – Phạm vi khảo sát tổng quan:**

- Máy chủ và hệ điều hành.
- Dịch vụ Web.
- Hệ quản trị cơ sở dữ liệu.
- Hạ tầng mạng và máy chủ ảo.
- Các thành phần Cloud và Data Center.
- Nhu cầu giám sát tài nguyên, trạng thái hoạt động và cảnh báo.

**Mức 2 – Phạm vi prototype dự kiến:**

- Giám sát tài nguyên các máy chủ Linux trên môi trường VM.
- Giám sát khả năng truy cập dịch vụ Web.
- Giám sát khả năng truy cập và một số chỉ số hoạt động của Database.
- Giám sát tình trạng thu thập dữ liệu của Prometheus.
- Hiển thị dữ liệu trên Grafana.
- Phát hiện sự cố và gửi cảnh báo thông qua Alertmanager.

Phạm vi prototype trên là định hướng ban đầu, chưa được xem là phạm vi nghiệm thu cuối cùng cho Cloud và Data Center.

## 4. Các đối tượng cần giám sát

Nhóm sử dụng mã định danh OBJ để phục vụ truy vết giữa đối tượng, vấn đề, yêu cầu và kiểm thử.

| Mã đối tượng | Đối tượng                   | Mô tả                                                                 | Phạm vi                                     |
| ------------ | --------------------------- | --------------------------------------------------------------------- | ------------------------------------------- |
| OBJ01        | Máy chủ và hệ điều hành     | Tài nguyên CPU, RAM, Disk, Network và trạng thái hoạt động            | Prototype                                   |
| OBJ02        | Dịch vụ Web                 | Khả năng truy cập, phản hồi và trạng thái dịch vụ Web                 | Prototype                                   |
| OBJ03        | Cơ sở dữ liệu               | Khả năng kết nối và một số chỉ số hoạt động của Database              | Prototype                                   |
| OBJ04        | Hệ thống Monitoring         | Prometheus, Grafana, Alertmanager và quá trình thu thập dữ liệu       | Prototype                                   |
| OBJ05        | Hạ tầng Cloud và máy chủ ảo | Máy ảo, tài nguyên được cấp phát, kết nối và trạng thái dịch vụ Cloud | Khảo sát; mô phỏng một phần                 |
| OBJ06        | Hạ tầng Data Center         | Máy chủ vật lý, thiết bị mạng, lưu trữ, điện và làm mát               | Khảo sát; chưa triển khai phần cứng thực tế |

### 4.1. Máy chủ và hệ điều hành (OBJ01)

Theo dõi tình trạng hoạt động của máy chủ Linux và khả năng cung cấp tài nguyên cho các dịch vụ.

Các khía cạnh cần quan tâm:

- Mức sử dụng CPU.
- Tình trạng bộ nhớ RAM.
- Dung lượng ổ đĩa.
- Hoạt động mạng.
- Thời gian hoạt động.
- Khả năng kết nối và trạng thái máy chủ.

Nguồn dữ liệu dự kiến: Node Exporter và các chỉ số do Prometheus cung cấp.

### 4.2. Dịch vụ Web (OBJ02)

Theo dõi khả năng hoạt động và phản hồi của dịch vụ Web được triển khai trên VM2.

Các khía cạnh cần quan tâm:

- Dịch vụ Web có phản hồi hay không.
- Khả năng truy cập qua HTTP/HTTPS.
- Thời gian phản hồi.
- Mã trạng thái HTTP.
- Khả năng phát hiện khi dịch vụ ngừng phản hồi.

Nguồn dữ liệu dự kiến: Blackbox Exporter để kiểm tra dịch vụ từ bên ngoài. Các chỉ số nội bộ của Nginx có thể được xem xét bổ sung nếu cần.

### 4.3. Cơ sở dữ liệu (OBJ03)

Theo dõi khả năng hoạt động và tình trạng truy cập của hệ quản trị cơ sở dữ liệu trên VM3.

Các khía cạnh cần quan tâm:

| Nội dung                                                  | Nguồn kiểm tra dự kiến                                       |
| --------------------------------------------------------- | ------------------------------------------------------------ |
| Máy chủ Database có thể kết nối qua TCP hay không         | Blackbox Exporter                                            |
| Database có thể thực hiện kết nối hoặc truy vấn hay không | Database Exporter hoặc phương thức kiểm tra truy vấn phù hợp |
| Số lượng kết nối đang sử dụng                             | Database Exporter                                            |
| Tình trạng sử dụng kết nối                                | Database Exporter                                            |
| Hoạt động truy vấn và hiệu năng Database                  | Database Exporter, nếu được hỗ trợ                           |

Lưu ý:

- Kiểm tra TCP chỉ xác nhận cổng dịch vụ có thể truy cập, không chứng minh Database có thể xử lý truy vấn thành công.
- Database Exporter cung cấp các chỉ số chuyên biệt về hệ quản trị cơ sở dữ liệu.
- Các nội dung phân tích hiệu năng Database chuyên sâu được xếp mức ưu tiên thấp trong prototype ban đầu.

### 4.4. Hệ thống Monitoring (OBJ04)

Theo dõi tình trạng hoạt động của chính hệ thống giám sát để bảo đảm quá trình thu thập và xử lý dữ liệu diễn ra bình thường.

Các khía cạnh cần quan tâm:

- Trạng thái hoạt động của Prometheus.
- Khả năng thu thập dữ liệu từ các Target.
- Trạng thái các Target.
- Hoạt động của Grafana và Alertmanager.
- Khả năng xử lý và chuyển tiếp cảnh báo.

Nguồn dữ liệu dự kiến: Các chỉ số nội bộ của Prometheus, trạng thái dịch vụ và các phép kiểm tra phù hợp.

### 4.5. Hạ tầng Cloud và máy chủ ảo (OBJ05)

Khảo sát các đối tượng như máy ảo, tài nguyên được cấp phát, kết nối mạng và trạng thái dịch vụ Cloud.

Trong prototype, nhóm có thể sử dụng các VM trên VirtualBox để mô phỏng một phần hoạt động của máy chủ ảo.

Các nội dung như quản lý tài nguyên qua API của nền tảng Cloud, giám sát dịch vụ Cloud thương mại và tích hợp nhiều nhà cung cấp chưa được xác nhận.

### 4.6. Hạ tầng Data Center (OBJ06)

Khảo sát các thành phần đặc trưng của Data Center như:

- Máy chủ vật lý và thiết bị phần cứng.
- Hạ tầng mạng.
- Hệ thống lưu trữ.
- Hệ thống cấp điện và UPS.
- Hệ thống làm mát và môi trường phòng máy.

Prototype hiện tại tập trung vào các thành phần máy chủ và dịch vụ có thể mô phỏng bằng VM. Việc giám sát phần cứng vật lý, điện, làm mát và môi trường cần có thiết bị hoặc nguồn dữ liệu phù hợp, chưa thuộc phạm vi triển khai ban đầu.

## 5. Các vấn đề vận hành và nhu cầu giám sát

Các vấn đề được nhận diện từ việc phân tích các đối tượng ở mục 4, kiến thức vận hành hệ thống và tài liệu kỹ thuật về những thành phần dự kiến sử dụng.

Các mã PRB được dùng để truy vết vấn đề trong các giai đoạn tiếp theo.

Mức ưu tiên:

- **Bắt buộc:** Cần có trong prototype ban đầu.
- **Nên có:** Có giá trị thực tế, thực hiện nếu đủ thời gian và nguồn lực.
- **Tùy chọn:** Nội dung mở rộng, chưa phải yêu cầu cốt lõi.

| Mã vấn đề | Đối tượng | Vấn đề                                           | Ảnh hưởng                                                   | Nhu cầu giám sát tương ứng                                                            | Ưu tiên  |
| --------- | --------- | ------------------------------------------------ | ----------------------------------------------------------- | ------------------------------------------------------------------------------------- | -------- |
| PRB01     | OBJ01     | CPU sử dụng quá cao                              | Hệ thống xử lý chậm, ảnh hưởng dịch vụ                      | Theo dõi mức sử dụng CPU và phát hiện khi vượt ngưỡng trong khoảng thời gian xác định | Bắt buộc |
| PRB02     | OBJ01     | RAM sử dụng gần hết                              | Nguy cơ thiếu bộ nhớ, tiến trình bị ảnh hưởng               | Theo dõi mức sử dụng và dung lượng RAM còn khả dụng                                   | Bắt buộc |
| PRB03     | OBJ01     | Dung lượng ổ đĩa gần đầy                         | Không thể ghi dữ liệu hoặc lưu trữ log                      | Theo dõi dung lượng đã sử dụng và còn khả dụng                                        | Bắt buộc |
| PRB04     | OBJ01     | Máy chủ mất kết nối hoặc ngừng hoạt động         | Không thể truy cập hoặc sử dụng dịch vụ trên máy chủ        | Phát hiện trạng thái mất kết nối và thời gian không phản hồi                          | Bắt buộc |
| PRB05     | OBJ02     | Dịch vụ Web ngừng hoạt động hoặc không phản hồi  | Người dùng không thể truy cập Web                           | Kiểm tra khả năng truy cập HTTP/HTTPS và trạng thái phản hồi                          | Bắt buộc |
| PRB06     | OBJ02     | Thời gian phản hồi Web tăng bất thường           | Chất lượng dịch vụ suy giảm                                 | Theo dõi thời gian phản hồi và phát hiện khi vượt ngưỡng                              | Nên có   |
| PRB07     | OBJ03     | Database không thể truy cập hoặc kết nối         | Ứng dụng không thể truy xuất dữ liệu                        | Kiểm tra kết nối TCP hoặc khả năng thực hiện truy vấn Database                        | Bắt buộc |
| PRB08     | OBJ03     | Số lượng kết nối Database tăng cao               | Nguy cơ quá tải hoặc từ chối kết nối                        | Theo dõi số lượng kết nối đang sử dụng và giới hạn kết nối                            | Nên có   |
| PRB09     | OBJ04     | Prometheus không thu thập được dữ liệu từ Target | Dashboard thiếu dữ liệu hoặc không phản ánh đúng trạng thái | Theo dõi trạng thái Target, kết quả scrape và lỗi thu thập                            | Bắt buộc |
| PRB10     | OBJ04     | Alertmanager không gửi được thông báo            | Người quản trị không nhận được cảnh báo                     | Theo dõi trạng thái chuyển tiếp và lỗi gửi thông báo                                  | Nên có   |

Ghi chú:

- Các vấn đề trên là kết quả khảo sát ban đầu, chưa phải toàn bộ danh sách Metrics hoặc điều kiện kích hoạt cảnh báo chính thức.
- Những ngưỡng cảnh báo, thời gian duy trì và độ trễ thông báo sẽ được xác định ở các giai đoạn yêu cầu và thiết kế.
- Những vấn đề thuộc Cloud và Data Center ngoài prototype được giữ trong phạm vi khảo sát, chưa được cam kết triển khai.

### 5.1. Ánh xạ sơ bộ với các tình huống cảnh báo

Bảng dưới đây là đề xuất ánh xạ để chuẩn bị cho việc xây dựng sáu tình huống cảnh báo S1–S6 trong kế hoạch dự án. Cần đối chiếu và xác nhận lại với danh sách tình huống cảnh báo chính thức trước khi chốt.

| Mã tình huống | Vấn đề liên quan | Mô tả tình huống dự kiến                                               |
| ------------- | ---------------- | ---------------------------------------------------------------------- |
| S1            | PRB01            | CPU sử dụng vượt ngưỡng trong khoảng thời gian xác định                |
| S2            | PRB02            | RAM sử dụng vượt ngưỡng                                                |
| S3            | PRB03            | Dung lượng ổ đĩa sử dụng vượt ngưỡng                                   |
| S4            | PRB04            | Máy chủ mất kết nối hoặc không còn hoạt động                           |
| S5            | PRB05            | Dịch vụ Web không thể truy cập hoặc không phản hồi                     |
| S6            | PRB07            | Database không thể truy cập hoặc không thực hiện được kết nối kiểm tra |

Các vấn đề PRB06, PRB08, PRB09 và PRB10 vẫn được ghi nhận trong khảo sát. Việc đưa chúng vào bộ tình huống cảnh báo nghiệm thu sẽ được xem xét trong các giai đoạn tiếp theo.

## 6. Nhu cầu tổng quan của hệ thống

Từ các vấn đề đã xác định, hệ thống cần đáp ứng những nhu cầu tổng quan sau:

### 6.1. Thu thập dữ liệu

- Thu thập thông tin hoạt động của máy chủ.
- Thu thập dữ liệu liên quan đến dịch vụ Web và Database.
- Có khả năng thu thập dữ liệu định kỳ từ các đối tượng giám sát.
- Lưu trữ dữ liệu để phục vụ theo dõi và đánh giá.

### 6.2. Hiển thị và theo dõi

- Cung cấp giao diện giám sát tập trung.
- Hiển thị tình trạng hoạt động của các máy chủ và dịch vụ.
- Hỗ trợ theo dõi dữ liệu hiện tại và lịch sử.
- Giúp người quản trị nhận biết những thành phần đang gặp vấn đề.

### 6.3. Phát hiện và cảnh báo

- Phát hiện khi máy chủ hoặc dịch vụ không còn hoạt động.
- Phát hiện các dấu hiệu sử dụng tài nguyên bất thường.
- Cho phép cấu hình điều kiện và ngưỡng cảnh báo.
- Gửi thông báo khi phát hiện sự cố.
- Có khả năng thông báo khi tình trạng hoạt động được khôi phục.

### 6.4. Quản lý và mở rộng

- Cho phép bổ sung đối tượng giám sát khi cần thiết.
- Cấu hình giám sát có khả năng quản lý và tái sử dụng.
- Lưu trữ cấu hình, dashboard và các thành phần liên quan trong GitHub.
- Hỗ trợ triển khai lại môi trường phục vụ kiểm thử và trình diễn.

## 7. Giải pháp công nghệ định hướng

Dựa trên định hướng ban đầu của nhóm, các công nghệ dự kiến được sử dụng gồm:

| Công nghệ         | Vai trò                                             |
| ----------------- | --------------------------------------------------- |
| Ubuntu Server     | Hệ điều hành cho các máy chủ mô phỏng               |
| Prometheus        | Thu thập, lưu trữ và truy vấn dữ liệu giám sát      |
| Grafana           | Hiển thị dữ liệu và xây dựng Dashboard              |
| Alertmanager      | Quản lý và chuyển tiếp cảnh báo                     |
| Node Exporter     | Cung cấp dữ liệu giám sát máy chủ Linux             |
| Blackbox Exporter | Kiểm tra khả năng truy cập HTTP, TCP và các dịch vụ |
| Database Exporter | Cung cấp dữ liệu giám sát chuyên biệt cho Database  |
| Telegram          | Kênh nhận thông báo cảnh báo                        |
| VirtualBox        | Tạo và quản lý môi trường máy ảo thử nghiệm         |

Lưu ý:

- Node Exporter và Blackbox Exporter có vai trò khác nhau. Node Exporter cung cấp dữ liệu hệ điều hành; Blackbox Exporter thực hiện phép kiểm tra từ bên ngoài đối với một dịch vụ hoặc endpoint.
- Blackbox Exporter không thay thế Database Exporter.
- Các công nghệ trên là định hướng ban đầu, cần được kiểm chứng trong quá trình thiết kế và triển khai prototype.

## 8. Giới hạn khảo sát và triển khai

Trong giai đoạn đầu, nhóm tập trung vào prototype trên môi trường máy ảo.

### 8.1. Nội dung nằm trong phạm vi prototype dự kiến

- Giám sát tài nguyên máy chủ Linux.
- Giám sát trạng thái dịch vụ Web.
- Giám sát khả năng kết nối và một số chỉ số Database.
- Giám sát quá trình thu thập dữ liệu.
- Hiển thị Dashboard và gửi cảnh báo.
- Mô phỏng một số sự cố để kiểm thử hệ thống.

### 8.2. Nội dung chưa nằm trong phạm vi triển khai ban đầu

- Giám sát toàn bộ hạ tầng Data Center production.
- Giám sát phần cứng máy chủ vật lý thực tế.
- Giám sát UPS, nguồn điện, hệ thống làm mát và cảm biến môi trường.
- Tích hợp đầy đủ với API của các nền tảng Cloud thương mại.
- Giám sát Kubernetes hoặc hạ tầng container quy mô lớn.
- Mô phỏng nhiều Data Center hoặc nhiều site độc lập, trừ khi được nhóm thống nhất bổ sung.
- Tự động khắc phục sự cố.
- Giám sát bảo mật chuyên sâu.
- Triển khai hệ thống phân tán quy mô lớn.

Các nội dung trên có thể được xem xét mở rộng nếu có yêu cầu từ mentor và đủ nguồn lực thực hiện.

## 9. Những vấn đề cần xác nhận thêm

Các nội dung dưới đây chưa được chốt. Nhóm cần phân biệt vấn đề nào có thể tự quyết định và vấn đề nào cần mentor xác nhận.

| STT | Nội dung cần xác nhận                                               | Người phụ trách xác nhận                      | Hạn dự kiến                     | Trạng thái      |
| --- | ------------------------------------------------------------------- | --------------------------------------------- | ------------------------------- | --------------- |
| 1   | Có bắt buộc triển khai giám sát Cloud thực tế hay chỉ cần mô phỏng? | Nhóm 1 đề xuất, Mentor xác nhận               | Tuần 6                          | Chưa xác nhận   |
| 2   | Có cần mô phỏng thêm thành phần đặc trưng của Data Center không?    | Nhóm 1 đề xuất, Mentor xác nhận               | Tuần 6                          | Chưa xác nhận   |
| 3   | Có cần mô phỏng nhiều site hoặc nhiều cụm máy chủ không?            | Nhóm 1 đề xuất, Mentor xác nhận               | Tuần 6                          | Chưa xác nhận   |
| 4   | Sử dụng MySQL hay PostgreSQL?                                       | Nhóm 2 đề xuất và quyết định, phối hợp Nhóm 3 | Trước khi dựng VM3 trong Tuần 5 | Chưa quyết định |
| 5   | Số lượng máy chủ tối thiểu cần giám sát khi nghiệm thu?             | Nhóm 1 đề xuất, Mentor xác nhận               | Tuần 6                          | Chưa xác nhận   |
| 6   | Những tiêu chí cụ thể dùng để đánh giá prototype?                   | Nhóm 1 tổng hợp, Mentor xác nhận              | Tuần 6                          | Chưa xác nhận   |

Ghi chú:

- Nhóm có thể chủ động quyết định các lựa chọn kỹ thuật nội bộ nếu không làm thay đổi phạm vi, tiêu chí nghiệm thu hoặc yêu cầu của mentor.
- Việc lựa chọn MySQL hay PostgreSQL cần được thống nhất với Nhóm 3 để bảo đảm exporter và phương pháp giám sát tương ứng.
- Các nội dung liên quan đến Cloud, Data Center và tiêu chí nghiệm thu cần được xác nhận trước khi chốt thiết kế.

## 10. Kết luận

Qua khảo sát ban đầu, nhóm xác định nhu cầu xây dựng một hệ thống giám sát tập trung có khả năng theo dõi tình trạng hoạt động của máy chủ, dịch vụ Web, cơ sở dữ liệu và một số thành phần liên quan đến hạ tầng Cloud và Data Center.

Trong phạm vi prototype, nhóm định hướng sử dụng ba máy ảo để mô phỏng máy chủ giám sát, máy chủ Web và máy chủ Database. Hệ thống dự kiến sử dụng Prometheus để thu thập và lưu trữ dữ liệu, Grafana để hiển thị thông tin và Alertmanager để quản lý, chuyển tiếp cảnh báo.

Các vấn đề vận hành đã được mã hóa và phân loại theo đối tượng, nhu cầu giám sát và mức ưu tiên. Đây là cơ sở để tiếp tục xác định Metrics, xây dựng tình huống cảnh báo, phân tích yêu cầu và thiết kế hệ thống trong các giai đoạn tiếp theo.

Phạm vi giám sát Cloud và Data Center thực tế vẫn cần được xác nhận với mentor trước khi mở rộng prototype.

## 11. Tài liệu tham khảo

Các tài liệu dưới đây được sử dụng để tìm hiểu công nghệ giám sát và các thành phần kỹ thuật dự kiến. Danh sách vấn đề vận hành trong tài liệu là kết quả phân tích ban đầu của nhóm dựa trên các đối tượng khảo sát, không phải nội dung sao chép nguyên văn từ một nguồn duy nhất.

1. Prometheus Documentation – Overview: https://prometheus.io/docs/introduction/overview/
2. Prometheus Documentation – Node Exporter Guide: https://prometheus.io/docs/guides/node-exporter/
3. Prometheus Documentation – Alerting: https://prometheus.io/docs/alerting/latest/overview/
4. Prometheus Documentation – Blackbox Exporter: https://prometheus.io/docs/guides/multi-target-exporter/
5. Grafana Documentation: https://grafana.com/docs/grafana/latest/
6. NIST Special Publication 800-145 – The NIST Definition of Cloud Computing: https://doi.org/10.6028/NIST.SP.800-145
7. Prometheus MySQL Exporter – https://github.com/prometheus/mysqld_exporter
8. Prometheus PostgreSQL Exporter – https://github.com/prometheus-community/postgres_exporter

Các tài liệu này cần được đối chiếu với phiên bản công cụ mà nhóm thực tế sử dụng trong giai đoạn triển khai.

---

**Tài liệu liên quan:**

- Jira Task: SCRUM-6 – Khảo sát bài toán giám sát hệ thống.
- Task tiếp theo: Liệt kê và phân loại Metrics.
- Task tiếp theo: Xây dựng tình huống cảnh báo.
- Tài liệu kế hoạch kiểm thử và tiêu chí nghiệm thu của dự án N4.7.
