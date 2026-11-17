# CONTRIBUTING – Quy định đóng góp và làm việc nhóm

Dự án: **Xây dựng hệ thống giám sát máy chủ, Cloud và trung tâm dữ liệu**

Chương trình: Học kỳ doanh nghiệp UTH – VNPT NET

## 1. Mục đích

Tài liệu này quy định cách các thành viên đóng góp vào repository của dự án, nhằm đảm bảo:

- Công việc giữa các nhóm được phối hợp thống nhất.
- Các thay đổi có mục đích rõ ràng và có thể kiểm tra.
- Tài liệu, cấu hình và kết quả thử nghiệm được lưu trữ có hệ thống.
- Hạn chế xung đột khi nhiều thành viên cùng làm việc.
- Đảm bảo sản phẩm có thể được tái tạo, kiểm thử và bàn giao.

## 2. Nguyên tắc đóng góp

Mỗi thành viên cần tuân thủ các nguyên tắc sau:

1. Chịu trách nhiệm về nội dung mình đóng góp, bao gồm tính chính xác và khả năng sử dụng.
2. Mỗi thay đổi cần có mục đích rõ ràng, phù hợp với phạm vi và mục tiêu dự án.
3. Ưu tiên các giải pháp đơn giản, dễ triển khai, dễ kiểm thử và dễ bảo trì.
4. Khi thay đổi cấu hình hoặc kết quả thử nghiệm, cần cập nhật tài liệu và minh chứng liên quan.
5. Không đưa mật khẩu, token, private key hoặc dữ liệu nội bộ chưa được phép chia sẻ lên GitHub.
6. Nội dung được hỗ trợ bởi AI phải được người thực hiện kiểm tra, hiểu rõ và chịu trách nhiệm trước khi đưa vào dự án.
7. Không tự ý thay đổi kiến trúc, yêu cầu hoặc tiêu chí nghiệm thu đã thống nhất mà chưa trao đổi với người phụ trách.

## 3. Quy định về Branch

### 3.1. Branch chính

| Branch | Mục đích                         |
| ------ | -------------------------------- |
| `main` | Chứa phiên bản ổn định của dự án |

Không tạo branch cố định cho từng nhóm. Các thành viên tạo branch riêng theo từng nhiệm vụ và xóa sau khi hoàn thành.

### 3.2. Quy tắc đặt tên Branch

Sử dụng cấu trúc:

```text
<type>/n<group>-<short-description>
```

Trong đó:

| Type      | Mục đích                        |
| --------- | ------------------------------- |
| `docs`    | Chỉnh sửa tài liệu              |
| `feature` | Bổ sung chức năng               |
| `config`  | Thay đổi cấu hình               |
| `test`    | Bổ sung hoặc chỉnh sửa kiểm thử |
| `fix`     | Sửa lỗi                         |

Ví dụ:

```text
docs/n1-update-requirements
config/n3-prometheus-rules
feature/n3-grafana-dashboard
test/n4-host-down
fix/n2-nginx-config
```

## 4. Quy định Commit

### 4.1. Cấu trúc Commit Message

Sử dụng tiền tố nhóm và mô tả ngắn gọn nội dung thay đổi:

```text
[Nx] <short-description>
```

Ví dụ:

```text
[N1] Add initial system requirements
[N2] Add Ubuntu VM setup guide
[N3] Configure Prometheus targets
[N4] Add host down test cases
```

Trong đó `Nx` tương ứng với nhóm thực hiện:

- `[N1]`: Nhóm Phân tích và Thiết kế.
- `[N2]`: Nhóm Hạ tầng và Môi trường.
- `[N3]`: Nhóm Monitoring và Phát triển.
- `[N4]`: Nhóm Kiểm thử và Đánh giá.

### 4.2. Nguyên tắc Commit

- Một commit nên tập trung vào một mục đích cụ thể.
- Không gộp quá nhiều thay đổi không liên quan trong cùng một commit.
- Không commit file tạm, file sinh tự động không cần thiết hoặc dữ liệu dung lượng lớn.
- Kiểm tra `git status` trước khi commit.
- Ưu tiên sử dụng `git add <file-path>` để chọn chính xác các file cần đưa vào commit.

## 5. Quy trình làm việc với GitHub

### 5.1. Quy trình cơ bản

```bash
# 1. Chuyển về branch main
git switch main

# 2. Cập nhật phiên bản mới nhất
git pull origin main

# 3. Tạo branch cho nhiệm vụ
git switch -c docs/n1-update-requirements

# 4. Kiểm tra các thay đổi
git status

# 5. Đưa file cần thiết vào staging
git add <file-path>

# 6. Commit
git commit -m "[N1] Update system requirements"

# 7. Đẩy branch lên GitHub
git push -u origin docs/n1-update-requirements
```

Sau khi push, thành viên tạo Pull Request (PR) trên GitHub để đề xuất đưa thay đổi vào `main` nếu nhiệm vụ thuộc diện cần review.

### 5.2. Quy định Pull Request

Các thay đổi quan trọng cần tạo PR, bao gồm:

- Thay đổi yêu cầu, phạm vi, kiến trúc và thiết kế hệ thống.
- Thay đổi cấu hình Prometheus, Alertmanager, Grafana và các thành phần monitoring chính.
- Thay đổi hạ tầng hoặc script ảnh hưởng đến nhiều nhóm.
- Thay đổi Test Plan, Test Cases và kết quả kiểm thử chính thức.
- Thay đổi README và CONTRIBUTING.

Các chỉnh sửa nhỏ, ít rủi ro như ghi nhận biên bản họp hoặc cập nhật tài liệu nội bộ có thể commit trực tiếp vào `main` nếu các thành viên thống nhất.

**Lộ trình áp dụng:**

- Tuần 3–5: Có thể commit trực tiếp các thay đổi nhỏ, ít rủi ro.
- Từ tuần 6: Các thay đổi trong `monitoring/` cần thực hiện qua PR để đảm bảo có review trước khi tích hợp.

### 5.3. Nội dung Pull Request

Mỗi PR cần mô tả:

- **Mục đích:** Vì sao cần thực hiện thay đổi?
- **Nội dung:** Những file hoặc thành phần nào được chỉnh sửa?
- **Kết quả:** Đã đạt được kết quả gì?
- **Minh chứng:** Ảnh chụp, log hoặc kết quả kiểm thử nếu có.
- **Liên kết:** Jira Issue, Acceptance Criteria hoặc Test Case liên quan.
- **Xác nhận:** Nội dung được hỗ trợ bởi AI (nếu có) đã được người thực hiện kiểm tra và hiểu rõ.

### 5.4. Review và Merge

- PR cần được ít nhất một thành viên khác review trước khi merge.
- Người review cần kiểm tra tính đúng đắn, khả năng hoạt động và sự phù hợp với phạm vi dự án.
- Người tạo PR có trách nhiệm giải quyết các góp ý trước khi merge.
- Người có chuyên môn phù hợp nên review các thay đổi thuộc lĩnh vực mình phụ trách.
- Team Leader xem xét các thay đổi ảnh hưởng đến kiến trúc, phạm vi hoặc sự phối hợp giữa nhiều nhóm.

Sau khi PR được merge:

```bash
git switch main
git pull origin main
```

Có thể xóa branch đã hoàn thành trên GitHub và máy local để tránh tích lũy branch không cần thiết.

## 6. Phân công Review giữa các nhóm

| Nội dung thay đổi                                     | Người review đề xuất                         |
| ----------------------------------------------------- | -------------------------------------------- |
| Yêu cầu và thiết kế hệ thống                          | Nhóm 3 hoặc Nhóm 4                           |
| Hạ tầng và cấu hình máy ảo                            | Nhóm 3                                       |
| Monitoring và Alerting                                | Nhóm 4                                       |
| Test Plan và Test Report                              | Nhóm 1 hoặc thành viên có chuyên môn phù hợp |
| Thay đổi kiến trúc, phạm vi hoặc ảnh hưởng nhiều nhóm | Nhóm 1 và các nhóm liên quan                 |

Người review không nhất thiết phải là Team Leader. Việc review nên được thực hiện bởi người có đủ hiểu biết về nội dung thay đổi.

**Thời gian phản hồi review đề xuất:** Trong vòng 2 ngày làm việc.

Nếu PR quá thời hạn chưa được review, người tạo PR chủ động nhắc trên Jira hoặc nhóm trao đổi. Nếu vẫn chưa có phản hồi, báo Team Leader để điều phối.

## 7. Quy định về tài liệu và minh chứng

### 7.1. Tài liệu kỹ thuật

Khi viết tài liệu hướng dẫn hoặc mô tả kỹ thuật, nên có các nội dung:

- Mục đích.
- Môi trường thực hiện.
- Các bước triển khai.
- Cấu hình hoặc lệnh sử dụng.
- Kết quả mong đợi và kết quả thực tế.
- Lỗi gặp phải và cách xử lý (nếu có).
- Minh chứng thực hiện.

### 7.2. Trạng thái tài liệu

Các tài liệu quan trọng có thể sử dụng trạng thái:

| Trạng thái | Ý nghĩa                              |
| ---------- | ------------------------------------ |
| Draft      | Đang soạn thảo                       |
| In Review  | Đang chờ review                      |
| Approved   | Đã được người có thẩm quyền xác nhận |

Lưu ý: Việc merge tài liệu vào `main` không đồng nghĩa với việc tài liệu đã được Mentor hoặc đơn vị phụ trách chính thức phê duyệt.

### 7.3. Lưu trữ minh chứng

Minh chứng nên được lưu tại thư mục phù hợp:

```text
infra/evidence/
monitoring/evidence/
tests/evidence/
```

Ví dụ tên file:

```text
vm2-ssh-ok.png
host-down-alert-AC03.png
grafana-cpu-dashboard.png
database-unreachable-AC08.png
```

Mỗi minh chứng cần gắn với Jira Issue, Acceptance Criteria hoặc Test Case tương ứng khi có thể.

Không đưa các file dung lượng lớn như `.vdi`, `.vmdk`, file ISO hoặc video demo dung lượng lớn vào repository. Có thể sử dụng kho lưu trữ phù hợp và dẫn liên kết trong tài liệu nếu cần.

## 8. Quy định bảo mật

Tuyệt đối không đưa các thông tin sau lên repository:

- Mật khẩu đăng nhập.
- API Token, Bot Token.
- Private Key.
- File `.env` chứa thông tin thật.
- Dữ liệu nội bộ của VNPT NET chưa được phép chia sẻ.
- Thông tin cá nhân hoặc dữ liệu nhạy cảm không cần thiết.

Nên bổ sung các file nhạy cảm vào `.gitignore`, ví dụ:

```gitignore
.env
*.key
*.pem
*.log
```

Nếu cần chia sẻ cấu hình mẫu, sử dụng file `.env.example` và chỉ điền các giá trị giả định.

Nếu phát hiện thông tin nhạy cảm đã bị đẩy lên GitHub, cần thông báo ngay cho Team Leader và thu hồi hoặc thay đổi thông tin bị lộ. Xóa file khỏi commit mới không có nghĩa là dữ liệu đã biến mất khỏi lịch sử Git.

## 9. Quy định phối hợp giữa các nhóm

- Mỗi nhóm chủ động triển khai công việc thuộc phạm vi chuyên môn đã được phân công.
- Các nhóm cần cập nhật tiến độ và khó khăn trên Jira.
- Khi công việc ảnh hưởng đến nhiều nhóm, cần trao đổi trước khi thực hiện.
- Những thay đổi liên quan đến yêu cầu, kiến trúc hoặc Acceptance Criteria cần được Nhóm 1 điều phối và thống nhất.
- Các quyết định quan trọng cần được ghi nhận để tránh hiểu nhầm trong quá trình triển khai.

### 9.1. Khi cần hỗ trợ hoặc chưa nhận được phản hồi

- Thành viên cần chủ động trao đổi với nhóm liên quan hoặc Team Leader.
- Nhóm 1 cố gắng phản hồi các vấn đề phối hợp trong vòng 48 giờ.
- Nếu chưa nhận được phản hồi, nhóm có thể tiếp tục các công việc độc lập, không bị ảnh hưởng.
- Với các lựa chọn kỹ thuật nội bộ có thể đảo ngược, nhóm có thể tạm chọn phương án đơn giản, ít rủi ro và ghi nhận quyết định trên Jira để xem xét sau.
- Không tự ý quyết định hoặc triển khai những thay đổi liên quan đến phạm vi đề tài, yêu cầu nghiệm thu, bảo mật hoặc nội dung cần Mentor/đơn vị phụ trách xác nhận.

## 10. Quản lý công việc trên Jira

Jira được sử dụng làm công cụ quản lý công việc, theo dõi tiến độ và phối hợp giữa các nhóm.

### 10.1. Quản lý nhiệm vụ

- Mỗi nhiệm vụ cần được tạo thành một Jira Issue.
- Issue cần có tiêu đề rõ ràng, mô tả công việc, người phụ trách và thời hạn dự kiến.
- Các nhiệm vụ lớn có thể được chia thành các Sub-task để dễ theo dõi.
- Issue cần liên kết với Acceptance Criteria, Test Case hoặc Pull Request nếu có liên quan.

### 10.2. Theo dõi trạng thái

Nhóm sử dụng Jira Board để theo dõi tiến độ công việc. Các trạng thái dự kiến:

| Trạng thái      | Ý nghĩa                              |
| --------------- | ------------------------------------ |
| Backlog / To Do | Công việc chưa bắt đầu               |
| In Progress     | Đang thực hiện                       |
| In Review       | Đang chờ review hoặc kiểm tra        |
| Done            | Đã hoàn thành và được xác nhận       |
| Blocked         | Đang bị vướng mắc, chưa thể tiếp tục |

Tên trạng thái thực tế có thể được điều chỉnh theo workflow của Jira mà nhóm thiết lập.

### 10.3. Cập nhật tiến độ

- Thành viên chủ động cập nhật trạng thái Issue khi bắt đầu, hoàn thành hoặc gặp trở ngại.
- Khi công việc bị chặn, cần ghi rõ nguyên nhân và người hoặc nhóm cần hỗ trợ.
- Không chuyển Issue sang Done chỉ vì đã hoàn thành phần code nếu vẫn còn yêu cầu kiểm thử hoặc xác nhận.
- Team Leader theo dõi tổng quan tiến độ và điều phối các nhiệm vụ liên nhóm.

### 10.4. Liên kết Jira với GitHub

Khi có thể, thành viên nên liên kết Jira Issue với branch, commit và Pull Request tương ứng.

Có thể sử dụng mã Issue trong tên branch hoặc commit message, ví dụ:

```text
feature/N3-15-grafana-dashboard
[N3-15] Add Grafana dashboard
```

Mã Issue cần được thay bằng mã thực tế do Jira tạo ra.

---

**Lưu ý cuối:** Tài liệu này là quy định làm việc nội bộ của dự án và có thể được cập nhật khi nhóm thống nhất thay đổi quy trình.
