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

### 3.3. Lấy chat_id bằng getUpdates

Sử dụng phương thức `getUpdates` của Telegram Bot API để lấy thông tin các bản cập nhật mà Bot nhận được.

Trên Ubuntu Server, nhập Bot Token thông qua biến môi trường:

```bash
read -rsp "Enter Telegram Bot Token: " BOT_TOKEN
echo
export BOT_TOKEN
```

Gọi API:

```bash
curl -s "https://api.telegram.org/bot${BOT_TOKEN}/getUpdates"
```

Kiểm tra kết quả trả về và tìm trường `message.chat.id`.

Ví dụ cấu trúc phản hồi:

```json
{
  "message": {
    "chat": {
      "id": "<CHAT_ID>"
    }
  }
}
```

Giá trị `chat.id` được sử dụng làm địa chỉ nhận tin nhắn khi gọi phương thức `sendMessage`.

### 3.4. Kiểm tra gửi tin nhắn bằng sendMessage

Sử dụng `chat_id` đã lấy được để gửi tin nhắn thử nghiệm:

```bash
curl -s -X POST \
  "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage" \
  -d "chat_id=<CHAT_ID>" \
  --data-urlencode "text=Test notification from HKDN Monitoring"
```

Thay `<CHAT_ID>` bằng giá trị thực tế đã lấy từ bước trước.

Sau khi thực hiện, kiểm tra cuộc trò chuyện Telegram để xác nhận Bot đã gửi tin nhắn thành công.

## 4. Kết quả kiểm thử

| STT | Nội dung kiểm thử | Kết quả mong đợi | Kết quả thực tế | Trạng thái |
|---|---|---|---|---|
| 1 | Gửi lệnh `/start` | Khởi tạo cuộc trò chuyện với Bot | Đã khởi tạo thành công | Đạt |
| 2 | Gọi API `getUpdates` | Nhận được thông tin cập nhật và `chat_id` | Đã lấy được `chat_id` | Đạt |
| 3 | Gọi API `sendMessage` | Bot gửi được tin nhắn đến cuộc trò chuyện | Đã nhận được tin nhắn thử nghiệm | Đạt |

## 5. Kết luận

Đã hoàn thành việc tạo Telegram Bot và kiểm tra các chức năng cơ bản của Telegram Bot API.

Các kết quả đạt được:

- Tạo thành công Bot `HKDN Monitoring Alert`.
- Khởi tạo cuộc trò chuyện với Bot.
- Truy xuất thành công `chat_id`.
- Gửi và nhận thành công tin nhắn thử nghiệm từ Ubuntu Server.

Telegram Bot đã sẵn sàng cho bước tích hợp với Prometheus và Alertmanager trong SCRUM-36.

**Phạm vi kiểm thử:** Các kết quả trên chỉ xác nhận khả năng giao tiếp trực tiếp với Telegram Bot API. Chưa kiểm tra luồng gửi cảnh báo tự động từ Prometheus thông qua Alertmanager.

## 6. Lưu ý bảo mật

- Không commit Bot Token lên GitHub.
- Không ghi Bot Token trực tiếp trong tài liệu hoặc ảnh chụp màn hình.
- Sử dụng biến môi trường để quản lý thông tin xác thực khi kiểm thử.
- Che các thông tin nhạy cảm trước khi đưa ảnh bằng chứng vào repository.

## 7. Bằng chứng thực hiện

Các bằng chứng nên được lưu kèm tài liệu:

| STT | Bằng chứng | Nội dung xác nhận |
|---|---|---|
| 1 | Ảnh cuộc trò chuyện Telegram | Bot đã được tạo và khởi tạo |
| 2 | Ảnh kết quả `getUpdates` | Truy xuất được `chat_id` |
| 3 | Ảnh tin nhắn thử nghiệm | Bot gửi tin nhắn thành công |

Thư mục đề xuất lưu bằng chứng:

```text
infra/evidence/telegram-bot/
```

