FROM mcr.microsoft.com/mssql/server:2019-latest

USER root

WORKDIR /src

COPY prep-server.sql /src/prep-server.sql
COPY configure.sh /src/configure.sh
COPY entrypoint.sh /src/entrypoint.sh

RUN chmod +x /src/configure.sh
RUN chmod +x /src/entrypoint.sh

USER mssql

ENTRYPOINT [ "/src/entrypoint.sh" ]