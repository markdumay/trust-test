FROM alpine

COPY message.txt /

ENTRYPOINT ["cat", "/message.txt"]