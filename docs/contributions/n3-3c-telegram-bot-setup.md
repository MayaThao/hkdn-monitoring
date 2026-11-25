# Thiết lập Telegram Bot và kiểm tra Bot API

## 1. Tổng quan

Tài liệu này ghi nhận quá trình tạo Telegram Bot và kiểm tra khả năng giao tiếp thông qua Telegram Bot API trong dự án HKDN Monitoring.

- **Nhóm phụ trách:** N3
- **Thành viên:** N3-3C
- **Task liên quan:** SCRUM-35 – Tạo Telegram Bot và kiểm tra Bot API
- **Tên Bot:** HKDN Monitoring Alert
- **Username:** `@HKDN_Monitoring_Alert_Bot`
- **Môi trường kiểm thử:** Ubuntu Server

## 2. Mục tiêu

- Tạo Telegram Bot phục vụ việc nhận thông báo giám sát.
- Khởi tạo cuộc trò chuyện với Bot.
- Lấy `chat_id` thông qua Telegram Bot API.
- Kiểm tra khả năng gửi tin nhắn bằng phương thức `sendMessage`.
- Chuẩn bị thông tin cần thiết cho bước tích hợp Alertmanager với Telegram tại SCRUM-36.

## 3. Quá trình thực hiện

### 3.1. Tạo Telegram Bot

Sử dụng BotFather trên Telegram để tạo Bot mới.

Thông tin Bot:

| Thuộc tính | Giá trị |
|---|---|
| Tên Bot | HKDN Monitoring Alert |
| Username | `@HKDN_Monitoring_Alert_Bot` |
| Nền tảng | Telegram |

Sau khi tạo thành công, BotFather cung cấp Bot Token để xác thực khi gọi Telegram Bot API.

**Lưu ý bảo mật:** Bot Token là thông tin bí mật, không đưa trực tiếp vào tài liệu hoặc commit lên GitHub.

### 3.2. Khởi tạo cuộc trò chuyện

- Tìm kiếm Bot `@HKDN_Monitoring_Alert_Bot` trên Telegram.
- Mở cuộc trò chuyện với Bot.
- Gửi lệnh:

```text
/start
```

Thao tác này giúp khởi tạo cuộc trò chuyện và tạo bản cập nhật để truy xuất thông tin thông qua Bot API.

### 3.3. Lấy Group Chat ID bằng getUpdates

Sau khi thêm Bot `@HKDN_Monitoring_Alert_Bot` vào nhóm Telegram `HKDN Monitoring Alerts`, tiến hành gửi tin nhắn trong nhóm để tạo bản cập nhật cho Bot.

Trên Ubuntu Server, nhập Bot Token thông qua biến môi trường:

```bash
read -s -p "Nhap Telegram Bot Token: " BOT_TOKEN
echo
```

Gọi API:

```bash
curl -s "https://api.telegram.org/bot${BOT_TOKEN}/getUpdates" | jq
```

Lọc thông tin các nhóm Telegram mà Bot nhận được cập nhật:

```bash
curl -s "https://api.telegram.org/bot${BOT_TOKEN}/getUpdates" | jq -r '
.result[] |
select(.message.chat.type == "group" or .message.chat.type == "supergroup") |
"Group: \(.message.chat.title)\nType: \(.message.chat.type)\nChat ID: \(.message.chat.id)\n---"
'
```

Thông tin nhóm thu được:

| Thuộc tính | Giá trị |
|---|---|
| Tên nhóm | HKDN Monitoring Alerts |
| Loại nhóm | group |
| Group Chat ID | `-5441789523` |

Group Chat ID được sử dụng làm địa chỉ nhận thông báo khi gọi phương thức `sendMessage`.

### 3.4. Kiểm tra gửi tin nhắn vào Telegram Group

Khai báo Group Chat ID:

```bash
GROUP_ID="-5441789523"
```

Sử dụng phương thức `sendMessage` để gửi tin nhắn thử nghiệm:

```bash
curl -s -X POST "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage" \
  -d "chat_id=${GROUP_ID}" \
  --data-urlencode "text=HKDN Monitoring: Telegram Group notification test successful!" \
  | jq
```

Kiểm tra phản hồi từ Telegram Bot API và nhóm Telegram.

Kết quả thực tế:

- API trả về `ok: true`.
- Bot gửi tin nhắn thành công vào nhóm `HKDN Monitoring Alerts`.
- `chat.id` trong phản hồi trùng khớp với Group Chat ID đã truy xuất.
- Tin nhắn thử nghiệm xuất hiện trong nhóm Telegram.

Sau khi hoàn thành kiểm thử, xóa các biến khỏi phiên terminal:

```bash
unset BOT_TOKEN
unset GROUP_ID
```

## 4. Kết quả kiểm thử

| STT | Nội dung kiểm thử | Kết quả thực tế | Trạng thái |
|---|---|---|---|
| 1 | Khởi tạo cuộc trò chuyện với Bot bằng `/start` | Đã khởi tạo thành công | Đạt |
| 2 | Gọi API `getUpdates` để lấy thông tin chat cá nhân | Đã lấy được `chat_id` cá nhân | Đạt |
| 3 | Gọi API `sendMessage` để kiểm tra gửi tin nhắn cá nhân | Đã nhận được tin nhắn thử nghiệm | Đạt |
| 4 | Thêm Bot vào nhóm Telegram Monitoring | Bot đã tham gia nhóm thành công | Đạt |
| 5 | Gọi API `getUpdates` để lấy Group Chat ID | Đã lấy được Group Chat ID `-5441789523` | Đạt |
| 6 | Gọi API `sendMessage` để kiểm tra gửi tin nhắn vào nhóm | Tin nhắn được gửi thành công vào nhóm `HKDN Monitoring Alerts` | Đạt |

## 5. Kết luận

Đã hoàn thành việc tạo Telegram Bot và kiểm tra khả năng giao tiếp thông qua Telegram Bot API.

Các kết quả đạt được:

- Tạo thành công Bot `HKDN Monitoring Alert`.
- Kiểm tra khả năng gửi tin nhắn thông qua Bot API.
- Thêm Bot vào nhóm Telegram `HKDN Monitoring Alerts`.
- Truy xuất thành công Group Chat ID.
- Gửi và nhận thành công tin nhắn thử nghiệm trong nhóm Telegram.

**Định hướng sử dụng:** Nhóm Telegram `HKDN Monitoring Alerts` được xác định là kênh nhận thông báo cảnh báo chung của dự án, thay vì sử dụng chat cá nhân.

Telegram Bot đã sẵn sàng cho bước tích hợp với Prometheus và Alertmanager trong SCRUM-36.

**Phạm vi kiểm thử:** Các kết quả trên xác nhận khả năng gửi tin nhắn trực tiếp từ Telegram Bot API đến nhóm Telegram. Chưa kiểm tra luồng gửi cảnh báo tự động từ Prometheus thông qua Alertmanager.

## 6. Lưu ý bảo mật

- Không commit Bot Token lên GitHub.
- Không ghi Bot Token trực tiếp trong tài liệu hoặc ảnh chụp màn hình.
- Sử dụng biến môi trường để quản lý thông tin xác thực khi kiểm thử.
- Che các thông tin nhạy cảm trước khi đưa ảnh bằng chứng vào repository.

## 7. Bằng chứng thực hiện

| STT | Tên ảnh | Nội dung xác nhận |
|---|---|---|
| 1 | `telegram-bot-created.png` | Telegram Bot HKDN Monitoring Alert đã được tạo |
| 2 | `telegram-bot-api-configuration.png` | Xác minh Bot API, lấy Group Chat ID và kiểm tra gửi tin nhắn vào nhóm bằng Ubuntu Server |
| 3 | `telegram-group-message-received.png` | Tin nhắn thử nghiệm được gửi thành công đến nhóm HKDN Monitoring Alerts |

Thư mục lưu bằng chứng:

```text
monitoring/evidence/25-11-2026
```
