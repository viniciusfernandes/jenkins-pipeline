# Dockerfile
FROM jenkins/jenkins:lts-jdk21

# Run as root to install plugins and set up permissions
USER root

# Install all plugins from the plugin list
# Set the update center BEFORE running plugin installation
ENV JENKINS_UC_DOWNLOAD=https://updates.jenkins.io/download
ENV JENKINS_UC=https://updates.jenkins.io

COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
COPY init.groovy.d/ /usr/share/jenkins/ref/init.groovy.d/

RUN jenkins-plugin-cli --verbose --plugin-file /usr/share/jenkins/ref/plugins.txt

# Optional: Disable setup wizard for automation
ENV JAVA_OPTS="-Djenkins.install.runSetupWizard=false"



# Return to the default Jenkins user
USER jenkins
