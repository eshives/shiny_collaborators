FROM rocker/tidyverse

RUN Rscript -e "install.packages('tm')"
RUN Rscript -e "install.packages('shiny')"
RUN Rscript -e "install.packages('wordcloud')"
RUN Rscript -e "install.packages('memoise')"