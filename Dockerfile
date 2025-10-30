# Base image: Jenkins LTS with JDK 21
FROM jenkins/jenkins:lts-jdk21

# Switch to root for installation steps
USER root

# ------------------------------------------------------------
# 🔹 1. Set Jenkins Update Center for plugin installation
# ------------------------------------------------------------
ENV JENKINS_UC_DOWNLOAD=https://updates.jenkins.io/download
ENV JENKINS_UC=https://updates.jenkins.io

# Copy plugin definitions and Groovy initialization scripts
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
COPY init.groovy.d/ /usr/share/jenkins/ref/init.groovy.d/

# Install all Jenkins plugins defined in plugins.txt
RUN jenkins-plugin-cli --verbose --plugin-file /usr/share/jenkins/ref/plugins.txt

# Disable setup wizard for automation
ENV JAVA_OPTS="-Djenkins.install.runSetupWizard=false"

# ------------------------------------------------------------
# 🔹 2. Install Docker CLI inside Jenkins
# ------------------------------------------------------------

# Install dependencies and Docker CLI
# We dont need to install FULL Docker
RUN apt-get update && \
    apt-get install -y ca-certificates curl gnupg lsb-release && \
    mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) \
        signed-by=/etc/apt/keyrings/docker.gpg] \
        https://download.docker.com/linux/debian \
        $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    apt-get update && \
    apt-get install -y docker-ce-cli docker-compose-plugin && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# ------------------------------------------------------------
# 🔹 3. Add Jenkins user to docker group
# ------------------------------------------------------------

# Create docker group if not exists, then add jenkins to it
RUN groupadd -f docker && usermod -aG docker jenkins

# ------------------------------------------------------------
# 🔹 4. Return to Jenkins user
# ------------------------------------------------------------

USER jenkins
