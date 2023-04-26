FROM ubuntu:jammy AS base
WORKDIR /usr/local/bin
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y software-properties-common curl git build-essential sudo && \
    apt-add-repository -y ppa:ansible/ansible && \
    apt-get update && \
    apt-get install -y ansible && \
    apt-get clean autoclean && \
    apt-get autoremove --yes

FROM base AS personal
ARG TAGS
RUN addgroup --gid 1000 vic
RUN adduser --gecos vic --uid 1000 --gid 1000 --disabled-password vic
RUN usermod -aG sudo vic
RUN echo "vic ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/vic
RUN chmod 0440 /etc/sudoers.d/vic
RUN mkdir /home/vic/ansible
WORKDIR /home/vic/ansible
COPY . .
RUN chmod 700 .ssh
RUN chmod 600 .ssh/id_ed25519
RUN chmod 644 .ssh/id_ed25519.pub
RUN chown -R vic:vic .ssh

FROM personal
USER vic
CMD ["ansible-playbook", "$TAGS", "local.yml"]


