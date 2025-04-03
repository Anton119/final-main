# Используем официальный образ Go как базовый для сборки
FROM golang:alpine AS builder



# Устанавливаем рабочую директорию внутри контейнера
WORKDIR /final-main

# Копируем файлы go.mod и go.sum в контейнер
COPY go.mod go.sum ./

# Загружаем зависимости
RUN go mod tidy

# Копируем весь код из текущей директории в контейнер
COPY . .

# Собираем приложение
RUN go build -o main .

# Используем более легкий образ для финального контейнера
FROM alpine:latest

# Устанавливаем необходимые библиотеки для работы с SQLite
RUN apk --no-cache add sqlite-libs

# Копируем собранный бинарный файл из этапа сборки
COPY --from=builder /final-main/main /usr/local/bin/main

# Устанавливаем рабочую директорию
WORKDIR /final-main

# Копируем базу данных в контейнер
COPY tracker.db /final-main/tracker.db

# Открываем порт для приложения, если требуется
EXPOSE 8080

# Запускаем приложение
CMD ["main"]
