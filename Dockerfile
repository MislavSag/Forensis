FROM rocker/shiny

WORKDIR /app

RUN apt update && apt install -y libglpk-dev \
  libmysqlclient-dev \
    pandoc \
    pandoc-citeproc \
    curl \
    gdebi-core \
    && rm -rf /var/lib/apt/lists/*

COPY install.R /app/

RUN curl -LO https://quarto.org/download/latest/quarto-linux-amd64.deb
RUN gdebi --non-interactive quarto-linux-amd64.deb

RUN Rscript install.R

COPY . /app/

ENTRYPOINT ["Rscript", "startApp.R"]
