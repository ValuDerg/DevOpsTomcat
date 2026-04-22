FROM tomcat:11

# Remove default ROOT app
RUN rm -rf /usr/local/tomcat/webapps/ROOT/*

# Copy your app into ROOT
COPY . /usr/local/tomcat/webapps/ROOT

EXPOSE 8080
