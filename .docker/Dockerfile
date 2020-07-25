FROM ruby:alpine3.12
LABEL Author="shridhar.patil@droitfintech.com"  
WORKDIR /opt/dashing
RUN addgroup droit \
    && adduser -S -G droit droit 
RUN apk update && apk add make gcc g++ nodejs
ADD  assets /opt/dashing/assets
ADD  dashboards /opt/dashing/dashboards
ADD  jobs /opt/dashing/jobs
ADD  lib /opt/dashing/lib
ADD  public /opt/dashing/public
ADD  widgets /opt/dashing/widgets
COPY config.ru /opt/dashing/
COPY Gemfile /opt/dashing/
COPY Gemfile.lock /opt/dashing/
RUN   bundle && chown -R droit:droit /opt/dashing && ls -lrt
EXPOSE 3030
USER droit
CMD ["smashing", "start"]
